return {
  {
    "echasnovski/mini.pick",
    version = false, -- Use false for the latest main branch, or "*" for stable releases
    config = function()
      require("mini.pick").setup()
    end,
    keys = {
      { "<leader>ff", "<cmd>Pick files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Pick grep_live<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Pick buffers<cr>", desc = "Buffers" },
    },
  },
}

