-- lua/pico8_connect/init.lua
local M = {}

M._carts_dir = (vim.loop.os_homedir() or "~") .. "/.lexaloffle/pico-8/carts"
M._last_cart_buf = nil

local function joinpath(...)
  return (vim.fs and vim.fs.joinpath and vim.fs.joinpath(...))
      or table.concat({ ... }, "/")
end

local function list_p8(dir)
  local out = {}
  local fd = vim.loop.fs_scandir(dir)
  if not fd then return out end
  while true do
    local name, t = vim.loop.fs_scandir_next(fd)
    if not name then break end
    if t == "file" and name:sub(-3) == ".p8" then
      table.insert(out, name)
    end
  end
  table.sort(out)
  return out
end

local function load_hidden_buffer(path)
  local bufnr = vim.fn.bufadd(path)
  vim.fn.bufload(bufnr)
  M._last_cart_buf = bufnr
  return bufnr
end


function M.set_carts_dir()
  vim.ui.input({ prompt = "Set carts directory:" , default = M._carts_dir }, function(input)
    if input and #input > 0 then
      M._carts_dir = input
      vim.notify("📁 carts dir: " .. M._carts_dir)
    end
  end)
end

function M.pick_cartridge()
  local dir = M._carts_dir
  local carts = list_p8(dir)

  if #carts == 0 then
    vim.notify("p8 not found in " .. dir, vim.log.levels.WARN)
    return
  end

  vim.ui.select(carts, { prompt = "Pick a pico-8 cartridge:" }, function(choice)
    if not choice then return end
    local path = joinpath(dir, choice)
    load_hidden_buffer(path)
    vim.notify("loaded cartidge: " .. path, vim.log.levels.INFO)
  end)
end

function M.inject_cartridge_code()
  local bufnr = M._last_cart_buf
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.notify("There is no cartridge loaded. Use :Pico8Pick first.", vim.log.levels.WARN)
    return
  end

  -- Contenido del buffer actual (fuente)
  local src_buf = vim.api.nvim_get_current_buf()
  local src_lines = vim.api.nvim_buf_get_lines(src_buf, 0, -1, false)

  local cart_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local lua_start, next_section = nil, nil
  for i, line in ipairs(cart_lines) do
    if not lua_start and line:match("^__lua__%s*$") then
      lua_start = i + 1
    elseif lua_start and line:match("^__%w+__%s*$") then
      next_section = i - 1
      break
    end
  end

  if not lua_start then
    vim.notify("__lua__ section not found in the cartridge.", vim.log.levels.ERROR)
    return
  end
  if not next_section then
    next_section = #cart_lines
  end

  local new_cart = {}
  for i = 1, lua_start - 1 do
    table.insert(new_cart, cart_lines[i])
  end
  for _, line in ipairs(src_lines) do
    table.insert(new_cart, line)
  end
  for i = next_section + 1, #cart_lines do
    table.insert(new_cart, cart_lines[i])
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_cart)

  local path = vim.api.nvim_buf_get_name(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd.write()
  end)

  vim.notify("injected code into cartridge: " .. path, vim.log.levels.INFO)
end

return M

