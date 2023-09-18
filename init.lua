local awful = require("awful")
local glib = require("lgi").GLib
local gears = require("gears")
local unpack = unpack or table.unpack -- luacheck: globals unpack
local awesome, keygrabber, client, root = awesome, keygrabber, client, root
local module = {}

local function run_key_sequence(seq)
	keygrabber.stop()
	for _, s in ipairs(seq) do
		if s.action == "press" then
			root.fake_input("key_press", s.key)
			print("key_press: " .. s.key)
		elseif s.action == "release" then
			root.fake_input("key_release", s.key)
			print("key_release: " .. s.key)
		elseif s.action == "press_and_release" then
			root.fake_input("key_release", s.key)
			root.fake_input("key_press", s.key)
			root.fake_input("key_release", s.key)
		end
	end
end

local function run_key_sequence_xdotool(seq)
	keygrabber.stop()

	-- combine inputs to speed things up
	local queue = nil

	local combine = false -- @WIP

	print("")

	local run_fn = function(s)
		if s.action == "press" then
			if s.is_combined then
				awful.spawn("xdotool key " .. s.key)
				print("xdotool key " .. s.key)
			else
				awful.spawn("xdotool keydown " .. s.key)
				print("xdotool keydown " .. s.key)
			end
		elseif s.action == "release" then
			if s.is_combined then
			else
				awful.spawn("xdotool keyup " .. s.key)
				print("xdotool keyup " .. s.key)
			end
		elseif s.action == "press_and_release" then
			awful.spawn("xdotool key " .. s.key)
			print("key " .. s.key)
		end
	end

	for _, s in ipairs(seq) do
		if queue then
			if combine and s.action == queue.action then
				queue.key = string.format("%s+%s", queue.key, s.key)
				queue.is_combined = true
			else
				run_fn(queue)
				queue = s
			end
		else
			queue = s
		end
	end

	run_fn(queue)
end

-- get key sequence to transition from current mods to next mods
local change_mods = function(current, next)
	local sequence = {}
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
			table.insert(sequence, { action = "release", key = c })
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
			table.insert(sequence, { action = "press", key = n })
		end
	end

	return sequence
end

local function new(args)
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

	local use_xdotool = cfg.use_xdotool or true

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

	local get_key_sequence = function(current_mods, next_mods, fn, dir)
		local sequence = {}
		-- release wm mods, press vim/tmux mods
		gears.table.merge(sequence, change_mods(current_mods, next_mods))

		-- press navigation direction
		gears.table.merge(sequence, fn(dir))

		-- release vim/tmux mods, restore wm mods
		gears.table.merge(sequence, change_mods(next_mods, current_mods))

		return sequence
	end

	local navigate_tmux = function(dir)
		return {
			{ action = "release", key = tmux_keys[dir] },
			{ action = "press", key = tmux_keys[dir] },
			{ action = "release", key = tmux_keys[dir] },
		}
	end

	local navigate_vim = function(dir)
		return {
			--{ action = "release", key = vim_keys[dir] },
			{ action = "press", key = vim_keys[dir] },
			{ action = "release", key = vim_keys[dir] },
		}
	end

	local run_fn = use_xdotool and run_key_sequence_xdotool or run_key_sequence

	-- use dynamic titles to determine type of client (default)
	local navigate = function(dir)
		local c = client.focus
		local client_name = c and c.name or ""

		if string.find(client_name, "%- N?VIM$") then
			run_fn(get_key_sequence(wm_keys.mods, vim_keys.mods, navigate_vim, dir))
			return
		elseif string.find(client_name, "%- TMUX$") then
			run_fn(get_key_sequence(wm_keys.mods, tmux_keys.mods, navigate_tmux, dir))
			return
		else
			focus(dir)
			return
		end
	end

	-- use pstree to determine type of client (experimental)
	if cfg.experimental then
		navigate = function(dir)
			local c = client.focus
			local pid = c and c.pid or -1
			awful.spawn.easy_async("pstree -A -T " .. pid, function(out)
				if string.find(out, "[^.*\n]%-tmux: client") then
					run_fn(get_key_sequence(wm_keys.mods, tmux_keys.mods, navigate_tmux, dir))
					return
				elseif
					string.find(out, "[^.*\n]%-n?vim$")
					or string.find(out, "[^.*\n]%-n?vim%-")
					or string.find(out, "^gvim$")
					or string.find(out, "^gvim%-")
				then
					run_fn(get_key_sequence(wm_keys.mods, vim_keys.mods, navigate_vim, dir))
					return
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
