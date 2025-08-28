-- TODO:
-- do cooler stuff with mini.pick

local clear_augroup = vim.api.nvim_create_augroup("augroup", { clear = true })

-- apparently I have to put this before the package manager
vim.g.mapleader = " "

-- strangely enough this contains what shell I'm using - huh
-- TODO: check if fish exists and use it if so
if vim.env.STARSHIP_SHELL then
	vim.opt.shell = vim.env.STARSHIP_SHELL
end

vim.opt.autoread = true
vim.opt.autowrite = true
vim.opt.autowriteall = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.shiftwidth = 0 -- indent is just the length of one tab
vim.opt.expandtab = false
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.cinoptions:append("l1,L0,=0,Ps,(s,m1")

vim.opt.fileformat = "unix"
vim.opt.fileformats = "unix,dos"

vim.opt.breakindent = true
vim.opt.breakindentopt = "list:-1"
vim.opt.linebreak = true
vim.opt.showbreak = "+++ "

vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
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
vim.opt.pumblend = 55

vim.opt.foldmethod = "indent"
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 99
vim.g.markdown_folding = 1

vim.opt.cursorline = true

vim.opt.cmdheight = 1

vim.opt.signcolumn="yes"

vim.opt.showmode = false

vim.opt.fixeol = false

vim.opt.nrformats:append("alpha")

vim.opt.complete:append("i,d,f")
vim.opt.completeopt = "menuone,fuzzy,preview,noselect"

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
		hlsl = "hlsl",
		m = "objc",
	},
})

local function map_toggle(lhs, rhs, desc, other_opts)
	local opts = other_opts and other_opts or {}
	if desc then
		opts.desc = desc
	end
	vim.keymap.set("n", [[\]] .. lhs, rhs, opts)
end
local function remap(mode, lhs_from, lhs_to)
	local keymap = vim.fn.maparg(lhs_from, mode, false, true)
	local rhs = keymap.callback or keymap.rhs
	if rhs == nil then
		error("Could not remap from " .. lhs_from .. " to " .. lhs_to)
	end
	vim.keymap.set(mode, lhs_to, rhs, { desc = keymap.desc })
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
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

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

require("mini.operators").setup({ replace = { prefix = "gb" } })

