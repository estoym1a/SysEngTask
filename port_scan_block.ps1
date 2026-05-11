# 1. Variables
$BlacklistPath = "C:\Security\blacklist.txt"
if (!(Test-Path "C:\Security")) { New-Item -ItemType Directory -Path "C:\Security" }

$TimeLimit = (Get-Date).AddMinutes(-1) 
$ScanThreshold = 10 

Write-Host "Monitorinq başladı..." -ForegroundColor Yellow

# 2. Log-ları gətir
$Logs = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=5156,5152; StartTime=$TimeLimit} `
-ErrorAction SilentlyContinue

if ($Logs) {
    Write-Host "Cəmi $($Logs.Count) ədəd loq tapıldı. Analiz edilir..." -ForegroundColor Gray

    # 3. Məlumatın filter-lənməsi (İndex 5 hücumçudur)
    $Data = $Logs | ForEach-Object {
        # Əgər 5-ci index boşdursa, 3-cü index-ə baxır
        $IP = $_.Properties[5].Value
        if (!$IP -or $IP -eq "0.0.0.0") { $IP = $_.Properties[3].Value }
        
        $Port = $_.Properties[6].Value

        if ($IP -and $IP -ne "192.168.79.10" -and $IP -ne "::1") {
            [PSCustomObject]@{ IP = $IP; Port = $Port }
        }
    }

    # 4. Qruplaşdır və Fayla Yaz
    $Groups = $Data | Group-Object IP

    foreach ($Group in $Groups) {
        $CurrentIP = $Group.Name
        $UniquePorts = ($Group.Group | Select-Object -ExpandProperty Port -Unique).Count

        Write-Host "Yoxlanılır: $CurrentIP | Port sayı: $UniquePorts" -ForegroundColor White

           
            Write-Host "!!! SKANER AŞKARLANDI: $CurrentIP !!!" -ForegroundColor Red
            
            # Fayla yazma əmri
            $Entry = "Tarix: $(Get-Date) | Skaner: $CurrentIP | Port Sayı: $UniquePorts"
            $Entry | Out-File -FilePath $BlacklistPath -Append
            
            Write-Host "Blacklist faylına yazıldı." -ForegroundColor Cyan
        }
    }
 else {
    Write-Host "Log tapılmadı." -ForegroundColor Green
}

# 5. Windows Firewall-da bloklama qaydası yarat
$RuleName = "Block_Scanner_$CurrentIP"

# Əgər bu IP üçün artıq bloklama qaydası yoxdursa, yenisini yarat
if (!(Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $RuleName `
                        -Direction Inbound `
                        -Action Block `
                        -RemoteAddress $CurrentIP `
                        -Description "Avtomatik Port Skan Bloklanması - $(Get-Date)"
    
    Write-Host "-> $CurrentIP üçün Firewall bloklama qaydası yaradıldı!" -ForegroundColor Cyan
} else {
    Write-Host "-> $CurrentIP artıq bloklanıb." -ForegroundColor Yellow
}