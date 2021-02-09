function Disconnect-O365Service {

    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
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

    if ($Azure) {
        try {
            Get-AzContext -ErrorAction Stop | Out-Null
            Write-Host "Disconnecting Azure"
            Disconnect-AzAccount | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        catch {
            Write-Host "No active connection to Azure" -ForegroundColor Yellow
        }
    }

    if ($AzureAD) {
        try {
            Get-AzureADTenantDetail -ErrorAction Stop | Out-Null
            Write-Host "Disconnecting AzureAD..."
            Disconnect-AzureAD | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        catch {
            Write-Host "No active connection to AzureAD" -ForegroundColor Yellow
        }
    }

    if ($ExchangeOnline) {
        $exchangeOnlineSession = Get-PSSession -ErrorAction SilentlyContinue | Where-Object { $_.ComputerName -match "outlook" -and $_.State -match "Opened" }
        if ($exchangeOnlineSession) {
            Write-Host "Disconnecting Exchange Online..."
            $exchangeOnlineSession | Remove-PSSession | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Exchange Online" -ForegroundColor Yellow
        }
    }

    if ($MicrosoftOnline) {
        try {
            Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
            Write-Host "Disconnecting Microsoft Online..."
            $fakePassword = ConvertTo-SecureString "notmypassword" -AsPlainText -Force
            $fakeCredential = New-Object System.Management.Automation.PSCredential ("fakeuser", $fakePassword)
            Connect-MsolService -Credential $fakeCredential -ErrorAction SilentlyContinue
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        catch {
            Write-Host "No active connection to Microsoft Online" -ForegroundColor Yellow
        }
    }

    if ($MicrosoftTeams) {
        try {
            Get-Team -ErrorAction Stop | Out-Null
            Write-Host "Disconnecting Microsoft Teams"
            Disconnect-MicrosoftTeams
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        catch {
            Write-Host "No active connection to Microsoft Teams" -ForegroundColor Yellow
        }
    }


    if ($SecurityAndComplianceCenter) {
        $sccSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.compliance.protection.outlook.com" -and $_.State -match "Opened" }
        if ($sccSession) {
            Write-Host "Disconnecting Security and Compliance Center..."
            $sccSession | Remove-PSSession | Out-Null
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        else {
            Write-Host "No active connection to Security and Compliance Center" -ForegroundColor Yellow
        }
    }

    if ($SharePointOnlinePnP) {
        try {
            Get-PnPWeb -ErrorAction Stop | Out-Null
            Write-Host "Disconnecting SharePointOnline PnP"
            Disconnect-PnPOnline
            Write-Host "        Disconnected!" -ForegroundColor Green
        }
        catch {
            Write-Host "No active connection to SharePointOnline PnP" -ForegroundColor Yellow
        }
    }

}

