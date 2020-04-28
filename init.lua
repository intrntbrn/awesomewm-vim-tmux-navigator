local capi = {
	root = root,
	screen = screen,
	client = client,
	keygrabber = keygrabber
}

local awful = require("awful")
local glib = require("lgi").GLib
local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local module = {}

local keys = {
	up = { "k" },
	down = { "j" },
	left = { "h" },
	right = { "l" }
}

local function new(ks)
	keys = ks or keys
	local aw = {}

	glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
		for k, v in pairs(keys) do
			for _, key_name in ipairs(v) do
				aw[#aw + 1] = awful.key(
					{ "Mod4" },
					key_name,
					function()
						module.focus(k)
					end,
					{
						description = "Change focus to the " .. key_name .. " window",
						group = "Navigator"
					}
				)
			end
		end
		capi.root.keys(awful.util.table.join(capi.root.keys(), unpack(aw)))
	end)
	return module
end

function module.focus(dir)
	local c = client.focus

	local client_name = c and c.name or ""

	if string.find(client_name, "- N?VIM$") then
		keygrabber.stop()
		root.fake_input("key_release", "Super_L")
		root.fake_input("key_release", "Control_L")
		root.fake_input("key_press", "Control_L")

		if dir == "left" then
			root.fake_input("key_release", "h")
			root.fake_input("key_press", "h")
			root.fake_input("key_release", "h")
		else
			if dir == "right" then
				root.fake_input("key_release", "l")
				root.fake_input("key_press", "l")
				root.fake_input("key_release", "l")
			else
				if dir == "up" then
					root.fake_input("key_release", "k")
					root.fake_input("key_press", "k")
					root.fake_input("key_release", "k")
				else
					if dir == "down" then
						root.fake_input("key_release", "j")
						root.fake_input("key_press", "j")
						root.fake_input("key_release", "j")
					end
				end
			end
		end
		root.fake_input("key_release", "Control_L")
		root.fake_input("key_press", "Super_L")
		return
	else
		if string.find(client_name, "- TMUX$") then
			keygrabber.stop()
			root.fake_input("key_release", "Super_L")
			root.fake_input("key_press", "Control_L")

			if dir == "left" then
				root.fake_input("key_release", "Left")
				root.fake_input("key_press", "Left")
				root.fake_input("key_release", "Left")
			else
				if dir == "right" then
					root.fake_input("key_release", "Right")
					root.fake_input("key_press", "Right")
					root.fake_input("key_release", "Right")
				else
					if dir == "up" then
						root.fake_input("key_release", "Up")
						root.fake_input("key_press", "Up")
						root.fake_input("key_release", "Up")
					else
						if dir == "down" then
							root.fake_input("key_release", "Down")
							root.fake_input("key_press", "Down")
							root.fake_input("key_release", "Down")
						end
					end
				end
			end
			root.fake_input("key_release", "Control_L")
			root.fake_input("key_press", "Super_L")
			return
		else
			awful.client.focus.global_bydirection(dir)
		end
	end
end

return setmetatable(module, { __call = function(_, ...)
	return new(...)
end })
