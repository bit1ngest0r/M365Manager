function Search-GroupFuzzyName {

    [CmdletBinding()]
    Param (

        [ValidateNotNullOrEmpty()]
        [string]
        $String

    )

    # Search Role Groups
    Write-Verbose "Searching in role groups..."
    $roleGroup = Get-RoleGroup -ResultSize Unlimited -ShowPartnerLinked -Filter "DisplayName -like '*$String*' -or Name -like '*$String*'"

    # Search Unified Groups
    Write-Verbose "Searching in unified groups..."
    $unifiedGroup = Get-UnifiedGroup -ResultSize Unlimited -Filter "DisplayName -like '*$String*' -or Name -like '*$String*'"            

    # Search AzureAD Groups
    Write-Verbose "Searching in AzureAD groups..."
    # Filter parameter -- at the time of programming this -- doesn't support substringof(<string>,PropertyName) queries (among other missing queries)
    $azureAdDynamicGroup = Get-AzureADMSGroup -All:$true -Filter "groupTypes/any(c:c eq 'DynamicMembership')" | Where-Object { $_.DisplayName -like "*$String*"}

    # Search Security Groups
    Write-Verbose "Searching in security groups..."
    $securityGroup = Get-MsolGroup -All:$true -GroupType Security | Where-Object { $_.DisplayName -like "*$String*" }

    # Search Distribution Groups
    Write-Verbose "Searching in distribution groups..."
    $distributionGroup = Get-DistributionGroup -ResultSize Unlimited -Filter "DisplayName -like '*$String*' -or Name -like '*$String*'"

    # Search Dynamic Distribution Groups
    Write-Verbose "Searching in dynamic distribution groups..."
    $dynamicDistributionGroup = Get-DynamicDistributionGroup -ResultSize Unlimited -Filter "DisplayName -like '*$String*' -or Name -like '*$String*'"

    # Search other Exchange Groups
    Write-Verbose "Searching in Exchange groups..."
    $exchangeGroup = Get-Group -ResultSize Unlimited -Filter "DisplayName -like '*$String*' -or Name -like '*$String*'"

    $results = @()

    Write-Verbose "Compiling sorted array of groups"
   
    # Please leave in this order
    # I have set it this way, since certain group types will be returned by different commands
    # I want to prioritize it so that certain group types get added to the array below first before others

    $results += $roleGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $unifiedGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $azureAdDynamicGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $securityGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $distributionGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $dynamicDistributionGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $exchangeGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }

    return $results

}