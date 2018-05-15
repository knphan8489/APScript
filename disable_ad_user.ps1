#This script will remove all groups user belongs to and disable that user and move that #user to disable group.

Import-Module ActiveDirectory
Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Creating AD User Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}
 
#Check Script is running with Elevated Privileges
Check-RunAsAdministrator
Write-host 'This script will disable AD user and put that user into specific OU!'
do{
do{
$username = Read-Host -Prompt 'Username '
$pathname = 'OU=SO-DisabledUsers,DC=spoton,DC=com'
Write-Host "*****Your inputs are listed as:***** `nUsername: $username"
$answer=Read-Host -Prompt "Is all information above right? Please type only y or n?"
        if($answer -ne 'y' -and $answer -ne 'n'){
            exit
            }
}
while ($answer -eq 'n' )

Set-ADUser -Identity $username -Enabled $false
Get-ADUser $username | Move-ADObject -TargetPath $pathname
Get-ADGroup -Filter {name -notlike "*domain users*"} | Remove-ADGroupMember -Members $username -Confirm:$false
$again=Read-Host -Prompt 'Run program again? Please type y or n'
    if($again -ne 'y' -and $again -ne 'n'){
    exit
    }
}
while($again -eq 'y')