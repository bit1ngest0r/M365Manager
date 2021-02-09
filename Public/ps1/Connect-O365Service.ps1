function Connect-O365Service {

    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param (

        [Parameter()]
        [PSCredential]
        $AdminCredentail = (Get-Credential -Message "Enter your O365 administrator credential."),

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
    try {
        if ($Azure) { connectAzure -Credential $AdminCredentail }
        if ($AzureAD) { connectAzureAD -Credential $AdminCredentail }
        if ($ExchangeOnline) { connectExchangeOnline -Credential $AdminCredentail }
        if ($MicrosoftOnline) { connectMicrosoftOnline -Credential $AdminCredentail }
        if ($MicrosoftTeams) { connectMicrosoftTeams -Credential $AdminCredentail }
    }
    catch {
        throw $_
    }

}

