hl.plugin.load("/home/arch/.config/hypr/plugins/hyprbars.so")

hl.config({
  plugin = {
    hyprbars = {
      bar_height = 28,
      bar_color = "rgba(24, 25, 38, 0.9)",
      ["col.text"] = "rgb(205, 214, 244)",
      bar_text_font = "JetBrains Mono",
      bar_text_size = 11,
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      bar_padding = 10,
      bar_button_padding = 8,
      on_double_click = "hyprctl dispatch 'hl.dsp.window.fullscreen(1)'",
    },
  },
})

-- 1. Close button (Red)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(237, 135, 150)",
  fg_color = "rgb(24, 25, 38)",
  size = 12,
  icon = "✕",
  action = "hyprctl dispatch 'hl.dsp.window.close()'",
})

-- 2. Maximize / Fullscreen button (Green)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(166, 218, 149)",
  fg_color = "rgb(24, 25, 38)",
  size = 12,
  icon = "□",
  action = "hyprctl dispatch 'hl.dsp.window.fullscreen(1)'",
})

-- 3. Float / Minimize button (Yellow)
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(238, 212, 159)",
  fg_color = "rgb(24, 25, 38)",
  size = 12,
  icon = "−",
  action = [[hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:minimized", follow = false })']],
})
