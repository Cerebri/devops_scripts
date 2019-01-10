function RemoveFileDir ([Microsoft.WindowsAzure.Storage.File.CloudFileDirectory]$dir)
{
    $filelist = Get-AzureStorageFile -Directory $dir
    foreach ($f in $filelist)
    {
        if ($f.GetType().Name -eq "CloudFileDirectory")
        {
            RemoveFileDir($f)
            #echo $f
        }
        else
        {
            Remove-AzureStorageFile -File $f
            echo $f
        }
    }
    Remove-AzureStorageDirectory -Directory $dir
    echo $dir
}

$ctx = New-AzureStorageContext -StorageAccountName "#########" -StorageAccountKey "###########"

$directory = Get-AzureStorageFile -ShareName "#######" -Path "#######" -Context $ctx

RemoveFileDir($directory)