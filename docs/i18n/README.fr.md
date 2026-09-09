# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-30363d?style=flat-square" alt="简体中文"></a>
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <a href="README.pt-BR.md"><img src="https://img.shields.io/badge/Portugu%C3%AAs-30363d?style=flat-square" alt="Português"></a>
  <a href="README.de.md"><img src="https://img.shields.io/badge/Deutsch-30363d?style=flat-square" alt="Deutsch"></a>
  <img src="https://img.shields.io/badge/Fran%C3%A7ais-2ea043?style=flat-square" alt="Français">
  <a href="README.ja.md"><img src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-30363d?style=flat-square" alt="日本語"></a>
  <a href="README.hi.md"><img src="https://img.shields.io/badge/%E0%A4%B9%E0%A4%BF%E0%A4%A8%E0%A5%8D%E0%A4%A6%E0%A5%80-30363d?style=flat-square" alt="हिन्दी"></a>
  <a href="README.id.md"><img src="https://img.shields.io/badge/Bahasa%20Indonesia-30363d?style=flat-square" alt="Bahasa Indonesia"></a>
</p>

[![ci](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml/badge.svg)](https://github.com/macintoshi-nakamoto/phonenode/actions/workflows/ci.yml)
![bash](https://img.shields.io/badge/bash-no%20dependencies-4EAA25?logo=gnubash&logoColor=white)
![android](https://img.shields.io/badge/Android%207%2B-no%20root-3DDC84?logo=android&logoColor=white)
![termux](https://img.shields.io/badge/Termux-F--Droid%20build-111111)
![license](https://img.shields.io/badge/license-MIT-blue)

Transformez un vieux téléphone Android en serveur toujours allumé. Sans root, sans ROM custom, en une commande.

Un vieux téléphone, c'est une petite machine Linux avec une batterie en guise d'onduleur, qui consomme un ou deux watts. Faire tourner quelque chose dessus n'a jamais été le problème. Le problème, c'est que six heures plus tard Android l'a tué, ou que le téléphone a redémarré et que rien n'est revenu, ou qu'il est derrière le NAT de votre box et que vous ne pouvez pas l'atteindre, ou que les logs ont mangé le stockage et que vous l'avez découvert une semaine après. phonenode, c'est l'ensemble de ce qu'il faut pour que le téléphone reste debout et reste joignable, plus un `doctor` qui vous dit ce qui manque sur le vôtre.

Je fais tourner une sonde de mesure réseau sur un POCO C51 qui a coûté une cinquantaine de dollars. Il vit dans un tiroir en Wi-Fi, se manifeste toutes les quinze minutes, a survécu aux redémarrages et à Android Go, et j'y entre en ssh de n'importe où via un VPS à deux dollars. Tout ce que j'ai dû apprendre pour en arriver là est dans ce dépôt, pour que vous n'ayez pas à le réapprendre.

<p align="center"><img src="../how-it-works.svg" alt="le téléphone sur le Wi-Fi de la maison, le tunnel inverse vers un VPS, le portable qui y accède en ssh, le heartbeat vers healthchecks" width="900"></p>

## Ce que vous obtenez

| Pourquoi les serveurs sur téléphone meurent | Ce que phonenode fait contre ça |
|---|---|
| Android tue les processus en arrière-plan | un superviseur par service qui le relance avec un délai croissant, et un script qui retire Termux de la liste noire de la batterie depuis votre ordinateur |
| le processeur s'endort, les timers dérivent ou se déclenchent en retard | maintient un wake lock via Termux:API |
| après un redémarrage rien ne démarre | un hook Termux:Boot remet tout en route, et ouvrir Termux à la main fait pareil si le système bloque un jour le hook |
| le téléphone est derrière un NAT | un tunnel SSH inverse vers n'importe quel VPS, pour que `ssh myphone` marche de partout |
| vous apprenez sa mort une semaine plus tard | un heartbeat vers healthchecks.io ou n'importe quelle URL, pour que quelque chose hors du téléphone s'en aperçoive |
| les logs remplissent le stockage | une rotation, parce que rien d'autre sur un téléphone ne s'en chargera |
| vous ne savez pas lequel de ces points cloche | `pn doctor` |

## Installation

Sur le téléphone, dans Termux. Prenez la version F-Droid de Termux, celle du Play Store est abandonnée et ne peut plus installer de paquets.

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

Il vous faut aussi deux petites applications depuis F-Droid, au même endroit que Termux : **Termux:API** (wake lock, état de la batterie) et **Termux:Boot** (démarrage au boot). Ouvrez Termux:Boot une fois après l'avoir installé. Android ne le lancera pas au démarrage tant qu'il n'a jamais été ouvert.

L'installateur met tout dans `~/.phonenode`, lie `pn` dans votre PATH, installe le hook de démarrage et lance `pn doctor`. Lisez ce que dit le doctor, il connaît votre fabricant.

## Utilisation

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` prend un nom et une ligne de commande. La commande tourne sous son propre superviseur. Quand elle se termine, elle est relancée au bout de cinq secondes, le délai double jusqu'à cinq minutes si elle continue de mourir, et revient à cinq secondes dès qu'elle a tenu une minute. `pn stop` l'arrête et cesse de la relancer. `pn restart` prend en compte une commande modifiée. Tout survit à un redémarrage.

```
pn doctor
```

passe en revue la liste de ce qui tue un serveur sur téléphone et dit quoi corriger, avec le chemin dans les menus pour votre fabricant. Il vous dit aussi si Termux:Boot a réellement tourné après le dernier redémarrage, la seule chose qu'on ne peut pas voir dans les réglages.

<p align="center"><img src="../status.svg" alt="sortie de pn status et pn doctor sur un POCO C51" width="880"></p>

## L'atteindre de n'importe où

Un téléphone sur le Wi-Fi de la maison n'a pas d'adresse publique. N'importe quel VPS bon marché règle ça : le téléphone garde une connexion SSH ouverte vers lui et lui demande de renvoyer un port.

```
pn tunnel pn@203.0.113.7 2201
```

Cela crée une clé, affiche la ligne exacte d'`authorized_keys` pour le VPS (restreinte pour que la clé puisse renvoyer un port et rien d'autre), affiche l'entrée `~/.ssh/config` pour votre portable, et met en place un service nommé `tunnel` qui garde la connexion en vie. Ensuite, `ssh myphone` depuis le portable atterrit sur le téléphone. Créez pour cela un utilisateur non privilégié séparé sur le VPS, la ligne affichée par la commande suppose que c'est fait.

## Savoir quand il meurt

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

appelle cette URL toutes les cinq minutes. Inscrivez-vous sur healthchecks.io (gratuit), créez un check avec une période de cinq minutes, et il vous enverra un mail ou un message quand le téléphone cessera de se manifester. N'importe quelle URL qui accepte un GET convient, donc un minuscule endpoint sur votre propre serveur aussi.

## Retirer Termux de la liste noire depuis votre ordinateur

Android a une liste blanche d'applications autorisées à tourner en arrière-plan, et les fabricants rajoutent leurs propres listes par-dessus. Certains de ces interrupteurs sont à cinq tapotements de profondeur et changent d'un téléphone à l'autre. Avec le débogage USB activé, ce script bascule ceux que adb peut atteindre :

```
bash tools/unleash.sh
```

Il met Termux, Termux:Boot et Termux:API sur la liste blanche de Doze, les autorise à tourner en arrière-plan, ouvre Termux:Boot une fois pour qu'Android l'accepte comme récepteur de démarrage, et dit au Wi-Fi de rester allumé écran éteint. Les réglages du fabricant que adb ne peut pas atteindre sont affichés par `pn doctor` sur le téléphone.

## Ce que ce n'est pas

Ce n'est pas du root et ça ne remplace pas le système, le téléphone fait donc toujours tout ce qu'il faisait avant, et vos données ne sont pas touchées.

Ce n'est pas un système d'init complet. Si vous voulez des fichiers de service à la runit avec des dépendances, `pkg install termux-services` fait ça bien. phonenode s'occupe de ce que le téléphone survive et soit joignable, et il fait tourner n'importe quoi sous son superviseur, y compris `sv` de termux-services.

Ce n'est pas un VPN et ça n'ouvre aucun port sur votre box. Le tunnel part du téléphone, comme n'importe quelle autre connexion sortante.

## Testé sur

| Téléphone | Android | Espace utilisateur | Notes |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | arm 32 bits sur une puce 64 bits | le téléphone de référence, en production depuis septembre 2026 |

Les retours depuis d'autres téléphones sont la contribution la plus utile qui soit. Ouvrez une issue avec le modèle, la version d'Android, la sortie de `pn doctor` et depuis combien de temps il tient.

## Ce qui m'a mordu

Chaque point a coûté une soirée. Le doctor les vérifie maintenant.

- **L'espace utilisateur peut être en 32 bits sur une puce 64 bits.** Les téléphones bon marché livrent un Termux armeabi-v7a sur un processeur arm64. `uname -m` dit armv8l et ment, `dpkg --print-architecture` dit arm et a raison. Un binaire arm64 ne démarre même pas.
- **Il n'y a pas de magasin de certificats.** Les binaires Go et Rust vérifient TLS contre le magasin système, Termux n'en a aucun avant `pkg install ca-certificates`, et les binaires statiques ont encore besoin de `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` pour le trouver. Le symptôme ressemble à un réseau cassé.
- **Il n'y a pas de `/etc/resolv.conf`.** Les outils propres à Termux résolvent les noms via Android. Un binaire statique non, et il échoue à chaque requête DNS tant que vous ne lui indiquez pas un résolveur. `getprop net.dns1` en montre un, la box fonctionne généralement aussi.
- **`/proc` est presque fermé.** Sur Android 13 une application ne peut pas lire `/proc/uptime` ni `/proc/net/tcp`, et `pgrep` peut rater des processus parce que les noms qu'il voit sont tronqués. phonenode lit l'uptime dans `/proc/self/stat` et vérifie sshd en s'y connectant.
- **Les commandes Termux:API bloquent indéfiniment quand l'application Termux:API manque.** Pas une erreur, un blocage. Tout dans phonenode les appelle sous `timeout`.
- **Ne faites jamais `scp` par-dessus un script en cours d'exécution.** bash lit les scripts par morceaux, `scp` tronque et réécrit le même fichier, et la copie en cours lit n'importe quoi ou se lance deux fois. Écrivez un nouveau fichier et faites `mv`. C'est comme ça que je me suis retrouvé une fois avec deux superviseurs sur un téléphone.
- **`pkill -f` par nom tuera votre propre superviseur** si sa ligne de commande contient le nom que vous cherchez. phonenode tue par pid lu dans des fichiers, et la ligne de commande du superviseur ne contient pas votre commande.
- **Android Go est une autre bête.** Il tue les applications en arrière-plan bien plus volontiers. Là, les réglages de batterie ne sont pas optionnels, et le test du redémarrage est la seule preuve.

## Contribuer

De petites pull requests, une chose chacune. `shellcheck` doit être propre et `tests/smoke.sh` doit passer, les deux tournent en CI à chaque push. Bash exprès : n'importe qui peut ouvrir les scripts et voir ce qu'ils font à son téléphone avant de les lancer.

Les traductions vivent dans `docs/i18n`. Si la vôtre se lit mal, corrigez-la, le fichier anglais fait référence.

## Licence

MIT.
