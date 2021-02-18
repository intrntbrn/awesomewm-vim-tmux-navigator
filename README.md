AwesomeWM - Vim - Tmux Navigator
==================

<p align="center">
  <img src="https://s7.gifyu.com/images/magic2c10caab0952e59d4.gif">
</p>

`awesomewm-vim-tmux-navigator` lets you navigate seamlessly between system windows, vim splits and tmux panes using a consisent set of hotkeys.
Every vim split and tmux pane is treated like a standalone system window and you can forget your (n)vim/tmux specific navigation hotkeys.
It also works for complex scenarios like embedded vim splits inside tmux panes.

The plugin is based on [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) and [fogine/vim-i3wm-tmux-navigator](https://github.com/fogine/vim-i3wm-tmux-navigator).

How does it work
------------
The plugin sends the correct keypresses based on the focused appplication.
In order to differentitate between (n)vim and tmux clients, the title of your terminal is changed.
Therefore your shell/terminal stack has to support dynamic titles (see Troubleshooting section).

Installation
------------

### AwesomeWM
Clone the repo.
```
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator ~/.config/awesome/awesomewm-vim-tmux-navigator
```
It's not recommended to change the path since it's hardcoded in other configuration files.

Add your preferred navigation (focus) keybinds to `rc.lua` (e.g. <kbd>Mod4</kbd>+<kbd>arrow</kbd> or <kbd>Mod4</kbd>+<kbd>hjkl</kbd>)

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

Troubleshooting
---------------
After a correct installation the title of a tmux session should end with "- TMUX" and "- VIM" or "- NVIM" for vim or nvim sessions respectively.
You can check the title (property `WM_NAME`) by using `xprop`.

In case your title does not change, your terminal and/or shell do not support dynamic titles.

- `xterm` does not support dynamic titles. Time to move on, boomer.
- Your shell is not configured. Try the provided minimal configurations for `zsh` or `bash`: 

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.zsh" >> ~/.zshrc
```

or

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.bash" >> ~/.bashrc
```

