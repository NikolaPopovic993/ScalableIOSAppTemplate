#!/bin/bash

set -e

# ---------------------------------------------------------
# Scalable iOS App Template - Feature Generator
# ---------------------------------------------------------
#
# Generates a new modular feature inside FeaturesPackage.
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
# Generated modules:
#
#   FeatureDomain
#   FeatureData
#   FeatureInterface
#   FeatureAssembly
#
# Optional tests:
#
#   FeatureDomainTests
#   FeatureDataTests
#
# ---------------------------------------------------------


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FEATURES_PACKAGE_DIR="$ROOT_DIR/Packages/FeaturesPackage"
PACKAGE_MANIFEST="$FEATURES_PACKAGE_DIR/Package.swift"
SOURCES_DIR="$FEATURES_PACKAGE_DIR/Sources"
TESTS_DIR="$FEATURES_PACKAGE_DIR/Tests"

PRODUCTS_MARKER="// FEATURE_GENERATOR_PRODUCTS"
TARGETS_MARKER="// FEATURE_GENERATOR_TARGETS"
TEST_TARGETS_MARKER="// FEATURE_GENERATOR_TEST_TARGETS"

FEATURE_NAME=""
USES_NETWORKING=""
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
    echo "    --name <name>       Feature name"
    echo "    --networking        Add CoreNetworking dependency"
    echo "    --no-networking     Do not add CoreNetworking"
    echo "    --tests             Generate Domain/Data test targets"
    echo "    --no-tests          Do not generate test targets"
    echo "    --yes               Skip confirmation"
    echo "    --help, -h          Show help"
    echo ""
}


validate_required_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        fail "Required file not found:

$file"
    fi
}


validate_marker() {
    local marker="$1"

    if ! grep -Fq "$marker" "$PACKAGE_MANIFEST"; then
        fail "Required Package.swift marker was not found:

$marker"
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
            marker_found=true
        fi

        printf '%s\n' "$line" >> "$temp_file"

    done < "$file"

    if [[ "$marker_found" != true ]]; then
        rm -f "$temp_file"
        fail "Could not find marker:

$marker"
    fi

    mv "$temp_file" "$file"
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


recovery_help() {
    echo ""
    echo "Feature generation did not complete successfully."
    echo ""
    echo "Review changes with:"
    echo ""
    echo "  git status"
    echo ""
    echo "Because generation requires a clean working tree,"
    echo "you can restore the previous state with:"
    echo ""
    echo "  git reset --hard HEAD"
    echo "  git clean -fd"
    echo ""
}


on_error() {
    recovery_help
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

validate_marker "$PRODUCTS_MARKER"
validate_marker "$TARGETS_MARKER"
validate_marker "$TEST_TARGETS_MARKER"


if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    fail "Feature generator must be executed inside a Git repository."
fi


cd "$ROOT_DIR"


if [[ -n "$(git status --porcelain)" ]]; then
    fail "The Git working tree must be clean before generating a feature.

Commit or stash existing changes first."
fi


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

if grep -Fq "\"${FEATURE_NAME}Domain\"" "$PACKAGE_MANIFEST"; then
    fail "Feature '$FEATURE_NAME' already appears to exist in Package.swift."
fi


if [[ -e "$SOURCES_DIR/${FEATURE_NAME}Domain" ]] ||
   [[ -e "$SOURCES_DIR/${FEATURE_NAME}Data" ]] ||
   [[ -e "$SOURCES_DIR/${FEATURE_NAME}Interface" ]] ||
   [[ -e "$SOURCES_DIR/${FEATURE_NAME}Assembly" ]]; then

    fail "One or more source directories for '$FEATURE_NAME' already exist."
fi


# MARK: - Options

if [[ -z "$USES_NETWORKING" ]]; then
    USES_NETWORKING="$(ask_yes_no "Use CoreNetworking?" true)"
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


# MARK: - Build Product Manifest Block

PRODUCT_BLOCK="$(cat <<EOF
        .library(
            name: "${FEATURE_NAME}Domain",
            targets: ["${FEATURE_NAME}Domain"]
        ),
        .library(
            name: "${FEATURE_NAME}Data",
            targets: ["${FEATURE_NAME}Data"]
        ),
        .library(
            name: "${FEATURE_NAME}Interface",
            targets: ["${FEATURE_NAME}Interface"]
        ),
        .library(
            name: "${FEATURE_NAME}Assembly",
            targets: ["${FEATURE_NAME}Assembly"]
        ),

EOF
)"


# MARK: - Build Source Target Manifest Block

if [[ "$USES_NETWORKING" == true ]]; then

    TARGET_BLOCK="$(cat <<EOF
        .target(
            name: "${FEATURE_NAME}Domain"
        ),
        .target(
            name: "${FEATURE_NAME}Data",
            dependencies: [
                "${FEATURE_NAME}Domain",
                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            ]
        ),
        .target(
            name: "${FEATURE_NAME}Interface",
            dependencies: [
                "${FEATURE_NAME}Domain",
                .product(
                    name: "CoreUI",
                    package: "CorePackage"
                )
            ]
        ),
        .target(
            name: "${FEATURE_NAME}Assembly",
            dependencies: [
                "${FEATURE_NAME}Domain",
                "${FEATURE_NAME}Data",
                "${FEATURE_NAME}Interface",
                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            ]
        ),

EOF
)"

