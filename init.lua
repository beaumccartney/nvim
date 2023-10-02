-- TODO:
-- submodes of some kind
-- undotree or telescope thing
-- undodir
-- session reloading




-- apparently I have to put this before the package manager
vim.g.mapleader = ' '

-- use homebrew python
vim.g.python3_host_prog = '/opt/homebrew/bin/python3'

vim.opt.shell = '/opt/homebrew/bin/fish' -- before plugin spec so terminal plugin sees it

vim.g.zig_fmt_autosave = 0

local make_keymap = vim.keymap.set

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
    {
        'FraserLee/ScratchPad',
        init = function()
            vim.g.scratchpad_autostart = 0
            make_keymap( 'n', 'S', vim.cmd.ScratchPad, {} )
        end,
    },

    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = true,
    },

    {
        '0x00-ketsu/maximizer.nvim',
        config = true,
    },

    -- highlight and search todo comments
    {
        'folke/todo-comments.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        opts = {
            signs = false,
            keywords = { TODO = { alt = { 'REVIEW', 'INCOMPLETE' }, }, },
        }
    },

    -- comment things - can respect tree-sitter or other things
    {
       'numToStr/Comment.nvim',
       config = function()
           require'Comment'.setup
           {
               pre_hook = require
                   'ts_context_commentstring.integrations.comment_nvim'
                   .create_pre_hook(),
           }
       end
    },

    -- vim-unimpaired
    -- REVIEW: should I get rid of or modify this?
    -- e.g. cursorline and cursor column
    {
        'tummetott/unimpaired.nvim',
        config = true,
    },

    -- surround things
    {
        'echasnovski/mini.surround',
        opts = { respect_selection_type = true, }
    },

    -- better [de]indenting and moving up and down
    {
        'echasnovski/mini.move',
        config = true,
    },

    -- everything
    {
        'nvim-treesitter/nvim-treesitter',
        build        = ':TSUpdate',
        dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring', },
        config = function()
            require'nvim-treesitter.install'.prefer_git = false

            require'nvim-treesitter.configs'.setup {
                ensure_installed      = 'all',
                highlight             = {
                    enable  = true,
                    disable = function(lang, bufnr)
                        return vim.api.nvim_buf_line_count(bufnr) > 1000

                            -- TODO: kill when zig parser isn't piss slow
                            or lang == 'zig'
                    end,
                    additional_vim_regex_highlighting = false,
                },
                context_commentstring = { enable = true, },
            }
        end
    },

    -- display the context of the cursor - e.g. what function or scope am I in

    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = 'nvim-treesitter',
        config       = { max_lines = 4, },
    },

    -- fuzzy-find files and strings
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tree/nvim-web-devicons'
        },
    },

    -- fzf syntax in fuzzy-finding
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        dependencies = 'nvim-telescope/telescope.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        config = function()
            require'telescope'.setup{}
            require'telescope'.load_extension('fzf')
        end
    },

    {
        'echasnovski/mini.statusline',
        config = true
    },

    -- git-gutter
    {
        'lewis6991/gitsigns.nvim',
        config = true,
    },

    -- all hail fugitive
    'tpope/vim-fugitive',
    'junegunn/gv.vim',
    'tpope/vim-rhubarb',
    -- 'shumphrey/fugitive-gitlab.vim',

    -- additional textobject keys after "a" and "i" e.g. <something>[a|i]q where q is quote text object
    {
        'echasnovski/mini.ai',
        config = true,
    },

    -- align stuff - great interactivity and keybinds
    {
        'echasnovski/mini.align',
        config = true,
    },

    -- highlight word under cursor
    {
        'echasnovski/mini.cursorword',
        config = true,
    },

    {
        'echasnovski/mini.files',
        dependencies = 'nvim-tree/nvim-web-devicons',
        opts = { windows = { preview = true, }, },
    },

    {
        'echasnovski/mini.indentscope',
        init = function() vim.g.miniindentscope_disable = true end,
        config = true,
    },

    {
        'echasnovski/mini.starter',
        config = true,
    },

    -- highlight and trim trailing whitespace
    {
        'echasnovski/mini.trailspace',
        config = true,
    },

    -- exchange, replace, sort, and evaluate stuff
    {
        'echasnovski/mini.operators',
        config = true,
    },

    {
        'sainnhe/gruvbox-material',
        lazy = true,
        init = function()
            vim.g.gruvbox_material_foreground = 'original'
            vim.g.gruvbox_material_background = 'hard'
        end
    },

    {
        'marko-cerovac/material.nvim',
        init = function() vim.g.material_style = "deep ocean" end,
        opts = {
            plugins =
            {
                -- Available plugins:
                -- "dap",
                -- "dashboard",
                "gitsigns",
                -- "hop",
                "indent-blankline",
                -- "lspsaga",
                "mini",
                -- "neogit",
                -- "neorg",
                "nvim-cmp",
                -- "nvim-navic",
                -- "nvim-tree",
                "nvim-web-devicons",
                -- "sneak",
                "telescope",
                -- "trouble",
                -- "which-key",
            },
        }
    },

    { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true },
    { "bluz71/vim-moonfly-colors",  name = "moonfly",  lazy = true },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = { show_current_context = true, }
    },

    {
        'mg979/vim-visual-multi',
        init = function()
            vim.g.VM_maps = {
                [ 'Add Cursor Down' ] = '<C-j>',
                [ 'Add Cursor Up'   ] = '<C-k>',
            }
        end
    },

    -- highlight cursor after large jump
    'rainbowhxch/beacon.nvim',

    -- fast j and k YEAH BUDDY
    -- holding j, k, w, b, W, B, etc goes fast after a while
    {
        'rainbowhxch/accelerated-jk.nvim',
        opts = {
            acceleration_motions = { 'w', 'b', 'W', 'B' },
        },
    },

    -- jai syntax-highlighting + folds + whatever
    { 'jansedivy/jai.vim', ft = "jai" },

    {
        'zbirenbaum/copilot.lua',
        opts = {
           suggestion = {
                auto_trigger = true,

            -- BEGIN stuff for use in nvim-cmp
                -- enabled = false,
            },
            -- panel = { enabled = false },
            -- end stuff for use in nvim-cmp
        }
    },
    'madox2/vim-ai',

    {
        "L3MON4D3/LuaSnip",
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },

    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require'lint'

            lint.linters_by_ft = {
                javascript = { 'eslint' },
                typescript = { 'eslint' },
                bash       = { 'shellcheck' },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                pattern = { "*.js", "*.ts", "*.jsx", "*.*js", "*.tsx", "*.sh", "*.bash" },
                callback = function()
                    lint.try_lint()
                end,
            })
        end
    },

    {
        'stevearc/conform.nvim',
        opts = {
	    formatters_by_ft = {
            javascript = { { "prettierd", "prettier" } },
            rust       = { { "rustfmt" } },
            zig        = { { "zigfmt" } },
            }
        },
    },


    {
        "ray-x/lsp_signature.nvim",
        opts = { toggle_key = "<C-i>", },
    },

    -- the stuff of nightmares
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'neovim/nvim-lspconfig',

            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer',
            'saadparwaiz1/cmp_luasnip',
            'mtoohey31/cmp-fish',
            -- {
            --     'zbirenbaum/copilot-cmp',
            --     config = function() require'copilot_cmp'.setup() end
            -- },
        },
        config = function()
            local cmp        = require'cmp'
            local sources    = cmp.config.sources
            local map        = cmp.mapping

            local modes = { 'i', 'c' }
            local i_only = { 'i' }

            cmp.setup {
                completion = { autocomplete = false },
                mapping = {
                    ['<C-b>'] = map(function() cmp.scroll_docs( -4 ) end, i_only),
                    ['<C-f>'] = map(function() cmp.scroll_docs(  4 ) end, i_only),
                    ['<C-j>'] = map(function()
                                        if not cmp.visible() then cmp.complete() end
                                        cmp.select_next_item()
                                    end,
                                modes),
                    ['<C-k>'] = map(function()
                                        if not cmp.visible() then cmp.complete() end
                                        cmp.select_prev_item()
                                    end,
                                modes),
                    ['<C-c>'] = map(cmp.abort, i_only),
                    ['<CR>' ] = map.confirm(),

                    -- free up these for snippet-traversing
                    ['<C-n>'] = cmp.config.disable,
                    ['<C-p>'] = cmp.config.disable,
                },
                snippet = { expand = function( args ) require'luasnip'.lsp_expand( args.body ) end },
                sources = sources {
                    -- { name = 'copilot', },
                    { name = 'fish'     },
                    { name = 'nvim_lsp' },
                    { name = 'luasnip'  },
                    { name = 'buffer'   },
                    { name = 'path'     },
                },
            }

            cmp.setup.cmdline({ '/', '?' }, {
                sources = sources { { name = 'buffer' }, },
            })
            cmp.setup.cmdline(':', {
                sources = sources {
                    { name = 'path',    },
                    { name = 'cmdline', },
                },
            })
            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function( client, bufnr )
                -- Enable completion triggered by <c-x><c-o>
                -- vim.api.nvim_buf_set_option( bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc' )
                local builtin = require'telescope.builtin'

                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                local lspbuf = vim.lsp.buf

                make_keymap( 'n', '<leader>gD', lspbuf.declaration,             bufopts )
                make_keymap( 'n', '<leader>i',  lspbuf.hover,                   bufopts )
                make_keymap( 'n', '<C-k>',      lspbuf.signature_help,          bufopts )
                make_keymap( 'n', '<leader>rn', lspbuf.rename,                  bufopts )
                make_keymap( 'n', '<leader>ca', lspbuf.code_action,             bufopts )
                make_keymap( 'n', '<leader>F',  function() lspbuf.format { async = true } end, bufopts )

                make_keymap( 'n', '<leader>gr',  builtin.lsp_references,       bufopts )
                make_keymap( 'n', '<leader>gd',  builtin.lsp_definitions,      bufopts )
                make_keymap( 'n', '<leader>gi',  builtin.lsp_implementations,  bufopts )
                make_keymap( 'n', '<leader>gtd', builtin.lsp_type_definitions, bufopts )
            end

            local lsp_servers = {
                -- 'asm_lsp',
                'astro', -- NOTE: must add typescript and astro-prettier-plugin as devDependencies for this to work
                'bashls',
                'clangd',
                -- 'cmake',
                'cssls',
                'cssmodules_ls',
                -- 'elmls',
                -- 'emmet_language_server',
                -- 'emmet_ls',
                'html',
                'hls',
                'rust_analyzer',
                'vtsls',
                'pyright',
                'prismals',
                -- 'quick_lint_js',
                'tailwindcss',
                'vimls',
                'zls',
            }
            local capabilities = require'cmp_nvim_lsp'.default_capabilities()
            local lspconfig = require'lspconfig'
            for _, server in pairs( lsp_servers ) do
                lspconfig[server].setup {
                    on_attach    = on_attach,
                    capabilities = capabilities,
                }
            end

        end
    },

    -- rainbow brackets
    'HiPhish/rainbow-delimiters.nvim',

}


