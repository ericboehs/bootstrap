#!/usr/bin/env bash
# This script is idempotent

# TODO: Add VERRBOSE to silence commands (default to no output)
# TODO: Add log file
# TODO: Convert >/dev/null to &>-
# TODO: Don't use cask for chrome since it screws up 1Password permission

# Before running script:
# * Create/login to the user you want to run it from
# * Export NEW_HOSTNAME if you want to change the hostname (normally set in Sharing prefPane)

# You may also want to do some stuff this script can't do:
# * Login to iCloud account (in System Preferences) (enable Find My Mac)
# * Login to MAS and install/update any MAS apps (no way to script these; well maybe AppleScript)
#   * Apps: Xcode (and command line tools), iWorks suite, Divvy
# * Remap caps lock to control on all keyboards (See http://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool for cli implementation)
# * Add the date to the clock

echo "---> Ask for the administrator password upfront"
sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "---> Generate ssh key for github (copied to clipboard)"
[ ! -f ~/.ssh/id_rsa ] && ssh-keygen -N '' -f ~/.ssh/id_rsa > /dev/null && pbcopy < ~/.ssh/id_rsa.pub && open https://github.com/settings/ssh

echo "---> Generate ssh key for heroku and setup heroku work"
if [ ! -f ~/.ssh/id_rsa_heroku_work ]; then
  heroku plugins:install git://github.com/ddollar/heroku-accounts.git > /dev/null
  echo "--->    Enter your heroku email (press enter), followed by your password."
  heroku accounts:add work > /dev/null
  ssh-keygen -N '' -f ~/.ssh/id_rsa_heroku_work > /dev/null
  heroku keys:add ~/.ssh/id_rsa_heroku_work.pub --account work > /dev/null
  cat << 'EOF' >> ~/.ssh/config
Host heroku.work
  HostName heroku.com
  IdentityFile ~/.ssh/id_rsa_heroku_work
  IdentitiesOnly yes
EOF
  git config --global heroku.account work
fi

echo "---> Create ~/Code directory"
mkdir -p ~/Code

echo "---> Setup github user"
#GITHUB_USER_SET=$(git config -f ~/.gitconfig.private github.user)
#[[ -z $GITHUB_USER_SET && -z $GITHUB_USER ]] && echo 'Please enter your github username:' && read GITHUB_USER
#[[ $GITHUB_USER_SET != $GITHUB_USER ]] && git config -f ~/.gitconfig.private github.user $GITHUB_USER > /dev/null
#[[ -z $GITHUB_USER ]] && GITHUB_USER=$GITHUB_USER_SET
#
#GIT_NAME_SET=$(git config -f ~/.gitconfig.private user.name)
#[[ -z $GIT_NAME_SET && -z $GIT_NAME ]] && echo 'Please enter your full name used for git:' && read GIT_NAME
#[[ $GIT_NAME_SET != $GIT_NAME ]] && git config -f ~/.gitconfig.private user.name $GIT_NAME > /dev/null
#
#GIT_EMAIL_SET=$(git config -f ~/.gitconfig.private user.email)
#[[ -z $GIT_EMAIL_SET && -z $GIT_EMAIL ]] && echo 'Please enter your Brightbit email used for git:' && read GIT_EMAIL
#[[ $GIT_EMAIL_SET != $GIT_EMAIL ]] && git config -f ~/.gitconfig.private user.email $GIT_EMAIL > /dev/null

if [[ -n $(/usr/bin/xcrun clang 2>&1 | grep "license") ]]; then
  echo "---> Accept xcode license"
  echo "You need to accept the Xcode license. To do this press:"
  echo "<Enter><Enter>qagree<Enter><Enter>qagree<Enter>"
  read
  xcodebuild -license
fi

echo "---> Remove about downloads LPDF"
rm -r ~/Downloads/About\ Downloads.lpdf 2>/dev/null

echo "---> Enable File Sharing, Screen Sharing and Remote Login for all users"
echo "#TODO: determine how to enable sharing on Yosemite"
#sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.AppleFileServer -dict Disabled -bool false #2>/dev/null
#sudo launchctl load /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist #2>/dev/null
#sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false #2>/dev/null
#sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist #2>/dev/null
#sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.openssh.sshd -dict Disabled -bool false #2>/dev/null
#sudo launchctl load /System/Library/LaunchDaemons/ssh.plist #2>/dev/null

