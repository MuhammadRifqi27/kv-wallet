import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Thin wrapper around ML Kit's on-device text recognizer — see
/// docs/flutter-ocr-scan-struk-plan.txt. Same try/catch-swallow pattern as
/// BiometricService: any failure (corrupt image, OCR engine error) just
/// means "couldn't read this", not a crash — the caller falls back to a
/// blank/manually-filled form either way.
class ReceiptScanner {
  ReceiptScanner({TextRecognizer? recognizer})
      : _recognizer = recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  /// Returns the raw multi-line recognized text, or `null` if nothing
  /// readable was found. Parsing that text into amount/date/description is
  /// [ReceiptParser]'s job, kept separate so it stays unit-testable without
  /// mocking ML Kit — see receipt_parser.dart.
  Future<String?> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await _recognizer.processImage(inputImage);
      return result.text.trim().isEmpty ? null : result.text;
    } catch (_) {
      return null;
    }
  }

  /// Releases the native recognizer. Call once when the owning
  /// widget/provider is disposed — cheap to recreate, but leaking one per
  /// scan would leak native resources.
  Future<void> dispose() => _recognizer.close();
}
