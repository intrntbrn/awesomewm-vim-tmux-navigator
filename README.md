# AwesomeWM - Vim - Tmux Navigator

<p align="center">
  <img src="https://user-images.githubusercontent.com/1234183/112910543-d9c5be80-90f3-11eb-840a-8c1d549c76ff.gif">
</p>

Usually vim and tmux have their own dedicated keybinds for navigation.
Christoomey's plugin [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) allows you to the use the same keybinds for both of them.
This might be sufficient for floating wm users, but when using a tiling wm like awesomewm we can do better and add another layer.

`awesomewm-vim-tmux-navigator` lets you navigate seamlessly between system windows, (n)vim splits and tmux panes by only using your awesomewm navigation keybinds (e.g. <kbd>Mod4+hjkl</kbd>).
Every split and pane is treated like a standalone system window, allowing you to forget your vim/tmux specific navigation hotkeys.

## 💡 How does it work?

It essentially works by emulating the correct keypresses based on the context.
Therefore the plugin has to detect whether the current focused application is vim, tmux, vim inside tmux (etc.) or any other system window.

The plugin offers two methods of determining the focused application:

1. By using dynamic titles. The plugin tries to change the title of your terminal in order to differentiate between applications. However, not every shell-terminal-stack supports dynamic titles or is configured correctly out of the box.

2. By using `pstree`. This should theoretically work on every setup, but it might perform slightly slower due to having an extra process to spawn.

By default the plugin uses awesomewm's builtin implementation (`root.fake_input`) to emulate keypresses.

## 📦 Installation

The configuration of vim or tmux is optional if you only use one of them.

### awesomewm:

Clone the repo:

```
git clone https://github.com/intrntbrn/awesomewm-vim-tmux-navigator ~/.config/awesome/awesomewm-vim-tmux-navigator
```

Import and configure the module:

```
require("awesomewm-vim-tmux-navigator")({
	mod = "Mod4",
	mod_keysym = "Super_L", -- comment out to autodetect
	up = { "Up", "k" },
	down = { "Down", "j" },
	left = { "Left", "h" },
	right = { "Right", "l" },

	tmux = {
		mods = { "Control_L" },
		up = "Up",
		down = "Down",
		left = "Left",
		right = "Right",
	},

	vim = {
		mods = { "Control_L" },
		up = "k",
		down = "j",
		left = "h",
		right = "l",
	},

	-- focus = require("awful").client.focus.global_bydirection,
	-- debug = print,

	-- dont_restore_mods = true, -- prevent sticky mods (see troubleshooting)
	-- use_pstree = true, -- detect app by using pstree instead of dynamic titles
	-- use_xdotool = true, -- emulate keypresses using xdotool instead of builtin
})
```

If the awesomewm navigation keybinds are already in use, you have to **remove them manually**
in your `rc.lua`.

The corresponding keysym names can be retrieved by running the terminal command `xev -event keyboard`.
If `mod_keysym` is nil the plugin tries to detect your modifier.

### vim:

This plugin replaces `christoomey/vim-tmux-navigator`. Therefore you have to
replace it in your plugin manager with `intrntbrn/awesomewm-vim-tmux-navigator`.
However, both plugins share the same keybind commands, so it's not necessary to
adjust already configured custom keybinds.
Custom keybinds have to match your awesomewm configuration.

lazy.nvim (lua):

```lua
 {
	"intrntbrn/awesomewm-vim-tmux-navigator",
	event = "VeryLazy",
	build = "git -C ~/.config/awesome/awesomewm-vim-tmux-navigator/ pull",
	keys = {
		{ mode = { "n" }, "<C-h>", ":TmuxNavigateLeft<CR>", { noremap = true, silent = true } },
		{ mode = { "n" }, "<C-j>", ":TmuxNavigateDown<CR>", { noremap = true, silent = true } },
		{ mode = { "n" }, "<C-k>", ":TmuxNavigateUp<CR>", { noremap = true, silent = true } },
		{ mode = { "n" }, "<C-l>", ":TmuxNavigateRight<CR>", { noremap = true, silent = true } },
	},
	init = function()
		vim.g.tmux_navigator_no_mappings = 1
		-- vim.g.tmux_navigator_no_dynamic_title = 1
		-- vim.g.tmux_navigator_save_on_switch = 1
		-- vim.g.tmux_navigator_disable_when_zoomed = 1
		-- vim.g.tmux_navigator_preserve_zoom = 1
	end,
}
```

