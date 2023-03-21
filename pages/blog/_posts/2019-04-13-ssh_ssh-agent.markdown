---
title: "SSH-代理ssh-agent"
layout: post
tags:
  - ssh
  - ssh-agent
---

  代理是一个应用程序，它可以帮助我们管理密钥，说白了就是私钥管理器。<br>

  SSH1 、 SSH2 、 OpenSSH 都有与代理有关的程序 ssh-agent 、 ssh-add 。<br>

  **ssh-agent 部分常用参数**

* -a : 启动时绑定一个unix-socket, 默认是$TMPDIR/ssh-agent/agent._ppid_
* -c : 生成一个 C-shell 风格的命令输出
* -d : 调试模式
* -k : 杀死当前 ssh-agent , 需要 SSH_AGENT_PID 环境变量，否则参数不生效
* -s : 生成一个 Bourne shell 风格的命令输出
* -t : 设置添加私钥的最大生效时间, 超时私钥会自动失效, 不指定则永远生效
* -D : 如果指定该参数则 ssh-agent 运行在前台

  **ssh-add 部分常用参数**

* -D : 删除 ssh-agent 中的所有私钥
* -d : 指定从 ssh-agent 中删除私钥，参数指定一个私钥文件路径
* -L : 显示所有已添加的私钥
* -l : 显示所有已添加私钥指纹
* -t : 指定私钥在 ssh-agent 中存活时间，超时将会自动卸载私钥
* -x : 对 ssh-agent 加锁
* -X : 对 ssh-agent 解锁

  **为什么需要 SSH 代理来管理私钥呢？**<br>

1. 当存在多个私钥，SSH 代理可自动选择对应的密钥进行认证，免去手动指定密钥的操作。<br>

2. 当私钥设置密语，SSH 代理可免去每次认证的重复输入密语的操作。<br>

3. 免去 SSH Config 指定 Host 使用哪个私钥的繁琐配置。

4. 最强大的，莫过于代理转发。

  如何使用 SSH 代理，本文会逐步介绍。<br>

## 1. 启动/关闭 SSH 代理
  启动 SSH 代理程序 ssh-agent ，有两种方式，但是略有不同。

```shell
  $ ssh-agent $SHELL
```
  执行以上命令，会在当前 shell 中启动一个默认 shell ，作为当前 shell 的子 shell ， ssh-agent 程序会在子 shell 中运行，终端自动进入新创建的子 shell 中。在当前终端会话中，我们已经可以使用 ssh-agent ， 但是此时 ssh-agent 会随着当前终端进程的消失而消失，这也是一种安全机制。

> 默认shell通常为 bash ，当然也有手动替换为 csh 的情况。无论如何，都可以将 $SHELL 替换为当前默认 shell 。

```shell
  $ eval `ssh-agent -s`
```
  执行以上命令，不会启动一个子 shell ，而是直接启动一个 ssh-agent 进程。如果我们退出当前 bash ， ssh-agnet 进程并不会自动关闭。

> 两种方式启动，在退出当前 bash 之前，均可使用 ssh-agent -k 手动结束 ssh-agent 进程。若退出了当前 bash 是无法关闭对应的 ssh-agent 进程的，除非使用 kill 命令。

  如何启动/关闭ssh代理，就这么简单。

## 2. 添加私钥到 SSH 代理

  使用 SSH 代理管理密钥，需要将密钥添加至代理，必须认识 ssh-add 命令。

```shell
  $ ssh-add ~/.ssh/id_rsa
```

  上述命令表示将私钥 id_rsa 加入到 SSH 代理中，如果启动 ssh-agent 不正确，那么在执行 ssh-add 命令时，可能会出现如下错误提示。

  Could not open a connection to your authentication agent.

## 3. 使用 SSH 代理

  **使用 SSH 代理选择对应私钥进行认证**

  **使用 SSH 代理免去重复输入私钥密码**

  当私钥设置了密语，基于密钥进行认证时，会提示输入私钥的密语，输入正确的私钥密语，才能够使用对应私钥进行认证。

  未开启SSH代理时：

```shell
  $ ssh user@host
  Enter passphrase for key '~/.ssh/id_rsa':******
  Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
  Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
  $ exit
  $ ssh user@host
  Enter passphrase for key '~/.ssh/id_rsa':******
  Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
  Last login: Thu Apr 4 10:38:47 2019 from 10.114.24.51
```

  开启SSH代理时：

```shell
  $ eval `ssh-agent -s`
  $ ssh-add ~/.ssh/id_rsa
  $ Enter passphrase for key '~/.ssh/id_rsa':******
  $ ssh user@host
  Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
  Last login: Thu Apr 4 10:49:29 2019 from 10.114.24.51
```

  如果私钥设置了密语，每次使用私钥进行认证连接时，都会要求输入私钥密语。如果你在当前 ssh 会话中需要反复的连接到远程用户，那么反复输入复杂的私钥密语，当然是痛苦不堪。<br>

  ssh-agent 可以帮助我们，在一个 ssh 会话中，只要输入一次私钥密语，在当前会话中再次使用到相同的私钥时，即可不用再次输入对应密语。<br>
