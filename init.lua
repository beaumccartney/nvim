-- TODO:
-- - mini.nvim
-- - telescope
-- - rip shit from doom like a degen
-- - save file keybind
-- - vertico from doom
-- - keybinds (maybe there's a plugin or something to wrap this and make
--             it less verbose????)

-- NOTE: I've added notes to plugins below that can be replaced by mini in case
-- they aren't good ('mini-replaceable')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require'lazy'.setup({
    -- TODO: tell fraser that the autostart doesn't respect the minwidth
    {
        'FraserLee/ScratchPad',
        config = function() vim.g.scratchpad_minwidth = 20 end,
    },

    {
        'folke/which-key.nvim',
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require'which-key'.setup()
        end,
    },

    {
        -- TODO: search these with telescope
        'folke/todo-comments.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup()
        end,
    },

    -- NOTE: mini-replaceable
    -- vim-commentary
    {
        'numToStr/Comment.nvim',
        config = function() require'Comment'.setup() end
    },

    -- vim-unimpaired
    {
        'tummetott/unimpaired.nvim',
        config = function() require'unimpaired'.setup() end
    },

    -- NOTE: mini-replaceable
    -- vim-surround
    {
        'kylechui/nvim-surround',
        config = function() require'nvim-surround'.setup() end
    },

    {
        'nvim-treesitter/nvim-treesitter',
        run    = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = 'all',
                highlight        = { enable = true, },
                incremental_selection = { -- thanks again fraser
                    keymaps = {
                        -- <enter> to select and expand selection via syntax
                        -- <shift+enter> to shrink and deselect
                        init_selection = '<CR>',
                        node_incremental = '<CR>',
                        node_decremental = '<S-CR>',
                    },
                },
            }
        end
    },

    -- NOTE: make sure this is maintained every once in a while
    {
        'mrjones2014/nvim-ts-rainbow',
        dependencies = 'nvim-treesitter',
        config       = function()
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
        after  = 'nvim-treesitter',
        config = function()
            require'nvim-treesitter.configs'.setup()
        end
    },

    {
        -- TODO: configure + keybinds
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons'
        },
    },

    -- statusline
    -- NOTE: mini-replaceable
    {
        'nvim-lualine/lualine.nvim',
        dependencies = 'kyazdani42/nvim-web-devicons',
        config = function() require'lualine'.setup() end,
    },

    {
	    'TimUntersberger/neogit',
	    dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require'neogit'.setup { disable_commit_confirmation = true, }
        end
    },

    {
        'echasnovski/mini.ai',
        config = function() require'mini.ai'.setup() end,
    },

    {
        'echasnovski/mini.cursorword',
        config = function() require'mini.cursorword'.setup() end,
    },

    {
        'echasnovski/mini.indentscope',
        config = function() require'mini.indentscope'.setup() end,
    },

    {
        'echasnovski/mini.jump',
        config = function() require'mini.jump'.setup() end,
    },

    {
        'echasnovski/mini.trailspace',
        config = function() require'mini.trailspace'.setup() end,
    },

    'gruvbox-community/gruvbox',

    -- TODO: replace
    'godlygeek/tabular', -- NOTE: mini-replaceable
    -- 'justinmk/vim-sneak',
    'mg979/vim-visual-multi',

    'mbbill/undotree',

    'jansedivy/jai.vim',
})

vim.opt.termguicolors  = true
vim.opt.nu             = true
vim.opt.relativenumber = true

vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4

vim.opt.expandtab      = true
vim.opt.smarttab       = true
vim.opt.cindent        = true
vim.opt.scrolloff      = 10
vim.opt.colorcolumn    = '80'
vim.opt.signcolumn     = 'yes'
vim.opt.signcolumn     = 'number'
vim.opt.hidden         = true
vim.opt.cmdheight      = 2
vim.opt.swapfile       = false
vim.opt.clipboard      = 'unnamedplus'

vim.opt.incsearch      = true
-- vim.opt.nohlsearch  = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.g.mapleader        = ' '

-- keymaps for built in things
vim.keymap.set( 'n',  '<leader>fs',  ':w<CR>', { noremap=true, silent=true } )
vim.keymap.set( 'n',  'Y',           'y$',     { noremap=true, silent=true } )
vim.keymap.set( 'v',  '<leader>y',   '"*y',    { noremap=true, silent=true } )
vim.keymap.set( 'n',  '<leader>y',   '"*y',    { noremap=true, silent=true } )
vim.keymap.set( 'v',  '<leader>p',   '"*p',    { noremap=true, silent=true } )
vim.keymap.set( 'n',  '<leader>p',   '"*p',    { noremap=true, silent=true } )

-- keymaps for miscellaneous plugins
vim.keymap.set( 'n',  '<leader>gg',  ':Neogit<CR>',      { noremap=true } )
vim.keymap.set( 'n',  'cc',          ':ScratchPad<CR>',  { noremap=true } )

-- telescope maps
local builtin = require('telescope.builtin')
vim.keymap.set( 'n',  '<leader>ff',   builtin .find_files,            {} )
vim.keymap.set( 'n',  '<leader>fg',   builtin .git_files,             {} )

vim.keymap.set( 'n',  '<leader>/',    builtin .live_grep,             {} )
vim.keymap.set( 'n',  '<leader>*',    builtin .grep_string,           {} )

vim.keymap.set( 'n',  '<leader>mp',   builtin .man_pages,             {} )
vim.keymap.set( 'n',  '<leader>ma',   builtin .marks,                 {} )
vim.keymap.set( 'n',  '<leader>vo',   builtin .vim_options,           {} )
vim.keymap.set( 'n',  '<leader>km',   builtin .keymaps,               {} )

vim.keymap.set( 'n',  '<leader>gr',   builtin .lsp_references,        {} )
vim.keymap.set( 'n',  '<leader>gd',   builtin .lsp_definitions,       {} )
vim.keymap.set( 'n',  '<leader>gi',   builtin .lsp_implementations,   {} )
vim.keymap.set( 'n',  '<leader>gtd',  builtin .lsp_type_definitions,  {} )

vim.keymap.set( 'n',  '<leader>ts',   builtin .treesitter,            {} )

-- run all vimscript stuffs
vim.cmd([[
    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
    augroup END

    colorscheme gruvbox

    syntax on

    " thanks a bunch fraser
    " https://github.com/FraserLee/dotfiles/blob/master/.vimrc#LL298-L323C40
    function! TabAlign(zs)
        " get the character under the cursor
        let c = matchstr(getline('.'), '\%' . col('.') . 'c.')
        let pos = getpos(".") " save the position of the cursor

        " if the character needs to be escaped, put a backslash in front of it
        " Todo: add more characters that need escaping
        if matchstr(c, '[\\\/\.]') != ''
            let c = '\' . c
        endif

        " Tabularize with that character
        if a:zs | :execute ":Tabularize /" . c . "\\zs"
        else    | :execute ":Tabularize /" . c
        endif
        call setpos('.', pos) " Restore the cursor position
    endfunction

    " <leader>t will align stuff like
    " aaaaaa | aaa | aaaaaa
    " b      | b   | b
    " while <leader>T will align stuff like
    " aaaaaa,  aaa,  aaaaaa
    " b,       b,    b
    noremap <leader>t :call TabAlign(0)<cr>
    noremap <leader>T :call TabAlign(1)<cr>
]])

