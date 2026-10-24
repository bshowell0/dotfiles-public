-- Minimal Hyprland Lua config.
-- Default reference: /usr/share/hypr/hyprland.lua

local terminal = "ghostty"
local menu = "hyprlauncher"
local authAgent = "/usr/lib/hyprpolkitagent/hyprpolkitagent"
local wallpaperDaemon = "hyprpaper"
local notificationDaemon = "swaync"
local notificationCenter = "swaync-client -t -sw"
local wallpaperCycleCommand = [[sh -c 'current=$(mktemp); trap "rm -f \"$current\"" EXIT; hyprctl hyprpaper listactive | sed "s/^[^:]*: //" > "$current"; wallpaper=$(find "$HOME/.local/share/wallpapers" -maxdepth 1 -type f | grep -Fvx -f "$current" | shuf -n 1); [ -n "$wallpaper" ] || exit 0; hyprctl monitors | awk "/^Monitor / {print \$2}" | while IFS= read -r monitor; do hyprctl hyprpaper wallpaper "$monitor, $wallpaper, cover"; done']]

local hyper = "CTRL + ALT + SUPER"
local layouts = { "dwindle", "scrolling", "hy3" }
local workspaceLayouts = {}

local function dispatch(command)
    return hl.dsp.exec_cmd("hyprctl --batch 'dispatch " .. command .. "'")
end

local function workspaceSelector(workspace)
    if not workspace then
        return nil
    end

    local configName = workspace.config_name

    if configName and configName ~= "" then
        if configName:match("^name:") or configName:match("^special:") or configName:match("^%-?%d+$") then
            return configName
        end

        if workspace.special then
            return "special:" .. configName
        end

        return "name:" .. configName
    end

    if workspace.special then
        return "special:" .. workspace.name
    end

    if workspace.id and workspace.id > 0 then
        return tostring(workspace.id)
    end

    if workspace.name and workspace.name ~= "" then
        return "name:" .. workspace.name
    end

    return nil
end

local function activeWorkspaceLayout()
    local workspace = hl.get_active_workspace()
    local selector = workspaceSelector(workspace)

    return selector and workspaceLayouts[selector] or workspace and workspace.tiled_layout or "dwindle"
end

local function cycleLayout(direction)
    return function()
        local workspace = hl.get_active_workspace()
        local selector = workspaceSelector(workspace)

        if not selector then
            return
        end

        local currentLayout = activeWorkspaceLayout()
        local currentIndex = 1

        for index, layout in ipairs(layouts) do
            if layout == currentLayout then
                currentIndex = index
                break
            end
        end

        local nextLayout = layouts[(currentIndex - 1 + direction) % #layouts + 1]

        workspaceLayouts[selector] = nextLayout
        hl.workspace_rule({
            workspace = selector,
            layout = nextLayout,
        })
    end
end

local function layoutAction(actions)
    return function()
        local action = actions[activeWorkspaceLayout()]

        if action then
            if type(action) == "function" then
                action()
            else
                hl.dispatch(hl.dsp.layout(action))
            end
        end
    end
end

local function hy3Action(factory)
    return function()
        local hy3 = hl.plugin.hy3

        if hy3 then
            hl.dispatch(factory(hy3))
        end
    end
end

local function focusByLayout(direction, actions)
    return function()
        local action = actions[activeWorkspaceLayout()]

        if action then
            if type(action) == "function" then
                action()
            else
                hl.dispatch(hl.dsp.layout(action))
            end
        else
            hl.dispatch(hl.dsp.focus({ direction = direction }))
        end
    end
end

local function moveWindowByLayout(direction, actions)
    return function()
        local action = actions[activeWorkspaceLayout()]

        if action then
            action()
        else
            hl.dispatch(hl.dsp.window.move({ direction = direction }))
        end
    end
end

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd(authAgent)
    hl.exec_cmd(wallpaperDaemon)
    hl.exec_cmd(notificationDaemon)
end)

