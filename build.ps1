param(
  [string]$DeviceId = "fenix7"
)

$Sdk = "$env:APPDATA\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-8.2.3-*\bin"
$SdkBin = (Get-ChildItem $Sdk | Select-Object -First 1).FullName

& "$SdkBin\monkeyc.bat" -o bin\app.prg -f manifest.xml -y developer_key
& "$SdkBin\monkeydo.bat" bin\app.prg $DeviceId
