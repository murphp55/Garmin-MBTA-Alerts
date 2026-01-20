param(
  [string]$DeviceId = "fenix7"
)

$Sdk = "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.2.3-*\bin"
$SdkBin = (Get-ChildItem $Sdk | Select-Object -First 1).FullName

$Key = "developer_key.der"
if (-not (Test-Path $Key)) {
  $Key = "$env:APPDATA\Garmin\ConnectIQ\developer_key.der"
}
if (-not (Test-Path $Key)) {
  throw "Missing developer key. Generate developer_key.der and place it in the repo or at $env:APPDATA\Garmin\ConnectIQ\developer_key.der"
}

& "$SdkBin\monkeyc.bat" -o bin\app.prg -f monkey.jungle -y $Key
& "$SdkBin\monkeyc.bat" -e -o bin\app.iq -f monkey.jungle -y $Key -d $DeviceId
& "$SdkBin\monkeydo.bat" bin\app.prg $DeviceId
