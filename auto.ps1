$GitHubUser = "arthurdev449"
$RepoName   = "Work-Desk" 
$Branch     = "main"

$BaseURL = "https://raw.githubusercontent.com/$GitHubUser/$RepoName/$Branch"

$TempDir = "$env:TEMP\AutoInstall"
if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

Write-Host "--- INITIALIZING CLOUD SETUP ---" -ForegroundColor Cyan

$ConfigPath = "$TempDir\config.xml" 
Write-Host "Installing office xml for pt-br download..."
Invoke-WebRequest -Uri "$BaseURL/config.xml" -OutFile $ConfigPath

$WallpaperPath = "$TempDir\wallpaper.png"
Write-Host "Downloading Wallpaper..."
try {
    Invoke-WebRequest -Uri "$BaseURL/wallpaper.png" -OutFile $WallpaperPath
} catch {
    Write-Warning "Wallpaper not found in repo."
}

$ProgramsToCheck = @(
    "*Java*",              
    "*Chrome*",          
    "*WinRAR*",          
    "*Adobe*Reader*",    
    "*Office*"           
)

Write-Host "Checking for installed programs..." -ForegroundColor Cyan

foreach ($Program in $ProgramsToCheck) {
    $Result = Get-Package -Name $Program -ErrorAction SilentlyContinue
    
    if ($Result) {
        Write-Host "[INSTALLED] Found match for '$Program':" -ForegroundColor Green
        $Result | Select-Object Name, Version | Format-Table -HideTableHeaders
    } else {
        Write-Host "[MISSING]   Could not find any program matching '$Program'" -ForegroundColor Red
        Write-Host "   -> Preparing to install '$Program'..." -ForegroundColor Yellow
        
        $Id = switch -Wildcard ($Program) {
            "*Chrome*"       { "Google.Chrome" }
            "*Java*"         { "Oracle.JavaRuntimeEnvironment" } 
            "*WinRAR*"       { "RARLab.WinRAR" }
            "*Adobe*Reader*" { "Adobe.Acrobat.Reader.64-bit" }
            "*Office*"       { "Microsoft.Office.365" }
            Default          { $null }
        }

        if ($Id -and $Id -ne "Microsoft.Office.365") {
            winget install --id $Id -e --silent --accept-package-agreements --accept-source-agreements
        } 
        elseif ($Id -eq "Mircosoft.Office.365") {
            $ODTPath = "$TempDir\odt_setup.exe"
            Write-Host "Downloading official Office Deployment Tool..."
            Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17126-20132.exe" -OutFile $ODTPath

            Write-Host "Extracting Office Tool..."
            Start-Process -FilePath $ODTPath -ArgumentList "/quiet /extract:`"$TempDir`"" -Wait

            $OfficeSetup = "$TempDir\setup.exe"

            if (-not (Test-Path $OfficeSetup)) {
                Write-Error "CRITICAL: setup.exe not found after extraction. ODT download might be corrupt."
                exit
            }
            if (Test-Path $OfficeSetup) {
                Write-Host "Installing Office 365..." -ForegroundColor Green
                Start-Process -FilePath $OfficeSetup -ArgumentList "/configure `"$ConfigPath`"" -Wait
            } else {
                Write-Error "Office Setup.exe failed to extract."
            }
        }
        else {
            Write-Host "   -> Error: Could not determine installer ID for $Program" -ForegroundColor Magenta
        }
    }
}

if (Test-Path $WallpaperPath) {
    Write-Host "Setting Wallpaper..."
    $code = @'
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
'@
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
    [Wallpaper]::SystemParametersInfo(0x0014, 0, $WallpaperPath, 0x01 -bor 0x02)
}

Write-Host "--- SETUP COMPLETE ---" -ForegroundColor Green
Remove-Item $TempDir -Recurse -Force
