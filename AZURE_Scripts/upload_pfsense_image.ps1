Param(
[string]$ResourceGroup,
[string]$ImageBase
)


#    $ImageName = "$($ImageBase)-$($i)"
    $ImageName = "$($ImageBase)"
    Write-Host "Uploading $($ImageName)...."
    $localFile = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$($ImageName).vhd"
    $urlOfUploadedImageVhd = "https://cerebrimbfs.blob.core.windows.net/images/$($ImageName).vhd"
    $location = "Central US"

    # Create the Source Image
    Add-AzureRmVhd -Destination $urlOfUploadedImageVhd -LocalFilePath $localFile -ResourceGroupName $ResourceGroup -Overwrite
    $imageConfig = New-AzureRmImageConfig -Location $location
    $imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $urlOfUploadedImageVhd
    $sourceimage = New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ResourceGroup -Image $imageConfig