else

    TARGET_BLOCK="$(cat <<EOF
        .target(
            name: "${FEATURE_NAME}Domain"
        ),
        .target(
            name: "${FEATURE_NAME}Data",
            dependencies: [
                "${FEATURE_NAME}Domain"
            ]
        ),
        .target(
            name: "${FEATURE_NAME}Interface",
            dependencies: [
                "${FEATURE_NAME}Domain",
                .product(
                    name: "CoreUI",
                    package: "CorePackage"
                )
            ]
        ),
        .target(
            name: "${FEATURE_NAME}Assembly",
            dependencies: [
                "${FEATURE_NAME}Domain",
                "${FEATURE_NAME}Data",
                "${FEATURE_NAME}Interface"
            ]
        ),

EOF
)"

fi


# MARK: - Build Test Manifest Block

TEST_TARGET_BLOCK=""

if [[ "$CREATE_TESTS" == true ]]; then

    TEST_TARGET_BLOCK="$(cat <<EOF
        .testTarget(
            name: "${FEATURE_NAME}DomainTests",
            dependencies: [
                "${FEATURE_NAME}Domain"
            ]
        ),
        .testTarget(
            name: "${FEATURE_NAME}DataTests",
            dependencies: [
                "${FEATURE_NAME}Domain",
                "${FEATURE_NAME}Data"
            ]
        ),

EOF
)"

fi


# MARK: - Update Package.swift

echo ""
echo "Updating FeaturesPackage/Package.swift..."
echo ""

insert_before_marker \
    "$PACKAGE_MANIFEST" \
    "$PRODUCTS_MARKER" \
    "$PRODUCT_BLOCK"

insert_before_marker \
    "$PACKAGE_MANIFEST" \
    "$TARGETS_MARKER" \
    "$TARGET_BLOCK"

if [[ "$CREATE_TESTS" == true ]]; then

    insert_before_marker \
        "$PACKAGE_MANIFEST" \
        "$TEST_TARGETS_MARKER" \
        "$TEST_TARGET_BLOCK"

fi


# MARK: - Create Source Directories

echo "Creating feature modules..."
echo ""

mkdir -p "$SOURCES_DIR/${FEATURE_NAME}Domain"
mkdir -p "$SOURCES_DIR/${FEATURE_NAME}Data"
mkdir -p "$SOURCES_DIR/${FEATURE_NAME}Interface"
mkdir -p "$SOURCES_DIR/${FEATURE_NAME}Assembly"


# MARK: - Domain

cat > "$SOURCES_DIR/${FEATURE_NAME}Domain/${FEATURE_NAME}Domain.swift" <<EOF
public enum ${FEATURE_NAME}Domain {}
EOF


# MARK: - Data

cat > "$SOURCES_DIR/${FEATURE_NAME}Data/${FEATURE_NAME}Data.swift" <<EOF
import ${FEATURE_NAME}Domain

public enum ${FEATURE_NAME}Data {}
EOF


# MARK: - Interface

cat > "$SOURCES_DIR/${FEATURE_NAME}Interface/${FEATURE_NAME}View.swift" <<EOF
import SwiftUI

public struct ${FEATURE_NAME}View: View {

    public init() {}

    public var body: some View {
        Text("${FEATURE_NAME}")
    }
}
EOF


# MARK: - Assembly

cat > "$SOURCES_DIR/${FEATURE_NAME}Assembly/${FEATURE_NAME}FeatureBuilder.swift" <<EOF
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

    mkdir -p "$TESTS_DIR/${FEATURE_NAME}DomainTests"
    mkdir -p "$TESTS_DIR/${FEATURE_NAME}DataTests"

    cat > "$TESTS_DIR/${FEATURE_NAME}DomainTests/${FEATURE_NAME}DomainTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Domain

@Suite("${FEATURE_NAME} Domain")
struct ${FEATURE_NAME}DomainTests {

    // Add domain tests here.
}
EOF

    cat > "$TESTS_DIR/${FEATURE_NAME}DataTests/${FEATURE_NAME}DataTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Data

@Suite("${FEATURE_NAME} Data")
struct ${FEATURE_NAME}DataTests {

    // Add data tests here.
}
EOF

fi


# MARK: - Validate Package Manifest

echo ""
echo "Validating Swift package manifest..."
echo ""

swift package \
    --package-path "$FEATURES_PACKAGE_DIR" \
    dump-package \
    >/dev/null

echo "✓ Package manifest is valid."


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

echo "Next steps:"
echo ""
echo "1. Open Xcode and resolve package changes"
echo ""
echo "2. Add ${FEATURE_NAME}Assembly to the application target"
echo "   if the application needs to present this feature"
echo ""
echo "3. Wire ${FEATURE_NAME}FeatureBuilder from AppContainer"
echo ""
echo "4. Add generated test targets to the Xcode Test Plan"
echo "   if they are not included automatically"
echo ""
echo "5. Replace the generated placeholder files with"
echo "   feature-specific implementation as requirements emerge"
echo ""
echo "6. Review generated changes with:"
echo ""
echo "   git status"
echo ""