#echo "---> Enable firewall"
#sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 #2>/dev/null

echo "---> Disble screen lock"
defaults -currentHost write com.apple.screensaver askForPassword -int 0

echo "---> Updating system software"
sudo softwareupdate --install --all

#if [[ -n $NEW_HOSTNAME ]]; then
#  echo "---> Set computer name (as done via System Preferences → Sharing)"
#  sudo scutil --set ComputerName "$NEW_HOSTNAME"
#  sudo scutil --set HostName "$NEW_HOSTNAME"
#  sudo scutil --set LocalHostName "$NEW_HOSTNAME"
#  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$NEW_HOSTNAME"
#else
#  echo "---> !Computer name not updated; rerun with NEW_HOSTNAME set or ignore"
#fi

echo "---> Set standby delay to 24 hours (default is 1 hour)"
sudo pmset -a standbydelay 86400

################################################################################
## Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
################################################################################

#echo "---> Trackpad: enable tap to click for this user and for the login screen"
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true #2>/dev/null
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 #2>/dev/null
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 #2>/dev/null

echo "---> Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
sudo defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 #2>/dev/null

echo "---> Set a blazingly fast keyboard repeat rate"
sudo defaults write NSGlobalDomain KeyRepeat -int 0 #2>/dev/null

echo "---> Set a blazingly fast trackpad speed"
defaults write -g com.apple.trackpad.scaling -int 5 #2>/dev/null

echo "---> Automatically illuminate built-in MacBook keyboard in low light"
defaults write com.apple.BezelServices kDim -bool true #2>/dev/null

echo "---> Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300 #2>/dev/null

echo "---> Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false #2>/dev/null

echo "---> Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false #2>/dev/null

#echo "---> Remove the auto-hiding Dock delay"
#defaults write com.apple.dock autohide-delay -float 0 #2>/dev/null

#echo "---> Automatically hide and show the Dock"
#defaults write com.apple.dock autohide -bool true #2>/dev/null

################################################################################
## Safari & WebKit                                                             #
################################################################################

#echo "---> Setup Safari"
## Set Safari’s home page to `about:blank` for faster loading
#defaults write com.apple.Safari HomePage -string "about:blank" #2>/dev/null

## Hide Safari’s bookmarks bar by default
#defaults write com.apple.Safari ShowFavoritesBar -bool false #2>/dev/null

## Disable Safari’s thumbnail cache for History and Top Sites
#defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 #2>/dev/null

## Enable Safari’s debug menu
#defaults write com.apple.Safari IncludeInternalDebugMenu -bool true #2>/dev/null

## Make Safari’s search banners default to Contains instead of Starts With
#defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false #2>/dev/null

## Remove useless icons from Safari’s bookmarks bar
#defaults write com.apple.Safari ProxiesInBookmarksBar "()" #2>/dev/null

## Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true #2>/dev/null
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true #2>/dev/null
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true #2>/dev/null

# Add a context menu item for showing the Web Inspector in web views
#defaults write NSGlobalDomain WebKitDeveloperExtras -bool true 2>/dev/null

################################################################################
## Homebrew                                                                    #
################################################################################

echo "---> Homebrew currently broken in Yosemite :("

echo "---> Installing homebrew"
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install more recent versions of some OS X tools
brew tap homebrew/dupes

echo "---> Install other useful binaries"

