function Get-GroupType {

    <#
    .SYNOPSIS

    Determines the group type of a specified group object.

    .DESCRIPTION
    
    Determines the group type of a specified group object.
    Takes any group object and attempts to determine the type of group.
    If it cannot determine the type, it will try to run Find-Group on the object.
    Find-Group will always return the group type in the output.

    .PARAMETER GroupObject

    This parameter is mandatory.
    This is the object on which the lookup will be performed.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.

    .PARAMETER ReturnGroupTypeNameOnly

    Use this parameter to return on the GroupType string.

    .EXAMPLE

    PS>Get-MsolGroup -SearchString 'my group name' | Get-GroupType

    Name                                                   DisplayName   GroupType      PrimarySmtpAddress
    ----                                                   -----------   ---------      ------------------
    mygroupname_1902139a-c80a-43df-b5ce-e513e536141b       My Group Name Office365Group mygroupname@company.com

    .EXAMPLE

    PS>Get-GroupType -GroupObject $group -ReturnGroupTypeNameOnly

    DistributionGroup
    
    .INPUTS
    
    PSObject

    .OUTPUTS
        
    PSObject
    System.String
    #>

    [CmdletBinding()]
    Param (

        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $GroupObject,

        # Returns the full group object back with the property, GroupType        
        [Switch]
        $ReturnGroupTypeNameOnly

    )
    process {

        $GroupObject | ForEach-Object {

            if (($_.RecipientType -eq "MailUniversalDistributionGroup" `
            -and $_.RecipientTypeDetails -eq "MailUniversalDistributionGroup") `
            -or $_.GroupType -eq "DistributionList" `
            -or $_.GroupType -eq "DistributionGroup") { # Distribution Group
                        
                if ($_.GroupType -eq "DistributionGroup") { # My custom note is already set

                    $result = $_

                } else {
                
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "DistributionGroup" -Force
                    $result = $_

                }
                        
            } 
            elseif (($_.RecipientType -eq "DynamicDistributionGroup" `
            -and $_.RecipientTypeDetails -eq "DynamicDistributionGroup") `
            -or $_.GroupType -eq "DynamicDistributionGroup") { # Dynamic Distribution Group
                
                if ($_.GroupType -eq "DynamicDistributionGroup") { # My custom note is already set

                    $result = $_

                } else {
                    
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "DynamicDistributionGroup" -Force
                    $result = $_

                }
                
            } 
            elseif (($_.RecipientType -eq "MailUniversalDistributionGroup" `
            -and $_.RecipientTypeDetails -eq "GroupMailbox") `
            -or $_.GroupTypes -eq 'Unified' `
            -or $_.GroupType -eq "Office365Group") { # Office 365 Group
                    
                if ($_.GroupType -eq "Office365Group") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "Office365Group" -Force
                    $result = $_

                }
               
            } 
            elseif (($_.RecipientType -eq "MailUniversalSecurityGroup" `
            -and $_.RecipientTypeDetails -eq "MailUniversalSecurityGroup") `
            -or ($_.SecurityEnabled -and $_.MailEnabled) `
            -or $_.GroupType -eq "MailEnabledSecurity" `
            -or $_.GroupType -eq "MailEnabledSecurityGroup") { # Mail-Enabled Security Group
                
                if ($_.GroupType -eq "MailEnabledSecurityGroup") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "MailEnabledSecurityGroup" -Force
                    $result = $_

                }

            } 
            elseif ($_.GroupTypes -eq "DynamicMembership" `
            -or $_.GroupType -eq "DynamicGroup") { # Dynamic Groups
                
                if ($_.GroupType -eq "DynamicGroup") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "DynamicGroup" -Force
                    $result = $_

                }
                
            } 
            elseif ((-not $_.MailEnabled -and $_.SecurityEnabled) `
            -or $_.GroupType -eq "Security" `
            -or $_.GroupType -eq "SecurityGroup") { # Security Group
                
                if ($_.GroupType -eq "SecurityGroup") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "SecurityGroup" -Force
                    $result = $_

                }

            } 
            elseif ($_.RoleGroupType -or $_.RecipientTypeDetails -eq "RoleGroup"`
            -or $_.GroupType -eq "RoleGroup") { # Role Group

                if ($_.GroupType -eq "RoleGroup") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "RoleGroup" -Force
                    $result = $_

                }

            } 
            elseif (($_.RecipientType -eq "MailUniversalDistributionGroup"`
            -and $_.RecipientTypeDetails -eq "RoomList")`
            -or $_.GroupType -eq "RoomResource") { # Room Resource
                
                if ($_.GroupType -eq "RoomResource") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "RoomResource" -Force
                    $result = $_

                }
                
            }
            elseif ($_.MailEnabled -and -not $_.SecurityEnabled) {

                <# 
                Get-AzureADGroup has these properties
                From my research, AAD Groups with the MailEnabled property only could be either:
                    # DistributionGroup
                    # Office365Group
                No one good way to determine from the object properties.
                Too much overhead to use Get-Group in this function.
                Will return a group type string for processing in other functions.
                #> 
                if ($_.GroupType -eq "MailEnabledAzureADGroup") { # My custom note is already set

                    $result = $_

                } else {

                    Add-Member -InputObject $_ -MemberType NoteProperty -Name GroupType -Value "MailEnabledAzureADGroup" -Force
                    $result = $_

                }

            }
            else {

                Write-Error "Unable to determine group type. Please ensure you have passed a valid group object."
                
            }

            if ($result) {
            
                switch ($ReturnGroupTypeNameOnly) {

                    $true { $result | Select-Object -ExpandProperty GroupType ; Break }
                    $false { $result ; Break }

                }

            }

        }

        return

    }

}
