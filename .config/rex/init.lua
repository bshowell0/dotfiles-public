-- Ghostty-style shortcuts. `super` is Command on macOS.

-- Create and close panes with a Vim-style prefix.
rex.bind("super+w>s", "pane.split", { direction = "down" })
rex.bind("super+w>v", "pane.split", { direction = "right" })
rex.bind("super+w>c", "pane.close")

-- Navigate panes without wrapping at the edge.
rex.bind("super+h", "pane.focus", { direction = "left", wrap = false })
rex.bind("super+j", "pane.focus", { direction = "down", wrap = false })
rex.bind("super+k", "pane.focus", { direction = "up", wrap = false })
rex.bind("super+l", "pane.focus", { direction = "right", wrap = false })

-- Move the divider by 5 percent of its split per press.
rex.bind("super+up", "pane.resize", { direction = "up", amount = 5 })
rex.bind("super+down", "pane.resize", { direction = "down", amount = 5 })
rex.bind("super+left", "pane.resize", { direction = "left", amount = 5 })
rex.bind("super+right", "pane.resize", { direction = "right", amount = 5 })

-- Font size controls.
rex.bind("super+=", "client.font.increase")
rex.bind("super+-", "client.font.decrease")
rex.bind("super+0", "client.font.reset")

-- Literal newline for terminal applications, matching Ghostty's Ctrl+J.
rex.bind("shift+enter", "pane.send_key", { key = "ctrl+j" })
