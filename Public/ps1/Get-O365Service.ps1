function Get-O365Service {

    [CmdletBinding()]
    Param ()

    $connectionsObject = [PSCustomObject]@{
        'Azure' = $null
        'AzureAD' = $null
        'ExchangeOnline' = $null
        'MicrosoftOnline' = $null
        'MicrosoftTeams' = $null
        'SecurityAndComplianceCenter' = $null
        'SharePointOnlinePnP' = $null
    }

    try { # Azure
        Get-AzContext -ErrorAction Stop | Out-Null
        $connectionsObject.Azure = $true
    }
    catch {
        $connectionsObject.Azure = $false
    }

    try { # AzureAD
        Get-AzureADTenantDetail -ErrorAction Stop | Out-Null
        $connectionsObject.AzureAD = $true
    }
    catch {
        $connectionsObject.AzureAD = $false
    }

    # Exchange Online
    $exchangeOnlineSession = Get-PSSession -ErrorAction SilentlyContinue | Where-Object { $_.ComputerName -match "outlook" -and $_.State -match "Opened" }
    if ($exchangeOnlineSession) { 
        $connectionsObject.ExchangeOnline = $true
    }
    else {
        $connectionsObject.ExchangeOnline = $false
    }

    try { # MicrosoftOnline
        Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
        $connectionsObject.MicrosoftOnline = $true
    }
    catch {
        $connectionsObject.MicrosoftOnline = $false
    }

    try { # Microsoft Teams
        Get-Team -ErrorAction Stop | Out-Null
        $connectionsObject.MicrosoftTeams = $true
    }
    catch {
        $connectionsObject.MicrosoftTeams = $false
    }

    # Security and Compliance
    $sccSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.compliance.protection.outlook.com" -and $_.State -match "Opened" }
    if ($sccSession) {
        $connectionsObject.SecurityAndComplianceCenter = $true
    }
    else {
        $connectionsObject.SecurityAndComplianceCenter = $false
    }

    try { # SharePointOnline PnP
        Get-PnpWeb -ErrorAction Stop | Out-Null
        $connectionsObject.SharePointOnlinePnP = $true
    }
    catch {
        $connectionsObject.SharePointOnlinePnP = $false
    }

    return $connectionsObject

}

