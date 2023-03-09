-- TODO:
-- submodes of some kind
-- copilot???
-- fix centered line

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

require'lazy'.setup({
    -- center screen and scratchpad to expand working memory
    {
        'FraserLee/ScratchPad',
        config = function()
            vim.g.scratchpad_minwidth  = 20
            vim.g.scratchpad_autostart = 0
        end,
    },

    -- fish for keybinds - will go once I know my keybinds well
    {
        'folke/which-key.nvim',
        config = function() require'which-key'.setup() end
    },

    -- highlight and search todo comments
    {
        -- TODO: search these with telescope
        'folke/todo-comments.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        config = function()
            require('todo-comments').setup { signs = false }
        end,
    },

    -- NOTE: mini-replaceable
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

    -- NOTE: mini-replaceable
    -- surround things
    {
        'kylechui/nvim-surround',
        config = function() require'nvim-surround'.setup() end
    },

    -- everything
    {
        'nvim-treesitter/nvim-treesitter',
        run    = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed      = 'all',
                highlight             = { enable = true, },
                incremental_selection = { -- thanks again fraser
                    enable = true,
                    keymaps = {
                        -- <enter> to select and expand selection via syntax
                        -- <shift+enter> to shrink and deselect
                        init_selection   = '<CR>',
                        node_incremental = '<CR>',
                        node_decremental = '<S-CR>',
                    },
                },
            }
        end
    },

    -- NOTE: make sure this is maintained every once in a while
    -- rainbow parens
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

    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = 'nvim-treesitter',
        config       = function() require'treesitter-context'.setup() end,
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
        build = 'make',
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
        enabled = false,
        'gbprod/substitute.nvim',
        config = function() require'substitute'.setup() end,
    },

    'gruvbox-community/gruvbox',

    -- TODO: replace
    'godlygeek/tabular', -- NOTE: mini-replaceable
    -- XXX: mini-jump remapes ; and , so they don't work with this
    'justinmk/vim-sneak', -- like mini.jump, but for two character patterns
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
        enabled = false,
        'github/copilot.vim',
        config = function()
            -- TODO: 
        end,
    },

    -- inlay hints for c++
    'p00f/clangd_extensions.nvim',
})

-- lsp stuff
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

vim.keymap.set( 'n', '<space>e', vim.diagnostic.open_float, opts )
vim.keymap.set( 'n', '[d',       vim.diagnostic.goto_prev,  opts )
vim.keymap.set( 'n', ']d',       vim.diagnostic.goto_next,  opts )
vim.keymap.set( 'n', '<space>q', vim.diagnostic.setloclist, opts )

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function( client, bufnr )
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option( bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc' )

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }

  vim.keymap.set( 'n', '<leader>gD', vim.lsp.buf.declaration,    bufopts )
  vim.keymap.set( 'n', 'leader<i>',  vim.lsp.buf.hover,          bufopts )
  vim.keymap.set( 'n', '<C-k>',      vim.lsp.buf.signature_help, bufopts )
  vim.keymap.set( 'n', '<space>rn',  vim.lsp.buf.rename,         bufopts )
  vim.keymap.set( 'n', '<space>ca',  vim.lsp.buf.code_action,    bufopts )
end

local lsp_servers = { 'bashls', 'cmake', 'hls', 'pyright', 'vimls', 'zls' }

for _, server in pairs( lsp_servers ) do
    require'lspconfig'[server].setup { on_attach = on_attach }
end

require'clangd_extensions'.setup { server = { on_attach = on_attach, } }

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
vim.opt.cmdheight      = 2
vim.opt.swapfile       = false
vim.opt.clipboard      = 'unnamedplus'

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.hlsearch       = false

vim.g.mapleader        = ' '

-- keymaps for built in things
vim.keymap.set( 'n', '<leader>fs', ':w<CR>',  { noremap=true,             } ) -- save file
vim.keymap.set( 'n', '<leader>bd', ':bd<CR>', { noremap=true,             } ) -- close buffer
vim.keymap.set( 'n', 'Y',          'y$',      { noremap=true, silent=true } ) -- yank to end of line

