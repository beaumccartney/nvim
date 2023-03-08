-- TODO:
-- - mini.nvim
-- - telescope
-- - rip shit from doom like a degen
-- - save file keybind
-- - vertico from doom
-- - keybinds (maybe there's a plugin or something to wrap this and make
--             it less verbose????)

-- NOTE: I've added notes to plugins below that can be replaced by mini in case
-- they aren't good ("mini-replaceable")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require'lazy'.setup({
    {
        "FraserLee/ScratchPad",
        config = function() vim.g.scratchpad_autostart = 0 end,
    },

    {
        "folke/which-key.nvim",
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup()
        end,
    },

    {
        -- TODO: search these with telescope
        "folke/todo-comments.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup()
        end,
    },

    {
        -- NOTE: mini-replaceable
        'numToStr/Comment.nvim',
        config = function() require'Comment'.setup() end
    },

    -- NOTE: mini-replaceable
    -- vim-unimpaired
    {
        'tummetott/unimpaired.nvim',
        config = function() require'unimpaired'.setup{} end
    },

    -- NOTE: mini-replaceable
    -- vim-surround
    {
        'kylechui/nvim-surround',
        config = function() require'nvim-surround'.setup{} end
    },

    {
        'nvim-treesitter/nvim-treesitter',
        run    = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = 'all',
                highlight        = { enable = true, },
            }
        end
    },

    {
        'mrjones2014/nvim-ts-rainbow',
        after   = 'nvim-treesitter',
        config  = function()
            require'nvim-treesitter.configs'.setup {
                rainbow = {
                    enable         = true,
                    extended_mode  = true,
                    max_file_lines = 1000,
                }
            }
        end
    },

    -- NOTE: mini-replaceable?
    {
        -- TODO: configure
        enabled = false,
        'nvim-treesitter/nvim-treesitter-textobjects',
        after   = 'nvim-treesitter',
        config  = function()
            require'nvim-treesitter.configs'.setup {}
        end
    },

    -- NOTE: mini-replaceable
    {
        -- TODO: configure + keybinds
        'nvim-telescope/telescope.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
    },

    -- statusline
    -- NOTE: mini-replaceable
    {
        'nvim-lualine/lualine.nvim',
        config = function() require'lualine'.setup() end,
    },

    -- TODO: keybindings??
    -- vim-eunuch
    { "chrisgrieser/nvim-genghis", dependencies = "stevearc/dressing.nvim" },

    {
	    'TimUntersberger/neogit',
	    dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require'neogit'.setup { disable_commit_confirmation = true, }
        end
    },

    'gruvbox-community/gruvbox',

    -- TODO: replace
    'tommcdo/vim-lion',
    'justinmk/vim-sneak',
    'mg979/vim-visual-multi',

    'mbbill/undotree',

    'jansedivy/jai.vim',
})

vim.opt.termguicolors = true
vim.opt.nu            = true
vim.opt.relativenumber= true

vim.opt.tabstop       = 4
vim.opt.softtabstop   = 4
vim.opt.shiftwidth    = 4

vim.opt.expandtab     = true
vim.opt.smarttab      = true
vim.opt.cindent       = true
vim.opt.scrolloff     = 10
vim.opt.colorcolumn   = '80'
vim.opt.signcolumn    = 'yes'
vim.opt.signcolumn    = 'number'
vim.opt.hidden        = true
vim.opt.cmdheight     = 2
vim.opt.swapfile      = false

vim.opt.incsearch     = true
-- vim.opt.nohlsearch    = true
vim.opt.ignorecase    = true
vim.opt.smartcase     = true

vim.g.mapleader       = ' '

vim.cmd([[
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
augroup END

colorscheme gruvbox

nnoremap Y y$

syntax on
]])

