return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      dir_path = "assets", -- Saves all images in ~/Documents/ObsidianVault/assets/
      embed_image_as_wickilink = true,
      file_name = "%Y-%m-%d-%H-%M-%S", -- Names files by timestamp
      use_absolute_path = false,
      relative_to_current_file = true,
    },
  },
  keys = {
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
  },
}
