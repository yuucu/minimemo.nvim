local M = {}
local file = require('minimemo.core.file')
local timestamp = require('minimemo.core.timestamp')

-- メモエントリ生成
function M.create_entry(content, extra_info)
  local config = require('minimemo.config').get()
  local now = timestamp.get_utc_timestamp()
  local display_time = timestamp.format_display_time(now, config)
  
  -- サマリー行の生成
  local summary_parts = {display_time}
  if extra_info then
    table.insert(summary_parts, extra_info)
  end
  local summary = table.concat(summary_parts, " - ")
  
  -- シンプルなリスト形式で生成
  local content_lines = {}
  
  -- 単純に改行で分割して空行は除外
  for line in content:gmatch("[^\n]+") do
    table.insert(content_lines, line)
  end
  
  -- 内容がないか単一行かを判定
  if #content_lines <= 1 and (content_lines[1] == nil or vim.trim(content_lines[1]) == "") then
    local entry = "- " .. summary .. "\n"
    return entry
  elseif #content_lines == 1 then
    local entry = "- " .. summary .. " - " .. content_lines[1] .. "\n"
    return entry
  else
    -- 複数行の場合：次の行からインデントして表示
    local entry = "- " .. summary .. "\n"
    
    for _, line in ipairs(content_lines) do
      entry = entry .. "  " .. line .. "\n"
    end
    
    return entry
  end
end

-- ひとことメモの追加
function M.add_quick_memo(content)
  if not content or vim.trim(content) == "" then
    vim.notify("Cannot add empty memo", vim.log.levels.WARN)
    return false
  end
  
  local entry = M.create_entry(content)
  return M.append_to_memo_file(entry)
end

-- 選択範囲メモの追加
function M.add_selection_memo(content, file_info)
  if not content or vim.trim(content) == "" then
    vim.notify("Cannot add empty selection", vim.log.levels.WARN)
    return false
  end
  
  -- コードブロック形式でラップ
  local config = require('minimemo.config').get()
  local wrapped_content
  
  if config.auto_detect_filetype and file_info and file_info.filetype then
    wrapped_content = "```" .. file_info.filetype .. "\n" .. vim.trim(content) .. "\n```"
  else
    wrapped_content = "```\n" .. vim.trim(content) .. "\n```"
  end
  
  local extra_info = nil
  if config.include_file_info and file_info then
    if file_info.filename and file_info.line_start and file_info.line_end then
      -- pwdを取得してフルパスを作成
      local pwd = vim.fn.getcwd()
      local full_path = pwd .. "/" .. file_info.filename
      
      if file_info.line_start == file_info.line_end then
        extra_info = string.format("From %s:%d", full_path, file_info.line_start)
      else
        extra_info = string.format("From %s:%d-%d", full_path, file_info.line_start, file_info.line_end)
      end
    end
  end
  
  local entry = M.create_entry(wrapped_content, extra_info)
  return M.append_to_memo_file(entry)
end

-- ファイルへの追記
function M.append_to_memo_file(entry)
  local config = require('minimemo.config').get()
  local success = file.append_memo_to_file(entry, config)
  
  if success then
    local filepath = file.get_memo_filepath(config)
    vim.notify("Memo added to " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
  else
    vim.notify("Failed to add memo", vim.log.levels.ERROR)
  end
  
  return success
end

return M 