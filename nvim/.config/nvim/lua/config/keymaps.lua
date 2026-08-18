local map = vim.keymap.set

-- 1. File Explorer (Right Side via snacks.nvim)
map("n", "<leader>e", function()
  Snacks.explorer({ position = "right", width = 25, })
end, { desc = "Toggle File Explorer" })

-- Rename file and ensure that it's in the right directory instead of the one you were cd'd into
vim.keymap.set("n", "<leader>rn", function()
    local old_name = vim.api.nvim_buf_get_name(0)
    if old_name == "" then return end

    vim.ui.input({ prompt = "Rename file to: ", default = old_name }, function(new_name)
        if not new_name or new_name == old_name then return end
        
        -- Rename file on disk and load it into the buffer
        os.rename(old_name, new_name)
        vim.cmd("edit " .. vim.fn.fnameescape(new_name))
        vim.cmd("bdelete #")
    end)
end, { desc = "Rename current file safely in place" })


-- 2. Focus Panes (works seamlessly across editor splits and file tree)
map("n", "<C-h>", "<C-w>h", { desc = "Focus Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus Right Window" })
map("n", "<C-q>", "<cmd>close<cr>", { desc = "Close Pane" })

-- 3. Move/Shift Pane Positions
map("n", "<C-S-h>", "<C-w>H", { desc = "Move Pane Far Left" })
map("n", "<C-S-j>", "<C-w>J", { desc = "Move Pane to Bottom" })
map("n", "<C-S-k>", "<C-w>K", { desc = "Move Pane to Top" })
map("n", "<C-S-l>", "<C-w>L", { desc = "Move Pane Far Right" })

-- 4. Tabs Management
map("n", "tt", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<A-h>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<A-l>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close Tab" })

-- 5. Obsidian Vault Shortcuts
map("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "Obsidian: New Note" })
map("n", "<leader>od", "<cmd>Obsidian today<cr>", { desc = "Obsidian: Daily Note" })
map("n", "<leader>oz", "<cmd>Obsidian quick_switch<cr>", { desc = "Obsidian: Switch Note" })
map("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "Obsidian: Search Vault" })
map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Obsidian: Backlinks" })
map("v", "<leader>ol", "<cmd>Obsidian link<cr>", { desc = "Obsidian: Link Selection" })
