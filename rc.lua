--[[ this is
  ___ __ _____ _  __ _ ___   ___ __    _____ ______  __ _ ___ 
 / _ | // / _ \ |/ /|/(_-<  / _ `/ |/|/ / -_|_-< _ \/  ' | -_)
/_//_|_, /\___/___/  /___/  \_,_/|__,__/\__/___|___/_/_/_|__/ 
    /___/                                                 2010 ]]

-----------------------------------------------------------------------
-- awesome configuration file, info at https://awesome.naquadah.org/ --
-----------------------------------------------------------------------

-- Add overrides to path
package.path =
	os.getenv("HOME") .. "/.config/awesome/config/?.lua;" ..
	os.getenv("HOME") .. "/.config/awesome/config/?/init.lua;" ..
	os.getenv("HOME") .. "/.config/awesome/lib/?.lua;" ..
	os.getenv("HOME") .. "/.config/awesome/lib/?/init.lua;" ..
	package.path

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- Vicious Widgets
require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.add_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes - symlink from themeswitcher
beautiful.init(awful.util.getdir("config") .. "/current_theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
-- x-terminal-emulator can't be aliased to urxvtc when using urxvtd?
-- (not used anymore for memory consumption reasons, if it fails all terms fail
--  or all terms get sluggish and fail to redraw)
--terminal = "urxvtc"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

themedir = awful.util.getdir("config") .. "/themes/"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
--	awful.layout.suit.spiral,
--	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
--	names  = { "☭", "⌥", "☕", "⌤", "☼", "⌘", "⌨", "☠", "✇" },
	names  = { "☭ sys", "⌥ net", "☕ pim", "⌤ irc", "☼ snd", "⌘ rem", "⌨ dev", "⍜ xsh", "✣ web" },
--	layout = { layouts[7], layouts[8], layouts[1], layouts[7], layouts[1], layouts[7], layouts[3], layouts[1], layouts[1] }
	-- apparently I use floats mostly anyway...
	layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Theme Switcher
themelist = {}

function theme_load(theme)
	local cfg_path = awful.util.getdir("config")

	-- Create a symlink from the given theme to ~/.config/awesome/current_theme
	-- awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
	awful.util.spawn("ln -sfn themes/" .. theme .. " " .. cfg_path .. "/current_theme")
	awesome.restart()
end

function theme_menu()
	-- List theme files and feed the menu table
	local cmd = "ls -1 " .. themedir
	local f = io.popen(cmd)

	for l in f:lines() do
		local item = { l, function () theme_load(l) end }
		table.insert(themelist, item)
	end

	f:close()
end

-- Generate table at startup or restart
theme_menu()
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
	{ "manual", terminal .. " -e man awesome" },
	{ "edit awesome config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "edit luakit  config", editor_cmd .. " " .. os.getenv("HOME") .. "/.config/luakit/rc.lua" },
	{ "themes", themelist },
	{ "restart", awesome.restart },
	{ "quit", awesome.quit }
}

myappmenu = {
	{ "luakit", "luakit", beautiful.appicon.luakit },
}

mysshmenu = {
	{ "company1",
		{
			-- obviously an example only
			-- my machine names here are usually aliases,
			-- their properties (user,port,keyring) defined in
			-- ~/.ssh/config
			-- (so I can type 'ssh some-box' in a term, even if it
			--  tunnels three other boxes to get there beforehand)
			{ "machine1", terminal .. " -e ssh machine" },
			{ "machine2", terminal .. " -e ssh -p 10000 -X user@machine" }
		},
		beautiful.awesome_icon
	}
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "debian", debian.menu.Debian_menu.Debian },
		{ "launcher", myappmenu },
		{ "ssh", mysshmenu },
		{ "filer", "thunar" },
		{ "terminal", terminal },
		{ "screen lock", function () awful.util.spawn("xscreensaver-command -lock") end }
	},
	width = 200
})

mylauncher = awful.widget.launcher({
	image = image(beautiful.awesome_icon),
	menu = mymainmenu
})
-- }}}

-- {{{ nyov's Widgets
-- Date
datewidget = widget({ type = "textbox" })
vicious.register(datewidget, vicious.widgets.date,
	'%a %d<span color="#777777">-</span>%m<span color="#777777">-</span>%y ' ..
	'<span color="#cccccc">%H</span><span color="#777777">:</span><span color="#cccccc">%M</span><span color="#777777">:</span><span color="#eeeeee">%S</span>'
)

-- Spacer
spacer = widget({ type = "textbox" })
spacer.text = " "

-- Separator
separator = widget({ type = "textbox" })
separator.text = ' <span color="#cccccc">|</span> '
-- }}}

