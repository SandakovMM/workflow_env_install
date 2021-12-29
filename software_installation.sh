#!/bin/bash

package_util="yum"
if command -v "apt" &> /dev/null; then
    package_util="apt-get"
fi

## ZSH and oh-my-zsh installation
"$package_util" install -y zsh git screen
chsh -s $(which zsh)
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sed -i 's/  read -r opt/  opt\=y/' install.sh # Avoid asking anything
chmod 755 install.sh
RUNZSH=no ./install.sh
rm install.sh

sed -i '/^ZSH_THEME/s/robbyrussell/afowler/' ~/.zshrc
