local awful = require("awful")
local glib = require("lgi").GLib
local unpack = unpack or table.unpack -- luacheck: globals unpack
local module = {}

local change_mods = function(current, next)
	local intersect = {}

	-- determine mods that needs to be released
	for _, c in ipairs(current) do
		local is_unique = true
		for _, n in ipairs(next) do
			if string.upper(c) == string.upper(n) then
				is_unique = false
				break
			end
		end
		if is_unique then
			root.fake_input("key_release", c)
		else
			intersect[#intersect + 1] = c
		end
	end

	-- determine mods that needs to be pressed
	for _, n in ipairs(next) do
		local is_unique = true
		for _, i in ipairs(intersect) do
			if string.upper(n) == string.upper(i) then
				is_unique = false
				break
			end
		end
		if is_unique then
			root.fake_input("key_press", n)
		end
	end
end

local function new(args)
	local awesome, client, root, keygrabber = awesome, client, root, keygrabber -- luacheck: awesome globals client root keygrabber
	local cfg = args
		or { up = { "k", "Up" }, down = { "j", "Down" }, left = { "h", "Left" }, right = {
			"l",
			"Right",
		} }

	local mod = cfg.mod or "Mod4"
	local mod_keysym = cfg.mod_keysym or "Super_L"
	local focus = cfg.focus or awful.client.focus.global_bydirection

	local wm_keys = {
		mods = { mod_keysym },
		up = cfg.up,
		down = cfg.down,
		left = cfg.left,
		right = cfg.right,
	}

	local tmux_keys = cfg.tmux
		or {
			mods = { "Control_L" },
			up = "Up",
			down = "Down",
			left = "Left",
			right = "Right",
		}

	local vim_keys = cfg.vim or {
		mods = { "Control_L" },
		up = "k",
		down = "j",
		left = "h",
		right = "l",
	}

	local switch_mods_fn = function(current_mods, next_mods, fn, dir)
		keygrabber.stop()
		change_mods(current_mods, next_mods)
		fn(dir)
		change_mods(next_mods, current_mods)
	end

	local tmux = {}
	tmux.left = function()
		root.fake_input("key_release", tmux_keys.left)
		root.fake_input("key_press", tmux_keys.left)
		root.fake_input("key_release", tmux_keys.left)
	end
	tmux.right = function()
		root.fake_input("key_release", tmux_keys.right)
		root.fake_input("key_press", tmux_keys.right)
		root.fake_input("key_release", tmux_keys.right)
	end
	tmux.up = function()
		root.fake_input("key_release", tmux_keys.up)
		root.fake_input("key_press", tmux_keys.up)
		root.fake_input("key_release", tmux_keys.up)
	end
	tmux.down = function()
		root.fake_input("key_release", tmux_keys.down)
		root.fake_input("key_press", tmux_keys.down)
		root.fake_input("key_release", tmux_keys.down)
	end
	local tmux_navigate = function(dir)
		tmux[dir]()
	end

	local vim = {}
	vim.left = function()
		root.fake_input("key_release", vim_keys.left)
		root.fake_input("key_press", vim_keys.left)
		root.fake_input("key_release", vim_keys.left)
	end
	vim.right = function()
		root.fake_input("key_release", vim_keys.right)
		root.fake_input("key_press", vim_keys.right)
		root.fake_input("key_release", vim_keys.right)
	end
	vim.up = function()
		root.fake_input("key_release", vim_keys.up)
		root.fake_input("key_press", vim_keys.up)
		root.fake_input("key_release", vim_keys.up)
	end
	vim.down = function()
		root.fake_input("key_release", vim_keys.down)
		root.fake_input("key_press", vim_keys.down)
		root.fake_input("key_release", vim_keys.down)
	end
	local vim_navigate = function(dir)
		vim[dir]()
	end

	-- use dynamic titles to determine type of client (default)
	local navigate = function(dir)
		local c = client.focus
		local client_name = c and c.name or ""
		if string.find(client_name, "%- N?VIM$") then
			switch_mods_fn(wm_keys.mods, vim_keys.mods, vim_navigate, dir)
			return
		elseif string.find(client_name, "%- TMUX$") then
			switch_mods_fn(wm_keys.mods, tmux_keys.mods, tmux_navigate, dir)
			return
		else
			focus(dir)
		end
	end

	-- use pstree to determine type of client (experimental)
	if cfg.experimental then
		navigate = function(dir)
			local c = client.focus
			local pid = c and c.pid or -1
			awful.spawn.easy_async("pstree -A -T " .. pid, function(out)
				if string.find(out, "[^.*\n]%-tmux: client") then
					return tmux_navigate(dir)
				elseif
					string.find(out, "[^.*\n]%-n?vim$")
					or string.find(out, "[^.*\n]%-n?vim%-")
					or string.find(out, "^gvim$")
					or string.find(out, "^gvim%-")
				then
					return vim_navigate(dir)
				else
					focus(dir)
				end
			end)
		end
	end

	-- register signals
	awesome.connect_signal("navigator::focus", focus)
	awesome.connect_signal("navigator::navigate", navigate)

	-- setup keybinds
	glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
		local aw = {}
		for k, v in pairs(cfg) do
			for _, dir in pairs({ "left", "right", "up", "down" }) do
				if k == dir then
					for _, key_name in ipairs(v) do
						aw[#aw + 1] = awful.key({ mod }, key_name, function()
							navigate(k)
						end, { description = "navigate " .. k, group = "client" })
					end
					break
				end
			end
		end
		root.keys(awful.util.table.join(root.keys(), unpack(aw)))
	end)
	return module
end

return setmetatable(module, {
	__call = function(_, ...)
		return new(...)
	end,
})