brew install ag                         #2>/dev/null # The Silver Searcher - faster than grep or ack
brew install bash                       #2>/dev/null # Bash 4
brew install coreutils                  #2>/dev/null # GNU core utilities (those that come with OS X are outdated)
brew install ctags                      #2>/dev/null # For indexing files (vim tab completion of methods, classes, variables)
#brew install curl-ca-bundle             #2>/dev/null # Makes ruby 2 + openssl happy (along with export SSL_CERT_FILE=/usr...)
brew install findutils                  #2>/dev/null # GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install gcal                       #2>/dev/null # GNU cal with 3-month view (gcal .)
brew install git                        #2>/dev/null # Distributed version control
brew install git-extras                 #2>/dev/null # Helpful git commands; See https://github.com/visionmedia/git-extras
brew install heroku-toolbelt            #2>/dev/null # Recommened way to install heroku command line
brew install htop-osx                   #2>/dev/null # Better top
brew install imagemagick                #2>/dev/null # Process images (used for carrierwave gem)
brew install macvim --override-system-vim --force #2>/dev/null # Newer, better, faster, stronger vim
brew install memcached                  #2>/dev/null # Good open source memory store for caching
brew install node                       #2>/dev/null # JS V8 engine
brew install phantomjs                  #2>/dev/null # Headless webkit used for testing (with capybara/poltergeist)
brew install postgresql --no-python     #2>/dev/null # Realational Database
brew install reattach-to-user-namespace #2>/dev/null # Reattaches user namespace in tmux  (for pasteboard interaction and ruby motion)
brew install redis                      #2>/dev/null # Key-value store
brew install rename                     #2>/dev/null # Like mv but better (takes regex)
brew install ruby                       #2>/dev/null # Straight up Ruby 2.0. Nothing fancy like rbenv or rvm.
brew install tmux                       #2>/dev/null # Terminal multiplexer (for saving project state and switching between projects)
brew install tree                       #2>/dev/null # ASCII view of directory/file structure
brew install watch                      #2>/dev/null # Repeateadly run a command (clearing output between runs)
brew install wget --enable-iri          #2>/dev/null # wget with IRI support
brew install zsh                        #2>/dev/null # Zsh 5

echo "---> Install native apps"
brew install caskroom/cask/brew-cask

function installcask() {
  brew cask install "${@}" #2> /dev/null
}

#installcask onepassword
installcask alfred
installcask bettertouchtool
#installcask dropbox
installcask droplr
#installcask flowdock
#installcask google-chrome
installcask harvest
#installcask iterm2
#installcask omnifocus
installcask rdio
#installcask istat-menus

open -a "Alfred 2" # Don't move to /Applications

brew cask alfred link

# Remove outdated versions from the cellar
brew cleanup

if [ ! -d /Library/Application\ Support/SIMBL/Plugins/SafariTabSwitching.bundle ]; then
  echo '---> Install Safari Tab Switching Fix'
  curl -L https://github.com/rs/SafariTabSwitching/releases/download/1.2.6/Safari.Tab.Switching-1.2.6.pkg > ~/Downloads/Safari.Tab.Switching.pkg 2>/dev/null
  open -W ~/Downloads/Safari.Tab.Switching.pkg
  rm ~/Downloads/Safari.Tab.Switching.pkg
fi

