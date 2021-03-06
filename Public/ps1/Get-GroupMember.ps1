function Get-GroupMember {
    
    <#
    .SYNOPSIS

    Returns a list of members of a specified group.

    .DESCRIPTION
    
    Returns a list of members of a specified group.
    Takes any group object and attempts to determine the type of group.
    Then, it runs the cmdlet specific to that group type to retrieve the members.

    .PARAMETER GroupObject

    This parameter is mandatory.
    This is the object on which the lookup will be performed.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.

    .PARAMETER ReturnDisplayNamesOnly

    Use this parameter to return on the display name string of any members found

    .EXAMPLE

    PS>Find-Group -ExactSearch 'IT Operations' | Get-GroupMember

    Name                 RecipientType
    ----                 -------------
    John.Doe             UserMailbox
    Jane.Doe             UserMailbox
    Super.Man            UserMailbox

    .EXAMPLE

    PS>Get-GroupMember -GroupObject $group

    ObjectId                             DisplayName        UserPrincipalName              UserType
    --------                             -----------        -----------------              --------
    0a92e27f-d63f-431a-a1fb-71aa866304a8 John Doe           John.Doe@domain.com            Member
    43060285-1413-482c-9417-fc30e41a8c80 Jane Doe           Jane.Doe@domain.com            Member
    
    .INPUTS
    
    PSObject

    .OUTPUTS
        
    PSObject
    System.String
    #>

    [CmdletBinding()]
    Param(

        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $GroupObject,

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

    }
    process {

        $GroupObject | ForEach-Object {

            $groupType = $_ | Get-GroupType | Select-Object -ExpandProperty GroupType

            if ($groupType -eq "DistributionGroup") { # Distribution groups managed by *-DistributionGroup cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {
                
                    $members = Get-DistributionGroupMember -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
                    
            } 
            elseif ($groupType -eq 'DynamicDistributionGroup') {

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {
                    
                    $dynamicDistributionGroup = Get-DynamicDistributionGroup -Identity $groupObjectId
                    $members = Get-Recipient -RecipientPreviewFilter $dynamicDistributionGroup.RecipientFilter `
                        -OrganizationalUnit $dynamicDistributionGroup.RecipientContainer | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error
                }

            } 
            elseif ($groupType -eq "Office365Group") { # Office 365 Groups are managed with *-UnifiedGroupLinks cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {
                    
                    $members = Get-UnifiedGroupLinks -ResultSize Unlimited -LinkType Member -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName

                } 
                catch {

                    if ($GroupObject.Members) {

                        $members = $GroupObject.Members | ForEach-Object {

                            Get-MsolUser -SearchString $_

                        }

                    }
                    else {
                        
                        $_ | Write-Error
                    }

                }
            
            } 
            elseif ($groupType -eq "MailEnabledSecurityGroup") { # Mail-Enabled Security Groups (MESGs) qualify as distribution groups and are managed with those cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                     
                try {

                    $members = Get-DistributionGroupMember -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
            
            } 
            elseif ($groupType -eq "DynamicGroup") { # Dynamic AD group

                # Find a group identifier which can be used with MSOL cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                } 
                catch {
                   
                    Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                    return

                }

                try {
                
                    $members = Get-AzureADGroupMember -All:$true -ObjectId $groupObjectId | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
                           
            } 
            elseif ($groupType -eq "SecurityGroup") { 

                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                } 
                catch {
                   
                    Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                    return

                }
                
                try {
                
                    $members =  Get-AzureADGroupMember -All:$true -ObjectId $groupObjectId | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
            
            } 
            elseif ($groupType -eq "RoleGroup") { 

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {
                
                    $members = Get-RoleGroupMember -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
            
            } 
            elseif ($groupType -eq "RoomResource") {

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } 
                catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } 
                    catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }

                try {

                    $members = Get-DistributionGroupMember -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName

                } 
                catch {

                    $_ | Write-Error

                }
            
            }
            elseif ($groupType -eq "MailEnabledAzureADGroup") {
                
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                } 
                catch {

                    Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                    return

                }

                try {

                    Get-DistributionGroup -Identity $groupObjectId -ErrorAction Stop | Out-Null
                    $GroupObject.GroupType = "DistributionGroup"

                }
                catch {

                    $GroupObject.GroupType = "Office365Group"

                }

                try {

                    $members = Get-GroupMember -GroupObject $GroupObject -ErrorAction Stop

                }
                catch {

                    $_ | Write-Error

                }
                
            }
            else {

                Write-Error "Unable to process, as group type could not be determined."

            }

            if ($members) {
            
                switch ($ReturnDisplayNamesOnly) {
                    
                    $true { $members | Select-Object -ExpandProperty DisplayName ; Break }
                    $false { $members ; Break }

                }

            }
        
        }

        return

    }

}
