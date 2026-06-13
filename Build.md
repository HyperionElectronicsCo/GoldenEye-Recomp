1. Compile REXGLUE
   cd GoldenEye-Recomp-rexglue
   mkdir build
   cd build
   cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
   cd ..
   cmake --build build -j$(nproc)

2. Generate Recompiled code
	REX_MAX_JUMP_TABLE_ENTRIES=2048 ./path/to/rexglue codegen ge_manifest.toml
3. Configure	
	cmake --preset linux-amd64-release -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DREXSDK_DIR=/GoldenEye-Recomp-rexglue/
4. Build
	cmake --build --preset linux-amd64-release -j$(nproc)
