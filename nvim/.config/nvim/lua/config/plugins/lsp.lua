
-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Native Neovim 0.11+ configuration (No deprecation warnings)
    vim.lsp.config("markdown_oxide", {
      cmd = { "markdown-oxide" },
      filetypes = { "markdown" },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = true,
          },
        },
      },
    })

    -- Enable markdown_oxide globally for markdown buffers
    vim.lsp.enable("markdown_oxide")
  end,
}
