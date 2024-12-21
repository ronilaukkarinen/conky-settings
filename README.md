# Conky settings

My opinionated conky settings.

![Screenshot from 2024-12-21 14-13-13](https://github.com/user-attachments/assets/e9cd3733-225b-4aed-a138-b8b1e9fdb7b5)

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
sudo chmod +x $HOME/.config/conky/betterstack-incidents.sh
sudo chmod +x $HOME/.config/conky/disk-quota-remote.sh
```

Update .env file with your credentials and edit conky.conf to your liking.

## Conky

```bash
conky -c ~/.config/conky/conky.conf
```
