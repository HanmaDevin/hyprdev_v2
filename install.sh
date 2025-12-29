#!/usr/bin/env bash
#     ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

REPO="$HOME/hyprdev_v2"
CFG_PATH="$REPO/.config"

installPackages() {
  sudo pacman -Syu

  local packages=("gum" "network-manager-applet" "ttf-ubuntu-nerd" "ttf-firacode-nerd" "ttf-fira-sans" "swayosd" "networkmanager-openvpn" "zip" "unzip" "gunzip" "man" "libreoffice" "sddm" "mpv-mpris" "fastfetch" "hyprland" "glow" "swww" "grub" "os-prober" "hyprlock" "kitty" "hyprpicker" "ntfs-3g" "tree" "lazygit" "ufw" "zsh" "unzip" "wget" "polkit-gnome" "neovim" "eza" "btop" "gamemode" "steam" "zoxide" "fzf" "bat" "jdk21-openjdk" "docker" "ripgrep" "fd" "starship" "okular" "cliphist" "hypridle" "rustup" "rust-analyzer" "bluez" "bluez-utils" "networkmanager" "brightnessctl" "wine" "bluez-obex" "python-pip" "python-requests" "python-pipx" "kvantum" "kvantum-qt5" "papirus-folders" "papirus-icon-theme" "matugen" "openssh" "pam-u2f" "pipewire" "mako" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pamixer" "ttf-font-awesome" "ttf-nerd-fonts-symbols" "ttf-jetbrains-mono-nerd" "noto-fonts-emoji" "wireplumber" "libfido2" "qt5-wayland" "qt6-wayland" "calc" "gnome-keyring" "piper" "xdg-desktop-portal-gtk" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-wlr" "gdb" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects" "wiremix" "pacman-contrib" "rofi" "libimobiledevice" "usbmuxd" "gvfs-gphoto2" "ifuse" "python-dotenv" "openvpn" "ncdu" "texlive" "grim" "slurp" "satty" "inetutils" "net-tools" "wl-clipboard" "jq" "nodejs" "npm" "nm-connection-editor" "hyprsunset" "github-cli" "waybar" "proton-vpn-gtk-app" "systemd-resolved" "wireguard-tools" "linux-headers" "ffmpeg4.4")

  for pkg in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$pkg"
  done

  sudo pacman -S --noconfirm gnome
  sudo pacman -Rns --noconfirm gnome
  sudo pacman -S --noconfirm nautilus

  rustup default stable

}

installAurPackages() {
  local packages=("google-chrome" "vesktop" "xpadneo-dkms" "nwg-look" "openvpn3" "xwayland-satellite" "wlogout" "localsend-bin" "qimgv" "openvpn-update-systemd-resolved" "gpu-screen-recorder" "lazydocker" "ufw-docker" "qt-heif-image-plugin" "tte" "luajit-tiktoken-bin" "ani-cli" "bluetui")
  for pkg in "${packages[@]}"; do
    yay -S --noconfirm "$pkg"
  done
}

installYay() {
  if ! command -v yay >/dev/null 2>&1; then
    cwd=$(pwd)
    echo ">>> Installing yay..."
    git clone https://aur.archlinux.org/yay.git "$HOME/yay"
    cd "$HOME/yay"
    makepkg -si
    cd "$cwd"
  fi
}

installDeepCoolDriver() {
  local deepcool
  echo ">>> Do you want to install DeepCool CPU-Fan driver?"
  deepcool=$(gum choose "Yes" "No")
  if [[ "$deepcool" == "Yes" ]]; then
    sudo cp "$REPO/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$REPO/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
    sudo systemctl enable deepcool-digital
  fi
}

configure_git() {
  local answer name email ssh
  echo ">>> Want to configure git?"
  answer=$(gum choose "Yes" "No")
  if [[ "$answer" == "Yes" ]]; then
    name=$(gum input --prompt ">>> What is your user name? ")
    git config --global user.name "$name"
    email=$(gum input --prompt ">>> What is your email? ")
    git config --global user.email "$email"
    git config --global pull.rebase true
  fi

  echo ">>> Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$email"
  fi
}

detect_nvidia() {
  local gpu
  gpu=$(lspci | grep -i '.* vga .* nvidia .*')

  shopt -s nocasematch

  if [[ $gpu == *' nvidia '* ]]; then
    echo ">>> Nvidia GPU is present"
    gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
    sudo pacman -S --noconfirm nvidia-lts nvidia-utils nvidia-settings
  else
    echo ">>> It seems you are not using a Nvidia GPU"
    echo ">>> If you have a Nvidia GPU then download the drivers yourself please :)"
  fi
}

get_wallpaper() {
  local ans
  echo ">>> Do you want to download cool wallpaper?"
  ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    if [ ! -d "$HOME/Pictures/Wallpaper/" ]; then
      mkdir -p "$HOME/Pictures/Wallpaper/"
    fi
    git clone "https://github.com/HanmaDevin/Wallpapes.git" "$HOME/Wallpapes"
    cp ~/Wallpapes/* "$HOME/Pictures/Wallpaper/"
    rm -rf "$HOME/Wallpapes/"
    rm -rf "$HOME/Pictures/Wallpaper/.git"
  else
    if [ ! -d "$HOME/Pictures/Wallpaper/" ]; then
      mkdir -p "$HOME/Pictures/Wallpaper/"
      cp "$REPO/default_wall/default.jpg" "$HOME/Pictures/Wallpaper/"
    fi
  fi
}

copy_config() {
  local ans
  echo ">>> Do you want to create backups before applying changes?"
  ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    mv "$HOME/.config" "$HOME/.config.bak"
  fi

  gum spin --spinner dot --title "Creating Home..." -- sleep 2
  mkdir -p "$HOME/Documents/"
  mkdir -p "$HOME/Music/"
  mkdir -p "$HOME/Desktop/"
  mkdir -p "$HOME/Downloads/"
  mkdir -p "$HOME/Pictures/"
  mkdir -p "$HOME/Videos/"
  mkdir -p "$HOME/Templates/"
  mkdir -p "$HOME/Public/"

  if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots/"
  fi

  cp "$REPO/.zshrc" "$HOME/"
  cp -r "$CFG_PATH" "$HOME/"
  cp -r "$REPO/.local" "$HOME/"
  cp -r "$REPO/.themes" "$HOME/"
  get_wallpaper

  sudo cp -r "$REPO/fonts/" "/usr/share"
  sudo cp "$REPO/etc/pacman.conf" "/etc/pacman.conf"
  sudo cp -r "$REPO/bin" /usr/
  sudo cp -r "$REPO/icons/" "/usr/share/"
  sudo cp -r "$REPO/sddm/catppuccin-mocha" "/usr/share/sddm/themes/"
  sudo cp -r "$REPO/sddm/sddm.conf" "/etc/"

  touch ~/.first_run

  echo ">>> Trying to change the shell..."
  chsh -s "/bin/zsh"
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "HanmaDevin HyprLand Setup"
echo -e "${NONE}"
while true; do
  read -r -p ">>> Do you want to start the installation now? (y/n): " yn
  case $yn in
  [Yy]*)
    echo ">>> Installation started."
    echo
    break
    ;;
  [Nn]*)
    echo ">>> Installation canceled"
    exit
    ;;
  *)
    echo ">>> Please answer yes or no."
    ;;
  esac
done

echo ">>> Installing required packages..."
installPackages
installYay
installAurPackages
copy_config
detect_nvidia
installDeepCoolDriver
configure_git

sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable swayosd-libinput-backend

echo -e "${MAGENTA}"
cat <<"EOF"
    ____       __                __  _
   / __ \___  / /_  ____  ____  / /_(_)___  ____ _   ____  ____ _      __
  / /_/ / _ \/ __ \/ __ \/ __ \/ __/ / __ \/ __ `/  / __ \/ __ \ | /| / /
 / _, _/  __/ /_/ / /_/ / /_/ / /_/ / / / / /_/ /  / / / / /_/ / |/ |/ /
/_/ |_|\___/_.___/\____/\____/\__/_/_/ /_/\__, /  /_/ /_/\____/|__/|__/
                                         /____/
EOF
echo "and thank you for choosing my config :)"
echo -e "${NONE}"

sleep 2
sudo systemctl reboot
