hl.monitor({
  output = "eDP-2",
  mode = "preferred",
  position = "0x0",
  scale = 1.0,
})

hl.monitor({
  output = "HDMI-A-2",
  mode = "1984x1300@59.96",
  position = "1920x0",
  scale = 1.0,
})

-- Workspace 1 on First Screen (eDP-2)
hl.workspace_rule({ workspace = "1", monitor = "eDP-2", default = true })

-- Workspaces 2, 3, 4, 5, 6 on Second Screen (HDMI-A-2)
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-2", default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-2" })
