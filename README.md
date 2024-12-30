# Conky settings

My opinionated conky settings.

![image](https://github.com/user-attachments/assets/2d08a6a2-3094-4d97-8838-5f302951892f)

## Features

- Top 50 processes
- The amount of Better Stack incidents
- Disk usage for remote server
- Now playing song from Last.fm
- Today's tasks from Todoist
- NextDNS status
- Amount of trackers blocked today
- Network speed
- Network latency
- CPU usage
- RAM usage
- Swap usage
- IRC lastlog

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
sudo chmod +x $HOME/.config/conky/lastfm.sh
sudo chmod +x $HOME/.config/conky/todoist.sh
sudo chmod +x $HOME/.config/conky/network-latency.sh
sudo chmod +x $HOME/.config/conky/network-speed.sh
sudo chmod +x $HOME/.config/conky/dns-latency.sh
sudo chmod +x $HOME/.config/conky/irc-lastlog.sh
```

Update .env file with your credentials and edit conky.conf to your liking.

## Conky

```bash
conky -c ~/.config/conky/conky.conf
```
