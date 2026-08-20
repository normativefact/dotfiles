
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.conceallevel = 2
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.number = true
vim.opt.relativenumber = true

require("config.keymaps")
require("config.lazy")

