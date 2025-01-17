-- Single file `plugins.lua` configuration
return {
    -- Lazy.nvim itself
    { "folke/lazy.nvim" },

    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "javascript",
                "typescript",
                "tsx",
                "vue",
                "c_sharp",
                "lua",
                "json",
                "yaml",
                "html",
                "css",
            }, -- Add any other languages you need
            highlight = { enable = true },
        })
        end,
    },

    -- Mason: Tool installer (LSP, linters, and formatters)
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        build = ":MasonUpdate",
        config = function()
        require("mason").setup() -- Initialize Mason without extra options

        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettierd",
                "stylua", -- lua formatter
                "csharpier", -- python formatter
                "eslint_d",
            },
        })
        end,
    },

    -- Mason-LSPConfig: Automatically configures LSP servers installed by Mason
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
        require("mason-lspconfig").setup({
            ensure_installed = { "ts_ls", "eslint", "omnisharp", "html", "cssls" },
        })
        end,
    },

    -- LSPConfig and TypeScript.nvim setup
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/typescript.nvim", -- Modern TypeScript support
            "jose-elias-alvarez/null-ls.nvim",   -- Linters and formatters
            "hrsh7th/nvim-cmp",                  -- Autocompletion plugin
        },
        config = function()
        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Setup TypeScript using typescript.nvim
        lspconfig.ts_ls.setup({
            capabilities = capabilities,
            on_attach = function(client, bufnr)
            -- TypeScript-specific keybindings or options
            require("typescript").setup({
                server = {
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                    -- TypeScript-related customizations
                    end,
                },
            })
            end,
        })

        -- ESLint LSP configuration
        lspconfig.eslint.setup({
            capabilities = capabilities,
        })

        -- OmniSharp configuration (for C#)
        lspconfig.omnisharp.setup({
            capabilities = capabilities,
            cmd = {
                "omnisharp",
                "--languageserver",
                "--hostPID",
                tostring(vim.fn.getpid())
            },
            settings = {
                RoslynExtensionsOptions = {
                    enableDecompilationSupport = false,
                    enableImportCompletion = true,
                    enableAnalyzersSupport = true,
                }
            },
            root_dir = lspconfig.util.root_pattern("*.sln")
        })

        lspconfig.html.setup({
            capabilities = capabilities,
        })

        -- Setup for CSS
        lspconfig.cssls.setup({
            capabilities = capabilities,
            settings = {
                css = { validate = true },
                scss = { validate = true },
                less = { validate = true }, -- Add if you also use LESS
            }
        })

        -- Null-ls setup for custom linters/formatters
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.prettierd, -- Prettier for formatting
                null_ls.builtins.diagnostics.eslint_d, -- Faster ESLint diagnostics
                null_ls.builtins.code_actions.eslint_d, -- ESLint code actions
                null_ls.builtins.formatting.csharpier, -- C# Formatter
            },
        })

        -- Auto-format with Null-ls on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function() vim.lsp.buf.format({ async = false }) end,
        })
        end,
    },

    -- Autocompletion plugins
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",   -- LSP completions
            "hrsh7th/cmp-buffer",     -- Buffer completions
            "hrsh7th/cmp-path",       -- Path completions
            "hrsh7th/cmp-vsnip",      -- Snippet completions
            "hrsh7th/vim-vsnip",      -- Snippet engine
        },
        config = function()
        local cmp = require("cmp")
        cmp.setup({
            snippet = {
                expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                                                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
                { name = "vsnip" },
            }),
        })
        end,
    },

    -- Fuzzy Finder (FZF-Lua)
    {
        "ibhagwan/fzf-lua",
        config = function()
        local fzf = require("fzf-lua")
        fzf.setup({}) -- Default FZF setup

        -- FZF Keybindings
        vim.keymap.set("n", "<leader>ff", function() fzf.files() end, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", function() fzf.live_grep() end, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>fb", function() fzf.buffers() end, { desc = "Find buffers" })
        vim.keymap.set("n", "<leader>fh", function() fzf.builtin() end, { desc = "FZF builtin commands" })
        end,
    },

    -- NeoTree: File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
        vim.g.neo_tree_remove_legacy_commands = 1
        require("neo-tree").setup({
            filesystem = {
                follow_current_file = true,
                use_libuv_file_watcher = true,
            },
            buffers = { follow_current_file = true },
            git_status = { follow_current_file = true },
        })

        -- Keybinding for NeoTree
        vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle NeoTree" })
        end,
    },

    -- Which-Key: Keybinding helper
    {
        "folke/which-key.nvim",
        config = function()
        require("which-key").setup({})
        end,
    },

    -- Git Integration
    { "tpope/vim-fugitive" }, -- Git commands in Neovim

    -- Colorscheme (Optional)
    {
        "morhetz/gruvbox",
        config = function()
        vim.cmd("colorscheme gruvbox")
        end,
    },
}
