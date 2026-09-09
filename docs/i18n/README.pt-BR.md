# phonenode

<p align="center">
  <a href="../../README.md"><img src="https://img.shields.io/badge/English-30363d?style=flat-square" alt="English"></a>
  <a href="README.ru.md"><img src="https://img.shields.io/badge/%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9-30363d?style=flat-square" alt="Русский"></a>
  <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-30363d?style=flat-square" alt="简体中文"></a>
  <a href="README.es.md"><img src="https://img.shields.io/badge/Espa%C3%B1ol-30363d?style=flat-square" alt="Español"></a>
  <img src="https://img.shields.io/badge/Portugu%C3%AAs-2ea043?style=flat-square" alt="Português">
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

Transforme um Android velho em um servidor sempre ligado. Sem root, sem ROM customizada, um comando só.

Um celular velho é uma pequena máquina Linux com uma bateria fazendo as vezes de nobreak e consumindo um ou dois watts. Colocar algo para rodar nele nunca foi a parte difícil. A parte difícil é que seis horas depois o Android matou o processo, ou o celular reiniciou e nada voltou, ou ele está atrás do NAT do seu roteador onde você não consegue alcançá-lo, ou os logs comeram o armazenamento e você só descobriu uma semana depois. O phonenode é o conjunto de coisas de que você precisa para o celular continuar de pé e continuar acessível, mais um `doctor` que diz qual delas está faltando no seu aparelho.

Eu rodo uma sonda de medição de rede em um POCO C51 que custou uns cinquenta dólares. Ele vive numa gaveta no Wi-Fi, reporta a cada quinze minutos, sobreviveu a reinicializações e ao Android Go, e eu entro nele por ssh de qualquer lugar através de um VPS de dois dólares. Tudo o que precisei aprender para chegar lá está neste repositório, para que você não precise aprender de novo.

<p align="center"><img src="../how-it-works.svg" alt="o celular no Wi-Fi de casa, o túnel reverso para um VPS, o notebook entrando por ssh, o heartbeat para o healthchecks" width="900"></p>

## O que você ganha

| Por que servidores em celulares morrem | O que o phonenode faz a respeito |
|---|---|
| o Android mata processos em segundo plano | um supervisor por serviço que o reinicia com espera crescente, e um script que tira o Termux da lista negra da bateria a partir do seu computador |
| a CPU dorme e os timers atrasam ou disparam fora de hora | mantém um wake lock via Termux:API |
| depois de reiniciar nada sobe | um hook do Termux:Boot traz tudo de volta, e abrir o Termux na mão faz o mesmo se o sistema um dia bloquear o hook |
| o celular está atrás de NAT | um túnel SSH reverso para qualquer VPS, assim `ssh myphone` funciona de qualquer lugar |
| você descobre que ele morreu uma semana depois | um heartbeat para o healthchecks.io ou qualquer URL, para que algo fora do celular perceba |
| os logs enchem o armazenamento | rotação, porque nada mais em um celular vai fazer isso |
| você não sabe qual das opções acima está errada | `pn doctor` |

## Instalação

No celular, dentro do Termux. Use a versão do Termux do F-Droid, a da Play Store está abandonada e não consegue instalar pacotes.

```
curl -fsSL https://raw.githubusercontent.com/macintoshi-nakamoto/phonenode/main/install.sh | bash
```

Você também precisa de dois aplicativos pequenos do F-Droid, do mesmo lugar que o Termux: **Termux:API** (wake lock, estado da bateria) e **Termux:Boot** (iniciar no boot). Abra o Termux:Boot uma vez depois de instalar. O Android não vai executá-lo no boot enquanto ele não tiver sido aberto.

O instalador coloca tudo em `~/.phonenode`, cria o link de `pn` no seu PATH, instala o hook de boot e roda `pn doctor`. Leia o que o doctor diz, ele conhece o seu fabricante.

## Uso

```
pn add bot 'python bot.py' --dir ~/bot
pn start bot
pn status
pn logs bot -f
```

`pn add` recebe um nome e uma linha de comando. O comando roda sob seu próprio supervisor. Quando ele termina, é iniciado de novo depois de cinco segundos, dobrando até cinco minutos se continuar morrendo, e voltando a cinco segundos assim que ficar de pé por um minuto. `pn stop` para o serviço e para de reiniciá-lo. `pn restart` aplica um comando alterado. Tudo sobrevive a uma reinicialização.

```
pn doctor
```

percorre a lista de coisas que matam um servidor em celular e diz o que corrigir, com o caminho do menu para o seu fabricante. Ele também diz se o Termux:Boot realmente rodou depois da última reinicialização, que é a única coisa que você não consegue ver nas configurações.

<p align="center"><img src="../status.svg" alt="saída de pn status e pn doctor em um POCO C51" width="880"></p>

## Acesse de qualquer lugar

Um celular no Wi-Fi de casa não tem endereço público. Qualquer VPS barato resolve isso: o celular mantém uma conexão SSH aberta com ele e pede que uma porta seja encaminhada de volta.

```
pn tunnel pn@203.0.113.7 2201
```

