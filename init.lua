-- TODO:
-- put all autocommands in a group so they don't get re-added on re-source
-- do cooler stuff with mini.pick

-- apparently I have to put this before the package manager
vim.g.mapleader = " "

-- strangely enough this contains what shell I'm using - huh
-- TODO: check if fish exists and use it if so
if vim.env.STARSHIP_SHELL then
	vim.opt.shell = vim.env.STARSHIP_SHELL
end

vim.opt.autowrite = true
vim.opt.autowriteall = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 8
vim.opt.shiftwidth = 0 -- indent is just the length of one tab
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.cindent = true
vim.opt.cinoptions:append("l1,L0,=0,Ps,(s,m1")

vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos"

vim.opt.breakindent = true
vim.opt.breakindentopt = "list:-1"
vim.opt.linebreak = true
vim.opt.showbreak = "+++ "

vim.opt.scrolloff = 10
vim.opt.colorcolumn = "81"
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.infercase = true

vim.opt.pumheight = 5

vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 99
vim.g.markdown_folding = 1

vim.opt.cursorline = true

vim.opt.cmdheight = 1

vim.opt.fixeol = false

vim.opt.nrformats:append("alpha")

vim.opt.complete:append("i,d,f")
vim.opt.completeopt = "menuone,fuzzy,preview"

vim.opt.virtualedit = "block"

vim.opt.wrap = false

vim.opt.listchars = "tab:> ,extends:…,precedes:…,nbsp:␣" -- Define which helper symbols to show
vim.opt.list = true -- Show some helper symbols

vim.opt.switchbuf = "useopen,usetab"

vim.opt.guifont = "Maple Mono NF"

vim.filetype.add({
	extension = {
		mdpp = "markdown",
		mdx = "markdown.mdx",
		vs = "glsl",
		fs = "glsl",
		vert = "glsl",
		frag = "glsl",
		m = "objc",
	},
})

local make_keymap = vim.keymap.set
local map_toggle = function(lhs, rhs, desc, other_opts)
	local opts = other_opts and other_opts or {}
	if desc then
		opts.desc = desc
	end
	make_keymap("n", [[\]] .. lhs, rhs, opts)
end
local function in_cmdwin()
	return vim.fn.getcmdwintype() ~= ""
end

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- early because other plugins depend on these
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- TODO: remove when everything supports devicons
MiniIcons.tweak_lsp_kind() -- TODO: remove when everything supports devicons
require("mini.extra").setup()

require("mini.align").setup()
require("mini.bufremove").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup()
require("mini.move").setup()
require("mini.splitjoin").setup()
require("mini.statusline").setup()
require("mini.tabline").setup()

require("mini.jump").setup()

local miniclue = require("mini.clue")
miniclue.setup({
	window = {
		delay = 0,
		config = { width = "auto" },
	},
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },

		-- bracketed
		{ mode = "n", keys = "]" },
		{ mode = "n", keys = "[" },

		-- Backslash triggers
		{ mode = "n", keys = "\\" },
		{ mode = "x", keys = "\\" },
	},

	clues = {
		{ mode = "n", keys = "]b", postkeys = "]" },
		{ mode = "n", keys = "[b", postkeys = "[" },

		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows({
			submode_move = true,
			submode_resize = true,
		}),
		miniclue.gen_clues.z(),
	},
})

require("mini.operators").setup({ replace = { prefix = "gz" } })

require("mini.trailspace").setup()
make_keymap("n", "<BS>", function()
	MiniTrailspace.trim()
	MiniTrailspace.trim_last_lines()
end, { desc = "Trim whitespace" })

local hipatterns = require("mini.hipatterns")
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup({
	highlighters = {
		todo = hi_words(
			{ "TODO", "REVIEW", "INCOMPLETE", "CLEANUP" },
			"MiniHipatternsTodo"
		),
		fixme = hi_words(
			{ "FIXME", "BUG", "ROBUSTNESS", "CRASH", "URGENT" },
			"MiniHipatternsFixme"
		),
		note = hi_words({ "NOTE", "INFO", "IMPORTANT" }, "MiniHipatternsNote"),
		hack = hi_words({ "HACK", "XXX", "TEMP", "DELETEME" }, "MiniHipatternsHack"),

		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
	delay = {
		text_change = 0,
		scroll = 0,
	},
})

require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring()
		end,
	},
	mappings = { textobject = "ic" },
})

