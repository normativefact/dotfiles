return 
{ "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  lazy = true,
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    legacy_commands = false, -- this will be removed in 4.0.0
    workspaces = {
      {
        name = "PKM",
        path = "~/notes",
      },
    },
  },

  ui = {enable = false},
  completion = {
      blink = true,
      min_chars = 2,
    },

    -- ID of the notes: 
    note_id_func = function(title)
	    if title ~= nil then
		    -- Convert "My New Note"" -> "my-new-note"
		    return title:gsub(" ","-"):gsub("[^A-Za-z0-9-]",""):lower()
		else
			return tostring(os.time())
		end
	end,

    mappings = {
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
	}
}
