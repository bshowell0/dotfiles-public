return {
  "brianhuster/live-preview.nvim",
  -- lazy-load only for these filetypes
  ft = { "markdown", "html", "css", "javascript", "asciidoc" },
  dependencies = {
    -- 'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
  },
  config = function()
    local is_mac = vim.uv.os_uname().sysname == "Darwin"
    local browser_cmd = ""

    if is_mac then
      browser_cmd = "open -na 'Zen' --args --new-window"
    else
      -- Check if binary is 'zen' or 'zen-browser'
      browser_cmd = 'zen --new-window'
    end

    -- 2. Apply the configuration
    require("livepreview.config").set({
      browser = browser_cmd,
    })

    -- 3. Buffer-local keymap only in markdown:
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set(
          "n",
          "<localleader>l",
          "<cmd>LivePreview start<cr>",
          { buffer = ev.buf, desc = "LivePreview start" }
        )
      end,
    })
  end,
}
