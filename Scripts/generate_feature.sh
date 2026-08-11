#!/bin/bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FEATURES_PACKAGE_DIR="$ROOT_DIR/Packages/FeaturesPackage"
MANIFEST_PATH="$FEATURES_PACKAGE_DIR/Package.swift"

SOURCES_DIR="$FEATURES_PACKAGE_DIR/Sources"
TESTS_DIR="$FEATURES_PACKAGE_DIR/Tests"

FEATURE_MARKER="// FEATURE_GENERATOR_FEATURES"

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------

FEATURE_NAME=""
MODULES_ARGUMENT=""

NETWORKING_OPTION=""
TESTS_OPTION=""

AUTO_CONFIRM=false

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

print_usage() {
    cat <<EOF
Usage:
  ./Scripts/generate_feature.sh

  ./Scripts/generate_feature.sh \
      --name Profile \
      --modules domain,data,interface,assembly \
      --networking \
      --tests \
      --yes

Options:
  --name <name>
      Feature name in PascalCase.

  --modules <modules>
      Comma-separated list of modules.

      Supported values:
        domain
        data
        interface
        assembly
        all

      Examples:
        --modules interface
        --modules domain,interface
        --modules domain,data,assembly
        --modules all

  --networking
      Add CoreNetworking to supported feature modules.

  --no-networking
      Do not use CoreNetworking.

  --tests
      Generate tests for supported modules.

  --no-tests
      Do not generate tests.

  --yes
      Skip interactive confirmation.

  --help
      Show this help.
EOF
}

fail() {
    echo ""
    echo "❌ $1"
    exit 1
}

ask_yes_no() {
    local prompt="$1"
    local default_answer="$2"
    local answer=""

    while true; do
        if [[ "$default_answer" == "yes" ]]; then
            read -r -p "$prompt [Y/n]: " answer

            if [[ -z "$answer" ]]; then
                return 0
            fi
        else
            read -r -p "$prompt [y/N]: " answer

            if [[ -z "$answer" ]]; then
                return 1
            fi
        fi

        answer="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')"

        case "$answer" in
            y|yes)
                return 0
                ;;

            n|no)
                return 1
                ;;

            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

bool_string() {
    if [[ "$1" == true ]]; then
        printf "true"
    else
        printf "false"
    fi
}

validate_feature_name() {
    local name="$1"

    if [[ ! "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]]; then
        fail "Feature name must use PascalCase and contain only letters and numbers. Example: Profile"
    fi
}

ensure_clean_git() {
    cd "$ROOT_DIR"

    if [[ -n "$(git status --porcelain)" ]]; then
        fail "Git working tree must be clean before generating a feature."
    fi
}

ensure_manifest_exists() {
    if [[ ! -f "$MANIFEST_PATH" ]]; then
        fail "FeaturesPackage manifest was not found at: $MANIFEST_PATH"
    fi
}

ensure_marker_exists() {
    local marker_count

    marker_count="$(
        grep -F -c "$FEATURE_MARKER" "$MANIFEST_PATH" || true
    )"

    if [[ "$marker_count" -ne 1 ]]; then
        fail "Expected exactly one '$FEATURE_MARKER' marker in Package.swift."
    fi
}

ensure_feature_does_not_exist() {
    local name="$1"

    if grep -Fq "name: \"$name\"" "$MANIFEST_PATH"; then
        fail "Feature '$name' already exists in Package.swift."
    fi

    if [[ -e "$SOURCES_DIR/$name" ]]; then
        fail "Sources directory already exists for feature '$name'."
    fi

    if [[ -e "$TESTS_DIR/$name" ]]; then
        fail "Tests directory already exists for feature '$name'."
    fi
}

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)
            [[ $# -ge 2 ]] || fail "--name requires a value."

            FEATURE_NAME="$2"
            shift 2
            ;;

        --modules)
            [[ $# -ge 2 ]] || fail "--modules requires a value."

            MODULES_ARGUMENT="$2"
            shift 2
            ;;

        --networking)
            NETWORKING_OPTION=true
            shift
            ;;

        --no-networking)
            NETWORKING_OPTION=false
            shift
            ;;

        --tests)
            TESTS_OPTION=true
            shift
            ;;

        --no-tests)
            TESTS_OPTION=false
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
            fail "Unknown argument: $1"
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Initial Validation
# -----------------------------------------------------------------------------

ensure_clean_git
ensure_manifest_exists
ensure_marker_exists

