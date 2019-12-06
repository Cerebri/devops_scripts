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
$SubscriptionIds = Get-AzureRmSubscription | Select-Object -Property Id

# Give me all labs in the subscription
if ($LabName) {
    Write-Verbose "Getting lab $($LabName)"
    [Array] $devTestLabs = Find-AzureRmResource -ResourceType 'Microsoft.DevTestLab/labs' -ResourceNameEquals $LabName
}
else {
    [Array] $devTestLabs = Find-AzureRmResource -ResourceType 'Microsoft.DevTestLab/labs'
}
foreach ($devTestLab in $devTestLabs) {
    Write-Output "Processing lab $($devTestLab.Name)..."
    $schedule = $null
    $labHealthy = $true
    
# Get the AS policy status in the lab
    try {
        $schedule = Get-AzureRmResource -ResourceId "$($devTestLab.ResourceId)/schedules/LabVmsShutdown" -ApiVersion 2016-05-15
    }
    catch {
        Write-Warning "Lab $($devTestLab.Name) auto-shutdown policy is disabled or no longer present"
        $labHealthy = $false
        continue
    }

    $schedDisabled = $false
    if ($schedule.Properties.status -ne 'Enabled') {
        Write-Warning "Lab $($devTestLab.Name) auto-shutdown policy is disabled"
        $schedDisabled = $true
        $labHealthy = $false
    }

   if (-not $schedDisabled) {
        # Get all the VMs in the lab for an override
        [Array] $virtualMachines = Get-AzureRmResource -ResourceId "$($devTestLab.ResourceId)/virtualmachines" -ApiVersion 2016-05-15
        foreach ($virtualMachine in $virtualMachines) {
            Write-Host -NoNewline "   >>> Processing virtual machine: "
            Write-Host -NoNewline "$($virtualMachine.Name)" -ForegroundColor Green
            Write-Host -NoNewline " Machine Size: "
            Write-Host -NoNewline "$($($virtualMachine.Properties).Size)" -ForegroundColor Cyan
            # Get the tag and use it to determine AS status
            $tags = $virtualMachine.Tags;
            if ($tags -and $tags["AlwaysOn"] -eq "true") {
                Write-Host " Auto-shutdown status is disabled" -ForegroundColor Red
                $labHealthy = $false
                }
            else
            {
                Write-Host ""
            }
            $vmSchedule = $null
            try {
                $vmSchedule = Get-AzureRmResource -ResourceId "$($devTestLab.ResourceId)/virtualmachines/$($virtualMachine.Name)/schedules/LabVmsShutdown" -ApiVersion 2016-05-15
            }
            catch {

            }
            if (($vmSchedule -ne $null) -and ($vmSchedule.Properties.status -ne 'Enabled')) {
                Write-Host "   >>> Virtual machine $($virtualMachine.Name) auto-shutdown status is disabled" -ForegroundColor Red
                $labHealthy = $false
            }
        }
    }
    if ($labHealthy) {
        Write-Host "$($devTestLab.Name) is fully opted-in to Auto-Shutdown" -ForegroundColor Green
    }
}
