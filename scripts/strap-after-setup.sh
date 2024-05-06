#!/usr/bin/env bash
### ----------------- Bootstrap post-installation scripts ----------------- ###
# Run by run_dotfile_scripts in bootstrap.sh
# Scripts must be executable (chmod +x)
echo "-> Running strap-after-setup. Some steps may require password entry."

echo "--> copying HOME/bin files"
if [ ! -d $HOME/bin ]; then
    mkdir -v $HOME/bin
fi
# TODO(make these symlinks?)
cp -v ~/.dotfiles/bin/* ~/bin/


### Configure macOS
if [ "${MACOS:-0}" -gt 0 ] || [ "$(uname)" = "Darwin" ]; then
  "$HOME"/.dotfiles/scripts/macos.sh
  # Configure 1Password SSH agent path for consistency with Linux
  # https://developer.1password.com/docs/ssh/get-started
  mkdir -p ~/.1password && ln -s \
    ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock \
    ~/.1password/agent.sock

  # https://gist.github.com/sbailliez/2305d831ebcf56094fd432a8717bed93
  # vmware 13 install steps
  #
  # vagrant plugin install vagrant-vmware-desktop

else
  echo "Not macOS. Skipping macos.sh."
fi

### Install Hatch
# if command -v pipx &>/dev/null && ! command -v hatch &>/dev/null; then
#   echo "Installing Hatch with pipx."
#   pipx install "hatch>=1,<2"
# else
#   echo "Skipping Hatch install."
# fi

# ### Install VSCode extensions
# for i in {code,code-exploration,code-insiders,code-server,codium}; do
#   "$HOME"/.dotfiles/scripts/vscode-extensions.sh "$i"
# done

# works with:
# ( cd ~/src/dev.heptapod.net/mercurial/hg-git/hggit ; hg sum )
# parent: 2075:162f2ee771d9 tip
# branching: merge branch 1.0.x into default

### Set shell
if ! [[ $SHELL =~ "bash" ]] && command -v bash &>/dev/null; then
  echo "--> Changing shell to bash. Password entry required."
  [ "${LINUX:-0}" -gt 0 ] || [ "$(uname)" = "Linux" ] &&
    command -v bash | sudo tee -a /etc/shells
  sudo chsh -s "$(command -v bash)" "$USER"
else
  echo "Shell is already set to Bash."
fi

### Find a working hg
if [[ -f $(echo ${HOME}/Library/Python/*/bin/hg) ]]; then
  HG_BIN=$(echo ${HOME}/Library/Python/*/bin/hg | sort -n | head -1)
  ${HG_BIN} version && echo "Found working mercurial binary at $HG_BIN"
elif [[ $(type -a hg) ]]; then
  echo type -a hg output: $(type -a hg)
  hg --version
  HG_BIN=hg
else
  echo "!!!> unable to find working hg"
  exit 1
fi

### Set doom
if ! [[ -d $HOME/.config/emacs ]]; then
  echo "--> Checking out DOOM emacs source."
  (
    cd $HOME/.config
    ${HG_BIN} clone git+https://github.com/doomemacs/doomemacs ~/.config/emacs
  )
fi
# path goes in bash_profile:
# PATH=$HOME/.config/emacs/bin:$PATH

echo "--> Don't forget to run 'doom sync'"