# -----------------------------------------------------------------------------
# Feature Name
# -----------------------------------------------------------------------------

if [[ -z "$FEATURE_NAME" ]]; then
    read -r -p "Feature name: " FEATURE_NAME
fi

validate_feature_name "$FEATURE_NAME"
ensure_feature_does_not_exist "$FEATURE_NAME"

# -----------------------------------------------------------------------------
# Module Selection
# -----------------------------------------------------------------------------

INCLUDE_DOMAIN=false
INCLUDE_DATA=false
INCLUDE_INTERFACE=false
INCLUDE_ASSEMBLY=false

enable_module() {
    local module="$1"

    case "$module" in
        domain)
            INCLUDE_DOMAIN=true
            ;;

        data)
            INCLUDE_DATA=true
            ;;

        interface)
            INCLUDE_INTERFACE=true
            ;;

        assembly)
            INCLUDE_ASSEMBLY=true
            ;;

        all)
            INCLUDE_DOMAIN=true
            INCLUDE_DATA=true
            INCLUDE_INTERFACE=true
            INCLUDE_ASSEMBLY=true
            ;;

        *)
            fail "Unsupported module '$module'. Supported modules: domain, data, interface, assembly, all."
            ;;
    esac
}

if [[ -n "$MODULES_ARGUMENT" ]]; then
    IFS=',' read -r -a requested_modules <<< "$MODULES_ARGUMENT"

    for module in "${requested_modules[@]}"; do
        normalized_module="$(
            printf '%s' "$module" |
                tr '[:upper:]' '[:lower:]' |
                tr -d ' '
        )"

        enable_module "$normalized_module"
    done

elif [[ "$AUTO_CONFIRM" == true ]]; then
    # Preserve the familiar full-feature behavior when running
    # non-interactively without an explicit module selection.
    INCLUDE_DOMAIN=true
    INCLUDE_DATA=true
    INCLUDE_INTERFACE=true
    INCLUDE_ASSEMBLY=true

else
    echo ""
    echo "Select feature modules:"
    echo ""

    if ask_yes_no "Include Domain?" "yes"; then
        INCLUDE_DOMAIN=true
    fi

    if ask_yes_no "Include Data?" "yes"; then
        INCLUDE_DATA=true
    fi

    if ask_yes_no "Include Interface?" "yes"; then
        INCLUDE_INTERFACE=true
    fi

    if ask_yes_no "Include Assembly?" "yes"; then
        INCLUDE_ASSEMBLY=true
    fi
fi

if [[ "$INCLUDE_DOMAIN" == false \
    && "$INCLUDE_DATA" == false \
    && "$INCLUDE_INTERFACE" == false \
    && "$INCLUDE_ASSEMBLY" == false ]]; then

    fail "A feature must contain at least one module."
fi

# -----------------------------------------------------------------------------
# Networking Selection
# -----------------------------------------------------------------------------

USES_NETWORKING=false

SUPPORTS_NETWORKING=false

if [[ "$INCLUDE_DATA" == true || "$INCLUDE_ASSEMBLY" == true ]]; then
    SUPPORTS_NETWORKING=true
fi

if [[ "$SUPPORTS_NETWORKING" == true ]]; then
    if [[ -n "$NETWORKING_OPTION" ]]; then
        USES_NETWORKING="$NETWORKING_OPTION"

    elif [[ "$AUTO_CONFIRM" == false ]]; then
        if ask_yes_no "Use CoreNetworking?" "no"; then
            USES_NETWORKING=true
        fi
    fi

else
    if [[ "$NETWORKING_OPTION" == true ]]; then
        fail "CoreNetworking requires a Data or Assembly module."
    fi
fi

# -----------------------------------------------------------------------------
# Test Selection
# -----------------------------------------------------------------------------

HAS_TESTS=false

SUPPORTS_TESTS=false

if [[ "$INCLUDE_DOMAIN" == true || "$INCLUDE_DATA" == true ]]; then
    SUPPORTS_TESTS=true
fi

if [[ "$SUPPORTS_TESTS" == true ]]; then
    if [[ -n "$TESTS_OPTION" ]]; then
        HAS_TESTS="$TESTS_OPTION"

    elif [[ "$AUTO_CONFIRM" == false ]]; then
        if ask_yes_no "Generate Domain/Data tests?" "yes"; then
            HAS_TESTS=true
        fi
    fi

