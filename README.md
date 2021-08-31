# Bootstrap

A script to bootstrap a freshly formatted Monterey Mac to almost-fully configured.

## Installation

After going through the macOS setup assistant (creating a local user account and logging into iCloud), download a zip of this repo and run:

``` sh
./bootstrap
```

## What it does

A lot. It's best just to read through the [bootstrap script](./bootstrap).

## What it doesn't do

If something is difficult to script, I'll skip it and do it by hand. Some examples:

- Enabling Develop menu and status bar in Safari.
- Setting up keybindings in Karabiner Elements (e.g. Caps lock as ctrl/esc via [Change caps_lock key (rev 5)](https://ke-complex-modifications.pqrs.org/?q=change%20caps_lock%20key)).
- Turning on iCloud Messages in Messages.app.
- Moving icons to the Control Center in macOS' Menu Bar (Siri, Spotlight, Wifi, Battery).
- Signing into various accounts (1Password, Mail/Calendar, Slack, etc).


## Post Installation

- After installation, I'll configure my non-GUI environment by installing [my dotfiles](https://github.com/ericboehs/dotfiles).
- I'll also copy over configurations and keys from my Carbon Copy Cloner backup (e.g. .ssh/id_rsa, .zsh_history, .zshrc.local).
- To install apps and tools, I continue to update this script and re-run `./bootstrap` to make sure I have non-user specific config in version control.