#echo "---> Set up postgres"
#initdb /usr/local/var/postgres -E utf8 >/dev/null 2>&1
#
#echo "---> Start service automatically"
#mkdir -p ~/Library/LaunchAgents
#ln -sf /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
#ln -sf /usr/local/opt/memcached/*.plist ~/Library/LaunchAgents
#ln -sf /usr/local/opt/redis/*.plist ~/Library/LaunchAgents
#
#echo "---> Make /usr/local/bin and /usr/local/opt/ruby/bin are highest in /etc/paths"
## Remove /usr/local/bin and /usr/local/opt/ruby/bin from /etc/paths
#sudo sed -ie '/\/usr\/local\/bin/d;/\/usr\/local\/opt\/ruby\/bin/d;/\/usr\/local\/share\/npm\/bin/d' /etc/paths
## Add them back at the end
#echo -e "/usr/local/bin\n/usr/local/opt/ruby/bin\n/usr/local/share/npm/bin" | sudo tee -a /etc/paths >/dev/null
## Move /usr/local/share/npm/bin to the top
#sudo sed -ie '1h;1d;$!H;$!d;G' /etc/paths
## Move /usr/local/opt/ruby/bin to the top
#sudo sed -ie '1h;1d;$!H;$!d;G' /etc/paths
## Move /usr/local/bin to the top
#sudo sed -ie '1h;1d;$!H;$!d;G' /etc/paths
#
#echo "---> Setup ruby and install gems"
##FIXME: I'm not sure if ruby is getting soruced correctly; Native gems might fail to compile in this script
#export PATH="/usr/local/bin:/usr/local/opt/ruby/bin:$PATH"
#gem update --system -f >/dev/null
#
#echo "--->      TODO Add Solarized iTerm themes"
#echo "--->      TODO Add patched powerline font"
#echo "--->      TODO Configure several GUI apps (Alfred, iTerm)"
#
## Update all core gems
#gem update -f test-unit psych rdoc rake io-console bigdecimal json minitest --no-ri --no-rdoc -f >/dev/null
#
## Install the goods
#gem install awesome_print brewdler forward ghi github-auth hub travis --no-ri --no-rdoc -f >/dev/null
#gem install pry rails -f >/dev/null
#gem install tmuxinator -v 0.6.5 --no-ri --no-rdoc -f >/dev/null # Tmux 0.6.6 has a bug which won't allow sessions to be started in cwd (.)
#gem install bundler --pre --no-ri --no-rdoc -f >/dev/null
#
#echo "---> Set shell to zsh"
#grep '/usr/local/bin/zsh' /etc/shells >/dev/null || echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells >/dev/null
#sudo chsh -s /usr/local/bin/zsh $USER 2>/dev/null
#
#echo "---> Set up pair user"
#if [[ -z $(sudo dscl . read /Users/pair 2>/dev/null) ]]; then
#  sudo dscl . create /Users/pair
#  sudo dscl . create /Users/pair RealName "Pair"
#  sudo dscl . create /Users/pair UniqueID $(($(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1) + 1))
#  sudo dscl . create /Users/pair PrimaryGroupID 20
#  sudo dscl . create /Users/pair UserShell /usr/local/bin/zsh
#  sudo dscl . create /Users/pair NFSHomeDirectory /Users/pair
#  sudo dscl . -append /Groups/staff GroupMembership pair
#fi
#[ ! -d /Users/pair ] && sudo cp -R /System/Library/User\ Template/English.lproj/ /Users/pair && sudo chown -R pair:staff /Users/pair
#
## Restrict pair user to tmux -S /tmp/tmux-pair-session
#grep 'Match User pair' /etc/sshd_config >/dev/null || echo -e "\nMatch User pair\n X11Forwarding no\n AllowTcpForwarding no\n ForceCommand /usr/local/bin/tmux -S /tmp/tmux-pair-session attach" | sudo tee -a /etc/sshd_config > /dev/null
#
#echo "---> Pull in Brightbit user keys from Github"
## Give Brightbit employees access to pair account
#[[ -n $(id -u pair 2>/dev/null) ]] &&
#  sudo su pair -c 'mkdir -p ~/.ssh;touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys' &&
#  sudo su pair -c 'gh-auth add ericboehs joshuaogle vlucas jefflowe jcamenisch >/dev/null'
#
## Give Brightbit owners access to brightbit account
#[[ -n $(id -u brightbit 2>/dev/null) ]] &&
#  sudo su brightbit -c 'mkdir -p ~/.ssh;touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys' &&
#  sudo su brightbit -c 'gh-auth add ericboehs joshuaogle vlucas >/dev/null'
#
#echo "---> Install Brightbit dotfiles"
#FRESH_LOCAL_SOURCE=brightbit/dotfiles bash -c "`curl -sL get.freshshell.com`" > /dev/null 2>&1
#vim +BundleInstall +qall
#
#echo "---> Prompt for github password to store in OS X Keychain"
#[[ -z $(grep -e '^github.com' ~/.ssh/known_hosts 2>/dev/null) ]] && ssh-keyscan github.com >> ~/.ssh/known_hosts 2> /dev/null
#git config -f ~/.gitconfig.private 'credential.https://github.com.username' $GITHUB_USER
#(cd ~/.dotfiles; git config --unset remote.origin.pushurl; git push >/dev/null 2>&1)
#
#echo "---> Configuring ghi - command line interface for github issues"
#GHI_TOKEN_SET=$(git config -f ~/.gitconfig.private ghi.token)
#[[ -z $GHI_TOKEN_SET && -z $GHI_TOKEN ]] && ghi config --auth 2>/dev/null && GHI_TOKEN=$(git config ghi.token) > /dev/null && git config -f ~/.gitconfig --unset ghi.token
#[[ $GHI_TOKEN_SET != $GHI_TOKEN ]] && git config -f ~/.gitconfig.private ghi.token $GHI_TOKEN > /dev/null

echo "---> All done!"
