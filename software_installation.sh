#!/bin/bash

package_util="yum"
if command -v "apt" &> /dev/null; then
    package_util="apt-get"
fi

"$package_util" install -y zsh git screen

# oh-my-zsh installation
chsh -s $(which zsh)
wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sed -i 's/  read -r opt/  opt\=y/' install.sh # Avoid asking anything
chmod 755 install.sh
RUNZSH=no ./install.sh
rm install.sh

# And some little plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions

sed -i '/^ZSH_THEME/s/robbyrussell/afowler/' ~/.zshrc
