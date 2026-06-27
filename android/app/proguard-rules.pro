# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# awesome_notifications
-keep class me.carda.** { *; }
-keepclassmembers class me.carda.** { *; }
-dontwarn me.carda.**

# mobile_scanner / ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Google Guava — fixes SHARED_PREFERENCES_NOT_AVAILABLE
-keep class com.google.common.** { *; }
-dontwarn com.google.common.**
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# SharedPreferences
-keep class android.app.SharedPreferencesImpl { *; }
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Hive
-keep class ** extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Gson
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

# App
-keep class com.noor.app.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# mobile_scanner
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**

# Hive
-keep class ** extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

# App model classes
-keep class com.noor.app.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
