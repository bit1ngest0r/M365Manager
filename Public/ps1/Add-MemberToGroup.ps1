function Add-MemberToGroup {

    <#
    .SYNOPSIS

    Adds a user or group as a member of a specified group.

    .DESCRIPTION
    
    Adds a user or group as a member of a specified group.
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

    PS>Add-MemberToGroup -GroupObject $thatGroup -InputObject $thisGroup

    .EXAMPLE

    PS>Get-MsolUser -SearchString 'John Doe' | Add-MemberToGroup -GroupObject $Group

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
                        $memberObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $memberObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $memberObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }

                } 
                elseif ($groupType -eq "DynamicDistributionGroup") {

                    $groupName = Get-GroupName -Group $group # Sometimes the DisplayName property is blank
                    Write-Error "$groupName is a Dynamic Distribution Group. Membership rules define group membership."

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
                        $memberObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Member -Links $memberObjectId -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $memberObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Member -Links $memberObjectId -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $memberObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Add-UnifiedGroupLinks -Identity $groupObjectId -LinkType Member -Links $memberObjectId -Confirm:$false -WarningAction SilentlyContinue

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
                        $memberObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $memberObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $memberObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Add-DistributionGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

                    }

                } 
                elseif ($groupType -eq "DynamicGroup") {

                    $groupName = Get-GroupName -Group $group # Sometimes the DisplayName property is blank
                    Write-Error "$groupName is a Dynamic Group. Membership rules define group membership."

                } 
                elseif ($groupType -eq "SecurityGroup") {

                    # Find a group identifier which can be used with MSOL cmdlets
                    try {

                        $groupObjectId = $group | Find-ObjectIdentifier -ObjectId -ErrorAction Stop

                    } catch {
                    
                        Write-Error "Group identifier could not be found using object properties and cannot continue processing"
                        return

                    }

                    try {
                        
                        $memberObjectId = $pipelineObject | Find-ObjectIdentifier -ObjectId -ErrorAction Stop
                        Add-MsolGroupMember -GroupObjectId $groupObjectId -GroupMemberObjectId $memberObjectId -ErrorAction Stop

                    } catch {

                        Write-Error -Exception $_.Exception

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
                        $memberObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                        Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                    } catch {

                        try {

                            # Second, since both user and group objects from different pipelines will have an Email property
                            $memberObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                            Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                        } catch {

                            try {

                                # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                $memberObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue

                            } catch {

                                $_ | Write-Error

                            }

                        }

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

                    if ($pipelineObject.RecipientTypeDetails -eq "RoomMailbox") {

                        try {
                        
                            # First, since both user and group Exchange objects will have a DistinguishedName property
                            $memberObjectId = $pipelineObject | Find-ObjectIdentifier -DistinguishedName -ErrorAction Stop
                            Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue
        
                        } catch {
        
                            try {
        
                                # Second, since both user and group objects from different pipelines will have an Email property
                                $memberObjectId = $pipelineObject | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction Stop
                                Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue
        
                            } catch {
        
                                try {
        
                                    # Last, since only user objects from different pipelines will have an UserPrincipalName property
                                    $memberObjectId = $pipelineObject | Find-ObjectIdentifier -UserPrincipalName -ErrorAction Stop
                                    Add-RoleGroupMember -Identity $groupObjectId -Member $memberObjectId -BypassSecurityGroupManagerCheck -Confirm:$false -WarningAction SilentlyContinue
        
                                } catch {
        
                                    $_ | Write-Error
        
                                }
        
                            }
        
                        }
                
                    } else {
                        
                        Write-Warning -Message "Object is not type: room mailbox"

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

                        Add-MemberToGroup -GroupObject $group -InputObject $pipelineObject -ErrorAction Stop

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
