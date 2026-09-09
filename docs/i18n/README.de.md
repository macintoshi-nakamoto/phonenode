# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-30363d?style=flat-square" alt="简体中文"></a>
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Portugu%C3%AAs-30363d?style=flat-square" alt="Português"></a>
  <img src="https://img.shields.io/badge/Deutsch-2ea043?style=flat-square" alt="Deutsch">
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

Mach aus einem alten Android-Handy einen Server, der immer läuft. Kein Root, keine Custom-ROM, ein Befehl.

Ein altes Handy ist eine kleine Linux-Kiste mit eingebauter USV in Form des Akkus, die ein bis zwei Watt zieht. Etwas darauf zum Laufen zu bringen war nie das Problem. Das Problem ist, dass Android es sechs Stunden später abgeschossen hat, oder dass das Handy neu gestartet ist und nichts wiederkam, oder dass es hinter dem NAT deines Routers sitzt, wo du nicht rankommst, oder dass die Logs den Speicher gefressen haben und du es eine Woche später gemerkt hast. phonenode ist die Sammlung von Dingen, die du brauchst, damit das Handy oben bleibt und erreichbar bleibt, plus ein `doctor`, der dir sagt, welches davon auf deinem Handy fehlt.

Ich betreibe eine Sonde für Netzwerkmessungen auf einem POCO C51 für etwa fünfzig Dollar. Es liegt in einer Schublade im WLAN, meldet sich alle fünfzehn Minuten, hat Neustarts und Android Go überlebt, und ich komme von überall per ssh über einen VPS für zwei Dollar drauf. Alles, was ich dafür lernen musste, steht in diesem Repository, damit du es nicht noch einmal lernen musst.

<p align="center"><img src="../how-it-works.svg" alt="das Handy im heimischen WLAN, der Reverse-Tunnel zu einem VPS, der Laptop per ssh, der Heartbeat an healthchecks" width="900"></p>

## Was du bekommst

| Warum Handy-Server sterben | Was phonenode dagegen tut |
|---|---|
| Android beendet Hintergrundprozesse | ein Supervisor pro Dienst, der ihn mit wachsender Wartezeit neu startet, und ein Skript, das Termux vom Rechner aus von der Akku-Abschussliste nimmt |
| die CPU schläft, Timer driften oder feuern zu spät | hält einen Wake Lock über Termux:API |
| nach einem Neustart startet nichts | ein Termux:Boot-Hook bringt alles zurück, und Termux von Hand zu öffnen tut dasselbe, falls das System den Hook jemals blockiert |
| das Handy sitzt hinter NAT | ein Reverse-SSH-Tunnel zu einem beliebigen VPS, damit `ssh myphone` von überall funktioniert |
| du erfährst eine Woche später, dass es tot ist | ein Heartbeat an healthchecks.io oder eine beliebige URL, damit etwas außerhalb des Handys es merkt |
| Logs füllen den Speicher | Rotation, weil sonst nichts auf einem Handy das übernimmt |
| du weißt nicht, welcher Punkt davon kaputt ist | `pn doctor` |

## Installation

Auf dem Handy, in Termux. Nimm die F-Droid-Version von Termux, die aus dem Play Store ist aufgegeben und kann keine Pakete installieren.

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

Außerdem brauchst du zwei kleine Apps aus F-Droid, von derselben Quelle wie Termux: **Termux:API** (Wake Lock, Akkustatus) und **Termux:Boot** (Start beim Booten). Öffne Termux:Boot nach der Installation einmal. Android führt es beim Booten nicht aus, solange es nie geöffnet wurde.

Der Installer legt alles unter `~/.phonenode` ab, verlinkt `pn` in deinen PATH, installiert den Boot-Hook und führt `pn doctor` aus. Lies, was der Doctor sagt, er kennt deinen Hersteller.