require("mini.surround").setup({
	respect_selection_type = true,
	n_lines = 200,
})

require("mini.notify").setup({
	lsp_progress = {
		-- enable = false,
		duration_last = 350,
	},
})

require("mini.pick").setup({
	mappings = {
		refine = "<C-;>",
		refine_marked = "<M-;>",
	},
})
local builtin = MiniPick.builtin
local extra_pickers = MiniExtra.pickers

make_keymap("n", "<leader>ff", builtin.files, { desc = "Find files" })
make_keymap("n", "<leader>fh", builtin.help, { desc = "Find help" })
make_keymap("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })

-- TODO: make cword maps use word highlighted by visual if applicable
-- TODO: leader-8 find cword in the current buffer
make_keymap(
	"n",
	"<leader>/",
	extra_pickers.buf_lines,
	{ desc = "Find line(s) in buffer" }
)
-- make_keymap( 'n', '<leader>8', '<Cmd>Pick buf_lines prompt="<cword>"<CR>' )
-- TODO: ugrep_live (fuzzy finding + --and patterns for each word)
make_keymap("n", "<leader>?", builtin.grep_live, { desc = "Live project grep" })
make_keymap(
	"n",
	"<leader>*",
	'<Cmd>Pick grep pattern="<cword>"<CR>',
	{ desc = "Grep for word under cursor" }
)

make_keymap(
	"n",
	"<leader>fc",
	extra_pickers.commands,
	{ desc = "Find commands" }
)
make_keymap("n", "<leader>fk", extra_pickers.keymaps, { desc = "Find keymaps" })
make_keymap(
	"n",
	"<leader>fd",
	extra_pickers.diagnostic,
	{ desc = "Find diagnostics" }
)
make_keymap("n", "<leader>fo", extra_pickers.options, { desc = "Find options" })
make_keymap(
	"n",
	"<leader>td",
	'<Cmd>Pick hipatterns highlighters={"todo" "fixme" "hack"}<CR>',
	{ desc = "Find todos" }
)

make_keymap("n", "<leader>fq", function()
	extra_pickers.list({ scope = "quickfix" })
end, { desc = "Find quickfix list" })
make_keymap(
	"n",
	"<leader>fv",
	extra_pickers.visit_paths,
	{ desc = "Find visit files" }
)
make_keymap(
	"n",
	"<leader>fl",
	extra_pickers.visit_labels,
	{ desc = "Find visit labels" }
)

require("mini.visits").setup()
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local currentDir = vim.fn.getcwd()
		local bufDir = vim.fn.fnamemodify(args.file, ":p:h")
		if not vim.startswith(bufDir, currentDir) then
			vim.b.minivisits_disable = true
		end
	end,
})
make_keymap(
	"n",
	"<leader>vv",
	MiniVisits.select_path,
	{ desc = "Select visit file" }
)
make_keymap(
	"n",
	"<leader>vl",
	MiniVisits.select_label,
	{ desc = "Select visit path" }
)
make_keymap(
	"n",
	"<leader>va",
	MiniVisits.add_label,
	{ desc = "Add visit label" }
)
make_keymap(
	"n",
	"<leader>vd",
	MiniVisits.remove_label,
	{ desc = "Remove visit label" }
)

local ai = require("mini.ai")
local extra_ai_spec = MiniExtra.gen_ai_spec
ai.setup({
	custom_textobjects = {
		j = extra_ai_spec.line(),
		d = extra_ai_spec.number(),
		g = extra_ai_spec.buffer(),
		e = extra_ai_spec.diagnostic(),
	},
})

require("mini.files").setup({
	windows = {
		max_number = 2,
	},
})
local open = MiniFiles.open
make_keymap("n", "<leader>fe", open, { desc = "File explorer in PWD" })
make_keymap("n", "<leader>fi", function()
	local buf = vim.api.nvim_buf_get_name(0)

	local file = io.open(buf) and buf or vim.fs.dirname(buf)

	open(file)
end, { desc = "File explorer in dir of current file" })

