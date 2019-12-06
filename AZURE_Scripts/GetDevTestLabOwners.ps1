  [CmdletBinding()]

  param
  (
    [Parameter(HelpMessage = "If you want to optionally target specific subscriptions instead of all of them, pass them in as a set")]

    [Array] $SubscriptionIds,

    [Parameter(HelpMessage = "If you want to optionally target a specific lab instead of all of them, pass the name in")]

    [String] $LabName

  )

  $console = (Get-Host).PrivateData
  $console.VerboseForegroundColor = "Gray"
  $VerbosePreference = "continue"
  $console.WarningForegroundColor = "Yellow"
  $WarningPreference = 'continue'
  $SubscriptionIds = Get-AzSubscription | Select-Object -Property Id

  # Give me all labs in the subscription
  if ($LabName) {
    Write-Verbose "Getting lab $($LabName)"
    [Array] $devTestLabs = Get-AzResource -ResourceType 'Microsoft.DevTestLab/labs' -ResourceNameEquals $LabName
  }
  else {
    [Array] $devTestLabs = Get-AzResource -ResourceType 'Microsoft.DevTestLab/labs'
  }
  foreach ($devTestLab in $devTestLabs) {
    Write-Output "Processing lab $($devTestLab.Name)..."
    [Array] $virtualMachines = Get-AzResource -ResourceId "$($devTestLab.ResourceId)/virtualmachines" -ApiVersion 2016-05-15
    $results = @()
    foreach ($virtualMachine in $virtualMachines) {
      $results += [pscustomobject]@{Name = $($virtualMachine.Name); Size = $($($virtualMachine.Properties).Size); Owner = $($($virtualMachine.Properties).ownerUserPrincipalName); CreatedBy = $($($virtualMachine.Properties).createdByUser) }
    }
    $results | Format-Table
    Write-Output "There are $($results.Count) VM's in this Lab."
    Write-Output ""
  }
