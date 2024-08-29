local M = {}

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

-- Default configuration
M.config = {
  notes_dir = fn.expand("~/.nvim-postit"),
}

-- Function to ensure the notes directory exists
local function ensure_notes_dir()
  if fn.isdirectory(M.config.notes_dir) == 0 then
    fn.mkdir(M.config.notes_dir, "p")
  end
end

-- Function to get all note files
local function get_note_files()
  ensure_notes_dir()
  return fn.glob(M.config.notes_dir .. "/*.md", 0, 1)
end

-- Function to create or open a note
local function create_or_open_note(name)
  local file_path = M.config.notes_dir .. "/" .. name .. ".md"
  cmd("edit " .. file_path)
  
  -- Create an autocommand for this buffer
  vim.api.nvim_create_autocmd("InsertLeave", {
    buffer = 0,  -- 0 means current buffer
    callback = function()
      if vim.bo.modified then
        vim.cmd("write")
      end
    end,
  })
end

-- Main function to display and manage notes using FZF
function M.show_notes()
  ensure_notes_dir()
  
  local notes = get_note_files()
  local note_names = {}
  for _, note in ipairs(notes) do
    table.insert(note_names, fn.fnamemodify(note, ":t:r"))
  end

  vim.fn['fzf#run'](vim.fn['fzf#wrap']({
    source = note_names,
    sinklist = function(lines)
      local query = lines[1]  -- This is the query (potentially empty)
      local selected = lines[2]  -- This is the actual selection

      if selected and selected ~= "" then
        -- vim.api.nvim_echo({{"Selected note: " .. selected, "WarningMsg"}}, true, {})
        create_or_open_note(selected)
      elseif query and query ~= "" then
        -- vim.api.nvim_echo({{"Created new note: " .. query, "WarningMsg"}}, true, {})
        create_or_open_note(query)
      else
        -- vim.api.nvim_echo({{"No note selected or created", "ErrorMsg"}}, true, {})
      end      
    end,
    options = {
      '--print-query',
      '--prompt', 'Select or create a note: ',
    },
  }))
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M