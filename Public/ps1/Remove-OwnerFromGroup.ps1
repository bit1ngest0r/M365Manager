function Remove-OwnerFromGroup {
     
    <#
    .SYNOPSIS

    Removes a user or group from ownership of a specified group.

    .DESCRIPTION
    
    Removes a user or group from ownership of a specified group.
    Takes an input object and attemps to remove it from a specified group.

    .PARAMETER GroupObject

    This parameter is mandatory.
    Must be a fully instantiated object. Cannot be of type string, int, or otherwise.
    This is the group from which the input object will be removed.

    .PARAMETER InputObject

    This parameter is mandatory.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.
    This is the object that will be remove from the group.
            
    .EXAMPLE

    PS>Remove-OwnerFromGroup -GroupObject $thatGroup -InputObject $thisGroup

    .EXAMPLE

    PS>Get-MsolUser -SearchString 'John Doe' | Remove-OwnerFromGroup -GroupObject $Group

    .INPUTS
       
    PSObject. Can be passed down the pipeline.

    .OUTPUTS
        
    None.
    #>
    
    [CmdletBinding()]
    Param(

        [Parameter(Mandatory = $true)]     
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
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

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

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

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
                        Remove-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Remove-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Remove-UnifiedGroupLinks -Identity $groupObjectId -LinkType Owner -Links $ownerObjectId -Confirm:$false

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
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }    
                    
                } 
                elseif ($groupType -eq "DynamicGroup") {

                    # Find a group identifier which can be used with MSOL cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                    } catch {
                    
                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }
                    

                    try {
                        
                        # First, since both user and group Exchange objects will have a DistinguishedName property
                        $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop
                        Remove-AzureADGroupOwner -ObjectId $groupObjectId -OwnerId $ownerObjectId

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
                        Remove-AzureADGroupOwner -ObjectId $groupObjectId -OwnerId $ownerObjectId

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
                        if ($groupOwners -notmatch $ownerObjectId) { continue } else { $groupOwners = $groupOwners | Where-Object { $pipelineObject -ne $ownerObjectId } } # If the group owners doesn't contain the user, continue, else remove the user to the array
                        Set-RoleGroup -Identity $groupObjectId -ManagedBy $groupOwners -BypassSecurityGroupManagerCheck # Set the new Role Group owners to the array

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
                        Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $ownerObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Set-DistributionGroup -Identity $groupObjectId -ManagedBy @{Remove=$ownerObjectId} -BypassSecurityGroupManagerCheck -Confirm:$false

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

                        Remove-OwnerFromGroup -GroupObject $group -InputObject $pipelineObject -ErrorAction Stop

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
