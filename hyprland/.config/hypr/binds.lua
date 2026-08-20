---------------------
---- KEYBINDINGS ----
---------------------
local terminal    = "kitty"
local fileManager = "yazi"
local menu        = "rofi -show drun"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal),{submap_universal = true})
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close(), {submap_universal = true})
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("kitty --class scratchpad -e nvim /home/normativefact/notes/scratchpad.md .", {workspace = "special:scratchpad"}))


	-- hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit"))    -- dwindle only
	hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | satty -f - --copy-command wl-copy -o "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png"'))

	hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" -l 3 -t png - | wl-copy'))

	hl.window_rule({
		name = "apply-something",
		match = {
			class = "com.gabm.satty"
		},
		float = true,
		center = true,
	})

	------------------------
	-------MOVEMENT --------
	------------------------

	-- Move focus with mainMod + arrow keys
	hl.bind(mainMod .. " + h",  hl.dsp.focus({ direction = "left" }),{submap_universal = true})
	hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }),{submap_universal = true})
	hl.bind(mainMod .. " + k",    hl.dsp.focus({ direction = "up" }),{submap_universal = true})
	hl.bind(mainMod .. " + j",  hl.dsp.focus({ direction = "down" }),{submap_universal = true})

	hl.bind(mainMod .. " + SHIFT + h",  hl.dsp.window.move({ direction = "left" }))
	hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
	hl.bind(mainMod .. " + SHIFT + k",    hl.dsp.window.move({ direction = "up" }))
	hl.bind(mainMod .. " + SHIFT + j",  hl.dsp.window.move({ direction = "down" }))


	------------------------
	-------WORKSPACE--------
	------------------------

	-- Switch workspaces with mainMod + [0-9]
	-- Move active window to a workspace with mainMod + SHIFT + [0-9]
	for i = 1, 10 do
		local key = i % 10 -- 10 maps to key 0
		hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
		hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
	end


	hl.bind(mainMod .. "+ M", hl.dsp.submap("Easy Mover"))

	-- WORKSPACE SUBMAP -- 
	-- Changes it so that using super + M will make it so that 1,2,3 map to 4,5,6,... instead.
	hl.define_submap("Easy Mover", function()
		for i = 1, 10 do
			local key = i % 10 -- 10 maps to key 0
			hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i+3}))
			hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i+3 }))
		end
		hl.bind("M", hl.dsp.submap("reset"))
	end)


	-- RESIZING SUBMAP -- 

	hl.bind(mainMod .. "+ O", hl.dsp.submap("resize"))

	-- SUBMAP DEFINITION
	hl.define_submap("resize", function()
		-- Resizing (binde repeats action while held)
		hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true}), { repeating = true })
		hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true}), { repeating = true })
		hl.bind("k", hl.dsp.window.resize({ x = 0, y = 10, relative = true}), { repeating = true })
		hl.bind("j", hl.dsp.window.resize({ x = 0, y = -10, relative = true}), { repeating = true })
		-- Exit Submap
		hl.bind("O", hl.dsp.submap("reset"))
	end)


	-- Scroll through existing workspaces with mainMod + scroll
	hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
	hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

	-- Move/resize windows with mainMod + LMB/RMB and dragging
	hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
	hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })




	-- Example special workspace (scratchpad)
	hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("scratchpad"))
	hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))


	hl.bind(mainMod .. " + Return", hl.dsp.layout("swapwithmaster"), {submap_universal = true})
	hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))




	------------------------
	-------GROUPS-----------
	------------------------

	hl.bind(mainMod .. " + D", hl.dsp.submap("group_mode"), {
		description = "Enter group management submap",
	})

	-- 2. Define Submap Keybinds
	hl.define_submap("group_mode", function()
		-- Tab Toggle (Turn window into a group / ungroup)
		hl.bind("grave", hl.dsp.group.toggle(), { description = "Toggle window group" })

		-- Tab Navigation (Next / Prev)
		hl.bind("CTRL + TAB", hl.dsp.group.next(), { description = "Next window in group" })
		hl.bind("CTRL + SHIFT + TAB", hl.dsp.group.prev(), { description = "Previous window in group" })

		-- Tab Reordering (Shift position inside the group)
		hl.bind("ALT + TAB", hl.dsp.group.move_window({ forward = true }), { description = "Move tab right" })
		hl.bind("ALT + SHIFT + TAB", hl.dsp.group.move_window({ forward = false }), { description = "Move tab left" })

		hl.bind(mainMod .. "+ SHIFT + l", hl.dsp.window.move({ into_group  ="right"}), {description = "Move window into existing group towards the right"})
		hl.bind(mainMod .. "+ SHIFT + h", hl.dsp.window.move({ into_group  ="left"}), {description = "Move window into existing group towards the left"})

		hl.bind(mainMod .. "+ SHIFT + k", hl.dsp.window.move({ into_group  ="up"}), {description = "Move window up, into existing group"})
		hl.bind(mainMod .. "+ SHIFT + j", hl.dsp.window.move({ into_group  ="down"}), {description = "Move window down, into existing group"})


		hl.bind(mainMod .. "+ SHIFT + semicolon + l", hl.dsp.window.move({ out_of_group  ="right"}), {description = "Move window out of the group towards the right"})

		hl.bind(mainMod .. "+ SHIFT + semicolon + h", hl.dsp.window.move({ out_of_group  ="left"}), {description = "Move window out of the group towards the left"})

		-- Lock Group (Prevents new windows from auto-joining this tab group)
		hl.bind("SHIFT + r", hl.dsp.group.lock_active(), { description = "Toggle group lock" })

		-- Quick Left-Hand Jump by Index (Tabs 1 to 4)
		for i = 1, 4 do
			hl.bind(tostring(i), hl.dsp.group.active({ index = i }), {
				description = "Switch to group tab " .. i,
			})
		end

		-- --- Quick Submap Exits ---
		-- Easily reachable home-row/thumb keys to drop back to normal typing:
		hl.bind("+ D + F", hl.dsp.submap("reset"), { description = "Panic exit" })
		hl.bind("escape", hl.dsp.submap("reset"), { description = "Panic exit" })
	end)










	-- Laptop multimedia keys for volume and LCD brightness
	hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
	hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
	hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
	hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
	hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
	hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

	-- Requires playerctl
	hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
	hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
	hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

