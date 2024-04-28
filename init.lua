-- TODO:
-- :s respects case
-- wrap mapping function
-- give all my keymaps descriptions
-- put all autocommands in a group so they don't get re-added on re-source
-- have mini pickers put shit in qf list where possible and replace with gf variants where not




-- apparently I have to put this before the package manager
vim.g.mapleader = ' '

-- strangely enough this contains what shell I'm using - huh
vim.opt.shell = vim.env.STARSHIP_SHELL

vim.g.zig_fmt_autosave = 0

local make_keymap = vim.keymap.set

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
    vim.cmd('echo "Installing `mini.nvim`" | redraw')
    local clone_cmd = {
        'git', 'clone', '--filter=blob:none',
        'https://github.com/echasnovski/mini.nvim', mini_path
    }
    vim.fn.system(clone_cmd)
    vim.cmd('packadd mini.nvim | helptags ALL')
    vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require'mini.deps'.setup { path = { package = path_package } }

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

add('nvim-tree/nvim-web-devicons')
require'nvim-web-devicons'.setup()

require'mini.extra'      .setup() -- first because other plugins depend on it

require'mini.align'      .setup()
require'mini.bracketed'  .setup()
require'mini.bufremove'  .setup()
require'mini.cursorword' .setup()
require'mini.indentscope'.setup()
require'mini.jump'       .setup()
require'mini.move'       .setup()
require'mini.operators'  .setup()
require'mini.splitjoin'  .setup()
require'mini.statusline' .setup()
require'mini.tabline'    .setup()

require'mini.trailspace' .setup()
make_keymap( 'n', '<leader>w', function()
    MiniTrailspace.trim()
    MiniTrailspace.trim_last_lines()
end,            {} )


local hipatterns = require'mini.hipatterns'
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup {
    highlighters = {
        todo  = hi_words({ 'TODO',  'REVIEW', 'INCOMPLETE'           }, 'MiniHipatternsTodo' ),
        fixme = hi_words({ 'FIXME', 'BUG',    'ROBUSTNESS', 'CRASH', }, 'MiniHipatternsFixme'),
        note  = hi_words({ 'NOTE',  'INFO',                          }, 'MiniHipatternsNote' ),
        hack  = hi_words({ 'HACK',  'XXX',                           }, 'MiniHipatternsHack' ),

        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
    delay = {
        text_change = 0,
        scroll = 0,
    },
}

require 'mini.comment'.setup {
    options = {
        custom_commentstring = function()
            return require 'ts_context_commentstring'.calculate_commentstring() or vim.bo.commentstring
        end,
    },
    mappings = { textobject = 'ic', },
}

require 'mini.surround'.setup {
    respect_selection_type = true,
}

require 'mini.notify'.setup {
    lsp_progress = {
        -- enable = false,
        duration_last = 350,
    },
}

require 'mini.pick'.setup {
    mappings = {
        refine        = '<C-;>',
        refine_marked = '<M-;>',
    },
}
local builtin = MiniPick.builtin
local extra = MiniExtra.pickers

make_keymap( 'n', '<leader>ff', builtin.files,   {} )
make_keymap( 'n', '<leader>fh', builtin.help,    {} )

-- TODO: make cword maps use word highlighted by visual if applicable
-- TODO: leader-8 find cword in the current buffer
make_keymap( 'n', '<leader>/', extra.buf_lines,                 {} )
-- make_keymap( 'n', '<leader>8', '<Cmd>Pick buf_lines prompt="<cword>"<CR>', {} )
-- TODO: ugrep_live (fuzzy finding + --and patterns for each word)
make_keymap( 'n', '<leader>?', builtin.grep_live,                          {} )
make_keymap( 'n', '<leader>*', '<Cmd>Pick grep pattern="<cword>"<CR>',     {} )

make_keymap( '',  '<leader>fc', extra.commands )
make_keymap( '',  '<leader>fd', extra.diagnostic )
make_keymap( 'n', '<leader>fo', extra.options )
make_keymap( 'n', '<leader>td', '<Cmd>Pick hipatterns highlighters={"todo" "fixme" "hack"}<CR>' )

make_keymap( '', '<leader>fq', function() extra.list({ scope = 'quickfix' }) end, {})
make_keymap( '', '<leader>fv', function() extra.visit_paths() end, {})

require 'mini.visits'.setup()
vim.api.nvim_create_autocmd( 'BufReadPre', {
    callback = function(args)
        local currentDir = vim.fn.getcwd()
        local bufDir     = vim.fn.fnamemodify( args.file, ':p:h' )
        if not vim.startswith( bufDir, currentDir ) then
            vim.b.minivisits_disable = true
        end
    end,
})
make_keymap( 'n', '<leader>v', MiniVisits.select_path, {} )

local ai = require'mini.ai'
local gen_spec = ai.gen_spec
local extra_ai_spec = MiniExtra.gen_ai_spec
ai.setup({
    search_method = 'cover_or_nearest',
    custom_textobjects = {
        F = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
        c = gen_spec.treesitter({ a = '@class.outer',    i = '@class.inner'    }),
        S = gen_spec.treesitter({ a = '@block.outer',    i = '@block.inner'    }),
        j = extra_ai_spec.line(),
        d = extra_ai_spec.number(),
        g = extra_ai_spec.buffer(),
        e = extra_ai_spec.diagnostic(),
        -- TODO:
        --      assignment inner
        --      assignment outer
        --      assignment lhs
        --      assignment rhs
    },
})

require 'mini.files'.setup {
    windows = {
        max_number = 3,
    },
}
local open = MiniFiles.open
make_keymap( 'n', '<leader>fe', open, {} )
make_keymap( 'n', '<leader>fi', function()
    local buf = vim.api.nvim_buf_get_name( 0 )

    local file = io.open( buf ) and buf or vim.fs.dirname( buf )

    open( file )
end, {} )

require 'mini.misc'.setup()
MiniMisc.setup_restore_cursor()
make_keymap( 'n', '<leader>z', MiniMisc.zoom, {} )

require 'mini.sessions'.setup()
make_keymap( 'n', '<leader>ss', function()
    local session = #vim.v.this_session == 0 and vim.fn.input({
        prompt = 'Session name: ',
        default = MiniSessions.config.file,
        completion = 'file',
    }) or nil

    if session then
        if session == '' then return end
        if not vim.endswith(session, '.vim') then session = session .. '.vim' end
    end

    MiniSessions.write(session)
