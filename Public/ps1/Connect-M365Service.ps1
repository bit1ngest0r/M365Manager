function Connect-M365Service {

    [CmdletBinding()]
    Param (

        [Parameter()]
        [PSCredential]
        $AdminCredential = (Get-Credential -Message "Enter your Microsoft 365 administrator credential."),

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

    if ($PSBoundParameters.Count -eq 0) { # Default connections
        $Azure = $true
        $AzureAD = $true
        $ExchangeOnline = $true
        $MicrosoftOnline = $true
        $MicrosoftTeams = $true
        $SecurityAndComplianceCenter = $false
        $SharePointOnlinePnP = $false
    } 

    $checkConnections = Get-M365Service
    if ($Azure) {

        if ($checkConnections.Azure.Connected -ne $true) {
            try { # Try to connect to Azure RM
        
                Write-Host "Connecting to Azure..."        
                Connect-AzAccount -Credential $AdminCredential -ErrorAction Stop | Out-Null # Login to AzureRM console
                Write-Host "          Connected" -ForegroundColor Green
    
            } 
            catch { 
    
                try {
    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-AzAccount -ErrorAction Stop | Out-Null
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
    
            }
        }
        else {
            Write-Host "A connection to Azure has already been established." -ForegroundColor Yellow
        }

    }
    if ($AzureAD) { 

        if ($checkConnections.AzureAD.Connected -ne $true) {
            try { # Try to connect to Azure AD
        
                Write-Host "Connecting to AzureAD..."        
                Connect-AzureAD -Credential $AdminCredential -ErrorAction Stop | Out-Null # Login to AzureAD
                Write-Host "        Connected!" -ForegroundColor Green    
    
            } 
            catch { # If connection fails
    
                try {
    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-AzureAD -ErrorAction Stop | Out-Null
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
                
            }
        }
        else {
            Write-Host "A connection to AzureAD has already been established." -ForegroundColor Yellow
        }

    }
    if ($ExchangeOnline) { 

        if ($checkConnections.ExchangeOnline.Connected -ne $true) {
            try { # Try connecting to Exchange Online admin

                Write-Host "Connecting to ExchangeOnline..."
                Connect-ExchangeOnline -Credential $AdminCredential -ShowBanner:$false -ErrorAction Stop
                Write-Host "        Connected!" -ForegroundColor Green
                
            } 
            catch { # If the connection fails
    
                try {
                    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
    
            }
        }
        else {
            Write-Host "A connection to ExchangeOnline has already been established." -ForegroundColor Yellow
        }

    }
    if ($MicrosoftOnline) {
        
        if ($checkConnections.MicrosoftOnline.Connected -ne $true) {
            try { 
            
                Write-Host "Connecting to MicrosoftOnline..."
                Connect-MsolService -Credential $AdminCredential -ErrorAction Stop | Out-Null # Login to Microsoft Online
                Write-Host "        Connected!" -ForegroundColor Green
    
            } 
            catch {
    
                try {
    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-MsolService -ErrorAction Stop | Out-Null
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
    
            }
        }
        else {
            Write-Host "A connection to MSOL has already been established." -ForegroundColor Yellow 
        }

    }
    if ($MicrosoftTeams) { 
        
        if ($checkConnections.MicrosoftTeams.Connected -ne $true) {
            try { # Try connecting to Microsoft Teams admin

                Write-Host "Connecting to MicrosoftTeams..."
                Connect-MicrosoftTeams -Credential $AdminCredential -ErrorAction Stop | Out-Null # Login to Microsoft Teams
                Write-Host "        Connected!" -ForegroundColor Green
    
            } 
            catch { # If the connection fails
                
                try {
    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
    
            }
        }
        else {
            Write-Host "A connection to Microsoft Teams has already been established." -ForegroundColor Yellow
        }

    }
    if ($SecurityAndComplianceCenter) {

        if ($checkConnections.SecurityAndComplianceCenter.Connected -ne $true) {
            try { # Try connecting to Exchange Online admin

                Write-Host "Connecting to Security and Compliance Center..."
                Connect-IPPSSession -Credential $AdminCredential -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Host "        Connected!" -ForegroundColor Green
                
            } 
            catch { # If the connection fails
    
                try {
    
                    Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                    Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
                    Write-Host "        Connected!" -ForegroundColor Green
    
                }
                catch {
    
                    throw $_
                    
                }
                
            }
        }
        else {
            Write-Host "A connection to Security and Compliance Center has already been established." -ForegroundColor Yellow
        }

    }
    if ($SharePointOnlinePnP) {

        if ($checkConnections.SharePointOnlinePnP.Connected -ne $true) {
            try { # Try connecting to SharePoint Online PnP admin

                Write-Host "Connecting to SharePointOnlinePnP..."
                Connect-PnPOnline -Url (Read-Host -Prompt "Enter the site URL to connect to") -Credentials $AdminCredential | Out-Null
                Write-Host "        Connected!" -ForegroundColor Green
    
            } 
            catch {
    
                throw $_
                
            }
        }
        else {
            Write-Host "A connection to SharePointOnline PnP has already been established." -ForegroundColor Yellow            
        }

    }

}