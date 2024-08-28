DOT_LOCATION="$HOME/dot-jeeva"

gitclone() {
  echo "Clone dot files into $DOT_LOCATION"
  if [ -d "$DOT_LOCATION" ]; then
    read -n 1 -p "Remove all contents in $DOT_LOCATION [Y/N] [DEFAULT Y]: " confirm
    echo
    confirm=${confirm:-Y}
    if [[ "$confirm" =~ [yY] ]]; then
      echo "Cleaning $DOT_LOCATION"
      cd "$DOT_LOCATION"
      rm -rf *
    else
      exit 1
    fi
  else
    mkdir "$DOT_LOCATION"
  fi
  git clone https://github.com/jeevithakannan2/my-dwm.git --depth 1 "$DOT_LOCATION/my-dwm"
}

install_dep() {
  sudo pacman -Sy xorg-server libxinerama libxft imlib2 --needed
}

install() {
  cd "$DOT_LOCATION/my-dwm"
  sudo make clean install
  cd "$DOT_LOCATION/my-dwm/slstatus"
  sudo make clean install
}

if command -v pacman &>/dev/null; then
  echo "Arch System !!!"
  if command -v git &>/dev/null; then
    echo "Git found in system"
    gitclone
    if [ $? -ne 0 ]; then
      echo "Cloning failed !!"
    fi
  else
    echo "Git not found in system installing git"
    sudo pacman -Syu git
    gitclone
    if [ $? -ne 0 ]; then
      echo "Cloning failed !!"
    fi
  fi
  echo "Installing make dependencies for dwm and dwmstatus"
  install_dep
  echo "Compiling and installing dwm and dwmstatus"
  install
else
  echo "Arch system not found"
  exit 1
fi
