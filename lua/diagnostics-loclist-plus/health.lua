local M = {}

local function check_neovim_version(ok, error)
  if vim.fn.has('nvim-0.8.0') == 1 then
    ok('Neovim version >= 0.8.0')
  else
    error('Neovim version must be >= 0.8.0')
  end
end

local function check_diagnostic_capabilities(ok, error)
  if vim.diagnostic then
    ok('Diagnostic capabilities available')
  else
    error('Diagnostic module not available')
  end
end

local function check_required_modules(ok, error)
  local required_modules = {
    'vim.diagnostic',
    'vim.api',
    'vim.fn',
  }

  for _, module in ipairs(required_modules) do
    local success = pcall(function()
      local parts = vim.split(module, '.', { plain = true })
      local current = _G
      for _, part in ipairs(parts) do
        current = current[part]
        if not current then error() end
      end
    end)

    if success then
      ok(string.format('Module \'%s\' found', module))
    else
      error(string.format('Module \'%s\' not found', module))
    end
  end
end

local function check_plugin_configuration(ok, warn)
  local config_ok, config = pcall(require('diagnostics-loclist').get_config)

  if config_ok and config then
    ok('Plugin configuration loaded')
  else
    warn('Plugin not configured. Run setup() with your desired options')
  end
end

function M.check()
  local health = vim.health or require('health')
  local start = health.start or health.report_start
  local ok = health.ok or health.report_ok
  local warn = health.warn or health.report_warn
  local error = health.error or health.report_error

  start('diagnostics-loclist-plus.nvim')
  check_neovim_version(ok, error)
  check_diagnostic_capabilities(ok, error)
  check_required_modules(ok, error)
  check_plugin_configuration(ok, warn)
end

return M

