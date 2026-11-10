# dot-agents

Open-source skills for AI coding agents.

The `skills/` directory contains skills that can be symlinked into a
per-machine config directory (`~/.llms/skills/`) which may also contain
skills from other sources. Run `./setup.sh` to create the symlinks.

- [`pyrefly-visual-review`](skills/pyrefly-visual-review/SKILL.md): experimental
  interactive code explanations pairing Python examples with Rust checker
  state. Includes a preserved example and an iteration starting point.
