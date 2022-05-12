#!/bin/bash

package_util="yum"
if command -v "apt" &> /dev/null; then
    package_util="apt-get"
fi

"$package_util" install -y zsh git screen cargo

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

sed -i '1 i\export PATH=$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:$PATH' ~/.zshrc
sed -i '/^ZSH_THEME/s/robbyrussell/afowler/' ~/.zshrc

# Some utilityes from github
git clone https://github.com/rupa/z.git
sed -i -e '$a. ~/z/z.sh' ~/.zshrc

git clone --depth 1 https://github.com/junegunn/fzf.git
~/fzf/install
source .zshrc

cargo install --locked navi
navi repo add https://github.com/SandakovMM/my_navi_cheats
navi repo add https://git.plesk.ru/scm/~msandakov/plesk-cheats-for-navi.git