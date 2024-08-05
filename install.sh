#!/bin/bash


# 설치할 패키지들
PACKAGES="vim net-tools openssh-server zsh curl wget git util-linux-user passwd sudo"



# 배포판 확인 함수
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif command -v lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
    elif [ -f /etc/debian_version ]; then
        OS=debian
    elif [ -f /etc/redhat-release ]; then
        OS=redhat
    else
        OS=$(uname -s)
    fi
}

# 패키지 매니저 설정 함수
set_package_manager() {
    case "$OS" in
        ubuntu|debian)
            PKG_MANAGER="apt"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
            ;;
        fedora)
            PKG_MANAGER="dnf"
            INSTALL_CMD="sudo dnf install -y"
            ;;
        centos|redhat|rocky)
            PKG_MANAGER="yum"
            INSTALL_CMD="sudo yum install -y"
            ;;
        arch)
            PKG_MANAGER="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
            ;;
        *)
            echo "지원하지 않는 배포판입니다: $OS"
            exit 1
            ;;
    esac

    echo "OS 정보 ::: $OS"
}

# 기본 패키지 설치 함수
install_packages() {

    echo "설치할 패키지: $PACKAGES"

    $INSTALL_CMD $PACKAGES
}


# zsh와 oh-my-zsh 설치 함수
install_zsh_and_ohmyzsh() {
    echo "zsh 설치를 시작합니다."
    $INSTALL_CMD zsh

    if [ $? -ne 0 ]; then
        echo "zsh 설치에 실패했습니다."
        exit 1
    fi


    change_default_shell_to_zsh

    echo "oh-my-zsh 설치를 시작합니다."

    sh -c "$(wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh)"

    echo "oh-my-zsh 설치가 완료되었습니다."
}

# 기본 셸을 zsh로 변경하는 함수
change_default_shell_to_zsh() {
    echo "기본 셸을 zsh로 변경합니다."

    # 현재 사용자
    USER=$(whoami)

    # chsh 명령어를 사용하여 기본 셸을 zsh로 변경
    sudo chsh -s $(which zsh) $USER

    if [ $? -eq 0 ]; then
        echo "기본 셸이 zsh로 변경되었습니다. 변경 사항을 적용하려면 로그아웃 후 다시 로그인해주세요."
    else
        echo "기본 셸 변경에 실패했습니다."
    fi
}

detect_distro
set_package_manager
install_packages
install_zsh_and_ohmyzsh



#echo "Setting Dot Files"
#touch ~/.zshrc.local
#ln -s -f "$(pwd)/.zshrc" ~/.zshrc
#ln -s -f "$(pwd)/.vimrc" ~/.vimrc
#ln -s -f "$(pwd)/.gitconfig" ~/.gitconfig
#ln -s -f "$(pwd)/.gitignore" ~/.gitignore

source ~/.zshrc
