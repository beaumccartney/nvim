-- TODO:
-- submodes of some kind
-- signature help
-- undotree or telescope thing
-- undodir
-- session reloading





-- apparently I have to put this before the package manager
vim.g.mapleader = ' '

-- bootstrap package manager (ngl it works nice)
local lazypath = vim.fn.stdpath( 'data' ) .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat( lazypath ) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend( lazypath )

require'lazy'.setup {
    -- center screen and scratchpad to expand working memory
    {
        'FraserLee/ScratchPad',
        config = function() vim.g.scratchpad_autostart = 0 end,
    },

    -- highlight and search todo comments
    {
        'folke/todo-comments.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require'todo-comments'.setup {
                signs = false,
                keywords = { TODO = { alt = { 'REVIEW', 'INCOMPLETE' }, }, },
            }
        end,
    },

    -- comment things - can respect tree-sitter or other things
    {
       'numToStr/Comment.nvim',
       config = function() require'Comment'.setup() end
    },

    -- vim-unimpaired
    -- REVIEW: should I get rid of or modify this?
    -- e.g. cursorline and cursor column
    {
        'tummetott/unimpaired.nvim',
        config = function() require'unimpaired'.setup() end
    },

    -- surround things
    {
        'echasnovski/mini.surround',
        config = function()
            require'mini.surround'.setup { respect_selection_type = true, }
        end,
    },

    -- everything
    {
        'nvim-treesitter/nvim-treesitter',
        run    = ':TSUpdate',
        config = function()
            require'nvim-treesitter.install'.prefer_git = false

            require'nvim-treesitter.configs'.setup {
                ensure_installed      = 'all',
                highlight             = {
                    enable  = true,
                    disable = { 'gitcommit' },
                },
                incremental_selection = { -- thanks again fraser
                    enable = true,
                    keymaps = {
                        -- Alt-k to select and expand selection via syntax
                        -- Alt-j to shrink and deselect
                        init_selection   = '<M-k>',
                        node_incremental = '<M-k>',
                        node_decremental = '<M-j>',
                    },
                },
            }
        end
    },

    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = 'nvim-treesitter',
        config       = function() require'treesitter-context'.setup() end,
    },

    -- fuzzy-find files and strings
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'kyazdani42/nvim-web-devicons'
        },
    },

    -- fzf syntax in fuzzy-finding
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        config = function()
            require'telescope'.setup()
            require'telescope'.load_extension('fzf')
        end
    },

    -- evilline
    {
        'windwp/windline.nvim',
        config = function() require'wlsample.evil_line' end
    },

    -- git-gutter
    {
        'lewis6991/gitsigns.nvim',
        config = function() require'gitsigns'.setup() end
    },

    -- all hail fugitive
    'tpope/vim-fugitive',
    'junegunn/gv.vim',
    'tpope/vim-rhubarb',
    'shumphrey/fugitive-gitlab.vim',

    -- additional textobject keys after "a" and "i" e.g. <something>[a|i]q where q is quote text object
    {
        'echasnovski/mini.ai',
        config = function() require'mini.ai'.setup() end,
    },

    -- align stuff - great interactivity and keybinds
    {
        'echasnovski/mini.align',
        config = function() require'mini.align'.setup() end,
    },

    -- highlight word under cursor
    {
        'echasnovski/mini.cursorword',
        config = function() require'mini.cursorword'.setup() end,
    },

    -- operations on the indent of the cursor - helps when there's no tree-sitter
    {
        'echasnovski/mini.indentscope',
        config = function() require'mini.indentscope'.setup() end,
    },

    -- good f/F/t/T keys - not confined to line and can keep mashing ; or ,
    {
        'echasnovski/mini.jump',
        config = function() require'mini.jump'.setup() end,
    },

    -- start screen when I don't start with someth
    {
        'echasnovski/mini.starter',
        config = function() require'mini.starter'.setup() end,
    },

    -- highlight and trim trailing whitespace
    {
        'echasnovski/mini.trailspace',
        config = function() require'mini.trailspace'.setup() end,
    },

    -- switch things easily
    -- TODO: keybindings
    {
        'gbprod/substitute.nvim',
        config = function() require'substitute'.setup() end,
    },

    'gruvbox-community/gruvbox',

    'mg979/vim-visual-multi',

    -- highlight cursor after large jump
    'rainbowhxch/beacon.nvim',

    -- fast j and k YEAH BUDDY
    -- holding j, k, w, b, W, B, etc goes fast after a while
    {
        'rainbowhxch/accelerated-jk.nvim',
        config = function()
            require'accelerated-jk'.setup {
                acceleration_motions = { 'w', 'b', 'W', 'B' },
            }
        end
    },

    -- jai syntax-highlighting + folds + whatever
    'jansedivy/jai.vim',

    'neovim/nvim-lspconfig',

    {
        'zbirenbaum/copilot.lua',
        config = function()
            require'copilot'.setup { suggestion = { auto_trigger = false }, }
        end
    },
    -- 'madox2/vim-ai', -- requires python3 support

    -- inlay hints for c++
    'p00f/clangd_extensions.nvim',

}

