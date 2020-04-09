function New-MyAdUser 
{
[cmdletBinding(PositionalBinding=$false)]
Param(
    [Parameter(Mandatory=$true,ParameterSetName="SingleUser",HelpMessage="VorName des neuen Users")]
    [String]$GivenName,

    [Parameter(Mandatory=$true,ParameterSetName="SingleUser")]
    [string]$SurName,

    [Parameter(Mandatory=$true,ParameterSetName="SingleUser")]
    [string]$Department,

    [Parameter(Mandatory=$true,ParameterSetName="SingleUser")]
    [string]$PlainPassword,

    [Parameter(Mandatory=$true,ParameterSetName="SingleUser")]
    [Parameter(Mandatory=$true,ParameterSetName="CSV")]
    [switch]$Enabled,

    [Parameter(Mandatory=$true,ParameterSetName="CSV")]
    [ValidateScript({Test-Path -Path $PSItem -Filter *.csv})]
    [string]$CSVPath = "Empty"
)

$Abteilungen = "EDV","Buchhaltung","Einkauf"

if($CSVPath -ne "Empty")
{
    $Users = Import-Csv -Path $CSVPath
    foreach($User in $Users)
    {
        $TargetOU = (Get-ADOrganizationalUnit -Filter {Name -eq $User.Department})
        if(($TargetOU | Get-Member).Count -eq 1)
        {
            $UserOU = $TargetOU.DistinguishedName
        }
        else
        {
            $UserOU = "CN=Users,DC=ppedv,DC=kurs"
            Write-Verbose -Message "Es wurde keine OU gefunden die dem Department entspricht, User wurde in Standardpfad abgelegt"
        }

        $Group = Get-ADGroup -Filter {Name -eq "GL-$($User.Department)" }
        
        $Name = "$($User.GivenName) $($User.SurName)"
        $SamAccountName = "$($User.GivenName).$($User.SurName)"

        $NewUser = New-ADUser -GivenName $User.GivenNAme -Surname $User.SurName -Name $Name -SamAccountName $SamAccountName -Department $User.Department -Path $UserOU -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String $User.Password) -Enabled ([bool]::Parse($User.Enabled))
        Add-ADGroupMember -Identity $Group -Members $NewUser
    }
}
else
{
        $Name = "$($GivenName) $($SurName)"
        $SamAccountName = "$($GivenName).$($SurName)"

        New-ADUser -GivenName $User.GivenNAme -Surname $User.SurName -Name $Name -SamAccountName $SamAccountName -Department $User.Department -Path $UserOU -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String $PlainPassword) -Enabled $Enabled
}
}

function Get-LogonEvents
{
<#
.SYNOPSIS 
    Abfrage von Anmeldebezogenen Events
.DESCRIPTION
    Ausführliche Beschreibung wie dieses Skript Anmeldeevents abfrägt
.PARAMETER Computername
    Name des Computers der auf die Events abgefragt werden soll
.EXAMPLE 
    Logonevent.ps1 -ComputerName localhost

    Frägt vom Computer Localhost die aktuellesten 5 AnmeldeEvents ab.
    Beispielausgabe:

   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
   25995 Apr 08 14:19  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25990 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25987 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25982 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
   25979 Apr 08 14:18  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
.LINK
    https://github.com/ppedvAG/20200406-PowerShell
#>
[cmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Connection -ComputerName $PSItem -Count 2 -Quiet})]
[string]$ComputerName,

[ValidateSet(4624,4625,4634)]
[int]$EventId = 4624,

[ValidateRange(5,20)]
[int]$Newest = 3,

[switch]$Detailed,

[ValidateSet("Blau","Grün")]
[string]$AusgabeFarbe = "leer"
)

Write-Verbose -Message "Vor Abfrage es wurden folgende Werte verwendet:
Computername: $ComputerName
EventID: $EventID
Newest: $Newest
"

#Abfrage des EventLog Security und anschließendes Filtern auf die Eventid 4624 (AnmeldeEvent)
$Ergebnis = Get-EventLog -LogName Security -ComputerName $ComputerName | Where-Object EventID -eq $EventId | Select-Object -First $Newest 

If($Detailed -eq $true)
{
    Format-List -InputObject $Ergebnis
}
else
{
    if($AusgabeFarbe -eq "leer")
    {
        $Ergebnis
    }
    else
    {
        #Debug Haltepunkt eingefügt
        Write-Debug -Message "Vor SwitchCase Color"
        switch($AusgabeFarbe)
        {
            "Blau" {Write-Host ($Ergebnis | Out-String) -ForegroundColor Blue -BackgroundColor White}
            "Grün" {Write-Host ($Ergebnis | Out-String) -ForegroundColor Green}
        }
    }
}


}

function Install-KursModul
{
[cmdletBinding()]
Param(
    
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $PSItem -PathType Leaf})]
    [string]$Modulefilepath,

    [ValidateScript({Test-Path -Path $PSItem -IsValid})]
    [string]$TargetPath = "NoPath",

    [switch]$Force
)
    $SourceModuleFile = Get-Item -Path $Modulefilepath

    if($TargetPath -eq "NoPath")
    {
        $TargetPath = $env:PSModulePath.Split(';')[0] + "\" + $SourceModuleFile.BaseName
        Write-Verbose -Message $TargetPath
    }

    if(Test-Path -Path $TargetPath -PathType Container)
    {
        if($Force)
        {
            foreach($Content in (Get-ChildItem -Path $TargetPath))
            {
                Remove-Item -Path $Content.FullName -Recurse
            }
        }
        else
        {
            Write-Error -Message "Datei ist bereits vorhanden" -ErrorAction Stop
        }
    }
    else
    {
        New-Item -Path $TargetPath -ItemType Directory
    }
        
    $Sourcepsdpath = $SourceModuleFile.DirectoryName + "\" + $SourceModuleFile.BaseName + ".psd1"
    if(Test-Path -Path $Sourcepsdpath)
    {
        Copy-Item -Path $Sourcepsdpath -Destination ($TargetPath + "\" + $SourceModuleFile.BaseName + ".psd1")
    }

    $SourceModuleFile.CopyTo(($TargetPath + "\" + $SourceModuleFile.Name))
}
