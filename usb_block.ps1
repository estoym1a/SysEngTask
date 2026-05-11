# 1. Ən son USB qoşulma hadisəsini (ID 2003) alırıq
$Log = Get-WinEvent -LogName "Microsoft-Windows-DriverFrameworks-UserMode/Operational" | 
Where-Object {$_.Id -eq 2003} | 
Select-Object -First 1

if ($Log) {

    # 2. Loqdan gələn ID-ni alırıq
    $LogId = $Log.Properties[1].Value.ToString()
    
    # 3. Sistemdəki BÜTÜN Disklər içindən loqdakı ID-yə uyğun gələni tapırıq
    # Burada markadan asılı olmayaraq loqdakı seriya nömrəsini axtarırıq
    $Device = Get-PnpDevice -Class "DiskDrive" | 
    Where-Object {
        $CleanInstanceId = $_.InstanceId.Replace("\", "#")
        $LogId -like "*$CleanInstanceId*"
    }

    if ($Device) {

        # 4. BLOKLAMA (Bütün USB yaddaş qurğuları üçün)
        try {
            $Device | Disable-PnpDevice -Confirm:$false
            
            # Log faylına yazırıq
            $Time = Get-Date
            $LogMessage = "$Time | BLOKLANDI: $($Device.FriendlyName) | 
            ID: $($Device.InstanceId)"
            $LogMessage | Out-File -FilePath "C:\Security\usb_logs.txt" -Append
            
            Write-Host "UĞURLU: $($Device.FriendlyName) dərhal bloklandı!" -ForegroundColor Green
        } catch {
            Write-Host "XƏTA: Səlahiyyət çatmadı və ya cihaz artıq söndürülüb." -ForegroundColor Red
        }
    } else {
        Write-Host "Məlumat: Yeni bir cihaz taxıldı, amma Mass Storage (Disk) deyil. Müdaxilə edilmədi." `
        -ForegroundColor Cyan
    }
}