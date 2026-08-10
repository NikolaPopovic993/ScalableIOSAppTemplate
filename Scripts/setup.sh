#!/bin/bash

set -e

# ---------------------------------------------------------
# Scalable iOS App Template Setup
# ---------------------------------------------------------
#
# Configures the application-specific values used by the
# template without modifying the Xcode project file.
#
# The script updates:
#
# - App display name
# - Bundle identifier
# - API scheme
# - API host
# - Local secrets configuration
#
# ---------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_DIR="$ROOT_DIR/Config"

SHARED_CONFIG="$CONFIG_DIR/Shared.xcconfig"
SECRETS_EXAMPLE="$CONFIG_DIR/Secrets.example.xcconfig"
SECRETS_CONFIG="$CONFIG_DIR/Secrets.xcconfig"


# MARK: - Helpers

print_header() {
    echo ""
    echo "========================================"
    echo "  Scalable iOS App Template Setup"
    echo "========================================"
    echo ""
}


fail() {
    echo ""
    echo "❌ $1"
    echo ""
    exit 1
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


validate_required_file() {

    local file="$1"

    if [[ ! -f "$file" ]]; then
        fail "Required file not found: $file"
    fi
}


# MARK: - Validation

validate_required_file "$SHARED_CONFIG"
validate_required_file "$SECRETS_EXAMPLE"


# MARK: - Input

print_header

echo "Enter the configuration for your application."
echo ""

read -r -p "App display name: " APP_NAME

while [[ -z "$APP_NAME" ]]; do
    echo "App display name cannot be empty."
    read -r -p "App display name: " APP_NAME
done


read -r -p "Bundle identifier: " BUNDLE_ID

while [[ -z "$BUNDLE_ID" ]]; do
    echo "Bundle identifier cannot be empty."
    read -r -p "Bundle identifier: " BUNDLE_ID
done


read -r -p "API scheme [https]: " API_SCHEME

API_SCHEME="${API_SCHEME:-https}"


read -r -p "API host [dummyjson.com]: " API_HOST

API_HOST="${API_HOST:-dummyjson.com}"


# MARK: - Summary

echo ""
echo "Configuration"
echo "----------------------------------------"
echo "App name:   $APP_NAME"
echo "Bundle ID:  $BUNDLE_ID"
echo "API:        $API_SCHEME://$API_HOST"
echo ""


read -r -p "Apply this configuration? [Y/n]: " CONFIRM

CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Setup cancelled."
    echo ""
    exit 0
fi


# MARK: - Shared Configuration

replace_config_value \
    "$SHARED_CONFIG" \
    "APP_DISPLAY_NAME" \
    "$APP_NAME"

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


# MARK: - Finished

echo ""
echo "========================================"
echo "  ✅ Setup completed successfully"
echo "========================================"
echo ""
echo "App:       $APP_NAME"
echo "Bundle ID: $BUNDLE_ID"
echo "API:       $API_SCHEME://$API_HOST"
echo ""
echo "Next steps:"
echo ""
echo "1. Review Config/Secrets.xcconfig"
echo "2. Open ScalableIOSAppTemplate.xcodeproj"
echo "3. Select your development team if required"
echo "4. Build and run the application"
echo "5. Run UnitTests.xctestplan"
echo ""
