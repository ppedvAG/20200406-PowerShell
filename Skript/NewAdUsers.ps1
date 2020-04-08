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