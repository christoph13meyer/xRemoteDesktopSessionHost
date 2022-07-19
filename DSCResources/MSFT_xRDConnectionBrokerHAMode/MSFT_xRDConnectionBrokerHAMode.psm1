Import-Module -Name "$PSScriptRoot\..\..\Modules\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement))
{
    throw "The minimum OS requirement was not met."
}
Import-Module RemoteDesktop
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $SQLServer,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Getting information about RD Connection Broker High Availability Mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }

    $ConnectionBrokerHighAvailability = Get-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue

    @{
        ConnectionBroker         = $ConnectionBrokerHighAvailability.ConnectionBroker
        ActiveManagementServer   = $ConnectionBrokerHighAvailability.ActiveManagementServer
        ClientAccessName         = $ConnectionBrokerHighAvailability.ClientAccessName
        DatabaseConnectionString = $ConnectionBrokerHighAvailability.DatabaseConnectionString
        DatabaseFilePath         = $ConnectionBrokerHighAvailability.DatabaseFilePath
    }

}


########################################################################
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource

{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $SQLServer,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Set RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }
    
    if ($localhost -eq $ConnectionBroker)
    {
        Set-RDConnectionBrokerHighAvailability -ConnectionBroker $ConnectionBroker -DatabaseConnectionString "DRIVER=SQL Server Native Client 11.0;SERVER=$SQLServer;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=$DatabaseName" -DatabaseFilePath $DatabaseFilePath -ClientAccessName $ClientAccessName -Verbose
    }

}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $true)]
        [string] $SQLServer,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName
    )
    Write-Verbose "Checking for existence of RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }
    
    $null -ne (Get-TargetResource -ConnectionBroker $ConnectionBroker).ActiveManagementServer
}


Export-ModuleMember -Function *-TargetResource
