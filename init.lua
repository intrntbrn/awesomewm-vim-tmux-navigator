local capi = {root = root, screen = screen, client = client, keygrabber = keygrabber}
local awful = require("awful")
local glib = require("lgi").GLib
local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local module = {}

local keys = {up = {"k"}, down = {"j"}, left = {"h"}, right = {"l"}}

local function new(ks)
    keys = ks or keys
    local aw = {}

    glib.idle_add(glib.PRIORITY_DEFAULT_IDLE, function()
        for k, v in pairs(keys) do
            for _, key_name in ipairs(v) do
                aw[#aw + 1] = awful.key({"Mod4"}, key_name, function()
                    module.focus(k)
                end, {description = "focus " .. key_name .. " window", group = "client"})
            end
        end
        capi.root.keys(awful.util.table.join(capi.root.keys(), unpack(aw)))
    end)
    return module
end

function module.focus(dir)
    local c = capi.client.focus
    local client_name = c and c.name or ""
    if string.find(client_name, "- N?VIM$") then
        capi.keygrabber.stop()
        capi.root.fake_input("key_release", "Super_L")
        capi.root.fake_input("key_release", "Control_L")
        capi.root.fake_input("key_press", "Control_L")
        if dir == "left" then
            capi.root.fake_input("key_release", "h")
            capi.root.fake_input("key_press", "h")
            capi.root.fake_input("key_release", "h")
        else
            if dir == "right" then
                capi.root.fake_input("key_release", "l")
                capi.root.fake_input("key_press", "l")
                capi.root.fake_input("key_release", "l")
            else
                if dir == "up" then
                    capi.root.fake_input("key_release", "k")
                    capi.root.fake_input("key_press", "k")
                    capi.root.fake_input("key_release", "k")
                else
                    if dir == "down" then
                        capi.root.fake_input("key_release", "j")
                        capi.root.fake_input("key_press", "j")
                        capi.root.fake_input("key_release", "j")
                    end
                end
            end
        end
        capi.root.fake_input("key_release", "Control_L")
        capi.root.fake_input("key_press", "Super_L")
        return
    else
        if string.find(client_name, "- TMUX$") then
            capi.keygrabber.stop()
            capi.root.fake_input("key_release", "Super_L")
            capi.root.fake_input("key_press", "Control_L")
            if dir == "left" then
                capi.root.fake_input("key_release", "Left")
                capi.root.fake_input("key_press", "Left")
                capi.root.fake_input("key_release", "Left")
            else
                if dir == "right" then
                    capi.root.fake_input("key_release", "Right")
                    capi.root.fake_input("key_press", "Right")
                    capi.root.fake_input("key_release", "Right")
                else
                    if dir == "up" then
                        capi.root.fake_input("key_release", "Up")
                        capi.root.fake_input("key_press", "Up")
                        capi.root.fake_input("key_release", "Up")
                    else
                        if dir == "down" then
                            capi.root.fake_input("key_release", "Down")
                            capi.root.fake_input("key_press", "Down")
                            capi.root.fake_input("key_release", "Down")
                        end
                    end
                end
            end
            capi.root.fake_input("key_release", "Control_L")
            capi.root.fake_input("key_press", "Super_L")
            return
        else
            awful.client.focus.global_bydirection(dir)
        end
    end
end

return setmetatable(module, {
    __call = function(_, ...)
        return new(...)
    end
})
