return {
  "HakonHarnes/img-clip.nvim",
  lazy = true,
  ft = { "markdown" },
  opts = {
    default = {
      dir_path = "assets",
      use_absolute_path = false,
      relative_to_current_file = true,
    },
  },
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard", ft = "markdown" },
  },
}
