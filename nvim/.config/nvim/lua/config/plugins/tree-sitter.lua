return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- Forces the stable branch with configs support
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "markdown", "markdown_inline", "lua", "vim", "vimdoc" },
      highlight = { enable = true },
    })
  end,
}

