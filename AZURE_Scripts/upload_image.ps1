Param(
[string]$ResourceGroup,
[string]$ImageBase
)

For ($i=11; $i -le 20; $i++) {
    $ImageName = "$($ImageBase)-$($i)"
    Write-Host "Uploading $($ImageName)...."
    $localFile = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$($ImageName).vhd"
    $urlOfUploadedImageVhd = "https://$($ResourceGroup).blob.core.windows.net/vhds/$($ImageName).vhd"
    $location = "Central US"

    # Create the Source Image
    Add-AzureRmVhd -Destination $urlOfUploadedImageVhd -LocalFilePath $localFile -ResourceGroupName $ResourceGroup
    $imageConfig = New-AzureRmImageConfig -Location $location
    $imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $urlOfUploadedImageVhd
    $sourceimage = New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ResourceGroup -Image $imageConfig

    }

