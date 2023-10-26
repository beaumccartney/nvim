-- TODO:
-- wrap mapping function
-- give all my keymaps descriptions
-- submodes of some kind (neovim hydra?)
-- fix neodev
-- gitsigns current hunk stuff
-- format range (see conform docs)
-- diffview nvim or idk get good at fugitive or someth
-- :make command for everything I need, including colorized output and error finding




-- apparently I have to put this before the package manager
vim.g.mapleader = ' '

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
            vim.g.scratchpad_location  = vim.fn.stdpath( 'data' ) .. '/scratchpad'
            make_keymap( 'n', '<leader>s', require'scratchpad'.invoke, {} )
        end,
    },

    {
        'akinsho/toggleterm.nvim',
        opts = { open_mapping = [[<c-/>]], },
    },

    {
        "stevearc/dressing.nvim",
        opts = { input = {
            insert_only     = false,
            start_in_insert = false,
        } },
    },

    {
        'echasnovski/mini.tabline',
        dependencies = 'nvim-tree/nvim-web-devicons',
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


    {
        'echasnovski/mini.clue',
        opts = {
            triggers = {
                { mode = 'n', keys = '<Leader>' },
                { mode = 'x', keys = '<Leader>' },

                { mode = 'n', keys = 'g' },
                { mode = 'x', keys = 'g' },

                { mode = 'n', keys = '<C-w>' },

                { mode = 'n', keys = 'z' },
                { mode = 'x', keys = 'z' },
            },
            window = { delay = 0, },
        },
        config = function(_, opts)
            local miniclue = require'mini.clue'

            local clues = {
                miniclue.gen_clues.g(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
            }

            local final_opts = vim.tbl_extend( 'error', opts, { clues = clues } )
            miniclue.setup( final_opts )
        end
    },

    {
        'echasnovski/mini.comment',
        opts = {
            options = {
                custom_commentstring = function()
                    return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
                end,
            }
        },
    },

    -- surround things
    {
        'echasnovski/mini.surround',
        opts = { respect_selection_type = true, }
    },

    -- change argument lists from one line to n lines or vice-versa
    {
    	'echasnovski/mini.splitjoin',
    	opts = true,
    },

    -- better [de]indenting and moving up and down
    {
        'echasnovski/mini.move',
        config = true,
    },

    -- everything
    {
        'nvim-treesitter/nvim-treesitter',
        opts  = {
            ensure_installed = 'all',
            -- TODO: kill when zig parser isn't piss slow
            ignore_install = { 'zig' },
            highlight        = {
                enable  = true,
                disable = function( lang, bufnr )
                    return vim.api.nvim_buf_line_count( bufnr ) > 1000
                end,
                additional_vim_regex_highlighting = false,
            },
        },
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring',
            'HiPhish/rainbow-delimiters.nvim',
            {
                'nvim-treesitter/nvim-treesitter-context',
                opts = { max_lines = 4, },
            },
        },
        build = ':TSUpdate',
        main  = 'nvim-treesitter.configs',
        init = function()
            -- set foldmethod to treesitter if parser is available
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    -- TODO: fold text highlighting w/ vim.wo.foldtext
                    vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
                    if require"nvim-treesitter.parsers".has_parser() then
                        vim.wo.foldmethod = 'expr'
                    else
                        vim.wo.foldmethod = 'indent'
                    end
                end,
            })
        end,
    },

    -- fuzzy-find files and strings
    {
        'echasnovski/mini.pick',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            mappings = {
                refine        = '<C-;>',
                refine_marked = '<M-;>',
            },
        },
        config = function( _, opts )
            local pick     = require'mini.pick'
            local registry = pick.registry
            pick.setup( opts )

            -- https://github.com/echasnovski/mini.nvim/issues/513#issuecomment-1762785125
            registry.buffer_lines = function( local_opts )
                -- Parse options
                local_opts = vim.tbl_deep_extend('force', { buf_id = nil, prompt = '' }, local_opts or {})
                local buf_id, prompt = local_opts.buf_id, local_opts.prompt
                local_opts.buf_id, local_opts.prompt = nil, nil

                -- Construct items
                if buf_id == nil or buf_id == 0 then buf_id = vim.api.nvim_get_current_buf() end
                local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
                local items = {}
                for i, l in ipairs(lines) do
                items[i] = { text = string.format('%d:%s', i, l), bufnr = buf_id, lnum = i }
                end

                -- Start picker while scheduling setting the query
                vim.schedule(function() MiniPick.set_picker_query(vim.split(prompt, '')) end)
                MiniPick.start({ source = { items = items, name = 'Buffer lines' } })
            end

            -- TODO: share this on the todo comments repo issue tracker or
            -- something
            registry.todo_comments = function( local_opts )
                require'todo-comments.search'.search( function( results )
                    local mini_pick_items = vim.tbl_map( function( entry )
                        return {
                            text = entry.text,
                            path = entry.filename,
                            lnum = entry.lnum,
                            col  = entry.col,
                        }
                    end, results )

                    local source = { items = mini_pick_items, name = 'Todo Comments' }
                    MiniPick.start( { source = source } )
                end )

            end
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
        init = function()
            make_keymap( { 'n', 'v' }, '<leader>gs', require'gitsigns'.stage_hunk, {} )
            make_keymap( { 'n', 'v' }, '<leader>ga', require'gitsigns'.stage_buffer, {} )
            make_keymap( { 'n', 'v' }, '<leader>gu', require'gitsigns'.undo_stage_hunk, {} )
        end
    },

    -- all hail fugitive
    'tpope/vim-fugitive',
    'junegunn/gv.vim',

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

    {
        'echasnovski/mini.bufremove',
        opts = true,
    },

    {
        'echasnovski/mini.bracketed',
        opts = true,
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
        config = true,
    },

    {
        'echasnovski/mini.jump',
        opts = { delay = { highlight = 0 }, },
    },

    {
        'echasnovski/mini.jump2d',
        opts = { view = { n_steps_ahead = 999, }, },
        config = function(_, opts)
            local jump2d = require('mini.jump2d')

            -- instead of jumping to arbitrary locations, jump to line starts
            local jump_line_start = jump2d.builtin_opts.line_start
            local final_opts = vim.tbl_extend( 'error', opts, {
                spotter = jump_line_start.spotter,
                hooks = { after_jump = jump_line_start.hooks.after_jump }
            })

            jump2d.setup( final_opts )

            local jump_word_start = jump2d.builtin_opts.word_start
            -- TODO: get this to work in operator pending mode
            make_keymap( { 'n', 'x', }, '<S-CR>', function() jump2d.start( jump_word_start ) end, {} )
        end,
    },

    {
        'echasnovski/mini.misc',
        config = function()
            require'mini.misc'.setup()

            MiniMisc.setup_restore_cursor()
        end,
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
                "gitsigns",
                "indent-blankline",
                "mini",
                "nvim-web-devicons",
                "rainbow-delimiters",
            },
        }
    },

    { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true },
    { "bluz71/vim-moonfly-colors",  name = "moonfly",  lazy = true },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = { scope = { enabled = false }, },
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
                debounce     = 5,
            },
        }
    },
    'madox2/vim-ai',

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
        -- TODO: better highlighting in signature help
        'echasnovski/mini.completion',
        opts = {
            mappings = {
                force_twostep  = '<C-j>',
                force_fallback = '<C-k>',
            },
            -- HACK: high delay for no autocomplete
            delay = { completion = 99999 },
            lsp_completion = {
                source_func = 'omnifunc',
                auto_setup  = false
            },
            window = { signature = { width = 120 }, },
            set_vim_settings = true, -- set shortmess and completeopt
        },
    },

    {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require'lspconfig'
            for _, server in pairs({
                -- 'asm_lsp',
                'astro', -- NOTE: must add typescript and astro-prettier-plugin as devDependencies for this to work
                'bashls',
                'clangd',
                -- 'cmake',
                'cssls',
                'cssmodules_ls',
                -- 'elmls',
                'html',
                'hls',
                'rust_analyzer',
                'vtsls',
                'pyright',
                'prismals',
                'tailwindcss',
                'vimls',
                'zls',
            }) do
                lspconfig[server].setup{}
            end
        end,
    },

}

