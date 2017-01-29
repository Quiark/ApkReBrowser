@ECHO OFF
ECHO Auto-Sign Created by Dave Da illest 1
ECHO Edited to be easier to use with APK files by mixpix405
ECHO.

ECHO Make sure the APK you want signed is the only APK inside this folder
PAUSE
ECHO.
 
ECHO .apk is now being signed. The signed version be named your_app_signed.apk

java -jar signapk.jar testkey.x509.pem testkey.pk8 *.apk your_app_signed.apk
ECHO.

ECHO If no errors, signing complete. If you DO see errors, good luck figuring it out, as I will be absolutely no help :)
ECHO.

PAUSE
EXIT