require("mini.trailspace").setup()
vim.keymap.set("n", "<BS>", function()
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

vim.keymap.set("n", "<leader>ff", builtin.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fh", builtin.help, { desc = "Find help" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })

-- TODO: make cword maps use word highlighted by visual if applicable
-- TODO: leader-8 find cword in the current buffer
vim.keymap.set(
	"n",
	"<leader>/",
	extra_pickers.buf_lines,
	{ desc = "Find line(s) in buffer" }
)
-- vim.keymap.set( 'n', '<leader>8', '<Cmd>Pick buf_lines prompt="<cword>"<CR>' )
-- TODO: ugrep_live (fuzzy finding + --and patterns for each word)
vim.keymap.set("n", "<leader>?", builtin.grep_live, { desc = "Live project grep" })
vim.keymap.set(
	"n",
	"<leader>*",
	'<Cmd>Pick grep pattern="<cword>"<CR>',
	{ desc = "Grep for word under cursor" }
)

vim.keymap.set(
	"n",
	"<leader>fc",
	extra_pickers.commands,
	{ desc = "Find commands" }
)
vim.keymap.set("n", "<leader>fk", extra_pickers.keymaps, { desc = "Find keymaps" })
vim.keymap.set(
	"n",
	"<leader>fd",
	extra_pickers.diagnostic,
	{ desc = "Find diagnostics" }
)
vim.keymap.set("n", "<leader>fo", extra_pickers.options, { desc = "Find options" })
vim.keymap.set(
	"n",
	"<leader>td",
	'<Cmd>Pick hipatterns highlighters={"todo" "fixme" "hack"}<CR>',
	{ desc = "Find todos" }
)

vim.keymap.set("n", "<leader>fq", function()
	extra_pickers.list({ scope = "quickfix" })
end, { desc = "Find quickfix list" })
vim.keymap.set(
	"n",
	"<leader>fv",
	extra_pickers.visit_paths,
	{ desc = "Find visit files" }
)
vim.keymap.set(
	"n",
	"<leader>fl",
	extra_pickers.visit_labels,
	{ desc = "Find visit labels" }
)

require("mini.visits").setup()
vim.keymap.set(
	"n",
	"<leader>vv",
	MiniVisits.select_path,
	{ desc = "Select visit file" }
)
vim.keymap.set(
	"n",
	"<leader>vl",
	MiniVisits.select_label,
	{ desc = "Select visit path" }
)
vim.keymap.set(
	"n",
	"<leader>va",
	MiniVisits.add_label,
	{ desc = "Add visit label" }
)
vim.keymap.set(
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

require("mini.misc").setup()
MiniMisc.setup_restore_cursor()
map_toggle("z", MiniMisc.zoom, "Maximize current window")

require("mini.sessions").setup()
vim.keymap.set("n", "<leader>ss", function()
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

vim.keymap.set("n", "<leader>sf", function()
	sessionaction("read")
end, { desc = "Open session" })
vim.keymap.set("n", "<leader>sd", function()
	sessionaction("delete")
end, { desc = "Delete session" })
vim.keymap.set("n", "<leader>sw", function()
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

require("mini.diff").setup({
    view = { style = "sign" },
    mappings = { textobject = "ih" },
})
map_toggle("d", function()
    MiniDiff.toggle(0)
    print((MiniDiff.get_buf_data(0) and "   " or "no ") .. "diff gutter")
end, "Toggle diff gutter")
map_toggle("g", function()
    MiniDiff.enable(0) -- overlay doesn't work if the plugin is disabled
    MiniDiff.toggle_overlay(0)

    print((MiniDiff.get_buf_data(0).overlay and "   " or "no ") .. "diff overlay")
end, "Toggle diff overlay")

require("mini.completion").setup({
    delay = { completion = 9999, info = 0, signature = 0 },
    lsp_completion = { source_func = "completefunc" },
    window = { signature = { width = 120 } },
})

MiniDeps.add("ludovicchabant/vim-gutentags")

MiniDeps.add("tpope/vim-dispatch")
MiniDeps.add("tpope/vim-abolish")
MiniDeps.add("tpope/vim-fugitive")
MiniDeps.add("tpope/vim-rhubarb")
MiniDeps.add("junegunn/gv.vim")

vim.g.scratchpad_autostart = 0
vim.g.scratchpad_location = vim.fn.stdpath("data") .. "/scratchpad"
MiniDeps.add("FraserLee/ScratchPad")
vim.keymap.set("n", "S", require("scratchpad").invoke, { desc = "Scratchpad" })

MiniDeps.add("chomosuke/typst-preview.nvim")
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

MiniDeps.add("brianhuster/live-preview.nvim")

MiniDeps.add("hat0uma/csvview.nvim")
require("csvview").setup()

MiniDeps.add("stevearc/oil.nvim")
require("oil").setup({
	columns = {
		"icon",
		"permissions",
		"size",
		"mtime",
	},
	skip_confirm_for_simple_edits = true,
	watch_for_changes = true,
	view_options = {
		show_hidden = true,
	},
	keymaps = {
		["gx"        ] = false,
		["gX"        ] = "actions.open_external",
		["gs"        ] = false,
		["<leader>gs"] = { "actions.change_sort", mode = "n" },
		["<C-c>"     ] = false,
		["q"         ] = { "actions.close", mode = "n" },
	},
	cleanup_delay_ms = 0,
})
vim.keymap.set('n', '-', vim.cmd.Oil, { desc = "Open parent directory" })

MiniDeps.add("stevearc/dressing.nvim")

require("dressing").setup({
	input = {
		insert_only = false,
		start_in_insert = false,
	},
})

MiniDeps.add({
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
		"hlsl",
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
		"objc",
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
		"typst",
		"vim",
		"vimdoc",
		"yaml",
	})

	vim.api.nvim_create_autocmd("Filetype", {
		pattern  = "*",
		group    = clear_augroup,
		callback = function(ev)
			-- TODO: if longest line in buffer is too long kill
			if vim.api.nvim_buf_line_count(ev.buf) < 4096 then
				local ok, parser = pcall(vim.treesitter.get_parser, ev.buf)
				if ok and parser then
					vim.treesitter.start(ev.buf)
					-- vim.bo[ev.buf].syntax = 'ON'
				end
			end
		end,
	})
end

MiniDeps.add("HiPhish/rainbow-delimiters.nvim")

MiniDeps.add("nvim-treesitter/nvim-treesitter-context")
require("treesitter-context").setup({
	multiline_threshold = 4,
	trim_scope = "inner",
	mode = "topline",
})

vim.g.gruvbox_material_foreground = "original"
vim.g.gruvbox_material_background = "hard"
MiniDeps.add("sainnhe/gruvbox-material")

vim.g.material_style = "deep ocean"
MiniDeps.add("marko-cerovac/material.nvim")
require("material").setup({
	plugins = {
		"indent-blankline",
		"mini",
		"rainbow-delimiters",
	},
})

MiniDeps.add("folke/tokyonight.nvim")
require("tokyonight").setup({
	style = "night",
})

MiniDeps.add("lukas-reineke/indent-blankline.nvim")
require("ibl").setup({ scope = { enabled = false } })

vim.g.VM_maps = {
	["Add Cursor Down"] = "<C-j>",
	["Add Cursor Up"] = "<C-k>",
}
MiniDeps.add("mg979/vim-visual-multi")

-- highlight cursor after large jump
MiniDeps.add("rainbowhxch/beacon.nvim")

-- fast j and k YEAH BUDDY
-- holding j, k, w, b, W, B, etc goes fast after a while
MiniDeps.add("rainbowhxch/accelerated-jk.nvim")
require("accelerated-jk").setup({
	acceleration_motions = { "w", "b", "W", "B" },
})

-- jai syntax-highlighting + folds + whatever
vim.g.jai_compiler = "jai"
MiniDeps.add("beaumccartney/jai.vim")

MiniDeps.add("kevinhwang91/nvim-bqf")

MiniDeps.add("mfussenegger/nvim-lint")
do
	local lint = require("lint")
	lint.linters_by_ft = {
		c = { "cppcheck" },
		cpp = { "cppcheck" },
		fish = { "fish" },
		-- REVIEW: directx shader compiler?
	}
	vim.api.nvim_create_autocmd("BufWritePost", {
		callback = function() lint.try_lint() end,
		group = clear_augroup,
	})
end

MiniDeps.add("stevearc/conform.nvim")
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
		markdown = prettier_spec,
		python = { "ruff_format" },
		rust = { "rustfmt" },
		typescript = prettier_spec,
		typescriptreact = prettier_spec,
		yaml = prettier_spec,
		zig = { "zigfmt" },
	},
})
vim.api.nvim_create_autocmd("FileType", {
	pattern  = vim.tbl_keys(conform.formatters_by_ft),
	group    = clear_augroup,
	callback = function()
		vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
})

MiniDeps.add("neovim/nvim-lspconfig")

MiniDeps.add("folke/lazydev.nvim")
require("lazydev").setup()

MiniDeps.add({
	source = "Julian/lean.nvim",
	depends = {
		"neovim/nvim-lspconfig",
		"nvim-lua/plenary.nvim",
	},
})
require("lean").setup({ mappings = true })
vim.api.nvim_create_autocmd("VimResized", {
	callback = require("lean.infoview").reposition,
	group = clear_augroup,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group    = clear_augroup,
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

		-- REVIEW: map without leader
		local lspmaps = {
			["textDocument/declaration"] = {
				lhs  = "<leader>gD",
				rhs  = vim.lsp.buf.declaration,
				desc = "Goto declaration",
			},
			["textDocument/typeDefinition"] = {
				lhs  = "<leader>gt",
				rhs  = vim.lsp.buf.type_definition,
				desc = "Goto type definition",
			},
			["callHierarchy/incomingCalls"] = {
				lhs  = "<leader>ci",
				rhs  = vim.lsp.buf.incoming_calls,
				desc = "Incoming calls",
			},
			["callHierarchy/outgoingCalls"] = {
				lhs  = "<leader>co",
				rhs  = vim.lsp.buf.outgoing_calls,
				desc = "Outgoing calls",
			},
		}
		for method, mapopts in pairs(lspmaps) do
			if client:supports_method(method) then
				vim.keymap.set(
					"n",
					mapopts.lhs,
					mapopts.rhs,
					{ buffer = ev.buf, desc = mapopts.desc }
				)
			end
		end

		if client:supports_method("textDocument/inlayHint") then
			map_toggle("H", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
				local new = not enabled
				vim.lsp.inlay_hint.enable(new, { bufnr = ev.buf })

				print((new and "   " or "no ") .. "inlay hints")
			end, "Toggle inlay hints", { buffer = ev.buf })
		end
	end,
})

vim.lsp.config("tinymist", {
	settings = { formatterMode = "typstyle" },
})
vim.lsp.enable({
	"basedpyright",
	"bashls",
	"cssls",
	"gopls",
	"html",
	"jsonls",
	"ltex_plus",
	"lua_ls",
	"tinymist",
	"ts_ls",
	"yamlls",
})

vim.keymap.set(
	"n",
	"<leader>dl",
	vim.diagnostic.setloclist,
	{ desc = "Diagnostic location list" }
)
vim.keymap.set(
	"n",
	"<leader>da",
	vim.diagnostic.setqflist,
	{ desc = "Diagnostic quickfix list" }
)
vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = true,
	signs = true,
	update_in_insert = true,
	jump = { float = true },
})
vim.api.nvim_create_autocmd( { "BufNew", "BufNewFile", "VimEnter" }, {
	callback = function(ev)
		vim.diagnostic.enable(false, { bufnr = ev.buf })
	end,
	group = clear_augroup,
})
map_toggle("D", function()
	local toggle_state = not vim.diagnostic.is_enabled({ bufnr = 0 })
	vim.diagnostic.enable(toggle_state, { bufnr = 0 })

	print((toggle_state and "   " or "no ") .. "diagnostics")
end, "Toggle diagnostics")

