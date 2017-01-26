
== Useful resources ==

Basic Android RE guide:
	http://www.slideshare.net/jserv/practice-of-android-reverse-engineering
	Except that for attaching, Android Debug Monitor is the easier option.

[[hook library injecting][https://github.com/evilsocket/arminject]]


Using `gdb` with forked processes:
	https://sourceware.org/gdb/onlinedocs/gdb/Forks.html
	But attaching to zygote and then trying to follow child process didn't work so well.
	https://gist.github.com/DipSwitch/985474

Low-level guide how to run `gdbserver`:
	https://software.intel.com/en-us/android/articles/remote-application-debug-on-android-os
	https://software.intel.com/en-us/android/articles/third-party-application-debug-reference-on-intel-processor-based-platforms-part-2

More tools:
	https://github.com/crmulliner/adbi
	https://github.com/pjlantz/droidbox
	https://github.com/sh4hin/Androl4b
	https://github.com/MindMac/AndroidEagleEye

== apktool info ==

If having trouble decoding, make sure I have the correct framework files in $USER\apktool.
See https://ibotpeaches.github.io/Apktool/documentation/#framework-files

== radare2 cheatsheet ==

Install on android using the installer APK.
Doesn't seem to work right now though.

== gdb cheatsheet ==
```
info inferiors
info shared
info proc
set stop-on-solib-events 1
set disassemble-next-line 1

gdbserver :1234 --attach `pgrep hfbank`
```

To search for symbols
`
set solib-search-path c:\Devel\apktool\Xposed\system\lib;C:\Devel\apktool\cm13built\system\lib;C:\Devel\apktool\cm13built\system\bin
target remote :1234

b fopen
b dlopen
b dlsym

b exit
b abort
b ptrace
b pthread_exit

display/i $pc

define arm_isa
  if ($cpsr & 0x20)
    printf "Using THUMB(2) ISA\n"
  else
    printf "Using ARM ISA\n"
  end
end
`

the ijiami reads /proc/pid/status and then calls strtok
so just mess with strtok
strncmp

=== modify instructions (thumb) ==
2 bytes
use radare2 assembler but need to switch endian so if I get `CDAB` then in gdb:
`set *(unsigned short*)$pc = 0xABCD`


== jdb cheatsheet ==
Open Android Debug Monitor, select process

`
jdb -connect com.sun.jdi.SocketAttach:hostname=localhost,port=8700
`
