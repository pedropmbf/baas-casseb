# Gera a chave de assinatura (upload keystore) do APK e o arquivo key.properties.
# A senha é aleatória e NÃO é exibida; fica apenas em app/android/key.properties
# (ignorado pelo git). Guarde uma cópia do .jks e do key.properties: sem eles não
# dá para publicar uma atualização assinada com a mesma chave.
#
# Uso (na raiz do projeto):  powershell -ExecutionPolicy Bypass -File scripts\gerar-keystore.ps1

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $raiz 'app\android'
$keyProps = Join-Path $androidDir 'key.properties'
$jks = Join-Path $androidDir 'app\upload-keystore.jks'

if ((Test-Path $keyProps) -or (Test-Path $jks)) {
    Write-Host "Já existe uma keystore ($jks) ou key.properties. Nada foi alterado."
    exit 0
}

$keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
if (-not $keytool) {
    $candidatos = @()
    if ($env:JAVA_HOME) { $candidatos += Join-Path $env:JAVA_HOME 'bin\keytool.exe' }
    $candidatos += Get-ChildItem 'C:\Program Files\Java\*\bin\keytool.exe' -ErrorAction SilentlyContinue | ForEach-Object FullName
    $candidatos += 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
    $keytool = $candidatos | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}
if (-not $keytool) { throw 'keytool não encontrado. Instale um JDK ou defina JAVA_HOME.' }

$alfabeto = [char[]]'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$senha = -join ($bytes | ForEach-Object { $alfabeto[$_ % $alfabeto.Length] })

& $keytool -genkeypair -v -keystore $jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
    -alias upload -storepass $senha -keypass $senha `
    -dname 'CN=Circuito de Descobertas, OU=Laboratorio de Programacao Mobile, O=CESUPA, L=Belem, ST=PA, C=BR' | Out-Null
if ($LASTEXITCODE -ne 0) { throw "keytool falhou (código $LASTEXITCODE)." }

@"
storePassword=$senha
keyPassword=$senha
keyAlias=upload
storeFile=upload-keystore.jks
"@ | Set-Content -Path $keyProps -Encoding ascii

Write-Host "Keystore criada em $jks"
Write-Host "key.properties criado em $keyProps (senha aleatória, não exibida)."
