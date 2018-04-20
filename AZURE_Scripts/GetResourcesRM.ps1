#Login-AzureRmAccount

$rgs = Get-AzureRmResourceGroup

foreach ($rg in $rgs)
{
    echo $rg.ResourceGroupName
    $resources = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName
    foreach($resource in $resources)
    {

        echo "   $($resource.Name),$($resource.HardwareProfile.VmSize)"

    }

}