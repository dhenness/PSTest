Push-Location
[Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") |out-null
Pop-Location

# Variable for your SSAS server name
$ServerName = "scmsts27"
$SSASInstance = ""
$SSASServerEnv = "DV"

$SSASServer = New-Object Microsoft.AnalysisServices.Server 
$SSASServer.Connect($ServerName)

if($SSASInstance -ne "")
{
   $SSASServerName = $Servername + $SSASInstance.ToUpper()
}

If($SSASServerEnv -eq 'DV') {
   $SSASBackupDir = "\\ncbkpq01\backupshszq\sql\sqlbackup4"
   $SSASConnection = "mss-d-msas-01"
}
ElseIf($SSASServerEnv -eq 'QA') {
   $SSASBackupDir = "\\ncbkpq01\backupshszq\sql\sqlbackup4"
   $SSASConnection = "mss-q-msas-01"
}
ElseIf($SSASServerEnv -eq 'PD') {
   $SSASBackupDir = "\\ncbkpp01\backups1\sql\sqlbackup1"
   $SSASConnection = "mss-p1-msas-01"
}

# Connect to the SSAS server


#$SSASServer.Connect("$SSASServerName\powerpivot")  #<== Use for powerpivot instance connection
$SSASMode = $SSASServer.ServerMode     #Detect what mode the SSAS instance is in.  i.e Multidimensional, Tabular, PowetPivot

if($SSASMODE -eq 'Tabular') {
$BackupDir = "$SSASBackupDir\$ServerName\AS\Tabular"
}
if($SSASMODE -eq 'SharePoint') {
$BackupDir = "$SSASBackupDir\$ServerName\AS\PowerPivot"
}
if($SSASMODE -eq 'Multidimensional' -or 'Default') {
$BackupDir = "$SSASBackupDir\$ServerName\AS"
}

if (!( Test-Path -path "$BackupDir" )) # create it if it does not existing
       {$progress ="attempting to create directory $BackupDir"
          Try { write-host $progress
                New-Item "$BackupDir" -type directory  } 
          Catch [system.exception]{
       Write-Error "error while $progress. $_"
                return
                } 

           }

# Try to list the SSAS database properties that are available to you
$SSASServer.ServerProperties.Item(“BackupDir”).Value = "$BackupDir"
$SSASServer.ServerProperties.Item(“Log\FlightRecorder\Enabled”).Value = "false"
$SSASServer.ServerProperties.Item(“Log\QueryLog\QueryLogConnectionString”).Value = "Provider=SQLNCLI11.1;Data Source=$SSASConnection;Integrated Security=SSPI;Initial Catalog=ASQueryLog"
$SSASServer.ServerProperties.Item(“Log\QueryLog\QueryLogSampling”).Value = "10"
$SSASServer.Update()

#Create Test Cube
function createTestCube{
param(
    [string]$CubeXmlaFilePath
    ,[string]$AnalysisServicesServer
)
$CubeXmlaFilePath
$AnalysisServicesServer
$CubeXmlaFilePath = $CubeXmlaFilePath.Replace('"',"")
$AnalysisServicesServer = $AnalysisServicesServer.Replace('"',"")
$CubeXmlaFilePath
$AnalysisServicesServer
$qry = [string](get-content $CubeXmlaFilePath)
$amo = "Microsoft.AnalysisServices"
[System.Reflection.Assembly]::LoadWithPartialName($amo) > $null
$svr = New-Object Microsoft.AnalysisServices.Server
$svr.Connect($AnalysisServicesServer)
$x = $svr.Execute($qry)
$x.Messages
$svr.Disconnect()
}
createTestCube "d:\temp\createtestcube.xmla" $ServerName

if($SSASMODE -eq 'Tabular' -and $SSASInstance -eq "") {
    invoke-Command -ScriptBlock { Get-Service -Name 'MSSQLServerOLAPService'  | Restart-Service } -ComputerName $ServerName -Credential (get-credential)
}
if($SSASMODE -eq 'Multidimensional' -and $SSASInstance -eq "") {
    invoke-Command -ScriptBlock { Get-Service -Name 'MSSQLServerOLAPService' | Restart-Service } -ComputerName $ServerName -Credential (get-credential)
}

if($SSASMODE -eq 'Sharepoint') {
    invoke-Command -ScriptBlock { Get-Service -Name 'MSOLAP$POWERPIVOT' | Restart-Service } -ComputerName $ServerName -Credential (get-credential)
}
if($SSASMODE -eq 'Multidimensional') {
    invoke-Command -ScriptBlock {Get-Service -Name 'MSSQLServerOLAPService' | Restart-Service } -ComputerName $ServerName -Credential (get-credential)
}