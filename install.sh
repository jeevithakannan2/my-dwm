#!/bin/sh -e

DOT_LOCATION="$HOME/dot-jeeva"

gitclone() {
  echo "Cloning dot files into $DOT_LOCATION"
  if [ -d "$DOT_LOCATION" ]; then
    read -n 1 -p "Remove all contents in $DOT_LOCATION [Y/N] [DEFAULT Y]: " confirm
    echo
    confirm=${confirm:-Y}
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
      echo "Cleaning $DOT_LOCATION"
      cd "$DOT_LOCATION"
      rm -rf *
    else
      exit 1
    fi
  else
    mkdir -p "$DOT_LOCATION"
  fi
  git clone https://github.com/jeevithakannan2/my-dwm.git --depth 1 "$DOT_LOCATION/my-dwm"
  git clone https://github.com/yshui/picom.git --depth 1 "$DOT_LOCATION/picom"
}

install_dep() {
  sudo pacman -Sy xorg-server libxinerama libxft imlib2 --needed
}

xinitrc() {
  if [ -f "$HOME/.xinitrc" ]; then
    mv "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
  fi

  cat <<EOF > "$HOME/.xinitrc"
export XDG_SESSION_TYPE=x11

exec dwm
EOF
}

install() {
  cd "$DOT_LOCATION/my-dwm"
  sudo make clean install

  cd "$DOT_LOCATION/my-dwm/slstatus"
  sudo make clean install

  cd "$DOT_LOCATION/picom"
  meson setup --buildtype=release build
  ninja -C build
  sudo ninja -C build install

}

main() {
  if command -v pacman &>/dev/null; then
    echo "Arch System detected"
    if command -v git &>/dev/null; then
      echo "Git found in system"
      gitclone
    else
      echo "Git not found in system, installing git"
      sudo pacman -Syu git
      gitclone
    fi

    if [ $? -ne 0 ]; then
      echo "Cloning failed!!"
      exit 1
    fi

    echo "Installing dependencies for dwm and slstatus"
    install_dep

    echo "Setting up .xinitrc"
    xinitrc

    echo "Compiling and installing dwm and slstatus"
    install
  else
    echo "Arch system not found"
    exit 1
  fi
}

main

