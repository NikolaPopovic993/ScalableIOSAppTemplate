#!/bin/bash

set -e

# ---------------------------------------------------------
# Application Configuration
# ---------------------------------------------------------
#
# Configures application-facing values through .xcconfig.
#
# Can be used interactively:
#
#   ./Scripts/setup.sh
#
# Or non-interactively:
#
#   ./Scripts/setup.sh \
#       --display-name "My Awesome App" \
#       --bundle-id "com.company.myawesomeapp" \
#       --api-scheme "https" \
#       --api-host "api.example.com" \
#       --yes
#
# ---------------------------------------------------------


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_DIR="$ROOT_DIR/Config"

SHARED_CONFIG="$CONFIG_DIR/Shared.xcconfig"
SECRETS_EXAMPLE="$CONFIG_DIR/Secrets.example.xcconfig"
SECRETS_CONFIG="$CONFIG_DIR/Secrets.xcconfig"

DISPLAY_NAME=""
BUNDLE_ID=""
API_SCHEME=""
API_HOST=""
AUTO_CONFIRM=false


# MARK: - Helpers

print_header() {
    echo ""
    echo "========================================"
    echo "  Application Setup"
    echo "========================================"
    echo ""
}


fail() {
    echo ""
    echo "❌ $1"
    echo ""
    exit 1
}


print_usage() {
    echo ""
    echo "Usage:"
    echo ""
    echo "  Interactive:"
    echo ""
    echo "    ./Scripts/setup.sh"
    echo ""
    echo "  With arguments:"
    echo ""
    echo "    ./Scripts/setup.sh \\"
    echo "        --display-name \"My Awesome App\" \\"
    echo "        --bundle-id \"com.company.myawesomeapp\" \\"
    echo "        --api-scheme \"https\" \\"
    echo "        --api-host \"api.example.com\" \\"
    echo "        --yes"
    echo ""
}


validate_required_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        fail "Required file not found: $file"
    fi
}


replace_config_value() {
    local file="$1"
    local key="$2"
    local value="$3"

    if grep -q "^${key} =" "$file"; then
        sed -i '' \
            "s|^${key} =.*|${key} = ${value}|" \
            "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
}


# MARK: - Arguments

while [[ $# -gt 0 ]]; do

    case "$1" in

        --display-name)
            [[ $# -ge 2 ]] || fail "Missing value for --display-name."
            DISPLAY_NAME="$2"
            shift 2
            ;;

        --bundle-id)
            [[ $# -ge 2 ]] || fail "Missing value for --bundle-id."
            BUNDLE_ID="$2"
            shift 2
            ;;

        --api-scheme)
            [[ $# -ge 2 ]] || fail "Missing value for --api-scheme."
            API_SCHEME="$2"
            shift 2
            ;;

        --api-host)
            [[ $# -ge 2 ]] || fail "Missing value for --api-host."
            API_HOST="$2"
            shift 2
            ;;

        --yes)
            AUTO_CONFIRM=true
            shift
            ;;

        --help|-h)
            print_usage
            exit 0
            ;;

        *)
            fail "Unknown argument: $1

Run ./Scripts/setup.sh --help for usage."
            ;;

    esac

done


# MARK: - Validation

validate_required_file "$SHARED_CONFIG"
validate_required_file "$SECRETS_EXAMPLE"


# MARK: - Input

print_header


if [[ -z "$DISPLAY_NAME" ]]; then

    read -r -p "App display name: " DISPLAY_NAME

    while [[ -z "$DISPLAY_NAME" ]]; do
        echo "App display name cannot be empty."
        read -r -p "App display name: " DISPLAY_NAME
    done

fi


if [[ -z "$BUNDLE_ID" ]]; then

    read -r -p "Bundle identifier: " BUNDLE_ID

    while [[ -z "$BUNDLE_ID" ]]; do
        echo "Bundle identifier cannot be empty."
        read -r -p "Bundle identifier: " BUNDLE_ID
    done

fi


if [[ -z "$API_SCHEME" ]]; then
    read -r -p "API scheme [https]: " API_SCHEME
fi

API_SCHEME="${API_SCHEME:-https}"


if [[ -z "$API_HOST" ]]; then
    read -r -p "API host [dummyjson.com]: " API_HOST
fi

API_HOST="${API_HOST:-dummyjson.com}"


# MARK: - Summary

echo ""
echo "Configuration"
echo "----------------------------------------"
echo "Display name: $DISPLAY_NAME"
echo "Bundle ID:    $BUNDLE_ID"
echo "API:          $API_SCHEME://$API_HOST"
echo ""


# MARK: - Confirmation

if [[ "$AUTO_CONFIRM" != true ]]; then

    read -r -p "Apply this configuration? [Y/n]: " CONFIRM

    CONFIRM="${CONFIRM:-Y}"

    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Setup cancelled."
        echo ""
        exit 0
    fi

fi


# MARK: - Shared Configuration

replace_config_value \
    "$SHARED_CONFIG" \
    "APP_DISPLAY_NAME" \
    "$DISPLAY_NAME"

replace_config_value \
    "$SHARED_CONFIG" \
    "APP_BUNDLE_IDENTIFIER" \
    "$BUNDLE_ID"

replace_config_value \
    "$SHARED_CONFIG" \
    "API_SCHEME" \
    "$API_SCHEME"

replace_config_value \
    "$SHARED_CONFIG" \
    "API_HOST" \
    "$API_HOST"


# MARK: - Secrets

if [[ ! -f "$SECRETS_CONFIG" ]]; then

    cp \
        "$SECRETS_EXAMPLE" \
        "$SECRETS_CONFIG"

    echo ""
    echo "Created local secrets file:"
    echo "Config/Secrets.xcconfig"

else

    echo ""
    echo "Local secrets file already exists."
    echo "Existing values were preserved."

fi


# MARK: - Detect Project

PROJECT_FILE="$(
    find "$ROOT_DIR" \
        -maxdepth 1 \
        -type d \
        -name "*.xcodeproj" \
        -print \
        -quit
)"

if [[ -n "$PROJECT_FILE" ]]; then
    PROJECT_NAME="$(basename "$PROJECT_FILE")"
else
    PROJECT_NAME="<project>.xcodeproj"
fi


# MARK: - Finished

echo ""
echo "========================================"
echo "  ✅ Setup completed successfully"
echo "========================================"
echo ""
echo "Display name: $DISPLAY_NAME"
echo "Bundle ID:    $BUNDLE_ID"
echo "API:          $API_SCHEME://$API_HOST"
echo ""
echo "Next steps:"
echo ""
echo "1. Review Config/Secrets.xcconfig"
echo ""
echo "2. Open:"
echo ""
echo "   $PROJECT_NAME"
echo ""
echo "3. Select your Development Team if required"
echo "4. Build and run the application"
echo "5. Run the configured test plan"
echo ""