else
    if [[ "$TESTS_OPTION" == true ]]; then
        fail "Automatic tests currently require a Domain or Data module."
    fi
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

echo ""
echo "Feature configuration"
echo "---------------------"
echo "Name:           $FEATURE_NAME"
echo "Domain:         $INCLUDE_DOMAIN"
echo "Data:           $INCLUDE_DATA"
echo "Interface:      $INCLUDE_INTERFACE"
echo "Assembly:       $INCLUDE_ASSEMBLY"
echo "CoreNetworking: $USES_NETWORKING"
echo "Tests:          $HAS_TESTS"
echo ""

if [[ "$AUTO_CONFIRM" == false ]]; then
    if ! ask_yes_no "Generate feature?" "yes"; then
        echo ""
        echo "Cancelled."
        exit 0
    fi
fi

# -----------------------------------------------------------------------------
# Module Helpers
# -----------------------------------------------------------------------------

MODULE_LINES=()

if [[ "$INCLUDE_DOMAIN" == true ]]; then
    MODULE_LINES+=(".domain")
fi

if [[ "$INCLUDE_DATA" == true ]]; then
    MODULE_LINES+=(".data")
fi

if [[ "$INCLUDE_INTERFACE" == true ]]; then
    MODULE_LINES+=(".interface")
fi

if [[ "$INCLUDE_ASSEMBLY" == true ]]; then
    MODULE_LINES+=(".assembly")
fi

# -----------------------------------------------------------------------------
# Source Generation
# -----------------------------------------------------------------------------

FEATURE_SOURCES_DIR="$SOURCES_DIR/$FEATURE_NAME"
FEATURE_TESTS_DIR="$TESTS_DIR/$FEATURE_NAME"

if [[ "$INCLUDE_DOMAIN" == true ]]; then
    DOMAIN_DIR="$FEATURE_SOURCES_DIR/Domain"

    mkdir -p "$DOMAIN_DIR"

    cat > "$DOMAIN_DIR/${FEATURE_NAME}DomainModule.swift" <<EOF
/// Marker type for the ${FEATURE_NAME} domain module.
///
/// Replace this type with feature-specific domain models, protocols,
/// use cases, and business rules as the feature grows.
public enum ${FEATURE_NAME}DomainModule {}
EOF
fi

if [[ "$INCLUDE_DATA" == true ]]; then
    DATA_DIR="$FEATURE_SOURCES_DIR/Data"

    mkdir -p "$DATA_DIR"

    cat > "$DATA_DIR/${FEATURE_NAME}DataModule.swift" <<EOF
/// Marker type for the ${FEATURE_NAME} data module.
///
/// Replace this type with repositories, DTOs, mappers, persistence,
/// and other infrastructure implementations as the feature grows.
public enum ${FEATURE_NAME}DataModule {}
EOF
fi

if [[ "$INCLUDE_INTERFACE" == true ]]; then
    INTERFACE_DIR="$FEATURE_SOURCES_DIR/Interface"

    mkdir -p "$INTERFACE_DIR"

    cat > "$INTERFACE_DIR/${FEATURE_NAME}InterfaceModule.swift" <<EOF
/// Marker type for the ${FEATURE_NAME} interface module.
///
/// Replace this type with SwiftUI views, view models, presentation models,
/// and feature-level navigation as the feature grows.
public enum ${FEATURE_NAME}InterfaceModule {}
EOF
fi

if [[ "$INCLUDE_ASSEMBLY" == true ]]; then
    ASSEMBLY_DIR="$FEATURE_SOURCES_DIR/Assembly"

    mkdir -p "$ASSEMBLY_DIR"

    cat > "$ASSEMBLY_DIR/${FEATURE_NAME}AssemblyModule.swift" <<EOF
/// Marker type for the ${FEATURE_NAME} assembly module.
///
/// Replace this type with feature composition and dependency wiring
/// when the feature requires it.
public enum ${FEATURE_NAME}AssemblyModule {}
EOF
fi

# -----------------------------------------------------------------------------
# Test Generation
# -----------------------------------------------------------------------------

if [[ "$HAS_TESTS" == true ]]; then
    if [[ "$INCLUDE_DOMAIN" == true ]]; then
        DOMAIN_TESTS_DIR="$FEATURE_TESTS_DIR/DomainTests"

        mkdir -p "$DOMAIN_TESTS_DIR"

        cat > "$DOMAIN_TESTS_DIR/${FEATURE_NAME}DomainTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Domain

