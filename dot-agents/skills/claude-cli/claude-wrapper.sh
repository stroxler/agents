#!/usr/bin/env bash
# claude-wrapper.sh - Call Claude CLI non-interactively with stable output.

set -euo pipefail

MODE="ask"
RESUME_ID=""
MODEL=""
EFFORT=""
FULL_LOG=false
UNSAFE_PERMISSIONS=false
PROMPT=""
REVIEW_ARGS=()

usage() {
  cat <<'USAGE'
Usage:
  claude-wrapper.sh [OPTIONS] [PROMPT]
  claude-wrapper.sh --review [--uncommitted | --base BRANCH | --commit REV] [PROMPT]

Options:
  --review          Include VCS diff context and request a review/debug pass.
  --resume ID       Resume an existing Claude session.
  --uncommitted     (review mode) Review working tree diff.
  --base BRANCH     (review mode) Review changes against merge-base with BRANCH.
  --commit REV      (review mode) Review a specific commit/revision.
  --model MODEL     Claude model alias/name.
  --effort LEVEL    Reasoning effort: low|medium|high|max.
  --unsafe-permissions
                   Allow bypassing permission checks for trusted advanced-integration tasks.
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
    --effort)
      EFFORT="${2:-}"
      if [[ -z "$EFFORT" ]]; then
        echo "Missing value for --effort" >&2
        exit 2
      fi
      shift 2
      ;;
    --full-log)
      FULL_LOG=true
      shift
      ;;
    --unsafe-permissions)
      UNSAFE_PERMISSIONS=true
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

detect_vcs() {
  if command -v sl >/dev/null 2>&1 && sl root >/dev/null 2>&1; then
    echo "sl"
  elif git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "git"
  else
    echo "none"
  fi
}

build_review_diff() {
  local vcs="$1"
  local mode="uncommitted"
  local value=""

  local i=0
  while [[ $i -lt ${#REVIEW_ARGS[@]} ]]; do
    case "${REVIEW_ARGS[$i]}" in
      --uncommitted)
        mode="uncommitted"
        ;;
      --base)
        mode="base"
        i=$((i + 1))
        value="${REVIEW_ARGS[$i]:-}"
        ;;
      --commit)
        mode="commit"
        i=$((i + 1))
        value="${REVIEW_ARGS[$i]:-}"
        ;;
    esac
    i=$((i + 1))
  done

  case "$vcs" in
    git)
      case "$mode" in
        uncommitted) git diff ;;
        base) git diff "$(git merge-base HEAD "$value")"..HEAD ;;
        commit) git show --patch --stat "$value" ;;
      esac
      ;;
    sl)
      case "$mode" in
        uncommitted) sl diff ;;
        base) sl diff -r "ancestor(., $value)" -r . ;;
        commit) sl show "$value" ;;
      esac
      ;;
    *)
      echo "No supported VCS detected for --review" >&2
      return 1
      ;;
  esac
}

if [[ "$MODE" == "review" ]]; then
  VCS="$(detect_vcs)"
  DIFF_TEXT="$(build_review_diff "$VCS")"
  PROMPT="You are an expert reviewer/debugger. Focus on correctness risks, regressions, missing tests, and concrete fixes.\n\nTask:\n$PROMPT\n\nContext diff:\n\n$DIFF_TEXT"
fi

LOG_DIR="${CLAUDE_LOG_DIR:-/tmp/claude-logs}"
mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/claude-${TIMESTAMP}-$$.log"
JSON_FILE="$LOG_DIR/claude-${TIMESTAMP}-$$.json"

CMD=(claude -p --output-format json)

if [[ -n "$MODEL" ]]; then
  CMD+=(--model "$MODEL")
fi
if [[ -n "$EFFORT" ]]; then
  CMD+=(--effort "$EFFORT")
fi
if [[ "$MODE" == "resume" ]]; then
  CMD+=(--resume "$RESUME_ID")
fi
if [[ "$UNSAFE_PERMISSIONS" == true ]]; then
  CMD+=(--allow-dangerously-skip-permissions --dangerously-skip-permissions)
fi

CMD+=("$PROMPT")

set +e
"${CMD[@]}" > "$LOG_FILE" 2>&1
EXIT_CODE=$?
set -e

awk 'BEGIN{json=""} /^\{/ {json=$0} END{if (json != "") print json}' "$LOG_FILE" > "$JSON_FILE"

SESSION_ID=""
RESULT_TEXT=""
if [[ -s "$JSON_FILE" ]]; then
  SESSION_ID="$(jq -r '.session_id // empty' "$JSON_FILE" 2>/dev/null || true)"
  RESULT_TEXT="$(jq -r '.result // empty' "$JSON_FILE" 2>/dev/null || true)"
fi

echo "=== CLAUDE SESSION ==="
if [[ -n "$SESSION_ID" ]]; then
  echo "session_id: $SESSION_ID"
fi
echo "exit_code: $EXIT_CODE"
if [[ "$FULL_LOG" == true ]]; then
  echo "full_log: $LOG_FILE"
fi
echo "======================"
echo ""

if [[ -n "$RESULT_TEXT" ]]; then
  printf '%s\n' "$RESULT_TEXT"
else
  cat "$LOG_FILE"
  if [[ $EXIT_CODE -ne 0 ]]; then
    echo "[claude exited with code $EXIT_CODE]"
  fi
fi

exit $EXIT_CODE
