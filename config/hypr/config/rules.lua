-- Suppress apps from forcing fullscreen/maximize on launch
hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Float kitty by default like in traditional desktop environments (KDE)
hl.window_rule({
  name = "kitty-floating",
  match = { class = "kitty" },
  float = true,
  center = true,
})

-- Quickshell bar layer blur control (synced with settings.json)
local function get_bar_blur()
  local f = io.open(os.getenv("HOME") .. "/.config/serpantinum/settings.json", "r")
  if not f then return true end
  local content = f:read("*a")
  f:close()
  if content:find('"blur"%s*:%s*false') then
    return false
  end
  return true
end

hl.layer_rule({
  name = "quickshell-bar-blur",
  match = { namespace = "quickshell" },
  blur = get_bar_blur(),
})