-- {{{ Wibox
-- Create a systray
mysystray = widget({ type = "systray" })

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = {
	"us",
	"de",
	"dvorak"
}
kbdcfg.current = 1  -- "us" is default layout
kbdcfg.widget = widget({ type = "textbox", align = "right" })
kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current] .. " "
kbdcfg.switch = function ()
	kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
	local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
	kbdcfg.widget.text = t
	os.execute( kbdcfg.cmd .. t )
end
-- Mouse bindings for the widget
kbdcfg.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () kbdcfg.switch() end)
))

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({        }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({        }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({        }, 4, awful.tag.viewnext),
	awful.button({        }, 5, awful.tag.viewprev)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width = 250 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end)
)

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end))
	)
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = awful.widget.tasklist(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
	end, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s })
	-- Add widgets to the wibox - order matters
	mywibox[s].widgets = {
		{
			mylauncher,
			mytaglist[s],
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright
		},
		mylayoutbox[s],
		spacer,
		datewidget,				-- date display
		spacer,
		s == 1 and mysystray or nil,		-- systray (screen 1)
		spacer,
		s == 1 and kbdcfg.widget or nil,	-- keymap switcher (screen 1)
		spacer,
		mytasklist[s],
		layout = awful.widget.layout.horizontal.rightleft
	}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

	awful.key({ modkey,           }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end
	),
	awful.key({ modkey,           }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end
	),
	awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end
	),

	-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),

	awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
	awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
	awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
	awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
	awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
	awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
	awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

	awful.key({ modkey }, "x",
		function ()
			awful.prompt.run(
				{ prompt = "Run Lua code: " },
				mypromptbox[mouse.screen].widget,
				awful.util.eval, nil,
				awful.util.getdir("cache") .. "/history_eval"
			)
		end
	)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
	awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
	awful.key({ modkey,           }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end
	),
	awful.key({ modkey,           }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end
	)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					awful.tag.viewonly(tags[screen][i])
				end
			end
		),
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					awful.tag.viewtoggle(tags[screen][i])
				end
			end
		),
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.movetotag(tags[client.focus.screen][i])
				end
			end
		),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.toggletag(tags[client.focus.screen][i])
				end
			end
		)
	)
end

clientbuttons = awful.util.table.join(
	awful.button({        }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
	{
		-- All clients will match this rule.
		rule =       { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons,
			-- remove window to screen border gaps,
			-- but can cause uglyness
			-- (half terminal lines or whatever)
			size_hints_honor = false
		}
	},
	{
		rule =       { class = "MPlayer" },
		properties = { floating = true }
	},
	{
		rule =       { class = "pinentry" },
		properties = { floating = true }
	},
	{
		rule =       { class = "gimp" },
		properties = { floating = true }
	},
	{
		-- Set Firefox to always map on tags number 2 of screen 1.
		-- rule =       { class = "Firefox" },
		rule =       { class = "Iceweasel" },
		properties = { tag = tags[1][2] }
	},
	{
		rule =       { class = "Opera" },
		properties = { tag = tags[1][2] }
	},
	{
		rule =       { class = "Chromium" },
		properties = { tag = tags[1][2] }
	},
	{
		rule =       { class = "Pidgin" },
		properties = { floating = true, tag = tags[1][3] }
	},
	{
		rule =       { class = "Evolution" },
		properties = { floating = true, tag = tags[1][3] }
	},
	{
		rule =       { class = "Claws-mail" },
		properties = { floating = true, tag = tags[1][3] }
	},
	{
		rule =       { class = "Icedove" },
		properties = { floating = true, tag = tags[1][3] }
	},
	{
		rule =       { name = "luakit" },
		properties = { tag = tags[1][2] }
	},
	{
		rule =       { name = "calcurse" },
		properties = { tag = tags[1][3] }
	},
	{
		rule =       { name = "irssi" },
		properties = { tag = tags[1][4] }
	},
	{
		rule =       { class = "Amarok" },
		properties = { floating = true, tag = tags[1][5] }
	},
	{
		rule =       { name = "mpd" },
		properties = { floating = true, tag = tags[1][5] }
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
	-- Add a titlebar
	awful.titlebar.add(c, {
		modkey = modkey,
		fg = "#dddddd",
		bg = "#000000",
		fg_focus = "#ffffff",
		bg_focus = "#222222",
		width = 100
	})

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
			client.focus = c
	        end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{ Autostart
-- Stuff to run on awesome (re)start
-- (most of my background programs (screensaver, filemanager daemon, keyring manager, ...) run from ~/.xinitrc, though)
function autostart(prg, arg_string, parent, screen)
	-- run_once
	if not prg then
		do return nil end
	end
	if not arg_string then
		if not parent then
			awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")",screen)
		else
			awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. parent .. " " .. prg .. ")",screen)
		end
	else
		if not parent then
			awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. " " .. arg_string .. ")",screen)
		else
			awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. parent .. " " .. prg .. " " .. arg_string .. ")",screen)
		end
	end
end

-- run it
autostart("pidgin", "--force-online")
autostart("calcurse", nil, terminal .. " -title calcurse -e")
autostart("irssi", nil, terminal .." -title irssi -e")
autostart("ncmpcpp", nil, terminal .." -title mpd -e")

awful.util.spawn("gnome-volume-control-applet &")
-- }}
