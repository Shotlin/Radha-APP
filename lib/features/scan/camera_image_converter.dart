// Converts a `camera` package [CameraImage] frame into the [InputImage]
// shape `google_mlkit_text_recognition` expects, so the live scanner can run
// on-device OCR directly against the camera stream instead of a captured
// still. This is the standard conversion documented by both plugins for
// live-feed recognition — concatenate the YUV/BGRA planes as-is and hand
// ML Kit the format + rotation + row stride metadata; ML Kit's native side
// (not this plugin) does the actual colour-space decoding.
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Sensor-orientation-degrees -> [InputImageRotation], covering the four
/// values Android/iOS camera sensors report.
const Map<int, InputImageRotation> _orientationToRotation = {
  0: InputImageRotation.rotation0deg,
  90: InputImageRotation.rotation90deg,
  180: InputImageRotation.rotation180deg,
  270: InputImageRotation.rotation270deg,
};

/// Builds an [InputImage] from a live camera frame, or `null` if the
/// frame's rotation/format can't be resolved (caller should just skip that
/// frame — there will be another one in well under a second).
InputImage? cameraImageToInputImage(
  CameraImage image,
  CameraDescription camera,
) {
  final rotation = Platform.isIOS
      ? InputImageRotationValue.fromRawValue(camera.sensorOrientation)
      : _orientationToRotation[camera.sensorOrientation];
  if (rotation == null) return null;

  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;

  final writeBuffer = WriteBuffer();
  for (final plane in image.planes) {
    writeBuffer.putUint8List(plane.bytes);
  }
  final bytes = writeBuffer.done().buffer.asUint8List();

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    ),
  );
}
