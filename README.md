# minimemo.nvim 📝

Minimal NeoVim memo plugin - Create quick memos with a single command

## 📖 Overview

minimemo.nvim is a memo plugin that pursues "simplicity". With just one command, it handles both single-line memos and code snippet memos, automatically saving them to daily Markdown files.

*Inspired by the quick capture functionality of [Thino](https://github.com/Quorafind/Obsidian-Thino) (Obsidian plugin), this plugin brings similar convenience to NeoVim users.*

## 🚀 Usage

### Basic Commands
```vim
" Single-line memo
:Minimemo Today's task completed

" Selection memo (after Visual selection)
:'<,'>Minimemo
```

### Output Example
```markdown
# 20250604

## minimemo
- 2025-06-04 01:05:29 JST - Today's task completed
- 2025-06-04 01:05:46 JST - From /path/to/file.js:1-3
  ```javascript
  function hello() {
    console.log('world');
  }
  ```


## 📦 Installation

```lua
-- lazy.nvim
{
  'yuucu/minimemo.nvim',
  config = function()
    require('minimemo').setup()
  end
}

-- packer.nvim
use {
  'yuucu/minimemo.nvim',
  config = function()
    require('minimemo').setup()
  end
}
```

## ⚙️ Configuration

```lua
require('minimemo').setup({
  memo_dir = "~/memo",                    -- 📂 Memo save directory
  file_format = "%Y%m%d.md",              -- 📄 File name format
  header_name = "minimemo",               -- 🏷️  Memo section name
  display_timezone = "Asia/Tokyo",        -- 🌍 Timezone display
  time_format = "%Y-%m-%d %H:%M:%S %Z",   -- 🕒 Time display format
  include_file_info = true,               -- 📋 Include file info in code
  auto_detect_filetype = true,            -- 🔍 Auto language detection
})
```

### 📝 File Format Examples
```lua
-- Compact format (default)
file_format = "%Y%m%d.md"        -- 20250604.md

-- Separated format
file_format = "%Y-%m-%d.md"      -- 2025-06-04.md

-- Different extension
file_format = "%Y%m%d.txt"       -- 20250604.txt

-- Custom format
file_format = "%Y%m%d_memo.md"   -- 20250604_memo.md
```

## 🏗️ Architecture

```
minimemo.nvim/
├── plugin/minimemo.vim          # 🎯 Vim command definition
└── lua/minimemo/
    ├── init.lua                 # 🚦 Main processing & argument branching
    ├── config.lua               # ⚙️  Configuration management
    └── core/
        ├── memo.lua             # ✍️  Memo entry generation
        ├── file.lua             # 📁 File operations
        └── timestamp.lua        # ⏰ Time processing
```

## 📄 License

MIT License

