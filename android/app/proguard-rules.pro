# MediaPlayer loglarını kapat
-keep class android.media.MediaPlayer {
    private <fields>;
}
-assumenosideeffects class android.media.MediaPlayer {
    void cleanDrmObj(...);
    void resetDrmState(...);
}

# EGL loglarını kapat
-assumenosideeffects class android.opengl.* {
    <methods>;
}

# Diğer debug logları kapat
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(...);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
