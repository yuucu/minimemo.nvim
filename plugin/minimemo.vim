" minimemo.nvim - Simple memo plugin
" ===================================

if exists('g:loaded_minimemo')
  finish
endif
let g:loaded_minimemo = 1

" メインコマンド - 引数があれば一行メモ、なければ選択範囲メモ
command! -nargs=* -range Minimemo lua require('minimemo').memo(<q-args>, <range>)

" 使用例:
" :Minimemo 今日はLua勉強中    " 一行メモ
" (visual modeで選択して) :Minimemo  " 選択範囲メモ 