local make_keymap = vim.keymap.set

-- lsp stuff
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

make_keymap( 'n', '<leader>e', vim.diagnostic.open_float, opts )
make_keymap( 'n', '[d',        vim.diagnostic.goto_prev,  opts )
make_keymap( 'n', ']d',        vim.diagnostic.goto_next,  opts )
make_keymap( 'n', '<leader>q', vim.diagnostic.setloclist, opts )

local builtin = require('telescope.builtin')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function( client, bufnr )
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option( bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc' )

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }

  make_keymap( 'n', '<leader>gD', vim.lsp.buf.declaration,    bufopts )
  make_keymap( 'n', '<leader>i',  vim.lsp.buf.hover,          bufopts )
  make_keymap( 'n', '<C-k>',      vim.lsp.buf.signature_help, bufopts )
  make_keymap( 'n', '<leader>rn',  vim.lsp.buf.rename,         bufopts )
  make_keymap( 'n', '<leader>ca',  vim.lsp.buf.code_action,    bufopts )

  make_keymap( 'n', '<leader>gr',  builtin.lsp_references,       {} )
  make_keymap( 'n', '<leader>gd',  builtin.lsp_definitions,      {} )
  make_keymap( 'n', '<leader>gi',  builtin.lsp_implementations,  {} )
  make_keymap( 'n', '<leader>gtd', builtin.lsp_type_definitions, {} )
end

local lsp_servers = {
    -- 'asm_lsp',
    'astro',
    'bashls',
    -- 'cmake',
    'cssls',
    'cssmodules_ls',
    -- 'elmls',
    'html',
    -- 'hls',
    'vtsls',
    'pyright',
    'prismals',
    'tailwindcss',
    'vimls'
}
for _, server in pairs( lsp_servers ) do
    require'lspconfig'[server].setup { on_attach = on_attach }
end

require'clangd_extensions'.setup { server = { on_attach = on_attach, } }

-- keymaps for built in things
make_keymap( 'n', '<leader>fs', '<Cmd>w<CR>',    { noremap=true, } ) -- save file
make_keymap( 'n', '<leader>sa', '<Cmd>wa<CR>',   { noremap=true, } ) -- save all files
make_keymap( 'n', '<leader>bd', '<Cmd>bd<CR>',   { noremap=true, } ) -- close buffer
make_keymap( 'n', '<leader>te', '<Cmd>tabe<CR>', { noremap=true, } ) -- close buffer

make_keymap( 'n', 'Y',         'y$',   { noremap=true, silent=true } ) -- yank to end of line
make_keymap( 'n', '<leader>Y', '"+y$', { noremap=true, silent=true } ) -- yank to end of line

make_keymap( { 'n', 'v' }, '<leader>y', '"+y', { noremap=true, silent=true } ) -- yank to clipboard
make_keymap( { 'n', 'v' }, '<leader>p', '"+p', { noremap=true, silent=true } ) -- put from clipboard

-- change directory to current file - thanks fraser
make_keymap( 'n', '<leader>cd', '<Cmd>cd %:p:h<CR>', { noremap=true } )
make_keymap( 'n', '<leader>..', '<Cmd>cd ..<CR>',    { noremap=true } )

make_keymap( 'n', '<leader>w', '<Cmd>lua MiniTrailspace.trim()<CR>', {} )

-- jk fixes (thanks yet again fraser)
make_keymap( 'n', 'j', '<Plug>(accelerated_jk_gj)', {} )
make_keymap( 'n', 'k', '<Plug>(accelerated_jk_gk)', {} )

