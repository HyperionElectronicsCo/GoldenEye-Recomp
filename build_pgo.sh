#!/bin/bash
# Profile-Guided Optimization build for GoldenEye Recomp
#
# Usage:
#   ./build_pgo.sh              # Full PGO cycle (build, run, rebuild)
#   ./build_pgo.sh instrument   # Only instrumented build
#   ./build_pgo.sh optimize     # Only optimized rebuild (after running game)
#
# After the instrumented build, play the game for 2-5 minutes in a real level
# (not just the menu) to collect representative profile data. Then re-run with
# 'optimize' to inject the profile and link the final binary.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/out/build/linux-amd64-release-pgo"
PROFILE_DIR="/tmp/ge_pgo_profiles"
REXSDK_DIR="$PROJECT_DIR/GoldenEye-Recomp-rexglue"

mkdir -p "$PROFILE_DIR"

step_instrument() {
    echo "=== Step 1: Instrumented build with -fprofile-instr-generate ==="
    cmake --preset linux-amd64-release -S "$PROJECT_DIR" -B "$BUILD_DIR" \
        -DREXSDK_DIR="$REXSDK_DIR" \
        -DCMAKE_C_FLAGS="-fprofile-instr-generate=$PROFILE_DIR" \
        -DCMAKE_CXX_FLAGS="-fprofile-instr-generate=$PROFILE_DIR" \
        -DCMAKE_EXE_LINKER_FLAGS="-fprofile-instr-generate=$PROFILE_DIR" \
        -DCMAKE_SHARED_LINKER_FLAGS="-fprofile-instr-generate=$PROFILE_DIR"
    cmake --build "$BUILD_DIR" --config Release -j$(nproc)
    echo ""
    echo "=== Instrumented build complete ==="
    echo "Run the game: $BUILD_DIR/ge"
    echo "Play for 2-5 minutes in a real level, then exit normally."
    echo "Profile data will be saved to $PROFILE_DIR"
    echo "Then run: $0 optimize"
}

step_optimize() {
    echo "=== Step 2: Optimized build with -fprofile-instr-use ==="

    # Merge any raw profiles into a single indexed profile
    if command -v llvm-profdata &>/dev/null; then
        echo "Merging raw profiles..."
        llvm-profdata merge -output="$PROFILE_DIR/merged.profdata" "$PROFILE_DIR"/*.profraw 2>/dev/null || true
        PROFILE_FLAG="-fprofile-instr-use=$PROFILE_DIR/merged.profdata"
    else
        PROFILE_FLAG="-fprofile-instr-use=$PROFILE_DIR"
    fi

    cmake --preset linux-amd64-release -S "$PROJECT_DIR" -B "$BUILD_DIR" \
        -DREXSDK_DIR="$REXSDK_DIR" \
        -DCMAKE_C_FLAGS="$PROFILE_FLAG" \
        -DCMAKE_CXX_FLAGS="$PROFILE_FLAG" \
        -DCMAKE_EXE_LINKER_FLAGS="$PROFILE_FLAG" \
        -DCMAKE_SHARED_LINKER_FLAGS="$PROFILE_FLAG"
    cmake --build "$BUILD_DIR" --config Release -j$(nproc)
    echo ""
    echo "=== PGO optimized build complete ==="
    echo "Binary: $BUILD_DIR/ge"
}

# === Main ===
case "${1:-full}" in
    instrument)
        step_instrument
        ;;
    optimize)
        step_optimize
        ;;
    full)
        step_instrument
        echo ""
        echo "=============================================="
        echo "Now run the game: $BUILD_DIR/ge"
        echo "Play for 2-5 minutes in a real level."
        echo "After you exit, run: $0 optimize"
        read -p "Press Enter after you've finished playing to continue..."
        step_optimize
        ;;
    *)
        echo "Usage: $0 {full|instrument|optimize}"
        exit 1
        ;;
esac
