function Get-GroupOwner {

    <#
    .SYNOPSIS

    Returns a list of owners of a specified group.

    .DESCRIPTION
    
    Returns a list of owners of a specified group.
    Takes any group object and attempts to determine the type of group.
    Then, it runs the cmdlet specific to that group type to retrieve the owners.

    .PARAMETER GroupObject

    This parameter is mandatory.
    This is the object on which the lookup will be performed.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.

    .PARAMETER ReturnDisplayNamesOnly

    Use this parameter to return on the display name string of any owners found

    .EXAMPLE

    PS>Find-Group -ExactSearch 'IT Operations' | Get-GroupOwner

    Name                 RecipientType
    ----                 -------------
    John.Doe             UserMailbox
    Jane.Doe             UserMailbox
    Super.Man            UserMailbox

    .EXAMPLE

    PS>Get-GroupOwner -GroupObject $group

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

            if ($groupType -eq "DistributionGroup") { # Distribution groups manged by *-DistributionGroup cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }                
                
                try {

                    $owners = Get-DistributionGroup -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object ManagedBy | 
                        Select-Object -ExpandProperty ManagedBy | 
                            ForEach-Object { 
                                
                                $pipelineObjectIsUser = Get-User -Filter "Name -eq '$_'"
                                if (-not($pipelineObjectIsUser)) { $pipelineObjectIsGroup = Get-Group -Filter "Name -eq '$_'" }
                                if ($pipelineObjectIsUser) { $pipelineObjectIsUser } else { $pipelineObjectIsGroup }
                                                            
                            }

                } catch {
                    
                    $_ | Write-Error

                }

            } 
            elseif ($groupType -eq 'DynamicDistributionGroup') {

                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }                
                
                try {

                    $owners = Get-DynamicDistributionGroup -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object ManagedBy | 
                        Select-Object -ExpandProperty ManagedBy | 
                            ForEach-Object { 
                                
                                $pipelineObjectIsUser = Get-User -Filter "Name -eq '$_'"
                                if (-not($pipelineObjectIsUser)) { $pipelineObjectIsGroup = Get-Group -Filter "Name -eq '$_'" }
                                if ($pipelineObjectIsUser) { $pipelineObjectIsUser } else { $pipelineObjectIsGroup }
                                                            
                            }

                } catch {
                    
                    $_ | Write-Error

                }

            } 
            elseif ($groupType -eq "Office365Group") { # O365 groups managed by *-UnifiedGroupLinks cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }                

                try {

                    $owners = Get-UnifiedGroupLinks -ResultSize Unlimited -LinkType Owner -Identity $groupObjectId -ErrorAction Stop | Sort-Object DisplayName
                
                } catch {

                    $_ | Write-Error

                }
                    
            } 
            elseif ($groupType -eq "MailEnabledSecurityGroup") { # Mail-Enabled Security Groups (MESGs) qualify as distribution groups and are managed with those cmdlets

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }                
                
                try {
                    
                    $owners = Get-DistributionGroup -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object ManagedBy | 
                        Select-Object -ExpandProperty ManagedBy | 
                            ForEach-Object { 
                                
                                $pipelineObjectIsUser = Get-User -Filter "Name -eq '$_'"
                                if (-not($pipelineObjectIsUser)) { $pipelineObjectIsGroup = Get-Group -Filter "Name -eq '$_'" }
                                if ($pipelineObjectIsUser) { $pipelineObjectIsUser } else { $pipelineObjectIsGroup}
                                                            
                            }

                } catch {

                    $_ | Write-Error

                }

            } 
            elseif ($groupType -eq "SecurityGroup") { 
                
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                } catch {
                   
                    Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                    return

                }

                try {
                
                    $owners = Get-AzureADGroupOwner -All:$true -ObjectId $groupObjectId | Sort-Object DisplayName

                } catch {

                    $_ | Write-Error

                }
                        
            } 
            elseif ($groupType -eq "DynamicGroup") { # Dynamic AD group

                # Find a group identifier which can be used with MSOL cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                } catch {
                   
                    Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                    return

                }
                
                try {
                
                    $owners = Get-AzureADGroupOwner -All:$true -ObjectId $groupObjectId | Sort-Object DisplayName

                } catch {

                    $_ | Write-Error

                }
                                      
            } 
            elseif ($groupType -eq "RoleGroup") { # Role groups already have owner info populated in the group object

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {

                    $owners = Get-RoleGroup -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object ManagedBy | 
                        Select-Object -ExpandProperty ManagedBy | 
                            ForEach-Object { 
                        
                                $pipelineObjectIsUser = Get-User -Filter "Name -eq '$_'"
                                if (-not($pipelineObjectIsUser)) { $pipelineObjectIsGroup = Get-Group -Filter "Name -eq '$_'" }
                                if ($pipelineObjectIsUser) { $pipelineObjectIsUser } else { $pipelineObjectIsGroup}
                                                            
                            }

                } catch {

                    $_ | Write-Error

                }

            } 
            elseif ($groupType -eq "RoomResource") {

                # Find a group identifier which can be used with Exchange cmdlets
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                } catch {

                    try {

                        $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                }
                
                try {
                
                    $owners = Get-DistributionGroup -ResultSize Unlimited -Identity $groupObjectId -ErrorAction Stop | Sort-Object ManagedBy | 
                        Select-Object -ExpandProperty ManagedBy | 
                            ForEach-Object { 
                                
                                $pipelineObjectIsUser = Get-User -Filter "Name -eq '$_'"
                                if (-not($pipelineObjectIsUser)) { $pipelineObjectIsGroup = Get-Group -Filter "Name -eq '$_'" }
                                if ($pipelineObjectIsUser) { $pipelineObjectIsUser } else { $pipelineObjectIsGroup}
                                                            
                            }

                } catch {

                    $_ | Write-Error

                }
                                                
            }
            elseif ($groupType -eq "MailEnabledAzureADGroup") {
                
                try {

                    $groupObjectId = $GroupObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                } catch {

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

                    $owners = Get-GroupOwner -GroupObject $GroupObject -ErrorAction Stop

                }
                catch {

                    $_ | Write-Error

                }
                
            } 
            else {

                Write-Error "Unable to process, as group type could not be determined."

            }

            if ($owners) {
                
                switch ($ReturnDisplayNamesOnly) {
                    
                    $true { $owners | Select-Object -ExpandProperty DisplayName ; Break }
                    $false { $owners ; Break }

                }

            }

        }

        return

    }
    
}
