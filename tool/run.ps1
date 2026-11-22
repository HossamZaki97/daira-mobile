# Run Daira (com.daira.circles) on a USB-connected Android phone against the
# local Odoo. The store app must be uninstalled first (different signature). The phone reaches the computer's Odoo
# (127.0.0.1:8019) through an adb tunnel that is lost whenever the phone is
# unplugged or adb restarts, so it is opened on every run.
#   .\tool\run.ps1            (extra flutter args are passed through)
#   .\tool\run.ps1 -d all     (every connected phone at once, e.g. two accounts)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
if (-not (Test-Path 'config/local.json')) { Copy-Item 'config/local.example.json' 'config/local.json' }
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (-not (Test-Path $adb)) { $adb = 'adb' }
# Every connected phone gets its own tunnel.
$phones = & $adb devices | Select-String -Pattern '^(\S+)\s+device$' | ForEach-Object { $_.Matches[0].Groups[1].Value }
foreach ($phone in $phones) { & $adb -s $phone reverse tcp:8019 tcp:8019 | Out-Null; Write-Host "Tunnel ready on $phone" }
try {
  Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 http://127.0.0.1:8019/daira/health | Out-Null
  Write-Host 'Odoo is running on 127.0.0.1:8019'
} catch {
  Write-Warning 'Odoo does not answer on 127.0.0.1:8019 - start it from PyCharm first.'
}
$defines = @('--dart-define-from-file=config/local.json')
# Several phones: build once first. Two builds at the same time in one folder
# break each other (Gradle "Resource compilation failed"); after this one,
# each phone's build is already up to date.
if (($args -join ' ') -match '-d\s+all') {
  flutter build apk --debug @defines
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
flutter run @defines @args
