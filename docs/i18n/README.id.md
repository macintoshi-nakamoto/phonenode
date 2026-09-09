# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-30363d?style=flat-square" alt="简体中文"></a>
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Portugu%C3%AAs-30363d?style=flat-square" alt="Português"></a>
  <a href="README.de.md"><img src="https://img.shields.io/badge/Deutsch-30363d?style=flat-square" alt="Deutsch"></a>
  <a href="README.fr.md"><img src="https://img.shields.io/badge/Fran%C3%A7ais-30363d?style=flat-square" alt="Français"></a>
  <a href="README.ja.md"><img src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-30363d?style=flat-square" alt="日本語"></a>
  <a href="README.hi.md"><img src="https://img.shields.io/badge/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-30363d?style=flat-square" alt="हिन्दी"></a>
  <img src="https://img.shields.io/badge/Bahasa%20Indonesia-2ea043?style=flat-square" alt="Bahasa Indonesia">
</p>

[![ci](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml/badge.svg)](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml)
![bash](https://img.shields.io/badge/bash-no%20dependencies-4EAA25?logo=gnubash&logoColor=white)
![android](https://img.shields.io/badge/Android%207%2B-no%20root-3DDC84?logo=android&logoColor=white)
![termux](https://img.shields.io/badge/Termux-F--Droid%20build-111111)
![license](https://img.shields.io/badge/license-MIT-blue)

Ubah ponsel Android lama menjadi server yang selalu menyala. Tanpa root, tanpa custom ROM, satu perintah.

Ponsel lama adalah mesin Linux kecil dengan baterai sebagai UPS-nya yang hanya menyedot satu atau dua watt. Menjalankan sesuatu di atasnya tidak pernah jadi bagian yang sulit. Yang sulit adalah enam jam kemudian Android sudah mematikannya, atau ponselnya reboot dan tidak ada yang kembali hidup, atau ia berada di belakang NAT router Anda sehingga tidak bisa dijangkau, atau log memakan habis penyimpanan dan Anda baru tahu seminggu kemudian. phonenode adalah kumpulan hal yang Anda butuhkan agar ponsel tetap hidup dan tetap bisa dijangkau, plus sebuah `doctor` yang memberi tahu mana di antaranya yang kurang di ponsel Anda.

Saya menjalankan probe pengukuran jaringan di sebuah POCO C51 seharga sekitar lima puluh dolar. Ia hidup di dalam laci dengan Wi-Fi, melapor setiap lima belas menit, sudah selamat dari reboot dan Android Go, dan saya masuk lewat ssh dari mana saja melalui VPS seharga dua dolar. Semua yang harus saya pelajari untuk sampai ke sana ada di repositori ini, supaya Anda tidak perlu mempelajarinya lagi.

<p align="center"><img src="../how-it-works.svg" alt="ponsel di Wi-Fi rumah, tunnel balik ke VPS, laptop masuk lewat ssh, heartbeat ke healthchecks" width="900"></p>

## Yang Anda dapatkan

| Kenapa server di ponsel mati | Apa yang dilakukan phonenode |
|---|---|
| Android mematikan proses latar belakang | satu supervisor per layanan yang menjalankannya lagi dengan jeda yang bertambah, dan sebuah skrip yang mengeluarkan Termux dari daftar bunuh baterai dari komputer Anda |
| CPU tidur dan timer melenceng atau terlambat | menahan wake lock lewat Termux:API |
| setelah reboot tidak ada yang jalan | hook Termux:Boot menghidupkan semuanya kembali, dan membuka Termux secara manual melakukan hal yang sama kalau suatu saat OS memblokir hook itu |
| ponsel berada di belakang NAT | reverse SSH tunnel ke VPS mana pun, sehingga `ssh myphone` bisa dari mana saja |
| Anda baru tahu ia mati seminggu kemudian | heartbeat ke healthchecks.io atau URL mana pun, supaya sesuatu di luar ponsel yang menyadarinya |
| log memenuhi penyimpanan | rotasi, karena tidak ada hal lain di ponsel yang akan melakukannya |
| Anda tidak tahu mana dari semua itu yang salah | `pn doctor` |

## Pemasangan

Di ponsel, di dalam Termux. Gunakan Termux versi F-Droid, versi Play Store sudah ditinggalkan dan tidak bisa memasang paket.

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

Anda juga butuh dua aplikasi kecil dari F-Droid, tempat yang sama dengan Termux: **Termux:API** (wake lock, status baterai) dan **Termux:Boot** (jalan saat boot). Buka Termux:Boot sekali setelah memasangnya. Android tidak akan menjalankannya saat boot sebelum aplikasi itu pernah dibuka.

Pemasang menaruh semuanya di `~/.phonenode`, menautkan `pn` ke PATH Anda, memasang hook boot, dan menjalankan `pn doctor`. Baca apa yang dikatakan doctor, ia tahu soal vendor ponsel Anda.

## Pemakaian

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` menerima sebuah nama dan sebuah baris perintah. Perintah itu berjalan di bawah supervisor-nya sendiri. Ketika berhenti, ia dijalankan lagi setelah lima detik, jedanya berlipat dua sampai lima menit kalau terus mati, dan kembali ke lima detik begitu ia bertahan satu menit. `pn stop` menghentikannya dan berhenti menjalankannya lagi. `pn restart` menerapkan perintah yang diubah. Semuanya selamat dari reboot.

```
pn doctor
```

memeriksa daftar hal yang membunuh server di ponsel dan mengatakan apa yang perlu diperbaiki, lengkap dengan jalur menu untuk vendor Anda. Ia juga memberi tahu apakah Termux:Boot benar-benar berjalan setelah reboot terakhir, satu-satunya hal yang tidak bisa dilihat dari pengaturan.

<p align="center"><img src="../status.svg" alt="keluaran pn status dan pn doctor di POCO C51" width="880"></p>

## Jangkau dari mana saja

Ponsel di Wi-Fi rumah tidak punya alamat publik. VPS murah mana pun menyelesaikannya: ponsel menjaga satu koneksi SSH tetap terbuka ke sana dan memintanya meneruskan satu port kembali.

```
pn tunnel pn@203.0.113.7 2201
```

Ini membuat kunci, mencetak baris `authorized_keys` yang persis untuk VPS (dibatasi supaya kunci itu hanya bisa meneruskan satu port dan tidak bisa yang lain), mencetak entri `~/.ssh/config` untuk laptop Anda, dan menyiapkan layanan bernama `tunnel` yang menjaga koneksi tetap hidup. Setelah itu, `ssh myphone` dari laptop mendarat di ponsel. Buat pengguna terpisah tanpa hak istimewa di VPS untuk ini, baris yang dicetak perintah itu mengasumsikan Anda sudah melakukannya.

## Tahu kapan ia mati

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

memanggil URL itu setiap lima menit. Daftar di healthchecks.io (gratis), buat check dengan periode lima menit, dan ia akan mengirim email atau pesan ketika ponsel berhenti melapor. URL apa pun yang menerima GET bisa dipakai, jadi endpoint kecil di server Anda sendiri juga bisa.

## Keluarkan Termux dari daftar bunuh dari komputer Anda

Android punya daftar putih aplikasi yang boleh berjalan di latar belakang, dan vendor menumpuk daftar mereka sendiri di atasnya. Beberapa sakelar itu terkubur lima ketukan dalamnya dan berbeda di tiap ponsel. Dengan USB debugging menyala, skrip ini membalik sakelar yang bisa dijangkau adb:

```
bash tools/unleash.sh
```

Ia memasukkan Termux, Termux:Boot, dan Termux:API ke daftar putih Doze, mengizinkan mereka berjalan di latar belakang, membuka Termux:Boot sekali supaya Android menerimanya sebagai penerima boot, dan menyuruh Wi-Fi tetap menyala saat layar mati. Pengaturan vendor yang tidak bisa dijangkau adb akan dicetak oleh `pn doctor` di ponsel.

## Yang bukan phonenode

Ini bukan root dan tidak mengganti OS, jadi ponsel tetap bisa melakukan semua yang sebelumnya bisa, dan data Anda tidak disentuh.

Ini bukan sistem init lengkap. Kalau Anda ingin berkas layanan gaya runit dengan dependensi, `pkg install termux-services` melakukannya dengan baik. phonenode adalah soal ponsel tetap hidup dan bisa dijangkau, dan ia menjalankan apa saja di bawah supervisor-nya, termasuk `sv` dari termux-services.

Ini bukan VPN dan tidak membuka port di router Anda. Tunnel keluar dari ponsel, seperti koneksi keluar lainnya.

## Diuji di

| Ponsel | Android | Userspace | Catatan |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | arm 32-bit di atas chip 64-bit | ponsel acuan, dipakai produksi sejak September 2026 |

Laporan dari ponsel lain adalah kontribusi paling berguna yang ada. Buka issue dengan model, versi Android, keluaran `pn doctor`, dan sudah berapa lama ia hidup.

## Hal-hal yang pernah menggigit saya

Masing-masing menghabiskan satu malam. Sekarang doctor memeriksanya.

- **Userspace bisa 32-bit di chip 64-bit.** Ponsel murah membawa Termux armeabi-v7a di atas CPU arm64. `uname -m` bilang armv8l dan itu bohong, `dpkg --print-architecture` bilang arm dan itu benar. Binary arm64 bahkan tidak akan jalan.
- **Tidak ada penyimpanan CA.** Binary Go dan Rust memverifikasi TLS terhadap penyimpanan sistem, Termux tidak punya sampai `pkg install ca-certificates`, dan binary statis masih butuh `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` untuk menemukannya. Gejalanya terlihat seperti jaringan rusak.
- **Tidak ada `/etc/resolv.conf`.** Alat bawaan Termux menyelesaikan nama lewat Android. Binary statis tidak, dan gagal di setiap pencarian DNS sampai Anda mengarahkannya ke sebuah resolver. `getprop net.dns1` menampilkan satu, router biasanya juga bisa.
- **`/proc` sebagian besar tertutup.** Di Android 13 aplikasi tidak bisa membaca `/proc/uptime` atau `/proc/net/tcp`, dan `pgrep` bisa melewatkan proses karena nama yang dilihatnya terpotong. phonenode membaca uptime dari `/proc/self/stat` dan memeriksa sshd dengan menyambung ke sana.
- **Perintah Termux:API menggantung selamanya ketika aplikasi Termux:API tidak ada.** Bukan error, tapi menggantung. Semua yang ada di phonenode memanggilnya di bawah `timeout`.
- **Jangan pernah `scp` menimpa skrip yang sedang berjalan.** bash membaca skrip sedikit demi sedikit, `scp` memotong dan menulis ulang berkas yang sama, dan salinan yang sedang berjalan membaca sampah atau fork dua kali. Tulis berkas baru lalu `mv`. Begitulah saya pernah punya dua supervisor di satu ponsel.
- **`pkill -f` berdasarkan nama akan membunuh supervisor Anda sendiri** kalau baris perintahnya mengandung nama yang Anda cari. phonenode membunuh berdasarkan pid dari berkas, dan baris perintah supervisor tidak mengandung perintah Anda.
- **Android Go adalah makhluk yang berbeda.** Ia membunuh aplikasi latar belakang jauh lebih agresif. Di sana pengaturan baterai bukan pilihan, dan uji reboot adalah satu-satunya bukti.

## Berkontribusi

Pull request kecil, satu hal per pull request. `shellcheck` harus bersih dan `tests/smoke.sh` harus lulus, keduanya berjalan di CI pada setiap push. Bash memang disengaja: siapa pun bisa membuka skripnya dan melihat apa yang akan dilakukannya pada ponsel mereka sebelum menjalankannya.

Terjemahan ada di `docs/i18n`. Kalau terjemahan bahasa Anda terbaca janggal, perbaiki, berkas bahasa Inggris adalah acuannya.

## Lisensi

MIT.
