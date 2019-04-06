---
title: "ssh-认证"
layout: post
tags:
  - ssh
---

&emsp;&emsp;SSH 支持很多种认证方式，口令，密钥，可信主机，Kerberos 认证等等。<br>
&emsp;&emsp;每个 SSH 连接都涉及双向认证，什么意思呢？不仅服务器需要验证发起请求的用户身份（用户认证），客户端也需要验证服务器的真伪（服务器认证）。<br>

&emsp;&emsp;在本文中，对于用户和服务器的密钥，我们分别以“**用户密钥**”和“**主机密钥**”来描述。<br>

## 1. 基于口令的用户认证

&emsp;&emsp;本质上就是基本的非对称加密/解密。存在**中间人攻击**风险。<br>

&emsp;&emsp;发起连接后，服务器将主机公钥发送给用户，用户使用主机公钥加密密码后发送给服务器。服务器使用主机私钥解密，然后获取密码。密码正确，允许登录；否则，中断连接。<br>

&emsp;&emsp;使用 ssh 命令，输入密码，即可登录。<br>

```coffeescript
$ ssh user@host
user@host's password: ******
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

## 2. 基于密钥的用户认证

&emsp;&emsp;基于密钥的用户认证，通常也叫**免密登录**或者**机器信任**。无**中间人攻击**风险。<br>

&emsp;&emsp;用户将用户公钥储存在远程主机。发起连接后，远程主机向用户发送一段随机字符串。用户使用用户私钥加密后，再发送给服务器。远程主机用事先储存的用户公钥进行解密。如果成功，就证明用户是可信的，直接允许访问，不再要求密码。<br>

### 2.1 利用 ssh-keygen 生成密钥对

&emsp;&emsp;ssh-keygen 命令用于为“ssh”生成、管理和转换认证密钥，它支持 RSA 和 DSA 两种认证密钥。<br>

```coffeescript
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

&emsp;&emsp;基于口令登录远程主机，访问该用户 SSH 配置目录下的 authorized_keys 文件，即~/.ssh/authorized_keys。将用户公钥拷贝到最后一行即可。<br>
&emsp;&emsp;SSH 服务器对配置目录的权限要求十分严格。如果权限设置不恰当，那么 SSH 服务器会拒绝连接。<br>

&emsp;&emsp;比较正确而又安全的做法是，确保用户访问的账号才具有写入权限。<br>

```coffeescript
$ chmod 755 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```

### 2.3 登录远程主机

&emsp;&emsp;使用 ssh 命令，无需密码，即可登录。<br>

```coffeescript
$ ssh user@host
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

## 3. 两种用户认证的区别

使用密码认证时，密码需要传输到远程主机。而使用密钥认证时，只是创建了一个认证关系。

基于密钥相对基于密码的认证方式，更加安全。

## 4. 中间人攻击

&emsp;&emsp;假如用户基于密码认证访问远程主机，此时有第三方拦截了你的请求，并发送一个假的主机公钥，那么用户使用假的主机公钥加密密码后发送，再次被截获，第三方就能通过自己的密钥解密，从而获取你的用户密码。

## 5. 服务器认证

&emsp;&emsp;用户每通过 ssh 访问一个新的远程主机，都会将服务器主机密钥中的通用部分保存下来，之后每次连接到该远程主机时会验证，主机密钥的通用部分是否一致。

首次连接远程主机时，服务器认证提示：

```coffeescript
$ ssh user@host
The authenticity of host 'host (10.172.16.2)' can't be established.
RSA key fingerprint is 0a:a8:82:80:11:8d:9a:5c:b4:96:f1:c9:66:4a:fa:c6.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'host,10.172.16.2' (RSA) to the list of known hosts.
user@host's password: ******
Welcome to Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-64-generic x86_64)
Last login: Thu Apr 4 10:38:37 2019 from 10.114.24.51
```

连接远程主机，主机公钥不一致时，服务器认证提示：

```coffeescript
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