## Benutzung

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` nimmt einen Namen und eine Befehlszeile. Der Befehl läuft unter seinem eigenen Supervisor. Wenn er sich beendet, wird er nach fünf Sekunden neu gestartet, die Wartezeit verdoppelt sich bis auf fünf Minuten, wenn er weiter stirbt, und fällt auf fünf Sekunden zurück, sobald er eine Minute durchgehalten hat. `pn stop` hält ihn an und startet ihn nicht mehr neu. `pn restart` übernimmt einen geänderten Befehl. Alles übersteht einen Neustart.

```
pn doctor
```

geht die Liste der Dinge durch, die einen Handy-Server umbringen, und sagt, was zu tun ist, mit dem Menüpfad für deinen Hersteller. Er sagt dir auch, ob Termux:Boot nach dem letzten Neustart wirklich gelaufen ist, das Einzige, was man in den Einstellungen nicht sehen kann.

<p align="center"><img src="../status.svg" alt="Ausgabe von pn status und pn doctor auf einem POCO C51" width="880"></p>

## Von überall erreichen

Ein Handy im heimischen WLAN hat keine öffentliche Adresse. Jeder billige VPS löst das: Das Handy hält eine SSH-Verbindung zu ihm offen und lässt sich einen Port zurückleiten.

```
pn tunnel pn@203.0.113.7 2201
```

Das erzeugt einen Schlüssel, gibt die exakte `authorized_keys`-Zeile für den VPS aus (eingeschränkt, sodass der Schlüssel einen Port weiterleiten kann und sonst nichts), gibt den `~/.ssh/config`-Eintrag für deinen Laptop aus und richtet einen Dienst namens `tunnel` ein, der die Verbindung am Leben hält. Danach landet `ssh myphone` vom Laptop auf dem Handy. Lege dafür auf dem VPS einen eigenen unprivilegierten Benutzer an, die ausgegebene Zeile geht davon aus.

## Merken, wenn es stirbt

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

ruft diese URL alle fünf Minuten auf. Registriere dich bei healthchecks.io (kostenlos), lege einen Check mit fünf Minuten Periode an, und du bekommst eine Mail oder Nachricht, wenn das Handy sich nicht mehr meldet. Jede URL, die ein GET annimmt, funktioniert, also auch ein winziger Endpunkt auf deinem eigenen Server.

## Termux vom Rechner aus von der Abschussliste nehmen

Android hat eine Whitelist für Apps, die im Hintergrund laufen dürfen, und Hersteller legen ihre eigenen Listen obendrauf. Manche dieser Schalter liegen fünf Taps tief und unterscheiden sich von Handy zu Handy. Mit eingeschaltetem USB-Debugging legt dieses Skript die um, an die adb herankommt:

```
bash tools/unleash.sh
```

Es setzt Termux, Termux:Boot und Termux:API auf die Doze-Whitelist, erlaubt ihnen den Hintergrundbetrieb, öffnet Termux:Boot einmal, damit Android es als Boot-Empfänger akzeptiert, und weist das WLAN an, bei ausgeschaltetem Bildschirm anzubleiben. Herstellereinstellungen, an die adb nicht herankommt, gibt `pn doctor` auf dem Handy aus.

## Was es nicht ist

Es ist kein Root und ersetzt nicht das System, das Handy kann also weiterhin alles, was es vorher konnte, und deine Daten werden nicht angefasst.

Es ist kein vollständiges Init-System. Wenn du Dienstdateien im runit-Stil mit Abhängigkeiten willst, macht `pkg install termux-services` das gut. Bei phonenode geht es darum, dass das Handy überlebt und erreichbar ist, und unter seinem Supervisor läuft alles, auch `sv` aus termux-services.

Es ist kein VPN und öffnet keine Ports auf deinem Router. Der Tunnel geht vom Handy nach draußen, wie jede andere ausgehende Verbindung.

## Getestet auf

| Handy | Android | Userspace | Anmerkungen |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | 32-Bit-arm auf einem 64-Bit-Chip | das Referenzgerät, seit September 2026 im Dauerbetrieb |

Berichte von anderen Handys sind der nützlichste Beitrag überhaupt. Mach ein Issue auf mit Modell, Android-Version, der Ausgabe von `pn doctor` und der bisherigen Laufzeit.

## Was mich gebissen hat

Jeder Punkt hat einen Abend gekostet. Der Doctor prüft sie jetzt.

- **Der Userspace kann auf einem 64-Bit-Chip 32-Bit sein.** Günstige Handys liefern ein armeabi-v7a-Termux auf einer arm64-CPU aus. `uname -m` sagt armv8l und lügt, `dpkg --print-architecture` sagt arm und hat recht. Ein arm64-Binary startet nicht einmal.
- **Es gibt keinen CA-Speicher.** Go- und Rust-Binaries prüfen TLS gegen den Systemspeicher, Termux hat bis `pkg install ca-certificates` keinen, und statische Binaries brauchen zusätzlich `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem`, um ihn zu finden. Das Symptom sieht aus wie ein kaputtes Netz.
- **Es gibt keine `/etc/resolv.conf`.** Termux' eigene Werkzeuge lösen Namen über Android auf. Ein statisches Binary nicht, es scheitert an jeder DNS-Anfrage, bis du ihm einen Resolver nennst. `getprop net.dns1` zeigt einen, der Router geht meist auch.
- **`/proc` ist größtenteils zu.** Unter Android 13 kann eine App `/proc/uptime` und `/proc/net/tcp` nicht lesen, und `pgrep` kann Prozesse übersehen, weil die Namen, die es sieht, abgeschnitten sind. phonenode liest die Laufzeit aus `/proc/self/stat` und prüft sshd, indem es sich verbindet.
- **Termux:API-Befehle hängen ewig, wenn die Termux:API-App fehlt.** Kein Fehler, ein Hänger. Alles in phonenode ruft sie unter `timeout` auf.
- **Nie per `scp` über ein laufendes Skript kopieren.** bash liest Skripte stückweise, `scp` kürzt und überschreibt dieselbe Datei, und die laufende Kopie liest Müll oder forkt doppelt. Neue Datei schreiben und `mv`. So hatte ich einmal zwei Supervisoren auf einem Handy.
- **`pkill -f` nach Namen bringt deinen eigenen Supervisor um,** wenn dessen Befehlszeile den gesuchten Namen enthält. phonenode beendet nach PID aus Dateien, und die Befehlszeile des Supervisors enthält deinen Befehl nicht.
- **Android Go ist ein anderes Tier.** Es beendet Hintergrund-Apps deutlich eifriger. Die Akku-Einstellungen sind dort keine Option, und der Neustart-Test ist der einzige Beweis.

## Mitmachen

Kleine Pull Requests, eine Sache pro Stück. `shellcheck` muss sauber sein und `tests/smoke.sh` muss durchlaufen, beides läuft bei jedem Push im CI. Bash mit Absicht: Jeder kann die Skripte öffnen und sehen, was sie mit seinem Handy machen, bevor er sie ausführt.

Übersetzungen liegen in `docs/i18n`. Wenn deine sich schlecht liest, verbessere sie, die englische Datei ist die Referenz.

## Lizenz

MIT.
