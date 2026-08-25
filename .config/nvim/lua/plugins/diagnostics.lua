return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost" },
    config = function()
      local lint = require("lint")
      lint.linters.kube_linter = {
        name = "kube_linter",
        cmd = "kube-linter",
        args = { "lint", "--format", "json", "-" },
        stdin = true,
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local diagnostics = {}
          local ok, data = pcall(vim.json.decode, output)
          if not ok or not data.Reports then
            return diagnostics
          end
          for _, report in ipairs(data.Reports) do
            local obj = report.Object and report.Object.K8sObject
            local kind = obj and string.format("%s/%s", obj.GroupVersionKind.Kind, obj.Name) or "unknown"
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = 0,
              col = 0,
              message = string.format("[%s] %s\nRemediation: %s", report.Check, report.Diagnostic.Message, report.Remediation),
              severity = vim.diagnostic.severity.WARN,
              source = string.format("kube-linter(%s)", kind),
            })
          end
          return diagnostics
        end,
      }
      lint.linters_by_ft = {
        helm = { "kube_linter" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
  },
}
