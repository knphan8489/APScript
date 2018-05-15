#This script will create user, generate password for that person and move to right OU or #group. Then this script will email that person about AD login information

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
Write-host 'This script will create new AD user and put that user into specific OU!'
do{
do{
$FirstName = Read-Host -Prompt 'First name '
$LastName = Read-Host -Prompt 'Last name '
$username = Read-Host -Prompt 'Username '
$email = Read-Host -Prompt "Agreed on email $username@spoton.com? Please enter for y or type in different username you want if n "
if($email -eq ''){
$email=$username+'@spoton.com'
}
else
{
$email=$email+'@spoton.com'
}
$mainOU = Read-Host -Prompt 'Please type exact name of your work location  (SF, Chicago, Shipping or Others)' 
$OUvariable = Read-Host -Prompt 'OU '
$displayName = $FirstName +' ' +$LastName
$randomPassword=([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join ''
$secPassword=ConvertTo-SecureString -AsPlainText $randomPassword -Force
$pathname = 'OU='+ $OUvariable + ',OU=SO-'+$mainOU+',DC=spoton,DC=com'
Write-Host "*****Your inputs are listed as:***** `nFirst Name: $FirstName `nLast Name: $LastName `nUsername: $username `nEmail: $email `nOU: $OUvariable `nPassword: $randomPassword"
$answer=Read-Host -Prompt "Is all information above right? Please type only y or n?"
        if($answer -ne 'y' -and $answer -ne 'n'){
            exit
            }
}
while ($answer -eq 'n' )
if($mainOU -eq 'SF'){
New-ADUser -GivenName $FirstName -SurName $lastName -SamAccountName $username -Name $displayName -DisplayName $displayname -EmailAddress $email -UserPrincipalName $email -AccountPassword $secPassword -Enabled $true -PasswordNeverExpires $false -ChangePasswordAtLogon $true -Path $pathname
}
if($mainOU -eq 'Chicago' -or $mainOU -eq 'Shipping' -or $mainOU -eq 'Others'){
New-ADUser -GivenName $FirstName -SurName $lastName -SamAccountName $username -Name $displayName -DisplayName $displayname -EmailAddress $email -UserPrincipalName $email -AccountPassword $secPassword -Enabled $true -PasswordNeverExpires $false -ChangePasswordAtLogon $false -Path $pathname
}


Add-ADGroupMember -Identity SO_InternalGroup -Members $username
if($mainOU -eq 'SF'){
    Add-ADGroupMember -Identity 'Team SF' -Members $username
}
if($mainOU -eq 'Chicago'){
    Add-ADGroupMember -Identity 'Chicago Team' -Members $username
}

if($mainOU -eq 'Shipping'){
    Add-ADGroupMember -Identity 'Shipping Team' -Members $username
}

#Set email template
$OFS="`r`n"
$msg="Welcome to SPOTON! Here is your account information:"+$OFS+"First Name: $Firstname"+$OFS+"Last Name: $Lastname"+$OFS+`
"Windows username login: $username"+$OFS+"Email: $email"+$OFS+"Password: $randomPassword"+$OFS+"If you have any questions or concerns about login, please create ticket by send to helpdesk@spoton.com"+$OFS+"Thanks!"
$clientEmail = Read-Host -Prompt "Client email "

##Set up email server and sending completion email with DL information## 
$emailFrom = "welcome@SPOTON.COM" 
$emailTo = "$clientEmail"
$Cc="helpdesk@spoton.com"
$subject = "New hire information" 
$smtpServer = "smtp.gmail.com"
$SMTPPORT = "587"
Send-MailMessage -From $emailFrom -to $emailTo -Subject $subject -Body $msg -SmtpServer $smtpServer -port $SMTPPORT -UseSsl -Credential (Get-Credential)
$again=Read-Host -Prompt 'Run program again? Please type y or n'
    if($again -ne 'y' -and $again -ne 'n'){
    exit
    }
}
while($again -eq 'y')