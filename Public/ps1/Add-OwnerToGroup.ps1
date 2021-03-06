function Add-OwnerToGroup {

    <#
    .SYNOPSIS

    Adds a user or group as an owner of a specified group.

    .DESCRIPTION
    
    Adds a user or group as an owner of a specified group.
    Takes an input object and attemps to assign it to a specified group.

    .PARAMETER GroupObject

    This parameter is mandatory.
    Must be a fully instantiated object. Cannot be of type string, int, or otherwise.
    This is the group to which the input object will be added.

    .PARAMETER InputObject

    This parameter is mandatory.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.
    This is the object that will be added to the group.
            
    .EXAMPLE

    PS>Add-OwnerToGroup -GroupObject $thisGroup -InputObject $thatGroup

    .EXAMPLE

    PS>Get-MsolUser -SearchString 'John Doe' | Add-OwnerToGroup -GroupObject $Group

    .INPUTS
       
    PSObject. Can be passed down the pipeline.

    .OUTPUTS
        
    None.
    #>

    [CmdletBinding()]
    Param(

        [Parameter(Mandatory=$true)]     
        $GroupObject,

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $InputObject

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
        
            $group = $_
            $groupType = $group | Get-GroupType | Select-Object -ExpandProperty GroupType

            $InputObject | ForEach-Object {

                $pipelineObject = $_

                if ($groupType -eq "DistributionGroup") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }                

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }

                } 
                elseif ($groupType -eq "DynamicDistributionGroup") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }                
                    
                    Write-Warning "Dynamic Distribution Groups can only have one owner."
                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Set-DynamicDistributionGroup -Identity $groupObjectId -ManagedBy $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DynamicDistributionGroup -Identity $groupObjectId -ManagedBy $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DynamicDistributionGroup -Identity $groupObjectId -ManagedBy $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }                
                    
                } 
                elseif ($groupType -eq "Office365Group") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }                

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }

                } 
                elseif ($groupType -eq "MailEnabledSecurityGroup") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }

                } 
                elseif ($groupType -eq "DynamicGroup") {

                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                    } catch {
                    
                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }                

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop
                        Add-AzureADGroupOwner -ObjectId $groupObjectId -RefObjectId $ownerObjectId -WarningAction SilentlyContinue

                    } catch {

                        $_ | Write-Error

                    }

                } 
                elseif ($groupType -eq "SecurityGroup") {

                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                    } catch {
                    
                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop
                        Add-AzureADGroupOwner -ObjectId $groupObjectId -RefObjectId $ownerObjectId -WarningAction SilentlyContinue

                    } catch {

                        $_ | Write-Error

                    }

                } 
                elseif ($groupType -eq "RoleGroup") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }                

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = ($pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop) -split "@" | Select-Object -First 1
                        $groupOwners = Get-RoleGroup -Identity $groupObjectId | Select-Object -ExpandProperty ManagedBy
                        if ($groupOwners -match $ownerObjectId) { continue } else { $groupOwners += $ownerObjectId } # If the group owners already contains the user, continue, else add the user to the array
                        Set-RoleGroup -Identity $groupObjectId -ManagedBy $groupOwners -BypassSecurityGroupManagerCheck -WarningAction SilentlyContinue # Set the new Role Group owners to the array

                    } catch {

                        $_ | Write-Error

                    }

                } 
                elseif ($groupType -eq "RoomResource") {

                    # Find a group identifier which can be used with Exchange cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop

                    } catch {

                        try {

                            $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                        } catch {

                            Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                            return

                        }

                    }

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Add=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }
                    
                }
                elseif ($groupType -eq "MailEnabledAzureADGroup") {
                    
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop

                    } catch {

                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                    try {

                        Get-DistributionGroup -Identity $groupObjectId -ErrorAction Stop | Out-Null
                        $group.GroupType = "DistributionGroup"

                    }
                    catch {

                        $group.GroupType = "Office365Group"

                    }

                    try {

                        Add-OwnerToGroup -GroupObject $group -InputObject $pipelineObject -ErrorAction Stop

                    }
                    catch {

                        $_ | Write-Error

                    }
                    
                }
                else {

                    Write-Error "Unable to process, as group type could not be determined."

                }

            }

        }

    }

}
