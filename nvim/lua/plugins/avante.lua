return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    config = function(_, opts)
      require("avante").setup(opts)

      local Sidebar = require("avante.sidebar")

      -- Custom code snippet extraction (copied from original plugin)
      local function extract_code_snippets(content)
        local snippets = {}
        local current_snippet = {}
        local in_code_block = false
        local lang, start_line, end_line
        local explanation = ""

        for _, line in ipairs(vim.split(content, "\n")) do
          local start_line_str, end_line_str = line:match("^Replace lines: (%d+)-(%d+)")
          if start_line_str and end_line_str then
            start_line = tonumber(start_line_str)
            end_line = tonumber(end_line_str)
          end
          if line:match("^```") then
            if in_code_block then
              if start_line and end_line then
                table.insert(snippets, {
                  range = { start_line, end_line },
                  content = table.concat(current_snippet, "\n"),
                  lang = lang,
                  explanation = explanation,
                })
              end
              current_snippet = {}
              start_line, end_line = nil, nil
              explanation = ""
              in_code_block = false
            else
              lang = line:match("^```(%w+)") or "text"
              in_code_block = true
            end
          elseif in_code_block then
            table.insert(current_snippet, line)
          else
            explanation = explanation .. line .. "\n"
          end
        end
        return snippets
      end

      -- Modified apply function for direct buffer editing
      function Sidebar:apply()
        local content = table.concat(vim.api.nvim_buf_get_lines(self.code.bufnr, 0, -1, false), "\n")
        local response = self:get_content_between_separators()
        local snippets = extract_code_snippets(response)

        -- Apply changes in reverse order to prevent line number shifts
        table.sort(snippets, function(a, b)
          return a.range[1] > b.range[1]
        end)

        vim.api.nvim_buf_set_option(self.code.bufnr, "modifiable", true)
        for _, snippet in ipairs(snippets) do
          vim.api.nvim_buf_set_lines(
            self.code.bufnr,
            snippet.range[1] - 1, -- Convert to 0-based index
            snippet.range[2], -- Exclusive end
            false,
            vim.split(snippet.content, "\n")
          )
        end
        vim.api.nvim_buf_set_option(self.code.bufnr, "modifiable", false)

        -- Optional: Refresh screen and preserve cursor position
        vim.cmd("redraw | diffupdate")
      end
    end,
    opts = {
      provider = "ollama",
      windows = {
        width = 30,
      },
      vendors = {
        ollama = {
          ["local"] = true,
          endpoint = "https://api.together.xyz/v1",
          model = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint .. "/chat/completions",
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. vim.env.XAI_API_KEY,
              },
              body = {
                model = opts.model,
                messages = require("avante.providers").copilot.parse_messages(code_opts),
                max_tokens = 2048,
                stream = true,
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").copilot.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
