param(
  [Parameter(Mandatory = $true)][string]$EnvFile,
  [Parameter(Mandatory = $true)][string]$RepoDir,
  [Parameter(Mandatory = $true)][string]$PublicBaseUrl
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $EnvFile)) {
  throw "Env file not found: $EnvFile"
}

$text = Get-Content -LiteralPath $EnvFile -Raw

function Set-EnvLine {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Value
  )

  $escapedName = [regex]::Escape($Name)
  $line = "$Name=$Value"
  if ($Text -match "(?m)^$escapedName=") {
    return [regex]::Replace($Text, "(?m)^$escapedName=.*$", $line)
  }

  if (-not $Text.EndsWith("`n")) {
    $Text += "`r`n"
  }
  return $Text + $line + "`r`n"
}

$text = Set-EnvLine -Text $text -Name "LU_REELS_REPO_DIR" -Value $RepoDir
$text = Set-EnvLine -Text $text -Name "LU_REELS_PUBLIC_BASE_URL" -Value $PublicBaseUrl

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($EnvFile, $text, $utf8NoBom)
Write-Host "Updated $EnvFile"
