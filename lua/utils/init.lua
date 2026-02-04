local M = {}

M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

function M.lazy_file()
  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")

  Event.mappings.LazyFile = { id = "LazyFile", event = M.lazy_file_events }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end

function M.executable(name)
  return vim.fn.executable(name) > 0
end

function M.merge_sets(array1, array2)
  local merged_array, seen = {}, {}

  local function add_unique(arr)
    for _, value in ipairs(arr) do
      if not seen[value] then
        table.insert(merged_array, value)
        seen[value] = true
      end
    end
  end

  add_unique(array1)
  add_unique(array2)

  return merged_array
end

---@generic T : fun(...)
---@param fn T
---@return T
function M.memo(fn)
  local cache = {}
  local hash_fn = function(...)
    return table.concat({ ... }, ",")
  end
  local new_fn = {
    revalidate = function(...)
      cache[hash_fn(...)] = nil
    end,
    clear = function()
      cache = {}
    end,
  }
  setmetatable(new_fn, {
    __call = function(_, ...)
      local key = hash_fn(...)
      if cache[key] then
        return cache[key]
      end
      local result = fn(...)
      cache[key] = result
      return result
    end,
  })
  return new_fn
end

return M
