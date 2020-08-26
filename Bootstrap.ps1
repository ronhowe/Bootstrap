<#
cmd.exe /C powershell.exe "sl '%CD%';$Path=(gl).Path;sl ~;start powershell.exe -WindowStyle Maximized -Verb RunAs -Args \""-NoExit -ExecutionPolicy Unrestricted -Command sl '"$Path"';& .\Bootstrap.ps1 \"""

Silence GitHub Desktop
Test Pre-Existing Installs
    Edge (from manual install)
    Windows Terminal (from Microsoft Store)
Test Idempotency
Test Upgrades
Create $global:Root
Register Trusted Repositories
Compare Versions from Chocolatey with Installs on DEATHSTAR
Create $Profile Before Chocolatey
Find Missing Az Module
Obfuscate SA Password
#>

#Requires -RunAsAdministrator

Start-Transcript -Path "$HOME\Bootstrap.log"

Write-Host "Checking Windows PowerShell Host..." -ForegroundColor Magenta

if ($PSVersionTable.PSVersion.Major -ne 5) {
    
    Write-Error "Requires Windows PowerShell" -ErrorAction Stop

}

Write-Host "Setting PowerShell Execution Policy..." -ForegroundColor Magenta

Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

if (-not (Test-Path -Path "C:\VSTS")) {

    Write-Host "Creating Source Control Root Folder..." -ForegroundColor Magenta

    New-Item -Path "C:\VSTS" -ItemType Directory

}

if (-not (Test-Path -Path $profile)) {

    Write-Host "Creating Windows PowerShell Profile..." -ForegroundColor Magenta

    New-Item -Path  $profile -ItemType File -Force

}

Write-Host "Bootstrapping..." -ForegroundColor Magenta

Write-Host "Installing Chocolatey..." -ForegroundColor Magenta

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))

Write-Host "Reloading Windows PowerShell Profile..." -ForegroundColor Magenta

# https://stackoverflow.com/questions/46758437/how-to-refresh-the-environment-of-a-powershell-session-after-a-chocolatey-instal
. $profile

Write-Host "Enabling Chocolatey global confirmation..." -ForegroundColor Magenta

choco feature enable -n=allowGlobalConfirmation

Write-Host "Installing Microsoft Edge..." -ForegroundColor Magenta

choco install microsoft-edge

Write-Host "Installing PowerShell Core..." -ForegroundColor Magenta

choco install powershell-core --install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'

Write-Host "Installing Git..." -ForegroundColor Magenta

choco install git

Write-Host "Installing GitHub CLI..." -ForegroundColor Magenta

choco install gh

Write-Host "Installing .NET Core SDK..." -ForegroundColor Magenta

choco install dotnetcore-sdk

Write-Host "Installing Azure CLI..." -ForegroundColor Magenta

choco install azure-cli

Write-Host "Installing Nuget Package Manager..." -ForegroundColor Magenta

Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.201" -Force

foreach ($Module in @("Az", "dbatools", "Oh-My-Posh", "Pester", "PSPKI", "Posh-Git")) {

        Write-Host "Installing $Module PowerShell Module..." -ForegroundColor Magenta

        Install-Module -Name $Module -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        
}

Write-Host "Installing Windows Terminal..." -ForegroundColor Magenta

choco install microsoft-windows-terminal

Write-Host "Installing Visual Studio Code..." -ForegroundColor Magenta

choco install vscode

Update-SessionEnvironment

Write-Host "Installing Visual Studio Code Extensions..." -ForegroundColor Magenta

code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.vscode-dotnet-runtime
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.powershell
code --install-extension msazurermtools.azurerm-vscode-tools
code --install-extension github.vscode-pull-request-github
code --install-extension donjayamanne.githistory

Write-Host "Installing Azure Data Studio ..." -ForegroundColor Magenta

choco install azure-data-studio

Write-Host "Installing Azure Data Studio SQL Server Admin Pack..." -ForegroundColor Magenta

choco install azure-data-studio-sql-server-admin-pack

Write-Host "Installing Azure Data Studio PowerShell Extension..." -ForegroundColor Magenta

choco install azuredatastudio-powershell

Write-Host "Installing GitHub Desktop..." -ForegroundColor Magenta

choco install github-desktop

Write-Host "Installing Azure Storage Explorer..." -ForegroundColor Magenta

choco install microsoftazurestorageexplorer

Write-Host "Installing Notepad++..." -ForegroundColor Magenta

choco install notepadplusplus

Write-Host "Installing KeePass..." -ForegroundColor Magenta

choco install keepass

Write-Host "Installing Remote Desktop Manager Enterprise Edition..." -ForegroundColor Magenta

choco install rdm

Write-Host "Installing Windows Admin Center..." -ForegroundColor Magenta

choco install windows-admin-center

$Config = Join-Path -Path $(Split-Path $MyInvocation.MyCommand.Path -Parent) -ChildPath "Bootstrap.vsconfig"

if (Test-Path -Path $Config) {

    Write-Host "Installing Visual Studio 2019..." -ForegroundColor Magenta

    choco install visualstudio2019community --params "'--config `"$Config`"'"

    Write-Host "Installing SQL Server Integration Services for Visual Studio 2019..." -ForegroundColor Magenta

    choco install ssis-vs2019

}
else {

    Write-Host "Could not find $Config.  Skipping Visual Studio 2019..." -ForegroundColor Magenta
    
    Write-Host "Could not find $Config.  Skipping SQL Server Integration Services for Visual Studio 2019..." -ForegroundColor Magenta

}

Write-Host "Creating SQL Server 2019 Folders..." -ForegroundColor Magenta

foreach ($Folder in @("C:\MSSQL\Backup", "C:\MSSQL\Data", "C:\MSSQL\JobLogs", "C:\MSSQL\Logs")) {

    if (-not (Test-Path -Path $Folder)) {

        New-Item -Path $Folder -ItemType Directory -Force

    }

}

Write-Host "Installing SQL Server 2019 Developer Edition..." -ForegroundColor Magenta

#choco install -y sql-server-2019 --params="'/TCPENABLED=`"1`" /SECURITYMODE=`"SQL`" /SAPWD:`"${ENV:BV7_DB_PASS}`"'"
choco install sql-server-2019 --params="'/IGNOREPENDINGREBOOT /SQLSVCSTARTUPTYPE=`"Automatic`" /AGTSVCSTARTUPTYPE=`"Automatic`" /INDICATEPROGRESS=`"True`" /USEMICROSOFTUPDATE=`"True`" /UPDATEENABLED=`"True`" /IACCEPTROPENLICENSETERMS=`"True`" /SUPPRESSPRIVACYSTATEMENTNOTICE=`"True`" /FEATURES=`"SQLENGINE,REPLICATION,CONN,IS,FULLTEXT`" /SQLUSERDBDIR=`"C:\MSSQL\Data`" /SQLUSERDBLOGDIR=`"C:\MSSQL\Logs`" /SQLBACKUPDIR=`"C:\MSSQL\Backup`" /SECURITYMODE=`"SQL`" /SAPWD=`"123!@#abc123!@#abc`"'"

Write-Host "Installing SQL Server Management Studio..." -ForegroundColor Magenta

choco install sql-server-management-studio --install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1"'

Update-SessionEnvironment

Write-Host "Enabling IIS..." -ForegroundColor Magenta

#Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -like "IIS*"} | Format-Table
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebServer" -All

Write-Host "Bootstrap complete." -ForegroundColor Magenta

Stop-Transcript
