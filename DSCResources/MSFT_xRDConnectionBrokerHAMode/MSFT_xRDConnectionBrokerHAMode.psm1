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
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $false)]
        [string] $SQLServer,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName,

        [Parameter(Mandatory = $false)]
        [string]
        $SqlServerDriver = 'SQL Server Native Client 11.0'
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
        SqlServerDriver          = $SqlServerDriver
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
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $false)]
        [string] $SQLServer,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SqlServerDriver = 'SQL Server Native Client 11.0'
    )
    Write-Verbose "Set RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }

    $parameters = @{
        ConnectionBroker         = $ConnectionBroker
        DatabaseConnectionString = "DRIVER=$SqlServerDriver;SERVER=$SQLServer;Trusted_Connection=Yes;APP=Remote Desktop Services Connection Broker;Database=$DatabaseName"
        ClientAccessName         = $ClientAccessName
    }
    
    if (-not [string]::IsNullOrWhiteSpace($DatabaseFilePath))
    {
        $parameters['DatabaseFilePath'] = $DatabaseFilePath
    }

    if ($localhost -eq $ConnectionBroker)
    {
        Set-RDConnectionBrokerHighAvailability @parameters
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
        [Parameter(Mandatory = $true)]
        [string] $ConnectionBroker,

        [Parameter(Mandatory = $false)]
        [string] $SQLServer,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $DatabaseName,

        [Parameter(Mandatory = $false)]
        [string] $DatabaseFilePath,

        [Parameter(Mandatory = $false)]
        [ValidateLength(1, 256)]
        [string] $ClientAccessName,

        [Parameter(Mandatory = $false)]
        [string]
        $SqlServerDriver = 'SQL Server Native Client 11.0'
    )
    Write-Verbose "Checking for existence of RD Connection Broker for high availability mode."

    if ([string]::IsNullOrWhiteSpace($ConnectionBroker))
    {
        $ConnectionBroker = $localhost
    }
    
    $null -ne (Get-TargetResource -ConnectionBroker $ConnectionBroker).ActiveManagementServer
}


Export-ModuleMember -Function *-TargetResource
