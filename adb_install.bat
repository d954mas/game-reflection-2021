::adb shell pm uninstall com.d954mas.game.reflection_symmetry
adb install "C:\Users\d954m\Desktop\armv7-android\Reflection Symmetry\Reflection Symmetry.apk"
adb shell monkey -p com.d954mas.game.reflection_symmetry -c android.intent.category.LAUNCHER 1
pause