-- credit: fraser and https://github.com/nvim-mini/mini.basics/blob/c31a4725710db9733e8a8edb420f51fd617d72a3/lua/mini/basics.lua#L600-L606
vim.keymap.set("n", "<C-z>", "[s1z=", { desc = "Correct latest misspelled word" })
vim.keymap.set(
	"i",
	"<C-z>",
	"<C-g>u<Esc>[s1z=`]a<C-g>u",
	{ desc = "Correct latest misspelled word" }
)

vim.keymap.set("", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("", "<C-u>", "<C-u>zz", { desc = "Scroll up" })

vim.keymap.set("n", "]w", "<Cmd>wincmd w<CR>", { desc = "Next window" })
vim.keymap.set("n", "[w", "<Cmd>wincmd W<CR>", { desc = "Previous window" })
vim.keymap.set("n", "]W", "<Cmd>wincmd b<CR>", { desc = "Bottom right window" })
vim.keymap.set("n", "[W", "<Cmd>wincmd t<CR>", { desc = "Top left window" })

-- fraser again goddamn
vim.keymap.set("n", "<ESC>", function()
	vim.cmd.nohlsearch()
	MiniJump.stop_jumping()

	if in_cmdwin() then
		vim.cmd.close()
	else
		vim.cmd.cclose()
		vim.cmd.lclose()
		vim.cmd.pclose()
		vim.cmd.fclose()
		if vim.o.filetype ~= "help" then
			vim.cmd.helpclose()
		end
	end
end, { desc = "Clear all windows and highlighting state" })
vim.keymap.set({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "x" }, "gY", '"+y$', { desc = "Copy to end of line to system clipboard" })
vim.keymap.set("n", "gp", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("n", "gP", '"+P', { desc = "Paste from system clipboard" })
-- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
vim.keymap.set("x", "gp", '"+P', { desc = "Paste from system clipboard" })

vim.keymap.set("n", "gV", '"`[" . strpart(getregtype(), 0, 1) . "`]"', {
	expr = true,
	replace_keycodes = false,
	desc = "Visually select changed text",
})
vim.keymap.set(
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

vim.keymap.set(
	"n",
	"X",
	MiniBufremove.delete,
	{ desc = "Remove buffer - keep window layout" }
)

vim.keymap.set(
	"n",
	"<leader>x",
	MiniBufremove.wipeout,
	{ desc = "Remove buffer - keep window layout" }
)

-- jk fixes (thanks yet again fraser)
-- TODO(beau): if there's a count, normal j/k
vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)")
vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)")

vim.keymap.set("v", "j", "gj")
vim.keymap.set("v", "k", "gk")

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "*",
	group = clear_augroup,
	callback = function()
		vim.opt_local.formatoptions:append("jcqrno")
		vim.opt_local.formatoptions:remove("t")
	end,
})
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	group = clear_augroup,
	callback = function(ev)
		MiniMisc.use_nested_comments(ev.buf)
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	group = clear_augroup,
	callback = function()
		vim.hl.on_yank({ timeout = 100 })
	end,
})
vim.api.nvim_create_autocmd("Filetype", {
	pattern = "DressingInput,gitcommit",
	group = clear_augroup,
	callback = function()
		vim.b.minivisits_disable     = true
		vim.b.minitrailspace_disable = true
	end,
})

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "text,markdown,gitcommit",
	group = clear_augroup,
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.comments:remove("fb:*")
		vim.opt_local.comments:remove("fb:-")
		vim.opt_local.comments:remove("fb:+")
	end,
})

vim.cmd.colorscheme("material")

local nvim_local_file = "nvim-local.lua"
if vim.uv.fs_stat(nvim_local_file) then
	dofile(nvim_local_file)
end
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern  = nvim_local_file,
	group    = clear_augroup,
	callback = function(ev)
		vim.cmd.source({ args = { ev.file } })
	end,
})
