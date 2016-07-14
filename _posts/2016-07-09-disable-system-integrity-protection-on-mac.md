---
layout: post
title: 关闭Mac上的System Integrity Protection
author: 董理
lang: zh
permalink: /2016-07-09/disable-system-integrity-protection-on-mac/
---

Apple在OS X El Capitan中加入了System Integrity Protection限制，导致在脚本中设置一些环境变量失败（如`DYLD_LIBRARY_PATH`），这对于提高系统安全性有好处（[见这里](https://support.apple.com/en-us/HT204899)）。因此为了使用STARMAN，我们需要关闭它！

```
$ csrutil status
System Integrity Protection status: enabled.
```

我们需要重新启动，然后按住`command + r`键进入Recovery OS，然后打开Terminal，键入

```
$ csrutil disable && reboot
```

好了，这样又可以愉快地玩耍了！
