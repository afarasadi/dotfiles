return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          settings = {
            tailwindCSS = {
              classAttributes = { "style", "className", "class", "[a-zA-Z]*ClassName" },
              experimental = {
                classRegex = {
                  "tw`([^`]*)",
                  { "tw\\.style\\(([^)]*)\\)", "'([^']*)'" },
                  { "cva\\(([^)]*)\\)", '"([^"]*)"' },
                  { "cva\\(([^)]*)\\)", "'([^']*)'" },
                  { "cn\\(([^)]*)\\)", '"([^"]*)"' },
                  { "cn\\(([^)]*)\\)", "'([^']*)'" },
                },
              },
            },
          },
        },
        sourcekit = {
          on_attach = function(_, bufnr)
            local opts_keymap = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts_keymap)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_keymap)
          end,
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                features = "all",
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },

        -- DO NOT use lspconfig for jdtls
        -- jdtls = {},
      },
    },
  },

  {
    "mfussenegger/nvim-jdtls",

    ft = { "java", "kotlin" },

    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
      local jdtls = require("jdtls")

      local group = vim.api.nvim_create_augroup("Jdtls", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "java", "kotlin" },

        callback = function()
          local root_dir = require("jdtls.setup").find_root({
            "gradlew",
            "mvnw",
            "settings.gradle",
            "settings.gradle.kts",
          })

          if not root_dir then
            return
          end

          local capabilities = require("blink.cmp").get_lsp_capabilities()

          jdtls.start_or_attach({
            cmd = { "jdtls" },

            root_dir = root_dir,

            capabilities = capabilities,

            settings = {
              java = {},
            },

            init_options = {
              bundles = {},
            },
          })
        end,
      })
    end,
  },

  {
    "rizukirr/droid-nvim",
    tag = "v0.0.1-beta03",

    ft = { "kotlin", "java", "groovy", "xml" },

    opts = {
      lsp = {
        jre_path = "/Applications/Android Studio.app/Contents/jbr/Contents/Home",

        kotlin = {
          enabled = true,

          jdk_for_symbol_resolution = "/Applications/Android Studio.app/Contents/jbr/Contents/Home",
        },
      },
    },
  },
}
