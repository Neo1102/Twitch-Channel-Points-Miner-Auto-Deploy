$jsonpath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
$json = (Get-Content $jsonpath -Raw -Encoding UTF8) -replace '^\s*//.*?(?=\r?\n|$)', '' -replace '\n\s*//.*?(?=\r?\n|$)', ''| ConvertFrom-Json
if ($json.network -and $json.network.downloader -eq 'wininet') {exit 0}
$json| Add-Member -MemberType NoteProperty -Name 'network' -Value (@{downloader='wininet'}) -Force
$json | ConvertTo-Json -Depth 10 | Set-Content $jsonpath -Encoding UTF8