-- lsp stuff
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

make_keymap( 'n', '<leader>e',  vim.diagnostic.open_float, opts )
make_keymap( 'n', '<leader>q',  vim.diagnostic.setloclist, opts )

-- keymaps for built in things
make_keymap( 'n', '<leader>fs', vim.cmd.w,    {}   ) -- save file
make_keymap( 'n', '<leader>fa', vim.cmd.wa,   {}   ) -- save all files
make_keymap( 'n', '<leader>te', vim.cmd.tabe, {}   ) -- new tab
make_keymap( 'n', '<leader>cc', vim.cmd.bd,   opts )
make_keymap( 'n', '<leader>cw', '<C-w><C-q>', opts )
make_keymap( { 'n', 'x', 'o', }, '<C-l>', 'g$', opts )
make_keymap( { 'n', 'x', 'o', }, '<C-h>', 'g^', opts )

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function( ev )
        vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

        local bufopts = { buffer=ev.buf }
        local lspbuf = vim.lsp.buf

        -- TODO:
        -- * incoming calls
        -- * outgoing calls

        make_keymap( 'n', '<leader>gD', lspbuf.declaration,             bufopts )
        make_keymap( 'n', '<leader>i',  lspbuf.hover,                   bufopts )
        -- TODO: there is a bizarre bug where mapping this to <C-i> causes it to
        -- also be triggered by <Tab> in normal mode. Idk what I could have done
        -- to cause this but I don't want to fix it right now
        -- make_keymap( 'n', '<C-i>',      lspbuf.signature_help,          bufopts )
        make_keymap( 'n', '<leader>rn', lspbuf.rename,                  bufopts )
        make_keymap( 'n', '<leader>ca', lspbuf.code_action,             bufopts )
        make_keymap( 'n', '<leader>F',  function() lspbuf.format { async = true } end, bufopts )

        make_keymap( 'n', '<leader>gr',  lspbuf.references,       bufopts )
        make_keymap( 'n', '<leader>gd',  lspbuf.definition,      bufopts )
        make_keymap( 'n', '<leader>gi',  lspbuf.implementation,  bufopts )
        make_keymap( 'n', '<leader>gtd', lspbuf.type_definition, bufopts )
    end
})

