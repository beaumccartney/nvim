require'packer'.startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'numToStr/Comment.nvim',
        config = function() require'Comment'.setup() end
    }

    use {
        'tummetott/unimpaired.nvim',
        config = function() require'unimpaired'.setup{} end
    }

    use {
        'kylechui/nvim-surround',
        config = function() require'nvim-surround'.setup{} end
    }

    use {
        disable = true,
        'nvim-treesitter/nvim-treesitter',
        run    = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = 'all',
                highlight        = { enable = true, },
            }
        end
    }

    use {
        disable = true,
        'mrjones2014/nvim-ts-rainbow',
        after   = 'nvim-treesitter',
        config  = function()
            require'nvim-treesitter.configs'.setup {
                rainbow {
                    enable         = true,
                    extended_mode  = true,
                    max_file_lines = 1000,
                }
            }
        end
    }

    use {
        -- TODO: configure
        disable = true,
        'nvim-treesitter/nvim-treesitter-textobjects',
        after   = 'nvim-treesitter',
        config  = function()
            require'nvim-treesitter.configs'.setup { }
        end
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = 'nvim-lua/plenary.nvim',
    }

    use {
        'nvim-lualine/lualine.nvim',
        config = function() require'lualine'.setup() end,
    }

    -- TODO: keybindings??
    use {"chrisgrieser/nvim-genghis", requires = "stevearc/dressing.nvim"}

    use 'gruvbox-community/gruvbox'

    use 'tommcdo/vim-lion'
    use 'justinmk/vim-sneak'
    use 'mg979/vim-visual-multi'

    use 'tpope/vim-fugitive'
    use 'tpope/vim-rhubarb'
    use 'shumphrey/fugitive-gitlab.vim'
    use 'junegunn/gv.vim'

    use 'mbbill/undotree'

    use 'jansedivy/jai.vim'
end)

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

