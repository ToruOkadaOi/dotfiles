# Shared dotfiles

One Git repository for macOS and Linux. Configuration files are symlinked into
the home directory, so edits take effect without copying files. Starship detects
the hostname and OS and shows the date/time, Git state, environments and failures.

## Setup

Requires Git and curl. On macOS, install Homebrew first. On Ubuntu/Debian, the
installer can extract distro Zsh and fzf packages into `~/.local` without sudo;
the distro's runtime libraries must already be installed. Other Linux distros
should install Zsh and Starship through their own package manager first.

```sh
git clone https://github.com/ToruOkadaOi/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash setup.sh --install
```

This installs Starship, fzf, Oh My Zsh and the autosuggestion/highlighting plugins
where missing, then links the shared configurations. On macOS, `/bin/zsh` is
already available. The Brewfile is the Mac's broader software inventory; it is
not installed automatically on the server.

For a Bash account such as `rvp`, use:

```sh
bash setup.sh --install --ssh-zsh
```

This adds a guarded launch of Zsh to `.bashrc` for interactive Bash sessions.
The account's login shell stays Bash, and non-interactive SSH commands and scp
continue working. Reconnect to activate it, or run `exec zsh` now. Remove the
marked `# dotfiles: interactive Zsh` block from `.bashrc` to undo that launch.

Existing files are moved into a dated directory under
`~/.local/state/dotfiles/backups/` before replacement. Existing correct links are
left alone. Existing `.gitconfig` settings remain in place and take precedence
over the shared `~/.config/git/config`. GUI applications are not installed on
the VPS; their linked settings are simply available if needed.

## Sync changes

On the machine where you edit settings:

```sh
cd ~/dotfiles # On the Mac: ~/Documents/dotfiles
git add zshrc zshenv starship.toml # Select the files you changed
git commit -m "Update shared shell settings"
git push
```

On the other machine:

```sh
cd ~/dotfiles # On the Mac: ~/Documents/dotfiles
git pull --ff-only
bash setup.sh
exec zsh
```

Pulls are explicit. Local edits must be committed or resolved before pulling.
Re-running setup creates links for newly added settings without reinstalling
dependencies. Starship reads its config on each prompt; shell settings require
a new shell or `source ~/.zshrc`.

## Machine-specific settings

Put local paths and aliases in `~/.zshrc.local`, which is ignored by Git and
loaded after shared settings. Keep credentials, SSH keys, server addresses and
machine-specific service configuration outside this public repository.

Optional tools are loaded only when installed. The shared shell works without
fzf or thefuck; older distro fzf versions use their packaged Zsh bindings. For
tmux themes, install TPM and its plugins separately; missing plugins do not
prevent tmux from starting. Lazygit uses delta as its configured pager, so install
delta if you use lazygit. Nano settings target recent GNU nano, not macOS's old
system nano.
