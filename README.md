AwesomeWM - Vim - Tmux Navigator
==================

<p align="center">
  <img src="https://user-images.githubusercontent.com/1234183/112910543-d9c5be80-90f3-11eb-840a-8c1d549c76ff.gif">
</p>

Usually vim and tmux have their own dedicated keybinds for navigation.
Christoomey's plugin [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) allows you to the use the same keybinds for vim and tmux.
This might be sufficient for floating wm users, but when using a tiling wm like awesomewm we can do better and add another layer.

`awesomewm-vim-tmux-navigator` lets you navigate seamlessly between system windows, vim splits and tmux panes by only using your awesomewm navigation keybinds (e.g. <kbd>Mod4+hjkl</kbd>).
Every vim split and tmux pane is treated like a standalone system window, allowing you to forget your vim/tmux specific navigation hotkeys.

How does it work
------------
It essentially works by sending the correct keypresses based on the context. 
Therefore the plugin has to detect whether the current focused application is vim, tmux or any other system window.

The plugin offers two methods of determining the focused application:

1. By using dynamic titles. The plugin tries to change the title (`WM_NAME`) of your terminal in order to differentitate between applications. However, not every shell-terminal-stack supports dynamic titles or is configured correctly out of the box. Minimal configurations are provided for `zsh` and `bash`.

2. By using `pstree`. This should theoretically work on every setup, but it might perform slower due to having an extra process to spawn. This method can be enabled by setting the `experimental` flag.


Installation
------------

### AwesomeWM
Clone the repo.
```
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator ~/.config/awesome/awesomewm-vim-tmux-navigator
```
It's not recommended to change the path since it's hardcoded in other configuration files.

Add your preferred navigation (focus) keybinds to `rc.lua` (e.g. <kbd>Mod4</kbd>+<kbd>arrows</kbd> or <kbd>Mod4</kbd>+<kbd>hjkl</kbd>):

```
require("awesomewm-vim-tmux-navigator") {
    up = {"Up", "k"},
    down = {"Down", "j"},
    left = {"Left", "h"},
    right = {"Right", "l"},
    mod = "Mod4",
    mod_keysym = "Super_L",
    --experimental = true
}
```

Please verify that `mod` and `mod_keysym` matches your actual awesomewm modifier key by using the terminal applications `xev` and `xmodmap`.
For instance you might press the right super key and have to specify "Super_R" as your `mod_keysym`, or "Mod1" and "Alt_L" if you prefer to use the alt key.

Don't forget to remove your previously used navigation keybinds (or other conflicting keybinds) in `rc.lua`.

If you like to use your own custom directional focus function, you can do this by defining `focus`.
Default is `awful.client.focus.global_bydirection`.

### Vim
Install using your favorite package manager, e.g. `vim-plug`: 

```vim
Plug 'intrntbrn/awesomewm-vim-tmux-navigator'
```

Remove `christoomey/vim-tmux-navigator` if you are using it.

**Options:** 

`let g:tmux_navigator_insert_mode = 1` to enable navigator keybinds in insert mode

### Tmux
Add the following to your `tmux.conf` at the very bottom.
```tmux
# Set title suffix to "- TMUX"
set-option -g set-titles on
set-option -g set-titles-string '#S: #W - TMUX'
# Smart pane switching with awareness of vim splits and system windows
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
	| grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-Left if-shell "$is_vim" "send-keys C-h" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh left'"
bind -n C-Down if-shell "$is_vim" "send-keys C-j" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh down'"
bind -n C-Up if-shell "$is_vim" "send-keys C-k" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh up'"
bind -n C-Right if-shell "$is_vim" "send-keys C-l" "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh right'"
bind-key -T copy-mode-vi 'C-Left' "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh left'"
bind-key -T copy-mode-vi 'C-Down' "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh down'"
bind-key -T copy-mode-vi 'C-Up' "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh up'"
bind-key -T copy-mode-vi 'C-Right' "run-shell 'sh ~/.config/awesome/awesomewm-vim-tmux-navigator/tmux_focus.sh right'"
```

Troubleshooting
---------------
1. Make sure there are no conflicting keybindings.

2. Check https://github.com/christoomey/vim-tmux-navigator#troubleshooting.

3. Try to enable dynamic titles in your shell. Minimal configurations are provided for `zsh` and `bash`:

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.zsh" >> ~/.zshrc
```

or

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.bash" >> ~/.bashrc
```

After a correct installation the title of a tmux session should end with "- TMUX" and "- VIM" or "- NVIM" for vim or nvim sessions respectively.
Check the title of the terminal client in your wm tasklist or by using the terminal application `xprop` (title is property `WM_NAME`).

In case your title does not change, your terminal and/or shell may not support dynamic titles. Try other.

4. Set `experimental = true`. The experimental mode does not require dynamic titles, but might be a bit slower.

Integration
---------------
This plugin can be used from everywhere and does not require any kind of import or reference.

Awesomewm: `awesome.emit_signal("navigator::navigate", "left")`

Shell: `echo 'awesome.emit_signal("navigator::navigate", "up")' | awesome-client`






