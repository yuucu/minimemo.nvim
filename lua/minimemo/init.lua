local M = {}

-- モジュールの遅延読み込み
local config = require('minimemo.config')
local memo = require('minimemo.core.memo')

-- プラグインの初期化
function M.setup(opts)
  config.setup(opts)
end

-- メインのメモ機能
function M.memo(text, range)
  -- 引数にテキストがある場合は一行メモ
  if text and vim.trim(text) ~= "" then
    return memo.add_quick_memo(text)
  end
  
  -- 引数がない場合は選択範囲メモ
  if range == 2 then
    -- visual modeでの選択範囲を取得
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    
    if start_pos[2] == 0 or end_pos[2] == 0 then
      vim.notify("Minimemo: No selection found", vim.log.levels.WARN)
      return false
    end
    
    -- 選択範囲のテキストを取得
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    if type(lines) == "string" then
      lines = {lines}
    end
    
    -- 最初と最後の行の部分選択を処理
    if #lines > 0 then
      if #lines == 1 then
        -- 単一行の場合
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
      else
        -- 複数行の場合
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      end
    end
    
    local content = table.concat(lines, "\n")
    
    if vim.trim(content) == "" then
      vim.notify("Minimemo: Empty selection", vim.log.levels.WARN)
      return false
    end
    
    -- ファイル情報の取得
    local file_info = M.get_current_file_info(start_pos[2], end_pos[2])
    
    return memo.add_selection_memo(content, file_info)
  end
  
  -- 引数もなく選択範囲もない場合
  vim.notify("Minimemo: Use ':Minimemo <text>' or select text first", vim.log.levels.INFO)
  return false
end

-- 現在のファイル情報を取得
function M.get_current_file_info(line_start, line_end)
  local filename = vim.fn.expand("%:t") -- ファイル名のみ
  local filepath = vim.fn.expand("%:p") -- フルパス
  local filetype = vim.bo.filetype
  
  -- ファイル名が空の場合（無名バッファ）
  if filename == "" then
    filename = "[unnamed]"
  end
  
  return {
    filename = filename,
    filepath = filepath,
    filetype = filetype,
    line_start = line_start,
    line_end = line_end
  }
end

-- 設定を取得
function M.get_config()
  return config.get()
end

return M 