local M = {}

-- UTC時間取得（epoch time）
function M.get_utc_timestamp()
  return os.time()
end

-- 表示用時刻文字列生成
function M.format_display_time(timestamp, config)
  timestamp = timestamp or M.get_utc_timestamp()
  config = config or require('minimemo.config').get()
  
  -- Luaの標準ライブラリではタイムゾーン変換は行わず、
  -- ローカルタイムでフォーマットしてラベルのみ置換
  local formatted_time = os.date(config.time_format, timestamp)
  
  -- タイムゾーン略語のマッピング
  local timezone_abbreviations = {
    ["Asia/Tokyo"] = "JST",
    ["America/New_York"] = "EST",
    ["America/Los_Angeles"] = "PST", 
    ["Europe/London"] = "GMT",
    ["Europe/Paris"] = "CET",
    ["UTC"] = "UTC",
    ["GMT"] = "GMT"
  }
  
  -- タイムゾーン表記の調整（ラベルのみ変更）
  local target_tz = timezone_abbreviations[config.display_timezone] or config.display_timezone
  
  -- 既存のタイムゾーン表記を設定されたものに置換
  formatted_time = formatted_time:gsub(" [A-Z][A-Z][A-Z]?$", " " .. target_tz)
  
  -- タイムゾーン略語が末尾にない場合は追加
  if not formatted_time:match(" [A-Z][A-Z][A-Z]?$") then
    formatted_time = formatted_time .. " " .. target_tz
  end
  
  return formatted_time
end

-- ファイル名用日付文字列生成
function M.get_date_string(timestamp, format)
  timestamp = timestamp or M.get_utc_timestamp()
  format = format or "%Y-%m-%d"
  return os.date(format, timestamp)
end

-- 今日の日付でファイル名生成
function M.get_today_filename(config)
  config = config or require('minimemo.config').get()
  local today = M.get_date_string(nil, config.file_format)
  return today
end

return M 