#This script will get stringID from user logs into, combine with random string from specific text file that is provided and hash it to create random password

Function Unique-Password-Generate([string]$argument1,$HashName,$nonce){
#Declare genrated password variable
$tempPassword = ""

#Get the text from salt file
$text=Get-Content -Path $argument1
#Splitting up the text to each character and create the char array. Then generate random password for that array
$textArray=$text.Split('').ToCharArray()
for($x=0;$x -le $text.Length;$x++){
    $textPass += $textArray | Get-Random
}

#Get stringID from computer where user logs in
[String]$stringSID=Get-ADComputer -Filter "name -eq '$env:computername'" -Properties sid | select sid
#Splitting up the stringID to character and create the array. Then generate random password for that array
$stringSIDArray=$stringSID.Split('=')[1].Replace('}','').ToCharArray()
for($x=0;$x -le $stringSID.Length;$x++){
    $tempPassword += $stringSIDArray | Get-Random
}

#Combining all
$tempPassword += $textPass

#Hash password with the choice of MD5, SHA1, SHA256, etc.
$StringBuilder = New-Object System.Text.StringBuilder 
[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($tempPassword))|%{ 
[Void]$StringBuilder.Append($_.ToString("x2")) 
} 

#Reading nonce passed as argument to the script
$StringBuilder.ToString() + $nonce

}