end, {} )

local function sessionaction(action)
    local exists = false
    for _, _ in pairs(MiniSessions.detected) do
        exists = true
    end

    if not exists then
        print('No sessions')
        return
    end

    MiniSessions.select(action)
end

make_keymap( 'n', '<leader>sf', function()
    sessionaction('read')
end, {} )
make_keymap( 'n', '<leader>sd', function()
    sessionaction('delete')
end, {} )
make_keymap( 'n', '<leader>sw', function()
    sessionaction('write')
end, {} )

local starter = require'mini.starter'
starter.setup {
    evaluate_single = true,
    items = {
        starter.sections.sessions(),
        starter.sections.recent_files(4, true, false),
        starter.sections.builtin_actions(),
    },
}

require 'mini.completion'.setup {
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
}

add({
    source = "pianocomposer321/officer.nvim",
    depends ={ "stevearc/overseer.nvim", }
})
make_keymap( 'n', '<CR><CR>',        "<Cmd>Make!<CR>", {} )
make_keymap( 'n', '<CR><SPACE><CR>', ":Make!<SPACE>",  {} )
require'officer'.setup()

add('FraserLee/ScratchPad')
vim.g.scratchpad_autostart = 0
vim.g.scratchpad_location  = vim.fn.stdpath( 'data' ) .. '/scratchpad'
make_keymap( 'n', 'S', require'scratchpad'.invoke, {} )

add("stevearc/dressing.nvim")

require'dressing'.setup {
    input = {
        insert_only     = false,
        start_in_insert = false,
    },
}


add({
  source = 'nvim-treesitter/nvim-treesitter',
  checkout = 'master',
  monitor = 'main',
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})
-- set foldmethod to treesitter if parser is available
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.api.nvim_create_autocmd("Filetype", {
    callback = function()
        if not require"nvim-treesitter.parsers".has_parser() then
            vim.wo.foldmethod = 'indent'
            return
        end

        vim.wo.foldmethod = 'expr'

        -- don't use fo-n, just indent with treesitter
        vim.bo.autoindent  = false
        vim.bo.smartindent = false
        vim.bo.cindent     = false

        -- TODO: if longest line in buffer is too long kill
        if vim.api.nvim_buf_line_count(0) > 1024 then return end
        vim.treesitter.start()
    end,
})
require'nvim-treesitter.configs'.setup {
    auto_install = true,
    ensure_installed = {
        'asm',
        'bash',
        'c',
        'cpp',
        'css',
        'csv',
        'diff',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'just',
        'lua',
        'luadoc',
        'make',
        'markdown',
        'markdown_inline',
        'odin',
        'printf',
        'python',
        'regex',
        'requirements',
        'scss',
        'todotxt',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
    },
    -- TODO: use ziglibs zig ts parser
    ignore_install = { 'zig' },
    indent = {
        enable = true,
        disable = { 'odin', },
    },
}

