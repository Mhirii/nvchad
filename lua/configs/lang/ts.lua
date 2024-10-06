local utils_lsp = require "utils.lsp"
return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "vtsls", "prettierd", "eslint-lsp" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      require("nvchad.configs.lspconfig").defaults()
      local nvlsp = require "nvchad.configs.lspconfig"
      local lspconfig = require "lspconfig"

      lspconfig["vtsls"].setup {
        on_attach = nvlsp.on_attach,
        on_init = nvlsp.on_init,
        capabilities = nvlsp.capabilities,
      }
      return {
        -- make sure mason installs the server
        servers = {
          --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
          --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
          tsserver = {
            enabled = false,
          },
          ts_ls = {
            enabled = false,
          },
          vtsls = {
            -- explicitly add default filetypes, so that we can extend
            -- them in related extras
            filetypes = {
              "javascript",
              "javascriptreact",
              "javascript.jsx",
              "typescript",
              "typescriptreact",
              "typescript.tsx",
            },
            settings = {
              complete_function_calls = true,
              vtsls = {
                enableMoveToFileCodeAction = true,
                autoUseWorkspaceTsdk = true,
                experimental = {
                  completion = {
                    enableServerSideFuzzyMatch = true,
                  },
                },
              },
              typescript = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = {
                  completeFunctionCalls = true,
                },
                inlayHints = {
                  enumMemberValues = { enabled = true },
                  functionLikeReturnTypes = { enabled = true },
                  parameterNames = { enabled = "literals" },
                  parameterTypes = { enabled = true },
                  propertyDeclarationTypes = { enabled = true },
                  variableTypes = { enabled = false },
                },
              },
            },
            keys = {
              {
                "gD",
                function()
                  local params = vim.lsp.util.make_position_params()
                  vim.lsp.execute {
                    command = "typescript.goToSourceDefinition",
                    arguments = { params.textDocument.uri, params.position },
                    open = true,
                  }
                end,
                desc = "Goto Source Definition",
              },
              {
                "gR",
                function()
                  utils_lsp.execute {
                    command = "typescript.findAllFileReferences",
                    arguments = { vim.uri_from_bufnr(0) },
                    open = true,
                  }
                end,
                desc = "File References",
              },
              {
                "<leader>co",
                utils_lsp.action["source.organizeImports"],
                desc = "Organize Imports",
              },
              {
                "<leader>cM",
                utils_lsp.action["source.addMissingImports.ts"],
                desc = "Add missing imports",
              },
              {
                "<leader>cu",
                utils_lsp.action["source.removeUnused.ts"],
                desc = "Remove unused imports",
              },
              {
                "<leader>cD",
                utils_lsp.action["source.fixAll.ts"],
                desc = "Fix all diagnostics",
              },
              {
                "<leader>cV",
                function()
                  utils_lsp.execute { command = "typescript.selectTypeScriptVersion" }
                end,
                desc = "Select TS workspace version",
              },
            },
          },
        },
        setup = {
          --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
          --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
          tsserver = function()
            -- disable tsserver
            return true
          end,
          ts_ls = function()
            -- disable tsserver
            return true
          end,
          vtsls = function(_, opts)
            utils_lsp.on_attach(function(client, buffer)
              client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
                ---@type string, string, lsp.Range
                local action, uri, range = unpack(command.arguments)

                local function move(newf)
                  client.request("workspace/executeCommand", {
                    command = command.command,
                    arguments = { action, uri, range, newf },
                  })
                end

                local fname = vim.uri_to_fname(uri)
                client.request("workspace/executeCommand", {
                  command = "typescript.tsserverRequest",
                  arguments = {
                    "getMoveToRefactoringFileSuggestions",
                    {
                      file = fname,
                      startLine = range.start.line + 1,
                      startOffset = range.start.character + 1,
                      endLine = range["end"].line + 1,
                      endOffset = range["end"].character + 1,
                    },
                  },
                }, function(_, result)
                  ---@type string[]
                  local files = result.body.files
                  table.insert(files, 1, "Enter new path...")
                  vim.ui.select(files, {
                    prompt = "Select move destination:",
                    format_item = function(f)
                      return vim.fn.fnamemodify(f, ":~:.")
                    end,
                  }, function(f)
                    if f and f:find "^Enter new path" then
                      vim.ui.input({
                        prompt = "Enter move destination:",
                        default = vim.fn.fnamemodify(fname, ":h") .. "/",
                        completion = "file",
                      }, function(newf)
                        return newf and move(newf)
                      end)
                    elseif f then
                      move(f)
                    end
                  end)
                end)
              end
            end, "vtsls")
            -- copy typescript settings to javascript
            opts.settings.javascript =
              vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
          end,
        },
      }
    end,
  },
}