<details><summary>vim-plug (VimL):</summary>

```viml
let g:tmux_navigator_no_mappings = 1
noremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
noremap <silent> <c-j> :<C-U>TmuxNavigateDown<cr>
noremap <silent> <c-k> :<C-U>TmuxNavigateUp<cr>
noremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>
" let g:tmux_navigator_no_dynamic_title = 1
" let g:tmux_navigator_save_on_switch = 1
" let g:tmux_navigator_disable_when_zoomed = 1
" let g:tmux_navigator_preserve_zoom = 1

Plug 'intrntbrn/awesomewm-vim-tmux-navigator', { do = 'git -C ~/.config/awesome/awesomewm-vim-tmux-navigator/ pull' }
```

</details>

### tmux:

Add the following to your `tmux.conf`:

```tmux
# smart pane switching with awareness of vim splits and awesomewm windows
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-Left' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"left\")" ' } { select-pane -L } }
bind-key -n 'C-Right' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"right\")" ' } { select-pane -R } }
bind-key -n 'C-Up' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"up\")" ' } { select-pane -U } }
bind-key -n 'C-Down' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"down\")" ' } { select-pane -D } }
bind-key -T copy-mode-vi 'C-Left' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"left\")" ' } { select-pane -L } }
bind-key -T copy-mode-vi 'C-Right' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"right\")" ' } { select-pane -R } }
bind-key -T copy-mode-vi 'C-Up' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"up\")" ' } { select-pane -U } }
bind-key -T copy-mode-vi 'C-Down' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}'   {run-shell 'awesome-client "awesome.emit_signal(\"navigator::focus\", \"down\")" ' } { select-pane -D } }

# set title suffix to "- TMUX" (optional when using pstree method)
set-option -g set-titles on
set-option -g set-titles-string '#S: #W - TMUX'
```

Custom keybinds have to match your awesomewm configuration.

## ❓ Troubleshooting

### Setup:

1. Enable debug mode:

```lua
debug = function(msg) require("naughty").notify({ text = msg }) end
```

2. Make sure there are no conflicting keybinds.
   You can bypass conflicts in awesomewm by invoking the plugin from the terminal for verification:

```bash
echo "select a window" && sleep 2 && awesome-client 'awesome.emit_signal("navigator::navigate", "up")'
```

3. Verify if dynamic titles are working. The title of (n)vim and tmux
   applications should end with "- (N)VIM" or "- TMUX" respectively.
   If you don't have a titlebar, you can use the terminal command `xprop | grep WM_NAME`.
   If dynamic titles are not working, set `use_pstree` to true or configure
   your shell-terminal-stack correctly. Minimal configurations are provided for `zsh` and `bash`:

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.zsh" >> ~/.zshrc
```

```
echo "source ~/.config/awesome/awesomewm-vim-tmux-navigator/dynamictitles.bash" >> ~/.bashrc
```

4. Check https://github.com/christoomey/vim-tmux-navigator#troubleshooting.

5. Create an issue.

### Sticky Mods:

In order to emulate keypresses in vim/tmux, the plugin needs to release your wm
modifier (e.g. <kbd>mod4</kbd>) temporarily and restore it afterwards.
There is a race condition if the user was fast enough to release the modifier
during this operation resulting in _sticky_ mods. This issue is very unlikely to be ever solved.

Restoring mods can be disabled by setting the `dont_restore_mods` option.
Please note that it's not possible to hold down the modifier for consecutive
actions using this option.
However, this side effect can be circumvented by assigning combo-keybinds using custom
keyboards (qmk or similar software/firmware).

## 📡 API

- **navigate**: directional vim/tmux aware navigation
- **focus**: regular directional system window navigation

awesomewm:

```lua
awesome.emit_signal("navigator::navigate", "left")
awesome.emit_signal("navigator::focus", "right")
```

shell:

```bash
awesome-client 'awesome.emit_signal("navigator::navigate", "up")'
awesome-client 'awesome.emit_signal("navigator::focus", "down")'
```
