function ConvertFrom-SecureStringToPlainText {
    [CmdletBinding()]
    param ( 
        [SecureString] $SecureString
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

}

$ErrorActionPreference = 'Stop';
$VerbosePreference = 'continue';

#$AzureUsername = 'trevor@trevorsullivan.net';
#$AzureCredential = Get-Credential -UserName $AzureUsername -Message 'Please enter your Microsoft Azure password.';
#$null = Add-AzureRmAccount -Credential $AzureCredential;

### The Start-AzureRm command is part of the Azure PowerShell Extensions project.
### On PowerShell version 5.0+, use Install-Module -Name AzureExt -Scope CurrentUser to install it
Start-AzureRm;

Write-Verbose -Message 'Creating Resource Group ...';

$ResourceGroup = @{
    Name = 'MMS2016-Infrastructure2';
    Location = 'North Central US';
    Force = $true;
    Tag = @{ Name = 'Conference'; Value = 'MMS 2016' };
    };
New-AzureRmResourceGroup @ResourceGroup;

Write-Verbose -Message 'Finished creating Azure Resource Group.';
Write-Verbose -Message 'Creating ARM JSON template deployment ...';

$Deployment = @{
    ResourceGroupName = $ResourceGroup.Name;
    Name = 'MMS2016-Infrastructure';
    TemplateFile = '{0}\Twenty-Linux-VMs.json' -f $PSScriptRoot;
    TemplateParameterObject = @{
        adminUsername = 'artofshell';
        adminPassword = ConvertFrom-SecureStringToPlainText -SecureString (Read-Host -AsSecureString -Prompt 'Please enter a password');
        dnsLabelPrefix = 'mms2016-iaas';
        };
    Mode = 'Incremental';
    DeploymentDebugLogLevel = 'All';
    };
New-AzureRmResourceGroupDeployment @Deployment;

Write-Verbose -Message 'Finished creating ARM JSON template deployment ...';

# Remove-AzureRmResourceGroup -Name $ResourceGroup.Name -Force;
