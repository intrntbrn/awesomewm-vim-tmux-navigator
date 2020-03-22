AwesomeWM - Vim - Tmux Navigator
==================

This plugin lets you navigate seamlessly between system windows, vim splits and tmux panes using a consisent set of hotkeys.
Based on [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) and [fogine/vim-i3wm-tmux-navigator](https://github.com/fogine/vim-i3wm-tmux-navigator).

Installation
------------

### AwesomeWM
Clone the repo.
```
cd ~/.config/awesome
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator
```
This path is hardcoded in some configuration files.

Add your preferred navigation keybinds to `rc.lua` (e.g. <kbd>Mod4</kbd>+<kbd>arrow</kbd> or <kbd>Mod4</kbd>+<kbd>hjkl</kbd>)

```
require("awesomewm-vim-tmux-navigator"){
        up    = {"Up", "k"},
        down  = {"Down", "j"},
        left  = {"Left", "h"},
        right = {"Right", "l"},
    }
```
Remove conflicting keybinds from your `rc.lua`.

### Vim


```vim
Plug 'intrntbrn/awesomewm-vim-tmux-navigator'
```

Remove similar plugins (like `christoomey/vim-tmux-navigator`).

### Tmux
Add the following to your `tmux.conf`.
```tmux
# Set Terminal titles where possible
set-option -g set-titles on
set-option -g set-titles-string '#S: #W - TMUX'

# Smart pane switching with awareness of vim splits and system windows
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
	| grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-Left if-shell "$is_vim" "send-keys C-h" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh left'"
bind -n C-Down if-shell "$is_vim" "send-keys C-j" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh down'"
bind -n C-Up if-shell "$is_vim" "send-keys C-k" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh up'"
bind -n C-Right if-shell "$is_vim" "send-keys C-l" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh right'"
```