-- lsp stuff
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

make_keymap( 'n', '<leader>e', vim.diagnostic.open_float, opts )
make_keymap( 'n', '[d',        vim.diagnostic.goto_prev,  opts )
make_keymap( 'n', ']d',        vim.diagnostic.goto_next,  opts )
make_keymap( 'n', '<leader>q', vim.diagnostic.setloclist, opts )

-- keymaps for built in things
make_keymap( 'n', '<leader>fs', vim.cmd.w,            {} ) -- save file
make_keymap( 'n', '<leader>fa', vim.cmd.wa,           {} ) -- save all files
make_keymap( 'n', '<leader>bd', vim.cmd.bd,           {} ) -- close buffer
make_keymap( 'n', '<leader>te', vim.cmd.tabe,         {} ) -- new tab

make_keymap( 'n', 'Y',         'y$',   opts ) -- yank to end of line
make_keymap( 'n', '<leader>Y', '"+y$', opts ) -- yank to end of line

make_keymap( { 'n', 'v' }, '<leader>y', '"+y',       opts ) -- yank to clipboard
make_keymap( { 'n', 'v' }, '<leader>p', '"+p', opts ) -- put from clipboard

-- change directory to current file - thanks fraser
make_keymap( 'n', '<leader>cd', '<Cmd>cd %:p:h<CR>', {} )
make_keymap( 'n', '<leader>..', '<Cmd>cd ..<CR>',    {} )

