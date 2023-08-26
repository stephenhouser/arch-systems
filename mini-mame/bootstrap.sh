#!/bin/bash

game_user=mame
game_password=gamer

# If I am *not* the mame user, create the *mame* user and run as them.
if [ "${USER}" != "${game_user}" ]; then
	if whiptail --yesno "You are not ${game_user}. Would you like to create ${game_user}?" 0 0; then
		echo ""
		echo "Creating ${game_user}..."
		sudo useradd -mU -s /usr/bin/zsh -G  wheel,uucp,video,audio,storage,games,input ${game_user}
		sudo chsh -s /usr/bin/zsh ${game_user}
		echo "${game_user}:${game_password}" | sudo chpasswd

		echo ""
		echo "You should now log in as ${game_user} and re-run this script."
		exit 0
	fi

	if whiptail --yesno "Continue anyway?" 0 0; then
		: # simply continues after the if...
	else
		exit 0
	fi
fi

# Clone the repository from GitHub
git clone https://github.com/stephenhouser/mini-mame.git mini-mame
cd mini-mame
exec bash ./setup-mini-mame.sh
