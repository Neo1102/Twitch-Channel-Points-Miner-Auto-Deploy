$jsonpath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$json = Get-Content $jsonpath -Raw | ConvertFrom-Json
$json.defaultProfile = '{0caa0dad-35be-5f56-a8ff-afceeeaa6101}'
if (-not $json.PSObject.Properties['windowingBehavior']) {
    Add-Member -InputObject $json -NotePropertyName 'windowingBehavior' -NotePropertyValue 'useAnyExisting'
} else {
    $json.windowingBehavior = 'useAnyExisting'
}
$json | ConvertTo-Json -Depth 32 | Set-Content $jsonpath -Encoding UTF8
