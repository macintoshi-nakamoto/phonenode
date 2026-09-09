# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-30363d?style=flat-square" alt="简体中文"></a>
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Portugu%C3%AAs-30363d?style=flat-square" alt="Português"></a>
  <a href="README.de.md"><img src="https://img.shields.io/badge/Deutsch-30363d?style=flat-square" alt="Deutsch"></a>
  <a href="README.fr.md"><img src="https://img.shields.io/badge/Fran%C3%A7ais-30363d?style=flat-square" alt="Français"></a>
  <img src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-2ea043?style=flat-square" alt="日本語">
  <a href="README.hi.md"><img src="https://img.shields.io/badge/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-30363d?style=flat-square" alt="हिन्दी"></a>
  <a href="README.id.md"><img src="https://img.shields.io/badge/Bahasa%20Indonesia-30363d?style=flat-square" alt="Bahasa Indonesia"></a>
</p>

[![ci](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml/badge.svg)](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml)
![bash](https://img.shields.io/badge/bash-no%20dependencies-4EAA25?logo=gnubash&logoColor=white)
![android](https://img.shields.io/badge/Android%207%2B-no%20root-3DDC84?logo=android&logoColor=white)
![termux](https://img.shields.io/badge/Termux-F--Droid%20build-111111)
![license](https://img.shields.io/badge/license-MIT-blue)

古い Android スマホを、常時稼働のサーバーにする。root 不要、カスタム ROM 不要、コマンド一つ。

古いスマホは、バッテリーという UPS を内蔵した小さな Linux マシンで、消費電力は 1〜2 ワット。何かを動かすこと自体が難しかったことは一度もありません。難しいのは、6 時間後に Android に殺されていること、再起動したら何も戻ってこないこと、ルーターの NAT の裏にいて手が届かないこと、ログがストレージを食い尽くして一週間後に気づくこと。phonenode は、スマホが落ちずに動き続け、手が届き続けるために必要なもの一式と、そのうちどれが自分のスマホに欠けているかを教えてくれる `doctor` です。

私は 50 ドルほどの POCO C51 でネットワーク計測用のプローブを動かしています。引き出しの中で Wi-Fi につながり、15 分ごとに報告し、再起動と Android Go を生き延び、2 ドルの VPS 経由でどこからでも ssh で入れます。そこにたどり着くまでに学ばなければならなかったことは全部このリポジトリにあるので、あなたはもう一度学ぶ必要がありません。

<p align="center"><img src="../how-it-works.svg" alt="自宅 Wi-Fi 上のスマホ、VPS へのリバーストンネル、ssh で入るノート PC、healthchecks へのハートビート" width="900"></p>

## 得られるもの

| スマホサーバーが死ぬ理由 | phonenode がすること |
|---|---|
| Android がバックグラウンドのプロセスを殺す | サービスごとに一つのスーパーバイザーが間隔を広げながら再起動し、PC からの一つのスクリプトが Termux をバッテリーのキルリストから外す |
| CPU が眠り、タイマーがずれたり遅れて発火する | Termux:API 経由で wake lock を保持する |
| 再起動後に何も起動しない | Termux:Boot のフックが全部を立ち上げ直す。OS がフックを止めても、Termux を手で開けば同じことが起きる |
| スマホが NAT の裏にいる | 任意の VPS へのリバース SSH トンネルで、どこからでも `ssh myphone` が通る |
| 死んだことに一週間後に気づく | healthchecks.io や任意の URL へのハートビートで、スマホの外側が気づく |
| ログがストレージを埋める | ローテーション。スマホの上でそれをやってくれるものは他にない |
| 上のどれが悪いのか分からない | `pn doctor` |

## インストール

スマホ上の Termux の中で実行します。Termux は F-Droid 版を使ってください。Play ストア版は放棄されていて、パッケージをインストールできません。

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

さらに、Termux と同じ F-Droid から小さなアプリを二つ入れます。**Termux:API**（wake lock、バッテリー状態）と **Termux:Boot**（起動時に実行）です。Termux:Boot はインストール後に一度開いてください。一度も開かれていないと、Android は起動時にそれを実行しません。

インストーラーはすべてを `~/.phonenode` に置き、`pn` を PATH にリンクし、ブートフックをインストールして `pn doctor` を実行します。doctor の言うことを読んでください。あなたのメーカーのことを知っています。

## 使い方

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` は名前とコマンドラインを受け取ります。コマンドは専用のスーパーバイザーの下で動きます。終了すると 5 秒後に再起動され、死に続けるなら間隔が 5 分まで倍々に伸び、1 分間持ちこたえたら 5 秒に戻ります。`pn stop` は停止し、再起動もやめます。`pn restart` は変更したコマンドを反映します。すべて再起動を生き延びます。

```
pn doctor
```

スマホサーバーを殺すもののリストを順に確認し、何を直すべきかを、あなたのメーカー向けのメニューの場所とともに教えます。前回の再起動後に Termux:Boot が本当に動いたかどうかも教えてくれます。これは設定画面からは見えない唯一の項目です。

<p align="center"><img src="../status.svg" alt="POCO C51 での pn status と pn doctor の出力" width="880"></p>

## どこからでも届くようにする

自宅 Wi-Fi 上のスマホにはグローバルアドレスがありません。安い VPS が一台あれば解決します。スマホが VPS への SSH 接続を張りっぱなしにして、ポートを一つ戻してもらいます。

```
pn tunnel pn@203.0.113.7 2201
```

これは鍵を作り、VPS の `authorized_keys` に書く正確な一行（この鍵はポート一つの転送だけができて他は何もできないよう制限済み）を表示し、ノート PC の `~/.ssh/config` のエントリを表示し、接続を維持する `tunnel` というサービスを用意します。その後はノート PC から `ssh myphone` でスマホに着きます。このために VPS 上に権限のない専用ユーザーを作ってください。表示される行はそうしている前提です。

## 死んだときに知る

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

その URL を 5 分ごとに叩きます。healthchecks.io に登録し（無料）、周期 5 分のチェックを作れば、スマホが報告しなくなったときにメールやメッセージが届きます。GET を受け付ける URL なら何でもいいので、自分のサーバーの小さなエンドポイントでも構いません。

## PC から Termux をキルリストから外す

Android にはバックグラウンド実行を許可するアプリのホワイトリストがあり、メーカーはその上に独自のリストを重ねています。そのスイッチの中には五回タップした先にあるものや、機種ごとに違うものがあります。USB デバッグを有効にした状態で、このスクリプトは adb の手が届くものを切り替えます。

```
bash tools/unleash.sh
```

Termux、Termux:Boot、Termux:API を Doze のホワイトリストに入れ、バックグラウンド実行を許可し、Android がブートレシーバーとして受け入れるよう Termux:Boot を一度開き、画面オフ中も Wi-Fi を維持するよう設定します。adb の手が届かないメーカー設定は、スマホ上の `pn doctor` が表示します。

## これは何ではないか

root ではなく、OS を置き換えるものでもありません。スマホは以前できたことをすべてそのままでき、データには触れません。

完全な init システムではありません。依存関係付きの runit 風サービスファイルが欲しいなら、`pkg install termux-services` がうまくやってくれます。phonenode はスマホが生き延びて手が届くことが目的で、termux-services の `sv` を含め何でもそのスーパーバイザーの下で動かせます。

VPN ではなく、ルーターのポートも開けません。トンネルは他の外向き接続と同じように、スマホから外へ出ていきます。

## 動作確認済み

| 機種 | Android | ユーザー空間 | 備考 |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | 64 ビットチップ上の 32 ビット arm | 基準機。2026 年 9 月から本番稼働中 |

他の機種からの報告が最も役に立つ貢献です。機種名、Android のバージョン、`pn doctor` の出力、稼働時間を添えて issue を開いてください。

## 私がはまったこと

どれも一晩ずつ費やしました。今は doctor が確認します。

- **64 ビットチップでもユーザー空間が 32 ビットのことがある。** 安価な機種は arm64 CPU に armeabi-v7a の Termux を載せています。`uname -m` は armv8l と言いますが嘘で、`dpkg --print-architecture` の arm が正しい。arm64 のバイナリは起動すらしません。
- **CA ストアがない。** Go や Rust のバイナリはシステムのストアで TLS を検証しますが、Termux には `pkg install ca-certificates` するまで何もなく、静的バイナリはさらに `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` がないと見つけられません。症状はネットワークの故障そっくりです。
- **`/etc/resolv.conf` がない。** Termux 自身のツールは Android 経由で名前を解決します。静的バイナリはそうではなく、リゾルバを指定するまですべての DNS 問い合わせに失敗します。`getprop net.dns1` に一つ出ますし、ルーターでも大抵大丈夫です。
- **`/proc` はほぼ閉じている。** Android 13 ではアプリは `/proc/uptime` も `/proc/net/tcp` も読めず、`pgrep` は見えるプロセス名が切り詰められているために取りこぼすことがあります。phonenode は稼働時間を `/proc/self/stat` から読み、sshd には実際に接続して確認します。
- **Termux:API アプリがないと、そのコマンドは永遠に固まる。** エラーではなく、固まります。phonenode の中では全部 `timeout` 付きで呼んでいます。
- **動いているスクリプトの上に `scp` で上書きしてはいけない。** bash はスクリプトを少しずつ読み、`scp` は同じファイルを切り詰めて書き直すので、動いている側はゴミを読むか二重に fork します。新しいファイルに書いて `mv` してください。私が一台のスマホにスーパーバイザーを二つ抱えたのはこれが原因でした。
- **名前で `pkill -f` すると自分のスーパーバイザーを殺す。** そのコマンドラインに探している名前が含まれていれば当然です。phonenode はファイルに記録した pid で殺し、スーパーバイザーのコマンドラインにはあなたのコマンドは含まれません。
- **Android Go は別の生き物。** バックグラウンドアプリをはるかに積極的に殺します。そこではバッテリー設定は任意ではなく、再起動テストだけが唯一の証明です。

## 貢献

小さなプルリクエストを、一つにつき一つのことで。`shellcheck` が通り、`tests/smoke.sh` が通ること。どちらも push のたびに CI で走ります。わざと Bash で書いています。誰でもスクリプトを開いて、実行前に自分のスマホに何をするのか確認できるからです。

翻訳は `docs/i18n` にあります。自分の言語の文章が読みにくければ直してください。英語のファイルが基準です。

## ライセンス

MIT。
