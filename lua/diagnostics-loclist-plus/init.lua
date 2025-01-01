local M = {}

local HEADER_SIZE = 1
local LOCLIST_FILETYPE = 'qf'

local loclist_win_id = nil
local user_wants_visible = false

local config = {
  allowed_filetypes = {},
  diagnostic_opts = {
    open = false,
    severity = {
      min = vim.diagnostic.severity.HINT,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  update_delay = 750,
  max_diagnostics_lines = 10,
}

local function get_filetpye(win_id)
  local filetype = vim.fn.getwinvar(win_id, '&filetype')
  return filetype
end

local function is_loclist_visible()
  local win_ids = vim.api.nvim_list_wins()
  local win_filetypes = vim.tbl_map(get_filetpye, win_ids)
  local is_visible = vim.tbl_contains(win_filetypes, LOCLIST_FILETYPE)
  return is_visible
end

local function should_process_buffer(buffer)
  local buffer_filetype = vim.bo[buffer].filetype
  local is_allowed_filetype = vim.tbl_contains(config.allowed_filetypes, buffer_filetype)
  return is_allowed_filetype
end

local function update_loclist()
  vim.schedule(function()
    local current_window = vim.api.nvim_get_current_win()

    local current_buffer = vim.api.nvim_get_current_buf()
    local should_process = should_process_buffer(current_buffer)
    if not should_process then
      return
    end

    local was_visible = is_loclist_visible()

    vim.diagnostic.setloclist({
      open = config.diagnostic_opts.open,
      severity = config.diagnostic_opts.severity,
    })

    local items = vim.fn.getloclist(0, { size = true }).size
    if items == 0 and was_visible then
      loclist_win_id = nil
      vim.cmd.lclose()

      vim.notify(
        '[diagnostics-loclist]: Window closed. It will automatically appear when diagnostics are available.',
        vim.log.levels.INFO)
      return
    end

    if user_wants_visible and not was_visible then
      vim.cmd.lwindow()
    end

    if not loclist_win_id or not vim.api.nvim_win_is_valid(loclist_win_id) then
      for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.fn.getwinvar(win_id, '&filetype') == LOCLIST_FILETYPE then
          loclist_win_id = win_id
          break
        end
      end
    end

    local loclist_items = vim.fn.getloclist(0)
    table.insert(loclist_items, 1, { text = 'Total Diagnostics: ' .. items, type = 'Header' })
    vim.fn.setloclist(0, loclist_items, 'r')

    if loclist_win_id and vim.api.nvim_win_is_valid(loclist_win_id) then
      local height = math.min(items + HEADER_SIZE, config.max_diagnostics_lines)
      vim.api.nvim_win_set_height(loclist_win_id, height)
    end

    if vim.api.nvim_win_is_valid(current_window) then
      vim.api.nvim_set_current_win(current_window)
    end
  end)
end

function M.toggle_loclist()
  update_loclist()

  local was_visible = is_loclist_visible()
  user_wants_visible = not was_visible

  if user_wants_visible then
    local items = vim.fn.getloclist(0, { size = true }).size - HEADER_SIZE
    if items == 0 then
      vim.notify(
        '[diagnostics-loclist]: The window will automatically appear when diagnostics are available.',
        vim.log.levels.INFO)
      return
    end
  else
    vim.cmd.lclose()
  end
end

function M.setup(opts)
  if opts then
    config = vim.tbl_deep_extend('force', config, opts)
  end

  local timer
  vim.api.nvim_create_autocmd({
      'BufEnter',
      'CursorHold',
      'TextChanged',
      'TextChangedI',
    },
    {
      group = vim.api.nvim_create_augroup('LocationListUpdate', { clear = true }),
      callback = function()
        if timer then
          timer:stop()
        end
        timer = vim.defer_fn(update_loclist, config.update_delay)
      end,
    })
end

function M.get_config()
  local copied_config = vim.deepcopy(config)
  return copied_config
end

return M

