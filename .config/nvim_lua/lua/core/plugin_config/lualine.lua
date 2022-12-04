require('lualine').setup {
  options = {
    -- icons_enabled = true,
    --theme = 'gruvbox',
    theme = 'jellybeans',
  },
  sections = {
    lualine_a = {
      {
        -- show full path
        'filename',
        path = 1,
      }
    }
  },
--   winbar = {
--     lualine_a = {
--       'buffers',
--     }
--   }
}
