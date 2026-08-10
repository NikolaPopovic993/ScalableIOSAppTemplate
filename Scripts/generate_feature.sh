#!/bin/bash

set -e

# ---------------------------------------------------------
# Scalable iOS App Template - Feature Generator
# ---------------------------------------------------------
#
# Generates a new feature inside FeaturesPackage.
#
# The generated feature follows the structure:
#
#   Sources/<Feature>/
#   ├── Domain/
#   ├── Data/
#   ├── Interface/
#   └── Assembly/
#
# Optional tests:
#
#   Tests/<Feature>/
#   ├── DomainTests/
#   └── DataTests/
#
# The generator also registers the feature through the
# FeatureConfiguration manifest in Package.swift.
#
# Interactive usage:
#
#   ./Scripts/generate_feature.sh
#
# Non-interactive usage:
#
#   ./Scripts/generate_feature.sh \
#       --name Profile \
#       --networking \
#       --tests \
#       --yes
#
# ---------------------------------------------------------


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FEATURES_PACKAGE_DIR="$ROOT_DIR/Packages/FeaturesPackage"
PACKAGE_MANIFEST="$FEATURES_PACKAGE_DIR/Package.swift"

SOURCES_DIR="$FEATURES_PACKAGE_DIR/Sources"
TESTS_DIR="$FEATURES_PACKAGE_DIR/Tests"

FEATURE_MARKER="// FEATURE_GENERATOR_FEATURES"

FEATURE_NAME=""
USES_NETWORKING=""
USES_SHARED_UI=""
CREATE_TESTS=""
AUTO_CONFIRM=false


# MARK: - Helpers

print_header() {
    echo ""
    echo "========================================"
    echo "  Feature Generator"
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
    echo "    ./Scripts/generate_feature.sh"
    echo ""
    echo "  Non-interactive:"
    echo ""
    echo "    ./Scripts/generate_feature.sh \\"
    echo "        --name Profile \\"
    echo "        --networking \\"
    echo "        --tests \\"
    echo "        --yes"
    echo ""
    echo "Options:"
    echo ""
    echo "    --name <name>       Feature name in PascalCase"
    echo "    --networking        Enable CoreNetworking"
    echo "    --no-networking     Do not use CoreNetworking"
    echo "    --shared-ui         Enable SharedUI"
    echo "    --no-shared-ui      Do not use SharedUI"
    echo "    --tests             Generate Domain and Data tests"
    echo "    --no-tests          Do not generate tests"
    echo "    --yes               Skip confirmation"
    echo "    --help, -h          Show this help"
    echo ""
}


validate_required_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        fail "Required file not found:

$file"
    fi
}


ask_yes_no() {
    local prompt="$1"
    local default_value="$2"

    local answer

    if [[ "$default_value" == "true" ]]; then
        read -r -p "$prompt [Y/n]: " answer
        answer="${answer:-Y}"
    else
        read -r -p "$prompt [y/N]: " answer
        answer="${answer:-N}"
    fi

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "true"
    else
        echo "false"
    fi
}


insert_before_marker() {
    local file="$1"
    local marker="$2"
    local content="$3"

    local temp_file
    temp_file="$(mktemp "${file}.XXXXXX")"

    local marker_found=false

    while IFS= read -r line || [[ -n "$line" ]]; do

        if [[ "$line" == *"$marker"* ]]; then
            printf '%s\n' "$content" >> "$temp_file"
            printf '\n' >> "$temp_file"
            marker_found=true
        fi

        printf '%s\n' "$line" >> "$temp_file"

    done < "$file"

    if [[ "$marker_found" != true ]]; then
        rm -f "$temp_file"

        fail "Could not find feature generator marker:

$marker"
    fi

    mv "$temp_file" "$file"
}


