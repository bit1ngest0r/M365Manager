function Get-UserGroupOwnership {

    <#
    .SYNOPSIS

    Returns a list of groups of which a user or group is an owner.

    .DESCRIPTION
    
    Returns a list of groups of which a user or group is an owner.

    .PARAMETER InputObject

    This parameter is mandatory when not searching by name or email.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.
    This is the object on which the lookup will be performed.

    .PARAMETER MemberType

    Used during name or email lookups.
    Must specify whether the object you are searching for is a user or group object.

    .PARAMETER Name

    Accepts a string and will try to find a user or group based on the MemberType.

    .PARAMETER EmailAddress

    Accepts a string in email address format only.
    Will try to find a user or group based on the MemberType.

    .PARAMETER ReturnDisplayNamesOnly

    If switched on, only the groups' -- if any -- DisplayNames are returned.
    
    .EXAMPLE

    PS>Get-MsolUser -SearchString 'John Doe' | Get-UserGroupOwnership

    ObjectId                               DisplayName                                       GroupType                                         Description
    --------                               -----------                                       ---------                                         -----------
    01594266-1dae-47dc-9871-3d3118728988   Test Group                                        SecurityGroup                                     Test Group

    .EXAMPLE

    PS>Get-UserGroupOwnership -Name 'John Doe' -MemberType User -ReturnDisplayNamesOnly

    Test Group

    .INPUTS
       
    PSObject. Can be passed down the pipeline.
    System.String
    System.Net.Mail.MailAddres

    .OUTPUTS
        
    PSObject
    System.String
    #>

    [CmdletBinding()]
    param (
     
        [Parameter(
            ParameterSetName = "UserObject",
            ValueFromPipeline = $true   
        )]
        $InputObject,

        [Parameter(
            Mandatory = $true, 
            ParameterSetName = "Name"
        )]
        [Parameter(
            Mandatory = $true, 
            ParameterSetName = "Email"
        )]
        [ValidateSet("User", "Group")]
        [string]
        $OwnerType,

        [Parameter(ParameterSetName = "Name")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(ParameterSetName = "Email")]
        [System.Net.Mail.MailAddress]
        $EmailAddress,

        [switch]
        $ReturnDisplayNamesOnly

    )
    begin {

        try {

            Test-RequiredConnections

        }
        catch {

            throw $_

        }

        if ($Name) { # Searching by Name

            if ($OwnerType -eq "User") {
            
                $InputObject = Get-AzureADUser -SearchString $Name -ErrorAction Stop

            } 
            else {
            
                $InputObject = Find-Group -ExactSearch $Name

            }
            
            if (-not($InputObject)) { 
                
                if ($MemberType -eq "User") {
                    
                    throw "User not found" 
                
                } 
                else {

                    throw "Group not found"

                }

            }

        } 
        elseif ($EmailAddress) { # Searching by Email

            if ($OwnerType -eq "User") {
            
                $InputObject = Get-AzureADUser -SearchString $EmailAddress -ErrorAction Stop

            } 
            else {

                if (-not($InputObject)) { $InputObject = Find-Group -ByEmailAddress $EmailAddress }

            }
            
            if (-not($InputObject)) { 
                
                if ($MemberType -eq "User") {
                    
                    throw "User not found" 
                
                } 
                else {

                    throw "Group not found"

                }

            }

        }

    
    }
    process {

        $InputObject | ForEach-Object {

            Write-Verbose -Message "Gathering Exchange groups."

            try {

                $primaryEmailAddress = $_ | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                $exchangeRecipientObject = Get-Recipient -Identity $primaryEmailAddress -ErrorAction Stop
                $exchangeRecipientDistinguishedNames = $exchangeRecipientObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                $exchangeOnlineGroups = Get-Recipient -Filter "ManagedBy -eq '$exchangeRecipientDistinguishedNames'" -ErrorAction Stop
                $otherExchangeOnlineGroups = Get-Group -Filter "ManagedBy -eq '$exchangeRecipientDistinguishedNames'" -ErrorAction Stop

            }
            catch {

                Out-Null

            }
            
            Write-Verbose -Message "Gathering Azure AD groups."
            try { 
                
                $azureAdGroups = Get-AzureADUserOwnedObject `
                    -ObjectId ($_ | Find-ObjectIdentifier -ObjectId -ErrorAction Stop) `
                    -All:$true `
                    -ErrorAction Stop | 
                        Where-Object { $_.ObjectType -eq "Group" }

            } 
            catch {

                Out-Null

            }
            
            $ownedGroups = @()
            $ownedGroups += $exchangeOnlineGroups
            $ownedGroups += $otherExchangeOnlineGroups | Where-Object { $_.DisplayName -notin $ownedGroups.DisplayName }
            $ownedGroups += $azureAdGroups | Where-Object {$_.DisplayName -notin $ownedGroups.DisplayName }

            if ($ownedGroups) {

                $ownedGroups = $ownedGroups | Sort-Object DisplayName
                $ownedGroups = $ownedGroups | Get-GroupType -ErrorAction SilentlyContinue
    
                switch ($ReturnDisplayNamesOnly) {

                    $true { $ownedGroups | Select-Object -ExpandProperty DisplayName ; Break }
                    $false { $ownedGroups ; Break }

                }

            } 
            else {

                return

            }

        }

    }

}
