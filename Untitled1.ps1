#Script sistemden username-i gotursun, desktopda hemin adda text file-i yaratsin ve file-in icine de hemin adi yazsin

$u = $env:USERNAME; $u | Out-File "$env:USERPROFILE\Desktop\$u.txt"

#basqa usulu:
New-Item `
-Path "C:\Users\$env:USERNAME\Desktop" `
-Path $env:USERNAME.txt`
-Value "Salam hormetli istifadei :$env:USERNAME"