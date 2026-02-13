#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SKILL_DIR/config.yaml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: config.yaml not found at $CONFIG_FILE" >&2
    exit 1
fi

parse_yaml() {
    local yaml_file="$1"
    local key="$2"
    grep "^${key}:" "$yaml_file" | sed "s/^${key}:\s*//" | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/"
}

parse_yaml_array() {
    local yaml_file="$1"
    local start_marker="$2"
    awk "/$start_marker/,/^[^ ]/ { if (/^  - path:/) print }" "$yaml_file"
}

WORKSPACE=$(parse_yaml "$CONFIG_FILE" "workspace")

if [[ "$WORKSPACE" == "null" || -z "$WORKSPACE" ]]; then
    WORKSPACE=$(find . -maxdepth 1 -name "*.code-workspace" | head -1)
    if [[ -z "$WORKSPACE" ]]; then
        echo "Error: No .code-workspace file found and workspace not specified in config" >&2
        exit 1
    fi
    echo "Auto-detected workspace: $WORKSPACE" >&2
fi

if [[ ! -f "$WORKSPACE" ]]; then
    echo "Error: Workspace file not found: $WORKSPACE" >&2
    exit 1
fi

WORKSPACE_DIR=$(dirname "$(realpath "$WORKSPACE")")

echo "{"
echo "  \"workspace\": \"$WORKSPACE\","
echo "  \"repositories\": ["

FIRST=true

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*path:[[:space:]]*(.+)$ ]]; then
        REPO_PATH=$(echo "${BASH_REMATCH[1]}" | sed 's/^[ \t]*//;s/[ \t]*$//')
        read -r next_line
        if [[ "$next_line" =~ ^[[:space:]]*base_branch:[[:space:]]*(.+)$ ]]; then
            BASE_BRANCH=$(echo "${BASH_REMATCH[1]}" | sed 's/^[ \t]*//;s/[ \t]*$//')
            
            FULL_PATH="$WORKSPACE_DIR/$REPO_PATH"
            
            if [[ ! -d "$FULL_PATH" ]]; then
                echo "Warning: Repository not found: $FULL_PATH" >&2
                continue
            fi
            
            if [[ ! -d "$FULL_PATH/.git" ]]; then
                echo "Warning: Not a git repository: $FULL_PATH" >&2
                continue
            fi
            
            cd "$FULL_PATH"
            
            if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
                echo "Error: Base branch '$BASE_BRANCH' not found in $FULL_PATH" >&2
                exit 1
            fi
            
            DIFF=$(git diff "$BASE_BRANCH"..HEAD)
            CHANGED_FILES=$(git diff --name-only "$BASE_BRANCH"..HEAD | jq -R -s -c 'split("\n") | map(select(length > 0))')
            
            if [[ "$FIRST" == "false" ]]; then
                echo ","
            fi
            FIRST=false
            
            echo "    {"
            echo "      \"path\": \"$FULL_PATH\","
            echo "      \"base_branch\": \"$BASE_BRANCH\","
            echo "      \"changed_files\": $CHANGED_FILES,"
            echo -n "      \"diff\": "
            echo -n "$DIFF" | jq -R -s -c '.'
            echo "    }"
        fi
    fi
done < <(grep -A1 "^  - path:" "$CONFIG_FILE")

echo ""
echo "  ]"
echo "}"
