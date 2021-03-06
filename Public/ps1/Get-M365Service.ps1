function Get-M365Service {

    [CmdletBinding()]
    Param ()

    $connectionsObject = [PSCustomObject]@{
        'Azure' = [PSCustomObject][PSCustomObject]@{'Connected' = $null}
        'AzureAD' = [PSCustomObject]@{'Connected' = $null}
        'ExchangeOnline' = [PSCustomObject]@{'Connected' = $null}
        'MicrosoftOnline' = [PSCustomObject]@{'Connected' = $null}
        'MicrosoftTeams' = [PSCustomObject]@{'Connected' = $null}
        'SecurityAndComplianceCenter' = [PSCustomObject]@{'Connected' = $null}
        'SharePointOnlinePnP' = [PSCustomObject]@{'Connected' = $null}
    }

    $azSession = Get-AzContext
    if ($azSession) {
        $connectionsObject.Azure.Connected = $true
    }
    else {
        $connectionsObject.Azure.Connected = $false
    }

    try { # AzureAD
        Get-AzureADTenantDetail -ErrorAction Stop | Out-Null
        $connectionsObject.AzureAD.Connected = $true
    }
    catch {
        $connectionsObject.AzureAD.Connected = $false
    }

    # Exchange Online
    $exchangeOnlineSession = Get-PSSession -ErrorAction SilentlyContinue | Where-Object { $_.ComputerName -match "outlook" -and $_.State -match "Opened" }
    if ($exchangeOnlineSession) { 
        $connectionsObject.ExchangeOnline.Connected = $true
    }
    else {
        $connectionsObject.ExchangeOnline.Connected = $false
    }

    try { # MicrosoftOnline
        Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
        $connectionsObject.MicrosoftOnline.Connected = $true
    }
    catch {
        $connectionsObject.MicrosoftOnline.Connected = $false
    }

    try { # Microsoft Teams
        Get-Team -ErrorAction Stop | Out-Null
        $connectionsObject.MicrosoftTeams.Connected = $true
    }
    catch {
        $connectionsObject.MicrosoftTeams.Connected = $false
    }

    # Security and Compliance
    $sccSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.compliance.protection.outlook.com" -and $_.State -match "Opened" }
    if ($sccSession) {
        $connectionsObject.SecurityAndComplianceCenter.Connected = $true
    }
    else {
        $connectionsObject.SecurityAndComplianceCenter.Connected = $false
    }

    try { # SharePointOnline PnP
        Get-PnpWeb -ErrorAction Stop | Out-Null
        $connectionsObject.SharePointOnlinePnP.Connected = $true
    }
    catch {
        $connectionsObject.SharePointOnlinePnP.Connected = $false
    }

    return $connectionsObject

}

