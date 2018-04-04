Param(
[string]$ResourceGroup,
[string]$Location,
[string]$StorageAccount
)

Get-AzureRmResourceGroup -Name $ResourceGroup -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent)
{
    New-AzureRmResourceGroup -Name $ResourceGroup -Location $Location
}
# Check for storage account and create if not found
$StorageAccountRM = Get-AzureRmStorageAccount -Name $StorageAccount -ResourceGroupName $ResourceGroup -ErrorAction Ignore
if ($StorageAccountRM -eq $null)
{
    New-AzureRmStorageAccount -Location $Location -Name $StorageAccount -ResourceGroupName $ResourceGroup -SkuName Standard_LRS -Kind Storage
}

    $ImageName = "pfsense"
    Write-Host "Uploading $($ImageName)...."
    $localFile = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$($ImageName).vhd"
    $urlOfUploadedImageVhd = "https://$($StorageAccount).blob.core.windows.net/images/$($ImageName).vhd"
    $location = "Central US"

    # Create the Source Image
    Add-AzureRmVhd -Destination $urlOfUploadedImageVhd -LocalFilePath $localFile -ResourceGroupName $ResourceGroup -Overwrite
#    $imageConfig = New-AzureRmImageConfig -Location $location
#    $imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $urlOfUploadedImageVhd
#    $sourceimage = New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ResourceGroup -Image $imageConfig
