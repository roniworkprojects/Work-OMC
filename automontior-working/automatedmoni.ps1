function Install-Nagios-OnLinux2
		{
# Set the error action preference to SilentlyContinue
$ErrorActionPreference = "SilentlyContinue"
copy C:\testAlexeym\Ronii\automontior-working\automontior-working\InstallNagiosOnLinux.txt.bak C:\testAlexeym\Ronii\automontior-working\automontior-working\InstallNagiosOnLinux.txt -ErrorAction Ignore
copy C:\testAlexeym\Ronii\automontior-working\automontior-working\InstallNagios-MonitorcPanel.txt.bak C:\testAlexeym\Ronii\automontior-working\automontior-working\InstallNagios-MonitorcPanel.txt -ErrorAction Ignore
copy C:\testAlexeym\Ronii\automontior-working\automontior-working\NagiosOnMonitor.txt.bak C:\testAlexeym\Ronii\automontior-working\automontior-working\NagiosOnMonitor.txt -ErrorAction Ignore

cd "C:\Program Files (x86)\PuTTY"
do {
	$connStatus = ""
	$pwMon = ""
	while (!$pwMon) {write-host "Please enter ROOT password for " -foreground "green" -nonewline
		write-host "ip adress" -foreground "Yellow" -backgroundcolor "Black" -nonewline
		$pwMon = read-host " " -AsSecureString
		$pwMon = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwMon))}
	write-host "Checking SSH connection..."
	$connStatus = echo y |.\plink.exe -ssh -l root -pw $pwMon monitor.omc.co.il -nc monitor.omc.co.il:22 | select -Last 2
	}
	until ($connStatus -like '*SSH*')
		echo "Password is OK."

$ivms = @()
write-host "`nEnter a Linux Server VM name for Nagios installation" -foreground "green" -nonewline
write-host " (do not use wildcards [*])" -foreground "red" -nonewline
$name = read-host " "
	while (!$name) 
		{		
		write-host "`nNo VM entered." -foreground "Red"
		write-host "`nEnter 1 VM full name for Nagios installation" -NoNewLine -foreground "green"
		write-host " (do not use wildcards [*])" -foreground "red" -nonewline
		$name = read-host " "
		}
$ErrorActionPreference= 'silentlycontinue'
$name = $name.TrimEnd()
$vmName = Get-VM -Name $name
	while (!$vmName)
		{
		Write-host "`nVM " -foreground "Red" -nonewline
		write-host "'$name'" -foregroundcolor "magenta" -nonewline 
		write-host " does not exists in vCenter " -foreground "Red" -nonewline 
		write-host "`n`nEnter Linux VM name to install nagios" -NoNewLine -foreground "green"
		write-host " (do not use wildcards [*])" -foreground "red" -nonewline
		$name = read-host " "
		$name = $name.TrimEnd()
		$vmName = Get-VM -Name $name
		}
$ivms = $ivms + $vmName;
	while ($name -ne "")
        {
		# Read VM names followed by <enter> until get empty string 
        Write-Host "`nEnter another VM full name for Nagios installation or leave empty to start installing" -foreground "green" -nonewline
		$name = read-host " "
		if ($name -eq "") {break}
		$name = $name.TrimEnd()
		$vmName = Get-VM -Name $name
		if ($vmName) 
			{
			foreach ($ivm in $ivms)
				{
				$vmIngnore = ""
				if ($ivm -eq $vmName)
					{
					write-host ""
					write-host "VM " -foregroundcolor "Red" -nonewline
					write-host "'$name'" -foregroundcolor "magenta" -nonewline
					write-host " already entered. Ignoring.`n" -foregroundcolor "Red"  -nonewline
					$vmIngnore = 1
					break
					}
				}
				if (!$vmIngnore) {
				write-host "`nAdding " -foregroundcolor "magenta" -nonewline
				write-host "$vmName" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
				write-host " to pool." -foregroundcolor "magenta"
				$ivms = $ivms + $vmName
				}
			}else{
				write-host ""
				Write-host "VM " -foregroundcolor "Red" -nonewline
				write-host "'$name'" -foregroundcolor "magenta"  -nonewline
				write-host " does not exists in vCenter.`n" -foreground "Red" -nonewline
				}
			}