Isso cria uma chave, imprime a linha exata de `authorized_keys` para o VPS (restrita para que a chave só possa encaminhar uma porta e nada mais), imprime a entrada de `~/.ssh/config` para o seu notebook e configura um serviço chamado `tunnel` que mantém a conexão viva. Depois disso, `ssh myphone` no notebook cai dentro do celular. Crie um usuário sem privilégios separado no VPS para isso, a linha que o comando imprime assume que você fez isso.

## Saiba quando ele morrer

```
pn heartbeat https://hc-ping.com/your-uuid 5
```

chama essa URL a cada cinco minutos. Cadastre-se no healthchecks.io (grátis), crie um check com período de cinco minutos, e ele vai te mandar e-mail ou mensagem quando o celular parar de dar sinal. Qualquer URL que aceite GET serve, então um endpoint minúsculo no seu próprio servidor também funciona.

## Tire o Termux da lista negra a partir do computador

O Android tem uma lista branca de aplicativos que podem rodar em segundo plano, e os fabricantes colocam suas próprias listas por cima. Alguns desses interruptores estão a cinco toques de profundidade e mudam de celular para celular. Com a depuração USB ligada, este script vira os que o adb consegue alcançar:

```
bash tools/unleash.sh
```

Ele coloca Termux, Termux:Boot e Termux:API na lista branca do Doze, permite que rodem em segundo plano, abre o Termux:Boot uma vez para que o Android o aceite como receptor de boot, e manda o Wi-Fi ficar ligado com a tela apagada. As configurações do fabricante que o adb não alcança são impressas pelo `pn doctor` no celular.

## O que ele não é

Não é root e não substitui o sistema, então o celular continua fazendo tudo o que fazia antes, e seus dados não são tocados.

Não é um sistema init completo. Se você quer arquivos de serviço no estilo runit com dependências, `pkg install termux-services` faz isso bem. O phonenode é sobre o celular sobreviver e ser acessível, e ele roda qualquer coisa sob seu supervisor, inclusive o `sv` do termux-services.

Não é uma VPN e não abre portas no seu roteador. O túnel sai do celular, como qualquer outra conexão de saída.

## Testado em

| Celular | Android | Espaço de usuário | Observações |
|---|---|---|---|
| POCO C51 (Xiaomi 2305EPCC4G) | 13 Go | arm de 32 bits num chip de 64 | o aparelho de referência, em produção desde setembro de 2026 |

Relatos de outros celulares são a contribuição mais útil que existe. Abra uma issue com o modelo, a versão do Android, a saída de `pn doctor` e há quanto tempo ele está de pé.

## Coisas que me morderam

Cada uma custou uma noite. O doctor agora verifica todas.

- **O espaço de usuário pode ser de 32 bits em um chip de 64.** Celulares baratos vêm com Termux armeabi-v7a em uma CPU arm64. `uname -m` diz armv8l e mente, `dpkg --print-architecture` diz arm e acerta. Um binário arm64 nem inicia.
- **Não existe repositório de CA.** Binários em Go e Rust verificam TLS contra o repositório do sistema, o Termux não tem nenhum até `pkg install ca-certificates`, e binários estáticos ainda precisam de `SSL_CERT_FILE=$PREFIX/etc/tls/cert.pem` para encontrá-lo. O sintoma parece uma rede quebrada.
- **Não existe `/etc/resolv.conf`.** As ferramentas do próprio Termux resolvem nomes através do Android. Um binário estático não, e falha em toda consulta DNS até você apontá-lo para um resolvedor. `getprop net.dns1` mostra um, o roteador normalmente também serve.
- **O `/proc` está quase todo fechado.** No Android 13 um aplicativo não consegue ler `/proc/uptime` nem `/proc/net/tcp`, e o `pgrep` pode deixar passar processos porque os nomes que ele vê estão truncados. O phonenode lê o uptime de `/proc/self/stat` e verifica o sshd conectando nele.
- **Os comandos do Termux:API travam para sempre quando o aplicativo Termux:API não está instalado.** Não é um erro, é um travamento. Tudo no phonenode os chama sob `timeout`.
- **Nunca faça `scp` por cima de um script que está rodando.** O bash lê scripts aos poucos, o `scp` trunca e reescreve o mesmo arquivo, e a cópia em execução lê lixo ou faz fork duas vezes. Escreva um arquivo novo e faça `mv`. Foi assim que uma vez tive dois supervisores em um celular.
- **`pkill -f` pelo nome vai matar o seu próprio supervisor** se a linha de comando dele contiver o nome que você está procurando. O phonenode mata pelo pid gravado em arquivo, e a linha de comando do supervisor não contém o seu comando.
- **O Android Go é outro bicho.** Ele mata aplicativos em segundo plano com muito mais vontade. Ali as configurações de bateria não são opcionais, e o teste de reinicialização é a única prova.

## Contribuindo

Pull requests pequenos, uma coisa em cada. O `shellcheck` precisa estar limpo e `tests/smoke.sh` precisa passar, os dois rodam no CI a cada push. Bash de propósito: qualquer pessoa pode abrir os scripts e ver o que eles fazem com o celular antes de executá-los.

As traduções ficam em `docs/i18n`. Se a sua estiver ruim de ler, corrija, o arquivo em inglês é a referência.

## Licença

MIT.
