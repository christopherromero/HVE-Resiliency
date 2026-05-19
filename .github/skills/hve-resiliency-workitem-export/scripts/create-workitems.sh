#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/export-workitems.py"

ASSESSMENT_PATH="Microsoft-Assessment/EXAMPLE_MACAESA-Code-Level-Resiliency-Assessment.md"
TOOL=""
OUTPUT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --assessment-path)
      ASSESSMENT_PATH="$2"
      shift 2
      ;;
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --output-path)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

ARGS=("$PYTHON_SCRIPT" "--assessment-path" "$ASSESSMENT_PATH")

if [[ -n "$TOOL" ]]; then
  ARGS+=("--tool" "$TOOL")
fi

if [[ -n "$OUTPUT_PATH" ]]; then
  ARGS+=("--output-path" "$OUTPUT_PATH")
fi

python3 "${ARGS[@]}"
