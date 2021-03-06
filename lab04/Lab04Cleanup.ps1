# Remove existing subscriptions and accounts from local PowerShell environment
Write-Host "Removing local Azure subscription certificates..."
foreach ($sub in Get-AzureSubscription)
{
    if ($sub.Name)
    {
        Remove-AzureSubscription $sub.Name -Force
    }
}
Write-Host "Signing out of Azure..."
foreach ($acct in Get-AzureAccount)
{
    Remove-AzureAccount $acct.Name -Force
}

# Sign into Azure
Add-AzureAccount

# Set correct mode ready to delete using service management model first
Switch-AzureMode -Name AzureServiceManagement

# Delete all VMs and cloud services
foreach ($svc in Get-AzureService)
{
    foreach ($vm in Get-AzureVM)
    {
        Stop-AzureVM -ServiceName $svc.ServiceName -Name $vm.Name -Force
        Remove-AzureVM -ServiceName $svc.ServiceName -Name $vm.Name -DeleteVHD
    }

    Remove-AzureService -ServiceName $svc.ServiceName -Force
}

# Delete everything else just in case ...
Get-AzureWebsite | Remove-AzureWebsite -Force
Get-AzureDisk | Remove-AzureDisk -DeleteVHD
Get-AzureStorageAccount | Remove-AzureStorageAccount
Get-AzureAffinityGroup | Remove-AzureAffinityGroup

# Delete automation objects created in lab. 

$AA = (Get-AzureAutomationAccount).AutomationAccountName

if ($AA -ne $null)
    {
        Get-AzureAutomationCredential -AutomationAccountName $AA | Remove-AzureAutomationCredential -Force
        Get-AzureAutomationVariable -AutomationAccountName $AA | Remove-AzureAutomationVariable -Force
        Get-AzureAutomationSchedule -AutomationAccountName $AA | Remove-AzureAutomationSchedule -Force
        Get-AzureAutomationRunbook -AutomationAccountName $AA | Remove-AzureAutomationRunbook -Force
        Remove-AzureAutomationAccount -Name $AA -Force
    }# Delete any VPN gatewaysforeach ($vnet in Get-AzureVNetSite)
{
    if ($vnet)
    {
         Write-Host "Processing  " $vnet.Name "virtual network ..."
         Remove-AzureVNetGateway -VNetName $vnet.Name
    }
}

# Delete all virtual networks, DNS servers etc.
Remove-AzureVNetConfig

# Delete all resource groups
Switch-AzureMode AzureResourceManager

foreach ($rg in Get-AzureResourceGroup)
{
    if ($rg)
    {
         Write-Host "Deleting " $rg.ResourceGroupName "resource group..."
         Remove-AzureResourceGroup $rg.ResourceGroupName -Force
    }
}
Switch-AzureMode -Name AzureServiceManagement