# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Add the missing keep rules for Alibaba FastJSON classes
-dontwarn com.alibaba.fastjson.JSON
-dontwarn com.alibaba.fastjson.TypeReference
-dontwarn com.alibaba.fastjson.annotation.JSONField
-dontwarn com.alibaba.fastjson.parser.Feature

# Keep the Alibaba FastJSON classes to prevent R8 from removing them
-keep class com.alibaba.fastjson.** { *; }
