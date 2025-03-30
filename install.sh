#!/bin/bash
set -eu

# Add error checking
[ ! -d "python" ] && { echo "Error: python directory not found"; exit 1; }

cmake -S . -B build -DTENSORRT_PATH=/usr/local/tensorrt -DBUILD_PYTHON=ON \
    || { echo "CMake configuration failed"; exit 1; }
cmake --build build -j$(nproc) --config Release \
    || { echo "Build failed"; exit 1; }

cd python || exit 1
pip install --upgrade build || exit 1
python -m build --wheel || { echo "Wheel build failed"; exit 1; }

# Find the exact wheel file (avoiding potential multiple matches)
WHEEL=$(ls dist/tensorrt_yolo-6.*-py3-none-any.whl 2>/dev/null | head -n1)
if [ -z "$WHEEL" ]; then
    echo "Error: No wheel file found in dist/"
    exit 1
fi

# Install with chosen configuration
pip install "$WHEEL"         # Base installation
# OR
# pip install "$WHEEL[export]"  # With export extras