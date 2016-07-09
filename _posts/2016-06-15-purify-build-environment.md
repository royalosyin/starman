---
layout: post
title: 保证编译环境的纯净
author: 董理
lang: zh
permalink: /2016-05-31/problem-with-rpath-on-os-x/
---

我已经在Mac OS X 10.11上编译好了GCC 6.1.0，但是遇到一个很诡异的问题，虽然有绕过的方法。

GCC依赖于GMP库，当GCC编译好后GMP库的动态链接库路径是写死到GCC的可执行程序里的（如`libexec/gcc/x86_64-apple-darwin15.5.0/6.1.0/f951`），这个可以通过`otool`工具来看：

```
$ otool -L /opt/starman/software/gcc/6.1.0/83894f21d07366be296600ec031ae4f6241381d9/libexec/gcc/x86_64-apple-darwin15.5.0/6.1.0/f951
/opt/starman/software/gcc/6.1.0/83894f21d07366be296600ec031ae4f6241381d9/libexec/gcc/x86_64-apple-darwin15.5.0/6.1.0/f951:
	/usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
	/opt/starman/software/isl/0.17.1/104994def2b7fb2dae7950b42205eb718a46ee0c/lib/libisl.15.dylib (compatibility version 18.0.0, current version 18.1.0)
	/opt/starman/software/mpc/1.0.3/6058925218009b8ab17e07333dc54de334134f6e/lib/libmpc.3.dylib (compatibility version 4.0.0, current version 4.0.0)
	/opt/starman/software/mpfr/3.1.4/f142dfcda3b56650a8c9cfe2fdd09ffdf7283a00/lib/libmpfr.4.dylib (compatibility version 6.0.0, current version 6.4.0)
	/opt/starman/software/gmp/6.1.0/0ec8ef118d09cb33f83559685d006f56a74f865c/lib/libgmp.10.dylib (compatibility version 14.0.0, current version 14.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1226.10.1)
```

由于我电脑中还有之前PACKMAN安装的GMP（版本是13.0.0）

```
$ otool -l /opt/software/gmp/6.0.0a/0/lib/libgmp.10.dylib
...
         name @rpath/lib/libgmp.dylib (offset 24)
   time stamp 1 Thu Jan  1 08:00:01 1970
      current version 13.0.0
compatibility version 13.0.0
...
```

当进入STARMAN设置的shell环境时（执行`starman shell`），使用`gfortran`出错：

```
dyld: Library not loaded: /opt/starman/software/gmp/6.1.0/0ec8ef118d09cb33f83559685d006f56a74f865c/lib/libgmp.10.dylib
  Referenced from: /opt/starman/software/gcc/6.1.0/83894f21d07366be296600ec031ae4f6241381d9/libexec/gcc/x86_64-apple-darwin15.5.0/6.1.0/f951
  Reason: Incompatible library version: f951 requires version 14.0.0 or later, but libgmp.10.dylib provides version 13.0.0
Trace/BPT trap: 5
```

`dyld`竟然告诉我GMP版本太低（需要14.0.0），但是显示的`libgmp.10.dylib`明明是正确的路径，并且版本也是对的：

```
$ otool -l /opt/starman/software/gmp/6.1.0/0ec8ef118d09cb33f83559685d006f56a74f865c/lib/libgmp.10.dylib
...
      cmdsize 120
         name /opt/starman/software/gmp/6.1.0/0ec8ef118d09cb33f83559685d006f56a74f865c/lib/libgmp.10.dylib (offset 24)
   time stamp 1 Thu Jan  1 08:00:01 1970
      current version 14.0.0
compatibility version 14.0.0
...
```

当我把13.0.0的GMP从环境变量DYLD_LIBRARY_PATH清理出去后，就对了，但是这不应该的。究竟是为什么呢？
