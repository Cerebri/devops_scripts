Param(
[string]$ResourceGroup
)

# Setting error and warning action preferences
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

$ExtensionName="OSPatchingForLinux"
$version="2.3"
$Publisher="Microsoft.OSTCExtensions"
# The OS updates for “ImportantAndRecommended” patches will start at “03:00” on “Sunday” and “Wednesday” every week.
$PrivateConfig = '{
    "disabled" : "False",
    "stop" : "False",
    "rebootAfterPatch" : "RebootIfNeed",
    "intervalOfWeeks" : "1",
    "dayOfWeek" : "Sunday|Wednesday",
    "startTime" : "03:00",
    "category" : "ImportantAndRecommended",
    "oneoff" : "True"
    "installDuration" : "01:00" }'
$PublicConfig = '{}'

Write-Host ("Checking " +$ResourceGroup)

# Getting all virtual machines in Resource Group
$RmVMs = Get-AzureRmVM -ResourceGroupName $ResourceGroup -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference

# Managing virtual machines deployed with the Resource Manager deployment model
if ($RmVMs) {
    foreach ($RmVM in $RmVMs) {
        if ($RmVM.StorageProfile.OsDisk.OsType -eq 'Linux') {
            $RmPState = (Get-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM.Name -Status -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).Statuses.Code[1]
            if ($RmPState -eq 'PowerState/running') {
                Write-Host ($RmVM.Name + " is started, setting up linux updates.")
                # Apply the configuration to the extension
                Set-AzureVMExtension -ExtensionName $ExtensionName -VM $RmVM -Publisher $Publisher -Version $version -PrivateConfiguration $PrivateConfig -PublicConfiguration $PublicConfig | Update-AzureVM
            }
            else {
                Write-Host ($RmVM.Name + " is starting ...")
                $RmSState = (Start-AzureRmVM -ResourceGroupName $ResourceGroup -Name $RmVM.Name -ErrorAction $ErrorActionPreference -WarningAction $WarningPreference).IsSuccessStatusCode
                if ($RmSState -eq 'True') {
                    Write-Host ($RmVM.Name + "has been started.")
                    # Apply the configuration to the extension
                    Set-AzureVMExtension -ExtensionName $ExtensionName -VM $RmVM -Publisher $Publisher -Version $version -PrivateConfiguration $PrivateConfig -PublicConfiguration $PublicConfig | Update-AzureVM
                }
                else {
                    Write-Host (RmVM.Name + "failed to start.")
                }
            }
        }
    }
}
else {
    Write-Host ("No VMs deployed with the Resource Manager deployment model in Resource Group " + $ResourceGroup)
}
