Do {
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=tcp:LMSSPPN-AG2,1433;Database=master;Integrated Security=SSPI;MultiSubnetFailover=No;ApplicationIntent=ReadOnly"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = 'Select @@servername'
$SqlCmd.Connection = $SqlConnection 
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd 
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$SqlConnection.Close() 
$DataSet.Tables[0]
} While ($DataSet.Tables.Count -ne 0)