require('lualine').setup {
  options = {
    -- icons_enabled = true,
    theme = 'gruvbox',
  },
  sections = {
    lualine_a = {
      {
        -- show full path
        'filename',
        path = 1,
      }
    }
  }
}
