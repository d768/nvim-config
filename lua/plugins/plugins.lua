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
            "neovim/nvim-lspconfig"
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

        require("mason-lspconfig").setup({
            ensure_installed = { "ts_ls", "eslint", "omnisharp", "html", "cssls", "volar"},
        })
        end,
    },

    -- Autocompletion
    {
        'saghen/blink.cmp',
        version = 'v0.x',
        opts = {
            keymap = { preset = 'super-tab' },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono'
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
        },
        opts_extend = { "sources.default" }
    },

    -- LSPConfig and TypeScript.nvim setup
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/typescript.nvim", -- Modern TypeScript support
            "jose-elias-alvarez/null-ls.nvim",   -- Linters and formatters
            "saghen/blink.cmp",-- Autocompletion plugin
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
        local lspconfig = require("lspconfig")
        local capabilities = require('blink.cmp').get_lsp_capabilities()

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

        lspconfig.omnisharp.setup({
          capabilities = capabilities,
          cmd = {
            "dotnet",
            "/home/sad/.local/share/nvim/mason/packages/omnisharp/libexec/OmniSharp.dll"
          },
          enable_roslyn_analysers = true,
          enable_import_completion = true,
          organize_imports_on_format = true,
          enable_decompilation_support = true,
          filetypes = { 'cs', 'vb', 'csproj', 'sln', 'slnx', 'props', 'csx', 'targets' }
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

        lspconfig.volar.setup({
            capabilities = capabilities, -- Enable autocompletion support, etc.
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }, -- Filetypes it handles
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
    -- Colorscheme (Optional)
    {
        "NTBBloodbath/doom-one.nvim",
        config = function()
        vim.cmd("colorscheme doom-one")
        end,
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    }
}
