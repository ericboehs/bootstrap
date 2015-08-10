# Bootstrap

A script to bootstrap a fresh Mac to fully configured. For Yosemite and El Capitan.

## Installation
After going through the OS X setup assistant (creating an account and logging into iCloud), run:

``` sh
bash -c "$(curl -sL https://raw.github.com/ericboehs/bootstrap/master/bootstrap)"
```

After entering your password and answering a few prompts, you should have every app and setting you could ever want.

Almost...

Note: The mac store app installer waits until the application is finished installing before proceeding to the next app. The large Xcode.app isn't a great one to start with. You can watch the install progress in Launchpad.app. I'd recommend going for a walk at this point.

## Post Installation

Bootstrap aims to configure a machine fully to my liking. It's not quite there. Some things to do after bootstrapping:
- Customize menu bar and dock icons
- Turn on iCloud Photo Library via Photos
- Turn on Apple Music via iTunes
- Sign into Mailbox and Slack
- Configure Terminal with the provided [Preferences file](https://github.com/ericboehs/bootstrap/blob/master/Preferences/com.apple.Terminal.plist) (Solarized and some other tweaks)
- Configure Alfred (sync dir, power pack, 3mo clipboard, many more in sync dir)
- Configure Divvy (Add shortcut to full screen current app via Ctrl-Space, no menu icon)
- Configure 1Password (lock after 5, no menu icon)
- And several others (Postico, Xcode, CCC, Chrome, Dash, Tweetbot, League)
- Add finally I install [my dotfiles](https://github.com/ericboehs/dotfiles).

Some other notes: I use *Safari and iCloud Keychain* as my primary browser and password store. I try not to install Flash (using Chrome for when I absolutely need it). I use *Terminal* instead of iTerm as it supports everything I need (UTF8, 256 colors, etc). I also use *Alfred* as a power house app. If there's an Alfred extension, I'd rather use it than adding an application. I tried Mail.app and *Mailbox* is superior. I tried El Capitan's Notes.app and it needs customizable default fonts and markdown support before I can ditch *Ulysses*. Finally, I use 1Password for secure notes, ids, licenses and certs.

## What are the other scripts?

### bootstrap_remote
Allows bootstrapping a remote mac. It will copy the relevant scripts to the remote machine and start ./bootstrap. It expects ssh keys to copy to the remote machine to be in `.ssh`.

### install_mas_app.scpt
An Apple Script used by the script to install Mac App Store apps.

### log_in_to_icloud.scpt and log_in_to_icloud_el_cap.scpt
An Apple Script formerly used by the script to log in to iCloud via GUI. It's currently disabled as I need to add a check to see if you're already logged in.

## xcode_agree.sh
Attempts to agree to the xcode license automatically. You may have to run the xcode accept command (brew will tell you what it is) manually.
