function Get-UserGroupAssignment {
    
    <#
    .SYNOPSIS

    Returns a list of groups of which a user or group is a member.

    .DESCRIPTION
    
    Returns a list of groups of which a user or group is a member.

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

    PS>Get-MsolUser -SearchString 'John Doe' | Get-UserGroupAssignment

    ObjectId                               DisplayName                                       GroupType                                         Description
    --------                               -----------                                       ---------                                         -----------
    01594266-1dae-47dc-9871-3d3118728988   Test Group                                        SecurityGroup                                     Test Group

    .EXAMPLE

    PS>Get-UserGroupAssignment -Name 'John Doe' -MemberType User -ReturnDisplayNamesOnly

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
        $MemberType,

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

            if ($MemberType -eq "User") {
            
                $InputObject = Get-MsolUser -ReturnDeletedUsers -SearchString $Name -ErrorAction Stop
                if (-not($InputObject)) { $InputObject = Get-MsolUser -SearchString $Name -ErrorAction Stop }

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

            if ($MemberType -eq "User") {
            
                $InputObject = Get-MsolUser -ReturnDeletedUsers -SearchString $EmailAddress.Address.Split("@")[0] -ErrorAction Stop
                if (-not($InputObject)) { $InputObject = Get-MsolUser -SearchString $EmailAddress.Address.Split("@")[0] -ErrorAction Stop }

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
                $exchangeOnlineGroups = Get-Recipient -Filter "Members -eq '$exchangeRecipientDistinguishedNames'" -ErrorAction Stop
                $otherExchangeOnlineGroups = Get-Group -Filter "Members -eq '$exchangeRecipientDistinguishedNames'" -ErrorAction Stop

            }
            catch {

                Out-Null

            }

            Write-Verbose -Message "Gathering Azure AD groups."
            try {
                
                $azureAdGroups = Get-AzureADUserMembership `
                    -ObjectId ($_ | Find-ObjectIdentifier -ObjectId -ErrorAction Stop) `
                    -All:$true `
                    -ErrorAction Stop | 
                        Where-Object { $_.ObjectType -eq "Group" }

            } 
            catch {

               Out-Null
                
            }

            Write-Verbose -Message "Filtering and compiling groups"
            $memberOf = @()
            $memberOf += $exchangeOnlineGroups
            $memberOf += $otherExchangeOnlineGroups | Where-Object { $_.DisplayName -notin $memberOf.DisplayName }
            $memberOf += $azureAdGroups | Where-Object { $_.DisplayName -notin $memberOf.DisplayName }
            
            if ($memberOf) {

                $memberOf = $memberOf | Sort-Object DisplayName
                $memberOf = $memberOf | Get-GroupType -ErrorAction SilentlyContinue
    
                switch ($ReturnDisplayNamesOnly) {

                    $true { return $memberOf | Select-Object -ExpandProperty DisplayName }
                    $false { return $memberOf }

                }

            } 
            else {

                return

            }

        }

    }

}
