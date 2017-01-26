# Reverse Engineering Android APKs #
---
## Motivation ##

* understanding what's possible
* security checks
* hacking (in the original sense)

---
## Disclaimer ##

I've never written an Android app.


---
## Roadblocks ##

* obfuscation (great against a general view but not if I'm targeting one specific thing)
* anti-decompilers (can be always bypassed)
* anti-debuggers (can also be bypassed)
* time investment

---
## Get the APK ##

* `adb pull /data/app/com.example.someapp-2.apk path/to/desired/destination`
* apkpure.com, apk-dl.com, apkmirror.com

---
## .apk contents ##

* Java code compiled to `smali` register VM, saved all in `classes.dex`
* `AndroidManifest.xml` in some kind of binary form
* native machine libraries `.so` (ARM, x86, ..)
* resources

---
## apktool ##

* the main workhorse
* decode, rebuild APK, disassemble `.dex` into `.smali`
* Get it at [https://ibotpeaches.github.io/Apktool/install/](https://ibotpeaches.github.io/Apktool/install/)
* Unzip `classes.dex` manually

---
## smali ##

* Icelandic "assembler"
* register based, as opposed to standard JVM stack-based
* closer to the CPU, less work for JIT compiler
* reasonably readable

```
    const-string v5, "UTF8"
    invoke-static {p0, v3, v4, v5}, Lcom/google/zxing/client/result/optional/NDEFURIResultParser;->bytesToString([BIILjava/lang/String;)Ljava/lang/String;
    move-result-object v2
```

---
## decompilers ##

* (optional) convert `.dex` to `.jar` using ... `dex2jar`
* several exist: Fernflower, Krakatau, Procyon, CFR
* different style of produced code, different caveats

---
## decompiled ##

* no variable names (unless debug symbols)
* `try/catch` often broken
* usually can't use Java compiler to put it back together
* obfuscation -> all methods and classes are now named alphabetically (`cd.i(a, b, c, d)`)

---
## Analysis ##

* look at code until your eyes get red
* use the SmalIDEA debugger (if you have the patience)
* trace using Xposed (or other approaches)

---
## BCV front-end ##

* Makes it easy to run decompilers on `.dex` or `.jar`
* still not quite there for more in-depth analysis
* so I use ... a text editor!
* decompile everything to `.java`, put in git and write comments


---
## soot ##

* Java analysis framework
* can load `.class`, `.dex`
* builds call graphs, control-flow-graphs, ...
* used for malware analysis, ...
* good for obfuscated code and (more) automated analysis
* very complicated to use


---
## Patching APKs ##

* Example: YeeLight
* write a new class in Android Studio (add `YeeLight.jar` to project)
* compile to `.smali`
* add the smali to already extracted `apk folder/smali`
* modify `.smali` files to construct and invoke the new class
---
* rebuild using `apktool`
* sign
* zipalign
* Install on your device!

---
## Preventing RE of your app ##

* obfuscate
* use TLS cert pinning (changing it is more work)
* secrets in your app are *never hidden*
* use server-side access control. Rate limiting, per-user access.
* anti-decompilers - saw one as a service in China, worried it could insert backdoor or other stuff

---
## Thanx ##

* Roman Plášil
* @quiark
