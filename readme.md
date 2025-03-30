```bash
# run docker image
docker run --name=tensorrt-convert -it --rm --gpus '"device=0"' -v ${PWD}:/workspace tensorrt-convert:latest /bin/bash


# build cmake
# pip install "pybind11[global]"
cmake -S . -B build -DTENSORRT_PATH=/usr/local/tensorrt -DBUILD_PYTHON=ON
cmake --build build -j$(nproc) --config Release

# install:
cd python
pip install --upgrade build
python -m build --wheel
# Install only inference-related dependencies
pip install dist/tensorrt_yolo-6.*-py3-none-any.whl
# Install both model export and inference-related dependencies
pip install dist/tensorrt_yolo-6.*-py3-none-any.whl[export]


## convert to onnx:
# Export models trained with Ultralytics (YOLOv3, YOLOv5, YOLOv6, YOLOv8, YOLOv9, YOLOv10, YOLO11) with plugin parameters, using dynamic batch export
trtyolo export -w yolov8s.pt -v ultralytics -o output --max_boxes 100 --iou_thres 0.45 --conf_thres 0.25 -b -1
# convert to TensorRT

trtexec --onnx=output/yolov8s.onnx --saveEngine=yolov8s.engine --fp16

trtexec --onnx=output/yolov8s.onnx --saveEngine=yolov8s.engine --fp16 \
    --minShapes=images:1x3x640x640 --optShapes=images:1x3x640x640 --maxShapes=images:1x3x640x640


## commit image
```