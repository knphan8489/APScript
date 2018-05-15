#This script will delete disabled user after 30 days. It will run as schedule task on #background
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
$searchPath="OU=SO-DisabedUsers,DC=spoton,DC=com"
$deleteDate=[DateTime]::Today.AddDays(-30)
$warningDate=[DateTime]::Today.AddDays(-23)
$deleteUsers=@()
$warningUsers=@()
$remainedUsers=@()
$disabledUsers = Get-ADUser -filter {(Enabled -eq $False)} -Searchbase $searchPath -Searchscope 1 -Properties Name,SID,Enabled,LastLogonDate,Modified,info,description
foreach ($name in $disabledUsers) { 
    if ($name.modified -le $deleteDate) { 
        Remove-ADUser -id $name.SID -confirm:$false 
        $deleteUsers = $deleteUsers + $name 
        } 
    elseif ($name.modified -le $warningDate) { 
        #Write-Host $name.name " is will be deleted in the next run" 
        $warningUsers = $warningUsers + $name 
        } 
    else { 
        #Write-Host $name.name " was modified less than 30 days ago" 
        $remainedUsers = $remainedUsers + $name 
        } 
}  

#Print report of whhich user is removed.
$report = "c:\powershell\report.htm"  
##Clears the report in case there is data in it 
Clear-Content $report 
##Builds the headers and formatting for the report 
Add-Content $report "<html>"  
Add-Content $report "<head>"  
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"  
Add-Content $report '<title>COMPANY Terminated User Cleanup Script</title>'  
add-content $report '<STYLE TYPE="text/css">'  
add-content $report  "<!--"  
add-content $report  "td {"  
add-content $report  "font-family: Tahoma;"  
add-content $report  "font-size: 11px;"  
add-content $report  "border-top: 1px solid #999999;"  
add-content $report  "border-right: 1px solid #999999;"  
add-content $report  "border-bottom: 1px solid #999999;"  
add-content $report  "border-left: 1px solid #999999;"  
add-content $report  "padding-top: 0px;"  
add-content $report  "padding-right: 0px;"  
add-content $report  "padding-bottom: 0px;"  
add-content $report  "padding-left: 0px;"  
add-content $report  "}"  
add-content $report  "body {"  
add-content $report  "margin-left: 5px;"  
add-content $report  "margin-top: 5px;"  
add-content $report  "margin-right: 0px;"  
add-content $report  "margin-bottom: 10px;"  
add-content $report  ""  
add-content $report  "table {"  
add-content $report  "border: thin solid #000000;"  
add-content $report  "}"  
add-content $report  "-->"  
add-content $report  "</style>"  
Add-Content $report "</head>"  
add-Content $report "<body>"  
 
##This section adds tables to the report with individual content 
##Table 1 for deleted users 
add-content $report  "<table width='100%'>"  
add-content $report  "<tr bgcolor='#CCCCCC'>"  
add-content $report  "<td colspan='7' height='25' align='center'>"  
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>The following users have been deleted (Report Only)</strong></font>"  
add-content $report  "</td>"  
add-content $report  "</tr>"  
add-content $report  "</table>"  
add-content $report  "<table width='100%'>"  
Add-Content $report "<tr bgcolor=#CCCCCC>"  
Add-Content $report  "<td width='20%' align='center'>Account Name</td>"  
Add-Content $report "<td width='10%' align='center'>Modified Date</td>"   
Add-Content $report "<td width='50%' align='center'>Description</td>"   
Add-Content $report "</tr>"  
if ($deleteUsers -ne $null){ 
    foreach ($name in $deleteUsers) { 
        $AccountName = $name.name 
        $LastChgd = $name.modified 
        Add-Content $report "<tr>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"   
    } 
} 
else { 
    Add-Content $report "<tr>"  
    Add-Content $report "<td>No Accounts match</td>"  
} 
Add-content $report  "</table>"  
 
##Table 2 for warning users 
add-content $report  "<table width='100%'>"  
add-content $report  "<tr bgcolor='#CCCCCC'>"  
add-content $report  "<td colspan='7' height='25' align='center'>"  
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>The following users will be deleted next week</strong></font>"  
add-content $report  "</td>"  
add-content $report  "</tr>"  
add-content $report  "</table>"  
add-content $report  "<table width='100%'>"  
Add-Content $report "<tr bgcolor=#CCCCCC>"  
Add-Content $report  "<td width='20%' align='left'>Account Name</td>"  
Add-Content $report "<td width='10%' align='center'>Modified Date</td>"   
Add-Content $report "<td width='50%' align='center'>Description</td>"   
Add-Content $report "</tr>" 
if ($warningUsers -ne $null){ 
    foreach ($name in $warningUsers) { 
        $AccountName = $name.name 
        $LastChgd = $name.modified 
        Add-Content $report "<tr>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"   
    } 
} 
else { 
    Add-Content $report "<tr>"  
    Add-Content $report "<td>No Accounts match</td>"  
} 
Add-content $report  "</table>"  
   
 
##Table 3 for recently modified users 
add-content $report  "<table width='100%'>"  
add-content $report  "<tr bgcolor='#CCCCCC'>"  
add-content $report  "<td colspan='7' height='25' align='center'>"  
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>The following users were modified in the last 30 days</strong></font>"  
add-content $report  "</td>"  
add-content $report  "</tr>"  
add-content $report  "</table>"  
add-content $report  "<table width='100%'>"  
Add-Content $report "<tr bgcolor=#CCCCCC>"  
Add-Content $report  "<td width='20%' align='left'>Account Name</td>"  
Add-Content $report "<td width='10%' align='center'>Modified Date</td>"   
Add-Content $report "<td width='50%' align='center'>Description</td>"   
Add-Content $report "</tr>"  
if ($remainedUsers -ne $null){ 
    foreach ($name in $remainedUsers) { 
        $AccountName = $name.name 
        $LastChgd = $name.modified 
        Add-Content $report "<tr>"  
        Add-Content $report "<td>$AccountName</td>"  
        Add-Content $report "<td>$LastChgd</td>"  
    } 
} 
else { 
    Add-Content $report "<tr>"  
    Add-Content $report "<td>No Accounts match</td>"  
} 
Add-content $report  "</table>"  
 
##This section closes the report formatting 
Add-Content $report "</body>"  
Add-Content $report "</html>"  
 
##Assembles and sends completion email with DL information## 
$emailFrom = "ADAlert@SPOTON.COM" 
$emailTo = "anh@spoton.com" 
$subject = "Terminated User Cleanup Script Complete" 
$smtpServer = "aspmx.l.google.com" 
$body = Get-Content $report | Out-String 
 
Send-MailMessage -To $emailTo -From $emailFrom -Subject $subject -BodyAsHtml -Body $body -SmtpServer $smtpServer