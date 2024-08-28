#!/bin/sh -e

DWMDIR="$HOME/dot-jeeva"

gitclone() {
  echo "Cloning dot files into $DWMDIR"
  if [ -d "$DWMDIR" ]; then
    read -p "Found existing $DWMDIR, Remove $DWMDIR [Y/N] [DEFAULT Y]: " confirm
    confirm=${confirm:-Y}
    if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
      echo "Removing $DWMDIR"
      rm -rf "$DWMDIR"
    else
      exit 1
    fi
  else
    mkdir -p "$DWMDIR"
  fi
  git clone https://github.com/jeevithakannan2/my-dwm.git --depth 1 "$DWMDIR/my-dwm"
  git clone https://github.com/yshui/picom.git --depth 1 "$DWMDIR/picom"
}

copy_configs() {
  # Ensure the target directory exists
  mkdir -p ~/.config

  # Iterate over all directories in config/*
  for dir in "$DWMDIR/configs"/*/; do
    # Extract the directory name
    dir_name=$(basename "$dir")

    # Clone the directory to ~/.config/
    if [ -d "$dir" ]; then
      cp -r "$dir" ~/.config/
      echo "Cloned $dir_name to ~/.config/"
    else
      echo "Directory $dir_name does not exist, skipping"
    fi
  done
}

install_dep() {
  sudo pacman -Sy base-devel xorg-server libxinerama libxft imlib2 \
    cmake libev xcb-util-image libconfig uthash xorg-xinit meson \
    xcb-util-renderutil --needed
}

xinitrc() {
  if [ -f "$HOME/.xinitrc" ]; then
    mv "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
  fi

  cat <<EOF >"$HOME/.xinitrc"
export XDG_SESSION_TYPE=x11

exec dwm
EOF
}

install() {
  cd "$DWMDIR/my-dwm" || exit
  sudo make clean install

  cd "$DWMDIR/my-dwm/slstatus" || exit
  sudo make clean install

  cd "$DWMDIR/picom" || exit
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

    echo "Installing dependencies for dwm and slstatus"
    install_dep

    echo "Setting up .xinitrc"
    xinitrc

    echo "Compiling and installing dwm and slstatus"
    install

    echo "Copying configs"
    copy_configs

  else
    echo "Arch system not found"
    exit 1
  fi
}

main
