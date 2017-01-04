<#
Surface Hub SfB account validator
Verion 0.1
Nabil LAKHNACHFI
OCWS
#>

Write-Host  "Validation compte Skype for business Surface Hub"
Write-Host  "Quel Compte sera utilise par la surface HUB?"
Write-Host  "Formats acceptes " -NoNewline;
Write-Host -ForegroundColor Cyan "adresse SIP" -NoNewline;
Write-Host  " , " -NoNewline;
Write-Host -ForegroundColor Cyan  "user principal name (UPN)" -NoNewline;
Write-Host  " , " -NoNewline;
Write-Host -ForegroundColor Cyan "domaine\utilsateur" -NoNewline
Write-Host  " , " -NoNewline;
Write-Host -ForegroundColor Cyan "Display name" -NoNewline;
$strLyncIdentity = Read-Host "?"

#Write-Host $strLyncIdentity
$Global:iFileText=$null
#file path
$logFilePath=$PSScriptRoot+"\LogSHValidateSfBfr.txt"

$Global:iTotalFailures = 0
$Global:iTotalWarnings = 0
$Global:iTotalPasses = 0

function Validate()
{
    Param(
        [string]$Test,
        [bool]  $Condition,
        [string]$FailureMsg,
        [switch]$WarningOnly
    )

    Write-Host -NoNewline -ForegroundColor White $Test.PadRight(100,'.')
    if ($Condition)
    {
        Write-Host -ForegroundColor Green "Reussi"
        Out-file -filePath $logFilePath -append "Reussi"
        $global:iTotalPasses++
    }
    else
    {
        if ($WarningOnly)
        {
            Write-Host -ForegroundColor Yellow ("Avertissement: "+$FailureMsg)
            Out-file -filePath $logFilePath -append ("Avertissement: "+$FailureMsg)
            $global:iTotalWarnings++
        }
        else
        {
            Write-Host -ForegroundColor Red ("Echec: "+$FailureMsg)
            Out-file -filePath $logFilePath -append ("Echec: "+$FailureMsg)
            $global:iTotalFailures++
        }
    }
}

## SfB ##

$lyncAccount = $null
try {
    $lyncAccount = Get-CsMeetingRoom -Identity $strLyncIdentity -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
} catch {
    try {
        $lyncAccount = Get-CsUser -Identity $strLyncIdentity -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    } catch { }
}
Validate -Test "Il existe un compte Lync ou Skype for Business pour $strLyncIdentity" -Condition ($lyncAccount -ne $null -and $lyncAccount.Enabled) -FailureMsg "Il n'y a pas de compte Lync/SfB"
if ($lyncAccount)
{
    Validate -Test "L'objet salle de r�union a une adresse SIP" -Condition (![System.String]::IsNullOrEmpty($lyncAccount.SipAddress)) -FailureMsg "Le compte n'a pas d'adresse SIP, la Surface HUB ne pourra pas se connecter a Lync/Skype for business."
}
## End SFB ##


## Summary ##

$global:iTotalTests = ($global:iTotalFailures + $global:iTotalPasses + $global:iTotalWarnings)

Write-Host -NoNewline $global:iTotalTests "tests realises: "
Out-file -filePath $logFilePath -append ($global:iTotalTests "tests realises: ")
Write-Host -NoNewline -ForegroundColor Red $Global:iTotalFailures "echecs "
Out-file -filePath $logFilePath -append ($Global:iTotalFailures "echecs ")
Write-Host -NoNewline -ForegroundColor Yellow $Global:iTotalWarnings "avertissements "
Out-file -filePath $logFilePath -append ($Global:iTotalWarnings "avertissements ")
Write-Host -ForegroundColor Green $Global:iTotalPasses "reussis "
Out-file -filePath $logFilePath -append ($Global:iTotalPasses "reussis ")

## End Summary ##