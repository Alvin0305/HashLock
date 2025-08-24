# Flutter-specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.plugins.**

# Rules for flutter_secure_storage (Google Tink library)
-keepclassmembers class com.google.crypto.tink.** { *; }
-keep public class com.google.crypto.tink.** { *; }

# Rules for common annotations
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**

# Rules for Flutter's Play Core dependency
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { <methods>; }
-keep class com.google.android.play.core.splitinstall.** { <methods>; }
-keep class com.google.android.play.core.tasks.** { <methods>; }

# Rules for google_api_client warnings
-dontwarn org.apache.http.**
-dontwarn com.google.api.client.**

# --- ADD THIS NEW RULE BELOW ---
-dontwarn org.joda.time.**