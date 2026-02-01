return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "autopep8" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
      -- Tùy chỉnh format khi lưu
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
}
