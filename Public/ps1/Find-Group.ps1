function Find-Group {
    
    <#
    .SYNOPSIS

    Searches for a group in all of an Office 365 tenant's resources.

    .DESCRIPTION
    
    Searches for a group by Display Name or Email in all of an Office 365 tenant's resources.
    Searches the following groups in this order for matches:

    RoleGroups
    UnifiedGroups
    AzureAdDynamicGroups
    SecurityGroups
    DistributionGroups
    DynamicDistributionGroups
    ExchangeGroups

    .PARAMETER  AllGroups
        
    Use this paramter to return all of the groups in an Office 365 tenant's resources.
    This usually takes a while to run.

    .PARAMETER InputOnject

    Use an object to find a group, as long as the object has an attribute that resembles a group display name.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.
    This is the object on which the lookup will be performed.

    .PARAMETER ExactSearch

    Use this paramter to search for a group where the display name matches precisely the string you entered.

    .PARAMETER StartsWith
    
    Use this paramter to search for a group where the display name starts with the string you entered.

    .PARAMETER FuzzySearch

    Use this paramter to search for a group where the display name contains the string you entered anywhere in its display name.

    .PARAMETER ByEmailAddress

    Use this paramter to search for a group where the primary email address property matches the email address you entered.

    .PARAMETER ReturnDisplayNamesOnly

    Use this paramter to return only the display name of a matching group that is found.

    .EXAMPLE

    PS>$allGroups = Find-Group -AllGroups

    .EXAMPLE

    PS>Find-Group -ExactSearch 'Sales'

    Name                                                             DisplayName GroupType      PrimarySmtpAddress
    ----                                                             ----------- ---------      ------------------
    21794651-7727-4e98-9f8c-ff6_59ae4d7a-1f21-407f-b4c8-7078379c6032 Sales       Office365Group Sales@domain.com

    .EXAMPLE

    PS>Find-Group -StartsWith 'H' -ReturnDisplayNamesOnly

    Help Desk
    Helpdesk Administrator
    HR

    .EXAMPLE

    PS>Find-Group -FuzzySearch 'ops' | Select-Object DisplayName, GroupType

    DisplayName                                GroupType
    -----------                                ---------
    SysOps                                     DynamicGroup
    ITOps                                      DistributionGroup
    Sales Ops                                  MailEnabledSecurityGroup
    
    .INPUTS
    
    PSObject
    System.String
    System.Net.Mail.MailAddress

    .OUTPUTS
        
    PSObject
    System.String
    #>

    [CmdletBinding(DefaultParameterSetName = 'ExactSearch')]
    Param (
        
        [Parameter(ParameterSetName = "AllGroups")]
        [switch]
        $AllGroups,

        [Parameter(
            ParameterSetName = "Object",
            ValueFromPipeline = $true    
        )]
        $InputObject,

        [Parameter(
            ParameterSetName = "Exact",
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExactSearch,

        [Parameter(ParameterSetName = "StartsWith")]
        [ValidateNotNullOrEmpty()]
        [string]
        $StartsWith,

        [Parameter(ParameterSetName = "FuzzySearch")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FuzzySearch,

        [Parameter(ParameterSetName = "EmailAddress")]
        [System.Net.Mail.MailAddress]
        $ByEmailAddress,

        [switch]
        $ReturnDisplayNamesOnly

    )
    begin {
     
        # Check for any missing admin shell connection requirements
        $connectionAttempt = 1
        while (-not (Confirm-EssentialConnections)) { 

            Write-Warning "Required connections to admin services not active, connecting now"
            Connect-AdminServices
            $connectionAttempt++
            if ($connectionAttempt -eq 3) {

                throw "Connecting to admin services failed too many times. Please try running this script again in a few minutes."

            }
            
        }            
        
        try {

            Test-RequiredConnections

        }
        catch {

            throw $_

        }
               
    } 
    process {

        if ($InputObject) {

            $InputObject | ForEach-Object {

                try {

                    $groupName = $_ | Get-GroupName -ErrorAction Stop
                    $searchResults = Search-ExactGroupName -String $groupName
                    
                    if ($null -eq $searchResults) {
        
                        Write-Error "Unable to find group matching your query"
        
                    } 
                    else {
                    
                        $searchResults = $searchResults | Sort-Object DisplayName
                        $searchResults = $searchResults | Get-GroupType -ErrorAction SilentlyContinue
                        switch ($ReturnDisplayNamesOnly) {
        
                            $true { return $searchResults | Get-GroupName }
                            $false { return $searchResults }
                
                        }    
        
                    }

                } 
                catch {

                    Write-Error -Exception $_.Exception

                }

            }

        }
        elseif ($ExactSearch -or $StartsWith -or $FuzzySearch -or $ByEmailAddress) {

            if ($ExactSearch) {

                $searchResults = Search-ExactGroupName -String $ExactSearch

            }
            elseif ($StartsWith) {

                $searchResults = Search-GroupStartsWith -String $StartsWith

            }
            elseif ($FuzzySearch) {

                $searchResults = Search-GroupFuzzyName -String $FuzzySearch

            }
            elseif ($ByEmailAddress) {

                $searchResults = Search-GroupByEmail -EmailAddress $ByEmailAddress

            }

            if ($null -eq $searchResults) {

                Write-Error "Unable to find group matching your query"

            } 
            else {
            
                $searchResults = $searchResults | Sort-Object DisplayName
                $searchResults = $searchResults | Get-GroupType -ErrorAction SilentlyContinue

                switch ($ReturnDisplayNamesOnly) {

                    $true { return $searchResults | Get-GroupName }
                    $false { return $searchResults }
        
                }    

            }

        }
        elseif ($AllGroups) {

            $searchResults = Search-AllGroups

            if ($null -eq $searchResults) {

                Write-Error "Unable to find any groups"

            } 
            else {
            
                $searchResults = $searchResults | Sort-Object DisplayName
                $searchResults = $searchResults | Get-GroupType -ErrorAction SilentlyContinue

                switch ($ReturnDisplayNamesOnly) {

                    $true { return $searchResults | Get-GroupName }
                    $false { return $searchResults }
        
                }    

            }

        }

    }

}
