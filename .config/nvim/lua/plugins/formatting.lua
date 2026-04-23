return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre", "InsertLeave" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "first" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      log_level = vim.log.levels.DEBUG,
      notify_on_error = false,
      lsp_format = "first",
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        else
          return {
            timeout_ms = 500,
            lsp_format = "first",
          }
        end
      end,
      formatters = {},
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports" },
        javascript = { "prettierd", stop_after_first = true },
        typescript = { "prettierd", stop_after_first = true },
        pug = { "prettierd", stop_after_first = true },
        markdown = { "prettierd", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        vue = { "prettierd", stop_after_first = true },
        graphql = { "prettierd" },
        sh = { "shfmt" },
        sql = { "pg_format" },
      },
    },
  },
}
