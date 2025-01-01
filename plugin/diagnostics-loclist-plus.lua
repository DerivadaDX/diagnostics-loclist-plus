vim.api.nvim_create_user_command('ToggleLoclist', function()
  require('diagnostics-loclist-plus').toggle_loclist()
end, {})