hl.config({
    general = {
        gaps_in = 10,
        gaps_out = 5,
        border_size = 2,
        layout = "dwindle",
        no_focus_fallback = true,
        resize_on_border = false,

        col = {
            active_border = "rgba(ddddddff)",
            inactive_border = "rgba(595959aa)",
        },
    },

    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        float_switch_override_focus = 2,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    scrolling = {
        column_width = 0.9,
        focus_fit_method = 0,
        wrap_focus = false,
        wrap_swapcol = false,
    },

    binds = {
        workspace_back_and_forth = false,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "workspacesIn", enabled = false })
hl.animation({ leaf = "workspacesOut", enabled = false })

hl.bind(hyper .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + Space", hl.dsp.exec_cmd(menu))
hl.bind(hyper .. " + backspace", hl.dsp.window.close())
hl.bind(hyper .. " + SHIFT + backspace", hl.dsp.window.kill())
hl.bind(hyper .. " + Space", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(hyper .. " + SHIFT + Space", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind(hyper .. " + grave", hl.dsp.window.float({ action = "toggle" }))
hl.bind(hyper .. " + backslash", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(hyper .. " + SHIFT + backslash", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(hyper .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(hyper .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(hyper .. " + 5", hl.dsp.exec_cmd(wallpaperCycleCommand))
hl.bind(hyper .. " + 9", hl.dsp.exec_cmd(notificationCenter))

hl.bind(hyper .. " + H", focusByLayout("left", {
    scrolling = "focus l",
    hy3 = hy3Action(function(hy3)
        return hy3.move_focus("l")
    end),
}))
hl.bind(hyper .. " + J", focusByLayout("down", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_focus("d")
    end),
}))
hl.bind(hyper .. " + K", focusByLayout("up", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_focus("u")
    end),
}))
hl.bind(hyper .. " + L", focusByLayout("right", {
    scrolling = "focus r",
    hy3 = hy3Action(function(hy3)
        return hy3.move_focus("r")
    end),
}))

hl.bind(hyper .. " + SHIFT + H", moveWindowByLayout("left", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_window("l")
    end),
}))
hl.bind(hyper .. " + SHIFT + J", moveWindowByLayout("down", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_window("d")
    end),
}))
hl.bind(hyper .. " + SHIFT + K", moveWindowByLayout("up", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_window("u")
    end),
}))
hl.bind(hyper .. " + SHIFT + L", moveWindowByLayout("right", {
    hy3 = hy3Action(function(hy3)
        return hy3.move_window("r")
    end),
}))

hl.bind(hyper .. " + left", layoutAction({
    hy3 = hy3Action(function(hy3)
        return hy3.make_group("h", { toggle = true })
    end),
}))
hl.bind(hyper .. " + down", layoutAction({
    hy3 = hy3Action(function(hy3)
        return hy3.make_group("v", { toggle = true })
    end),
}))
hl.bind(hyper .. " + up", layoutAction({
    hy3 = hy3Action(function(hy3)
        return hy3.make_group("v", { toggle = true })
    end),
}))
hl.bind(hyper .. " + right", layoutAction({
    hy3 = hy3Action(function(hy3)
        return hy3.make_group("h", { toggle = true })
    end),
}))

hl.bind(hyper .. " + Minus", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(hyper .. " + Equal", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(hyper .. " + SHIFT + Minus", hl.dsp.window.resize({ x = 0, y = -25, relative = true }))
hl.bind(hyper .. " + SHIFT + Equal", hl.dsp.window.resize({ x = 0, y = 25, relative = true }))

hl.bind(hyper .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(hyper .. " + SHIFT + Tab", dispatch("movecurrentworkspacetomonitor +1"))
hl.bind(hyper .. " + Slash", layoutAction({
    dwindle = "togglesplit",
    scrolling = "consume_or_expel next",
}))
hl.bind(hyper .. " + SHIFT + Slash", layoutAction({
    dwindle = "swapsplit",
    scrolling = "consume_or_expel prev",
}))
hl.bind(hyper .. " + comma", cycleLayout(1))
hl.bind(hyper .. " + SHIFT + comma", cycleLayout(-1))

hl.bind(hyper .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(hyper .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(hyper .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(hyper .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))

for _, key in ipairs({
    "A", "B", "C", "D", "E", "F", "G", "I", "M", "N", "O", "P",
    "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}) do
    local workspace = "name:" .. key

    hl.bind(hyper .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(hyper .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
