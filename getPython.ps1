$content = (Invoke-WebRequest -Uri "https://www.python.org/downloads/").Content
$urlPattern = 'href="(https://www.python.org[^"]+\.exe)"'
$regex = [regex]::new($urlPattern)
$match = $regex.Match($content)
if ($match.Success) {
    $downloadUrl = $match.Groups[1].Value
	Write-Host $downloadUrl
}