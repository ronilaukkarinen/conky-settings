# Conky settings

## Getting started

Install [conky](https://github.com/brndnmtthws/conky).

```bash
sudo apt update
sudo apt install conky-all
```

Clone this repository to `$HOME/.config/conky`.

```bash
git clone https://github.com/ronilaukkarinen/conky-settings.git ~/.config/conky
sudo chmod +x $HOME/.config/conky/top-processes.sh
```

## Conky

```bash
conky -c ~/.config/conky/conky.conf
```
