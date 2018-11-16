#!/usr/bin/env bash

COLOR_WHITE=$(tput setaf 7);
COLOR_MAGENTA=$(tput setaf 5);
FONT_BOLD=$(tput bold);
FONT_NORMAL=$(tput sgr0);

prompt_install () {
  while true; do
  	echo
    read -p "Proceed with $1 (Y/N)? > " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Try again. Please answer yes or no.";;
    esac
  done
}

echo
echo -e "$COLOR_WHITE $FONT_BOLD Substrate Dependencies Setup...$FONT_NORMAL";
echo
echo -e "  Installing Rust with WASM...";
echo
curl https://sh.rustup.rs -sSf | sh;
rustup update nightly;
rustup target add wasm32-unknown-unknown --toolchain nightly;
rustup update stable;
echo
echo -e "  Switching to Rust Stable...";
rustup default stable;
cargo install --git https://github.com/alexcrichton/wasm-gc --force;
cargo install --git https://github.com/pepyakin/wasm-export-table.git --force;

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo
  echo -e "  Mac OS Detected...";

  APP="Homebrew"
  echo
  echo -e "$COLOR_MAGENTA $FONT_BOLD Searching for $APP...$COLOR_WHITE $FONT_NORMAL";
  if brew 2>&1 | grep Example; then
    echo -e "  Skipping, $APP already installed";
  else
    if prompt_install $APP; then
      echo -e "  Installing $APP...";
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
      export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"
      brew doctor
      brew update
    fi
  fi

  APP="Git"
  echo
  echo -e "$COLOR_MAGENTA $FONT_BOLD Searching for $APP...$COLOR_WHITE $FONT_NORMAL";
  if git 2>&1 | grep usage; then
    echo -e "  Skipping, $APP already installed";
  else
    if prompt_install $APP; then
      echo -e "  Installing $APP latest version...";
      brew install git; brew upgrade git;
      git config --global color.ui auto;
      echo -e "  Please enter your username for $APP Config:";
      read -p "    Username > " uservar
      echo -e "  Please enter your email for $APP Config:";
      read -p "    Email >" emailvar
      git config --global user.name "$uservar";
      git config --global user.email "$emailvar";
      echo
      echo -e "  $APP Config updated with your credentials";
    fi
  fi

  echo
  echo -e "  Installing CMake, pkg-config, OpenSSL, and Git for Mac OS...";
  brew install openssl; brew upgrade openssl;
  brew install cmake; brew upgrade cmake;
  brew install pkg-config; brew upgrade pkg-config;
else
  prompt_install "Linux OS dependencies installation"
  echo -e "  Installing CMake, pkg-config, Libssl, and Git for Linux OS...";
  sudo apt install -y cmake pkg-config libssl-dev git
fi