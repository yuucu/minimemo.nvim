local M = {}
local timestamp = require('minimemo.core.timestamp')

-- ファイルパス生成
function M.get_memo_filepath(config)
  config = config or require('minimemo.config').get()
  local filename = timestamp.get_today_filename(config)
  local filepath = vim.fn.expand(config.memo_dir) .. "/" .. filename
  
  -- ファイルパスにディレクトリが含まれている場合は作成
  local dir = vim.fn.fnamemodify(filepath, ":h")
  M.ensure_directory(dir)
  
  return filepath
end

-- ファイルの存在確認
function M.file_exists(filepath)
  return vim.fn.filereadable(filepath) == 1
end

-- ディレクトリの存在確認・作成
function M.ensure_directory(dirpath)
  if vim.fn.isdirectory(dirpath) == 0 then
    return vim.fn.mkdir(dirpath, "p") == 1
  end
  return true
end

-- ファイルの全内容を読み取り
function M.read_file(filepath)
  if not M.file_exists(filepath) then
    return nil
  end
  
  local lines = {}
  for line in io.lines(filepath) do
    table.insert(lines, line)
  end
  return lines
end

-- ファイルに内容を書き込み
function M.write_file(filepath, lines)
  -- ディレクトリの存在確認
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if not M.ensure_directory(dir) then
    vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
    return false
  end
  
  local file = io.open(filepath, "w")
  if not file then
    vim.notify("Failed to open file for writing: " .. filepath, vim.log.levels.ERROR)
    return false
  end
  
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()
  return true
end

-- ファイルに内容を追記
function M.append_to_file(filepath, content)
  -- ディレクトリの存在確認
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if not M.ensure_directory(dir) then
    vim.notify("Failed to create directory: " .. dir, vim.log.levels.ERROR)
    return false
  end
  
  local file = io.open(filepath, "a")
  if not file then
    vim.notify("Failed to open file for appending: " .. filepath, vim.log.levels.ERROR)
    return false
  end
  
  file:write(content)
  file:close()
  return true
end

-- ヘッダーの位置を検索
function M.find_header_position(lines, header_name)
  local header_pattern = "^## " .. header_name .. "$"
  
  for i, line in ipairs(lines) do
    if line:match(header_pattern) then
      return i
    end
  end
  return nil
end

-- ヘッダー下に内容を挿入
function M.insert_under_header(lines, header_name, content)
  local header_pos = M.find_header_position(lines, header_name)
  
  if not header_pos then
    -- ヘッダーが存在しない場合は末尾に追加
    table.insert(lines, "")
    table.insert(lines, "## " .. header_name)
    header_pos = #lines
  end
  
  -- ヘッダーの直後に挿入（先頭に新しいエントリを挿入）
  local insert_pos = header_pos + 1
  
  -- contentを行ごとに分割して挿入（空行は除外）
  local content_lines = {}
  for line in content:gmatch("[^\n]+") do  -- 空行を除外
    table.insert(content_lines, line)
  end
  
  -- 行を逆順で挿入（最初の行が一番上に来るように）
  for i = #content_lines, 1, -1 do
    table.insert(lines, insert_pos, content_lines[i])
  end
  
  return lines
end

-- 日別ファイルの初期化
function M.initialize_daily_file(filepath, config)
  if M.file_exists(filepath) then
    return true -- 既に存在する場合は何もしない
  end
  
  local filename = vim.fn.fnamemodify(filepath, ":t:r") -- 拡張子を除いたファイル名
  local lines = {
    "# " .. filename,
    "",
    "## " .. config.header_name
  }
  
  return M.write_file(filepath, lines)
end

-- メモをファイルに追記
function M.append_memo_to_file(content, config)
  config = config or require('minimemo.config').get()
  local filepath = M.get_memo_filepath(config)
  
  -- ファイルの初期化
  if not M.initialize_daily_file(filepath, config) then
    return false
  end
  
  -- 既存の内容を読み取り
  local lines = M.read_file(filepath)
  if not lines then
    vim.notify("Failed to read memo file: " .. filepath, vim.log.levels.ERROR)
    return false
  end
  
  -- ヘッダー下に内容を挿入
  lines = M.insert_under_header(lines, config.header_name, content)
  
  -- ファイルに書き戻し
  return M.write_file(filepath, lines)
end

return M