function insertDBAWebInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ServerInstance,
                
        [Parameter(Mandatory=$True, Position = 1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [ValidateSet("DV","QA","PD","ST","TR")]
        [string]$Environment,

        [Parameter()]
        [string]$Comments

    )
$SSASInstance = ""
$SSASInstanceName = $ServerInstance 
$HostName=$SSASInstance.Split("\")[0]
$InstanceName = $SSASInstance.Split("\")[1]
#$comments = "BIDS SSAS Sandbox Environment"
$lanid = $env:USERNAME
$envcd = $Environment
switch ($envcd)
{
    "PD" {$srvlvl = 2}
    "TR" {$srvlvl = 2}
    "DV" {$srvlvl = 4}
    "QA" {$srvlvl = 4}
    "ST" {$srvlvl = 4}
    
}
$pridba = "BAIT"
$complianceexcpt = 0
$storageid = 3
$clusternam = ""
$dflt = 1
Write-Debug "$comments $envcd $srvlvl"

foreach ($item in $SSASInstanceName)
    {
    $HostName = $item.Split("\")[0]
    Write-Debug $item
    Write-Debug $Hostname
    $connString = "Server=mss-p1-eadbaweb-01;Database=dbawebdb1;Trusted_Connection=True"
    $connection = new-object System.Data.SqlClient.SqlConnection $connString 
    $connection.Open() 
    $Command = new-Object System.Data.SqlClient.SqlCommand("[Installer].[usp_InsertInstance]", $connection)
    $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $Command.Parameters.Add("@Instancenam", "$item") | Out-Null
    $Command.Parameters.Add("@srvlvl", "$srvlvl") | Out-Null
    $Command.Parameters.Add("@comments", "$comments") | Out-Null
    $Command.Parameters.Add("@lanid", "$lanid") | Out-Null
    $Command.Parameters.Add("@envcd", "$envcd") | Out-Null
    $Command.Parameters.Add("@pridba", "$pridba") | Out-Null
    $Command.Parameters.Add("@complianceexcpt", "$complianceexcpt") | Out-Null
    $Command.Parameters.Add("@Results", [System.Data.SqlDbType]"Int") | Out-Null
    $Command.Parameters["@Results"].Direction = [system.Data.ParameterDirection]::ReturnValue 
    $Command.ExecuteNonQuery() | Out-Null
    $RC = $Command.Parameters["@Results"].Value
    write-debug "Results from InsertInstance $RC"
    $RC

    #$connString = "Server=mss-q-eadbaweb-01;Database=dbawebdb1;Trusted_Connection=True"
    #$connection = new-object System.Data.SqlClient.SqlConnection $connString 
    #$connection.Open() 
    $Command = new-Object System.Data.SqlClient.SqlCommand("[Installer].[usp_InsertMachine]", $connection)
    $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $Command.Parameters.Add("@machinenam", "$HostName") | Out-Null
    $Command.Parameters.Add("@storageid", "$storageid") | Out-Null
    $Command.Parameters.Add("@lanid", "$lanid") | Out-Null
    $Command.Parameters.Add("@clusternam", "$clusternam") | Out-Null
    $Command.Parameters.Add("@Results", [System.Data.SqlDbType]"Int") | Out-Null
    $Command.Parameters["@Results"].Direction = [system.Data.ParameterDirection]::ReturnValue
    $Command.ExecuteNonQuery() | Out-Null
    $RC = $Command.Parameters["@Results"].Value
    write-debug "Results from InsertMachine $RC"
    $RC

    #$connString = "Server=mss-q-eadbaweb-01;Database=dbawebdb1;Trusted_Connection=True"
    #$connection = new-object System.Data.SqlClient.SqlConnection $connString 
    #$connection.Open() 
    $Command = new-Object System.Data.SqlClient.SqlCommand("[Installer].[usp_InsertMachineInstance]", $connection)
    $Command.CommandType = [System.Data.CommandType]'StoredProcedure'
    $Command.Parameters.Add("@Instancenam", "$item") | Out-Null
    $Command.Parameters.Add("@Machinenam", "$HostName") | Out-Null
    $Command.Parameters.Add("@dflt", "$dflt") | Out-Null
    $Command.Parameters.Add("@Results", [System.Data.SqlDbType]"Int") | Out-Null
    $Command.Parameters["@Results"].Direction = [system.Data.ParameterDirection]::ReturnValue
    $Command.ExecuteNonQuery() | Out-Null
    $RC = $Command.Parameters["@Results"].Value
    write-debug "Results from InsertMachineInstance $RC"
    $RC

    $connection.Close() | Out-Null
    $Command.Dispose() | Out-Null
    $connection.Dispose() | Out-Null
    }
}