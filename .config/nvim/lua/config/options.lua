local o = vim.opt
-- stylua: ignore start
o.autoread = true -- Enable auto-reading of files when they change on disk
o.breakindent = true -- Enable break indent so wrapped lines continue visually indented
vim.schedule(function() o.clipboard = 'unnamedplus' end) -- Sync clipboard between OS and Neovim (see `:help 'clipboard'`)
o.confirm = true -- Show confirm dialog on destructive actions
o.cursorline = true -- Enable highlighting of the current line
o.foldenable = true -- Enable folding; `:help foldenable`
o.foldlevel = 99 -- Set the fold level to a high value to keep all folds open by default
o.foldlevelstart = -1 -- Top level folds only are closed by default
o.foldmethod = "expr" -- Set the fold method to "expr" for treesitter-based folding
o.foldnestmax = 4 -- Limit folding to 3 nested levels
o.foldtext = "" -- Disable fold text display since it's redundant with the status line
o.ignorecase = true -- Ignore case in search patterns
o.inccommand = "split" -- Show the effects of a command incrementally in a split
o.list = true -- Show whitespace characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Configure how whitespace characters are displayed
o.mouse = "nv" -- Enable mouse support in normal and visual modes
o.number = true -- Show line numbers
o.relativenumber = false -- Don't show relative line numbers
o.scrolloff = 10 -- Keep 10 lines visible when scrolling
o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
o.showmode = false -- Don't show the mode since it's already in the statusline
o.signcolumn = "yes" -- Always show the sign column, otherwise it would shift the text each time
o.smartcase = true -- Override 'ignorecase' if the search pattern contains uppercase letters
o.smartindent = true -- Insert indents automatically
o.splitbelow = true -- Force all horizontal splits to go below the current window
o.splitright = true -- Force all vertical splits to go to the right of the current window
o.undodir = vim.fn.stdpath("data") .. "/undo" -- Set undo directory to a subdirectory of the standard data path
o.undofile = true -- Enable persistent undo so that undo history is saved to a file
o.undolevels = 1000 -- Set the maximum number of changes that can be undone
o.updatetime = 250 -- Faster completion (4000ms default)
o.winborder = "rounded" -- Use rounded borders for floating windows
o.fillchars = o.fillchars + 'diff:/' -- Set diagonal fillchar for diffs
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions" -- Configure what to store in sessions

-- stylua: ignore end

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
})
