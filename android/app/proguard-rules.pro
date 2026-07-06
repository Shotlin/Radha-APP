# ─────────────────────────────────────────────────────────────────────────────
# RADHA — R8 / ProGuard keep rules for release builds.
# Applied via `proguardFiles(...)` in app/build.gradle.kts.
# ─────────────────────────────────────────────────────────────────────────────

# ── Google ML Kit — text recognition ─────────────────────────────────────────
# google_mlkit_text_recognition references optional per-script recognizers
# (Chinese / Devanagari / Japanese / Korean) that we do NOT bundle (Latin only).
# R8 treats those absent classes as a hard error; tell it to ignore them, and
# keep the ML Kit classes we DO use so they aren't stripped.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ── Razorpay Standard Checkout ────────────────────────────────────────────────
# The SDK drives a checkout webview via reflection + a JavascriptInterface and
# ships proguard annotations; keep its classes/annotations so release
# minification doesn't break payments at runtime.
-keep class com.razorpay.** { *; }
-keep class proguard.annotation.** { *; }
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-dontwarn proguard.annotation.**

# ── Common reflection-sensitive attributes (json_serializable, SDKs) ──────────
-keepattributes Signature,InnerClasses,EnclosingMethod,Exceptions
