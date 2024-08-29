# nvim-postit
capture post-it like notes with nvim

```lua
-- with lazy.vim
local plugins = {
  -- other plugins
  {
    "deepakjois/nvim-postit",
    dependencies = { "junegunn/fzf.vim" },
    config = function()
      require("postit").setup({
        -- You can override the default config here
        -- notes_dir = vim.fn.expand("~/my-custom-notes-dir")
      })

      vim.api.nvim_create_user_command("PostIt", function()
        require("postit").show_notes()
      end, {})
    end,
  }
}
```