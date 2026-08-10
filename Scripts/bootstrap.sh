#!/bin/bash

set -e

# ---------------------------------------------------------
# Scalable iOS App Template - Bootstrap
# ---------------------------------------------------------
#
# Recommended entry point for creating a new application
# from the template.
#
# The bootstrap process:
#
# 1. Collects application information
# 2. Validates the input
# 3. Shows a configuration summary
# 4. Renames the technical Xcode project
# 5. Configures application-facing values
# 6. Creates the local secrets configuration
#
# Usage:
#
#   ./Scripts/bootstrap.sh
#
# ---------------------------------------------------------


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RENAME_SCRIPT="$SCRIPT_DIR/rename_project.sh"
SETUP_SCRIPT="$SCRIPT_DIR/setup.sh"

PROJECT_NAME=""
DISPLAY_NAME=""
BUNDLE_ID=""
API_SCHEME=""
API_HOST=""


# MARK: - Helpers

print_header() {
    echo ""
    echo "========================================"
    echo "  Scalable iOS App Template Bootstrap"
    echo "========================================"
    echo ""
}


fail() {
    echo ""
    echo "❌ $1"
    echo ""
    exit 1
}


print_recovery_help() {
    echo ""
    echo "Bootstrap did not complete successfully."
    echo ""
    echo "Review the current changes with:"
    echo ""
    echo "  git status"
    echo ""
    echo "If this is a fresh repository created from the template"
    echo "and you want to discard the bootstrap changes, you can use:"
    echo ""
    echo "  git reset --hard HEAD"
    echo "  git clean -fd"
    echo ""
}


validate_required_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        fail "Required script not found: $file"
    fi
}


validate_project_name() {
    if [[ -z "$PROJECT_NAME" ]]; then
        fail "Project name cannot be empty."
    fi

    if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
        fail "Invalid technical project name.

Use only letters and numbers and start with a letter.

Examples:

MyAwesomeApp
Biologer
BankingApp

Do not use spaces, hyphens, underscores, or special characters."
    fi
}


validate_display_name() {
    if [[ -z "$DISPLAY_NAME" ]]; then
        fail "Application display name cannot be empty."
    fi
}


