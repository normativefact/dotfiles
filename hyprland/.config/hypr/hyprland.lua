require("monitors")
require("looknfeel")
require("permissions")
require("rules")
require("binds")

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("swaybg -i /home/normativefact/Downloads/wallpapers/mountain-dark.jpg")
end)
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
end)



-- Scratchpad Area Win + S
hl.on("hyprland.start", function()
    hl.exec_cmd("kitty --class scratchpad -e nvim /home/normativefact/notes/ .", {workspace = "special:scratchpad"})
end)


-- Zen Browser

hl.on("hyprland.start", function()
    hl.exec_cmd("zen-beta", {workspace = 2})
end)

-- Zathura

hl.on("hyprland.start", function()
    hl.exec_cmd("zathura", {workspace = 1})
end)

-- Obsidian nvim

hl.on("hyprland.start", function()
    hl.exec_cmd("kitty --class scratchpad -e nvim /home/normativefact/notes/ .", {workspace = 1})
end)


-- Clipboard hist trim every 30m
hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/cliphis-trim.sh")
end)

-- Clipboard Watch 
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store &")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,     -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true,  -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 1,

        repeat_rate  = 35,
        repeat_delay = 200,

        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})