make_keymap( 'v', 'j', 'gj', {} )
make_keymap( 'v', 'k', 'gk', {} )

make_keymap( 'n', '<leader>ss', '<Cmd>ScratchPad<CR>', { noremap=true } )

-- git log stuff
make_keymap( { 'n', 'v' }, '<leader>gl', '<Cmd>GV<CR>',  { noremap=true } )
make_keymap( { 'n', 'v' }, '<leader>GL', ':GV',          { noremap=true } )

make_keymap( { 'n', 'v' }, '<leader>gv', '<Cmd>GV!<CR>', { noremap=true } )
make_keymap( { 'n', 'v' }, '<leader>GV', ':GV!',         { noremap=true } )

make_keymap( 'n', '<leader>gp', '<Cmd>GV --patch<CR>', { noremap=true } )

-- REVIEW: I may get away with only the visual mode binding
local exchange = require'substitute.exchange'
make_keymap( "n", "cx",  exchange.operator, { noremap = true } )
make_keymap( "n", "cxx", exchange.line,     { noremap = true } )
make_keymap( "x", "X",   exchange.visual,   { noremap = true } )
make_keymap( "n", "cxc", exchange.cancel,   { noremap = true } )

-- telescope maps
make_keymap( 'n', '<leader>ff', builtin.find_files,  {} )
make_keymap( 'n', '<leader>gg', builtin.git_files,   {} )

make_keymap( 'n', '<leader>/',  builtin.live_grep,   {} )
make_keymap( 'n', '<leader>*',  builtin.grep_string, {} )

make_keymap( 'n', '<leader>fm', builtin.marks,       {} )
make_keymap( 'n', '<leader>fo', builtin.vim_options, {} )
make_keymap( 'n', '<leader>fk', builtin.keymaps,     {} )
make_keymap( 'n', '<leader>fh', builtin.help_tags,   {} )

make_keymap( 'n', '<leader>td', '<Cmd>TodoTelescope<CR>', {} )

make_keymap( 'n', '<leader>ts', builtin.treesitter,       {} )

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

vim.opt.hidden         = true
vim.opt.swapfile       = false

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.opt.completeopt    = 'menu'

vim.opt.foldenable     = false

vim.opt.cmdheight      = 2

function write_centered_line()
    -- https://github.com/numToStr/Comment.nvim - good plugin
    local api = require'Comment.api'

    -- uncomment line
    -- HACK: just uncomment both linewise and blockwise ig
    -- TODO: make it not throw errors when there's nothing to uncomment
    api.uncomment.linewise()
    api.uncomment.blockwise()

    local line = vim.fn.trim( vim.fn.getline( '.' ) )

    local comment_text = line ~= '' and line or vim.fn.input( 'Comment text: ' )

    -- make the comment_text either an empty string, or pad it with spaces
    if comment_text ~= '' then comment_text = ' ' .. comment_text .. ' ' end

    local comment_len = string.len( comment_text )
    local indent_len  = vim.fn.cindent( '.' )
    local dash_len    = 74 - indent_len -- TODO: factor in commentstring

    local half_dash_len    = math.floor( dash_len    / 2 )
    local half_comment_len = math.floor( comment_len / 2 )

    local num_left_dashes  = half_dash_len - half_comment_len
    local num_right_dashes = dash_len - num_left_dashes - comment_len

    local leading_spaces    = string.rep( ' ', indent_len       ) -- indent
    local left_dash_string  = string.rep( '-', num_left_dashes  )
    local right_dash_string = string.rep( '-', num_right_dashes )

    local new_line = leading_spaces .. left_dash_string .. comment_text .. right_dash_string
    vim.fn.setline( '.', new_line )

    api.comment.blockwise()
end

make_keymap( 'n', '<leader>l', write_centered_line,                         {} )
make_keymap( 'i', '<C-l>',     '<c-\\><c-o>:lua write_centered_line()<CR>', {} )

-- run all vimscript stuffs
-- TODO: factor this out into lua
vim.cmd([[
    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )
    augroup END

    augroup treesitter_folds
        autocmd!
        autocmd FileType * if luaeval('require"nvim-treesitter.parsers".has_parser()') | setlocal foldmethod=expr | setlocal foldexpr=nvim_treesitter#foldexpr() | endif
    augroup END

    colorscheme gruvbox
]])