-- fraser again goddamn
make_keymap( 'n', '<ESC>', '<Cmd>noh<CR><Cmd>lua require"maximizer".restore()<CR>', opts )

make_keymap( 'n', '<leader>w', MiniTrailspace.trim, {} )

-- jk fixes (thanks yet again fraser)
make_keymap( 'n', 'j', '<Plug>(accelerated_jk_gj)', {} )
make_keymap( 'n', 'k', '<Plug>(accelerated_jk_gk)', {} )

make_keymap( 'v', 'j', 'gj', {} )
make_keymap( 'v', 'k', 'gk', {} )

local fileexplorer = function()
    MiniFiles.open( vim.api.nvim_buf_get_name( 0 ), false )
end
make_keymap( 'n', '<leader>fe', fileexplorer, {} )

make_keymap( 'n', 'M', require'maximizer'.toggle, {} )

-- git log stuff
make_keymap( { 'n', 'v' }, '<leader>gl', '<Cmd>GV<CR>',  {} )

make_keymap( { 'n', 'v' }, '<leader>gv', '<Cmd>GV!<CR>', {} )

make_keymap( 'n', '<leader>gp', '<Cmd>GV --patch<CR>', {} )

local builtin = require'telescope.builtin'

-- telescope maps
make_keymap( 'n', '<leader>ff', builtin.find_files,  {} )
make_keymap( 'n', '<leader>gg', builtin.git_files,   {} )
make_keymap( 'n', '<leader>fd', builtin.oldfiles,   {} )