-- jk fixes (thanks yet again fraser)
vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', {})
vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', {})

vim.api.nvim_set_keymap('v', 'j', 'gj', {})
vim.api.nvim_set_keymap('v', 'k', 'gk', {})

vim.keymap.set( 'n', '<leader>ss', ':ScratchPad<CR>', { noremap=true } )

vim.keymap.set( 'n', '<leader>gg', ':Git<CR>',        { noremap=true } )

-- git log stuff
vim.keymap.set( 'n', '<leader>gl', ':GV<CR>',         { noremap=true } )
vim.keymap.set( 'n', '<leader>GL', ':GV',             { noremap=true } )

vim.keymap.set( 'n', '<leader>gv', ':GV!<CR>',        { noremap=true } )
vim.keymap.set( 'n', '<leader>GV', ':GV!',            { noremap=true } )

vim.keymap.set( 'n', '<leader>gp', ':GV --patch<CR>', { noremap=true } )

vim.keymap.set( 'v', '<leader>gl', ':GV<CR>',         { noremap=true } )
vim.keymap.set( 'v', '<leader>GL', ':GV',             { noremap=true } )

-- telescope maps
local builtin = require('telescope.builtin')
vim.keymap.set( 'n', '<leader>ff',  builtin.find_files,           {} )
vim.keymap.set( 'n', '<leader>fg',  builtin.git_files,            {} )

vim.keymap.set( 'n', '<leader>/',   builtin.live_grep,            {} )
vim.keymap.set( 'n', '<leader>*',   builtin.grep_string,          {} )

vim.keymap.set( 'n', '<leader>mp',  builtin.man_pages,            {} )
vim.keymap.set( 'n', '<leader>ma',  builtin.marks,                {} )
vim.keymap.set( 'n', '<leader>vo',  builtin.vim_options,          {} )
vim.keymap.set( 'n', '<leader>km',  builtin.keymaps,              {} )

vim.keymap.set( 'n', '<leader>gr',  builtin.lsp_references,       {} )
vim.keymap.set( 'n', '<leader>gd',  builtin.lsp_definitions,      {} )
vim.keymap.set( 'n', '<leader>gi',  builtin.lsp_implementations,  {} )
vim.keymap.set( 'n', '<leader>gtd', builtin.lsp_type_definitions, {} )

-- vim.keymap.set( 'n', '<leader>ts',  builtin.treesitter,           {} )

-- thanks again fraser
-- XXX: doesn't write a comment!
function write_centered_line( text )
    local c = vim.fn.col('.')
    local line = vim.fn.getline('.')

    -- make the text either an empty string, or pad it with spaces
    text = (text == nil or text == '') and '' or ' ' .. text .. ' '
    -- if the line doesn't end in a space, add one
    if line:sub(-1) ~= ' ' and line:len() > 0 then
        line = line .. ' '
    end

    local line_length = string.len(line)
    local dash_length = 80 - line_length

    local left = math.floor(dash_length / 2) - math.floor(string.len(text) / 2)
    local right = dash_length - left - string.len(text)

    local new_line = line .. string.rep('-', left) .. text .. string.rep('-', right)
    vim.fn.setline('.', new_line)
end

function WriteCenteredLine()
    local text = vim.fn.input( 'Comment text: ')
    write_centered_line( " " .. text .. " " )
end

-- TODO: insert mode mapping for this
vim.keymap.set( 'n', '<leader>l', WriteCenteredLine, {} )

-- run all vimscript stuffs
vim.cmd([[
    augroup highlight_yank
        autocmd!
        autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )
    augroup END

    colorscheme gruvbox

    syntax on

    " thanks a bunch fraser
    " https://github.com/FraserLee/dotfiles/blob/master/.vimrc#LL298-L323C40
    " TODO: replace with a lua version backed by something that isn't tabular
    function! TabAlign( zs )
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
    noremap <leader>t :call TabAlign( 0 )<cr>
    noremap <leader>T :call TabAlign( 1 )<cr>
]])

