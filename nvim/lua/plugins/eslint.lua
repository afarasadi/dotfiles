return {
  -- Add nvim-lsp-installer plugin
  {
    "williamboman/nvim-lsp-installer",
    config = function()
      local lsp_installer = require("nvim-lsp-installer")

      -- Register a handler that will be called for all installed servers.
      -- Alternatively, you can register handlers on specific servers.
      lsp_installer.on_server_ready(function(server)
        local opts = {}

        -- Customize the options passed to the server
        if server.name == "eslint" then
          opts.on_attach = function(client, bufnr)
            -- Add your custom on_attach function here
          end
          opts.settings = {
            -- Add any additional settings for the ESLint language server here
          }
        end

        -- This setup() function is exactly the same as lspconfig's setup function.
        server:setup(opts)
      end)

      -- Ensure the ESLint server is installed
      local ensure_installed = { "eslint" }
      for _, name in pairs(ensure_installed) do
        local server_is_found, server = lsp_installer.get_server(name)
        if server_is_found and not server:is_installed() then
          print("Installing " .. name)
          server:install()
        end
      end
    end,
  },
}
