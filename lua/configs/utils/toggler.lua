return {
  "nguyenvukhang/nvim-toggler",
  event = "VeryLazy",
  config = function()
    require("nvim-toggler").setup {
      inverses = {
        ["disable"] = "enable",
      },
    }
  end,
}
