---
layout: post
title: 近期开发内容
author: 董理
lang: zh
permalink: /2016-05-31/recent-development/
---

最近主要是实现之前PACKMAN所具有的一些基本功能，同时测试预编译包系统，主要是完成如下设计：

- 默认使用`/opt/starman/software`作为安装根目录，只有使用该目录才能使用预编译包，其它目录需本地编译，之前想做到任意位置的预编译，但是需要正确修改编译出来的动态链接库的搜索路径，这是很难做到的，目前没有人力；
- 使用SHA256来构造软件包安装路径`prefix`，里面包含操作系统、编译器、编译设置信息，这样做的原因是去除之前`prefix`中含有的编译器集合编号，因为该编号可能会变化，而路径信息是嵌入到编译的文件中，一定不能变；

```
/opt/starman/software/gcc/6.1.0/83894f21d07366be296600ec031ae4f6241381d9/
```

- 增加`shell`命令，用来开启一个子shell，其中的环境变量（如`PATH`、`LD_LIBRARY_PATH`等）都是设置正确，同时也与默认shell环境的隔离。

尚未解决的难点：

- 同一个软件包可能采用不同的编译配置编译，如何通过`shell`命令来切换？由于配置被加密到了SHA256中，无法简单获取，目前我将一些信息存入到了安装目录下的`<package>.profile`中，格式是YAML

```
---
:name: :gcc
:version: 6.1.0
:revision:
  0: {}
:sha256: 09c4c85cabebb971b1de732a0219609f93fc0af5f86f6e437fd8d7f832f1a351
:options:
  :with-fortran: true
:os_tag: mac_10.11
:compiler_tag: clang_7.0-clang++_7.0
:dependencies:
  :gmp:
  :name: :gmp
  :version: 6.1.0
  :revision:
    0: {}
  :sha256: 68dadacce515b0f8a54f510edf07c1b636492bcdb8e8d54c56eb216225d16989
  :options: {}
:mpfr:
  :name: :mpfr
  :version: 3.1.4
  :revision:
    0: {}
  :sha256: d3103a80cdad2407ed581f3618c4bed04e0c92d1cf771a65ead662cc397f7775
  :options: {}
:mpc:
  :name: :mpc
  :version: 1.0.3
  :revision:
    0: {}
  :sha256: 617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3
  :options: {}
:isl:
  :name: :isl
  :version: 0.17.1
  :revision:
    0: {}
  :sha256: d6307bf9a59514087abac3cbaab3d99393a0abb519354f7e7834a8c842310daa
  :options: {}
```

### 补充 2016-06-01:

目前的做法是采用软件包的默认选项，如果STARMAN发现软件包的prefix不存在，则提示用户指定相应的参数。
