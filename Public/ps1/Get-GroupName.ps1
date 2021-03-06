function Get-GroupName {

    <#
    .SYNOPSIS

    Returns the name of a group as a string.

    .DESCRIPTION
    
    Returns the name of a group as a string.
    Attempts to find a display name or name property of a group object and return it as a string.

    .PARAMETER GroupObject

    This parameter is mandatory.
    This is the object on which the lookup will be performed.
    Must be fully instantiated object. Cannot be of type string, int, or otherwise. 
    Can be passed down the pipeline or by the parameter.

    .EXAMPLE

    PS>Find-Group -ExactSearch 'Sales' | Get-GroupName

    Sales

    .EXAMPLE

    PS>Get-GroupName -GroupObject $group

    Operations
    
    .INPUTS
    
    PSObject

    .OUTPUTS
        
    System.String
    #>

    [CmdletBinding()]
    Param (

        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        $GroupObject

    )

    process {

        $GroupObject | ForEach-Object {

            # Necessary for logging, as sometimes the DisplayName property is blank
            if (-not [string]::IsNullOrEmpty($_.DisplayName)) { 
                
                $groupName = $_.DisplayName
                return $groupName
                
            }
            elseif (-not [string]::IsNullOrEmpty($_.Name)) { 
                
                $groupName = $_.Name
                return $groupName
            
            }
            else { # Otherwise, just put the object into table format and output to a string
                
                Write-Error "Could not determine group name using object properties"

            }

        }

    }
    
}
