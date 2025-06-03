local M = {}

-- デフォルト設定
M.defaults = {
  -- ファイル保存設定
  memo_dir = vim.fn.expand("~/memo"),
  file_format = "%Y%m%d.md",                -- ファイル名形式（デフォルト: 20250604.md）
  header_name = "minimemo",                 -- ## minimemo
  
  -- 時間設定
  display_timezone = "Asia/Tokyo",          -- 表示時のタイムゾーン
  time_format = "%Y-%m-%d %H:%M:%S %Z",     -- 2025-01-15 14:30:25 JST
  
  -- コードブロック設定
  include_file_info = true,                 -- ファイル名・行番号を含める
  auto_detect_filetype = true,              -- 言語自動判定
}

-- 現在の設定
M.current = vim.deepcopy(M.defaults)

-- 設定初期化
function M.setup(opts)
  opts = opts or {}
  M.current = vim.tbl_deep_extend("force", M.defaults, opts)
  
  -- memo_dirの作成
  local memo_dir = vim.fn.expand(M.current.memo_dir)
  if vim.fn.isdirectory(memo_dir) == 0 then
    vim.fn.mkdir(memo_dir, "p")
  end
end

-- 設定取得
function M.get()
  return M.current
end

-- 設定の一部を更新
function M.update(key, value)
  if M.current[key] ~= nil then
    M.current[key] = value
  else
    vim.notify("Unknown config key: " .. tostring(key), vim.log.levels.ERROR)
  end
end

return M 