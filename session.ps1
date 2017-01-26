# Some tools for disassembling Android apps and other reverse engineering.
#
# EDIT these paths to match your computer
# then run powershell and source this script with    . .\session.ps1
$TOOLSHOME="C:\Devel\apktool"
$APKTOOL="$TOOLSHOME\apktool_2.1.1.jar"
$env:JAVA_HOME="C:\Devel\JDK8"
$JAVA="$env:JAVA_HOME\bin\java.exe"
$ANDROIDSDK="C:\Devel\ADT\sdk"
$ANDROIDNDK="C:\Devel\ADT\android-ndk-r10e"
$ADB="$ANDROIDSDK\platform-tools\adb.exe"
$BUILDTOOLS="$ANDROIDSDK\build-tools\24.0.1"
$JAVA6="C:\Devel\JDK1.6"
$ANDROIDJAR="$ANDROIDSDK\platforms\android-19\android.jar"
$GRAPHVIZ="C:/Software/graphviz"
$KRAKATAU="C:\Users\Roman\.Bytecode-Viewer\krakatau_9\Krakatau-master\decompile.py"

# concat like this ("$BINTOOLARM{0}" -f "gdb")
$BINTOOLX86="$ANDROIDNDK\toolchains\x86-4.9\prebuilt\windows-x86_64\bin\i686-linux-android-"
$BINTOOLARM="$ANDROIDNDK\toolchains\arm-linux-androideabi-4.9\prebuilt\windows-x86_64\bin\arm-linux-androideabi-"

$PATH_orig=$env:PATH


function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host("apk :: " ) -nonewline -ForegroundColor Green
    Write-Host($pwd.ProviderPath + " ") -nonewline -ForegroundColor Blue
    # Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

function set_path {
	$env:PATH="$env:PATH;$env:JAVA_HOME\bin;$GRAPHVIZ\bin"
}

function Run-BCV {
	java -jar "BCV/BytecodeViewer 2.9.8.jar"
}

function Run-Gdb {
	& $ADB forward tcp:1234 tcp:1234
	& ("$BINTOOLARM{0}" -f "gdb") .\cm13built\system\bin\app_process32
}

function adb_shell {
	& $ADB shell
}

function adb_connect {
	& $ADB connect 192.168.40.117:5555
}

function adb_logcat {
	& $ADB logcat -C -T 25 -b main
}

function Jdwp-Forward {
	# TODO how to get PID
	$YEE=& $ADB shell pgrep yee
	echo $YEE
	& $ADB forward tcp:8601 jdwp:$YEE[0]
}

function jdb_attach {
	& "$env:JAVA_HOME\bin\jdb"  -connect com.sun.jdi.SocketAttach:hostname=localhost,port=8601
}

function Run-Monitor {
	& "$ANDROIDSDK\tools\monitor.bat"
}

function Get-Content-Hex {
	param([string[]]$path)
	gc -en byte $path | % { '{0:X2}' -f $_ } | Join-String
}

function Run-Bokken {
	$env:PATH="$env:PATH;c:\Software\graphviz\bin"
	cd bokken
	python bokken.py
}

function Run-Studio() {
	set_path
	start C:\Devel\AndroidStudio\bin\studio64.exe
}

function dex2jar {
	& "$TOOLSHOME\dex2jar-2.0\d2j-dex2jar.bat" "$PROJECT\classes.dex" -o "$PROJECT\classes.jar"
}

function dex2smali {
	& "$TOOLSHOME\dex2jar-2.0\d2j-dex2smali.bat" "$PROJECT\classes.dex" -b -o "$PROJECT\smali"
}

function decode([string]$apk) {
	mkdir -Force $PROJECT
	& $JAVA -jar $APKTOOL d $apk -f -k -o $PROJECT
	#dex2jar
}

function rebuild() {
	$out = "$PROJECT\out.apk" 
	$signed = "$PROJECT\signed.apk"
	$aligned = "$PROJECT\aligned.apk"
	echo "-- apktool build --"
	& $JAVA -jar $APKTOOL b $PROJECT -d -o $out #--aapt "$BUILDTOOLS\aapt.exe"
	echo "-- signing --"
	& $JAVA -jar sign\signapk.jar sign\testkey.x509.pem sign\testkey.pk8 $out $signed
	echo "-- zipalign --"
	& "$BUILDTOOLS\zipalign" -f -v 4 $signed $aligned
}

# Use after rebuild()
function Apk-Install() {
	$aligned = "$PROJECT\aligned.apk"
	& $ADB install $aligned
}


# uses a bit of custom code
function Apk-Get-Manifest([string]$apk) {
	& $JAVA -cp "apk-parser\target\classes" net.dongliu.apk.parser.Main $apk
}

function openjar() {
	& $JAVA -jar jd-gui-1.4.0.jar "$PROJECT\classes.jar"
}