require("mini.misc").setup()
MiniMisc.setup_restore_cursor()
make_keymap(
	"n",
	"<leader>z",
	MiniMisc.zoom,
	{ desc = "Maximize current window" }
)

require("mini.sessions").setup()
make_keymap("n", "<leader>ss", function()
	local session = #vim.v.this_session == 0
			and vim.fn.input({
				prompt = "Session name: ",
				default = MiniSessions.config.file,
				completion = "file",
			})
		or nil

	if session then
		if session == "" then
			return
		end
		if not vim.endswith(session, ".vim") then
			session = session .. ".vim"
		end
	end

	MiniSessions.write(session)
end, { desc = "Save session" })

local function sessionaction(action)
	local exists = false
	for _, _ in pairs(MiniSessions.detected) do
		exists = true
		break
	end

	if not exists then
		print("No sessions")
		return
	end

	MiniSessions.select(action)
end

make_keymap("n", "<leader>sf", function()
	sessionaction("read")
end, { desc = "Open session" })
make_keymap("n", "<leader>sd", function()
	sessionaction("delete")
end, { desc = "Delete session" })
make_keymap("n", "<leader>sw", function()
	sessionaction("write")
end, { desc = "Save session" })

local starter = require("mini.starter")
starter.setup({
	evaluate_single = true,
	items = {
		starter.sections.sessions(),
		starter.sections.recent_files(4, true, false),
		starter.sections.builtin_actions(),
	},
})

add("ludovicchabant/vim-gutentags")

add("tpope/vim-dispatch")
add("tpope/vim-abolish")
add("tpope/vim-fugitive")
add("tpope/vim-rhubarb")
add("junegunn/gv.vim")

add("lewis6991/gitsigns.nvim")
local gs = require("gitsigns")
local gs_opts = {
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 0,
	},
}
gs.setup(gs_opts)

make_keymap(
	{ "o", "x" },
	"ih",
	":<C-U>Gitsigns select_hunk<CR>",
	{ desc = "Select git hunk" }
)

make_keymap(
	{ "n" },
	"<leader>gp",
	gs.preview_hunk_inline,
	{ desc = "Preview hunk" }
)