print_recovery_help() {
    echo ""
    echo "Feature generation did not complete successfully."
    echo ""
    echo "Review generated changes with:"
    echo ""
    echo "  git status"
    echo ""
    echo "Because the generator requires a clean working tree,"
    echo "the generated changes can be discarded with:"
    echo ""
    echo "  git reset --hard HEAD"
    echo "  git clean -fd"
    echo ""
}


on_error() {
    print_recovery_help
}

trap on_error ERR


# MARK: - Arguments

while [[ $# -gt 0 ]]; do

    case "$1" in

        --name)
            [[ $# -ge 2 ]] || fail "Missing value for --name."
            FEATURE_NAME="$2"
            shift 2
            ;;

        --networking)
            USES_NETWORKING=true
            shift
            ;;

        --no-networking)
            USES_NETWORKING=false
            shift
            ;;
            
        --shared-ui)
            USES_SHARED_UI=true
            shift
            ;;

        --no-shared-ui)
            USES_SHARED_UI=false
            shift
            ;;

        --tests)
            CREATE_TESTS=true
            shift
            ;;

        --no-tests)
            CREATE_TESTS=false
            shift
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

Run ./Scripts/generate_feature.sh --help for usage."
            ;;

    esac

done


# MARK: - Initial Validation

print_header

validate_required_file "$PACKAGE_MANIFEST"


if ! grep -Fq "$FEATURE_MARKER" "$PACKAGE_MANIFEST"; then
    fail "Feature generator marker was not found in:

Packages/FeaturesPackage/Package.swift

Expected marker:

$FEATURE_MARKER"
fi


if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    fail "Feature generator must be executed inside a Git repository."
fi


cd "$ROOT_DIR"


if [[ -n "$(git status --porcelain)" ]]; then
    fail "The Git working tree must be clean before generating a feature.

Commit or stash existing changes first."
fi


# MARK: - Validate Existing Manifest

echo "Validating FeaturesPackage manifest..."

swift package \
    --package-path "$FEATURES_PACKAGE_DIR" \
    dump-package \
    >/dev/null

echo "✓ Existing package manifest is valid."
echo ""


# MARK: - Feature Name

if [[ -z "$FEATURE_NAME" ]]; then
    read -r -p "Feature name (for example Profile): " FEATURE_NAME
fi


if [[ -z "$FEATURE_NAME" ]]; then
    fail "Feature name cannot be empty."
fi