function drozer() {
	& $ADB forward tcp:31415 tcp:31415
	$env:PATH="$JAVA6\bin;$env:PATH"
	#$env:PYTHONPATH=".\drozer\env\Lib;.\drozer\env\Lib\site-packages"
	. drozer\env\scripts\activate.ps1
	python drozer\env\scripts\drozer $args
}

function soot() {
	# To get call graph:
	#	* Need to run 						CHATransformer.v().transform();
	#	* Need to have an entry point (manually add it)
	# -p wjap.cgg enabled:true
	& $JAVA -jar soot\soot-trunk.jar -cp "$ANDROIDJAR;$PROJECT\classes.jar" ckz
}

function flowdroid() {
	$CP="soot\soot-infoflow\bin;soot\soot-infoflow-android\bin"
	#$CP="soot\built\soot-infoflow.jar;soot\built\soot-infoflow-android.jar"
	$APK="GO Keyboard 2015_2.55.apk" 
	#$APK="samples/DeskClock.apk"
	$CP="C:\Devel\apktool\ApkReBrowser\bin;C:\Devel\jython\jython.jar;C:\Devel\apktool\soot\axml-2.0.jar;C:\Devel\apktool\soot\slf4j-api-1.7.5.jar;C:\Devel\apktool\soot\slf4j-simple-1.7.5.jar;C:\Devel\apktool\soot\soot-infoflow-android\bin;C:\Devel\apktool\soot\soot\testclasses;C:\Devel\apktool\soot\soot\classes;C:\Devel\apktool\soot\soot\libs\polyglot.jar;C:\Devel\apktool\soot\soot\libs\AXMLPrinter2.jar;C:\Devel\apktool\soot\soot\libs\hamcrest-all-1.3.jar;C:\Devel\apktool\soot\soot\libs\junit-4.11.jar;C:\Devel\apktool\soot\soot\libs\cglib-nodep-2.2.2.jar;C:\Devel\apktool\soot\soot\libs\javassist-3.18.2-GA.jar;C:\Devel\apktool\soot\soot\libs\mockito-all-1.10.8.jar;C:\Devel\apktool\soot\soot\libs\powermock-mockito-1.6.1-full.jar;C:\Devel\apktool\soot\soot\libs\jboss-common-core-2.5.0.Final.jar;C:\Devel\apktool\soot\soot\libs\asm-debug-all-5.0.3.jar;C:\Devel\apktool\soot\soot\libs\dexlib2-2.1.2-87d10dac.jar;C:\Devel\apktool\soot\soot\libs\util-2.1.2-87d10dac.jar;C:\Devel\apktool\soot\herosclasses-trunk.jar;C:\Devel\apktool\soot\jasminclasses-2.5.0.jar;C:\Devel\apktool\soot\polyglotclasses-1.3.5.jar;C:\Devel\apktool\soot\guava-19.0.jar;C:\Devel\apktool\soot\soot-infoflow-android\lib\AXMLPrinter2.jar;C:\Devel\apktool\soot\soot-infoflow\bin;C:\Devel\apktool\soot\soot-infoflow\lib\cos.jar;C:\Devel\apktool\soot\soot-infoflow\lib\j2ee.jar;C:\Devel\apktool\soot\soot-infoflow\lib\slf4j-api-1.7.5.jar;C:\Devel\apktool\soot\soot-infoflow\lib\slf4j-simple-1.7.5.jar;C:\Devel\EclipseMars2\plugins\org.junit_4.12.0.v201504281640\junit.jar;C:\Devel\EclipseMars2\plugins\org.hamcrest.core_1.3.0.v201303031735.jar;C:\Devel\apktool\soot\soot-infoflow-android\lib\axml-2.0.jar;C:\Devel\apktool\soot\classes"
	& $JAVA -cp "$CP;soot\axml-2.0.jar;soot\slf4j-api-1.7.5.jar;soot\slf4j-simple-1.7.5.jar" soot.jimple.infoflow.android.TestApps.Test $APK $ANDROIDJAR --saveresults flowdroid.xml
}

function Run-Krakatau() {
	$KRARGS="-skip -nauto -path '$env:JAVA_HOME\jre\lib\rt.jar;$ANDROIDJAR' -out $PROJECT\java $PROJECT\classes.jar"
	iex "& python -O $KRAKATAU $KRARGS"
}

function Run-Eclipse() {
	set_path
	start C:/Devel/EclipseMars2/eclipse.exe
}

# "C:\Devel\Python\pythonw.exe" 
# -O C:\Users\Roman\.Bytecode-Viewer\krakatau_9\Krakatau-master\decompile.py 
#	-skip -nauto 
#	-path C:\Devel\JDK8\jre\lib\rt.jar;C:\Users\Roman\.Bytecode-Viewer\bcv_temp\tempHKXjJaieCoUXunJUpXOuxXpDkGOouGXj.jar 
#	-out C:\Users\Roman\.Bytecode-Viewer\bcv_temp\VRFJEhBbzJXLNGUESIZfxYRBKMchJyKu 
#	com/yeelight/yeelib/device/c/aa.class
