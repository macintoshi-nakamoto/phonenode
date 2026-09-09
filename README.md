# phonenode

Turn an old Android phone into an always-on server. No root, no custom ROM, one command.

An old phone is a small Linux box with a battery for a UPS that draws a watt or two. Getting something to run on it was never the hard part. The hard part is that six hours later Android has killed it, or the phone rebooted and nothing came back, or it sits behind your router's NAT where you cannot reach it, or the logs ate the storage and you found out a week later. phonenode is the set of things you need so that the phone stays up and stays reachable, plus a `doctor` that tells you which of them is missing on your phone.

I run a network measurement probe on a POCO C51 that cost about fifty dollars. It lives in a drawer on Wi-Fi, checks in every fifteen minutes, has survived reboots and Android Go, and I ssh into it from anywhere through a two dollar VPS. Everything I had to learn to get there is in this repository, so you do not have to learn it again.

## What you get

| Why phone servers die | What phonenode does about it |
|---|---|
| Android kills background processes | one supervisor per service that restarts it with backoff, and a script that takes Termux off the battery kill list from your computer |
| the CPU sleeps and timers drift or fire late | holds a wake lock through Termux:API |
| after a reboot nothing starts | a Termux:Boot hook brings everything back, and opening Termux by hand does the same if the OS ever blocks the hook |
| the phone is behind NAT | a reverse SSH tunnel to any VPS, so `ssh myphone` works from anywhere |
| you learn it died a week later | a heartbeat to healthchecks.io or any URL, so something outside the phone notices |
| logs fill the storage | rotation, because nothing else on a phone will do it |
| you do not know which of the above is wrong | `pn doctor` |

## Install

On the phone, inside Termux. Use the F-Droid build of Termux, the Play Store one is abandoned and cannot install packages.

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

You also need two small apps from F-Droid, same place as Termux: **Termux:API** (wake lock, battery status) and **Termux:Boot** (start at boot). Open Termux:Boot once after installing it. Android will not run it at boot until it has been opened.

The installer puts everything under `~/.phonenode`, links `pn` into your PATH, installs the boot hook, and runs `pn doctor`. Read what the doctor says, it knows about your vendor.

## Use

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` takes a name and a command line. The command runs under its own supervisor. When it exits it is started again after five seconds, doubling up to five minutes if it keeps dying, back to five seconds once it has stayed up for a minute. `pn stop` stops it and stops restarting it. `pn restart` picks up a changed command. Everything survives a reboot.

```
pn doctor
```

goes through the list of things that kill a phone server and says what to fix, with the menu path for your vendor. It also tells you whether Termux:Boot actually ran after the last reboot, which is the one thing you cannot see from the settings.

```
$ pn status
phonenode 0.1.0 on Xiaomi 2305EPCC4G, Android 13, arm, up 4d 2h, battery 100% full
wake lock   held
boot hook   ran 1m after the last boot
sshd        running on port 8022
tunnel      pn@203.0.113.7, phone port 8022 on 127.0.0.1:2201 there, running

SERVICE        STATE       PID     UPTIME    RESTARTS
probe          running     31602   4d 2h     0
tunnel         running     31611   4d 2h     1
heartbeat      running     31640   4d 2h     0
```

## Reach it from anywhere

A phone on home Wi-Fi has no public address. Any cheap VPS solves that: the phone keeps an SSH connection open to it and asks it to forward one port back.

```
pn tunnel pn@203.0.113.7 2201
```

This makes a key, prints the exact `authorized_keys` line for the VPS (restricted so the key can forward one port and nothing else), prints the `~/.ssh/config` entry for your laptop, and sets up a service called `tunnel` that keeps the connection alive. After that, `ssh myphone` from the laptop lands on the phone. Create a separate unprivileged user on the VPS for this, the line the command prints assumes you did.

## Know when it dies

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

pings that URL every five minutes. Sign up at healthchecks.io (free), create a check with a five minute period, and it will email or message you when the phone stops calling in. Any URL that accepts a GET works, so a tiny endpoint on your own server does too.

## Take Termux off the kill list from your computer

Android has a whitelist for apps that may run in the background, and vendors add their own lists on top. Some of those switches are five taps deep and differ per phone. With USB debugging on, this script flips the ones that adb can reach:

```
bash tools/unleash.sh
```

It whitelists Termux, Termux:Boot and Termux:API from Doze, allows them to run in the background, opens Termux:Boot once so Android accepts it as a boot receiver, and tells Wi-Fi to stay on while the screen is off. Vendor settings that adb cannot reach are printed by `pn doctor` on the phone.

## What it is not

It is not root and it does not replace the OS, so the phone still does everything it did before, and your data is not touched.

It is not a full init system. If you want runit style service files with dependencies, `pkg install termux-services` does that well. phonenode is about the phone surviving and being reachable, and it runs anything, including `sv` from termux-services, under its supervisor.

It is not a VPN and it does not open ports on your router. The tunnel goes out from the phone, like any other outgoing connection.

## Tested on

| Phone | Android | Userspace | Notes |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | 32-bit arm on a 64-bit chip | the reference phone, in production since September 2026 |

Reports from other phones are the most useful contribution there is. Open an issue with the model, Android version, `pn doctor` output and how long it has been up.

## Things that bit me

Each of these cost an evening. The doctor checks for them now.

- **The userspace can be 32-bit on a 64-bit chip.** Budget phones ship armeabi-v7a Termux on an arm64 CPU. `uname -m` says armv8l and lies, `dpkg --print-architecture` says arm and is right. An arm64 binary will not even start.
- **There is no CA store.** Go and Rust binaries verify TLS against the system store, Termux has none until `pkg install ca-certificates`, and static binaries still need `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` to find it. The symptom looks like a broken network.
- **There is no `/etc/resolv.conf`.** Termux's own tools resolve names through Android. A static binary does not, and fails every DNS lookup until you point it at a resolver. `getprop net.dns1` shows one, the router usually works too.
- **Termux:API commands hang forever when the Termux:API app is missing.** Not an error, a hang. Everything in phonenode calls them under `timeout`.
- **Never `scp` a script over one that is running.** bash reads scripts incrementally, `scp` truncates and rewrites the same file, and the running copy reads garbage or forks twice. Write a new file and `mv` it. That is how I once had two supervisors on one phone.
- **`pkill -f` by name will kill your own supervisor** if its command line contains the name you are matching. phonenode kills by pid from files, and the supervisor's command line does not contain your command.
- **Android Go is a different animal.** It kills background apps far more eagerly. The battery settings are not optional there, and the reboot test is the only proof.

## Contributing

Small pull requests, one thing each. `shellcheck` must be clean and `tests/smoke.sh` must pass, both run in CI on every push. Bash on purpose: anyone can open the scripts and see what they do to their phone before running them.

## License

MIT.
