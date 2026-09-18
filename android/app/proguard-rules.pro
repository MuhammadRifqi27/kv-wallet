# google_mlkit_text_recognition (Scan Struk, see lib/core/ocr/) references
# every script-specific recognizer (Chinese/Devanagari/Japanese/Korean) from
# one shared code path, even though this app only depends on the base
# package + Latin script (see ReceiptScanner). R8 can't verify those other
# script classes are unreachable and fails the build over it — safe to
# silence since TextRecognitionScript.latin never touches that code path.
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