make_keymap({ "n" }, "gh", gs.stage_hunk, { desc = "Stage hunk" })
make_keymap({ "v" }, "gh", function()
	gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage hunk" })
make_keymap(
	{ "n" },
	"<leader>gh",
	gs.undo_stage_hunk,
	{ desc = "Undo stage hunk" }
)

make_keymap({ "n" }, "gH", gs.reset_hunk, { desc = "Reset hunk" })
make_keymap({ "v" }, "gH", function()
	gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset hunk" })
make_keymap({ "n" }, "<leader>gH", gs.reset_buffer, { desc = "Reset buffer" })

make_keymap({ "n" }, "<leader>gb", function()
	gs.blame_line({ full = true })
end, { desc = "Blame line" })

local gitsigns_toggle_state = gs_opts.signs or true
local extra_toggle_state = false
local function signs_toggle(switch, extra)
	gitsigns_toggle_state = switch or not gitsigns_toggle_state
	gs.toggle_current_line_blame(gitsigns_toggle_state)
	gs.toggle_signs(gitsigns_toggle_state)
	gs.toggle_numhl(gitsigns_toggle_state)

	extra_toggle_state = extra and not extra_toggle_state or false
	gs.toggle_deleted(extra_toggle_state)
	gs.toggle_linehl(extra_toggle_state)
	gs.toggle_word_diff(extra_toggle_state)

	if not extra then
		print((gitsigns_toggle_state and "   " or "no ") .. "git gutter")
	else
		print((extra_toggle_state and "   " or "no ") .. "git overlay")
	end
end
map_toggle("g", signs_toggle, "Toggle git gutter")
map_toggle("G", function()
	signs_toggle(true, true)
end, "Toggle git overlay")

make_keymap("", "[h", function()
	gs.nav_hunk("prev", { target = "all" })
end, { desc = "Go to next hunk" })
make_keymap("", "]h", function()
	gs.nav_hunk("next", { target = "all" })
end, { desc = "Go to prev hunk" })

vim.g.scratchpad_autostart = 0
vim.g.scratchpad_location = vim.fn.stdpath("data") .. "/scratchpad"
add("FraserLee/ScratchPad")
make_keymap("n", "S", require("scratchpad").invoke, { desc = "Scratchpad" })

add("chomosuke/typst-preview.nvim")
do
	local tinymist = vim.fn.exepath("tinymist")
	local websocat = vim.fn.exepath("websocat")
	require("typst-preview").setup({
		dependencies_bin = {
			tinymist = #tinymist > 0 and tinymist or nil,
			websocat = #websocat > 0 and websocat or nil,
		},
	})
end

add("brianhuster/live-preview.nvim")

add("hat0uma/csvview.nvim")
require("csvview").setup()

add("stevearc/dressing.nvim")

require("dressing").setup({
	input = {
		insert_only = false,
		start_in_insert = false,
	},
})

add({
	source = "nvim-treesitter/nvim-treesitter",
	checkout = "main",
	hooks = {
		post_checkout = function()
			require("nvim-treesitter").update()
		end,
	},
})
do
	local treesitter = require("nvim-treesitter")
	treesitter.install({
		"asm",
		"bash",
		"c",
		"cpp",
		"css",
		"csv",
		"diff",
		"dockerfile",
		"fish",
		"git_config",
		"git_rebase",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"go",
		"gomod",
		"gosum",
		"gowork",
		"html",
		"javascript",
		"jsdoc",
		"json",
		"json5",
		"just",
		"lua",
		"luadoc",
		"make",
		"markdown",
		"markdown_inline",
		"odin",
		"printf",
		"python",
		"regex",
		"requirements",
		"rust",
		"scss",
		"todotxt",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	})

	vim.api.nvim_create_autocmd("Filetype", {
		pattern = "*",
		callback = function(ev)
			-- TODO: if longest line in buffer is too long kill
			if vim.api.nvim_buf_line_count(ev.buf) < 4096 then
				local ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
				if ok and parser then
					vim.treesitter.start()
					-- vim.bo[ev.buf].syntax = 'ON'
				end
			end
		end,
	})
end

vim.g.skip_ts_context_commentstring_module = true
add("JoosepAlviste/nvim-ts-context-commentstring")
require("ts_context_commentstring").setup({
	enable_autocmd = false,
	languages = {
		c = "// %s",
		cpp = "// %s",
		wgsl = "// %s",
		just = "# %s",
	},
})

add("HiPhish/rainbow-delimiters.nvim")

add("nvim-treesitter/nvim-treesitter-context")
require("treesitter-context").setup({
	multiline_threshold = 4,
	trim_scope = "inner",
	mode = "topline",
})

vim.g.gruvbox_material_foreground = "original"
vim.g.gruvbox_material_background = "hard"
add("sainnhe/gruvbox-material")

vim.g.material_style = "deep ocean"
add("marko-cerovac/material.nvim")
require("material").setup({
	plugins = {
		"indent-blankline",
		"mini",
		"rainbow-delimiters",
	},
})

add("folke/tokyonight.nvim")
require("tokyonight").setup({
	style = "night",
})

add("lukas-reineke/indent-blankline.nvim")
require("ibl").setup({ scope = { enabled = false } })

vim.g.VM_maps = {
	["Add Cursor Down"] = "<C-j>",
	["Add Cursor Up"] = "<C-k>",
}
add("mg979/vim-visual-multi")

-- highlight cursor after large jump
add("rainbowhxch/beacon.nvim")

-- fast j and k YEAH BUDDY
-- holding j, k, w, b, W, B, etc goes fast after a while
add("rainbowhxch/accelerated-jk.nvim")
require("accelerated-jk").setup({
	acceleration_motions = { "w", "b", "W", "B" },
})

-- jai syntax-highlighting + folds + whatever
vim.g.jai_compiler = "jai"
add("beaumccartney/jai.vim")

add("kevinhwang91/nvim-bqf")

add("stevearc/conform.nvim")
local conform = require("conform")
local prettier_spec = { "prettierd", "prettier", stop_after_first = true }
conform.setup({
	formatters_by_ft = {
		css = prettier_spec,
		go = { "gofmt" }, -- TODO: goimports
		html = prettier_spec,
		javascript = prettier_spec,
		javascriptreact = prettier_spec,
		json = prettier_spec,
		lua = { "stylua" },
		python = { "ruff_format" },
		rust = { "rustfmt" },
		typescript = prettier_spec,
		typescriptreact = prettier_spec,
		zig = { "zigfmt" },
	},
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(conform.formatters_by_ft),
	-- group = vim.api.nvim_create_augroup('conform_formatexpr', { clear = true }),
	callback = function()
		vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
})
make_keymap("n", "<leader>F", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

add("neovim/nvim-lspconfig")

add("folke/lazydev.nvim")
require("lazydev").setup()

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function makebufopts(desc)
			return { buffer = ev.buf, desc = desc }
		end
		local lsp = vim.lsp
		local lspbuf = lsp.buf
		local function picklsp(scope)
			return function()
				MiniExtra.pickers.lsp({ scope = scope })
			end
		end

		make_keymap(
			"n",
			"<leader>gD",
			lspbuf.declaration,
			makebufopts("Goto declaration")
		)

		-- REVIEW: map without leader
		make_keymap(
			"n",
			"<leader>gt",
			lspbuf.type_definition,
			makebufopts("Goto type definition")
		)
		make_keymap(
			"n",
			"<leader>ci",
			lspbuf.incoming_calls,
			makebufopts("Incoming calls")
		)
		make_keymap(
			"n",
			"<leader>co",
			lspbuf.outgoing_calls,
			makebufopts("Outgoing calls")
		)

		local inlay_hint = lsp.inlay_hint
		map_toggle("H", function()
			local enabled = inlay_hint.is_enabled({ bufnr = ev.buf })
			local new = not enabled
			inlay_hint.enable(new, { bufnr = ev.buf })

			print((new and "   " or "no ") .. "inlay hints")
		end, "Toggle inlay hints", { buffer = ev.buf })

		local diagnostic = vim.diagnostic
		diagnostic.enable(false, { bufnr = ev.buf })

		make_keymap(
			"n",
			"<leader>bd",
			diagnostic.setloclist,
			makebufopts("Diagnostic loclist")
		)
	end,
})
vim.lsp.enable({
	"bashls",
	"basedpyright",
	"cssls",
	"eslint",
	"gopls",
	"html",
	"jsonls",
	"ltex_plus",
	"lua_ls",
	"tinymist",
	"ts_ls",
	"yamlls",
})

-- credit: fraser and https://github.com/echasnovski/mini.basics/blob/c31a4725710db9733e8a8edb420f51fd617d72a3/lua/mini/basics.lua#L600-L606
make_keymap("n", "<C-z>", "[s1z=", { desc = "Correct latest misspelled word" })
make_keymap(
	"i",
	"<C-z>",
	"<C-g>u<Esc>[s1z=`]a<C-g>u",
	{ desc = "Correct latest misspelled word" }
)

make_keymap("", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
make_keymap("", "<C-u>", "<C-u>zz", { desc = "Scroll up" })

make_keymap("n", "]w", "<Cmd>wincmd w<CR>", { desc = "Next window" })
make_keymap("n", "[w", "<Cmd>wincmd W<CR>", { desc = "Previous window" })
make_keymap("n", "]W", "<Cmd>wincmd b<CR>", { desc = "Bottom right window" })
make_keymap("n", "[W", "<Cmd>wincmd t<CR>", { desc = "Top left window" })

-- fraser again goddamn
make_keymap("n", "<ESC>", function()
	vim.cmd.nohlsearch()
	MiniJump.stop_jumping()

	if in_cmdwin() then
		vim.cmd.close()
	else
		vim.cmd.cclose()
		vim.cmd.lclose()
		vim.cmd.pclose()
	end
end, { desc = "Clear all windows and highlighting state" })
make_keymap({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
make_keymap({ "n", "x" }, "gY", '"+y$', { desc = "Copy to end of line to system clipboard" })
make_keymap("n", "gp", '"+p', { desc = "Paste from system clipboard" })
make_keymap("n", "gP", '"+P', { desc = "Paste from system clipboard" })
-- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
make_keymap("x", "gp", '"+P', { desc = "Paste from system clipboard" })

make_keymap("n", "gV", '"`[" . strpart(getregtype(), 0, 1) . "`]"', {
	expr = true,
	replace_keycodes = false,
	desc = "Visually select changed text",
})
make_keymap(
	"x",
	"g/",
	"<esc>/\\%V",
	{ silent = false, desc = "Search inside visual selection" }
)

map_toggle(
	"c",
	"<Cmd>setlocal cursorline! cursorline?<CR>",
	"Toggle 'cursorline'"
)
map_toggle(
	"C",
	"<Cmd>setlocal cursorcolumn! cursorcolumn?<CR>",
	"Toggle 'cursorcolumn'"
)
map_toggle("d", function()
	local toggle_state = not vim.diagnostic.is_enabled()
	vim.diagnostic.enable(toggle_state, { bufnr = 0 })

	print((toggle_state and "   " or "no ") .. "diagnostics")
end, "Toggle diagnostics")
map_toggle(
	"h",
	'<Cmd>let v:hlsearch = 1 - v:hlsearch | echo (v:hlsearch ? "  " : "no") . "hlsearch"<CR>',
	"Toggle search highlight"
)
map_toggle(
	"i",
	"<Cmd>setlocal ignorecase! ignorecase?<CR>",
	"Toggle 'ignorecase'"
)
map_toggle("l", "<Cmd>setlocal list! list?<CR>", "Toggle 'list'")
map_toggle("s", "<Cmd>setlocal spell! spell?<CR>", "Toggle 'spell'")
map_toggle("w", "<Cmd>setlocal wrap! wrap?<CR>", "Toggle 'wrap'")

make_keymap(
	"n",
	"X",
	MiniBufremove.delete,
	{ desc = "Remove buffer - keep window layout" }
)

make_keymap(
	"n",
	"<leader>x",
	MiniBufremove.wipeout,
	{ desc = "Remove buffer - keep window layout" }
)

-- jk fixes (thanks yet again fraser)
-- TODO(beau): if there's a count, normal j/k
make_keymap("n", "j", "<Plug>(accelerated_jk_gj)")
make_keymap("n", "k", "<Plug>(accelerated_jk_gk)")

make_keymap("v", "j", "gj")
make_keymap("v", "k", "gk")

---------------------------------------------------------------------------
-- write centered line - 80 character line with text in the middle and dashes
-- padding it
vim.cmd([[
	filetype plugin indent on

	autocmd TextYankPost * silent! lua vim.hl.on_yank({ timeout=100 })

	autocmd Filetype * setlocal formatoptions+=jcqrno formatoptions-=t

	autocmd FileType html,css,scss,json,jsonc,xml,javascript,javascriptreact,typescript,typescriptreact,astro,yaml setlocal nocindent expandtab tabstop=2 foldmethod=expr foldexpr=nvim_treesitter#foldexpr()

	autocmd Filetype text,markdown,gitcommit setlocal spell autoindent comments-=fb:* comments-=fb:- comments-=fb:+
	autocmd BufEnter * lua pcall(require'mini.misc'.use_nested_comments)

	autocmd FileType DressingInput,gitcommit let b:minivisits_disable = v:true | let b:minitrailspace_disable = v:true

	autocmd FileType odin setlocal smartindent | compiler odin

	autocmd FileType jai compiler jai

	autocmd FileType gitconfig,go setlocal noexpandtab tabstop=8

	autocmd FileType dosbatch setlocal commentstring=::\ %s

	" colorscheme gruvbox-material
	" colorscheme material
	colorscheme tokyonight-night

	if !exists("syntax_on")
		syntax enable
	endif
]])

-- TODO(beau): autocommand to source this file every time its saved if in the same directory
if vim.uv.fs_stat("nvim-local.lua") then
	dofile("nvim-local.lua")
end
