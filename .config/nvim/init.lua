-- netrw VOR allem anderen deaktivieren
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Leader-Taste auf Leertaste (muss vor den Keymaps stehen)
vim.g.mapleader = " "

-- für korrekte Farben in bufferline nötig
vim.opt.termguicolors = true

vim.cmd([[
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath=&runtimepath
    source ~/.vimrc
    call plug#begin()
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'akinsho/bufferline.nvim'
    Plug 'famiu/bufdelete.nvim'
    Plug 'tpope/vim-fugitive'    
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " LSP
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'neovim/nvim-lspconfig'

    " Completion
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'
    call plug#end()
]])

-- nvim-tree konfigurieren (ein einziger setup-Aufruf)
require("nvim-tree").setup({
  sync_root_with_cwd = true,
  view = {
    width = 40,
  },
  filters = {
    git_ignored = false,
    custom = { "^.git$" },
  },
    live_filter = {
    always_show_folders = false,
  },
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = true,
        git = true,
        
      },
      glyphs = {
        git = {
          unstaged  = "M",
          staged    = "A",
          unmerged  = "U",
          renamed   = "R",
          untracked = "?",
          deleted   = "D",
          ignored   = "!",
        },
        folder = {
          arrow_closed = "|",   -- zugeklappter Ordner
          arrow_open   = "-",   -- aufgeklappter Ordner
        },
      },
    },
  },
  actions = {
    change_dir = { enable = true}
  },
})

-- bufferline: ein Reiter pro Datei (Buffer), ohne Nerd-Font-Glyphen
require("bufferline").setup({
  options = {
    mode = "buffers",
    show_buffer_icons = false,         -- keine Dateityp-Icons
    show_buffer_close_icons = false,   -- keine Schließen-Glyphe pro Reiter
    show_close_icon = false,           -- keine globale Schließen-Glyphe
    separator_style = { "|", "|" },    -- ASCII-Trenner statt Glyphen
    indicator = {
      style = "underline",             -- aktiver Reiter unterstrichen statt Glyphe
    },
    offsets = {
      {
        filetype = "NvimTree",
        text = "Explorer",             -- Überschrift über dem Baum
        separator = true,
      },
    },
  },
})

local telescope = require("telescope")
telescope.setup({
  defaults = {
    file_ignore_patterns = { "%.git/", "node_modules/" },
    path_display = { "smart" },
  }
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fn", function()
  local node = require("nvim-tree.api").tree.get_node_under_cursor()
  if not node then return end
  -- Ordner -> der Pfad selbst; Datei -> deren Elternordner
  local path = (node.type == "directory")
      and node.absolute_path
      or vim.fn.fnamemodify(node.absolute_path, ":h")
  builtin.find_files({
    cwd = path,
    hidden = true,
  })
end, { desc = "Find files under tree node" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep,   { desc = "Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers,     { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags,   { desc = "Help" })


-- Mason: Installer für die Sprachserver
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "intelephense",  -- PHP
    "ts_ls",         -- JavaScript
    "html",
    "cssls",         -- CSS + SCSS
    "jsonls",
    "emmet_ls",      -- Emmet für HTML/CSS/Twig-Markup
  },
})

vim.lsp.config("intelephense", {
  root_dir = function(bufnr, on_dir)
    -- Shopware-Root erkennen: Ordner, der bin/console UND vendor/shopware enthält.
    -- Vom aktuellen File aufwärts suchen.
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local found = vim.fs.find(
      { "vendor/shopware" },
      { upward = true, path = vim.fs.dirname(fname), type = "directory" }
    )[1]
    if found then
      -- found zeigt auf .../vendor/shopware -> zwei Ebenen hoch ist der Shopware-Root
      on_dir(vim.fn.fnamemodify(found, ":h:h"))
    else
      -- Fallback: cwd
      on_dir(vim.fn.getcwd())
    end
  end,
})

-- LSP über native API (KEIN require("lspconfig"))
local capabilities = require("cmp_nvim_lsp").default_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- emmet zusätzlich in Twig aktivieren
vim.lsp.config("emmet_ls", {
  filetypes = { "html", "css", "scss", "javascript", "twig" },
})

-- Server aktivieren
vim.lsp.enable({
  "intelephense",
  "ts_ls",
  "html",
  "cssls",
  "jsonls",
  "emmet_ls",
})

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
    ["<C-n>"]     = cmp.mapping.select_next_item(),
    ["<C-p>"]     = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- LSP-Keymaps (greifen, sobald ein Server andockt)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})



-- custom keymaps:

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })    -- Baum togglen
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })  -- vorheriger Reiter
vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })  -- nächster Reiter
vim.keymap.set("n", "<leader>x", ":Bdelete<CR>", { silent = true })    -- Reiter schließen
vim.keymap.set("n", "<leader>d", ":%d<CR>", {silent = true}) -- Reiterpuffer leeren

vim.keymap.set('n', 'cd', ':NvimTreeChangeRootToNode<CR>') -- change current dir
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]]) -- exit terminal german layout
