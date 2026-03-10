# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Store Split Install (referenced by Flutter engine)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }

# Just Audio, Audio Service, Audio Session
# Сохраняем АБСОЛЮТНО ВСЕ классы и их члены для аудио-плагинов
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# ExoPlayer (движок just_audio) - критично для метаданных
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Android Media & Support Library
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }
-keep class androidx.media.app.** { *; }

# Networking (OkHttp)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class javax.annotation.** { *; }
-keep class org.conscrypt.** { *; }

# Сохранение всех атрибутов для рефлексии и сериализации
-keepattributes Signature,Annotation,EnclosingMethod,InnerClasses,SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes *Metadata*

# Если используются GSON или другие сериализаторы
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
