# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }

# Hive
-keep class ** extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Gson (used internally by some plugins)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

# Keep all model classes
-keep class com.noor.app.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
