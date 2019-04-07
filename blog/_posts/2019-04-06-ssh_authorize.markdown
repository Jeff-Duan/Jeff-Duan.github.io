---
title: "ssh-认证"
layout: post
tags:
  - ssh
---

  SSH 支持很多种认证方式，口令，密钥，可信主机，Kerberos 认证等等。<br>

  每个 SSH 连接都涉及双向认证，什么意思呢？不仅服务器需要验证发起请求的用户身份（用户认证），客户端也需要验证服务器的真伪（服务器认证）。<br>

  在本文中，对于用户和服务器的密钥，我们分别以“**用户密钥**”和“**主机密钥**”来描述。<br>

## 1. 基于口令的用户认证

  本质上就是基本的非对称加密/解密。存在**中间人攻击**风险。<br>

  用户在客户端发起连接后，服务器将主机公钥发送给客户端，客户端使用主机公钥加密密码后发送给服务器。服务器使用主机私钥解密，然后获取密码。密码正确，允许登录；否则，中断连接。<br>

  ![基于口令的用户认证](/static/images/ssh_authorize1.jpg)

  使用 ssh 命令，输入密码，即可登录。<br>

```shell
$ ssh user@host
user@host's password: ******
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

## 2. 基于密钥的用户认证

  基于密钥的用户认证，通常也叫**免密登录**或者**机器信任**。无**中间人攻击**风险。<br>

  用户将用户公钥储存在服务器。客户端发起连接后，服务器向客户端发送一段随机字符串。客户端使用用户私钥加密后，再发送给服务器。服务器用事先储存的用户公钥进行解密。如果成功，就证明用户是可信的，直接允许访问，不再要求密码。<br>

  ![基于口令的用户认证](/static/images/ssh_authorize1.jpg)

### 2.1 利用 ssh-keygen 生成密钥对

  ssh-keygen 命令用于为“ssh”生成、管理和转换认证密钥，它支持 RSA 和 DSA 两种认证密钥。<br>

```shell
$ ssh-keygen -t RSA -b 521 -f ~/.ssh/id_rsa
Generating public/private id_rsa key pair.
Enter file in which to save the key (/home/username/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/username/.ssh/id_rsa.
Your public key has been saved in /home/username/.ssh/id_rsa.pub.
The key's randomart image is:
+--[RSA  521]---+
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

### 2.2 在 SSH 服务器上安装公钥

  基于口令登录远程主机，访问该用户 SSH 配置目录下的 authorized_keys 文件，即~/.ssh/authorized_keys。将用户公钥拷贝到最后一行即可。<br>
  SSH 服务器对配置目录的权限要求十分严格。如果权限设置不恰当，那么 SSH 服务器会拒绝连接。<br>

  比较正确而又安全的做法是，确保用户访问的账号才具有写入权限。<br>

```shell
$ chmod 755 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```

### 2.3 登录远程主机

  使用 ssh 命令，无需密码，即可登录。<br>

```shell
$ ssh user@host
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

## 3. 两种用户认证的区别

* 密码认证，仅有密码一个加密部分。而密钥认证，存在密钥对和passphrase口令。
* 密码认证，密码需要传输到远程主机。而密钥认证，只是创建了一个认证关系。
* 密码认证，可以字典破解。而密钥认证，也可以破解passphrase口令，但是需要先获取密钥。

> 所以基于密钥相对基于密码的认证方式，更加安全。

## 4. 中间人攻击

  如果黑客想获取你的服务器密码，但是用户使用的是SSH，黑客就无法通过监听网络来窃取密码等数据，因为SSH建立安全、可靠的连接，并且交互数据都是加密后在连接中传输。<br>
  此时可以换一个思路，黑客入侵并修改用户所使用**DNS**（域名解析服务），那么用户的连接请求就任由黑客转换到任意IP（伪装服务器）。此时若用户输入密码尝试登录，伪装服务器就会记录密码供黑客以后使用。<br>

  这就是著名的“**中间人攻击**”，不能保证访问的服务器真伪，用户完全无感知。

  如何保证访问正确的目标服务器呢？所以SSH连接在认证时，同时包含对**服务器认证**。

## 5. 服务器认证

  服务器认证，也叫做“**已知名主机机制**”。

  客户端每通过SSH访问一个新的服务器，都会将服务器主机公钥的通用部分保存，一般储存在SSH配置目录中的know_hosts文件中，即~/.ssh/know_hosts。之后每次连接到该服务器时会校验当前主机密钥的通用部分是否与本地记录的一致。

  首次连接远程主机时，服务器认证提示：

```shell
$ ssh user@host
The authenticity of host 'host (10.172.16.2)' can't be established.
RSA key fingerprint is 0a:a8:82:80:11:8d:9a:5c:b4:96:f1:c9:66:4a:fa:c6.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'host 10.172.16.2' (RSA) to the list of known hosts.
user@host's password: ******
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

  连接服务器，主机公钥不一致时，服务器认证提示：

```shell
$ ssh user@host
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that the RSA host key has just been changed.
Please contact your system administrator.
Add correct host key in /root/.ssh/known_hosts to get rid of this message.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'host,10.172.16.2' (RSA) to the list of known hosts.
user@host's password: ******
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

  由此看来，最好在首次连接到服务器之前就应该获取服务器主机公钥，否则首次连接也会受到“**中间人攻击**”。