make_keymap( 'n', '<leader>/',  builtin.live_grep,   {} )
make_keymap( 'n', '<leader>*',  builtin.grep_string, {} )

make_keymap( 'n', '<leader>fm', builtin.marks,       {} )
make_keymap( 'n', '<leader>fo', builtin.vim_options, {} )
make_keymap( 'n', '<leader>fk', builtin.keymaps,     {} )
make_keymap( 'n', '<leader>fh', builtin.help_tags,   {} )

make_keymap( 'n', '<leader>td', vim.cmd.TodoTelescope, {} )

make_keymap( 'n', '<leader>ts', builtin.treesitter,       {} )

-- luasnip
local ls = require'luasnip'
make_keymap( {"i", "s"}, "<C-n>", function() ls.jump( 1) end, opts )
make_keymap( {"i", "s"}, "<C-p>", function() ls.jump(-1) end, opts )

vim.opt.termguicolors  = true
vim.opt.nu             = true
vim.opt.relativenumber = true

vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true
vim.opt.smarttab    = true
vim.opt.cindent     = true
vim.opt.breakindent = true
vim.opt.linebreak   = true
vim.opt.formatoptions = vim.opt.formatoptions - 't' + 'cqrn' -- NOTE: formatting can be done manually with gq{textobj}
vim.opt.textwidth = 80

vim.opt.scrolloff      = 10
vim.opt.colorcolumn    = '81'

vim.opt.hidden         = true
vim.opt.swapfile       = false

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.opt.completeopt    = 'menu'

vim.opt.foldenable     = false

vim.opt.cmdheight      = 2

vim.opt.spell = true
make_keymap( 'i', '<C-z>', '<c-g>u<Esc>[s1z=`]a<c-g>u', opts )

local function write_centered_line()
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

make_keymap( 'n', '<leader>l', write_centered_line, {} )

function set_fold_options()
    if require"nvim-treesitter.parsers".has_parser() then
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr   = 'nvim_treesitter#foldexpr()'
    else
        vim.wo.foldmethod = 'indent'
    end
end

-- run all vimscript stuffs
-- TODO: factor this out into lua
vim.cmd[[
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )

    autocmd BufEnter * lua set_fold_options()

    autocmd BufEnter * set formatoptions-=to

    autocmd FileType html,css,scss,xml,yaml,json,javascript,typescript,javascriptreact,typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2 nocindent smartindent

    autocmd Filetype prisma setlocal smartindent nocindent

    " colorscheme gruvbox-material
    colorscheme material
]]

