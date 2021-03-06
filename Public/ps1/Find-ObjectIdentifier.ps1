function Find-ObjectIdentifier {
    
    <#
    .SYNOPSIS

    Returns a string containing the unique identifier of an object.

    .DESCRIPTION
    
    Returns a string containing the unique identifier of an object as specified by parameters.

    .PARAMETER InputObject

    This parameter is mandatory.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.
    This is the object on which the lookup will be performed.

    .PARAMETER PrimaryEmailAddress

    When specified, the function will return a string containing the object's PrimarySmtpAddress.

    .PARAMETER UPN

    When specified, the function will return a string containing the object's UserPrincipalName.

    .PARAMETER ObjectId

    When specified, the function will return a string containing the object's Guid.

    .PARAMETER DistinguishedName

    When specified, the function will return a string containing the object's X.509 DistinguishedName.
    
    .EXAMPLE

    PS>Get-MsolUser -SearchString 'John Doe' | Find-ObjectIdentifier -ObjectId

    d32f7df1-89de-471b-ba9c-dcdc71db3923

    .EXAMPLE

    PS>Find-ObjectIdentifier -InputObject (Get-User -Identity 'john doe') -PrimaryEmailAddress

    john.doe@domain.com

    Test Group

    .INPUTS
       
    PSObject. Can be passed down the pipeline.

    .OUTPUTS
        
    System.String
    #>

    [CmdletBinding()]
    Param (
    
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $InputObject,

        [Parameter(ParameterSetName = "Email")]
        [switch]
        $PrimaryEmailAddress,

        [Parameter(ParameterSetName = "UPN")]
        [switch]
        $UserPrincipalName,
        
        [Parameter(ParameterSetName = "ObjectId")]
        [switch]
        $ObjectId,

        [Parameter(ParameterSetName = "DistinguishedName")]
        [switch]
        $DistinguishedName

    )
    
    process {

        $InputObject | ForEach-Object {

            if ($PrimaryEmailAddress) { # If this parameter is switched

                if ($_.WindowsEmailAddress) { 
                    
                    <# The following cmdlets return objects with the WindowsEmailAddress property
                    Get-CsOnlineUser
                    Get-User
                    Get-DistributionGroup
                    Get-DynamicDistributionGroup
                    Get-Group
                    #>

                    return $_.WindowsEmailAddress 
                
                }
                
                elseif ($_.Mail) { return $_.Mail } # Get-AzureADDeviceRegisteredUser, Get-AzureADUser, Get-AzureADGroup return an object with this identifier
                elseif ($_.UserPrincipalName) { return $_.UserPrincipalName -replace 'phishme.com', 'cofense.com' } # Get-AzureRmADUser and Get-MsolUser return an object with this identifier
                elseif ($_.SipAddress) { return $_.SipAddress.Split(":")[1] -replace 'phishme.com', 'cofense.com' } # Get-CsOnlineDialInConferencingUser returns an object with this identifier
                elseif ($_.Name -and $_.SipDomain) { return "$($_.Name -replace " ", ".")@$($_.SipDomain)" -replace 'phishme.com', 'cofense.com' } # Get-CsOnlineVoiceUser returns an object with this identifier
                elseif ($_.Email) { return $_.Email -replace 'phishme.com', 'cofense.com' } # Get-PnPUser returns an object with this identifier
                elseif ($_.EmailAddress) { return $_.EmailAddress } # Get-MsolGroup returns an object with this identifier
                elseif ($_.LoginName) { return $_.LoginName -replace 'phishme.com', 'cofense.com' } # Get-SPOUser returns an object with this identifier
                elseif ($_.User) { return $_.User -replace 'phishme.com', 'cofense.com' } # Get-TeamUser returns an object with this identifieer
                elseif ($_.PrimarySmtpAddress) { return $_.PrimarySmtpAddress } # Get-UnifiedGroup, Get-DistributionGroup, Get-DynamicDistributionGroup return an object with this identifieer
                else { Write-Error "Unable to determine the PrimaryEmailAddress for this object" }

            }
            if ($UserPrincipalName) { # If this parameter is switched

                if ($_.UserPrincipalName) { 
                    
                    <# The following cmdlets return objects with the UserPrincipalName property
                    Get-AzureADDeviceRegisteredUser
                    Get-AzureRmADUser
                    Get-AzureADUser
                    Get-CsOnlineUser
                    Get-MsolUser
                    Get-User
                    #>

                    $_.UserPrincipalName 
                
                }
                elseif ($_.SipAddress) { return $_.SipAddress.Split(":")[1] } # Get-CsOnlineDialInConferencingUser returns an object with this identifier
                elseif ($_.Name -and $_.SipDomain) { return "$($_.Name -replace " ", ".")@$($_.SipDomain)" } # Get-CsOnlineVoiceUser returns an object with this identifier
                elseif ($_.Email) { return $_.Email } # Get-PnPUser returns an object with this identifier
                elseif ($_.LoginName) { return $_.LoginName } # Get-SPOUser returns an object with this identifier
                elseif ($_.User) { return $_.User } # Get-TeamUser returns an object with this identifieer
                else { Write-Error "Unable to determine the UserPrincipalName for this object" }

            }
            if ($ObjectId) { # If this parameter is switched

                if ($_.ObjectId) { 
                
                    <# The following cmdlets return objects with ObjectId property
                    Get-AzureADGroup
                    Get-AzureADUser
                    Get-AzureADDeviceRegisteredUser
                    Get-MsolGroup
                    Get-MsolUser
                    #>


                    if ($_.ObjectId.Guid) {

                        return $_.ObjectId.Guid
                    
                    } else {

                        return $_.ObjectId

                    }
                
                }
                elseif ($_.ExternalDirectoryObjectId) { 
                
                    <# The following cmdlets return objects with ExternalDirectoryObjectId property
                    Get-DistributionGroup
                    Get-Group
                    Get-RoleGroup
                    Get-UnifiedGroup
                    Get-User
                    #>
                    
                    return $_.ExternalDirectoryObjectId 
                
                }
                elseif ($_.Id) { try { return [guid]::new($_.Id).Guid } catch { Write-Error "Unable to determine the ObjectId for this object" } } # Get-AzureADMSGroup, Get-AzureRmADUser, Get-CsOnlineVoiceUser return an object with this identifier
                elseif ($_.Identity) { try { return [guid]::new($_.Identity.RawIdentity.Split("=")[1].Split(",")[0]).Guid } catch { Write-Error "Unable to determine the ObjectId for this object" } } # Get-CsOnlineDialInConferencingUser returns an object with this identifier
                elseif ($_.Name) { try { return [guid]::new($_.Name).Guid } catch { Write-Error "Unable to determine the ObjectId for this object" } } # Get-CsOnlineUser returns an object with this identifier
                else { Write-Error "Unable to determine the ObjectId for this object" }

            }
            if ($DistinguishedName) { # If this parameter is switched

                if ($_.DistinguishedName) { return $_.DistinguishedName } # Only pertains to objects returned by Exchange cmdlets
                else { Write-Error "Unable to determine the DistinguishedName for this object" }

            }

        }

    }

}
