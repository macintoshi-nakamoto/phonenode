# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-2ea043?style=flat-square" alt="简体中文">
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Portugu%C3%AAs-30363d?style=flat-square" alt="Português"></a>
  <a href="README.de.md"><img src="https://img.shields.io/badge/Deutsch-30363d?style=flat-square" alt="Deutsch"></a>
  <a href="README.fr.md"><img src="https://img.shields.io/badge/Fran%C3%A7ais-30363d?style=flat-square" alt="Français"></a>
  <a href="README.ja.md"><img src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-30363d?style=flat-square" alt="日本語"></a>
  <a href="README.hi.md"><img src="https://img.shields.io/badge/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-30363d?style=flat-square" alt="हिन्दी"></a>
  <a href="README.id.md"><img src="https://img.shields.io/badge/Bahasa%20Indonesia-30363d?style=flat-square" alt="Bahasa Indonesia"></a>
</p>

[![ci](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml/badge.svg)](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml)
![bash](https://img.shields.io/badge/bash-no%20dependencies-4EAA25?logo=gnubash&logoColor=white)
![android](https://img.shields.io/badge/Android%207%2B-no%20root-3DDC84?logo=android&logoColor=white)
![termux](https://img.shields.io/badge/Termux-F--Droid%20build-111111)
![license](https://img.shields.io/badge/license-MIT-blue)

把一台旧安卓手机变成常年在线的服务器。不用 root，不刷机，一条命令。

一台旧手机就是一台自带电池当 UPS 的小型 Linux 机器，功耗一两瓦。在上面跑点东西从来不是难事。难的是六个小时后安卓把它杀了，或者手机重启后什么都没起来，或者它躲在路由器的 NAT 后面根本连不上，又或者日志把存储吃光了而你一周后才发现。phonenode 就是让手机一直活着并且一直能连上所需的那一整套东西，外加一个 `doctor`，告诉你你的手机上到底缺了哪一样。

我在一台五十美元左右的 POCO C51 上跑着一个网络测量探针。它连着 Wi-Fi 躺在抽屉里，每十五分钟汇报一次，经受住了重启和 Android Go，而我通过一台两美元的 VPS 在任何地方 ssh 上去。为了走到这一步我学到的所有东西都在这个仓库里，你不必再学一遍。

<p align="center"><img src="../how-it-works.svg" alt="家里 Wi-Fi 上的手机、到 VPS 的反向隧道、笔记本通过 ssh 连上、到 healthchecks 的心跳" width="900"></p>

## 你能得到什么

| 手机服务器为什么会死 | phonenode 怎么应对 |
|---|---|
| 安卓杀后台进程 | 每个服务一个独立的守护进程，按退避策略重启，再加一个脚本从电脑上把 Termux 从电池黑名单里拿出来 |
| CPU 休眠，定时器漂移或者晚触发 | 通过 Termux:API 持有 wake lock |
| 重启后什么都不启动 | Termux:Boot 钩子把一切拉起来；如果系统哪天拦了这个钩子，手动打开 Termux 也能做同样的事 |
| 手机在 NAT 后面 | 到任意 VPS 的反向 SSH 隧道，`ssh myphone` 在哪儿都能用 |
| 手机死了一周后你才知道 | 向 healthchecks.io 或任意 URL 发心跳，让手机之外的东西来发现 |
| 日志塞满存储 | 日志轮转，因为手机上没有别的东西会替你做 |
| 你不知道上面哪一条出了问题 | `pn doctor` |

## 安装

在手机上，在 Termux 里操作。请用 F-Droid 版的 Termux，Play 商店那个已经停止维护，装不了软件包。

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

还需要从 F-Droid（和 Termux 同一个来源）装两个小应用：**Termux:API**（wake lock、电池状态）和 **Termux:Boot**（开机启动）。装好 Termux:Boot 后打开它一次。没被打开过的话，安卓不会在开机时运行它。

安装程序把所有东西放在 `~/.phonenode` 下，把 `pn` 链接进你的 PATH，安装开机钩子，然后运行 `pn doctor`。认真读 doctor 的输出，它了解你的手机厂商。

## 使用

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` 接受一个名字和一条命令行。命令在它自己的守护进程下运行。退出后五秒重新启动，如果持续崩溃，间隔翻倍直到五分钟，只要稳定运行满一分钟就回到五秒。`pn stop` 停止它并且不再重启。`pn restart` 让修改后的命令生效。一切都能挺过重启。

```
pn doctor
```

逐项检查会杀死手机服务器的那些事，告诉你该修什么，并给出你这个厂商的菜单路径。它还会告诉你 Termux:Boot 在上次重启后是否真的运行了，这是唯一一件在设置里看不出来的事。

<p align="center"><img src="../status.svg" alt="POCO C51 上 pn status 和 pn doctor 的输出" width="880"></p>

## 在任何地方连上它

家里 Wi-Fi 上的手机没有公网地址。随便一台便宜的 VPS 就能解决：手机对它保持一条 SSH 连接，并请它把一个端口转发回来。

```
pn tunnel pn@203.0.113.7 2201
```

这条命令生成密钥，打印出要写进 VPS 上 `authorized_keys` 的精确一行（带限制，这把钥匙只能转发一个端口，别的什么都做不了），打印出笔记本 `~/.ssh/config` 的条目，并建立一个叫 `tunnel` 的服务来维持连接。之后在笔记本上 `ssh myphone` 就落到手机上了。请在 VPS 上为此单独建一个无特权用户，打印出来的那一行默认你已经这么做了。

## 知道它什么时候死了

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

每五分钟请求一次那个 URL。在 healthchecks.io 注册（免费），建一个周期为五分钟的检查，手机不再报到时它会给你发邮件或消息。任何接受 GET 的 URL 都行，你自己服务器上的一个小接口也可以。

## 从电脑上把 Termux 从黑名单里拿出来

安卓有一份允许后台运行的应用白名单，厂商还会在上面叠加自己的名单。有些开关藏在五层菜单之下，而且每台手机都不一样。打开 USB 调试后，这个脚本会切换 adb 够得着的那些：

```
bash tools/unleash.sh
```

它把 Termux、Termux:Boot 和 Termux:API 加入 Doze 白名单，允许它们后台运行，打开一次 Termux:Boot 让安卓承认它是开机接收者，并让 Wi-Fi 在熄屏时保持连接。adb 够不着的厂商设置由手机上的 `pn doctor` 打印出来。

## 它不是什么

它不是 root，也不替换系统，手机原来能做的事照样能做，你的数据不会被动。

它不是完整的 init 系统。如果你想要带依赖关系的 runit 风格服务文件，`pkg install termux-services` 做得很好。phonenode 关心的是手机活下来并且连得上，任何东西都可以在它的守护进程下运行，包括 termux-services 的 `sv`。

它不是 VPN，也不会在你的路由器上开端口。隧道从手机向外发起，和任何其他出站连接一样。

## 测试过的设备

| 手机 | Android | 用户空间 | 备注 |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | 64 位芯片上的 32 位 arm | 参考机，自 2026 年 9 月起持续运行 |

来自其他手机的报告是最有价值的贡献。开一个 issue，写上型号、Android 版本、`pn doctor` 的输出以及它已经跑了多久。

## 踩过的坑

每一条都花了我一个晚上。现在 doctor 会检查它们。

- **64 位芯片上的用户空间可能是 32 位的。** 廉价手机在 arm64 CPU 上装的是 armeabi-v7a 的 Termux。`uname -m` 说 armv8l，那是骗人的；`dpkg --print-architecture` 说 arm，那才是对的。arm64 的二进制根本起不来。
- **没有 CA 证书库。** Go 和 Rust 的二进制按系统证书库校验 TLS，Termux 在 `pkg install ca-certificates` 之前什么都没有，静态二进制还需要 `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` 才找得到。症状看起来像网络坏了。
- **没有 `/etc/resolv.conf`。** Termux 自己的工具通过安卓解析域名。静态二进制不会，在你给它指定解析器之前每次 DNS 查询都失败。`getprop net.dns1` 能看到一个，路由器通常也行。
- **`/proc` 基本是关着的。** 在 Android 13 上应用读不了 `/proc/uptime` 和 `/proc/net/tcp`，`pgrep` 也可能漏掉进程，因为它看到的名字被截断了。phonenode 从 `/proc/self/stat` 读取运行时间，通过实际连接来检查 sshd。
- **Termux:API 应用没装的时候，它的命令会永远挂住。** 不是报错，是挂住。phonenode 里所有对它们的调用都套着 `timeout`。
- **永远不要用 `scp` 覆盖一个正在运行的脚本。** bash 是分段读脚本的，`scp` 会截断并重写同一个文件，正在运行的那份会读到垃圾或者 fork 两次。写一个新文件再 `mv`。我有一次一台手机上跑出两个守护进程就是这么来的。
- **按名字 `pkill -f` 会杀掉你自己的守护进程，** 只要它的命令行里含有你匹配的字符串。phonenode 按文件里记录的 pid 来杀，而且守护进程的命令行里不含你的命令。
- **Android Go 是另一种动物。** 它杀后台应用积极得多。在那上面电池设置不是可选项，重启测试是唯一的证明。

## 参与贡献

小的 pull request，一次只做一件事。`shellcheck` 必须干净，`tests/smoke.sh` 必须通过，两者在每次 push 时都会在 CI 里运行。特意用 Bash：任何人在运行之前都能打开脚本看清它会对自己的手机做什么。

翻译放在 `docs/i18n`。如果你的语言读起来别扭，请修正，英文文件是基准。

## 许可证

MIT。
