#!/bin/bash

package_util="yum"
if command -v "apt" &> /dev/null; then
    package_util="apt-get"
fi

DISTRO_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)

PACKAGES_TO_INSTALL=(zsh git jq)
IS_NAVI_AVAILABLE=false

case "$DISTRO_NAME" in
    "Rocky Linux 8"*) ;;
    "Ubuntu 18.04"*) PACKAGES_TO_INSTALL+=screen ; IS_NAVI_AVAILABLE=true ;;
    "Ubuntu 20.04"*) PACKAGES_TO_INSTALL+=screen ; IS_NAVI_AVAILABLE=true ;;
    "CentOS Linux 7"*) PACKAGES_TO_INSTALL+=screen ; IS_NAVI_AVAILABLE=true ;;
    *) echo "Distro is not supported" ; exit 1 ;;
esac

if "$IS_NAVI_AVAILABLE" ; then
    PACKAGES_TO_INSTALL+=cargo
fi

# "$package_util" install -y "${PACKAGES_TO_INSTALL[@]}"

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

if "$IS_NAVI_AVAILABLE" ; then
    git clone --depth 1 https://github.com/junegunn/fzf.git
    ~/fzf/install --completion --key_bindings --no-update-rc
    sed -i -e '$a [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' ~/.zshrc
    source .zshrc

    # require 2021 version of rust, so could not be installed on some distros (Rocky linux 8 for example)
    cargo install --locked navi
    navi repo add https://github.com/SandakovMM/my_navi_cheats
    navi repo add https://git.plesk.ru/scm/~msandakov/plesk-cheats-for-navi.git
fi

source .zshrc