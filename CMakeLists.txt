
# ge - ReXGlue Recompiled Project
#
# This file is yours to edit. 'rexglue migrate' will NOT overwrite it.
# SDK boilerplate lives in generated/rexglue.cmake.

cmake_minimum_required(VERSION 3.25)
project(ge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(generated/rexglue.cmake)

# Sources
set(GE_SOURCES
    src/main.cpp
    src/ge_hooks.cpp
    src/ge_menu.cpp
    src/ge_postfx.cpp
    src/ge_username.cpp
)

if(WIN32)
    add_executable(ge WIN32 ${GE_SOURCES})
else()
    add_executable(ge ${GE_SOURCES})
endif()

rexglue_setup_target(ge)

# Enable ThinLTO on the final binary (scoped — doesn't affect thirdparty libs).
# The rexglue SDK libraries (rexcore, rexgraphics, etc.) get their own LTO
# from the SDK CMakeLists. This matches Xenia Canary's D3D12 pipeline which
# benefits from cross-module inlining between the host code and the SDK.
set_target_properties(ge PROPERTIES
    INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
)

# Override -march=x86-64-v3 (from rexglue SDK) with -march=native.
# This enables BMI2, FMA, AVX512 etc. specific to the build host CPU.
# The rexglue SDK adds -march=x86-64-v3 globally, so we re-append after it.
# Scoped to the ge target only (not thirdparty).
target_compile_options(ge PRIVATE $<$<CONFIG:Release>:-march=native>)

# Post-build: copy the default runtime config to the output directory so the
# game can find its config at launch without manual copying.
# Uses copy_if_different so the game's existing ge.toml (with saved settings)
# is not overwritten unless the template has changed.
add_custom_command(TARGET ge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/ge.default.toml"
        "$<TARGET_FILE_DIR:ge>/ge.toml"
    COMMENT "Copying ge.default.toml -> ge.toml"
)

# Post-build: colocate all rexglue output files (shared libs, static libs,
# codegen tool) next to the ge binary so the output directory is fully
# self-contained after a single build.
add_custom_command(TARGET ge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "$<TARGET_FILE_DIR:rexruntime>"
        "$<TARGET_FILE_DIR:ge>"
    COMMENT "Copying rexglue output directory to ge binary directory"
)
