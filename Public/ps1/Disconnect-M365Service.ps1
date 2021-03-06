function Disconnect-M365Service {

    [CmdletBinding()]
    Param (

        [Parameter()]
        [switch]
        $Azure,

        [Parameter()]
        [switch]
        $AzureAD,

        [Parameter()]
        [switch]
        $ExchangeOnline,

        [Parameter()]
        [switch]
        $MicrosoftOnline,

        [Parameter()]
        [switch]
        $SecurityAndComplianceCenter,

        [Parameter()]
        [switch]
        $SharePointOnlinePnP,

        [Parameter()]
        [switch]
        $MicrosoftTeams

    )

    if ($PSBoundParameters.Count -eq 0) {
        $Azure = $true
        $AzureAD = $true
        $ExchangeOnline = $true
        $MicrosoftOnline = $true
        $MicrosoftTeams = $true
        $SecurityAndComplianceCenter = $true
        $SharePointOnlinePnP = $true
    }

    $checkConnections = Get-M365Service
    if ($Azure) {

        if ($checkConnections.Azure.Connected) {
            Write-Host "Disconnecting Azure"
            Disconnect-AzAccount | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Azure" -ForegroundColor Yellow
        }

    }
    if ($AzureAD) {

        if ($checkConnections.AzureAD.Connected) {
            Write-Host "Disconnecting AzureAD..."
            Disconnect-AzureAD | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to AzureAD" -ForegroundColor Yellow
        }

    }
    if ($ExchangeOnline) {

        if ($checkConnections.ExchangeOnline.Connected) {
            Write-Host "Disconnecting Exchange Online..."
            Get-PSSession | Where-Object { $_.ComputerName -match "outlook" -and $_.State -match "Opened" } | Remove-PSSession
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Exchange Online" -ForegroundColor Yellow
        }
        
    }
    if ($MicrosoftOnline) {

        if ($checkConnections.MicrosottOnline.Connected) {
            Write-Host "Disconnecting Microsoft Online..."
            $fakePassword = ConvertTo-SecureString "notmypassword" -AsPlainText -Force
            $fakeCredential = New-Object System.Management.Automation.PSCredential ("fakeuser", $fakePassword)
            Connect-MsolService -Credential $fakeCredential -ErrorAction SilentlyContinue
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Microsoft Online" -ForegroundColor Yellow
        }

    }
    if ($MicrosoftTeams) {

        if ($checkConnections.MicrosoftTeams.Connected) {
            Write-Host "Disconnecting Microsoft Teams"
            Disconnect-MicrosoftTeams
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Microsoft Teams" -ForegroundColor Yellow
        }

    }
    if ($SecurityAndComplianceCenter) {

        if ($checkConnections.SecurityAndComplianceCenter.Connected) {
            Write-Host "Disconnecting Security and Compliance Center"
            Get-PSSession | Where-Object { $_.ComputerName -like "*.compliance.protection.outlook.com" -and $_.State -match "Opened" } | Remove-PSSession
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Security and Compliance Center" -ForegroundColor Yellow
        }

    }

    if ($SharePointOnlinePnP) {

        if ($checkConnections.SharePointOnlinePnP.Connected) {
            Write-Host "Disconnecting SharePointOnline PnP"
            Disconnect-PnPOnline
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to SharePointOnline PnP" -ForegroundColor Yellow
        }

    }

}

