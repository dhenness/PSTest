$createDB = @'
{
    "createOrReplace": {
      "object": {
        "database": "TestTabular"
      },
      "database": {
        "name": "TestTabular",
        "id": "123",
        "compatibilityLevel": 1200,
        "model": {
          "culture": "en-US",
          "dataSources": [
            {
              "name": "SqlServer localhost Test",
              "connectionString": "Provider=SQLNCLI11;Data Source=localhost;Initial Catalog=Test;Integrated Security=SSPI;Persist Security Info=false",
              "impersonationMode": "impersonateAccount",
              "account": "   ",
              "annotations": [
                {
                  "name": "ConnectionEditUISource",
                  "value": "SqlServer"
                }
              ]
            }
          ]
        }
      }
    }
  }
'@
$backupDB = @'
{
    "backup": {
      "database": "TestTabular",
      "file": "\\\\ncbkpq01\\backupshszq\\sql\\sqlbidsbkp1\\SCMSAS07\\AS\\TestTabular.abf",
      "allowOverwrite": true,
      "applyCompression": true
    }
  }
'@
$deleteDB = @'
{
    "delete": {
      "object": {
        "database": "TestTabular"
      }
    }
  }
'@
Invoke-ASCmd -Query $createDB -server "scmsas07\tabular"
Invoke-ASCmd -Query $backupDB -server "scmsas07\tabular"
Invoke-ASCmd -Query $deleteDB -server "scmsas07\tabular"