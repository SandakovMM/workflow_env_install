#!/bin/bash

if "$1" == "--remote" || "$1" == "-r" ; then
    echo "Upload to remoate host and update"
    scp -i ~/.ssh/id_testers $(readlink -m "$0") root@$1:/root/software_installation.sh
    ssh -i ~/.ssh/id_testers root@$1 "bash /root/software_installation.sh"
    exit 0
fi

package_util="yum"
if command -v "apt" &> /dev/null; then
    package_util="apt-get"
fi

DISTRO_NAME=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)

PACKAGES_TO_INSTALL=(vim fish git jq gdb python3-pip)
IS_NAVI_AVAILABLE=false

case "$DISTRO_NAME" in
    "Rocky Linux 8"*) PACKAGES_TO_INSTALL+=(screen gdb-gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "AlmaLinux 8"*) PACKAGES_TO_INSTALL+=(screen gdb-gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "Ubuntu 18.04"*) PACKAGES_TO_INSTALL+=(screen gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "Ubuntu 20.04"*) PACKAGES_TO_INSTALL+=(screen gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "Ubuntu 22.04"*) PACKAGES_TO_INSTALL+=(screen gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "Debian GNU/Linux 11"*) PACKAGES_TO_INSTALL+=(screen gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    "CentOS Linux 7"*) PACKAGES_TO_INSTALL+=(screen gdbserver) ; IS_NAVI_AVAILABLE=true ;;
    *) echo "Distro is not supported" ; exit 1 ;;
esac

if "$IS_NAVI_AVAILABLE" ; then
    PACKAGES_TO_INSTALL+=(cargo)
fi

"$package_util" update -y
"$package_util" install -y "${PACKAGES_TO_INSTALL[@]}"

# Configure fish and plugins
chsh -s $(which fish)

curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jorgebucaran/z # Analog of z utility but as plugin in fish

if "$IS_NAVI_AVAILABLE" ; then
    PATH="$HOME/.cargo/bin:$PATH"
    echo 'set PATH $HOME/.cargo/bin $PATH' >> /etc/fish/config.fish
    git clone --depth 1 https://github.com/junegunn/fzf.git
    ~/fzf/install --completion --key-bindings --no-update-rc

    # require 2021 version of rust, so could not be installed on some distros (Rocky linux 8 for example)
    cargo install --locked navi
    fish -c "navi repo add https://github.com/SandakovMM/my_navi_cheats"
    fish -c "navi repo add https://git.plesk.ru/scm/~msandakov/plesk-cheats-for-navi.git"
fi

if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" >> ~/.ssh/authorized_keys
fi
