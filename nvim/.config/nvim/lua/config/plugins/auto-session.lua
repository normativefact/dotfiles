return {
  "rmagatti/auto-session",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Integrates with your existing Telescope
  },
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore_last_session = true, -- Automatically restores last session on startup
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" }, -- Skip generic folders
      
      -- Connects auto-session directly to Telescope
      session_lens = {
        load_on_setup = true,
        theme_conf = { border = true },
        previewer = false,
      },
    })

  end,
}

