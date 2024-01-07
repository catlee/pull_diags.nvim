-- textDocument/diagnostic support until 0.10.0 is released
local vim = vim
local log = require("vim.lsp.log")

local _timers = {}
local function setup_diagnostics(client, buffer, opts)
  local diagnostic_handler = function()
    local params = vim.lsp.util.make_text_document_params(buffer)
    client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
      if err then
        local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
        log.error(err_msg)
      end
      if not result then
        return
      end
      vim.lsp.diagnostic.on_publish_diagnostics(
        nil,
        vim.tbl_extend("keep", params, { diagnostics = result.items }),
        { client_id = client.id },
        {}
      )
    end)
  end

  diagnostic_handler() -- to request diagnostics on buffer when first attaching

  local timeout = opts.timeout or 200

  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
      _timers[buffer] = vim.fn.timer_start(timeout, diagnostic_handler)
    end,
    on_detach = function()
      if _timers[buffer] then
        vim.fn.timer_stop(_timers[buffer])
      end
    end,
  })
end

local M = {}

function M.setup(opts)
  if require("vim.lsp.diagnostic")._enable then
    -- Disable if nvim's LSP module supports enabling (0.10.0+)
    return
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- TODO: Skip if the LSP backend supports push diagnostics
      -- Bonus TODO: If the LSP backend supports both, use pull diagnostics
      if vim.tbl_get(client.server_capabilities, "diagnosticProvider") then
        setup_diagnostics(client, bufnr, opts)
      end
    end,
  })
end

return M