if [[ ! "$FEATURE_NAME" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
    fail "Invalid feature name.

Use PascalCase containing only letters and numbers.

Examples:

Profile
UserProfile
PaymentHistory

Do not use spaces, underscores, hyphens, or special characters."
fi


# MARK: - Duplicate Validation

if grep -Fq "name: \"$FEATURE_NAME\"" "$PACKAGE_MANIFEST"; then
    fail "Feature '$FEATURE_NAME' already exists in Package.swift."
fi


FEATURE_SOURCE_DIR="$SOURCES_DIR/$FEATURE_NAME"
FEATURE_TESTS_DIR="$TESTS_DIR/$FEATURE_NAME"


if [[ -e "$FEATURE_SOURCE_DIR" ]]; then
    fail "Feature source directory already exists:

Sources/$FEATURE_NAME"
fi


if [[ -e "$FEATURE_TESTS_DIR" ]]; then
    fail "Feature test directory already exists:

Tests/$FEATURE_NAME"
fi


# MARK: - Feature Options

if [[ -z "$USES_NETWORKING" ]]; then
    USES_NETWORKING="$(ask_yes_no "Use CoreNetworking?" true)"
fi

if [[ -z "$USES_SHARED_UI" ]]; then
    USES_SHARED_UI="$(ask_yes_no "Use SharedUI?" true)"
fi


if [[ -z "$CREATE_TESTS" ]]; then
    CREATE_TESTS="$(ask_yes_no "Create Domain and Data tests?" true)"
fi


# MARK: - Summary

echo ""
echo "Feature Configuration"
echo "========================================"
echo ""
echo "Feature:"
echo "  $FEATURE_NAME"
echo ""
echo "Location:"
echo "  Packages/FeaturesPackage"
echo ""
echo "Modules:"
echo "  ${FEATURE_NAME}Domain"
echo "  ${FEATURE_NAME}Data"
echo "  ${FEATURE_NAME}Interface"
echo "  ${FEATURE_NAME}Assembly"
echo ""

if [[ "$CREATE_TESTS" == true ]]; then

    echo "Tests:"
    echo "  ${FEATURE_NAME}DomainTests"
    echo "  ${FEATURE_NAME}DataTests"
    echo ""

else

    echo "Tests:"
    echo "  Disabled"
    echo ""

fi


if [[ "$USES_NETWORKING" == true ]]; then

    echo "CoreNetworking:"
    echo "  Enabled"

else

    echo "CoreNetworking:"
    echo "  Disabled"

fi

echo ""

if [[ "$USES_SHARED_UI" == true ]]; then

    echo "SharedUI:"
    echo "  Enabled"

else

    echo "SharedUI:"
    echo "  Disabled"

fi

echo ""
echo "Structure:"
echo ""
echo "  Sources/$FEATURE_NAME/"
echo "  ├── Domain/"
echo "  ├── Data/"
echo "  ├── Interface/"
echo "  └── Assembly/"

if [[ "$CREATE_TESTS" == true ]]; then
    echo ""
    echo "  Tests/$FEATURE_NAME/"
    echo "  ├── DomainTests/"
    echo "  └── DataTests/"
fi

echo ""
echo "========================================"
echo ""


# MARK: - Confirmation

if [[ "$AUTO_CONFIRM" != true ]]; then

    read -r -p "Create this feature? [Y/n]: " CONFIRM

    CONFIRM="${CONFIRM:-Y}"

    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Feature generation cancelled."
        echo ""
        exit 0
    fi

fi


# MARK: - Create Feature Structure

echo ""
echo "Creating feature structure..."
echo ""

mkdir -p "$FEATURE_SOURCE_DIR/Domain"
mkdir -p "$FEATURE_SOURCE_DIR/Data"
mkdir -p "$FEATURE_SOURCE_DIR/Interface"
mkdir -p "$FEATURE_SOURCE_DIR/Assembly"


if [[ "$CREATE_TESTS" == true ]]; then
    mkdir -p "$FEATURE_TESTS_DIR/DomainTests"
    mkdir -p "$FEATURE_TESTS_DIR/DataTests"
fi


# MARK: - Domain Placeholder

cat > "$FEATURE_SOURCE_DIR/Domain/${FEATURE_NAME}Domain.swift" <<EOF
public enum ${FEATURE_NAME}Domain {}
EOF


# MARK: - Data Placeholder

cat > "$FEATURE_SOURCE_DIR/Data/${FEATURE_NAME}Data.swift" <<EOF
import ${FEATURE_NAME}Domain

public enum ${FEATURE_NAME}Data {}
EOF


# MARK: - Interface Placeholder

cat > "$FEATURE_SOURCE_DIR/Interface/${FEATURE_NAME}View.swift" <<EOF
import SwiftUI

public struct ${FEATURE_NAME}View: View {

    public init() {}

    public var body: some View {
        Text("${FEATURE_NAME}")
    }
}
EOF


# MARK: - Assembly Placeholder

cat > "$FEATURE_SOURCE_DIR/Assembly/${FEATURE_NAME}FeatureBuilder.swift" <<EOF
import ${FEATURE_NAME}Interface
import SwiftUI

public struct ${FEATURE_NAME}FeatureBuilder {

    public init() {}

    @MainActor
    public func makeView() -> some View {
        ${FEATURE_NAME}View()
    }
}
EOF


# MARK: - Tests

if [[ "$CREATE_TESTS" == true ]]; then

    cat > "$FEATURE_TESTS_DIR/DomainTests/${FEATURE_NAME}DomainTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Domain

@Suite("${FEATURE_NAME} Domain")
struct ${FEATURE_NAME}DomainTests {

    // Add domain tests here.
}
EOF


    cat > "$FEATURE_TESTS_DIR/DataTests/${FEATURE_NAME}DataTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Data

@Suite("${FEATURE_NAME} Data")
struct ${FEATURE_NAME}DataTests {

    // Add data tests here.
}
EOF

fi


# MARK: - Feature Manifest Configuration

FEATURE_CONFIGURATION="$(cat <<EOF
    FeatureConfiguration(
        name: "$FEATURE_NAME",
        usesNetworking: $USES_NETWORKING,
        usesSharedUI: $USES_SHARED_UI,
        hasTests: $CREATE_TESTS
    ),
EOF
)"


echo "Registering feature in Package.swift..."

insert_before_marker \
    "$PACKAGE_MANIFEST" \
    "$FEATURE_MARKER" \
    "$FEATURE_CONFIGURATION"


# MARK: - Validate Generated Package

echo ""
echo "Validating generated package..."
echo ""

swift package \
    --package-path "$FEATURES_PACKAGE_DIR" \
    dump-package \
    >/dev/null

echo "✓ Package manifest is valid."


# MARK: - Verify Generated Files

EXPECTED_FILES=(
    "$FEATURE_SOURCE_DIR/Domain/${FEATURE_NAME}Domain.swift"
    "$FEATURE_SOURCE_DIR/Data/${FEATURE_NAME}Data.swift"
    "$FEATURE_SOURCE_DIR/Interface/${FEATURE_NAME}View.swift"
    "$FEATURE_SOURCE_DIR/Assembly/${FEATURE_NAME}FeatureBuilder.swift"
)


if [[ "$CREATE_TESTS" == true ]]; then

    EXPECTED_FILES+=(
        "$FEATURE_TESTS_DIR/DomainTests/${FEATURE_NAME}DomainTests.swift"
        "$FEATURE_TESTS_DIR/DataTests/${FEATURE_NAME}DataTests.swift"
    )

fi


for file in "${EXPECTED_FILES[@]}"; do

    if [[ ! -f "$file" ]]; then
        fail "Expected generated file is missing:

$file"
    fi

done


# MARK: - Success

trap - ERR

echo ""
echo "========================================"
echo "  ✅ Feature created successfully"
echo "========================================"
echo ""
echo "Feature:"
echo "  $FEATURE_NAME"
echo ""
echo "Generated modules:"
echo ""
echo "  ${FEATURE_NAME}Domain"
echo "  ${FEATURE_NAME}Data"
echo "  ${FEATURE_NAME}Interface"
echo "  ${FEATURE_NAME}Assembly"
echo ""


if [[ "$CREATE_TESTS" == true ]]; then

    echo "Generated tests:"
    echo ""
    echo "  ${FEATURE_NAME}DomainTests"
    echo "  ${FEATURE_NAME}DataTests"
    echo ""

fi


echo "Registered configuration:"
echo ""
echo "  FeatureConfiguration("
echo "      name: \"$FEATURE_NAME\","
echo "      usesNetworking: $USES_NETWORKING,"
echo "      usesSharedUI: $USES_SHARED_UI,"
echo "      hasTests: $CREATE_TESTS"
echo "  )"
echo ""
echo "Next steps:"
echo ""
echo "1. Open Xcode and resolve package changes if required"
echo ""
echo "2. Add ${FEATURE_NAME}Assembly to the application target"
echo "   when the application needs to present this feature"
echo ""
echo "3. Wire ${FEATURE_NAME}FeatureBuilder from AppContainer"
echo ""
echo "4. Add generated test targets to the Xcode Test Plan"
echo "   if they are not included automatically"
echo ""
echo "5. Replace placeholder files with implementation"
echo "   as feature requirements emerge"
echo ""
echo "6. Review generated changes with:"
echo ""
echo "   git status"
echo ""