-- c-z to correct last misspelled word
-- credit: fraser and https://github.com/echasnovski/mini.basics/blob/c31a4725710db9733e8a8edb420f51fd617d72a3/lua/mini/basics.lua#L600-L606
make_keymap( 'n', '<C-Z>', '[s1z=`]',                   { desc = 'Correct latest misspelled word' } )
make_keymap( 'i', '<C-Z>', '<C-g>u<Esc>[s1z=`]a<C-g>u', { desc = 'Correct latest misspelled word' } )

-- from mini.basic
make_keymap('x', 'g/', '<esc>/\\%V', { silent = false, desc = 'Search inside visual selection' })

 --[[ BEGIN https://github.com/echasnovski/mini.nvim/blob/1fdbb864e2015eb6f501394d593630f825154385/lua/mini/basics.lua#L549C11-L549C11 ]]
-- Add empty lines before and after cursor line supporting dot-repeat
local cache_empty_line = nil
put_empty_line = function(put_above)
    -- This has a typical workflow for enabling dot-repeat:
    -- - On first call it sets `operatorfunc`, caches data, and calls
    --   `operatorfunc` on current cursor position.
    -- - On second call it performs task: puts `v:count1` empty lines
    --   above/below current line.
    if type(put_above) == 'boolean' then
        vim.o.operatorfunc = 'v:lua.put_empty_line'
        cache_empty_line = { put_above = put_above }
        return 'g@l'
    end
    local target_line = vim.fn.line('.') - (cache_empty_line.put_above and 1 or 0)
    vim.fn.append(target_line, vim.fn['repeat']({ '' }, vim.v.count1))
end
make_keymap( 'n', '[<space>', 'v:lua.put_empty_line(v:true)',  { expr = true, desc = 'Put empty line above' } )
make_keymap( 'n', ']<space>', 'v:lua.put_empty_line(v:false)', { expr = true, desc = 'Put empty line below' } )
--[[ ----------------------------------- END ---------------------------------- ]]

make_keymap( 'n', 'Y',         'y$',   opts ) -- yank to end of line
make_keymap( 'n', '<leader>Y', '"+y$', opts ) -- yank to end of line

make_keymap( { 'n', 'v' }, '<leader>y', '"+y', opts ) -- yank to clipboard
make_keymap( { 'n', 'v' }, '<leader>p', '"+p', opts ) -- put from clipboard

make_keymap( { 'n', 'v' }, '<C-d>', '<C-d>zz', opts ) -- scroll down
make_keymap( { 'n', 'v' }, '<C-u>', '<C-u>zz', opts ) -- scroll down

-- change directory to current file - thanks fraser
-- TODO: print directory I cd'd to
-- TODO: look at vim cd commands and see if one of them is applicable
--     - current file
--     - current buffer
--     - current window
--     - etc.
make_keymap( 'n', '<leader>cd', '<Cmd>cd %:p:h<CR>', {} )
make_keymap( 'n', '<leader>..', '<Cmd>cd ..<CR>',    {} )

-- fraser again goddamn
make_keymap( 'n', '<ESC>', function()
    vim.cmd.nohlsearch()
    vim.cmd.ccl()
    MiniJump.stop_jumping()
end, opts )

make_keymap( 'n', '<leader>w',  MiniTrailspace.trim,  {} )
make_keymap( 'n', '<leader>bd', MiniBufremove.delete, {} ) -- close buffer

-- jk fixes (thanks yet again fraser)
make_keymap( 'n', 'j', '<Plug>(accelerated_jk_gj)', {} )
make_keymap( 'n', 'k', '<Plug>(accelerated_jk_gk)', {} )

make_keymap( 'v', 'j', 'gj', {} )
make_keymap( 'v', 'k', 'gk', {} )

make_keymap( 'n', '<leader>fe', function()
    local buf = vim.api.nvim_buf_get_name( 0 )

    file = io.open( buf ) and buf or vim.fs.dirname( buf )

    MiniFiles.open( file )
end, {} )

make_keymap( 'n', 'M', MiniMisc.zoom, {} )

-- git log stuff
make_keymap( { 'n', 'v' }, '<leader>gl', '<Cmd>GV<CR>',  {} )

make_keymap( { 'n', 'v' }, '<leader>gv', '<Cmd>GV!<CR>', {} )

make_keymap( 'n', '<leader>gp', '<Cmd>GV --patch<CR>', {} )

local builtin = MiniPick.builtin

make_keymap( 'n', '<leader>ff', builtin.files, {} )
make_keymap( 'n', '<leader>fh', builtin.help, {} )
make_keymap( 'n', '<leader>td', MiniPick.registry.todo_comments, {} )

-- TODO: make cword maps use word highlighted by visual if applicable
make_keymap( 'n', '<leader>/', '<Cmd>Pick buffer_lines<CR>',                  {} )
make_keymap( 'n', '<leader>8', '<Cmd>Pick buffer_lines prompt="<cword>"<CR>', {} )
make_keymap( 'n', '<leader>?', builtin.grep_live,                             {} )
make_keymap( 'n', '<leader>*', '<Cmd>Pick grep pattern="<cword>"<CR>',        {} )


vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true

vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true
vim.opt.smarttab    = true
vim.opt.cindent     = true
vim.opt.breakindent = true
vim.opt.linebreak   = true
vim.opt.formatoptions = vim.opt.formatoptions:append( 'jcqrn' ) -- NOTE: formatting can be done manually with gq{textobj}
vim.opt.textwidth = 80

vim.opt.scrolloff      = 10
vim.opt.colorcolumn    = '81'
vim.opt.splitbelow     = true

vim.opt.hidden         = true
vim.opt.swapfile       = false
vim.opt.undofile       = true

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.opt.pumheight      = 5

vim.opt.foldenable     = false
vim.opt.foldmethod     = 'indent'

vim.opt.cmdheight      = 2

-- write centered line - 80 character line with text in the middle and dashes
-- padding it
make_keymap( 'n', '<leader>l', function()
    local line = vim.fn.trim( vim.fn.getline( '.' ) )

    local comment_text = line ~= '' and line or vim.fn.input( 'Comment text: ' )

    -- make the comment_text either an empty string, or pad it with spaces
    if comment_text ~= '' then comment_text = ' ' .. comment_text .. ' ' end

    local comment_len = string.len( comment_text )
    local indent_len  = vim.fn.cindent( '.' )
    local dash_len    = 77 - indent_len -- TODO: factor in commentstring

    local half_dash_len    = math.floor( dash_len    / 2 )
    local half_comment_len = math.floor( comment_len / 2 )

    local num_left_dashes  = half_dash_len - half_comment_len
    local num_right_dashes = dash_len - num_left_dashes - comment_len

    local leading_spaces    = string.rep( ' ', indent_len       ) -- indent
    local left_dash_string  = string.rep( '-', num_left_dashes  )
    local right_dash_string = string.rep( '-', num_right_dashes )

    local new_line = leading_spaces .. left_dash_string .. comment_text .. right_dash_string
    vim.fn.setline( '.', new_line )

    local linenum = vim.api.nvim_win_get_cursor( 0 )[ 1 ]
    MiniComment.toggle_lines( linenum, linenum )
end , {} )

-- run all vimscript stuffs
-- TODO: factor this out into lua
vim.cmd[[
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )

    autocmd Filetype * set formatoptions-=to formatoptions+=j

    autocmd Filetype *.wgsl set filetype=wgsl

    autocmd Filetype *.zon set filetype=zig

    autocmd FileType html,css,scss,xml,yaml,json,javascript,typescript,javascriptreact,typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2 nocindent smartindent

    autocmd Filetype prisma setlocal smartindent nocindent

    " turn on spellcheck for plain text stuff
    autocmd Filetype text,markdown,gitcommit setlocal spell

    autocmd Filetype jai,wgsl setlocal commentstring=//\ %s

    autocmd FileType DressingInput lua vim.b.minicompletion_disable = true

    " colorscheme gruvbox-material
    colorscheme material
]]

