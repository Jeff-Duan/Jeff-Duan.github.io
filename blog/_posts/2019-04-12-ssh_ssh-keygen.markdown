---
title: "SSH-密钥生成器ssh-keygen"
layout: post
tags:
  - ssh
  - ssh-keygen
---

  密钥生成器是为 SSH 创建永久性密钥（用户密钥和主机密钥）的应用程序。<br>

  SSH1 、 SSH2 、 OpenSSH 都是使用 ssh-keygen 来做密钥生成器。<br>

  ssh-keygen 命令用于为 ssh 生成、管理和转换认证密钥，它支持 RSA 和 DSA 两种认证密钥。（较新的 OpenSSH 版本中，可以使用 ECDSA 密钥，这种数字签名算法生成的密钥较小，安全性更高）<br>

  列出 ssh-keygen 的部分常用参数
* -t：指定生成密钥的类型，默认使用SSH2的RSA
* -f：指定生成密钥的文件路径，默认为 id_密钥类型（如：私钥 id_rsa ，公钥 id_rsa.pub）
* -P：提供旧密语，空表示不需要密语
* -N：提供新密语，空表示不需要密语
* -b：指定密钥长度（bits），RSA最小要求768位，默认是2048位； DSA 密语必须是1024位
* -C：提供一个新注释
* -R：提供一个 hostname ，删除 known_hosts 文件中 hostname 的密钥

## 1. 生成密钥对

  使用 ssh-keygen 生成一对长度为 2048 bit 的 RSA 加密的密钥对，指定生成路径为 ~/.ssh/id_rsa 。

```shell
$ ssh-keygen -t RSA -b 2048 -f ~/.ssh/id_rsa
Generating public/private id_rsa key pair.
Enter file in which to save the key (/home/username/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/username/.ssh/id_rsa.
Your public key has been saved in /home/username/.ssh/id_rsa.pub.
The key's randomart image is:
+--[RSA  2048]---+
|     ..oB=.   .  |
|    .    . . . . |
|  .  .      . +  |
| oo.o    . . =   |
|o+.+.   S . . .  |
|=.   . E         |
| o    .          |
|  .              |
|                 |
+-----------------+
```

## 2. 保护密钥对

  生成密钥对时 ssh-keygen 要求提供一个密码短语（passphrase）。密码短语（passphrase）和密码/口令不同。

* 密语（passphrase）是生成密钥对时使用的。它从不离开主机，主要用来加解密密钥对，保护你的私钥安全。
* 密码/口令（password）是登录服务器时使用的。它会在登录时，在网络中传输到服务器。

  生成密钥对时， ssh-keygen 请求输入密语，您应该输入一些复杂却毫无规律的短语，以防私钥泄露后被破解。

  当然回车跳过，也能够生成所需的密钥对。但是在没有输入密码短语的情况下，私钥未经加密就存储在硬盘上，任何人拿到私钥都可以随意的访问对应的 SSH 服务器。还有一种情况，如果您不是 root 用户，则该机器上的 root 用户可以完全拥有您的密钥对，因为他的权限是最大的。

  如果密钥对已经生成，也可以使用 ssh-keygen -N 和 -P 参数指定新的密语。

## 3. 管理密钥对

  我的另一篇文章中会介绍，如何管理密钥对？[SSH-代理ssh-agent](/blog/2019/04/13/ssh_ssh-agent/ "SSH-代理ssh-agent") 。<br>