validate_bundle_identifier() {
    if [[ -z "$BUNDLE_ID" ]]; then
        fail "Bundle identifier cannot be empty."
    fi

    if [[ ! "$BUNDLE_ID" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]; then
        fail "Invalid bundle identifier.

Use a reverse-domain identifier.

Example:

com.company.myawesomeapp"
    fi
}


validate_api_scheme() {
    if [[ "$API_SCHEME" != "https" && "$API_SCHEME" != "http" ]]; then
        fail "API scheme must be either 'https' or 'http'."
    fi
}


validate_api_host() {
    if [[ -z "$API_HOST" ]]; then
        fail "API host cannot be empty."
    fi

    if [[ "$API_HOST" == *"://"* ]]; then
        fail "API host must not contain a scheme.

Use:

api.example.com

instead of:

https://api.example.com"
    fi

    if [[ "$API_HOST" == */* ]]; then
        fail "API host must not contain a URL path.

Use:

api.example.com

instead of:

api.example.com/v1"
    fi
}


on_error() {
    print_recovery_help
}

trap on_error ERR


# MARK: - Initial Validation

print_header

validate_required_file "$RENAME_SCRIPT"
validate_required_file "$SETUP_SCRIPT"


if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    fail "Bootstrap must be executed inside a Git repository."
fi


cd "$ROOT_DIR"


if [[ -n "$(git status --porcelain)" ]]; then
    fail "The Git working tree must be clean before running bootstrap.

Commit or discard existing changes first."
fi


# MARK: - Introduction

echo "This script will prepare a new application from the template."
echo ""
echo "You will configure:"
echo ""
echo "  • Technical Xcode project name"
echo "  • Application display name"
echo "  • Bundle identifier"
echo "  • API configuration"
echo ""
echo "You will be asked for confirmation before any files are changed."
echo ""


# MARK: - Project Name

read -r -p "Technical project name [MyAwesomeApp]: " PROJECT_NAME

PROJECT_NAME="${PROJECT_NAME:-MyAwesomeApp}"

validate_project_name


# MARK: - Display Name

read -r -p "App display name [My Awesome App]: " DISPLAY_NAME

DISPLAY_NAME="${DISPLAY_NAME:-My Awesome App}"

validate_display_name


# MARK: - Bundle Identifier

read -r -p "Bundle identifier [com.example.myawesomeapp]: " BUNDLE_ID

BUNDLE_ID="${BUNDLE_ID:-com.example.myawesomeapp}"

validate_bundle_identifier


# MARK: - API Scheme

read -r -p "API scheme [https]: " API_SCHEME

API_SCHEME="${API_SCHEME:-https}"

validate_api_scheme


# MARK: - API Host

read -r -p "API host [dummyjson.com]: " API_HOST

API_HOST="${API_HOST:-dummyjson.com}"

validate_api_host


# MARK: - Summary

echo ""
echo "Application Configuration"
echo "========================================"
echo ""
echo "Technical project name:"
echo "  $PROJECT_NAME"
echo ""
echo "Application display name:"
echo "  $DISPLAY_NAME"
echo ""
echo "Bundle identifier:"
echo "  $BUNDLE_ID"
echo ""
echo "API:"
echo "  $API_SCHEME://$API_HOST"
echo ""
echo "========================================"
echo ""

read -r -p "Create this application? [Y/n]: " CONFIRM

CONFIRM="${CONFIRM:-Y}"


if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Bootstrap cancelled."
    echo ""
    exit 0
fi


# MARK: - Rename Project

echo ""
echo "----------------------------------------"
echo "Step 1/2 - Renaming Xcode project"
echo "----------------------------------------"
echo ""

"$RENAME_SCRIPT" \
    --name "$PROJECT_NAME" \
    --yes


# MARK: - Configure Application

echo ""
echo "----------------------------------------"
echo "Step 2/2 - Configuring application"
echo "----------------------------------------"
echo ""

"$SETUP_SCRIPT" \
    --display-name "$DISPLAY_NAME" \
    --bundle-id "$BUNDLE_ID" \
    --api-scheme "$API_SCHEME" \
    --api-host "$API_HOST" \
    --yes


# MARK: - Final Verification

PROJECT_FILE="$ROOT_DIR/${PROJECT_NAME}.xcodeproj"
TEST_PLAN="$ROOT_DIR/${PROJECT_NAME}.xctestplan"
SECRETS_FILE="$ROOT_DIR/Config/Secrets.xcconfig"


if [[ ! -d "$PROJECT_FILE" ]]; then
    fail "Expected Xcode project was not created:

${PROJECT_NAME}.xcodeproj"
fi


if [[ ! -f "$TEST_PLAN" ]]; then
    fail "Expected Xcode test plan was not created:

${PROJECT_NAME}.xctestplan"
fi


if [[ ! -f "$SECRETS_FILE" ]]; then
    fail "Expected local secrets configuration was not created:

Config/Secrets.xcconfig"
fi


# MARK: - Success

trap - ERR

echo ""
echo "========================================"
echo "  ✅ Application created successfully"
echo "========================================"
echo ""
echo "Project:"
echo "  ${PROJECT_NAME}.xcodeproj"
echo ""
echo "Display name:"
echo "  $DISPLAY_NAME"
echo ""
echo "Bundle identifier:"
echo "  $BUNDLE_ID"
echo ""
echo "API:"
echo "  $API_SCHEME://$API_HOST"
echo ""
echo "Next steps:"
echo ""
echo "1. Open:"
echo ""
echo "   ${PROJECT_NAME}.xcodeproj"
echo ""
echo "2. Review:"
echo ""
echo "   Config/Secrets.xcconfig"
echo ""
echo "3. Select your Development Team if required"
echo ""
echo "4. Build and run the application"
echo ""
echo "5. Run the configured test plan with ⌘ + U"
echo ""
echo "6. Review generated changes with:"
echo ""
echo "   git status"
echo ""