$ErrorActionPreference= 'continue'

write-host "`nVM(s) to install: " -foreground "magenta" -nonewline 
	foreach ($ivm in $ivms)
		{
		write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
		write-host "; " -nonewline
		}
		write-host ""

foreach ($vmorg in $ivms)
	{
	$customServices = ""
	$customServicesRemove = ""
	$customServicescPanelPres = "check_http,;check_https,;check_ping,;check_smtp,;check_ssh,;nsca_check_cpu,;nsca_check_disk,;nsca_check_mem"
	$arrayCustomServicescPanelPres = $customServicescPanelPres -split ";"
	$customServicesPres = "check_ping,;check_ssh,;nsca_check_cpu,;nsca_check_disk,;nsca_check_mem"
	$arrayCustomServicesPres = $customServicesPres -split ";"

		write-host "`nVM: " -foreground "yellow" -nonewline
		write-host "$vmorg`n" -foregroundcolor "Yellow" -backgroundcolor "Black"
		write-host "`nEnter Prefix to Virtual Machine name as so: [Customer Number]_[VM Location/City of Physical Machine Location]_[Service Type] (e.g. 123456_il-pt_vm_srv.xyz / 123456_telaviv_pm_xyzserver.local)" -NoNewLine -foreground "green"
		$vmPrefix = read-host " "
		$countPrefix = 1
		
		while (!$vmPrefix -and $countPrefix -lt 3){
			$countPrefix++
			write-host "`nNo VM Prefix entered." -foreground "Red"
			write-host "`nEnter Prefix to VM name [Customer Number]_[VM Location/City of Physical Server Location]_[Service Type] (e.g. 123456_il-pt_vm_www.abc.com / 123456_telaviv_vm_www.abc.com)" -NoNewLine -foreground "green"
			$vmPrefix = read-host " "
		}
		if ($countPrefix -lt 3){
			while (!$checkPrefix){			
				$vm = $vmPrefix + "_" + "$vmorg"			
				write-host "`nVM name with Prefix to be monitored in nagios is: " -nonewline
				write-host "$vm" -foreground "yellow" -backgroundcolor "Black" 
				$vmNewPrefix = read-Host "`nTo change VM Prefix please re-enter, otherwise leave empty and press [ENTER]"
				if ($vmNewPrefix) {
					$vmPrefix = $vmNewPrefix                
				}else{
					$checkPrefix = 1
					}
			}
		}
		else{
			$vm = $vmorg
		}
		
				

	
		$fileNameMon = "C:\testAlexeym\Ronii\automontior-working\NagiosOnMonitor.txt"
		copy $fileNameMon $fileNameMon".bak"
		$fileNameMonBak = "C:\testAlexeym\Ronii\automontior-working\NagiosOnMonitor.txt.bak"
		do {
			write-host "`nIf you need, enter another custom Nagios Service, one at a time, otherwise, leave empty."
			write-host "To add service enter: check_zyx or nsca_check_xyz (e.g. check_ftp)."
			write-host "To remove service enter prefix '-!' (e.g. -!check_https)." 
			write-host "Services already included: " -foreground "magenta"
			write-host $arrayCustomServicesPres"," $customServices -foreground "yellow"
			$customService = read-host " "
			if ($customService -eq "") {break}
				write-host "customService: $customService"			
			if ($customService -like '*-!*') 
				{
				$customService = $customService -replace '[-!]',''
				if (!$customServicesRemove) 
					{
					$customServicesRemove = $customService					
					if ($customService -eq "nsca_check_mem")
						{
						$arrayCustomServicesPres = "$arrayCustomServicesPres" -replace ", $customService", ""
						}else{
						$arrayCustomServicesPres = "$arrayCustomServicesPres" -replace "$customService, ", ""
						}
					$arrayCustomServicesPres = $arrayCustomServicesPres | ? {$_}
					}else{					
					$customServicesRemove = $customServicesRemove + "," + $customService
					if ($customService -eq "nsca_check_mem")
						{
						$arrayCustomServicesPres = "$arrayCustomServicesPres" -replace ", $customService", ""
						}else{
						$arrayCustomServicesPres = "$arrayCustomServicesPres" -replace "$customService, ", ""
						}
						$arrayCustomServicesPres = $arrayCustomServicesPres | ? {$_}
						}
				}else{
					if (!$customServices) 
						{
						$customServices = $customService
						}else{
						$customServices = $customServices + ", " + $customService 
						}
					}
				}
				
		until ($customService -eq "")
	}
	
	if ($customServices)
		{
		write-host "`nCustom Service(s) added: " -foreground "green" -nonewline 
		write-host $customServices 
		
		}

	if ($customServices) 
		{
		$customServices = $customServices | ? {$_}
		(gc $fileNameMon) -replace 'nsca_check_mem', "nsca_check_mem,$customServices" | sc $fileNameMon
		}
	if ($customServicesRemove) 
		{
		write-host "`nCustom Service(s) removed: " -foreground "green" -nonewline
		$icustomServicesRemove = $customServicesRemove -split ","
		foreach ($icustomServiceRemove in $icustomServicesRemove)
			{
			#$icustomServiceRemove = $icustomServiceRemove -replace '[-!]',''
			write-host "$icustomServiceRemove," -foreground "yellow" -backgroundcolor "Black" -nonewline
			if ($cPanel -eq "1") 
				{
				(gc $fileNameMon) -replace  "$icustomServiceRemove,", "" | sc $fileNameMon
				}else{
				(gc $fileNameMon) -replace  "$icustomServiceRemove,", "" | sc $fileNameMon
				}
			}
		}
	$vmPhone = ""
	$vmPhone = read-host "`nEnter Phone number for Alert Contact"
	$vmEmail = read-host "Enter EMail for Alert Contact"
	$fileName = "C:\testAlexeym\Ronii\automontior-working\InstallNagiosOnLinux.txt"
	copy $fileName $fileName".bak"
	$fileNameBak = "C:\testAlexeym\Ronii\automontior-working\InstallNagiosOnLinux.txt.bak"
	
	(gc $fileName) -replace "VMNAME", $vm | sc $fileName
	
	$ipVC = $vmorg.guest.IPAddress[0]
	$ip = read-host "`nPlease enter '$vm' IP address or leave empty to extract from VC (IP: $ipVC)"
	if (!$ip) {		
		$ip = $vmorg.guest.IPAddress[0]
	}else{
		write-host "IP address entered is: " -nonewline
		write-host "$ip" -foreground "yellow" -backgroundcolor "Black" 
		$ipNew = read-Host "To change IP address please re-enter, otherwise leave empty and press [ENTER]"
		if ($ipNew) {$ipNew = $ip}
		}
	write-host "IP address entered is: " -nonewline
	write-host "$ip" -foreground "yellow" -backgroundcolor "Black" 
	
	cd "C:\Program Files (x86)\PuTTY"
	
	do {
		$connStatus = ""
		$pw = ""
		write-host "`n$vm ($ip)" -foreground "Yellow" -backgroundcolor "Black"
			while (!$pw) {$pw = read-host "Please enter password" -AsSecureString
				$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw))}
		write-host "Checking SSH connection..."
		
		$plinkCmd = ".\plink.exe -ssh -l root -pw $pw $ip -m c:\script\other\ssh_exit.txt"
		$connStatus = Invoke-Expression $plinkCmd | Select-Object -Last 1
		#$connStatus = echo y |.\plink.exe -ssh -l root -pw $pw $ip -nc $ip":22" | select -Last 2
		}
		until ($connStatus -like '*')

		echo y |.\plink.exe -ssh -l root -pw $pw $ip -m $fileName

	(gc $fileName) -replace $vm, "VMNAME" | sc $fileName
	write-host "`n********************************************"
	write-host "Ended Nagios installation on server: " -foreground "green" -nonewline
	write-host "$vm" -foreground "Yellow" -backgroundcolor "Black"
	write-host "********************************************"
	write-host "`nConfiguring server $vm on the Nagios Server (monitor.omc.co.il)...`n" -foreground "green"
	
	(gc $fileNameMon) -replace "VMNAME", $vm | sc $fileNameMon
	(gc $fileNameMon) -replace "VMIP", $ip | sc $fileNameMon
	if (!$vmPhone -and !$vmEmail)
		{
		(gc $fileNameMon) -replace '`grep -iw "contact_name.*VMPHONE"', '! `grep -iw "contact_name.*VMPHONE"' | sc $fileNameMon
		(gc $fileNameMon) -replace '`grep -iw "contact_name.*VMEMAIL"', '! `grep -iw "contact_name.*VMEMAIL"' | sc $fileNameMon
		(gc $fileNameMon) -replace "`tcontacts.+", "" | sc $fileNameMon
		(gc $fileNameMon) | ? {$_.trim() -ne "" } | sc $fileNameMon
		}else{
		if ($vmPhone) {
			write-host "Adding contact " -foreground "green" -nonewline
			write-host "'$vmPhone'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " to Nagios server." -foreground "green"
			(gc $fileNameMon) -replace "VMPHONE", $vmPhone | sc $fileNameMon
			}else{
			(gc $fileNameMon) -replace '`grep -iw "contact_name.*VMPHONE"', '! `grep -iw "contact_name.*VMPHONE"' | sc $fileNameMon
			(gc $fileNameMon) -replace 'contacts        VMPHONE@sms.inforu.co.il,', 'contacts        ' | sc $fileNameMon
		}
		if ($vmEmail) {
			write-host "Adding contact " -foreground "green" -nonewline
			write-host "'$vmEmail'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " to Nagios server." -foreground "green"
			(gc $fileNameMon) -replace "VMEMAIL", $vmEmail | sc $fileNameMon
			}
			else{
			(gc $fileNameMon) -replace '`grep -iw "contact_name.*VMEMAIL"', '! `grep -iw "contact_name.*VMEMAIL"' | sc $fileNameMon
			(gc $fileNameMon) -replace ',VMEMAIL', '' | sc $fileNameMon
		}
	}
    echo y | .\plink.exe -ssh -l root -pw $pwMon monitor.omc.co.il -m $fileNameMon
	(gc $fileNameMon) -replace $vm, "VMNAME" | sc $fileNameMon
	(gc $fileNameMon) -replace $ip, "VMIP" | sc $fileNameMon
	if ($vmPhone) {(gc $fileNameMon) -replace $vmPhone, "VMPHONE" | sc $fileNameMon}
	if ($vmEmail) {(gc $fileNameMon) -replace $vmEmail, "VMEMAIL" | sc $fileNameMon}
	(gc $fileNameMon) -replace '! `', '`' | sc $fileNameMon
	(gc $fileNameMon) -replace "nsca_check_mem", "nsca_check_mem`r`n`tcontacts        VMPHONE@sms.inforu.co.il,VMEMAIL" | sc $fileNameMon
	(gc $fileNameMon) | ? {$_.trim() -ne "" } | sc $fileNameMon
	(gc $fileNameMon) -replace "nsca_check_mem,$customServices", "nsca_check_mem" | sc $fileNameMon
	copy $fileNameMonBak $fileNameMon
	copy $fileNameBak $fileName
	write-host "********************************************"
	write-host "Ended $vm Nagios configuration on monitor.omc.co.il." -foreground "Yellow" -backgroundcolor "Black"
	write-host "********************************************"

	}
