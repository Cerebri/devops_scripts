#
# Powershell Script to get all clusternodes after deploy
#
Login-AzureRmAccount
$resourceGroupName = Read-Host -Prompt "Enter the resource group that contains the virtual network used with HDInsight"
$NICs = Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName
$NICs[0].DnsSettings.InternalDomainNameSuffix

#$clusterNICs = Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName | where-object {$_.Name -like "*node*"}
$clusterNICs = Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName

$nodes = @()
foreach($nic in $clusterNICs) {
    $node = new-object System.Object
    $node | add-member -MemberType NoteProperty -name "Type" -value $nic.Name.Split('-')[1]
    $node | add-member -MemberType NoteProperty -name "InternalIP" -value $nic.IpConfigurations.PrivateIpAddress
    $node | add-member -MemberType NoteProperty -name "InternalFQDN" -value $nic.DnsSettings.InternalFqdn
    $nodes += $node
}
$nodes | sort-object Type