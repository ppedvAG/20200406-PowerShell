Import-Csv -Path C:\Testfiles\MyNewAdUsers2.csv | ForEach-Object {
            New-ADUser -GivenName $_.GivenName `                       -Surname $_.GivenName `                       -Name $_.Name `                       -SamAccountName $_.SamAccountName `
                       -Department $_.Department `                       -Path $_.Path `                       -Enabled ([bool]::Parse($_.Enabled)) `                       -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force)

}