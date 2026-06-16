# Face Recognition Model

Place the MobileFaceNet ONNX model here as `mobilefacenet.onnx`.

## Recommended Model
- **MobileFaceNet** (1.2MB, 512-d output)
- Input: 112x112 RGB 
- Output: 512-dimensional L2-normalized embedding
- Optimized for mobile inference (<30ms on Helio G85)

## How to obtain
1. Download from InsightFace model zoo
2. Convert to ONNX format if needed
3. Place as `mobilefacenet.onnx` in this directory

## Alternative models
- ArcFace-MobileNet (2.1MB) - higher accuracy, slightly slower
- CosFace-MobileNetV2 (3.4MB) - best accuracy, moderate speed
