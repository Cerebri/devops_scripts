# This is a script to create a VM with an existing NIC and Unmanaged OSDisk in a Storage Account

# Commonly used in repairing broken OS Disks

# Troubleshooting steps
# 1. Create a new repair VM same size and OS
# 2. Delete the broken VM, the Unmanaged Blob and NIC will not be deleted
# 3. Connect the OSDisk Blob as DataDisk to the repair VM
# 4. Use chroot to mount disk and repair: https://superuser.com/questions/111152/whats-the-proper-way-to-prepare-chroot-to-recover-a-broken-linux-installation
# 5. When done disconnect disk from repair VM
# 6. Use below procedure to re-create the original VM which will also try booting it up
# 7. If it is still broken, rinse and repeat

$resourceGroupName = "TrustFord"
$destinationVhd = "https://cerebritrustford.blob.core.windows.net/vhds/osDiskDatabase.vhd"
$virtualNetworkName = "trustfordVnet"
$locationName = "westeurope"
$virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName
$networkInterface = Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name "database-nic"
Get-AzureRmVMSize $locationName | Out-GridView
$vmConfig = New-AzureRmVMConfig -VMName "database" -VMSize "Standard_E16s_v3"
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -Name "databaseOSDisk" -VhdUri $destinationVhd -CreateOption Attach -Linux
$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id
$vm = New-AzureRmVM -VM $vmConfig -Location $locationName -ResourceGroupName $resourceGroupName