add('nvim-treesitter/nvim-treesitter-textobjects')

add('JoosepAlviste/nvim-ts-context-commentstring')
vim.g.skip_ts_context_commentstring_module = true
require'ts_context_commentstring'.setup {
    languages = {
        cpp = '// %s',
        just = '# %s',
    },
}

add('HiPhish/rainbow-delimiters.nvim')

add('nvim-treesitter/nvim-treesitter-context')
require'treesitter-context'.setup {
    multiline_threshold = 4,
    trim_scope = 'inner',
    mode = 'topline',
}

add('lewis6991/gitsigns.nvim')
local gs_opts = {
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 0,
    },
}
local gs = require'gitsigns'
gs.setup(gs_opts)
make_keymap({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {})

make_keymap( { 'n' }, '<leader>gp', gs.preview_hunk, {} )

make_keymap( { 'n' }, '<leader>gs', gs.stage_hunk, {} )
make_keymap( { 'v' }, '<leader>gs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
make_keymap( { 'n' }, '<leader>gu', gs.undo_stage_hunk, {} )
make_keymap( { 'n' }, '<leader>ga', gs.stage_buffer, {} )

make_keymap( { 'n' }, '<leader>gk', gs.reset_hunk, {} )
make_keymap( { 'v' }, '<leader>gk', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
make_keymap( { 'n' }, '<leader>gK', gs.reset_buffer, {} )

make_keymap( { 'n' }, '<leader>gb', function()
    gs.blame_line({ full = true })
end, {} )

local toggle_state = gs_opts.signs or true
local extra_toggle_state = false
local function signs_toggle(switch, extra)
    toggle_state = switch or (not toggle_state)
    gs.toggle_current_line_blame(toggle_state)
    gs.toggle_signs(toggle_state)
    gs.toggle_numhl(toggle_state)

    extra_toggle_state = extra and (not extra_toggle_state) or false
    gs.toggle_deleted(extra_toggle_state)
    gs.toggle_linehl(extra_toggle_state)
    gs.toggle_linehl(extra_toggle_state)
    gs.toggle_word_diff(extra_toggle_state)
end
make_keymap( { 'n' }, '<leader>gh', signs_toggle, {} )

make_keymap( { 'n' }, '<leader>gf', function()
    signs_toggle(true, true)
end, {} )

make_keymap( '', '[h', gs.prev_hunk, {} )
make_keymap( '', ']h', gs.next_hunk, {} )

add('sindrets/diffview.nvim')
add({
    source = 'NeogitOrg/neogit',
    checkout = 'nightly',
    depends = {
        'nvim-lua/plenary.nvim',
    },
})
local ng = require'neogit'
ng.setup({
    disable_insert_on_commit = true,
})
make_keymap( 'n', '<leader>gg', ng.open, {} )

-- additional textobject keys after "a" and "i" e.g. <something>[a|i]q where q is quote text object
add('nvim-treesitter/nvim-treesitter-textobjects')

add('sainnhe/gruvbox-material')
vim.g.gruvbox_material_foreground = 'original'
vim.g.gruvbox_material_background = 'hard'

add('marko-cerovac/material.nvim')
vim.g.material_style = "deep ocean"
require'material'.setup {
    plugins = {
        "gitsigns",
        "indent-blankline",
        "mini",
        "neogit",
        "nvim-web-devicons",
        "rainbow-delimiters",
    },
}

add("lukas-reineke/indent-blankline.nvim")
require'ibl'.setup { scope = { enabled = false }, }

vim.g.VM_maps = {
    [ 'Add Cursor Down' ] = '<C-j>',
    [ 'Add Cursor Up'   ] = '<C-k>',
}
add('mg979/vim-visual-multi')

-- highlight cursor after large jump
add('rainbowhxch/beacon.nvim')

-- fast j and k YEAH BUDDY
-- holding j, k, w, b, W, B, etc goes fast after a while
add('rainbowhxch/accelerated-jk.nvim')
require'accelerated-jk'.setup {
    acceleration_motions = { 'w', 'b', 'W', 'B' },
}


-- jai syntax-highlighting + folds + whatever
add('puremourning/jai.vim')
vim.g.jai_compiler = vim.env.HOME .. '/external/jai/bin/jai-macos'

add('zbirenbaum/copilot.lua')
require'copilot'.setup {
    suggestion = {
        auto_trigger = true,
        debounce     = 0,
    },
    filetypes = {
        DressingInput = false,
        NeogitStatus = false,
        NeogitCommitView = false,
    },
}

add('stevearc/conform.nvim')
make_keymap( { 'n', 'x' }, '<leader>F', function() require'conform'.format { async = true, lsp_fallback = true, } end )
require'conform'.setup {
    formatters_by_ft = {
        javascript = { { "prettierd", "prettier" } },
        json       = { { "prettierd", "prettier" } },
        odin       = { { "odinfmt" } },
        rust       = { { "rustfmt" } },
        zig        = { { "zigfmt" } },
    }
}

add('neovim/nvim-lspconfig')

add("folke/neodev.nvim")
require'neodev'.setup()

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function( ev )
        vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'

        local bufopts = { buffer = ev.buf }
        local lsp     = vim.lsp
        local lspbuf  = lsp.buf
        local function picklsp( scope )
            return function()
                MiniExtra.pickers.lsp( { scope = scope } )
            end
        end

        make_keymap( 'n', '<leader>gD',  lspbuf.declaration,     bufopts )
        make_keymap( 'n', '<leader>i',   lspbuf.hover,           bufopts )
        make_keymap( 'n', '<leader>I',   lspbuf.signature_help,  bufopts )
        make_keymap( 'n', '<leader>rn',  lspbuf.rename,          bufopts )
        make_keymap( 'n', '<leader>ca',  lspbuf.code_action,     bufopts )

        make_keymap( 'n', '<leader>gr',  lspbuf.references,      bufopts )
        make_keymap( 'n', '<leader>gd',  lspbuf.definition,      bufopts )
        make_keymap( 'n', '<leader>gi',  lspbuf.implementation,  bufopts )
        make_keymap( 'n', '<leader>gtd', lspbuf.type_definition, bufopts )
        make_keymap( 'n', '<leader>fs',  lspbuf.document_symbol, bufopts )
        make_keymap( 'n', '<leader>co',  lspbuf.incoming_calls,  bufopts )
        make_keymap( 'n', '<leader>ci',  lspbuf.outgoing_calls,  bufopts )

        local inlay_hint = lsp.inlay_hint
        make_keymap( 'n', '<leader>h', function()
            local enabled = inlay_hint.is_enabled( ev.buf )
            inlay_hint.enable( not enabled )
        end, bufopts )
    end
})
local lspconfig = require'lspconfig'
for _, server in pairs({
    'bashls',
    'clangd',
    'cssls',
    'eslint',
    'gopls',
    'html',
    'jsonls',
    'lua_ls',
    'pyright',
    'vtsls',
}) do
    lspconfig[server].setup{}
end
lspconfig.ols.setup {
    init_options = {
        enable_document_symbols  = true,
        enable_snippets          = false,
        enable_inlay_hints       = true,
        enable_references        = true,
        enable_hover             = true,
        enable_procedure_context = true,
    },
}

local configs = require'lspconfig.configs'

if configs.jails then error("Jails config exists") end

local util = lspconfig.util
configs.jails = {
    default_config = {
        cmd                 = { 'jails', },
        filetypes           = { 'jai', },
        single_file_support = true,
        root_dir            = function( fname )
            return util.root_pattern(unpack({
                'build.jai',
                'first.jai',
                'jails.json',
            }))(fname) or util.find_git_ancestor(fname)

                -- HACK: jails crashes if I don't put this - lspconfig docs tell me explicitly to NOT do this
                or util.path.dirname(fname)
        end,
    },
}
lspconfig.jails.setup{}

-- lsp stuff
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

local diagnostic = vim.diagnostic
make_keymap( 'n', '<leader>e', diagnostic.open_float, opts )
make_keymap( 'n', '<leader>bd', diagnostic.setloclist, opts )

make_keymap( 'n', '<leader>d', function()
    diagnostic.enable(not diagnostic.is_enabled())
end, opts )

-- keymaps for built in things
make_keymap( '',  '<C-s>', vim.cmd.wall, {} ) -- save file
make_keymap( '!', '<C-s>', vim.cmd.wall, {} ) -- save file
make_keymap( 'n', '<leader>te', vim.cmd.tabe, {}   ) -- new tab
make_keymap( 'n', '<leader>tc', vim.cmd.tabc, {}   ) -- new tab
make_keymap( 'n', '<leader>cw', '<C-w><C-q>', opts )
make_keymap( '', '<C-l>', 'g$', opts )
make_keymap( '', '<C-h>', 'g^', opts )


make_keymap( '', '<leader>q', function()
    local windows = vim.fn.getwininfo()
    for _, win in pairs(windows) do
        if win['quickfix'] == 1 then
            vim.cmd.cclose()
            return
        end
    end
    vim.cmd.copen()
end, opts )

-- credit: fraser and https://github.com/echasnovski/mini.basics/blob/c31a4725710db9733e8a8edb420f51fd617d72a3/lua/mini/basics.lua#L600-L606
make_keymap( 'n', '<C-c>', '[s1z=`]',                   { desc = 'Correct latest misspelled word' } )
make_keymap( 'i', '<C-c>', '<C-g>u<Esc>[s1z=`]a<C-g>u', { desc = 'Correct latest misspelled word' } )

-- from mini.basic
make_keymap('x', 'g/', '<esc>/\\%V', { silent = false, desc = 'Search inside visual selection' })

 --[[ BEGIN https://github.com/echasnovski/mini.nvim/blob/1fdbb864e2015eb6f501394d593630f825154385/lua/mini/basics.lua#L549C11-L549C11 ]]
-- Add empty lines before and after cursor line supporting dot-repeat
local cache_empty_line = nil
function put_empty_line(put_above)
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

make_keymap( '', '<C-d>', '<C-d>zz', opts ) -- scroll down
make_keymap( '', '<C-u>', '<C-u>zz', opts ) -- scroll down

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
    vim.cmd.cclose()
    vim.cmd.lclose()
    MiniJump.stop_jumping()
end, opts )

make_keymap( 'n', '<leader>cc', MiniBufremove.delete, {}   )
make_keymap( 'n', 'Q',          vim.cmd.bd,           opts )

-- jk fixes (thanks yet again fraser)
make_keymap( 'n', 'j', '<Plug>(accelerated_jk_gj)', {} )
make_keymap( 'n', 'k', '<Plug>(accelerated_jk_gk)', {} )

make_keymap( 'v', 'j', 'gj', {} )
make_keymap( 'v', 'k', 'gk', {} )

vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true

vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.smarttab       = true
vim.opt.cindent        = true
vim.opt.breakindent    = true
vim.opt.breakindentopt = 'list:-1'
vim.opt.linebreak      = true

vim.opt.scrolloff      = 10
vim.opt.colorcolumn    = '81'
vim.opt.splitbelow     = true
vim.opt.splitright     = true

vim.opt.hidden         = true
vim.opt.swapfile       = false
vim.opt.undofile       = true

vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

vim.opt.pumheight      = 5

vim.opt.foldmethod     = 'indent'
vim.opt.foldlevel      = 100

vim.opt.cursorline     = true
vim.opt.cursorcolumn   = true

vim.opt.cmdheight      = 1
---------------------------------------------------------------------------
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

vim.filetype.add({
    extension = {
        mdpp = 'markdown',
    },
})

vim.cmd[[
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank( { timeout = 100 } )

    autocmd Filetype * setlocal formatoptions+=jcqrno formatoptions-=t

    autocmd FileType html,css,scss,xml,javascriptreact,typescriptreact setlocal shiftwidth=2 softtabstop=2

    autocmd Filetype text,markdown,git,gitcommit,NeogitCommitMessage setlocal spell autoindent comments-=fb:* comments-=fb:- comments-=fb:+
    autocmd BufEnter * lua pcall(require'mini.misc'.use_nested_comments)

    autocmd Filetype wgsl setlocal commentstring=//\ %s

    autocmd FileType DressingInput,gitcommit,NeogitCommitMessage let b:minicompletion_disable = v:true | let b:minivisits_disable = v:true | let b:minitrailspace_disable = v:true

    autocmd FileType NeogitStatus,NeogitCommitMessage,NeogitCommitView setlocal foldmethod=manual
    autocmd FileType odin setlocal smartindent errorformat+=%f(%l:%c)\ %m

    " open help windows to the left
    autocmd FileType help if winwidth(0) > winheight(0) | wincmd H | endif

    " colorscheme gruvbox-material
    colorscheme material

    if executable('ugrep')
        set grepprg=ugrep\ -RInk\ -j\ -u\ --tabs=1\ --ignore-files\ --config
        set grepformat=%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\\|%l\\\|%c\\\|%m
    endif
]]
