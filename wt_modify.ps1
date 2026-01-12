$jsonpath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$json = Get-Content $jsonpath -Raw | ConvertFrom-Json
$json.defaultProfile    = '{0caa0dad-35be-5f56-a8ff-afceeeaa6101}'
$json.windowingBehavior = 'useAnyExisting'
$json | ConvertTo-Json -Depth 32 | Set-Content -Path $jsonpath -Encoding UTF8
