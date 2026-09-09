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
  <img src="https://img.shields.io/badge/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-2ea043?style=flat-square" alt="हिन्दी">
  <a href="README.id.md"><img src="https://img.shields.io/badge/Bahasa%20Indonesia-30363d?style=flat-square" alt="Bahasa Indonesia"></a>
</p>

[![ci](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml/badge.svg)](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml)
![bash](https://img.shields.io/badge/bash-no%20dependencies-4EAA25?logo=gnubash&logoColor=white)
![android](https://img.shields.io/badge/Android%207%2B-no%20root-3DDC84?logo=android&logoColor=white)
![termux](https://img.shields.io/badge/Termux-F--Droid%20build-111111)
![license](https://img.shields.io/badge/license-MIT-blue)

पुराने Android फ़ोन को हमेशा चलने वाला सर्वर बनाइए। बिना root, बिना custom ROM, एक कमांड में।

पुराना फ़ोन असल में एक छोटी Linux मशीन है जिसमें बैटरी के रूप में UPS लगा है और जो एक या दो वॉट खाती है। उस पर कुछ चला देना कभी मुश्किल नहीं था। मुश्किल यह है कि छह घंटे बाद Android ने उसे मार दिया, या फ़ोन रीबूट हुआ और कुछ वापस नहीं आया, या वह आपके राउटर के NAT के पीछे बैठा है जहाँ आप पहुँच नहीं सकते, या लॉग ने स्टोरेज खा लिया और आपको हफ़्ते भर बाद पता चला। phonenode उन सब चीज़ों का सेट है जो चाहिए ताकि फ़ोन चलता रहे और पहुँच में रहे, और साथ में एक `doctor` जो बताता है कि आपके फ़ोन पर इनमें से क्या कमी है।

मैं करीब पचास डॉलर के POCO C51 पर नेटवर्क मापने वाला एक probe चलाता हूँ। वह Wi-Fi पर एक दराज़ में पड़ा रहता है, हर पंद्रह मिनट में रिपोर्ट करता है, रीबूट और Android Go दोनों झेल चुका है, और मैं दो डॉलर के VPS के ज़रिए कहीं से भी उस पर ssh कर लेता हूँ। वहाँ तक पहुँचने के लिए जो कुछ मुझे सीखना पड़ा, वह सब इस रिपॉज़िटरी में है, ताकि आपको दोबारा न सीखना पड़े।

<p align="center"><img src="../how-it-works.svg" alt="घर के Wi-Fi पर फ़ोन, VPS तक reverse tunnel, ssh से पहुँचता लैपटॉप, healthchecks को heartbeat" width="900"></p>

## आपको क्या मिलता है

| फ़ोन सर्वर क्यों मर जाते हैं | phonenode इसका क्या करता है |
|---|---|
| Android बैकग्राउंड प्रोसेस मार देता है | हर सर्विस के लिए अलग supervisor जो बढ़ते अंतराल के साथ उसे दोबारा चलाता है, और एक स्क्रिप्ट जो आपके कंप्यूटर से Termux को बैटरी की kill list से बाहर निकालती है |
| CPU सो जाता है और टाइमर खिसक जाते हैं या देर से चलते हैं | Termux:API के ज़रिए wake lock पकड़े रखता है |
| रीबूट के बाद कुछ शुरू नहीं होता | Termux:Boot का hook सब कुछ वापस ले आता है, और अगर OS कभी hook रोक दे तो Termux को हाथ से खोलना भी वही काम करता है |
| फ़ोन NAT के पीछे है | किसी भी VPS तक reverse SSH tunnel, ताकि `ssh myphone` कहीं से भी चले |
| फ़ोन के मरने का पता हफ़्ते भर बाद चलता है | healthchecks.io या किसी भी URL पर heartbeat, ताकि फ़ोन के बाहर कोई चीज़ नोटिस करे |
| लॉग स्टोरेज भर देते हैं | rotation, क्योंकि फ़ोन पर यह काम और कोई नहीं करेगा |
| पता नहीं ऊपर वाली में से क्या गड़बड़ है | `pn doctor` |

## इंस्टॉल

फ़ोन पर, Termux के अंदर। Termux का F-Droid वाला बिल्ड लीजिए, Play Store वाला छोड़ दिया गया है और पैकेज इंस्टॉल नहीं कर सकता।

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

साथ में F-Droid से, जहाँ से Termux लिया, दो छोटे ऐप चाहिए: **Termux:API** (wake lock, बैटरी की स्थिति) और **Termux:Boot** (बूट पर शुरू करना)। Termux:Boot इंस्टॉल करने के बाद उसे एक बार खोलिए। जब तक वह खोला नहीं गया, Android उसे बूट पर नहीं चलाएगा।

इंस्टॉलर सब कुछ `~/.phonenode` में रखता है, `pn` को आपके PATH में लिंक करता है, boot hook लगाता है और `pn doctor` चलाता है। doctor जो कहे उसे पढ़िए, वह आपके फ़ोन के निर्माता को जानता है।

## इस्तेमाल

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` एक नाम और एक कमांड लाइन लेता है। कमांड अपने ही supervisor के नीचे चलती है। बंद होने पर पाँच सेकंड बाद फिर शुरू होती है, लगातार मरती रहे तो अंतराल दोगुना होते हुए पाँच मिनट तक जाता है, और एक मिनट टिक जाए तो वापस पाँच सेकंड पर आ जाता है। `pn stop` उसे रोकता है और दोबारा चलाना बंद कर देता है। `pn restart` बदली हुई कमांड लागू करता है। सब कुछ रीबूट के बाद भी बचा रहता है।

```
pn doctor
```

उन चीज़ों की सूची पर चलता है जो फ़ोन सर्वर को मार देती हैं और बताता है कि क्या ठीक करना है, आपके निर्माता के लिए मेनू का रास्ता भी। यह यह भी बताता है कि पिछले रीबूट के बाद Termux:Boot सच में चला या नहीं, जो एक ऐसी चीज़ है जो सेटिंग्स में नहीं दिखती।

<p align="center"><img src="../status.svg" alt="POCO C51 पर pn status और pn doctor का आउटपुट" width="880"></p>

## कहीं से भी पहुँचिए

घर के Wi-Fi पर फ़ोन का कोई सार्वजनिक पता नहीं होता। कोई भी सस्ता VPS इसे हल कर देता है: फ़ोन उस तक एक SSH कनेक्शन खुला रखता है और उससे एक पोर्ट वापस भेजने को कहता है।

```
pn tunnel pn@203.0.113.7 2201
```

यह एक key बनाता है, VPS के लिए `authorized_keys` की सटीक लाइन छापता है (इस तरह सीमित कि key सिर्फ़ एक पोर्ट forward कर सके और कुछ नहीं), आपके लैपटॉप के लिए `~/.ssh/config` की एंट्री छापता है, और `tunnel` नाम की एक सर्विस बनाता है जो कनेक्शन को ज़िंदा रखती है। उसके बाद लैपटॉप से `ssh myphone` सीधे फ़ोन पर उतरता है। इसके लिए VPS पर एक अलग बिना विशेषाधिकार वाला user बनाइए, कमांड जो लाइन छापती है वह मानकर चलती है कि आपने ऐसा किया है।

## पता चले कि यह कब मरा

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

उस URL को हर पाँच मिनट में ping करता है। healthchecks.io पर साइन अप कीजिए (मुफ़्त), पाँच मिनट के period वाला एक check बनाइए, और फ़ोन जब रिपोर्ट करना बंद करेगा तो वह आपको ईमेल या मैसेज भेजेगा। कोई भी URL जो GET स्वीकार करता हो चलेगा, इसलिए आपके अपने सर्वर पर एक छोटा सा endpoint भी काफ़ी है।

## कंप्यूटर से Termux को kill list से बाहर निकालिए

Android में उन ऐप्स की whitelist होती है जो बैकग्राउंड में चल सकते हैं, और निर्माता उसके ऊपर अपनी सूचियाँ जोड़ देते हैं। इनमें से कुछ स्विच पाँच टैप गहराई में छिपे हैं और हर फ़ोन में अलग हैं। USB debugging चालू होने पर यह स्क्रिप्ट वे स्विच पलट देती है जहाँ तक adb पहुँच सकता है:

```
bash tools/unleash.sh
```

यह Termux, Termux:Boot और Termux:API को Doze की whitelist में डालती है, उन्हें बैकग्राउंड में चलने देती है, Termux:Boot को एक बार खोलती है ताकि Android उसे boot receiver के रूप में स्वीकार करे, और Wi-Fi को स्क्रीन बंद होने पर भी चालू रहने को कहती है। निर्माता की जो सेटिंग्स adb की पहुँच से बाहर हैं, उन्हें फ़ोन पर `pn doctor` छापता है।

## यह क्या नहीं है

यह root नहीं है और OS की जगह नहीं लेता, इसलिए फ़ोन पहले जो कुछ करता था वह अब भी करता है, और आपके डेटा को छुआ नहीं जाता।

यह पूरा init सिस्टम नहीं है। अगर आपको dependencies वाली runit जैसी service फ़ाइलें चाहिए, तो `pkg install termux-services` यह अच्छे से करता है। phonenode का काम है कि फ़ोन बचा रहे और पहुँच में रहे, और अपने supervisor के नीचे यह कुछ भी चलाता है, termux-services का `sv` भी।

यह VPN नहीं है और आपके राउटर पर पोर्ट नहीं खोलता। tunnel फ़ोन से बाहर की ओर जाता है, किसी भी और बाहर जाने वाले कनेक्शन की तरह।

## इन पर परखा गया

| फ़ोन | Android | Userspace | नोट |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | 64-bit चिप पर 32-bit arm | संदर्भ फ़ोन, सितंबर 2026 से लगातार चल रहा है |

दूसरे फ़ोनों से रिपोर्ट सबसे उपयोगी योगदान है। मॉडल, Android का संस्करण, `pn doctor` का आउटपुट और यह कितने समय से चल रहा है, इनके साथ एक issue खोलिए।

## जिन चीज़ों ने मुझे काटा

इनमें से हर एक में एक शाम गई। अब doctor इन्हें जाँचता है।

- **64-bit चिप पर userspace 32-bit हो सकता है।** सस्ते फ़ोन arm64 CPU पर armeabi-v7a वाला Termux देते हैं। `uname -m` armv8l कहता है और झूठ बोलता है, `dpkg --print-architecture` arm कहता है और सही है। arm64 का binary शुरू ही नहीं होगा।
- **CA store नहीं है।** Go और Rust के binary सिस्टम store से TLS जाँचते हैं, Termux में `pkg install ca-certificates` तक कोई store नहीं होता, और static binary को उसे ढूँढने के लिए अलग से `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` चाहिए। लक्षण ऐसे दिखते हैं जैसे नेटवर्क टूटा हो।
- **`/etc/resolv.conf` नहीं है।** Termux के अपने टूल Android के ज़रिए नाम resolve करते हैं। static binary नहीं करता, और जब तक उसे resolver न बताया जाए हर DNS lookup में फ़ेल होता है। `getprop net.dns1` एक दिखाता है, राउटर भी आमतौर पर चल जाता है।
- **`/proc` लगभग बंद है।** Android 13 पर ऐप `/proc/uptime` या `/proc/net/tcp` नहीं पढ़ सकता, और `pgrep` प्रोसेस छोड़ सकता है क्योंकि उसे दिखने वाले नाम कटे हुए होते हैं। phonenode uptime `/proc/self/stat` से पढ़ता है और sshd को उससे जुड़कर जाँचता है।
- **Termux:API ऐप न हो तो उसकी कमांड हमेशा के लिए अटक जाती हैं।** त्रुटि नहीं, अटकाव। phonenode में सब कुछ उन्हें `timeout` के नीचे बुलाता है।
- **चलती हुई स्क्रिप्ट के ऊपर कभी `scp` मत कीजिए।** bash स्क्रिप्ट को टुकड़ों में पढ़ता है, `scp` उसी फ़ाइल को काटकर फिर से लिखता है, और चलती हुई कॉपी कचरा पढ़ती है या दो बार fork होती है। नई फ़ाइल लिखिए और `mv` कीजिए। एक बार मेरे एक फ़ोन पर दो supervisor इसी वजह से हो गए थे।
- **नाम से `pkill -f` आपका अपना supervisor मार देगा** अगर उसकी कमांड लाइन में वह नाम है जो आप ढूँढ रहे हैं। phonenode फ़ाइलों में रखे pid से मारता है, और supervisor की कमांड लाइन में आपकी कमांड नहीं होती।
- **Android Go अलग ही जानवर है।** यह बैकग्राउंड ऐप्स कहीं ज़्यादा तत्परता से मारता है। वहाँ बैटरी की सेटिंग्स वैकल्पिक नहीं हैं, और रीबूट टेस्ट ही एकमात्र सबूत है।

## योगदान

छोटे pull request, हर एक में एक ही चीज़। `shellcheck` साफ़ होना चाहिए और `tests/smoke.sh` पास होना चाहिए, दोनों हर push पर CI में चलते हैं। Bash जानबूझकर: कोई भी स्क्रिप्ट खोलकर चलाने से पहले देख सकता है कि वे उसके फ़ोन के साथ क्या करेंगी।

अनुवाद `docs/i18n` में हैं। अगर आपकी भाषा वाला ठीक से नहीं पढ़ा जाता, तो उसे सुधारिए, अंग्रेज़ी फ़ाइल संदर्भ है।

## लाइसेंस

MIT.
