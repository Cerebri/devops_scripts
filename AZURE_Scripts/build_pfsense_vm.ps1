

$rgName = "CerebriPrivate"
$localFile = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\pfsense242.vhd"
$urlOfUploadedImageVhd = "https://cerebriprivate.blob.core.windows.net/vhds/pfSense-2.4.2.vhd"
$location = "Central US"


# Create the Source Image
#Add-AzureRmVhd -Destination $urlOfUploadedImageVhd -LocalFilePath $localFile -ResourceGroupName $rgName
#$imageConfig = New-AzureRmImageConfig -Location $location
#$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $urlOfUploadedImageVhd
#$imageName = "pfSense-2.4.2"
#$sourceimage = New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig


# Create the VM
$rgName = "CerebriPrivate"
$location = "Central US"
$imageName = "pfSense-2.4.2"
$VMName = "pfSense"
$ComputerName = "pfSense"
$OSDiskName = "pfSense-OSDisk"
$VMSize = "Standard_D2S_V3"
$userName = "pfsense"
$publicIPName = "pfSense-PublicIP"
$publicNICNmame = "pfSense-PublicNIC"
$privateNICNmame = "pfSense-PrivateNIC"
$vnetName = "privateVnet"
$sshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA1JzHZHAL25ZFgEqH7eyXDzJaIfgulEefPFR+B74Kcnqlmdu4ipJtWT37MR7S42/sj4bzhnMDRWwdNBK7Y1uBeV2kPMRWh0RQ3IGHg0yRMApvyvnoAwddK37mZanvU2VChWJGNRJT8bC85dEoMvE+5q1x9ynRzlE6l5ujV1LdUwcCIRMGx18ytCdLzk1OprLxzFRLCwADUA1ZbR8mcww/s7RPxw5smqjssaAYs1fbnK30Hh3C7B8do2YxnV6CLUmQaoef8rIW/Zzl6oIgp7u2pWLvNCrKz/K43xKBoHFqaGKd3AOKZQedkmOKexbo4tPsOXwzR7HDNgaFkuQmV4d9DQ== nic.swart"

$sourceimage = Get-AzureRmImage -ResourceGroupName $rgName -ImageName $imageName

# Definer user name and blank password
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($userName, $securePassword)

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Location $location -Name $publicIPName -AllocationMethod Static -IdleTimeoutInMinutes 4

$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
# Create a virtual network cards and associate with public IP address

$subnet_dmz = "/subscriptions/e85f8f8e-cd5f-4aaf-a8d4-eddcc41d05a4/resourceGroups/CerebriPrivate/providers/Microsoft.Network/virtualNetworks/privateVnet/subnets/dmzSubnet"
$IPconfig1 = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "10.1.1.50" -Primary -SubnetId $subnet_dmz -PublicIpAddressId $pip.Id
$nic1 = New-AzureRmNetworkInterface -Name $publicNICNmame -ResourceGroupName $rgName -Location $location -IpConfiguration $IPconfig1 -EnableIPForwarding

$subnet_priv = "/subscriptions/e85f8f8e-cd5f-4aaf-a8d4-eddcc41d05a4/resourceGroups/CerebriPrivate/providers/Microsoft.Network/virtualNetworks/privateVnet/subnets/privateSubnet"
$IPconfig2 = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig2" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "10.1.0.50" -SubnetId $subnet_priv
$nic2 = New-AzureRmNetworkInterface -Name $privateNICNmame -ResourceGroupName $rgName -Location $location -IpConfiguration $IPconfig2 -EnableIPForwarding

# Create the virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $VMSize |
            Set-AzureRmVMOperatingSystem -Linux -ComputerName $ComputerName -Credential $cred -DisablePasswordAuthentication |
            Set-AzureRmVMSourceImage -Id $sourceimage.Id |
            Set-AzureRmVMOSDisk -Name $OSDiskName -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite |
            Add-AzureRmVMSshPublicKey -KeyData $sshPublicKey -Path "/home/$($userName)/.ssh/authorized_keys" |
            Add-AzureRmVMNetworkInterface -Id $nic1.Id -Primary | `
            Add-AzureRmVMNetworkInterface -Id $nic2.Id

# Create the virtual machine
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vmConfig