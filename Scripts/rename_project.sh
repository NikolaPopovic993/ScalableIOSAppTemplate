#!/bin/bash

set -e

# ---------------------------------------------------------
# Scalable iOS App Template - Project Rename
# ---------------------------------------------------------
#
# Renames the technical Xcode project structure.
#
# Can be used interactively:
#
#   ./Scripts/rename_project.sh
#
# Or non-interactively:
#
#   ./Scripts/rename_project.sh \
#       --name MyAwesomeApp \
#       --yes
#
# It renames:
#
# - Xcode project
# - Application target references
# - Scheme references
# - Application source directory
# - App entry file/type
# - Unit test target references
# - UI test target references
# - Xcode test plan
#
# It does NOT change:
#
# - App display name
# - Bundle identifier
# - API configuration
# - Secrets
#
# Those values are configured through setup.sh.
#
# ---------------------------------------------------------


OLD_NAME="ScalableIOSAppTemplate"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

NEW_NAME=""
AUTO_CONFIRM=false


# MARK: - Helpers

print_header() {
    echo ""
    echo "========================================"
    echo "  Scalable iOS App Template Rename"
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
    echo "    ./Scripts/rename_project.sh"
    echo ""
    echo "  With arguments:"
    echo ""
    echo "    ./Scripts/rename_project.sh \\"
    echo "        --name MyAwesomeApp \\"
    echo "        --yes"
    echo ""
    echo "Options:"
    echo ""
    echo "    --name <name>   Technical Xcode project name"
    echo "    --yes           Skip confirmation"
    echo "    --help, -h      Show this help"
    echo ""
}


rename_if_exists() {
    local source="$1"
    local destination="$2"

    if [[ ! -e "$source" ]]; then
        return
    fi

    if [[ -e "$destination" ]]; then
        fail "Cannot rename '$source' because '$destination' already exists."
    fi

    mv "$source" "$destination"

    echo "Renamed:"
    echo "  $source"
    echo "  → $destination"
}


replace_project_name_in_tracked_files() {
    echo ""
    echo "Updating project references..."
    echo ""

    git grep -Il "$OLD_NAME" -- . | while IFS= read -r file
    do
        # The script must continue to know the original
        # template name if it is executed again.
        if [[ "$file" == "Scripts/rename_project.sh" ]]; then
            continue
        fi

        sed -i '' \
            "s/${OLD_NAME}/${NEW_NAME}/g" \
            "$file"

        echo "Updated: $file"
    done
}


# MARK: - Arguments

