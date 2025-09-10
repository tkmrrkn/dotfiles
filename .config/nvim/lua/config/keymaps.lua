local map = vim.keymap.set

map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>e", ":NvimTreeToggle<CR>")

map("i", "jj", "<Esc>")
map("i", "jk", "<Esc>")

map("i", "{<Enter>", "{}<Left><CR><Esc><S-o>", { noremap = true})
map("i", "{", "{}<Left>", { noremap = true })
map("i", "\"", "\"\"<Left>", { noremap = true })
map("i", "'", "''<Left>", { noremap = true })
