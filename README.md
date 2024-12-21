# Conky settings

My opinionated conky settings.

![image](https://github.com/user-attachments/assets/2d08a6a2-3094-4d97-8838-5f302951892f)

## Features

- Displays top 50 processes
- Displays the amount of Better Stack incidents
- Displays disk usage for remote server
- Displays now playing song from Last.fm
- Displays today's tasks from Todoist

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
```

Update .env file with your credentials and edit conky.conf to your liking.

## Conky

```bash
conky -c ~/.config/conky/conky.conf
```