@Suite("${FEATURE_NAME} Domain")
struct ${FEATURE_NAME}DomainTests {

    @Test("Domain module is available")
    func moduleIsAvailable() {
        _ = ${FEATURE_NAME}DomainModule.self
    }
}
EOF
    fi

    if [[ "$INCLUDE_DATA" == true ]]; then
        DATA_TESTS_DIR="$FEATURE_TESTS_DIR/DataTests"

        mkdir -p "$DATA_TESTS_DIR"

        cat > "$DATA_TESTS_DIR/${FEATURE_NAME}DataTests.swift" <<EOF
import Testing
@testable import ${FEATURE_NAME}Data

@Suite("${FEATURE_NAME} Data")
struct ${FEATURE_NAME}DataTests {

    @Test("Data module is available")
    func moduleIsAvailable() {
        _ = ${FEATURE_NAME}DataModule.self
    }
}
EOF
    fi
fi

# -----------------------------------------------------------------------------
# FeatureConfiguration Generation
# -----------------------------------------------------------------------------

FEATURE_BLOCK_FILE="$(mktemp)"
MANIFEST_BACKUP="$(mktemp)"
UPDATED_MANIFEST="$(mktemp)"

cleanup() {
    rm -f \
        "$FEATURE_BLOCK_FILE" \
        "$MANIFEST_BACKUP" \
        "$UPDATED_MANIFEST"
}

trap cleanup EXIT

cp "$MANIFEST_PATH" "$MANIFEST_BACKUP"

{
    echo "    FeatureConfiguration("
    echo "        name: \"$FEATURE_NAME\","
    echo "        modules: ["

    module_count="${#MODULE_LINES[@]}"
    module_index=0

    for module in "${MODULE_LINES[@]}"; do
        module_index=$((module_index + 1))

        if [[ "$module_index" -lt "$module_count" ]]; then
            echo "            $module,"
        else
            echo "            $module"
        fi
    done

    echo "        ],"
    echo "        usesNetworking: $(bool_string "$USES_NETWORKING"),"
    echo "        hasTests: $(bool_string "$HAS_TESTS")"
    echo "    ),"
} > "$FEATURE_BLOCK_FILE"

while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"$FEATURE_MARKER"* ]]; then
        cat "$FEATURE_BLOCK_FILE"
        echo ""
    fi

    printf '%s\n' "$line"
done < "$MANIFEST_PATH" > "$UPDATED_MANIFEST"

mv "$UPDATED_MANIFEST" "$MANIFEST_PATH"

# -----------------------------------------------------------------------------
# Manifest Validation
# -----------------------------------------------------------------------------

echo ""
echo "Validating FeaturesPackage..."

if ! swift package \
    --package-path "$FEATURES_PACKAGE_DIR" \
    dump-package >/dev/null; then

    echo ""
    echo "Manifest validation failed. Rolling back generated feature..."

    cp "$MANIFEST_BACKUP" "$MANIFEST_PATH"

    rm -rf "$FEATURE_SOURCES_DIR"
    rm -rf "$FEATURE_TESTS_DIR"

    fail "Feature generation failed."
fi

# -----------------------------------------------------------------------------
# Result
# -----------------------------------------------------------------------------

echo ""
echo "✅ Feature '$FEATURE_NAME' generated successfully."
echo ""

echo "Generated modules:"

if [[ "$INCLUDE_DOMAIN" == true ]]; then
    echo "  - ${FEATURE_NAME}Domain"
fi

if [[ "$INCLUDE_DATA" == true ]]; then
    echo "  - ${FEATURE_NAME}Data"
fi

if [[ "$INCLUDE_INTERFACE" == true ]]; then
    echo "  - ${FEATURE_NAME}Interface"
fi

if [[ "$INCLUDE_ASSEMBLY" == true ]]; then
    echo "  - ${FEATURE_NAME}Assembly"
fi

if [[ "$HAS_TESTS" == true ]]; then
    echo ""
    echo "Generated tests:"

    if [[ "$INCLUDE_DOMAIN" == true ]]; then
        echo "  - ${FEATURE_NAME}DomainTests"
    fi

    if [[ "$INCLUDE_DATA" == true ]]; then
        echo "  - ${FEATURE_NAME}DataTests"
    fi
fi

echo ""
echo "Next steps:"
echo "  1. Add feature-specific implementation."
echo "  2. Add any required custom dependencies in FeatureConfiguration."
echo "  3. Add the product used by the host app to the application target."
echo ""
