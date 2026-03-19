return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
        sourcekit = {},
        -- tsserver = {
        -- vtsls = {
        --   root_dir = function(...)
        --     return require("lspconfig.util").root_pattern("tsconfig.base.json")(...)
        --   end,
        -- },
      },
      setup = {
        tailwindcss = function(_, opts)
          opts.settings = {
            tailwindCSS = {
              classAttributes = { "style", "className", "class", "[a-zA-Z]*ClassName" },
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
                  { "tw\\.style\\(([^)]*)\\)", "'([^']*)'" },
                  -- CVA function calls
                  { "cva\\(([^)]*)\\)", '"([^"]*)"' },
                  { "cva\\(([^)]*)\\)", "'([^']*)'" },
                  -- CN function calls
                  { "cn\\(([^)]*)\\)", '"([^"]*)"' },
                  { "cn\\(([^)]*)\\)", "'([^']*)'" },
                },
              },
            },
          }

          require("lspconfig")["tailwindcss"].setup(opts)
        end,
        sourcekit = function(_, opts)
          local capabilities = require("blink.cmp").get_lsp_capabilities()
          opts.capabilities = capabilities
          opts.on_attach = function(_, bufnr)
            local opts_keymap = { noremap = true, silent = true, buffer = bufnr }

            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts_keymap)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_keymap)
          end

          require("lspconfig")["sourcekit"].setup(opts)
        end,
      },
    },
  },

  -- {
  --   "laytan/tailwind-sorter.nvim",
  --   dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
  --   build = "cd formatter && npm ci && npm run build",
  --   config = function()
  --     -- Plugin specific configuration
  --     require("tailwind-sorter").setup({
  --       on_save_enabled = true, -- Disables automatic sorting on save
  --       on_save_pattern = { "*.html", "*.js", "*.jsx", "*.tsx", "*.twig", "*.hbs", "*.php", "*.heex", "*.astro" }, -- Specifies file patterns for manual sorting
  --       node_path = "node", -- Specifies the path to the node executable
  --     })
  --   end,
  -- },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    opts = function(_, opts)
      -- original LazyVim kind icon formatter
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item) -- add icons
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
}
