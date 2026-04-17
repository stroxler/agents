#!/usr/bin/env bash
# codex-wrapper.sh - Call Codex CLI non-interactively with stable output.

set -euo pipefail

MODE="ask"
RESUME_ID=""
MODEL=""
FULL_LOG=false
FULL_AUTO=false
EPHEMERAL=false
PROMPT=""
REVIEW_ARGS=()

usage() {
  cat <<'USAGE'
Usage:
  codex-wrapper.sh [OPTIONS] [PROMPT]
  codex-wrapper.sh --review [--uncommitted | --base BRANCH | --commit REV] [PROMPT]

Options:
  --review          Run a code review via codex exec review.
  --resume ID       Resume an existing Codex session.
  --uncommitted     (review mode) Review working tree diff.
  --base BRANCH     (review mode) Review changes against merge-base with BRANCH.
  --commit REV      (review mode) Review a specific commit/revision.
  --model MODEL     Codex model name (e.g. o3, o4-mini).
  --full-auto       Use workspace-write sandbox (no confirmation prompts).
  --ephemeral       Do not persist session files.
  --full-log        Print full log path in metadata header.
  -h, --help        Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --review)
      MODE="review"
      shift
      ;;
    --resume)
      MODE="resume"
      RESUME_ID="${2:-}"
      if [[ -z "$RESUME_ID" ]]; then
        echo "Missing value for --resume" >&2
        exit 2
      fi
      shift 2
      ;;
    --uncommitted)
      REVIEW_ARGS+=("--uncommitted")
      shift
      ;;
    --base)
      REVIEW_ARGS+=("--base" "${2:-}")
      if [[ -z "${2:-}" ]]; then
        echo "Missing value for --base" >&2
        exit 2
      fi
      shift 2
      ;;
    --commit)
      REVIEW_ARGS+=("--commit" "${2:-}")
      if [[ -z "${2:-}" ]]; then
        echo "Missing value for --commit" >&2
        exit 2
      fi
      shift 2
      ;;
    --model)
      MODEL="${2:-}"
      if [[ -z "$MODEL" ]]; then
        echo "Missing value for --model" >&2
        exit 2
      fi
      shift 2
      ;;
    --full-auto)
      FULL_AUTO=true
      shift
      ;;
    --ephemeral)
      EPHEMERAL=true
      shift
      ;;
    --full-log)
      FULL_LOG=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      PROMPT="$*"
      break
      ;;
    *)
      if [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$PROMPT" ]] && [[ ! -t 0 ]]; then
  PROMPT="$(cat)"
fi

if [[ -z "$PROMPT" ]]; then
  PROMPT="Please help with this task."
fi

LOG_DIR="${CODEX_LOG_DIR:-/tmp/codex-logs}"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/codex-${TIMESTAMP}-$$.log"
EVENTS_FILE="$LOG_DIR/codex-${TIMESTAMP}-$$.events.jsonl"
LAST_MSG_FILE="$LOG_DIR/codex-${TIMESTAMP}-$$.last-message.txt"

# Build the command based on mode.
if [[ "$MODE" == "review" ]]; then
  CMD=(codex exec review)
  CMD+=("${REVIEW_ARGS[@]}")
elif [[ "$MODE" == "resume" ]]; then
  CMD=(codex exec resume "$RESUME_ID")
else
  CMD=(codex exec)
fi

if [[ -n "$MODEL" ]]; then
  CMD+=(--model "$MODEL")
fi
if [[ "$FULL_AUTO" == true ]]; then
  CMD+=(--full-auto)
fi
if [[ "$EPHEMERAL" == true ]]; then
  CMD+=(--ephemeral)
fi

CMD+=(--json -o "$LAST_MSG_FILE")
CMD+=("$PROMPT")

set +e
"${CMD[@]}" > "$LOG_FILE" 2>&1
EXIT_CODE=$?
set -e

# Extract JSON events from the log.
awk '/^\{/{print}' "$LOG_FILE" > "$EVENTS_FILE"

# Try to extract session_id from events.
SESSION_ID=""
if [[ -s "$EVENTS_FILE" ]]; then
  SESSION_ID="$(jq -r 'select(.type == "thread.started") | .thread_id' "$EVENTS_FILE" 2>/dev/null | head -n 1 || true)"
fi

echo "=== CODEX SESSION ==="
if [[ -n "$SESSION_ID" && "$SESSION_ID" != "null" ]]; then
  echo "session_id: $SESSION_ID"
fi
echo "exit_code: $EXIT_CODE"
if [[ "$FULL_LOG" == true ]]; then
  echo "full_log: $LOG_FILE"
fi
echo "====================="
echo ""

# Prefer the last-message file if available, fall back to events, then raw log.
if [[ -s "$LAST_MSG_FILE" ]]; then
  cat "$LAST_MSG_FILE"
elif [[ -s "$EVENTS_FILE" ]]; then
  jq -r 'select(.type == "message" and .role == "assistant") | .content' "$EVENTS_FILE" 2>/dev/null || cat "$LOG_FILE"
else
  cat "$LOG_FILE"
  if [[ $EXIT_CODE -ne 0 ]]; then
    echo "[codex exited with code $EXIT_CODE]"
  fi
fi

exit $EXIT_CODE
