# Twitch-Channel-Points-Miner-Auto-Deploy
下載Windows.bat執行即可, 其餘檔案若有需求腳本會自動下載

首次執行腳本會自動下載並安裝Python與Miner

執行Download Miner Program會順便Install Requirements

下載/安裝完成之後 請(4)手動編輯挖礦設定

詳細的機器人設定/使用方法請參閱 https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2

(5)可以切換機器人自動挖礦,設為自動時將在進入選單5秒後自動執行挖礦,設定值會儲存在同目錄下,下次執行時會自動帶入

(6)可以將腳本加入開機自動啟動,或將其從自動啟動刪除

一切都就緒之後 按(0)開始挖礦
![image](https://github.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/assets/22034115/ebb67502-43b2-4ce0-b2b2-c031be9668f7)


建議使用Notepad++作為編輯器, 比內建的記事本方便很多
https://notepad-plus-plus.org/downloads/


建議使用WindowsTerminal, 並且將它設為預設終端機, 相容性更好
https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=zh-tw&gl=tw
![image](https://github.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/assets/22034115/4829b2d5-de3f-4b78-a667-ac9b4c342541)


已知問題
在較舊的Windows上可會遇到以下錯誤：
wget : 無法剖析回應內容，因為 Internet Explorer 引擎無法使用，或者 Internet Explorer 的第一次啟動設定尚未完成。請指定 U seBasicParsing 參數，然後再試一次。
解法：打開IE，選擇 [使用建議的安全性、隱私權雨相容性設定]
https://blog.darkthread.net/blog/invoke-webrequest-ie-error/

系統內未安裝winget，會造成Crash
解法：手動安裝winget，用Powershell執行  irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex

