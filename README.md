# Diagnostics Loclist Plus for Neovim

A Neovim plugin that provides an enhanced location list for diagnostics with automatic updates and visibility controls.

## Features

- Automatically updates the location list with current buffer diagnostics
- Configurable update delay and maximum window height
- Filetype filtering support
- Header showing total diagnostic count
- Toggle command for quick access

## Installation

Using vim-plug:

```vim
Plug 'DerivadaDX/diagnostics-loclist-plus.nvim'
```

Then add to your init.vim/init.lua:

```lua
require('diagnostics-loclist-plus').setup({
    allowed_filetypes = { 'lua' },
})
```

## Usage

The plugin provides the `:ToggleLoclist` command to show/hide the diagnostics window.

## Configuration

```lua
require('diagnostics-loclist').setup({
  -- Filetypes to enable the plugin for
  allowed_filetypes = {},

  -- Diagnostic configuration
  diagnostic_opts = {
    open = false,  -- Auto-open the loclist
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.ERROR,
    },
  },

  -- Delay before updating the loclist (in milliseconds)
  update_delay = 750,

  -- Maximum number of lines to show in the loclist window
  max_diagnostics_lines = 10,
})
```