while [[ $# -gt 0 ]]; do

    case "$1" in

        --name)
            [[ $# -ge 2 ]] || fail "Missing value for --name."
            NEW_NAME="$2"
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

Run ./Scripts/rename_project.sh --help for usage."
            ;;

    esac

done


# MARK: - Validation

print_header


if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    fail "This script must be executed inside a Git repository."
fi


if [[ ! -d "${OLD_NAME}.xcodeproj" ]]; then
    fail "Expected project '${OLD_NAME}.xcodeproj' was not found."
fi


if [[ -n "$(git status --porcelain)" ]]; then
    fail "The Git working tree must be clean before renaming the project.

Commit or discard existing changes first.

Recommended order:

1. Create repository from template
2. Run ./Scripts/rename_project.sh
3. Run ./Scripts/setup.sh"
fi


# MARK: - Input

if [[ -z "$NEW_NAME" ]]; then

    echo "This script performs a technical rename of the Xcode project."
    echo ""
    echo "Current project:"
    echo "  $OLD_NAME"
    echo ""

    read -r -p "New project name (for example MyAwesomeApp): " NEW_NAME

fi


# MARK: - Project Name Validation

if [[ -z "$NEW_NAME" ]]; then
    fail "Project name cannot be empty."
fi


if [[ "$NEW_NAME" == "$OLD_NAME" ]]; then
    fail "The new project name must be different from '$OLD_NAME'."
fi


if [[ ! "$NEW_NAME" =~ ^[A-Za-z][A-Za-z0-9]*$ ]]; then
    fail "Invalid project name.

Use a technical project name containing only letters and numbers.

Examples:

MyAwesomeApp
Biologer
BankingApp

Do not use spaces, hyphens, underscores, or special characters."
fi


# MARK: - Summary

echo ""
echo "Rename summary"
echo "----------------------------------------"
echo "Current name: $OLD_NAME"
echo "New name:     $NEW_NAME"
echo ""
echo "This will rename technical project identifiers."
echo ""
echo "Application display name and bundle identifier"
echo "will NOT be changed by this script."
echo ""


# MARK: - Confirmation

if [[ "$AUTO_CONFIRM" != true ]]; then

    read -r -p "Continue? [Y/n]: " CONFIRM

    CONFIRM="${CONFIRM:-Y}"

    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Rename cancelled."
        echo ""
        exit 0
    fi

fi


# MARK: - Replace References

replace_project_name_in_tracked_files


# MARK: - Rename Top-Level Structure

echo ""
echo "Renaming project structure..."
echo ""

rename_if_exists \
    "${OLD_NAME}.xcodeproj" \
    "${NEW_NAME}.xcodeproj"

rename_if_exists \
    "$OLD_NAME" \
    "$NEW_NAME"

rename_if_exists \
    "${OLD_NAME}Tests" \
    "${NEW_NAME}Tests"

rename_if_exists \
    "${OLD_NAME}UITests" \
    "${NEW_NAME}UITests"


# MARK: - Rename Test Plan

rename_if_exists \
    "${OLD_NAME}.xctestplan" \
    "${NEW_NAME}.xctestplan"


# MARK: - Rename Scheme

rename_if_exists \
    "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes/${OLD_NAME}.xcscheme" \
    "${NEW_NAME}.xcodeproj/xcshareddata/xcschemes/${NEW_NAME}.xcscheme"


# MARK: - Rename App Entry

rename_if_exists \
    "${NEW_NAME}/App/AppEntry/${OLD_NAME}App.swift" \
    "${NEW_NAME}/App/AppEntry/${NEW_NAME}App.swift"


# MARK: - Rename Test Files

rename_if_exists \
    "${NEW_NAME}Tests/${OLD_NAME}Tests.swift" \
    "${NEW_NAME}Tests/${NEW_NAME}Tests.swift"

rename_if_exists \
    "${NEW_NAME}UITests/${OLD_NAME}UITests.swift" \
    "${NEW_NAME}UITests/${NEW_NAME}UITests.swift"

rename_if_exists \
    "${NEW_NAME}UITests/${OLD_NAME}UITestsLaunchTests.swift" \
    "${NEW_NAME}UITests/${NEW_NAME}UITestsLaunchTests.swift"


# MARK: - Verification

echo ""
echo "Checking for remaining project-name references..."
echo ""

REMAINING_REFERENCES="$(
    grep -RIl \
        --exclude-dir=.git \
        --exclude=rename_project.sh \
        "$OLD_NAME" \
        . \
        2>/dev/null || true
)"

REMAINING_PATHS="$(
    find . \
        -path "./.git" -prune -o \
        -name "*${OLD_NAME}*" \
        -print
)"


if [[ -n "$REMAINING_REFERENCES" ]]; then
    echo "⚠️ Some textual references still contain '$OLD_NAME':"
    echo ""
    echo "$REMAINING_REFERENCES"
    echo ""
else
    echo "✓ No remaining textual project references found."
fi


if [[ -n "$REMAINING_PATHS" ]]; then
    echo ""
    echo "⚠️ Some paths still contain '$OLD_NAME':"
    echo ""
    echo "$REMAINING_PATHS"
    echo ""
else
    echo "✓ No remaining project paths found."
fi


# MARK: - Finished

echo ""
echo "========================================"
echo "  ✅ Project rename completed"
echo "========================================"
echo ""
echo "Old project: $OLD_NAME"
echo "New project: $NEW_NAME"
echo ""
echo "Next steps:"
echo ""
echo "1. Review the changes with:"
echo ""
echo "   git status"
echo ""
echo "2. Configure the application with:"
echo ""
echo "   ./Scripts/setup.sh"
echo ""
echo "3. Open:"
echo ""
echo "   ${NEW_NAME}.xcodeproj"
echo ""
echo "4. Build and run the application"
echo ""
echo "5. Run the configured test plan:"
echo ""
echo "   ${NEW_NAME}.xctestplan"
echo ""
