Function EjectCDROMs{
#Get array of all Clusters
$myDatacenter = read-host "Enter a location (e.g. 'as' - for the DataCenter in Asia)"
Get-Datacenter -Name $myDatacenter | Get-Cluster | Format-List Name
$myClusters = read-host "Enter a cluster from list"
Write-Host ""

#Create VMs array
$VMs = @()

Write-Host "Okay - I'm going to check all VMs whether there are mounted ISO files."
Write-Host "This will take some time - get yourself some coffee.. ;-)"
Write-Host ""

#Get vms of cluster
                #Get VMs
                #$thisVMs = Get-VM
                if (!$myClusters) {$thisVMs = Get-Datacenter -Name $myDatacenter | Get-VM
				}else{
				$thisVMs = Get-Datacenter -Name $myDatacenter | Get-Cluster $myClusters | Get-VM}
                $counter=0;

                #Get VM information
                foreach ($vm in $thisVMs) {
                               #Get view
                               $vmView = $vm | Get-View

                               if( (($vm | Get-CDDrive).ISOPath) -or (($vm | Get-CDDrive).RemoteDevice) -or (($vm | Get-CDDrive).HostDevice) )
                               {
                                               #Setup output
                                               $VMInfo = "" | Select "VM","Host","ISO","RemoteDevice","HostDevice"

                                               #Write-Host "VM = $vm | Host = " ($vm | Get-VMHost).name " | ISO = " ($vm | Get-CDDrive).ISOPath " / Remote-Device = " $(vm | Get-CDDrive).RemoteDevice " / HostDevice = " $(vm | Get-CDDrive).HostDevice

                                               #Defining hostname, ESX host and ISO path
                                               $VMInfo."VM" = $vm.Name
                                               $VMInfo."Host" = ($vm | Get-VMHost).Name
                                               $VMInfo."ISO" = ($vm | Get-CDDrive).ISOPath
                                               $VMInfo."RemoteDevice" = ($vm | Get-CDDrive).RemoteDevice
                                               $VMInfo."HostDevice" = ($vm | Get-CDDrive).HostDevice

                                               #Add to array
                                               $VMs += $VMInfo
                               }

                               $counter++;
                               if( $counter % 10 -eq 0 ) {
                               Write-Host "Check $counter of " $thisVMs.length " in " $cluster " so far..."
                               }
                }

#sort array by Cluster
$VMs | Sort Cluster

#disconnect
$answer = Read-Host "Found " $VMs.length " mappings - force disconnect now? [Y/N]"
if($answer -eq "y")
{
                foreach ($vm in $VMs)
                {
                               Write-Host "Disconnect on " $vm.VM "..."
                               Get-VM $vm.VM | Get-CDDrive | Set-CDDrive -NoMedia -Confirm:$false
                }
}
else { Write-Host "Disconnect aborted by user." }
}
Function CopyVLanID
		{
$vlanname = read-host "Please enter VLAN name to copy" 
write-host "Host to copy from (SOURCE)" -foreground "green" -nonewline 
$vmhostfrom = read-host " "
$vmhostfrom = Get-VMHost -Name "$vmhostfrom*" 
write-host "Host to copy to (DESTINATION)" -foreground "Red" -nonewline
$vmhostto = read-host " "
$vmhostto = Get-VMHost -Name "$vmhostto*" 
$vswitch = Get-VirtualSwitch -VMHost $vmhostto.Name | sort | select -First 1
$vlanid = Get-VirtualPortGroup -VMHost $vmhostfrom.Name -Name $vlanname
New-VirtualPortGroup -VirtualSwitch $vswitch -Name $vlanname -vlanid $vlanid.Vlanid
# -VirtualSwitch $vswitch.Name
}

Function Migrate-Vm
        {
$ivms = @(); # array of srings for VM names
$ivmsTOmigrate = @(); # array of srings for VM names
$VmsCPUType = @()
$CheckCPUtypes = @()

write-host "ROOOOOOO"
write-host "`n[00]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " Show VM(s) with more than 2 vCPUs and CPU usage under 10%."
write-host "`n[01]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " Show VM(s) with CPU usage greater than 10% and 'cpuReserve' not true."
write-host "`nEnter datacenter number to migrate VM(s)." -foreground "Yellow" -backgroundcolor "Black"
write-host "`n[0]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " IL"
write-host "`n[1]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " US-TX232322"
write-host "`n[2]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU"
write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " AS"
write-host "`n[4]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " IL-RH"
write-host "`n[5]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " US-NY2"
write-host "`n[6]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU-LO"
write-host "`n[7]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " IL-PT"
write-host "`n[8]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " US-SC"
write-host "`n[9]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " IL-TA"
write-host "`n[10]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " IL-HA"
write-host "`n[11]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU-FR"
write-host "`n[12]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " CA-TR"
write-host "`n[13]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " US-MI"
write-host "`n[14]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " US-CH"
write-host "`n[15]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU-MD"
write-host "`n[16]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU-ML"
write-host "`n[17]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
write-host " EU-ST`n"

do {
	$vmsDCEnt = read-host "Enter your DataCenter selection"
	if ($vmsDCEnt -eq "00" -or $vmsDCEnt -eq "01") {		
		do {$VMhostName = read-host "Enter VMHost Name (e.g. vm201)"
			$VMHost = Get-VMhost $VMhostName-*}
		until ($VMhost)
		$VMhost
		if ($vmsDCEnt -eq "00"){
			write-host "`nSerching for VM(s) with more than 2 vCPUs and usage under 10% on " -foreground "Yellow" -nonewline
			write-host "${VMhost}. " -foreground "Yellow" -backgroundcolor "Black"
			write-host "`nIt may take some time!" -foreground "Yellow" -backgroundcolor "Red" -nonewline
			write-host " (depending on the number of VMs in host)" -foreground "Magenta"  -nonewline
			write-host " ..." -foreground "Yellow" 
			$VMhost | Get-VM | Select-Object Name,NumCPU,@{N="UsedSpace";E={[Math]::Round(($_.UsedSpaceGB),0)}},@{N="Mem Usage";E={[math]::Round((get-stat -realtime -stat mem.usage.average -entity $_ -start (get-date).addminutes(-1)-IntervalMins 1 -MaxSamples (1)).Value / 100 * $_.MemoryMB)}},@{N='CPU%';E={[Math]::Round("$(Get-Stat -Entity $_ -Stat cpu.usage.average -Realtime -MaxSamples 1 | select -ExpandProperty Value)")}},@{N="Notes";E={$_ | Select-Object -ExpandProperty Notes}},PowerState | ? {$_.NumCpu -ge 2 -and $_."CPU%" -lt 10 -and $_.PowerState -Like "PoweredOn"} | Sort-Object "NumCpu",UsedSpace,"Mem Usage" | ft -Autosize
		}elseif ($vmsDCEnt -eq "01"){
			write-host "`nSerching for VM(s) with CPU usage greater than 10% and 'cpuReserve' not true on " -foreground "Yellow" -nonewline
			write-host "${VMhost}. " -foreground "Yellow" -backgroundcolor "Black"
			write-host "`nIt may take some time!" -foreground "Yellow" -backgroundcolor "Red" -nonewline
			write-host " (depending on the number of VMs in host)" -foreground "Magenta"  -nonewline
			write-host " ..." -foreground "Yellow" 
			$VMhost | Get-VM | Select-Object Name,@{N='NumCpuUsed';E={[Math]::Round($_.NumCPU * "$(Get-Stat -Entity $_ -Stat cpu.usage.average -Realtime -MaxSamples 1 | select -ExpandProperty Value)" / 100)}},NumCPU,@{N="UsedSpace";E={[Math]::Round(($_.UsedSpaceGB),0)}},@{N="Mem Usage";E={[math]::Round((get-stat -realtime -stat mem.usage.average -entity $_ -start (get-date).addminutes(-1)-IntervalMins 1 -MaxSamples (1)).Value / 100 * $_.MemoryMB)}},@{N='CPU%';E={[Math]::Round("$(Get-Stat -Entity $_ -Stat cpu.usage.average -Realtime -MaxSamples 1 | select -ExpandProperty Value)")}},@{N="Notes";E={$_ | Select-Object -ExpandProperty Notes}},PowerState | ? {$_."CPU%" -ge 10 -and $_.PowerState -Like "PoweredOn" -and $_.Notes -notMatch "cpuReserve=true"} | Sort-Object NumCpuUsed,NumCpu,UsedSpace,"Mem Usage" | ft -Autosize
		}
	}	
	if ($vmsDCEnt -eq "00") {write-host "Enter datacenter number to migrate VM(s)"  -foreground "Yellow" -backgroundcolor "Black"  -nonewline;$vmsDCEnt = read-host " "}
	if ($vmsDCEnt -eq "0") {$vmsDC = Get-Datacenter IL}
	if ($vmsDCEnt -eq 1) {$vmsDC = Get-Datacenter US-TX}
	if ($vmsDCEnt -eq 2) {$vmsDC = Get-Datacenter EU}
	if ($vmsDCEnt -eq 3) {$vmsDC = Get-Datacenter AS}	
	if ($vmsDCEnt -eq 4) {$vmsDC = Get-Datacenter IL-RH}
	if ($vmsDCEnt -eq 5) {$vmsDC = Get-Datacenter US-NY2}
	if ($vmsDCEnt -eq 6) {$vmsDC = Get-Datacenter EU-LO}
	if ($vmsDCEnt -eq 7) {$vmsDC = Get-Datacenter IL-PT}
	if ($vmsDCEnt -eq 8) {$vmsDC = Get-Datacenter US-SC}
	if ($vmsDCEnt -eq 9) {$vmsDC = Get-Datacenter IL-TA}
	if ($vmsDCEnt -eq 10) {$vmsDC = Get-Datacenter IL-HA}
	if ($vmsDCEnt -eq 11) {$vmsDC = Get-Datacenter EU-FR}
	if ($vmsDCEnt -eq 12) {$vmsDC = Get-Datacenter CA-TR}
	if ($vmsDCEnt -eq 13) {$vmsDC = Get-Datacenter US-MI}
	if ($vmsDCEnt -eq 14) {$vmsDC = Get-Datacenter US-CH}
	if ($vmsDCEnt -eq 15) {$vmsDC = Get-Datacenter EU-MD}
	if ($vmsDCEnt -eq 16) {$vmsDC = Get-Datacenter EU-ML}
	if ($vmsDCEnt -eq 17) {$vmsDC = Get-Datacenter EU-ST}
} until ($vmsDC)
	write-host "`nDataCenter selected: " -nonewline
	write-host "$vmsDC" -foreground "Yellow" -backgroundcolor "Black" 

	write-host "`nEnter 1 VM full name to migrate (" -foreground "green" -NoNewLine
	write-host "wildcard can be used at end of name" -foreground "red" -nonewline
	write-host ")" -foreground "green" -NoNewLine
	$name = read-host "   "
	while (!$name){		
		write-host "`nNo VM entered." -foreground "Red"
		write-host "`nEnter 1 VM full name to migrate (" -foreground "green" -NoNewLine
		write-host "wildcard can be used at end of name" -foreground "red" -nonewline
		write-host ")" -foreground "green" -NoNewLine
		$name = read-host "   "
	}
	$ErrorActionPreference= 'silentlycontinue'
	$name = $name.TrimEnd()
	$VMVCName = Get-VM -Location $vmsDC -Name $name
	$vmDataCenter = $VMVCName.vmhost.parent.parentfolder.parent.Name
	$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
	while (!$vmDataCenter -or $VMRelocated){
		do {
			if (!$vmDataCenter){
				Write-host "`nVM " -foreground "Red" -nonewline
				write-host "'$name'" -foregroundcolor "magenta" -nonewline 
				write-host " does not exists or not in the same vCenter as selected DataCenter1 " -foreground "Red" -nonewline 
				write-host "$vmsDC`n" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
				write-host "`nEnter 1 VM full name to migrate (" -NoNewLine -foreground "green"
				write-host "wildcard can be used at end of name" -foreground "red" -nonewline
				write-host ")" -foreground "green" -NoNewLine
				$name = read-host "   "
				$name = $name.TrimEnd()
				$VMVCName = Get-VM -Location $vmsDC -Name $name
				$vmDataCenter = $VMVCName.vmhost.parent.parentfolder.parent.Name
				$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
			}
			if ($VMRelocated){
				Write-host "`nVM " -foreground "Red" -nonewline
				write-host "'$name'" -foregroundcolor "magenta" -nonewline 
				write-host " is already being migrated.`n" -foreground "Red" -nonewline 
				write-host "`nEnter 1 VM full name to migrate (" -NoNewLine -foreground "green"
				write-host "wildcard can be used at end of name" -foreground "red" -nonewline
				write-host ")" -foreground "green" -NoNewLine
				$name = read-host "   "
				$name = $name.TrimEnd()
				$VMVCName = Get-VM -Location $vmsDC -Name $name
				$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
				$vmDataCenter = $VMVCName.vmhost.parent.parentfolder.parent.Name
			}
		} until ($vmDataCenter -and !$VMRelocated)
	}

	$ivms = $ivms + $VMVCName
	while ($name -ne ""){
		$name = $name.TrimEnd()
		$VMVCName = Get-VM -Location $vmsDC -Name $name
		$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
		While ($VMRelocated){
			do {
				if ($VMRelocated){
					Write-host "`nVM " -foreground "Red" -nonewline
					write-host "'$name'" -foregroundcolor "magenta" -nonewline 
					write-host " is already being migrated.`n" -foreground "Red" -nonewline 
					write-host "`nEnter 1 VM full name to migrate (" -NoNewLine -foreground "green"
					write-host "wildcard can be used at end of name" -foreground "red" -nonewline
					write-host ")" -foreground "green" -NoNewLine
					$name = read-host "   "
					$name = $name.TrimEnd()
					$VMVCName = Get-VM -Location $vmsDC -Name $name
					$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
					$vmDataCenter = $VMVCName.vmhost.parent.parentfolder.parent.Name
				}
			} until (!$VMRelocated)
		}
		if (($VMVCName | Select-Object -ExpandProperty Notes) -like "*hostcpumodel=*"){			
			$CPUType = ($VMVCName.Notes -split (",") | sls "hostcpumodel=") -Split("=") | Sort | Select -First 1
			$Allhostcpumodel = ($VMVCName.Notes -split (",") | sls "hostcpumodel") -join "," | ? {$_.trim() -ne "" }
			$AllCPUType = (($VMVCName.Notes -split (",") | sls "hostcpumodel=") -Split("=") -replace "hostcpumodel","" | ? {$_.trim() -ne "" }) -join ","
			$Delimter = ":"
			$VmsCPUType = $VmsCPUType + "$VMVCName$Delimter$CPUType"
			write-host "`nVM '$VMVCName' is marked as " -foregroundcolor "magenta" -nonewline
			write-host $Allhostcpumodel -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
			write-host ". Migration is allowed only to ESXi hosts with Processor Type: " -foregroundcolor "magenta"	-nonewline			
			write-host $AllCPUType  -foregroundcolor "Yellow" -backgroundcolor "Black"  -nonewline
			write-host " or higher." -foregroundcolor "magenta"
			foreach ($VmCPUType in $VmsCPUType){$CheckCPUtypes += $VmCPUType.split(":")[1]}
			if (($CheckCPUtypes | Unique).Count -gt 1){
				write-host "`nThere are different Processor Types marked in multiple VMs notes (hostcpumodel=)." -foreground "Red" -backgroundcolor "Black"
				write-host "`nMigrate again and choose only the VMs with the same processor types marked in notes." -foreground "Yellow" -backgroundcolor "Black" -nonewline
				break 2
			}
		}
		if (($VMVCName | Select-Object -ExpandProperty Notes) -like "*storagetype=ssd*" -or ($VMVCName | Select-Object -ExpandProperty Notes) -like "*SSD-MUST*"){
			write-host "VM '$VMVCName' is marked as " -foregroundcolor "Red" -nonewline
			write-host "storagetype=ssd" -foregroundcolor "magenta" -backgroundcolor "Black" -nonewline
			write-host ". Migration is allowed to SSD storage only!" -foregroundcolor "Red"
			$SSDMust = 1
			if ($SATAMust){
				write-host "`nThere are different Storage Types marked in multiple VMs notes (storagetype=)." -foreground "Red" -backgroundcolor "Black"
				write-host "`nMigrate again and choose only the VMs with the same Storage Types marked in notes." -foreground "Yellow" -backgroundcolor "Black" -nonewline
				break 2
			}
		}
		if (($VMVCName | Select-Object -ExpandProperty Notes) -like "*storagetype=sata*" -or ($VMVCName | Select-Object -ExpandProperty Notes) -like "*SSD-MUST*"){
			write-host "VM '$VMVCName' is marked as " -foregroundcolor "Red" -nonewline
			write-host "storagetype=sata" -foregroundcolor "magenta" -backgroundcolor "Black" -nonewline
			write-host ". Migration is allowed to SATA storage only!" -foregroundcolor "Red"
			$SATAMust = 1
			if ($SSDMust){
				write-host "`nThere are different Storage Types marked in multiple VMs notes (storagetype=)." -foreground "Red" -backgroundcolor "Black"
				write-host "`nMigrate again and choose only the VMs with the same Storage Types marked in notes." -foreground "Yellow" -backgroundcolor "Black" -nonewline
				break 2
			}
		}
		if ($VMVCName.ExtensionData.Snapshot.RootSnapshotList.Name){
			if ($VMVCName.ExtensionData.Snapshot.RootSnapshotList.Name -Like "VEEAM BACKUP TEMPORARY SNAPSHOT" -or $VMVCName.ExtensionData.Snapshot.RootSnapshotList.Name -Like "Veeam Replica Working Snapshot"){$isSnapshot = 1}
			#if (!$isSnapshot){$VMVCNameSnap = $VMVCName | Get-Snapshot;if ($VMVCNameSnap.Name -Like "VEEAM BACKUP TEMPORARY SNAPSHOT" -or $VMVCNameSnap.Name -Like "Veeam Replica Working Snapshot"){$isSnapshot = 1}}
			if ($VMVCName.ExtensionData.Snapshot.RootSnapshotList.ChildSnapshotList.Name -Like "VEEAM BACKUP TEMPORARY SNAPSHOT" -or $VMVCName.ExtensionData.Snapshot.RootSnapshotList.ChildSnapshotList.Name -Like "Veeam Replica Working Snapshot"){$isSnapshotChild = 1}
			if ($isSnapshot -or $isSnapshotChild){
				#if ($VMVCNameSnap){
				#	$VMVCNameSnapDate = Get-Date ($VMVCNameSnap | ? {$_.Name -Match "VEEAM BACKUP TEMPORARY SNAPSHOT|Veeam Replica Working Snapshot"} | Select -Last 1).Created
				#}else{
				if ($isSnapshot){	
					$VMVCNameSnapDate = Get-Date ($VMVCName.ExtensionData.Snapshot.RootSnapshotList | ? {$_.Name -Match "VEEAM BACKUP TEMPORARY SNAPSHOT|Veeam Replica Working Snapshot"} | Select -Last 1).CreateTime
				}elseif ($isSnapshotChild){	
					$VMVCNameSnapDate = Get-Date ($VMVCName.ExtensionData.Snapshot.RootSnapshotList.ChildSnapshotList | ? {$_.Name -Match "VEEAM BACKUP TEMPORARY SNAPSHOT|Veeam Replica Working Snapshot"} | Select -Last 1).CreateTime 
				}
				$createdHoursAgo = [math]::Round((((Get-Date) - $VMVCNameSnapDate).TotalHours) - 3)
				write-host "`n====================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
				write-host "VM " -foreground "Magenta" -backgroundcolor "Black" -nonewline
				write-host $VMVCName -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " has " -foreground "Magenta" -backgroundcolor "Black" -nonewline
				write-host '"VEEAM BACKUP TEMPORARY SNAPSHOT"' -foreground "Yellow" -backgroundcolor "Red" -nonewline
				write-host " created " -foreground "Magenta" -backgroundcolor "Black" -nonewline
				write-host $createdHoursAgo -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " hours ago (" $VMVCNameSnapDate ")." -foreground "Magenta" -backgroundcolor "Black"
				write-host "====================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
				do {
					write-host -nonewline "Continue migrating "
					write-host $VMVCName.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host -nonewline "? [Y/N] "							
					$response = read-host
				} until ($response -eq "Y" -or $response -eq "N")
				if ($response -eq "N"){
					if (($ivms | Select -First 1) -Like $VMVCName){
						$ivms = @()
					}else{
						$ivms = $ivms | ? {$_ -notLike $VMVCName};$NoMigrate = $null
					}
				}
				$VMVCNameSnap = $null
				$VMVCNameSnapDate = $null
				$isSnapshot = $null
				$isSnapshotChild = $null
				$createdHoursAgo = $null
			}
		}
		if (($VMVCName | Select-Object -ExpandProperty Notes) -Match "nomigrate=true" -or ($VMVCName | Select-Object -ExpandProperty Notes) -Match "host="){			
			write-host "`n===================================================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
			write-host "VM " -foreground "Magenta" -backgroundcolor "Black" -nonewline
			write-host $VMVCName -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " is marked as " -foreground "Magenta" -backgroundcolor "Black" -nonewline
			if (($VMVCName | Select-Object -ExpandProperty Notes) -Match "nomigrate=true"){
				write-host '"nomigrate=true"'  -foreground "Red" -backgroundcolor "Black" -nonewline
			}
			if (($VMVCName | Select-Object -ExpandProperty Notes) -Match "host=" -and ($VMVCName | Select-Object -ExpandProperty Notes) -Match "nomigrate=true"){
				$VMVCNameHostNote = (($VMVCName | Select-Object -ExpandProperty Notes).Split(',') | sls "host=") -replace "`n",""
				write-host " and " -foreground "Magenta" -backgroundcolor "Black" -nonewline
				write-host '"' -foreground "Red" -backgroundcolor "Black" -nonewline
				write-host $VMVCNameHostNote'"'  -foreground "Red" -backgroundcolor "Black" -nonewline
			}else{
				if (($VMVCName | Select-Object -ExpandProperty Notes) -Match "host="){
					$VMVCNameHostNote = (($VMVCName | Select-Object -ExpandProperty Notes).Split(',') | sls "host=") -replace "`n",""
					write-host '"' -foreground "Red" -backgroundcolor "Black" -nonewline
					write-host $VMVCNameHostNote'"'  -foreground "Red" -backgroundcolor "Black" -nonewline
				}
			}
			write-host ". VM needs additional approval for migration. Please contact your manager." -foreground "Magenta" -backgroundcolor "Black" # -nonewline
			write-host "===================================================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
			$NoMigrate = 1			
			do {
				write-host -nonewline "Continue migrating "
				write-host $VMVCName.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host -nonewline "? [Y/N] "							
				$response = read-host
			} until ($response -eq "Y" -or $response -eq "N")
			if ($response -eq "N"){
				if (($ivms | Select -First 1) -Like $VMVCName){
					$ivms = @()
				}else{
					$ivms = $ivms | ? {$_ -notLike $VMVCName};$NoMigrate = $null
				}
			}
		}
		
		Write-Host "Enter another VM full name to migrate or leave empty to start migrating" -foreground "green" -nonewline
		$name = $null
		$name = read-host " "		
		if ($name){
			$name = $name.TrimEnd()
			$VMVCName = Get-VM -Location $vmsDC -Name $name
			$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
			While ($VMRelocated){
				do {
					if ($VMRelocated){
						Write-host "`nVM " -foreground "Red" -nonewline
						write-host "'$name'" -foregroundcolor "magenta" -nonewline 
						write-host " is already being migrated.`n" -foreground "Red" -nonewline 
						write-host "`nEnter 1 VM full name to migrate (" -NoNewLine -foreground "green"
						write-host "wildcard can be used at end of name" -foreground "red" -nonewline
						write-host ")" -foreground "green" -NoNewLine
						$name = read-host "   "
						$name = $name.TrimEnd()
						$VMVCName = Get-VM -Location $vmsDC -Name $name
						$VMRelocated = $VMVCName | Get-VIEvent | Select -First 1 | ? {$_.FullFormattedMessage -Match "Relocate virtual machine|Migrating.*off host|Hot migrating"}
					}
				} until (!$VMRelocated)
			}
			if ($vmDataCenter -eq ($VMVCName.vmhost.parent.parentfolder.parent.Name)){
				if ($ivms -Match "^${VMVCName}$"){
					write-host "VM " -foregroundcolor "Red" -nonewline
					write-host "'$name'" -foregroundcolor "magenta" -nonewline
					write-host " already entered. Ignoring." -foregroundcolor "Red"
				}else{
					$ivms = $ivms + $VMVCName
				}
			}else{
				Write-host "VM " -foregroundcolor "Red" -nonewline
				write-host "'$name'" -foregroundcolor "magenta"  -nonewline
				write-host " does not exists in vCenter or not in same DataCenter " -foreground "Red" -nonewline
				write-host "'$vmDataCenter'" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
				write-host ".`n" -foreground "Red" -nonewline
			}
		}
	}
	$ErrorActionPreference= 'continue'
	write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
	foreach ($ivm in $ivms){
		write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
		write-host "; " -nonewline
	}
	write-host ""

	if (!$ivms){write-host "`nNo VMs left to migrate. Exiting..." -foreground "Red" -backgroundcolor "Black" ;break}

#Select Host
$VMhostsMatch = @()
$VMhosts = Get-VMHost -Location $vmsDC | ? {$_.ConnectionState -ne "Maintenance" -and $_.ExtensionData.Summary.Runtime.ConnectionState -eq 'connected' -and ($_ | Get-Annotation | ? {$_.Name -Like "Dedicated Customer Host"}).Value.trimEnd() -eq ""}

if ($CheckCPUtypes){
	$CheckCPUtypesLow = $CheckCPUtypes | Unique | Sort | Select -Last 1
	$VMhostsMatch += $VMhosts | ? {(($_.ProcessorType.Split(' ') | sls [0-9][0-9][0-9][0-9]) -replace "[^0-9]") -ge $CheckCPUtypesLow}
}
if ($ivms.Notes -Match "withvm=" -or $ivms.Notes -Match "withoutvm="){
	$vmsWithNote = $ivms | ? {$_.Notes -Match "withvm="}
	if ($vmsWithNote){
		$vmsWith = @()
		Foreach ($vmWithNote in $vmsWithNote){$vmsWith += (((($vmWithNote.Notes.Split(',') | sls "withvm=") -replace "`n","") -split '=' | sls -NotMatch "withvm") -replace "`n","")}
		$VMhostsVMsWith = @()
		Foreach ($GetVMWith in ($vmsWith -Split ",")){$VMhostsVMsWith += (Get-VM -location $vmsDC $GetVMWith).VMhost}
		$VMhostsMatch += $VMhostsVMsWith
	}
	$vmsWithoutNote = $ivms | ? {$_.Notes -Match "withoutvm="}
	if ($vmsWithoutNote){
		$vmsWithout = @()
		Foreach ($vmWithoutNote in $vmsWithoutNote){$vmsWithout += (((($vmWithoutNote.Notes.Split(',') | sls "withoutvm=") -replace "`n","") -split '=' | sls -NotMatch "withoutvm") -replace "`n","")}
		$VMhostsVMsWithout = @()
		$ErrorActionPreference= 'silentlycontinue'
		Foreach ($GetVMWithout in $vmsWithout -Split ","){$VMhostsVMsWithout += (Get-VM -location $vmsDC $GetVMWithout).VMhost}
		$ErrorActionPreference= 'continue'
	}
}

if ($VMhostsVMsWithout){
	if ($VMhostsMatch){
		$VMhostsMatch = $VMhostsMatch | ? {$_.Name -notLike $VMhostsVMsWithout.Name}
	}else{
		$VMhostsMatch = $VMhosts | ? {$_.Name -notLike $VMhostsVMsWithout.Name}
	}
}elseif (!$VMhostsMatch){
	$VMhostsMatch = $VMhosts
}

$VMhostsSame = $ivms.VMhost | Sort -Unique
#if ($VMhostSame.Count -eq 1){$VMhostsMatch = $VMhostsMatch | ? {$_.Name -notLike $VMhostSame}}
Foreach ($VMhostSame in $VMhostsSame){$VMhostsMatch = $VMhostsMatch | ? {$_.Name -notLike $VMhostSame}}

Write-Host "`nVMHosts recommended which match VMs notes & resources (choose from last):" -foreground "Yellow" -backgroundcolor "Black"
$VMhostsMatchView = $VMhostsMatch | Select-Object Name,@{N="CPU Usage";E={[Math]::Round(($_.CpuUsageMhz / $_.CpuTotalMhz * 100),0)}},@{N="Mem Usage";E={[Math]::Round(($_.MemoryUsageMB / $_.MemoryTotalMB * 100),0)}},@{N="SpaceGB";E={Get-Datastore -VMHost $_ vm[0-9]*:storage[0-9]*}},@{N="UUID";E={$_.ExtensionData.hardware.systeminfo.uuid}} | Foreach {$_ | Select-Object Name,@{N="Storages";E={(($_.SpaceGB | Measure-Object FreeSpaceGB).Count)}},@{N="FreeSpace";E={[Math]::Round((($_.SpaceGB | Measure-Object FreeSpaceGB -Sum).Sum),0)}},@{N="Capacity";E={[Math]::Round((($_.SpaceGB | Measure-Object CapacityGB -Sum).Sum),0)}},"CPU Usage","Mem Usage",UUID} | ? {$_.Storages -eq 1} | Sort FreeSpace,"CPU Usage","Mem Usage" #| ft -AutoSize
$VMhostsMatchViewAnnot = @()
Foreach ($VMhostMatchView in $VMhostsMatchView){
	$uuidVMhost = $VMhostMatchView.uuid
	if ((((Invoke-WebRequest -Uri "https://staging.cloudwm.com/cwmqueue/cwmstatus/$uuidVMhost" -UseBasicParsing).Content | ConvertFrom-Json).SyncRoot | sls allowProvisioning) -Match "True"){
		$VMhostMatchViewProv = $VMhostMatchView | Select-Object *,@{N="Provisioning";E={echo "Allow"}}
		$VMhostsMatchViewAnnot += $VMhostMatchViewProv
	}else{
		$VMhostsMatchViewAnnot += $VMhostMatchView | Select-Object *,@{N="Provisioning";E={echo ""}}
	}
}
$VMhostsMatchViewAnnot | Select-Object Name,FreeSpace,Capacity,"CPU Usage","Mem Usage",Provisioning | ft -AutoSize


:VMHostSelect do {
	$datastoreFound = $null
	$vmhost = SelectHostFast
	$esxcli = $vmhost | Get-EsxCli
	while ($vmDataCenter -ne ($vmhost.parent.parentfolder.parent.Name)){
		write-host "`nHost " -foreground "Red" -nonewline
		write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " is not in the same DataCenter " -foreground "Red" -nonewline
		write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
		$vmhost = ""
		$vmhost = SelectHostFast
		$esxcli = $vmhost | Get-EsxCli
	}
	
	Function ChooseiVMsorVMhost {
		[CmdletBinding()]
		param(
			[Parameter(Mandatory=$true,HelpMessage="ivms")]$ivms
		)
		$script:ivmsRM = @()
		do {
			$ChoiceVMorHost = read-Host "Select VM to remove for migration & continue [1], or choose another host [2]"
			if ($ChoiceVMorHost -eq 1){
				do {
					$ivms | Select Name,NumCpu | ft -AutoSize
					$VM2RM = read-host "Enter VM name to remove form migration, or press 'ENTER' to continue"
					$ivms = $ivms | ? {$_.Name -notMatch $VM2RM}
					$script:ivmsRM += $VM2RM
				} until ($VM2RM -eq "")
			}
			if ($ChoiceVMorHost -eq 2){
				continue VMHostSelect
			}
		} until ($ChoiceVMorHost -eq 1 -or $ChoiceVMorHost -eq 2)
	}
	
	$uuidVMhost = $VMhost.ExtensionData.hardware.systeminfo.uuid
	if ((((Invoke-WebRequest -Uri "https://staging.cloudwm.com/cwmqueue/cwmstatus/$uuidVMhost").Content | ConvertFrom-Json).SyncRoot | sls allowProvisioning) -Match "True"){
		Write-Host "`nNew Servers Provisioning Host!" -foreground "Yellow" -backgroundcolor "Red"
		Write-Host " " -nonewline
		$VMHostCpuTotalMhz = $vmhost.CpuTotalMhz
		$VMHostLCPU = $vmhost.numcpu
		$cpuThreads = $vmhost.numcpu * 2
		$cpuThreads500 = [int]$cpuThreads * 5
		$cpuThreads300 = [int]$cpuThreads * 3
		$ivmsCPUs = $ivms.NumCpu | measure -sum | % sum
		$VMhostCPUs = ($vmhost | Get-VM | ? {$_.PowerState -Like "PoweredOn"}).NumCpu | measure -sum | % sum
		$vmsCpuCount = [int]$ivmsCPUs + [int]$VMhostCPUs
		if ($vmsCpuCount -gt $cpuThreads500){
			Write-Host "`n`nVMs CPU Count is higher than 500% ($vmsCpuCount vCPUs out of $cpuThreads500 vCPUs ($cpuThreads X 5))`n" -foreground "Red" -backgroundcolor "Black"
			$ChooseiVMsorVMhostOn = 1
			ChooseiVMsorVMhost $ivms
		}elseif ($vmsCpuCount -gt $cpuThreads300){
			Write-Host "`n`nVMs CPU Count is higher than 300% ($vmsCpuCount vCPUs out of $cpuThreads300 vCPUs ($cpuThreads X 3))`n" -foreground "Yellow" -backgroundcolor "Black"
			$ChooseiVMsorVMhostOn = 1
			ChooseiVMsorVMhost $ivms
		}
		
		Foreach ($ivmRM in $ivmsRM){$ivms = $ivms | ? {$_ -notLike $ivmRM}}
		#$ivms | Select Name,NumCpu | ft -AutoSize
		write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
		foreach ($ivm in $ivms){
			write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
			write-host "; " -nonewline
		}
		write-host ""
		
		$VMscpuR = $ivms | ? {$_.Notes -Match "cpuReserve=true"}
		if ($VMscpuR){
			Write-Host "`n`nUn-allowed to migrate to " -foreground "Red" -nonewline
			Write-Host "New Servers Provisioning Host" -foreground "Yellow" -backgroundcolor "Red" -nonewline
			Write-Host " VM(s) with note '" -foreground "Red" -nonewline
			Write-Host "cpuReserve=true" -backgroundcolor "Yellow" -foreground "Black" -nonewline
			Write-Host "': " -foreground "Red" -nonewline
			Write-Host ($VMscpuR.Name -Join ";") -foreground "Yellow" -backgroundcolor "Black"
			continue VMHostSelect
		}elseif (!$ChooseiVMsorVMhostOn){
			Read-Host "`nPress any key to continue"
		}
	}
	
	if ($CPUType){
		if ([int]($CheckCPUtypes | Unique | Sort | Select -Last 1) -gt [int]((($vmhost.ProcessorType.Split(' ') | sls [0-9][0-9][0-9][0-9]*) -split ("-"))[-1] -replace "[^0-9]")){
			do {
				write-host "`nHost " -foreground "Red" -nonewline
				write-host $vmhost.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " has a different Processor Type (" -foreground "Red" -nonewline
				write-host $vmhost.ProcessorType -foreground "Yellow" -backgroundcolor "Black" -nonewline 
				write-host ") than marked in note:"  -foreground "Red" -nonewline
				write-host ($CheckCPUtypes | Unique | Select -Last 1) "`n" -foreground "Yellow" -backgroundcolor "Black" -nonewline 
				$vmhost = ""
				$vmhost = SelectHostFast					
					if ($vmDataCenter -ne ($vmhost.parent.parentfolder.parent.Name)){
						write-host "`nHost " -foreground "Red" -nonewline
						write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
						write-host " is not in the same DataCenter " -foreground "Red" -nonewline
						write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
						write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
						$vmhost = ""
						$vmhost = SelectHostFast
						$esxcli = $vmhost | Get-EsxCli
					}
				}
			until ([int]($CheckCPUtypes | Unique | Select -First 1) -le [int]((($vmhost.ProcessorType.Split(' ') | sls [0-9][0-9][0-9][0-9]*) -split ("-"))[-1] -replace "[^0-9]"))
		}
	}
	if ($SSDMust -eq 1){
		if (!($esxcli.storage.core.device.list() | ? {$_.DisplayName -Match "Disk"} | ? {$_.IsSSD -eq "true"})){
			do {
				write-host "`nHost " -foreground "Red" -nonewline
				write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " does not have SSD storage.`n" -foreground "Red" -nonewline
				$vmhost = ""
				$vmhost = SelectHostFast					
				if ($vmDataCenter -ne ($vmhost.parent.parentfolder.parent.Name)){
					#$esxcli = $vmhost | Get-EsxCli
				#} else {
					write-host "`nHost " -foreground "Red" -nonewline
					write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host " is not in the same DataCenter " -foreground "Red" -nonewline
					write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
					$vmhost = ""
					$vmhost = SelectHostFast
					$esxcli = $vmhost | Get-EsxCli
				}
			}
			until ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Where-Object {$_.IsSSD -eq "true"})
		}
	}
	
	if ($SATAMust -eq 1){
		if ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Where-Object {$_.IsSSD -eq "false"}){
		} else {
			write-host "`nHost" -foreground "Red" -nonewline
			write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " does not have SATA storage.`n" -foreground "Red" -nonewline			
			$vmsWithSATANote = $ivms | ? {$_.Notes -Match "storagetype=sata"}
			if ($vmsWithSATANote){
			:SkipWithSATAVM	foreach ($vmWithSATANote in $vmsWithSATANote){	
					if (!$ivms){break}										
					write-host "`n$vmWithSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
					write-host " must be on SATA storage." -foreground "Red" -backgroundcolor "Black"						
					do {
						write-host -nonewline "Continue migrating "
						write-host $vmWithSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
						write-host -nonewline "? [Y/N] "														
						$answerWithSATAVM = read-host
						if ($answerWithSATAVM -eq "Y"){$SkipWithSATAVMC = 1;continue SkipWithSATAVM}
						if ($answerWithSATAVM -eq "N"){
							$ivms = $ivms | ? {$_ -notLike $vmWithSATANote}
							if ($ivms){																										
								write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
								foreach ($ivm in $ivms){
									write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
									write-host "; " -nonewline
								}
								write-host ""
							}else{
								break 2
							}
							continue SkipWithSATAVM
						}											
					} until ($answerWithSATAVM -eq "Y" -or $answerWithSATAVM -eq "N" -or $answerWithSATAVM -eq "C")										
				}			
			}
		}
	}
	$VMsCPUReserve = $vmhost | Get-VM | ? {$_.Notes -Match "cpuReserve=true"}
	if ($VMsCPUReserve){
		Write-Host "`nFound VM(s) with " -foreground "Green" -nonewline
		Write-Host "'cpuReserve=true'" -backgroundcolor "Yellow" -foreground "Black" -nonewline
		Write-Host ": " -foreground "Green" -nonewline
		Write-Host ($VMsCPUReserve.Name -Join ", ") -foreground "Yellow" -backgroundcolor "Black"
		Write-Host "Checking there's enough free vCPUs on host for migrating..." -foreground "Green"
		$VMHostCpuTotalMhz = $vmhost.CpuTotalMhz
		$VMHostLCPU = $vmhost.numcpu
		$cpuThreads = $vmhost.numcpu * 2
		$hostCpuMhz = [Math]::Ceiling(($VMHostCpuTotalMhz / $VMHostLCPU) / 100) * 100
		$CPULOADVALUE = (Get-Stat $VMhost | ? {$_.MetricId -Like "cpu.usage.average"}).Value | Select -First 1
		$freeVCPU = [Math]::Round($cpuThreads - ($cpuThreads * ($CPULOADVALUE / 100)))
		$cpuCountNeededVMsArray = @()
		Foreach ($VMCPUReserve in $VMsCPUReserve){
			$cpuCount = $VMCPUReserve.NumCpu
			$ErrorActionPreference = 'SilentlyContinue'
			$cpuUsageMhz = (Get-Stat $VMCPUReserve | ? {$_.MetricId -Like "cpu.usagemhz.average"}).Value | Select -First 1
			$ErrorActionPreference = 'Continue'
			$cpuUsagePer = [Math]::Round($cpuUsageMhz / ($cpuCount * $hostCpuMhz) * 100)
			$cpuCountUsageVM = [Math]::Round($cpuCount * ($cpuUsagePer / 100))
			$cpuCountNeededVM = $cpuCount - $cpuCountUsageVM
			$cpuCountNeededVMsArray += $cpuCountNeededVM
		}
		$cpuCountNeededVMs = $null;$cpuCountNeededVMsArray | Foreach {$cpuCountNeededVMs += $_}
		#Foreach ($ivm in $ivms){$ivmsCPUs = $ivm.NumCpu + $ivmsCPUs}
		$ivmsCPUs = $ivms.NumCpu | measure -sum | % sum
		if (($cpuCountNeededVMs + ($ivmsCPUs / 3)) -gt $freeVCPU){
			write-host "`nNot enough free vCPUs on host for migrating. " -foreground "Yellow" -backgroundcolor "Magenta" -nonewline
			$VMsCPU = $cpuCountNeededVMs + $ivmsCPUs - $freeVCPU
			write-host $VMsCPU -nonewline -foreground "Yellow" -backgroundcolor "Red"
			Write-Host " vCPU(s) are needed." -foreground "Yellow" -backgroundcolor "Magenta"
			do {						
				write-host "Continue migrating? [Y/N] " -nonewline 
				$answerCPUReserve = read-host
				if ($answerCPUReserve -eq "Y"){continue}
				if ($answerCPUReserve -eq "N"){
					$ivms = $ivms | ? {$_ -notLike $vmWithNote}
					if ($ivms){																										
						write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
						foreach ($ivm in $ivms){
							write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
							write-host "; " -nonewline
						}
						write-host ""
					}
					continue SkipWithVM
				}
			} until ($answerCPUReserve -eq "Y" -or $answerCPUReserve -eq "N")
		}
	}
	
	$AnnoValue = ($vmhost | Get-Annotation | where {$_.Name -Like "Dedicated Customer Host"}).Value.trimEnd()
	while ($AnnoValue){
		write-host "`n=============================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
		write-host "||  $vmhost is a Dedicated Customer Host or has a custom remark: " -foreground "Yellow" -backgroundcolor "Black" -nonewline
		#write-host " Migrate only Servers belonging to " -foreground "Red" -backgroundcolor "Black" -nonewline
		write-host "$AnnoValue" -foreground "Red" -backgroundcolor "Black" -nonewline
		#write-host "!!! " -foreground "Red" -backgroundcolor "Black" -nonewline
		write-host ".              " -foreground "Yellow" -backgroundcolor "Black"
		write-host "=============================================================================================================================" -foreground "Yellow" -backgroundcolor "Black"
		
		Write-Host "`nEnter new host or leave empty to migrate to " -foreground "green" -nonewline
		write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
		$newVMHost = read-host " "
		if (!$newVMHost){
			$AnnoValue = $null
		}else{
			$vmhost = $null
			$vmhost = SelectHostFast $newVMHost			
			while ($vmDataCenter -ne ($vmhost | Get-Datacenter)){
				write-host "`nHost " -foreground "Red" -nonewline
				write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " is not in the same DataCenter " -foreground "Red" -nonewline
				write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
				write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
				$vmhost = ""
				$vmhost = SelectHostFast
				$esxcli = $vmhost | Get-EsxCli
			}
			if ($CPUType){	
				if ($vmhost.ProcessorType -notMatch ($CheckCPUtypes | Unique | Select -First 1)){
					do {
						write-host "`nHost " -foreground "Red" -nonewline
						write-host $vmhost.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
						write-host " has a different Processor Type (" -foreground "Red" -nonewline
						write-host $vmhost.ProcessorType -foreground "Yellow" -backgroundcolor "Black" -nonewline 
						write-host ") than marked in note:"  -foreground "Red" -nonewline
						write-host ($CheckCPUtypes | Unique | Select -First 1) "`n" -foreground "Yellow" -backgroundcolor "Black" -nonewline 
						$vmhost = ""
						$vmhost = SelectHostFast						
							if ($vmDataCenter -eq ($vmhost | Get-Datacenter)){
								$esxcli = $vmhost | Get-EsxCli
							} else {
								write-host "`nHost " -foreground "Red" -nonewline
								write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
								write-host " is not in the same DataCenter " -foreground "Red" -nonewline
								write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
								write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
								$vmhost = ""
								$vmhost = SelectHostFast
								$esxcli = $vmhost | Get-EsxCli
							}
						}
					until ($vmhost.ProcessorType -Match ($CheckCPUtypes | Unique | Select -First 1))
				}
			}
			if ($SSDMust -eq 1){
				#$esxcli = $vmhost | Get-EsxCli
				if ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Where-Object {$_.IsSSD -eq "true"}){
					} else {
					do {
					write-host "`nHost " -foreground "Red" -nonewline
					write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host " does not have SSD storage.`n" -foreground "Red" -nonewline
					$vmhost = ""
					$vmhost = SelectHostFast					
						if ($vmDataCenter -eq ($vmhost | Get-Datacenter)){
							$esxcli = $vmhost | Get-EsxCli
						} else {
							write-host "`nHost " -foreground "Red" -nonewline
							write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
							write-host " is not in the same DataCenter " -foreground "Red" -nonewline
							write-host "$vmDataCenter" -foreground "Yellow" -backgroundcolor "Black" -nonewline
							write-host " as the VM(s) entered above.`n" -foreground "Red" -nonewline
							$vmhost = ""
							$vmhost = SelectHostFast
							$esxcli = $vmhost | Get-EsxCli
						}
					}
					until ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Where-Object {$_.IsSSD -eq "true"})
				}
			}
			if ($SATAMust -eq 1){
				#$esxcli = $vmhost | Get-EsxCli
				if ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Where-Object {$_.IsSSD -eq "false"}){
				} else {
					#do {
					write-host "`nHost " -foreground "Red" -nonewline
					write-host "'$vmhost'" -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host " does not have SATA storage.`n" -foreground "Red" -nonewline
					$vmsWithSATANote = $ivms | ? {$_.Notes -Match "storagetype=sata"}
					if ($vmsWithSATANote){
					:SkipWithSATAVM2	foreach ($vmWithSATANote in $vmsWithSATANote){	
									#$vmsWithSATA = (((($vmWithSATANote.Notes.Split(',') | sls "storagetype=") -replace "`n","") -split '=') -replace "`n","")				
										#foreach ($vmWithSATA in $vmsWithSATA){
											if (!$ivms){break}											
											write-host "`n$vmWithSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
											write-host " must be on SATA storage." -foreground "Red" -backgroundcolor "Black"						
											do {
												write-host -nonewline "Continue migrating "
												write-host $vmWithSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
												write-host -nonewline "? [Y/N] "														
												$answerWithSATAVM = read-host
												if ($answerWithSATAVM -eq "Y"){$SkipWithSATAVMC = 1;continue SkipWithSATAVM2}
												if ($answerWithSATAVM -eq "N"){
													$ivms = $ivms | ? {$_ -notLike $vmWithSATANote}
													if ($ivms){																										
														write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
														foreach ($ivm in $ivms){
															write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
															write-host "; " -nonewline
														}
														write-host ""
													}else{
														break 2
													}
													continue SkipWithSATAVM2
												}												
											} until ($answerWithSATAVM -eq "Y" -or $answerWithSATAVM -eq "N" -or $answerWithSATAVM -eq "C")
										}			
									#}
					}
				}
			}	
		$AnnoValue = ($vmhost | Get-Annotation | where {$_.Name -Like "Dedicated Customer Host"}).Value.trimEnd()
		}
	}
	
	if ($ivms.Notes -Match "withvm=" -or $ivms.Notes -Match "withoutvm="){
		$vmsWithNote = $ivms | ? {$_.Notes -Match "withvm="}
		if ($vmsWithNote){
:SkipWithVM	foreach ($vmWithNote in $vmsWithNote){			
				$vmsWith = (((($vmWithNote.Notes.Split(',') | sls "withvm=") -replace "`n","") -split '=' | sls -NotMatch "withvm") -replace "`n","")				
				foreach ($vmWith in $vmsWith){
					if (!$ivms){break}
					if (($vmhost | Get-VM | ? {$_.Name -Like $vmWith}).Count -eq 0){				
						write-host "`n$vmWithNote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
						write-host " must be on same host as " -nonewline -foreground "Red" -backgroundcolor "Black"
						write-host $vmWith  -nonewline -foreground "Yellow" -backgroundcolor "Black"
						write-host "." -foreground "Red" -backgroundcolor "Black"						
						do {						
							write-host -nonewline "Continue migrating "
							write-host $vmWithNote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
							write-host -nonewline "? [Y/N] "							
							$answerWithVM = read-host
							if ($answerWithVM -eq "Y"){continue}
							if ($answerWithVM -eq "N"){
								$ivms = $ivms | ? {$_ -notLike $vmWithNote}
								if ($ivms){																										
									write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
									foreach ($ivm in $ivms){
										write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
										write-host "; " -nonewline
									}
									write-host ""
								}
								continue SkipWithVM
							}
						} until ($answerWithVM -eq "Y" -or $answerWithVM -eq "N")
					}
				}			
			}
		}
		$vmsWithoutNote = $ivms | ? {$_.Notes -Match "withoutvm="}
		if ($vmsWithoutNote){
:SkipWithoutVM foreach ($vmWithoutNote in $vmsWithoutNote){			
				$vmsWithout = (((($vmWithoutNote.Notes.Split(',') | sls "withoutvm=") -replace "`n","") -split '=' | sls -NotMatch "withvm") -replace "`n","")
				foreach ($vmWithout in $vmsWithout){
					if (!$ivms){$vmWithout = $null;break}
					if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithout}).Count -gt 0){				
						write-host "`n$vmWithoutNote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
						write-host " must not be on same host as " -nonewline -foreground "Red" -backgroundcolor "Black"
						write-host $vmWithout  -nonewline -foreground "Yellow" -backgroundcolor "Black"
						write-host "." -foreground "Red" -backgroundcolor "Black"
						do {
							write-host -nonewline "Continue migrating "
							write-host $vmWithoutNote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
							write-host -nonewline "? [Y/N] "														
							$answerWithoutVM = read-host
							if ($answerWithoutVM -eq "Y"){continue}
							if ($answerWithoutVM -eq "N"){
								$ivms = $ivms | ? {$_ -notLike $vmWithoutNote}
								if ($ivms){																										
									write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
									foreach ($ivm in $ivms){
										write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
										write-host "; " -nonewline
									}
									write-host ""
								}
								continue SkipWithoutVM
							}
						} until ($answerWithoutVM -eq "Y" -or $answerWithoutVM -eq "N")
					}
				}			
			}
		}
	}	
	
	if ((($vmhost | get-vm).NumCPU | measure -sum | % sum) -gt ($vmhost.NumCPU * 2 * 0.7)){
		$VMHostLCPU = $vmhost.numcpu * 2
		$PerMinVMHost = 0.3
		foreach ($ivm in $ivms){
			if ($ivm.NumCPU -gt ($VMHostLCPU * $PerMinVMHost)){
				write-host "`n$ivm" -nonewline -foreground "Yellow" -backgroundcolor "Black"
				write-host " has " -nonewline -foreground "Red" -backgroundcolor "Black"
				write-host $ivm.NumCPU  -nonewline -foreground "Yellow" -backgroundcolor "Black"
				write-host " CPUs, which is more than required " -nonewline -foreground "Red" -backgroundcolor "Black"
				write-host ($PerMinVMHost * 100) "%" -nonewline -foreground "Yellow" -backgroundcolor "Black"
				write-host " of target host Logical Processors (" -nonewline -foreground "Red" -backgroundcolor "Black"
				write-host $VMHostLCPU -nonewline -foreground "Yellow" -backgroundcolor "Black"
				write-host ")" -foreground "Red" -backgroundcolor "Black"
				do {
					write-host -nonewline "Continue migrating "
					write-host $ivm.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host -nonewline "? [Y/N] "														
					$answerMinCPU = read-host
					if ($answerMinCPU -eq "Y"){$answerMinCPUSubject = 1;continue}
					if ($answerMinCPU -eq "N"){
						$ivms = $ivms | ? {$_ -notLike $ivm}
						if ($ivms){																										
							write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
							foreach ($ivm in $ivms){
								write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
								write-host "; " -nonewline
							}
							write-host ""
						}
						#continue SkipWithoutVM
					}
				} until ($answerMinCPU -eq "Y" -or $answerMinCPU -eq "N")			
			}
		}
	}
	
	if ($ivms -and $ivms.Notes -Match "hostosversion="){
		$VMshostosversion = $ivms | ? {$_.Notes -Match "hostosversion="}
		$HostVer = ((($VMHost | get-view).Config.Product.FullName -split " " | sls "^[0-9]") -replace "(?m)^\s*`r`n",'').substring(0,3)
		Foreach ($VMhostosversion in $VMshostosversion){
			$hostosversion = (($VMhostosversion.Notes -Split (",") | sls "hostosversion=") -Split ("=") | sls "^[0-9]") -replace "(?m)^\s*`r`n",''
#write-host "hostosversion: $hostosversion"
#write-host "HostVer: $HostVer"
			if ((($hostosversion) -match $HostVer) -eq $false -or !(($hostosversion) -match $HostVer)){
				write-host "`n$VMhostosversion" -nonewline -foreground "Yellow" -backgroundcolor "Black"
				write-host " must be on host ESXi version " -nonewline -foreground "Red" -backgroundcolor "Black"
				write-host $hostosversion -foreground "Yellow" -backgroundcolor "Black"				
				do {
					write-host -nonewline "Continue migrating "
					write-host $VMhostosversion.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
					write-host -nonewline "? [Y/N] "														
					$answerhostosversion = read-host
					if ($answerhostosversion -eq "Y"){$answerhostosversionSubject = 1;continue}
					if ($answerhostosversion -eq "N"){
						$ivms = $ivms | ? {$_ -notLike $VMhostosversion}
						if ($ivms){																										
							write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
							foreach ($ivm in $ivms){
								write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
								write-host "; " -nonewline
							}
							write-host ""
						}
						#continue SkipWithoutVM
					}
				} until ($answerhostosversion -eq "Y" -or $answerhostosversion -eq "N")
			}
		}
	}
	
	if (!$ivms){write-host "`nNo VMs left to migrate. Exiting..." -foreground "Red" -backgroundcolor "Black" ;break}
	
	write-host "`nAvailable Datastore(s) to migrate to:" -foreground "green"
	#$vmhost.Datastores.Name
	$vmhost | Get-Datastore -Refresh | select Name,@{N="FreeSpace(GB)";E={[Math]::Round($_.FreeSpaceMB/1024)}}, @{N="(%) Free";E={[math]::Round(((100* ($_.FreeSpaceMB))/ ($_.CapacityMB)),0)}}, @{N="Capacity(GB)";E={[Math]::Round($_.CapacityMB/1024)}} | Sort-Object name -Descending | ft -au
	$vmhostDatastores = $vmhost | Get-Datastore
	write-host "Enter a Datastore Name from the list above or press:" -foreground "green"
	write-host "`n[0]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
	write-host " To choose a different VMHost`n" -foreground "Magenta" -backgroundcolor "Black"
	write-host "[1]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
	write-host " To choose the default local VM storage (e.g. vm9:storage1)" -foreground "green"
	write-host "[2]" -foreground "Yellow" -backgroundcolor "Black"  -nonewline
	write-host " To choose the second local VM storage (e.g. vm9:storage2)" -foreground "green"
	write-host "[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
	write-host " To choose the third local VM storage (e.g. vm9:storage3)" -foreground "green"
	
	$dataStoreName = read-host "Enter your choice";
	while (!$datastoreFound){
		:empty
		while (!$dataStoreName)
			{
			write-host "`nNo Datastore entered." -foreground "Red"
			write-host "`nEnter a Datastore Name from the list above or press local VM storage number" -foreground "green"
			write-host "(e.g. for vm9:storage1 press 1)" -foreground "green" -nonewline
			$dataStoreName = read-host " ";
			}
		while (!$datastoreFound)
			{	
			foreach ($datastore in ($vmhostDatastores.Name | ? {$_ -Match ":storage"})){
				if  ($dataStoreName -eq 1){
					if ($datastore -like "*:storage1*"){
						$isSSD = ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Local DELL Disk"} | Select-Object IsSSD).IsSSD | Select -First 1	
#write-host "isSSD: " $isSSD						
						if ((($isSSD -eq $true -and $SATAMust) -or ($isSSD -eq $false -and !$SATAMust)) -and $SkipWithSATAVMC -ne 1){
							$datastoreFound = 1							
							$vmsWithSATANote = $ivms | ? {$_.Notes -Match "storagetype=sata"}
							if ($vmsWithSATANote){
								write-host "`nSelected storage: " -foreground "Red" -backgroundcolor "Black" -nonewline
								write-host $datastoreFound -foreground "Yellow" -backgroundcolor "Black" -nonewline
								write-host " is not compatible with SATA requirements." -backgroundcolor "Black" -foreground "Red" # -nonewline
							:SkipWithSATAVM01	foreach ($vmWithSATANote in $vmsWithSATANote){	
												if (!$ivms){break}
												#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithSATANote}).Count -gt 0){				
													write-host "`n$vmWithSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
													write-host " must be on SATA storage." -foreground "Red" -backgroundcolor "Black"						
													do {
														write-host -nonewline "Continue migrating "
														write-host $vmWithSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
														write-host -nonewline "? [Y/N] "														
														$answerWithSATAVM = read-host
														if ($answerWithSATAVM -eq "Y"){continue}
														if ($answerWithSATAVM -eq "N"){
															$ivms = $ivms | ? {$_ -notLike $vmWithSATANote}
															if ($ivms){																										
																write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																foreach ($ivm in $ivms){
																	write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																	write-host "; " -nonewline
																}
																write-host ""
															}
															continue SkipWithSATAVM01
														}
													} until ($answerWithSATAVM -eq "Y" -or $answerWithSATAVM -eq "N")
												#}
											}
							}
						}
						if ($isSSD -eq $false){
							$vmsWithOutSATANote = $ivms | ? {$_.Notes -notMatch "storagetype=sata"}
							if ($vmsWithOutSATANote){
							:SkipWithSATAVM001	foreach ($vmWithOutSATANote in $vmsWithOutSATANote){	
												if (!$ivms){break}
												#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithOutSATANote}).Count -gt 0){				
													write-host "`n$vmWithOutSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
													write-host " is not marked for SATA Storage." -foreground "Red" -backgroundcolor "Black"						
													do {
														write-host -nonewline "Continue migrating "
														write-host $vmWithOutSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
														write-host -nonewline "? [Y/N] "														
														$answerWithOutSATAVM = read-host
														if ($answerWithOutSATAVM -eq "Y"){continue}
														if ($answerWithOutSATAVM -eq "N"){
															$ivms = $ivms | ? {$_ -notLike $vmWithOutSATANote}
															if ($ivms){																										
																write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																foreach ($ivm in $ivms){
																	write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																	write-host "; " -nonewline
																}
																write-host ""
															}
															continue SkipWithSATAVM001
														}
													} until ($answerWithOutSATAVM -eq "Y" -or $answerWithOutSATAVM -eq "N")
												#}
											}
							}
						}						
						$datastoreFound = $datastore
						write-host "`nSelected storage: " -foreground "Yellow" -nonewline
						write-host "$datastoreFound" -foreground "Yellow" -backgroundcolor "Black" -nonewline
						$isVMHostSelect = 1
						break
					}
				}
				if  ($dataStoreName -eq 2){
					if ($datastore -like "*:storage2*"){
						$isSSD = ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Select-Object IsSSD).IsSSD | Select -First 2 | Select -Last 1	
						if ((($isSSD -eq $true -and $SATAMust) -or ($isSSD -eq $false -and !$SATAMust)) -and $SkipWithSATAVMC -ne 1){
							$datastoreFound = 1							
							$vmsWithSATANote = $ivms | ? {$_.Notes -Match "storagetype=sata"}
							if ($vmsWithSATANote){
								write-host "`nSelected storage: " -foreground "Red" -backgroundcolor "Black" -nonewline
								write-host $datastoreFound -foreground "Yellow" -backgroundcolor "Black" -nonewline
								write-host " is not compatible with SATA requirements." -backgroundcolor "Black" -foreground "Red" # -nonewline
							:SkipWithSATAVM02	foreach ($vmWithSATANote in $vmsWithSATANote){	
												if (!$ivms){break}
												#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithSATANote}).Count -gt 0){				
													write-host "`n$vmWithSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
													write-host " must be on SATA storage." -foreground "Red" -backgroundcolor "Black"						
													do {
														write-host -nonewline "Continue migrating "
														write-host $vmWithSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
														write-host -nonewline "? [Y/N] "														
														$answerWithSATAVM = read-host
														if ($answerWithSATAVM -eq "Y"){continue}
														if ($answerWithSATAVM -eq "N"){
															$ivms = $ivms | ? {$_ -notLike $vmWithSATANote}
															if ($ivms){																										
																write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																foreach ($ivm in $ivms){
																	write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																	write-host "; " -nonewline
																}
																write-host ""
															}
															continue SkipWithSATAVM02
														}
													} until ($answerWithSATAVM -eq "Y" -or $answerWithSATAVM -eq "N")
												#}
											}
							}
						}else{						
							if ($isSSD -eq $false){
								$vmsWithOutSATANote = $ivms | ? {$_.Notes -notMatch "storagetype=sata"}
								if ($vmsWithOutSATANote){
								:SkipWithSATAVM002	foreach ($vmWithOutSATANote in $vmsWithOutSATANote){	
													if (!$ivms){break}
													#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithOutSATANote}).Count -gt 0){				
														write-host "`n$vmWithOutSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
														write-host " is not marked for SATA Storage." -foreground "Red" -backgroundcolor "Black"						
														do {
															write-host -nonewline "Continue migrating "
															write-host $vmWithOutSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
															write-host -nonewline "? [Y/N] "														
															$answerWithOutSATAVM = read-host
															if ($answerWithOutSATAVM -eq "Y"){continue}
															if ($answerWithOutSATAVM -eq "N"){
																$ivms = $ivms | ? {$_ -notLike $vmWithOutSATANote}
																if ($ivms){																										
																	write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																	foreach ($ivm in $ivms){
																		write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																		write-host "; " -nonewline
																	}
																	write-host ""
																}
																continue SkipWithSATAVM002
															}
														} until ($answerWithOutSATAVM -eq "Y" -or $answerWithOutSATAVM -eq "N")
													#}
												}
								}
							}
						}
						$datastoreFound = $datastore
						write-host "`nSelected storage: " -foreground "Yellow" -nonewline
						write-host "$datastoreFound" -foreground "Yellow" -backgroundcolor "Black" -nonewline
						$isVMHostSelect = 1
						break
					}
				}
				if  ($dataStoreName -eq 3){
					if ($datastore -like "*:storage3*"){
						$isSSD = ($esxcli.storage.core.device.list() | Where-Object {$_.DisplayName -Match "Disk"} | Select-Object IsSSD).IsSSD | Select -First 3 | Select -Last 1
						if ((($isSSD -eq $true -and $SATAMust) -or ($isSSD -eq $false -and !$SATAMust)) -and $SkipWithSATAVMC -ne 1){
							$datastoreFound = 1							
							$vmsWithSATANote = $ivms | ? {$_.Notes -Match "storagetype=sata"}
							if ($vmsWithSATANote){
								write-host "`nSelected storage: " -foreground "Red" -backgroundcolor "Black" -nonewline
								write-host $datastoreFound -foreground "Yellow" -backgroundcolor "Black" -nonewline
								write-host " is not compatible with SATA requirements." -backgroundcolor "Black" -foreground "Red" # -nonewline
							:SkipWithSATAVM03	foreach ($vmWithSATANote in $vmsWithSATANote){	
												if (!$ivms){break}
												#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithSATANote}).Count -gt 0){				
													write-host "`n$vmWithSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
													write-host " must be on SATA storage." -foreground "Red" -backgroundcolor "Black"						
													do {
														write-host -nonewline "Continue migrating "
														write-host $vmWithSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
														write-host -nonewline "? [Y/N] "														
														$answerWithSATAVM = read-host
														if ($answerWithSATAVM -eq "Y"){continue}
														if ($answerWithSATAVM -eq "N"){
															$ivms = $ivms | ? {$_ -notLike $vmWithSATANote}
															if ($ivms){																										
																write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																foreach ($ivm in $ivms){
																	write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																	write-host "; " -nonewline
																}
																write-host ""
															}
															continue SkipWithSATAVM03
														}
													} until ($answerWithSATAVM -eq "Y" -or $answerWithSATAVM -eq "N")
												#}
											}
							}							
						}else{						
							if ($isSSD -eq $false){
								$vmsWithOutSATANote = $ivms | ? {$_.Notes -notMatch "storagetype=sata"}
								if ($vmsWithOutSATANote){
								:SkipWithSATAVM002	foreach ($vmWithOutSATANote in $vmsWithOutSATANote){	
													if (!$ivms){break}
													#if (($vmhost | Get-VM | ? {$_.Name -Like $vmWithOutSATANote}).Count -gt 0){				
														write-host "`n$vmWithOutSATANote" -nonewline -foreground "Yellow" -backgroundcolor "Black"
														write-host " is not marked for SATA Storage." -foreground "Red" -backgroundcolor "Black"						
														do {
															write-host -nonewline "Continue migrating "
															write-host $vmWithOutSATANote.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
															write-host -nonewline "? [Y/N] "														
															$answerWithOutSATAVM = read-host
															if ($answerWithOutSATAVM -eq "Y"){continue}
															if ($answerWithOutSATAVM -eq "N"){
																$ivms = $ivms | ? {$_ -notLike $vmWithOutSATANote}
																if ($ivms){																										
																	write-host "`nVM(s) Selected: " -foreground "magenta" -nonewline 
																	foreach ($ivm in $ivms){
																		write-host "$ivm" -foregroundcolor "Yellow" -backgroundcolor "Black" -nonewline
																		write-host "; " -nonewline
																	}
																	write-host ""
																}
																continue SkipWithSATAVM002
															}
														} until ($answerWithOutSATAVM -eq "Y" -or $answerWithOutSATAVM -eq "N")
													#}
												}
								}
							}
						}
						$datastoreFound = $datastore
						write-host "`nSelected storage: " -foreground "Yellow" -nonewline
						write-host "$datastoreFound" -foreground "Yellow" -backgroundcolor "Black" -nonewline
						$isVMHostSelect = 1
						break
					}
				}
				if  ($dataStoreName -eq 0){$datastoreFound = 1;break :VMHostSelect}
				if ($datastore -eq $dataStoreName){
					$datastoreFound = $dataStoreName
					write-host "`nSelected storage: " -foreground "Yellow" -nonewline
					write-host "$datastoreFound" -foreground "Yellow" -backgroundcolor "Black" -nonewline
					$isVMHostSelect = 1
					break
				}
			}
			if (!$datastoreFound){				
				write-host "`nDatastore entered is not available or wrong." -foreground "Red"
				write-host "`nPlease enter again a Datastore from the list above or press local VM storage number" -foreground "green"
				write-host "(e.g. for vm9:storage1 press 1)" -foreground "green" -nonewline
				$dataStoreName = read-host " ";
				if (!$dataStoreName) {break :empty}
			}
		}
	}
} until ($isVMHostSelect)
write-host ""

if (!$ivms){break}

$VMsSize = ($ivms | Select @{N="UsedSpaceGB";E={[Math]::Round(($_.UsedSpaceGB),0)}} | measure-object -Property UsedSpaceGB -sum).sum
$leftAfterVMs = ([Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB) - $VMsSize)

if ($leftAfterVMs -lt 100){
	write-host "`n${leftAfterVMs}GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
	write-host " of free space will be left on $datastoreFound after migrating: " -nonewline -foreground "Red" -backgroundcolor "Black"
	write-host $ivms -nonewline -foreground "Yellow" -backgroundcolor "Black"
	write-host "`n`nSkipping "  -nonewline -foreground "Red" -backgroundcolor "Black"
	write-host $ivms -nonewline -foreground "Yellow" -backgroundcolor "Black"
	write-host " migration!"  -foreground "Red" -backgroundcolor "Black"
	$freeSpace = [Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB)
	$subject = "User: '$env:UserName' tried migrating | No free space on $datastoreFound (${freeSpace}G) for VM: $ivms (${VMsSize}G)"
	SendMail $subject haviv@omc.co.il $body
	$ivms = $ivms | ? {$_ -notLike $ivms}
	$ivms
	break
}else{
	do {
		if ($answer -eq "Y" -or $leftAfterVMs -gt 400){break}
#	if ($leftAfterVMs -lt 400){
		write-host "`n${leftAfterVMs}GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
		write-host " of free space will be left on $datastoreFound after migrating." -nonewline -foreground "Red" -backgroundcolor "Black"		
		write-host "`nAre you sure you want to continue migrating: " -nonewline 
		write-host ($ivms -Join '; ') -foreground "Yellow" -backgroundcolor "Black"
		do {$answer = read-host "[Y/N]"			 
			if ($answer -eq "N"){
				Foreach ($ivm in $ivms){
					if ($answer -eq "Y"){break}
					Write-Host "`nSkip migrating " -nonewline -foreground "Green" -backgroundcolor "Black"
					write-host $ivm -nonewline -foreground "Yellow" -backgroundcolor "Black"
					write-host " (" -nonewline -foreground "Green" -backgroundcolor "Black"
					write-host "$([Math]::Round($ivm.UsedSpaceGB,0))GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
					write-host ")?" -foreground "Green" -backgroundcolor "Black"				
					do {$answerIVM = read-host "[Y/N]"
						if ($answerIVM -eq "N"){continue}
						if ($answerIVM -eq "Y"){
							Write-Host "`nSkipping " -nonewline -foreground "Green" -backgroundcolor "Black"
							write-host $ivm -nonewline -foreground "Yellow" -backgroundcolor "Black"
							write-host "..." -foreground "Green" -backgroundcolor "Black"
							$ivms = $ivms | ? {$_ -notLike $ivm}
							if ($ivms){
								write-host "`nVMs left to migrate: " -foreground "Magenta" -backgroundcolor "Black" -nonewline 
								write-host ($ivms -Join '; ') -foreground "Yellow" -backgroundcolor "Black"
							}else{
								write-host "`nNo VMs left to migrate. Exiting..." -foreground "Red" -backgroundcolor "Black" 
							}
							$VMsSize = ($ivms | Select @{N="UsedSpaceGB";E={[Math]::Round(($_.UsedSpaceGB),0)}} | measure-object -Property UsedSpaceGB -sum).sum
							$leftAfterVMs = ([Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB) - $VMsSize)
							if ($leftAfterVMs -gt 400){
								$answer = "Y"
								if ($ivms){
									write-host "${leftAfterVMs}GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
									write-host " of free space will be left on $datastoreFound after migrating." -foreground "Magenta" -backgroundcolor "Black"	
								}else{
									write-host "`nNo VMs left to migrate. Exiting..." -foreground "Red" -backgroundcolor "Black" 
								}
								break
							}
						}
					} until ($answerIVM -eq "Y" -or $answerIVM -eq "N")
				}
			}else{
				#write-host "Prepering sending mail to Administrator..."
				$freeSpace = [Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB)				
				$subject = "User: '$env:UserName' started migrating | Less than 400G will be left on $datastoreFound (${freeSpace}G) for VM(s): $($ivms -Join '; ') - (Total VMs Size: ${VMsSize}G)"				
				SendMail $subject haviv@omc.co.il $body				
			}
		} until ($answer -eq "Y" -or $answer -eq "N")
	} until ($leftAfterVMs -lt 400 -and $answer -eq "Y")
}

$nameonvc = $vmhost.Name
$Queue = New-Object System.Collections.Queue

foreach ($vmname in $ivms){
	if ($copyVLan){$copyVLan = $null;$copyVLanMark = 1}
	$VMSize = ($vmname | Select @{N="UsedSpaceGB";E={[Math]::Round(($_.UsedSpaceGB),0)}} | measure-object -Property UsedSpaceGB -sum).sum
	$leftAfterVM = ([Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB) - $VMsize)
	if ($leftAfterVM -lt 100){
		write-host "`n${leftAfterVM}GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
		write-host " of free space will be left on $datastoreFound after migrating: " -nonewline -foreground "Red" -backgroundcolor "Black"
		write-host $vmname -nonewline -foreground "Yellow" -backgroundcolor "Black"
		write-host "`n`nSkipping "  -nonewline -foreground "Red" -backgroundcolor "Black"
		write-host $vmname -nonewline -foreground "Yellow" -backgroundcolor "Black"
		write-host " migration!"  -foreground "Red" -backgroundcolor "Black"
		$freeSpace = [Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB)
		$subject = "User: '$env:UserName' tried migrating | No free space on $datastoreFound (${freeSpace}G) for VM: $vmname (${VMsize}G)"
		SendMail $subject haviv@omc.co.il $body
		$ivms = $ivms | ? {$_ -notLike $vmname}
		$ivms
		continue
	}else{
		if ($leftAfterVM -lt 400){
			write-host "`n${leftAfterVM}GB" -nonewline -foreground "Yellow" -backgroundcolor "Black"
			write-host " of free space will be left on $datastoreFound after migrating: " -nonewline -foreground "Magenta" -backgroundcolor "Black"
			write-host $vmname -foreground "Yellow" -backgroundcolor "Black"
			write-host "Are you sure you want to continue migrating " -nonewline 
			write-host $vmname -foreground "Yellow" -backgroundcolor "Black"
			do {$answer = read-host "[Y/N]"			 
				if($answer -ne "y"){
					Write-Host "`nSkipping " -nonewline -foreground "Green" -backgroundcolor "Black"
					write-host $vmname -nonewline -foreground "Yellow" -backgroundcolor "Black"
					write-host " migration!" -foreground "Green" -backgroundcolor "Black"
					$freeSpace = [Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB)
					$subject = "User: '$env:UserName' tried migrating | No free space on $datastoreFound (${freeSpace}G) for VM: $vmname (${VMsize}G)"
					SendMail $subject haviv@omc.co.il $body
					$ivms = $ivms | ? {$_ -notLike $vmname}
					$ivms
					continue
				}
			} until ($answer -eq "Y" -or $answer -eq "N")
		}
		Write-Host "`nVM " -foreground "green" -nonewline
		Write-Host "'$vmname' " -foreground "yellow" -nonewline
		Write-Host "added to queue." -foreground "green" -nonewline
		$vlan = Get-VirtualPortGroup -VM $vmname	
		foreach ($vlanX in $vlan){
			$foundMatch = ""
			$vlanall = Get-VirtualPortGroup -VMHost $vmhost
			foreach ($vlanallX in $vlanall) {
				if ($vlanallX -cLike $vlanX){
					$foundMatch = 1
					break
				}
			}	
			if (!$foundMatch){
				Write-Host " Copying " -foreground "magenta" -nonewline
				Write-Host "$vmname" -foreground "yellow" -nonewline
				Write-Host "'s vLAN " -foreground "magenta" -nonewline
				Write-Host "'$vlanX' " -foreground "yellow" -nonewline
				Write-Host "to new host "  -foreground "magenta" -nonewline
				Write-Host "$nameonvc" -foreground "yellow" -nonewline
				Write-Host "..." -foreground "magenta" -nonewline
				###[string]$vLanNew  = $vmname.VMHost | Get-VirtualPortGroup -Name $vlanX.Name
				###$VLanFull = $vmname.VMHost | Get-VirtualPortGroup -Name $vlanX.Name
				$Policy = $vlanX.ExtensionData.Spec
				$ErrorActionPreference = 'SilentlyContinue'
				if (!$copyVLan){
					$vmSwitch = $vlanX.VirtualSwitchName #($vmname | Get-VirtualSwitch).name
					$vswitch = Get-VirtualSwitch -VMHost $vmhost.Name | ? {$_.name -Like $vmSwitch}
					$netSys = Get-View $vmhost.ExtensionData.ConfigManager.NetworkSystem
				}
				$NewPortGroup = New-VirtualPortGroup -VirtualSwitch $vswitch -Name ($vlanX.Name) -vlanid $vlanX.Vlanid
				if (!$copyVLan){$netSys.UpdatePortGroup($NewPortGroup.Name,$Policy)}
				$copyVLan = 1
			}
		}
	}
}
	
$ErrorActionPreference = 'continue'
if ($copyVLan -or $copyVLanMark){
	$CountVPG = 0
	Write-Host "`n`nRefreshing host network system because new vLAN(s) added..." -foreground "magenta" -backgroundcolor "Black"
	do {
		(Get-View $vmhost.ExtensionData.ConfigManager.NetworkSystem).RefreshNetworkSystem()
		#$NewPortGroup.Name
		$CountVPG++
		sleep 1
	} until ((Get-VirtualPortGroup -VMHost $vmhost | ? {$_.Name -Like $NewPortGroup.Name}) -or $CountVPG -gt 5)
	if ($CountVPG -ge 5){
		Write-Host "`nUnable to add vLAN(s) to:" -foreground "Yellow" -backgroundcolor "Red" -nonewline
		write-host " $vmhost" -foreground 4"Yellow" -backgroundcolor "Black"	
		write-host "Check VMHost Tasks or vCenter failed 'Recent Tasks' for errors." -foreground "Red" -backgroundcolor "Yellow"
		write-host "Exiting!" -foreground "Red" -backgroundcolor "Black"
		break
	}
	$copyVLan = $null
	$copyVLanMark = $null
}

if ($ivms){			
	$CDConnected = Get-CDDrive $ivms | where { ($_.ConnectionState.Connected -eq "true") }
	if ($CDConnected){write-host "`nFound CD connected. Disconecting...";foreach ($VMcdConnected in $CDConnected.parent){$VMcdConnected | Set-CDDriveAndAnswer}}
		Write-Host "`n`nStarting migration. Please wait..."
		$body = $ivms | Select-Object Name,@{N="UsedSpaceGB";E={[Math]::Round(($_.UsedSpaceGB),0)}},NumCpu | Out-String
		$freeSpace = [Math]::Round(($vmhostDatastores | ? {$_.Name -Match $datastoreFound}).FreeSpaceGB)
		if ($answerMinCPUSubject -eq 1){
			$subject = "WARNING - HIGH RISK MIGRATION | User: '$env:UserName' is migrating to: $nameonvc in DC: $vmsDC"
		}else{
			$subject = "User: '$env:UserName' is migrating to $nameonvc in $vmsDC"
		}
		$From = "CloudWM Alerts <alert_clubvps@omc.co.il>"
		$to = "haviv@omc.co.il"
		$cc = "yohay@omc.co.il"			
		SendMail $subject $to $body $cc
		Get-VM -Location $vmDataCenter -Name $ivms | Move-VM -Destination $nameonvc -Datastore $datastoreFound -DiskStorageFormat Thin
	}
}


function Merge-CSVFiles
		{            
[cmdletbinding()]            
param(            
    [string[]]$CSVFiles,            
    [string]$OutputFile = "c:\script\temp\merged.csv"            
)            
$Output = @();            
foreach($CSV in $CSVFiles) {            
    if(Test-Path $CSV) {            
                    
        #$FileName = [System.IO.Path]::GetFileName($CSV)            
        $temp = Import-CSV -Path $CSV 
#| select *, @{Expression={$FileName};Label="FileName"}            
        $Output += $temp            
            
    } else {            
        Write-Warning "$CSV : No such file found"            
    }            
            
}            
$Output | Export-Csv -Path $OutputFile -NoTypeInformation            
Write-Output "$OutputFile successfully created"            
            
}                   
function Install-Nagios-OnLinux
		{

copy C:\script\other\InstallNagiosOnLinux.txt.bak C:\script\other\InstallNagiosOnLinux.txt
copy C:\script\other\InstallNagios-MonitorcPanel.txt.bak C:\script\other\InstallNagios-MonitorcPanel.txt
copy C:\script\other\InstallNagios-Monitor.txt.bak C:\script\other\InstallNagios-Monitor.txt

cd "C:\Program Files (x86)\PuTTY"
do {
	$connStatus = ""
	$pwMon = ""
	while (!$pwMon) {write-host "Please enter ROOT password for " -foreground "green" -nonewline
		write-host "monitor.omc.co.il - 77.247.180.45/185.167.99.99" -foreground "Yellow" -backgroundcolor "Black" -nonewline
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
		}else{
			$vm = $vmorg
		}
		$vmPhone = read-host "`nEnter Phone number for Alert Contact"
#		$vmPhones = $vmPhones + $vmPhone
#			while ($vmPhone -ne "")
#				{
#				$vmPhone = read-Host "`nEnter another Phone number for Alert Contact or leave empty to continue"
#				$vmPhones = $vmPhones + $vmPhone
#				}
		$vmEmail = read-host "Enter EMail for Alert Contact"
#		$vmEmails = $vmEmails + $Email
#			while ($vmEmail -ne "")
#				{
#				$vmEmail = read-Host "`nEnter another Phone number for Alert Contact or leave empty to continue"
#				$vmEmails = $vmEmails + $vmEmail
#				}
	write-host "`nVM: " -foreground "yellow" -nonewline
	write-host "$VM" -foreground "Yellow" -backgroundcolor "Black" 
	write-host "`nIf installing on cPanel Server please enter " -foreground "green" -nonewline
	write-host "[1]" -foreground "red" -backgroundcolor "Black"
	write-host "Otherwise, leave empty for regular installation" -foreground "green"  -nonewline
	$cPanel = read-host " "

	if ($cPanel -eq "1") 
		{
		$fileNameMon = "c:\script\other\InstallNagios-MonitorcPanel.txt"
		copy $fileNameMon $fileNameMon".bak"
		$fileNameMonBak = "c:\script\other\InstallNagios-MonitorcPanel.txt.bak"
		do {
			write-host "`nIf you need, enter another custom Nagios Service, one at a time, otherwise, leave empty."
			write-host "To add service enter: check_zyx or nsca_check_xyz (e.g. check_ftp)."
			write-host "To remove service enter prefix '-!' (e.g. -!check_https)." 
			write-host "Services already included: " -foreground "magenta"
			write-host $arrayCustomServicescPanelPres"," $customServices -foreground "yellow"
			$customService = read-host " "
			if ($customService -eq "") {break}
			if ($customService -like '*-!*') 
				{
				$customService = $customService -replace '[-!]',''
				if (!$customServicesRemove) 
					{
					$customServicesRemove = $customService
					if ($customService -eq "nsca_check_mem")
						{
						$arrayCustomServicescPanelPres = "$arrayCustomServicescPanelPres" -replace ", $customService", ""
						}else{
						$arrayCustomServicescPanelPres = "$arrayCustomServicescPanelPres" -replace "$customService, ", ""
						}
					$arrayCustomServicescPanelPres = $arrayCustomServicescPanelPres | ? {$_}
					}else{					
					$customServicesRemove = $customServicesRemove + "," + $customService
					if ($customService -eq "nsca_check_mem")
						{
						$arrayCustomServicescPanelPres = "$arrayCustomServicescPanelPres" -replace ", $customService", ""
						}else{
						$arrayCustomServicescPanelPres = "$arrayCustomServicescPanelPres" -replace "$customService, ", ""
						}
					$arrayCustomServicescPanelPres = $arrayCustomServicescPanelPres | ? {$_}
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

	}else{
		$fileNameMon = "c:\script\other\InstallNagios-Monitor.txt"
		copy $fileNameMon $fileNameMon".bak"
		$fileNameMonBak = "c:\script\other\InstallNagios-Monitor.txt.bak"
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
	
	$fileName = "c:\script\other\InstallNagiosOnLinux.txt"
	copy $fileName $fileName".bak"
	$fileNameBak = "c:\script\other\InstallNagiosOnLinux.txt.bak"
	
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
		
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $pw $ip -m c:\script\other\ssh_exit.txt | select -Last 1
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
			}else{
			(gc $fileNameMon) -replace '`grep -iw "contact_name.*VMEMAIL"', '! `grep -iw "contact_name.*VMEMAIL"' | sc $fileNameMon
			(gc $fileNameMon) -replace ',VMEMAIL', '' | sc $fileNameMon
		}
	}
	echo y |.\plink.exe -ssh -l root -pw $pwMon monitor.omc.co.il -m $fileNameMon
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
}
function GetSnapshot
		{
			$vmhost = read-host "Please choose ESXI (e.g vm017)"
			$vm = read-host "Please choose a virtual machine (full name or partial)"
			write-host ""
		    	#$vmhostname = Get-VMHost | sls "$vmhost"
				#$vmnames = Get-VM | sls "$vm" | Where  {$_ -notlike '*_replica*' }
				foreach ($vmname in $vm)
				{
				#$vmnamefull = Get-VMHost $vmhost* | Get-VM  $vm* | select -expand Name
				#echo "Snapshot(s) for vm: $vmnamefull"
				$snapshot = Get-VMHost $vmhost* | Get-VM  $vmname* | Where  {$_ -notlike '*_replica*' } | Get-Snapshot | Select-Object VM,Name,Created | Format-Table -AutoSize
				write-host VMHost: $vmhost 
				echo $snapshot
				}
}
Function UpdateEsxiInMaintenance
        {
 [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true,HelpMessage="Computer name or Ip address INOBJect")]$vmhost,
    [Parameter(Mandatory=$true,HelpMessage="esxi patch name in/vmfs/volumes/zone-cdimage/system/vmware/")]$latestPatchFolder,
    [Parameter(Mandatory=$true,HelpMessage="Link to download OM")]$OMversionDownload,
    [Parameter(Mandatory=$true,HelpMessage="Result of Get-Vmhost")]$VMName,
    [Parameter(Mandatory=$false,HelpMessage="Esxi Password")]$esxipasswd,
    [Parameter(Mandatory=$false,HelpMessage="Run update? leave blank if not")]$StandAlone
    )
    $hostnameText=$vmhost.NAmeOnVC
    #$hostnameText=$hostnameText.trim()
    $zone = $vmhost.DataCenter
    $ip = $vmhost.HostIp
    $zone = $zone.tolower()
    $OMversion = ($OMversionDownload -split '/')[-1]
    Write-Host "hostnameText $hostnameText"
    Write-Host "esxipatch /vmfs/volumes/$zone-cdimage/system/vmware/esxi55-latest.zip"
    Write-Host "zone $zone"
$procced = 0
 Write-warning "Host Status NOT in Maintenance Mode."

"esxcli software vib install -d /vmfs/volumes/$zone-cdimage/system/vmware/esxi55-latest.zip
cd /tmp/
wget $OMversionDownload
esxcli software vib install -d /tmp/$OMversion
esxcli software vib install -d /vmfs/volumes/$zone-cdimage/system/vmware/ixgbe.zip
esxcli software vib install -d /vmfs/volumes/$zone-cdimage/system/vmware/tg3driver.zip" | Out-File -FilePath C:\script\newesxi\UpdateOMdell.txt -encoding "Default"
if($StandAlone){&"C:\Program Files (x86)\PuTTY\plink.exe" -ssh -l root -pw $esxipasswd $ip -m C:\script\newesxi\UpdateOMdell.txt}


}
function Get-VMByMAC
		{
    <#  .Description
        Find all VMs w/ a NIC w/ the given MAC address or IP address (by IP address relies on info returned from VMware Tools in the guest, so those must be installed).  Includes FindByIPWildcard, so that one can find VMs that approximate IP, like "10.0.0.*"
        .Example
        Get-VMByAddress -MAC 00:50:56:00:00:02
        VMName        MacAddress
        ------        ----------
        dev0-server   00:50:56:00:00:02,00:50:56:00:00:04
 
        Get VMs with given MAC address, return VM name and its MAC addresses
        .Example
        Get-VMByAddress -IP 10.37.31.120
        VMName         IPAddr
        ------         ------
        dev0-server2   192.168.133.1,192.168.253.1,10.37.31.120,fe80::...
 
        Get VMs with given IP as reported by Tools, return VM name and its IP addresses
        .Example
        Get-VMByAddress -AddressWildcard 10.0.0.*
        VMName   IPAddr
        ------   ------
        someVM0  10.0.0.119,fe80::...
        someVM2  10.0.0.138,fe80::...
        ...
 
        Get VMs matching the given wildcarded IP address
    #>
 
    [CmdletBinding(DefaultParametersetName="FindByMac")]
    param (
        ## MAC address in question, if finding VM by MAC; expects address in format "00:50:56:83:00:69"
        [parameter(Mandatory=$true,ParameterSetName="FindByMac")][string]$MacToFind_str,
        ## IP address in question, if finding VM by IP
        [parameter(Mandatory=$true,ParameterSetName="FindByIP")][ValidateScript({[bool][System.Net.IPAddress]::Parse($_)})][string]$IpToFind_str,
        ## wildcard string IP address (standard wildcard like "10.0.0.*"), if finding VM by approximate IP
        [parameter(Mandatory=$true,ParameterSetName="FindByIPWildcard")][string]$AddressWildcard_str
    ) ## end param
 
 
    Process {
        Switch ($PsCmdlet.ParameterSetName) {
            "FindByMac" {
                ## return the some info for the VM(s) with the NIC w/ the given MAC
                Get-View -Viewtype VirtualMachine -Property Name, Config.Hardware.Device | Where-Object {$_.Config.Hardware.Device | Where-Object {($_ -is [VMware.Vim.VirtualEthernetCard]) -and ($_.MacAddress -eq $MacToFind_str)}} | select @{n="VMName"; e={$_.Name}},@{n="MacAddress"; e={($_.Config.Hardware.Device | Where-Object {$_ -is [VMware.Vim.VirtualEthernetCard]} | %{$_.MacAddress} | sort) -join ","}}
                break;
                } ## end case
            {"FindByIp","FindByIPWildcard" -contains $_} {
                ## scriptblock to use for the Where clause in finding VMs
                $sblkFindByIP_WhereStatement = if ($PsCmdlet.ParameterSetName -eq "FindByIPWildcard") {{$_.IpAddress | Where-Object {$_ -like $AddressWildcard_str}}} else {{$_.IpAddress -contains $IpToFind_str}}
                ## return the .Net View object(s) for the VM(s) with the NIC(s) w/ the given IP
                Get-View -Viewtype VirtualMachine -Property Name, Guest.Net | Where-Object {$_.Guest.Net | Where-Object $sblkFindByIP_WhereStatement} | Select @{n="VMName"; e={$_.Name}}, @{n="IPAddr"; e={($_.Guest.Net | %{$_.IpAddress} | sort) -join ","}}
            } ## end case
        } ## end switch
    } ## end process
} ## end function			
Function OpenNfsClient
        {
		
[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,HelpMessage="Computer name or Ip address INOBJect")]$vmhost,
        [Parameter(Mandatory=$true,HelpMessage="Password For Esxi")]$passwd
         )
    $zone = $vmhost.DataCenter
    $zone = $zone.tolower()
    $vmSimple = $vmhost.vmSimple
    $HostName = $vmhost.HostName
    $ip = $vmhost.HostIp
    $fwzoneNfs = "Nfs-fw$zone.txt"

cd "C:\Program Files (x86)\PuTTY"
echo 'y'| .\plink.exe -ssh -l root -pw $passwd $ip -m C:\script\temp\agree.txt
.\plink.exe -ssh -l root -pw $passwd $ip -m C:\script\newesxi\firewall\$fwzoneNfs
}
Function ChangeVLanId
        {
    [CmdletBinding()]
   param
    (
    [Parameter(Mandatory=$true,HelpMessage="Vlan Name For Change")]$VlanName,
    [Parameter(Mandatory=$true,HelpMessage="New Id For Vlan")]$VLanID
    )   
	Get-VirtualPortGroup -Name $VlanName | Set-VirtualPortGroup -VLanId $VlanID
	}
function CheckIfVlanExistonFW
        {
            [CmdletBinding()]
   param
    (
    [Parameter(Mandatory=$false,HelpMessage="Firewall ip")]$fw,
    [Parameter(Mandatory=$false,HelpMessage="DataCenter")]$farm
    )   

    function Run-CheckIfVlanExistonFW 
        {
                    [CmdletBinding()]
   param
    (
    [Parameter(Mandatory=$true,HelpMessage="Firewall ip")]$fw,
    [Parameter(Mandatory=$true,HelpMessage="DataCenter")]$farm,
	[Parameter(Mandatory=$true,HelpMessage="Password for SSHkey")]$passwd,
    [Parameter(Mandatory=$false,HelpMessage="Write-outpot")]$return
    )   
    if(Test-Path C:\script\temp\$farm-VlanOnFirewall.txt){rm C:\script\temp\$farm-VlanOnFirewall.txt}
	 &"C:\Program Files (x86)\PuTTY\plink.exe" -l root -i C:\script\sshkey\mgmt.ppk -ssh $fw -pw $passwd >>C:\script\temp\$farm-VlanOnFirewall.txt "ip a | grep UP | cut -d@ -f 1 | cut -d. -f 2 | grep -v :"
	 if($farm -eq "eu")
	 {
		 Get-Content C:\script\temp\EU-VlanOnFirewall.txt | Where-Object {$_ -notmatch '166'} | Set-Content C:\script\temp\EU-VlanOnFirewall-temp.txt
		 rm C:\script\temp\EU-VlanOnFirewall.txt
		 Get-Content C:\script\temp\EU-VlanOnFirewall-temp.txt | Where-Object {$_ -notmatch '166'} | Set-Content C:\script\temp\EU-VlanOnFirewall.txt
	}
	$vlan = Get-Datacenter $farm | Get-VirtualPortGroup
		   $VlanNotUse = @()
		   $VlanId = $vlan.vlanid
	foreach($line in (Get-Content C:\script\temp\$farm-VlanOnFirewall.txt))
			{
			     if($VlanId -notcontains $line){if(!$return){Write-Host "Vlan  $line Does not Exist"};$VlanNotUse += $line }
            }
            if(!$return){Write-Host "Vlan from fw $fw that not used $VlanNotUse"}
           if($return -eq "Yes"){ Write-Output $VlanNotUse}
         } 
$passwd = read-host "Enter-password for sshKey:"
    if($fw -and $farm){Run-CheckIfVlanExistonFW $fw $farm $passwd Yes}
    else
            {
             do
               {
                        if($fw -notlike "ALL"){cls
                        $choice =read-host "Choose firewall:`n  1. fw1-il.clubvps.com (195.28.181.254)`n  2. fw2-il.clubvps.com (195.28.180.254)`n  3. fw3-il.clubvps.com (91.228.127.254)`n  4. fw-hosted.co.il (62.90.188.254)`n  5. fw-eu.clubvps.com (109.201.141.4)`n  6. fw-us.clubvps.com (74.217.224.175)`n  7. fw-as.clubvps.com (202.56.13.100)`n  8. All`n  0. Quit`n Enter Your choice: "
                        }
                         else
                        {$choice = "8"}
	                            switch ($choice)
	                            {
	                            1 {$fw='195.28.181.254'; $farm='IL';write-host "----------- $fw $farm ----------" ; Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            2 {$fw='195.28.180.254'; $farm='IL';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            3 {$fw='91.228.127.254'; $farm='IL';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            4 {$fw='62.90.188.254'; $farm='IL-RH';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            5 {$fw='109.201.141.4'; $farm='EU';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            6 {$fw='74.217.224.175'; $farm='US-TX';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
	                            7 {$fw='202.56.13.100'; $farm='AS';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd;$choice = 0}
            	                8 {
                                    $fw='195.28.181.254'; $farm='IL';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='195.28.180.254'; $farm='IL';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='91.228.127.254'; $farm='IL';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='62.90.188.254'; $farm='IL-RH';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='109.201.141.4'; $farm='EU';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='74.217.224.175'; $farm='US-TX';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
	                                $fw='202.56.13.100'; $farm='AS';write-host "----------- $fw $farm ----------"  ;Run-CheckIfVlanExistonFW $fw $farm $passwd
                                    $choice = 0
                                  }

	                            }
              }
while ($choice -ne "0")

            }
}
function UpdateEsxiHost
        {
            ######## Set Static Parmeters #######
            [string]$latestPatchFolder ="esxi55-latest"
            [string]$OMversionDownload = "http://downloads.dell.com/FOLDER03909554M/1/OM-SrvAdmin-Dell-Web-8.4.0-2193.VIB-ESX55i_A00.zip"
            ###### select vm and get VMHOST PARAM #############
            $vmhost = SelectHost
            if($vmhost -eq "HostNotExist")
                    {Write-host "Your host selection does not exist. Please choose a different host" 
                    $vmhost = SelectHost}
            write-host 'HOST NAME =' $vmhost.NAmeOnVC
            $hostnameText=$vmhost.NAmeOnVC
            $hostnameText=$hostnameText.trim()
            $VMName = Get-VMHost $hostnameText
            $passwd = GetSecurePassword $hostnameText
            UpdateEsxi $vmhost $latestPatchFolder $OMversionDownload $VMName $passwd 1
}
function ChangeVcIP
        {
                    [CmdletBinding()]
   param
    (
    [Parameter(Mandatory=$true,HelpMessage="Old IP of Vcenter")]$oldip,
    [Parameter(Mandatory=$true,HelpMessage="New IP of Vcenter")]$newip
    )   

"hostname
sed -i 's/$oldip/$newip/g' /etc/vmware/vpxa/vpxa.cfg
/etc/init.d/hostd restart
/etc/init.d/vpxa restart" | Out-File -FilePath C:\script\temp\changip.txt -encoding "Default"

 $passtemp = read-host "Please insert Xpassword"
 cls
 Write-Host "Changing ip from $oldip to $newip..."

foreach ($vmhost in Get-VMHost)
	{
	   $namevmhost=$vmhost.name
       $ip=$namevmhost.Split('-')[-1]
	   $lastip=$ip.Split('.')[-1]
	   $passnam=[int]$lastip * 2 + 2
	   $esxipasswd=$passtemp+$passnam
	   cd "C:\Program Files (x86)\PuTTY"
		echo y |.\plink.exe -ssh -l root -pw $esxipasswd $ip -m C:\script\temp\changip.txt
	}


        }
Function TestILConnection 
		{	
                while ($true) {
                                Write-host "------------------Check Connections in Vlan 1654-WAN yoel ---------------" -foregroundcolor Yellow
                                if (Test-Connection 80.179.140.132 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  80.179.140.128/26 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  80.179.140.128/26 DOWN" -foregroundcolor red}
                                if (Test-Connection 195.28.181.129 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  195.28.181.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  195.28.181.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 5.100.248.4 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  5.100.248.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  5.100.248.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 5.100.249.252 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  5.100.249.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  5.100.249.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 5.100.250.220 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  5.100.250.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  5.100.250.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 5.100.251.58 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  5.100.251.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  5.100.251.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 80.179.92.166 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  80.179.92.160/27 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  80.179.92.160/27 DOWN" -foregroundcolor red}
                                if (Test-Connection 80.179.141.22 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  80.179.141.0/26 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  80.179.141.0/26 DOWN" -foregroundcolor red}
                                if (Test-Connection 91.228.126.187 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  91.228.126.0/23 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  91.228.126.0/23 DOWN" -foregroundcolor red}
                                if (Test-Connection 212.199.114.85 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  212.199.114.0/25 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  212.199.114.0/25 DOWN" -foregroundcolor red}
                                if (Test-Connection 212.199.115.186 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  212.199.115.128/25 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  212.199.115.128/25 DOWN" -foregroundcolor red}
                                if (Test-Connection 212.199.177.135 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  212.199.177.128/25 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  212.199.177.128/25 DOWN" -foregroundcolor red}
                                if (Test-Connection 80.179.219.134 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan1654:  80.179.219.128/25 OK" -foregroundcolor Green}else{Write-Host "Vlan1654:  80.179.219.128/25   DOWN" -foregroundcolor red}
                                Write-host "------------------Check Connections in Vlan 156-WAN sivim ---------------" -foregroundcolor Yellow
                                if (Test-Connection 80.179.226.44 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan156:  80.179.226.0/26 OK" -foregroundcolor Green}else{Write-Host "Vlan156:  80.179.226.0/26 DOWN" -foregroundcolor red}
                                if (Test-Connection 195.28.180.254 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan156:  195.28.180.0/24 OK" -foregroundcolor Green}else{Write-Host "Vlan156:  195.28.180.0/24 DOWN" -foregroundcolor red}
                                if (Test-Connection 212.199.114.144 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan156:  212.199.114.128/25 OK" -foregroundcolor Green}else{Write-Host "Vlan156:  212.199.114.128/25 DOWN" -foregroundcolor red}
                                if (Test-Connection 212.199.221.181 -Count 2 -ErrorAction SilentlyContinue){Write-Host "Vlan156:  212.199.221.176/28 OK" -foregroundcolor Green}else{Write-Host "Vlan156:  212.199.221.176/28 DOWN" -foregroundcolor red}
                                Write-host "================== Check Connections DONE Checking again =========================" -foregroundcolor Cyan
                                Write-host "==================================================================================" -foregroundcolor Cyan
                                Write-host "==================================================================================" -foregroundcolor Cyan
                                Write-host "==================================================================================" -foregroundcolor Cyan
                                Write-host "==================================================================================" -foregroundcolor Cyan
                           if ($Host.UI.RawUI.KeyAvailable -and ("q" -eq $Host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho").Character)) {
                        Write-Host "Exiting now, don't try to stop me...." -Background DarkRed
                        break;
                    }
                }
        }		
function SSDVMCheck
        {
$vmhost = read-host "Please choose ESXI (e.g vm017)"
		  write-host ""
	  $vmhostname = Get-VMHost | sls "$vmhost"
	  
	  #write-host "$vmhostname"

	$ssdvm = Get-VMHost $vmhostname	| get-vm | Where-Object -FilterScript {$_.Notes -like "SSD.*"} | Format-Table -AutoSize -Property Name 
#	$ssdvmname = $ssdvm | Format-Table -Wrap -AutoSize -Property Name

	write-host "***********************"
	write-host "VM(s) belonging to SSD:"
	echo $ssdvm
	echo ""
	
	$nossdvm = Get-VMHost $vmhostname | get-vm |  Where-Object -FilterScript {$_.Notes -notlike "SSD"} | Format-Table -Wrap -AutoSize -Property Name
	write-host "***************************"
	write-host "VM(s) not belonging to SSD:"
	echo  $nossdvm
  	
	
	echo ""
	echo ""
			#UpdateEsxi $vmhost $latestPatchFolder $OMversionDownload $VMName $passwd 1
}
function Get-MOLDatabaseData 
		{
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName `
            System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName `
            System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName `
        System.Data.SqlClient.SqlDataAdapter $command
    } else {
        $adapter = New-Object -TypeName `
        System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset)
    $dataset.Tables[0]
    $connection.close()
}
function Invoke-MOLDatabaseQuery
		{
		
    [CmdletBinding(SupportsShouldProcess=$True,
                   ConfirmImpact='Low')]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName `
            System.Data.SqlClient.SqlConnection
    } else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName `
            System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery() | Out-Null
        $connection.close()
    }
}
		
Function Create-New-User
        {
 [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true,HelpMessage="Please insert username")]$user,
    [Parameter(Mandatory=$true,HelpMessage="Please insert new password")]$password
    )
        #$user = Read-Host -Prompt 'please insert a username'
        #$password = Read-Host -Prompt 'please insert a password'
        NET USER $user $password /add
        WMIC USERACCOUNT WHERE "Name = '$user'" SET PasswordExpires=FALSE
    }
Function Add-New-User-To-Group
        {
 [CmdletBinding()]
    param
    (
    [Parameter(Mandatory=$true,HelpMessage="Please insert username")]$user,
    [Parameter(Mandatory=$true,HelpMessage="Please select group")]$group
    )
    net localgroup $group /add $user
    }

Function Create-Vcenter-User
        {
 
        $user = Read-Host -Prompt 'please insert a username'
        $password = Read-Host -Prompt 'please insert a password'
        $company = Read-Host "please select user for OMC or GNS"


        connect-vc

        Import-Module C:\script\function\OMCFunctions.psm1

        Write-Host "Working on  $computer"

        Create-New-User $user $password
        Add-New-User-To-Group $user 'Remote Desktop Users'

        if ($company -like 'OMC'){ Add-New-User-To-Group $user 'VcenterManager'}
        if ($company -like 'GNS'){ Add-New-User-To-Group $user 'VcenterGNS'}
        
    }
        
        function connect-vc
 {
 $computer = "vc"
 Enter-PSSession $computer
 }

Function CountCPUs
	{
	Remove-Variable -Name vmhost -Scope Global -Force -ErrorAction SilentlyContinue
Remove-Variable -Name sum -Scope Global -Force -ErrorAction SilentlyContinue
$vmhost = SelectHostFast
foreach ($vm in ($vmhost | get-vm | get-view)){
	$sum += $vm.config.hardware.NumCPU 
} 
$sum
}

	function Join-Object
{
    <#
    .SYNOPSIS
        Join data from two sets of objects based on a common value

    .DESCRIPTION
        Join data from two sets of objects based on a common value

        For more details, see the accompanying blog post:
            http://ramblingcookiemonster.github.io/Join-Object/

        For even more details,  see the original code and discussions that this borrows from:
            Dave Wyatt's Join-Object - http://powershell.org/wp/forums/topic/merging-very-large-collections
            Lucio Silveira's Join-Object - http://blogs.msdn.com/b/powershell/archive/2012/07/13/join-object.aspx

    .PARAMETER Left
        'Left' collection of objects to join.  You can use the pipeline for Left.

        The objects in this collection should be consistent.
        We look at the properties on the first object for a baseline.
    
    .PARAMETER Right
        'Right' collection of objects to join.

        The objects in this collection should be consistent.
        We look at the properties on the first object for a baseline.

    .PARAMETER LeftJoinProperty
        Property on Left collection objects that we match up with RightJoinProperty on the Right collection

    .PARAMETER RightJoinProperty
        Property on Right collection objects that we match up with LeftJoinProperty on the Left collection

    .PARAMETER LeftProperties
        One or more properties to keep from Left.  Default is to keep all Left properties (*).

        Each property can:
            - Be a plain property name like "Name"
            - Contain wildcards like "*"
            - Be a hashtable like @{Name="Product Name";Expression={$_.Name}}.
                 Name is the output property name
                 Expression is the property value ($_ as the current object)
                
                 Alternatively, use the Suffix or Prefix parameter to avoid collisions
                 Each property using this hashtable syntax will be excluded from suffixes and prefixes

    .PARAMETER RightProperties
        One or more properties to keep from Right.  Default is to keep all Right properties (*).

        Each property can:
            - Be a plain property name like "Name"
            - Contain wildcards like "*"
            - Be a hashtable like @{Name="Product Name";Expression={$_.Name}}.
                 Name is the output property name
                 Expression is the property value ($_ as the current object)
                
                 Alternatively, use the Suffix or Prefix parameter to avoid collisions
                 Each property using this hashtable syntax will be excluded from suffixes and prefixes

    .PARAMETER Prefix
        If specified, prepend Right object property names with this prefix to avoid collisions

        Example:
            Property Name                   = 'Name'
            Suffix                          = 'j_'
            Resulting Joined Property Name  = 'j_Name'

    .PARAMETER Suffix
        If specified, append Right object property names with this suffix to avoid collisions

        Example:
            Property Name                   = 'Name'
            Suffix                          = '_j'
            Resulting Joined Property Name  = 'Name_j'

    .PARAMETER Type
        Type of join.  Default is AllInLeft.

        AllInLeft will have all elements from Left at least once in the output, and might appear more than once
          if the where clause is true for more than one element in right, Left elements with matches in Right are
          preceded by elements with no matches.
          SQL equivalent: outer left join (or simply left join)

        AllInRight is similar to AllInLeft.
        
        OnlyIfInBoth will cause all elements from Left to be placed in the output, only if there is at least one
          match in Right.
          SQL equivalent: inner join (or simply join)
         
        AllInBoth will have all entries in right and left in the output. Specifically, it will have all entries
          in right with at least one match in left, followed by all entries in Right with no matches in left, 
          followed by all entries in Left with no matches in Right.
          SQL equivalent: full join

    .EXAMPLE
        #
        #Define some input data.

        $l = 1..5 | Foreach-Object {
            [pscustomobject]@{
                Name = "jsmith$_"
                Birthday = (Get-Date).adddays(-1)
            }
        }

        $r = 4..7 | Foreach-Object{
            [pscustomobject]@{
                Department = "Department $_"
                Name = "Department $_"
                Manager = "jsmith$_"
            }
        }

        #We have a name and Birthday for each manager, how do we find their department, using an inner join?
        Join-Object -Left $l -Right $r -LeftJoinProperty Name -RightJoinProperty Manager -Type OnlyIfInBoth -RightProperties Department


            # Name    Birthday             Department  
            # ----    --------             ----------  
            # jsmith4 4/14/2015 3:27:22 PM Department 4
            # jsmith5 4/14/2015 3:27:22 PM Department 5

    .EXAMPLE  
        #
        #Define some input data.

        $l = 1..5 | Foreach-Object {
            [pscustomobject]@{
                Name = "jsmith$_"
                Birthday = (Get-Date).adddays(-1)
            }
        }

        $r = 4..7 | Foreach-Object{
            [pscustomobject]@{
                Department = "Department $_"
                Name = "Department $_"
                Manager = "jsmith$_"
            }
        }

        #We have a name and Birthday for each manager, how do we find all related department data, even if there are conflicting properties?
        $l | Join-Object -Right $r -LeftJoinProperty Name -RightJoinProperty Manager -Type AllInLeft -Prefix j_

            # Name    Birthday             j_Department j_Name       j_Manager
            # ----    --------             ------------ ------       ---------
            # jsmith1 4/14/2015 3:27:22 PM                                    
            # jsmith2 4/14/2015 3:27:22 PM                                    
            # jsmith3 4/14/2015 3:27:22 PM                                    
            # jsmith4 4/14/2015 3:27:22 PM Department 4 Department 4 jsmith4  
            # jsmith5 4/14/2015 3:27:22 PM Department 5 Department 5 jsmith5  

    .EXAMPLE
        #
        #Hey!  You know how to script right?  Can you merge these two CSVs, where Path1's IP is equal to Path2's IP_ADDRESS?
        
        #Get CSV data
        $s1 = Import-CSV $Path1
        $s2 = Import-CSV $Path2

        #Merge the data, using a full outer join to avoid omitting anything, and export it
        Join-Object -Left $s1 -Right $s2 -LeftJoinProperty IP_ADDRESS -RightJoinProperty IP -Prefix 'j_' -Type AllInBoth |
            Export-CSV $MergePath -NoTypeInformation

    .EXAMPLE
        #
        # "Hey Warren, we need to match up SSNs to Active Directory users, and check if they are enabled or not.
        #  I'll e-mail you an unencrypted CSV with all the SSNs from gmail, what could go wrong?"
        
        # Import some SSNs. 
        $SSNs = Import-CSV -Path D:\SSNs.csv

        #Get AD users, and match up by a common value, samaccountname in this case:
        Get-ADUser -Filter "samaccountname -like 'wframe*'" |
            Join-Object -LeftJoinProperty samaccountname -Right $SSNs `
                        -RightJoinProperty samaccountname -RightProperties ssn `
                        -LeftProperties samaccountname, enabled, objectclass

    .NOTES
        This borrows from:
            Dave Wyatt's Join-Object - http://powershell.org/wp/forums/topic/merging-very-large-collections/
            Lucio Silveira's Join-Object - http://blogs.msdn.com/b/powershell/archive/2012/07/13/join-object.aspx

        Changes:
            Always display full set of properties
            Display properties in order (left first, right second)
            If specified, add suffix or prefix to right object property names to avoid collisions
            Use a hashtable rather than ordereddictionary (avoid case sensitivity)

    .LINK
        http://ramblingcookiemonster.github.io/Join-Object/

    .FUNCTIONALITY
        PowerShell Language

    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine = $true)]
        [object[]] $Left,

        # List to join with $Left
        [Parameter(Mandatory=$true)]
        [object[]] $Right,

        [Parameter(Mandatory = $true)]
        [string] $LeftJoinProperty,

        [Parameter(Mandatory = $true)]
        [string] $RightJoinProperty,

        [object[]]$LeftProperties = '*',

        # Properties from $Right we want in the output.
        # Like LeftProperties, each can be a plain name, wildcard or hashtable. See the LeftProperties comments.
        [object[]]$RightProperties = '*',

        [validateset( 'AllInLeft', 'OnlyIfInBoth', 'AllInBoth', 'AllInRight')]
        [Parameter(Mandatory=$false)]
        [string]$Type = 'AllInLeft',

        [string]$Prefix,
        [string]$Suffix
    )
    Begin
    {
        function AddItemProperties($item, $properties, $hash)
        {
            if ($null -eq $item)
            {
                return
            }

            foreach($property in $properties)
            {
                $propertyHash = $property -as [hashtable]
                if($null -ne $propertyHash)
                {
                    $hashName = $propertyHash["name"] -as [string]         
                    $expression = $propertyHash["expression"] -as [scriptblock]

                    $expressionValue = $expression.Invoke($item)[0]
            
                    $hash[$hashName] = $expressionValue
                }
                else
                {
                    foreach($itemProperty in $item.psobject.Properties)
                    {
                        if ($itemProperty.Name -like $property)
                        {
                            $hash[$itemProperty.Name] = $itemProperty.Value
                        }
                    }
                }
            }
        }

        function TranslateProperties
        {
            [cmdletbinding()]
            param(
                [object[]]$Properties,
                [psobject]$RealObject,
                [string]$Side)

            foreach($Prop in $Properties)
            {
                $propertyHash = $Prop -as [hashtable]
                if($null -ne $propertyHash)
                {
                    $hashName = $propertyHash["name"] -as [string]         
                    $expression = $propertyHash["expression"] -as [scriptblock]

                    $ScriptString = $expression.tostring()
                    if($ScriptString -notmatch 'param\(')
                    {
                        Write-Verbose "Property '$HashName'`: Adding param(`$_) to scriptblock '$ScriptString'"
                        $Expression = [ScriptBlock]::Create("param(`$_)`n $ScriptString")
                    }
                
                    $Output = @{Name =$HashName; Expression = $Expression }
                    Write-Verbose "Found $Side property hash with name $($Output.Name), expression:`n$($Output.Expression | out-string)"
                    $Output
                }
                else
                {
                    foreach($ThisProp in $RealObject.psobject.Properties)
                    {
                        if ($ThisProp.Name -like $Prop)
                        {
                            Write-Verbose "Found $Side property '$($ThisProp.Name)'"
                            $ThisProp.Name
                        }
                    }
                }
            }
        }

        function WriteJoinObjectOutput($leftItem, $rightItem, $leftProperties, $rightProperties)
        {
            $properties = @{}

            AddItemProperties $leftItem $leftProperties $properties
            AddItemProperties $rightItem $rightProperties $properties

            New-Object psobject -Property $properties
        }

        #Translate variations on calculated properties.  Doing this once shouldn't affect perf too much.
        foreach($Prop in @($LeftProperties + $RightProperties))
        {
            if($Prop -as [hashtable])
            {
                foreach($variation in ('n','label','l'))
                {
                    if(-not $Prop.ContainsKey('Name') )
                    {
                        if($Prop.ContainsKey($variation) )
                        {
                            $Prop.Add('Name',$Prop[$Variation])
                        }
                    }
                }
                if(-not $Prop.ContainsKey('Name') -or $Prop['Name'] -like $null )
                {
                    Throw "Property is missing a name`n. This should be in calculated property format, with a Name and an Expression:`n@{Name='Something';Expression={`$_.Something}}`nAffected property:`n$($Prop | out-string)"
                }


                if(-not $Prop.ContainsKey('Expression') )
                {
                    if($Prop.ContainsKey('E') )
                    {
                        $Prop.Add('Expression',$Prop['E'])
                    }
                }
            
                if(-not $Prop.ContainsKey('Expression') -or $Prop['Expression'] -like $null )
                {
                    Throw "Property is missing an expression`n. This should be in calculated property format, with a Name and an Expression:`n@{Name='Something';Expression={`$_.Something}}`nAffected property:`n$($Prop | out-string)"
                }
            }        
        }

        $leftHash = @{}
        $rightHash = @{}

        # Hashtable keys can't be null; we'll use any old object reference as a placeholder if needed.
        $nullKey = New-Object psobject
        
        $bound = $PSBoundParameters.keys -contains "InputObject"
        if(-not $bound)
        {
            [System.Collections.ArrayList]$LeftData = @()
        }
    }
    Process
    {
        #We pull all the data for comparison later, no streaming
        if($bound)
        {
            $LeftData = $Left
        }
        Else
        {
            foreach($Object in $Left)
            {
                [void]$LeftData.add($Object)
            }
        }
    }
    End
    {
        foreach ($item in $Right)
        {
            $key = $item.$RightJoinProperty

            if ($null -eq $key)
            {
                $key = $nullKey
            }

            $bucket = $rightHash[$key]

            if ($null -eq $bucket)
            {
                $bucket = New-Object System.Collections.ArrayList
                $rightHash.Add($key, $bucket)
            }

            $null = $bucket.Add($item)
        }

        foreach ($item in $LeftData)
        {
            $key = $item.$LeftJoinProperty

            if ($null -eq $key)
            {
                $key = $nullKey
            }

            $bucket = $leftHash[$key]

            if ($null -eq $bucket)
            {
                $bucket = New-Object System.Collections.ArrayList
                $leftHash.Add($key, $bucket)
            }

            $null = $bucket.Add($item)
        }

        $LeftProperties = TranslateProperties -Properties $LeftProperties -Side 'Left' -RealObject $LeftData[0]
        $RightProperties = TranslateProperties -Properties $RightProperties -Side 'Right' -RealObject $Right[0]

        #I prefer ordered output. Left properties first.
        [string[]]$AllProps = $LeftProperties

        #Handle prefixes, suffixes, and building AllProps with Name only
        $RightProperties = foreach($RightProp in $RightProperties)
        {
            if(-not ($RightProp -as [Hashtable]))
            {
                Write-Verbose "Transforming property $RightProp to $Prefix$RightProp$Suffix"
                @{
                    Name="$Prefix$RightProp$Suffix"
                    Expression=[scriptblock]::create("param(`$_) `$_.'$RightProp'")
                }
                $AllProps += "$Prefix$RightProp$Suffix"
            }
            else
            {
                Write-Verbose "Skipping transformation of calculated property with name $($RightProp.Name), expression:`n$($RightProp.Expression | out-string)"
                $AllProps += [string]$RightProp["Name"]
                $RightProp
            }
        }

        $AllProps = $AllProps | Select -Unique

        Write-Verbose "Combined set of properties: $($AllProps -join ', ')"

        foreach ( $entry in $leftHash.GetEnumerator() )
        {
            $key = $entry.Key
            $leftBucket = $entry.Value

            $rightBucket = $rightHash[$key]

            if ($null -eq $rightBucket)
            {
                if ($Type -eq 'AllInLeft' -or $Type -eq 'AllInBoth')
                {
                    foreach ($leftItem in $leftBucket)
                    {
                        WriteJoinObjectOutput $leftItem $null $LeftProperties $RightProperties | Select $AllProps
                    }
                }
            }
            else
            {
                foreach ($leftItem in $leftBucket)
                {
                    foreach ($rightItem in $rightBucket)
                    {
                        WriteJoinObjectOutput $leftItem $rightItem $LeftProperties $RightProperties | Select $AllProps
                    }
                }
            }
        }

        if ($Type -eq 'AllInRight' -or $Type -eq 'AllInBoth')
        {
            foreach ($entry in $rightHash.GetEnumerator())
            {
                $key = $entry.Key
                $rightBucket = $entry.Value

                $leftBucket = $leftHash[$key]

                if ($null -eq $leftBucket)
                {
                    foreach ($rightItem in $rightBucket)
                    {
                        WriteJoinObjectOutput $null $rightItem $LeftProperties $RightProperties | Select $AllProps
                    }
                }
            }
        }
    }
}

Function Merge-Csv {
<#
.SYNOPSIS
Merges an arbitrary amount of CSV files based on an ID column or several combined ID columns.
Also works on custom PowerShell objects, with the InputObject parameter.

Joakim Svendsen (C) 2014-2017
All rights reserved.

MIT license.

.PARAMETER Id
Shared ID column(s)/header(s).
.PARAMETER Path
CSV files to process.
.PARAMETER InputObject
Custom PowerShell objects to process.
.PARAMETER Delimiter
Optional delimiter that's used if you pass file paths (default is a comma).
.PARAMETER Separator
Optional multi-ID column string separator (default "#Merge-Csv-Separator#").
.PARAMETER AllowDuplicates
Allow duplicate entries (IDs).

.EXAMPLE
ipcsv users.csv | ft -AutoSize

Username Department
-------- ----------
John     IT        
Jane     HR        

PS C:\> ipcsv user-mail.csv | ft -AutoSize

Username Email           
-------- -----           
John     john@example.com
Jane     jane@example.com

PS C:\> Merge-Csv -Path users.csv, user-mail.csv -Id Username | Export-Csv -enc UTF8 merged.csv

PS C:\> ipcsv .\merged.csv | ft -AutoSize

Username Department Email           
-------- ---------- -----           
John     IT         john@example.com
Jane     HR         jane@example.com

.EXAMPLE
Merge-Csv -In (ipcsv .\csv1.csv), (ipcsv csv2.csv), (ipcsv csv3.csv) -Id Username | sort-object username | ft -AutoSize

Merging three files.

WARNING: Duplicate identifying (shared column(s) ID) entry found in CSV data/file 0: user42
WARNING: Identifying column entry 'firstOnly' was not found in all CSV data objects/files. Found in object/file no.: 1
WARNING: Identifying column entry '2only' was not found in all CSV data objects/files. Found in object/file no.: 2
WARNING: Identifying column entry 'user2and3only' was not found in all CSV data objects/files. Found in object/file no.: 2, 3

Username      File1A      File1B      TestID File2A  File2B  TestX      File3  
--------      ------      ------      ------ ------  ------  -----      -----  
2only                                        a       b       c                 
firstOnly     firstOnlyA1 firstOnlyB1 foo                                      
user1         1A1         1B1         same   1A3     2A3     same       same   
user2         2A1         2B1         diff2  2A3     2B3     diff2_2    testC2 
user2and3only                                2and3A2 2and3B2 test2and3X testID 
user3         3A1         3B1         same   3A3     3B3     same       same   
user42        42A1        42B1        same42 testA42 testB42 testX42    testC42

.EXAMPLE
Merge-Csv -Path csvmerge1.csv, csvmerge2.csv, csvmerge3.csv -Id Username, TestID | Sort-Object username | ft -a

Two shared/ID column, three files.

WARNING: Duplicate identifying (shared column(s) ID) entry found in CSV data/file 1: user42, same42
WARNING: Identifying column entry 'user2, diff2' was not found in all CSV data objects/files. Found in object/file no.: 1
WARNING: Identifying column entry 'user2and3only, testID' was not found in all CSV data objects/files. Found in object/file no.: 3
WARNING: Identifying column entry 'user2, testC2' was not found in all CSV data objects/files. Found in object/file no.: 3
WARNING: Identifying column entry '2only, c' was not found in all CSV data objects/files. Found in object/file no.: 2
WARNING: Identifying column entry 'user2and3only, test2and3X' was not found in all CSV data objects/files. Found in object/file no.: 2
WARNING: Identifying column entry 'user2, diff2_2' was not found in all CSV data objects/files. Found in object/file no.: 2
WARNING: Identifying column entry 'firstOnly, foo' was not found in all CSV data objects/files. Found in object/file no.: 1

Username      TestID     File1A      File1B      File2A  File2B 
--------      ------     ------      ------      ------  ------ 
2only         c                                  a       b      
firstOnly     foo        firstOnlyA1 firstOnlyB1                
user1         same       1A1         1B1         1A3     2A3    
user2         diff2      2A1         2B1                        
user2         diff2_2                            2A3     2B3    
user2         testC2                                            
user2and3only testID                                            
user2and3only test2and3X                         2and3A2 2and3B2
user3         same       3A1         3B1         3A3     3B3    
user42        same42     42A1        42B1        testA42 testB42

#>
    [CmdletBinding(
        DefaultParameterSetName='Files'
    )]
    param(
        # Shared ID column(s)/header(s).
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string[]] $Id,
        # CSV files to process.
        [Parameter(ParameterSetName='Files',Mandatory=$true)][ValidateScript({Test-Path $_ -PathType Leaf})][string[]] $Path,
        # Custom PowerShell objects to process.
        [Parameter(ParameterSetName='Objects',Mandatory=$true)][psobject[]] $InputObject,
        # Optional delimiter that's used if you pass file paths (default is a comma).
        [Parameter(ParameterSetName='Files')][string] $Delimiter = ',',
        # Optional multi-ID column string separator (default "#Merge-Csv-Separator#").
        [string] $Separator = '#Merge-Csv-Separator#',
        # Allow duplicate entries (IDs).
        [switch] $AllowDuplicates
    )
    # v1.5 - Changed Sort to Sort-Object to support "Linux changes" in PSv6.
    # v1.4 - 2016-09-16 - Added support for handling duplicate IDs.
    [psobject[]] $CsvObjects = @()
    if ($PSCmdlet.ParameterSetName -eq 'Files') {
        $CsvObjects = foreach ($File in $Path) {
            ,@(Import-Csv -Delimiter $Delimiter -Path $File)
        }
    }
    else {
        $CsvObjects = $InputObject
    }
    $Headers = @()
    foreach ($Csv in $CsvObjects) {
        $Headers += , @($Csv | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name)
    }
    $Counter = 0
    foreach ($h in $Headers) {
        $Counter++
        foreach ($Column in $Id) {
            if ($h -notcontains $Column) {
                Write-Error "Headers in object/file $Counter don't include $Column. Exiting."
                return
            }
        }
    }
    $HeadersFlatNoShared = @($Headers | ForEach { $_ } | Where { $Id -notcontains $_ })
    if ($HeadersFlatNoShared.Count -ne @($HeadersFlatNoShared | Sort-Object -Unique).Count) {
        Write-Error "Some headers are shared. Are you just looking for '@(ipcsv csv1) + @(ipcsv csv2) | Export-Csv ...'?`nTo remove duplicate (between the files to merge) headers from a CSV file, Import-Csv it, pass it to Select-Object, and omit the duplicate header(s)/column(s).`nExiting."
        return
    }
    $SharedColumnHashes = @()
    $SharedColumnCount = $Id.Count
    $Counter = 0
    foreach ($Csv in $CsvObjects) {
        $SharedColumnHashes += @{}
        $Csv | ForEach {
            $CurrentID = $(for ($i = 0; $i -lt $SharedColumnCount; $i++) {
                $_ | Select -ExpandProperty $Id[$i] -EA SilentlyContinue
            }) -join $Separator
            if (-not $SharedColumnHashes[$Counter].ContainsKey($CurrentID)) {
                $SharedColumnHashes[$Counter].Add($CurrentID, @($_ | Select -Property $Headers[$Counter]))
            }
            else {
                if ($AllowDuplicates) {
                    $SharedColumnHashes[$Counter].$CurrentID += $_ | Select -Property $Headers[$Counter]
                }
                else {
                    Write-Warning ("Duplicate identifying (shared column(s) ID) entry found in CSV data/file $($Counter+1): " + ($CurrentID -replace [regex]::Escape($Separator), ', '))
                }
            }
        }
        $Counter++
    }
    $Result = @{}
    $NotFound = @{}
    foreach ($Counter in 0..($SharedColumnHashes.Count-1)) {
        foreach ($InnerCounter in (0..($SharedColumnHashes.Count-1) | Where-Object { $_ -ne $Counter })) {
            foreach ($Key in $SharedColumnHashes[$Counter].Keys) {
                Write-Verbose "Key: $Key, Counter: $Counter, InnerCounter: $InnerCounter"
                $Obj = New-Object -TypeName PSObject
                if ($SharedColumnHashes[$InnerCounter].ContainsKey($Key)) {
                    foreach ($Header in $Headers[$InnerCounter] | Where { $Id -notcontains $_ }) {
                        Add-Member -InputObject $Obj -MemberType NoteProperty -Name $Header -Value ($SharedColumnHashes[$InnerCounter].$Key | Select $Header)
                    }
                }
                else {
                    foreach ($Header in $Headers[$Counter]) {
                        if ($Id -notcontains $Header) {
                            Add-Member -InputObject $Obj -MemberType NoteProperty -Name $Header -Value ($SharedColumnHashes[$Counter].$Key | Select $Header)
                        }
                    }
                    if (-not $NotFound.ContainsKey($Key)) {
                        $NotFound.Add($Key, @($Counter))
                    }
                    else {
                        $NotFound[$Key] += $Counter
                    }
                }
                if (-not $Result.ContainsKey($Key)) {
                    $Result.$Key = $Obj
                }
                else {
                    foreach ($Property in @($Obj | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name)) {
                        if (-not ($Result.$Key | Get-Member -MemberType NoteProperty -Name $Property)) {
                            Add-Member -InputObject $Result.$Key -MemberType NoteProperty -Name $Property -Value $Obj.$Property #-EA SilentlyContinue
                        }
                    }
                }
                
            }
        }
    }
    if ($NotFound) {
        foreach ($Key in $NotFound.Keys) {
            Write-Warning "Identifying column entry '$($Key -replace [regex]::Escape($Separator), ', ')' was not found in all CSV data objects/files. Found in object/file no.: $(
                if ($NotFound.$Key) { ($NotFound.$Key | ForEach { ([int]$_)+1 } | Sort-Object -Unique) -join ', '}
                elseif ($CsvObjects.Count -eq 2) { '1' }
                else { 'none' }
                )"
        }
    }
    #$Global:Result = $Result
    $Counter = 0
    [hashtable[]] $SharedHeadersNoDuplicate = $Id | ForEach {
        @{n="$($Id[$Counter])";e=[scriptblock]::Create("(`$_.Name -split ([regex]::Escape('$Separator')))[$Counter]")}
        $Counter++
    }
    [hashtable[]] $HeaderPropertiesNoDuplicate = $HeadersFlatNoShared | ForEach {
        @{n=$_.ToString(); e=[scriptblock]::Create("`$_.Value.'$_' | Select -ExpandProperty '$_'")}
    }
    [hashtable[]] $SharedHeaders = @(foreach ($h in $Id) {
        @{n="$($Id[$Counter])";e=[scriptblock]::Create("`$Obj.Name.'$(($h -split [regex]::Escape($Separator))[$Counter])'")}
        $Counter++
    })
    [hashtable[]] $HeaderProperties = @(foreach ($h in $HeadersFlatNoShared) {
        @{n=$h.ToString(); e=[scriptblock]::Create("`$Obj.Value.'$h'")}
    })
    [int] $HeadersFlatNoSharedCount = $HeadersFlatNoShared.Count
    # Return results.
    if (-not $AllowDuplicates) {
        $Result.GetEnumerator() | Select -Property ($SharedHeadersNoDuplicate + $HeaderPropertiesNoDuplicate)
    }
    else {
        $Result.GetEnumerator() | foreach { #Select -Property ($SharedHeaders + $HeaderProperties) | foreach {
            # Latching on support for duplicate objects. Insanely inefficient.
            # Variable for the count of duplicates we find. Initialize to 1 for each array of PSobjects for each ID.
            $MaxDuplicateCount = 1
            foreach ($Title in $_.Value | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name) {
                $Count = @($_.Value.$Title).Count
                # find max count for this instance (if at all higher than 1)
                # duplicates are processed in the order they occur
                if ($MaxDuplicateCount -lt $Count) {
                    $MaxDuplicateCount = $Count
                }
            }
            Write-Verbose "Max duplicate count: $MaxDuplicateCount"
            foreach ($i in 0..($MaxDuplicateCount-1)) {
                # Add ID(s) once to each object.
                $Obj = $null
                $Obj = New-Object -TypeName PSObject
                foreach ($TempID in $Id) {
                    Add-Member -InputObject $Obj -MemberType NoteProperty -Name $TempID -Value $_.Name
                }
                foreach ($NumHeader in 0..($HeadersFlatNoSharedCount-1)) {
                    try {
                        $Value = ($_.Value.($HeadersFlatNoShared[$NumHeader]))[$i] | Select -ExpandProperty $HeadersFlatNoShared[$NumHeader]
                    }
                    catch {
                        Write-Verbose "Caught out of bounds in array."
                        $Value = '' | Select -Property $HeadersFlatNoShared[$NumHeader]
                    }
                    Add-Member -InputObject $Obj -MemberType NoteProperty -Name $HeadersFlatNoShared[$NumHeader] -Value $Value
                }
                $Obj | Select -Property ($Id + $HeadersFlatNoShared)
            }
        }
    }
}
Function Decrypt-SecureString {
param(
    [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
    [System.Security.SecureString]
    $sstr
)

$marshal = [System.Runtime.InteropServices.Marshal]
$ptr = $marshal::SecureStringToBSTR( $sstr )
$str = $marshal::PtrToStringBSTR( $ptr )
$marshal::ZeroFreeBSTR( $ptr )
$str
}

function Get-TaskPlus {
 
<#  
.SYNOPSIS  Returns vSphere Task information   
.DESCRIPTION The function will return vSphere task info. The
  available parameters allow server-side filtering of the
  results
.NOTES  Author:  Luc Dekens  
.PARAMETER Alarm
  When specified the function returns tasks triggered by
  specified alarm
.PARAMETER Entity
  When specified the function returns tasks for the
  specific vSphere entity
.PARAMETER Recurse
  Is used with the Entity. The function returns tasks
  for the Entity and all it's children
.PARAMETER State
  Specify the State of the tasks to be returned. Valid
  values are: error, queued, running and success
.PARAMETER Start
  The start date of the tasks to retrieve
.PARAMETER Finish
  The end date of the tasks to retrieve.
.PARAMETER UserName
  Only return tasks that were started by a specific user
.PARAMETER MaxSamples
  Specify the maximum number of tasks to return
.PARAMETER Reverse
  When true, the tasks are returned newest to oldest. The
  default is oldest to newest
.PARAMETER Server
  The vCenter instance(s) for which the tasks should
  be returned
.PARAMETER Realtime
  A switch, when true the most recent tasks are also returned.
.PARAMETER Details
  A switch, when true more task details are returned
.PARAMETER Keys
  A switch, when true all the keys are returned
.EXAMPLE
  PS> Get-TaskPlus -Start (Get-Date).AddDays(-1)
.EXAMPLE
  PS> Get-TaskPlus -Alarm $alarm -Details
#>
  
  param(
    [CmdletBinding()]
    [VMware.VimAutomation.ViCore.Impl.V1.Alarm.AlarmDefinitionImpl]$Alarm,
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl]$Entity,
    [switch]$Recurse = $false,
    [VMware.Vim.TaskInfoState[]]$State,
    [DateTime]$Start,
    [DateTime]$Finish,
    [string]$UserName,
    [int]$MaxSamples = 100,
    [switch]$Reverse = $true,
    [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl[]]$Server = $global:DefaultVIServer,
    [switch]$Realtime,
    [switch]$Details,
    [switch]$Keys,
    [int]$WindowSize = 100
  )
 
  begin {
    function Get-TaskDetails {
      param(
        [VMware.Vim.TaskInfo[]]$Tasks
      )
      begin{
        $psV3 = $PSversionTable.PSVersion.Major -ge 3
      }
 
      process{
        $tasks | %{
          if($psV3){
            $object = [ordered]@{}
          }
          else {
            $object = @{}
          }
          $object.Add("Name",$_.Name)
          $object.Add("Description",$_.Description.Message)
          if($Details){$object.Add("DescriptionId",$_.DescriptionId)}
          if($Details){$object.Add("Task Created",$_.QueueTime)}
          $object.Add("Task Started",$_.StartTime)
          if($Details){$object.Add("Task Ended",$_.CompleteTime)}
          $object.Add("State",$_.State)
          $object.Add("Result",$_.Result)
          $object.Add("Entity",$_.EntityName)
          $object.Add("VIServer",$VIObject.Name)
          $object.Add("Error",$_.Error.ocalizedMessage)
          if($Details){
            $object.Add("Cancelled",(&{if($_.Cancelled){"Y"}else{"N"}}))
            $object.Add("Reason",$_.Reason.GetType().Name.Replace("TaskReason",""))
            $object.Add("AlarmName",$_.Reason.AlarmName)
            $object.Add("AlarmEntity",$_.Reason.EntityName)
            $object.Add("ScheduleName",$_.Reason.Name)
            $object.Add("User",$_.Reason.UserName)
          }
          if($keys){
            $object.Add("Key",$_.Key)
            $object.Add("ParentKey",$_.ParentTaskKey)
            $object.Add("RootKey",$_.RootTaskKey)
          }
 
          New-Object PSObject -Property $object
        }
      }
    }
 
    $filter = New-Object VMware.Vim.TaskFilterSpec
    if($Alarm){
      $filter.Alarm = $Alarm.ExtensionData.MoRef
    }
    if($Entity){
      $filter.Entity = New-Object VMware.Vim.TaskFilterSpecByEntity
      $filter.Entity.entity = $Entity.ExtensionData.MoRef
      if($Recurse){
        $filter.Entity.Recursion = [VMware.Vim.TaskFilterSpecRecursionOption]::all
      }
      else{
        $filter.Entity.Recursion = [VMware.Vim.TaskFilterSpecRecursionOption]::self
      }
    }
    if($State){
      $filter.State = $State
    }
    if($Start -or $Finish){
      $filter.Time = New-Object VMware.Vim.TaskFilterSpecByTime
      $filter.Time.beginTime = $Start
      $filter.Time.endTime = $Finish
      $filter.Time.timeType = [vmware.vim.taskfilterspectimeoption]::startedTime
    }
    if($UserName){
      $userNameFilterSpec = New-Object VMware.Vim.TaskFilterSpecByUserName
      $userNameFilterSpec.UserList = $UserName
      $filter.UserName = $userNameFilterSpec
    }
    $nrTasks = 0
  }
 
  process {
    foreach($viObject in $Server){
      $si = Get-View ServiceInstance -Server $viObject
      $tskMgr = Get-View $si.Content.TaskManager -Server $viObject 
 
      if($Realtime -and $tskMgr.recentTask){
        $tasks = Get-View $tskMgr.recentTask
        $selectNr = [Math]::Min($tasks.Count,$MaxSamples-$nrTasks)
        Get-TaskDetails -Tasks[0..($selectNr-1)]
        $nrTasks += $selectNr
      }
 
      $tCollector = Get-View ($tskMgr.CreateCollectorForTasks($filter))
 
      if($Reverse){
        $tCollector.ResetCollector()
        $taskReadOp = $tCollector.ReadPreviousTasks
      }
      else{
        $taskReadOp = $tCollector.ReadNextTasks
      }
      do{
        $tasks = $taskReadOp.Invoke($WindowSize)
        if(!$tasks){return}
        $selectNr = [Math]::Min($tasks.Count,$MaxSamples-$nrTasks)
        Get-TaskDetails -Tasks $tasks[0..($selectNr-1)]
        $nrTasks += $selectNr
      }while($nrTasks -lt $MaxSamples)
    }
    $tCollector.DestroyCollector()
  }
}

Function PowerONVMsOnHost
		{
 $VMHostName = Read-Host "Which Host's VMs would you like to power on (e.g. vm004)? "
 $view = Get-View -ViewType 'virtualmachine' -Property Name

 $taskTracker = @()
 $VMs = @()
 Get-Content "\\192.168.0.100\c$\script\VMHosts\$VMHostName.txt" | %{
  $vmName = $_
  Write-Host "Powering on " -nonewline
  Write-Host "$vmName`t`t" -foreground "Yellow" -backgroundcolor "Black"  -nonewline  
  $taskTracker += ($view | ?{$_.name -eq "$vmName" }).PowerOnVM_Task($null)
  Start-Sleep -Milliseconds 500
  $Task = $taskTracker[-1]  
  $TaskState = (Get-Task -id "$Task").State
  if ($TaskState -Match "Error"){
	Write-Host $TaskState -foreground "Red" -backgroundcolor "Black"
  }else{
	if ($TaskState -Match "Success"){
		Write-Host $TaskState -foreground "Green" -backgroundcolor "Black"
	}else{
		Write-Host $TaskState " Unknown" -foreground "Yellow" -backgroundcolor "Black"
	}
  }
	
 }
 echo "================================================"
 "Submitted $($taskTracker.Count) power on requests"
}

Function Set-CDDriveAndAnswer{
<#
.SYNOPSIS  Unmounts a CD/DVD from a VM and answers an outstanding question
.DESCRIPTION The function will unmount a CD/DVD from a DVD.
   If the unmount causes a question, the function will answer the question.
.NOTES  Authors:  Luc Dekens, David A. Stewart
.PARAMETER VM
   The DisplayName of the VM
.PARAMETER Server
   The vSphere Server on which the VM is located.
   The default is $global:defaultviserver
.EXAMPLE
   PS> Set-CDDriveAndAnswer -VM MyVM -Server $global:DefaultVIServer
.EXAMPLE
   PS> Get-VM | Set-CDDriveAndAnswer
#>
   [CmdletBinding()]
   param(
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
  [string[]]$VM
   )

$objVM = Get-VM $VM
$vCenter = $objVM | %{$_.Uid.Substring($_.Uid.Indexof('@')+1).split(":")[0]}
IF($objVM | Get-CDDrive | ?{$_.IsoPath -AND ($_.ConnectionState.Connected -match "True")}){
  $VMView = $objVM | Get-View
  $driveName = "CD/DVD Drive 1"
  $dev = $VMView.Config.Hardware.Device | where {$_.DeviceInfo.Label -eq $driveName}
  If($dev){
   $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
   $spec.deviceChange = New-Object VMware.Vim.VirtualDeviceConfigSpec[] (1)
   $spec.deviceChange[0] = New-Object VMware.Vim.VirtualDeviceConfigSpec
   $spec.deviceChange[0].operation = "edit"
   $spec.deviceChange[0].device = $dev
   $spec.deviceChange[0].device.backing = New-Object VMware.Vim.VirtualCdromRemoteAtapiBackingInfo
   $spec.deviceChange[0].device.backing.DeviceName = ""
   $spec.deviceChange[0].device.backing.UseAutoDetect = "false"
   $spec.deviceChange[0].device.Connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
   $spec.deviceChange[0].device.Connectable.Connected = "false"
   $VMView.ReconfigVM_Task($spec)

   $maxPass = 30
   $pass = 0
   Write-Host -NoNewLine "$VM Pass..."
   while($pass -lt $maxPass){
    $question = ""
    $question = Get-VM $VM -server $vCenter | Get-VMQuestion -QuestionText "*locked the CD-ROM*"
    If($question){
     $Option = ($question.Options | ?{$_.Summary -match "Yes"} | Select -ExpandProperty Label)
     Set-VMQuestion -VMQuestion $question -Option "$Option" -Confirm:$False -ErrorAction SilentlyContinue | Out-Null
    }
    $pass++
    Write-Host -NoNewLine "$pass..."
    IF(!(Get-VM $VM -server $vCenter | Get-CDDrive | ?{$_.IsoPath -AND ($_.ConnectionState.Connected -match "True")})){$pass = $maxPass; Write-Host " CD/DVD cleared on $VM"}
   }
   IF(Get-VM $VM -server $vCenter | Get-CDDrive | ?{$_.IsoPath -AND ($_.ConnectionState.Connected -match "True")}){Write-Host "`n ERROR: CD/DVD still connected on $VM" -foreground "Red" -backgroundcolor "Black"}
  }
}Else{Write-Host "CD/DVD Not connected on $VM"}
}

Function SendMail{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,HelpMessage="Subject")]$subject,
        [Parameter(Mandatory=$true,HelpMessage="To")]$to,		
		[Parameter(Mandatory=$false,HelpMessage="Body")]$body,
		[Parameter(Mandatory=$false,HelpMessage="Cc")]$cc,
		[Parameter(Mandatory=$false,HelpMessage="BCc")]$bcc,
		[Parameter(Mandatory=$false,HelpMessage="Attachment")]$AttachmentFile
	)
	$From = "CloudWM Alerts <alert_clubvps@omc.co.il>"
	$SMTPServer = "ns6.clubweb.co.il"
	$SMTPPort = "25"
	$Username = "alert_clubvps@omc.co.il"
	$Password = "Al87h45g#"
		
	$message = New-Object System.Net.Mail.MailMessage
	$message.subject = $subject
	if ($body){$message.body = $body}
	$message.to.add($to)
	if ($cc){$message.cc.add($cc)}
	if ($bcc){$message.bcc.add($bcc)}
	$message.from = $From	
	if ($AttachmentFile){
		$Attachment = new-object Net.Mail.Attachment($AttachmentFile)
		$message.attachments.add($Attachment)
	}
	
	$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
	$smtp.EnableSSL = $true
	$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
	$smtp.send($message)
	write-host "Mail Sent |" $Subject
	if ($AttachmentFile){$Attachment.Dispose()}
}

function New-PEDRACSessionPort
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='low')]
    [OutputType([Microsoft.Management.Infrastructure.CimSession])]
    param (
        [Parameter (Mandatory)]
        [PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter (Mandatory,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    ValueFromRemainingArguments=$false)]
        [ValidateScript({[System.Net.IPAddress]::TryParse($_,[ref]$null)})]
        [string] $IPAddress,
		
		[Parameter (Mandatory,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true, 
                    ValueFromRemainingArguments=$false)]        
        [string] $Port,

        [Parameter()]
        [int] $MaxTimeout = 10
    )

	$cimOptions = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
    $session = New-CimSession -Authentication Basic -Credential $Credential -ComputerName $IPAddress -Port $Port -SessionOption $cimOptions -OperationTimeoutSec $MaxTimeout # -ErrorAction Stop
}
function Exec
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}

Function Set-Host-Disable {
	[CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,HelpMessage="VMHost")]$VMHost
	)
	#https://www.dotcom-monitor.com/wiki/knowledge-base/api-postman-http-requests-content-types/
	#https://www.dotcom-monitor.com/wiki/knowledge-base/api/
	cd "C:\Program Files (x86)\PuTTY"
	
	if ($VMHost){
		$Alerts = 1
	}else{
		do {
			write-host "To Disable Alarm(s):" -foreground "Yellow" -backgroundcolor "Black"
			write-host "`n[1]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host Only"
			write-host "`n[2]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host & iDRAC"
			write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host, iDRAC & BPHost"
			write-host "`n[4]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host, iDRAC, BPHost & OSD"
			#write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			#write-host " Firewall"
			
			$Alerts = read-host "`nEnter your selection"
		} until ($Alerts -eq 1 -or $Alerts -eq 2 -or $Alerts -eq 3 -or $Alerts -eq 4)
	}
	
	$DC = $null
	$VMName = $null
	$IP = $null
	$HostNameCONS = $null
	$HostNameDRAC = $null
	$pwMon = $null
	$VMNameFull = $null
	
	Function getVMHostDetails {
		if (!$VMHost){$VMHost = SelectHostFast}
		$script:DC = ($VMHost | Get-Datacenter).Name.ToUpper()
		if ($script:DC -Like "IL"){
			$script:VMName = $VMHost.Name.ToUpper().Split('-')[0] -replace 'VM00','VM' -replace 'VM0','VM'
			$script:VMNameFull = $VMHost.Name.ToUpper().Split('-')[0]
		}else{
			$script:VMName = $VMHost.Name.ToUpper().Split('-')[0]
			$script:VMNameFull = $script:VMName
		}
		$script:IP = $VMHost.Name.Split('-')[-1]
		
		$script:HostNameCONS = $script:DC + "-" + $script:VMNameFull + "-CONS-" + $script:ip + "_ping"	
	}
	
	Function getiDRACDetails {
		[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
		$regex = [regex] "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
		do {$iDRACIP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Host iDRAC IP to Add to disable alerts in Site24x7-Monitor.", "Host iDRAC IP")}
		until (($regex.Matches($iDRACIP) | %{ $_.value }))
		$script:HostNameDRAC = $script:DC + "-" + $script:VMNameFull + "-DRAC-" + $iDRACIP + "_ping"
	}
	
	Function getNagiosPW {	
		do {
			while (!$pwMonRH){
				write-host "Please enter ROOT password for " -foreground "green" -nonewline
				write-host "monitor.omc.co.il - 77.247.180.45/185.167.99.99" -foreground "Yellow" -backgroundcolor "Black" -nonewline
				$pwMonRH = read-host " " -AsSecureString
				$script:pwMon = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwMonRH))
			}
			write-host "Checking SSH connection..."
			$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il -nc monitor.omc.co.il:22 | select -Last 2
			$pwMonRH = $null
		} until ($connStatus -like '*SSH*OpenSSH*')
		echo "Password is OK."
	}
	
	Function Disable-osd-bp1 {
		param (
			[int]$Alerts,
			[string]$VMNameTL
		)
		$vmNumber = [regex]::Match($VMNameTL, "vm(\d+)").Groups[1].Value
	
		if ($vmNumber.Length -lt 3) {
			$vmNumber = $vmNumber.PadLeft(3, "0")
		}
	
		$regionName = $script:DC.ToLower()
	
		if ($Alerts -eq 3) {
			$bphostPattern = "${regionName}-bphost-vm${vmNumber}"
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $bphostPattern"
			write-host "Disabled notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $bphostPattern
		} elseif ($Alerts -eq 4) {
			$osdPattern = "osd${vmNumber}.vsan001.${regionName}.cloudwm.com"
			$bphostPattern = "${regionName}-bphost-vm${vmNumber}"
		
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $bphostPattern"
			write-host "Disabled notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $bphostPattern
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $osdPattern"
			write-host "Disabled notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $osdPattern
		}
	}

	if ($Alerts -eq 1){
		if ($VMHost){
			getVMHostDetails
		}else{
			getVMHostDetails
			getNagiosPW
			$VMNameTL = ($script:VMName).ToLower()
			$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $VMNameTL"
			write-host "====================================="
			write-host "Disabled notifications to " -foreground "magenta" -nonewline
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
		}
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Suspend-Monitor.ps1 $script:HostNameCONS
		write-host "====================================="
	}
	if ($Alerts -eq 2){
		getVMHostDetails
		getNagiosPW
		$VMNameTL = ($script:VMName).ToLower()
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $VMNameTL"
		write-host "Disabled notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh ${VMNameTL}_drac"
		write-host "Disabled notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		getiDRACDetails
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " & " -foreground "magenta" -nonewline
		write-host $script:HostNameDRAC -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Suspend-Monitor.ps1 $script:HostNameCONS $script:HostNameDRAC
		write-host "====================================="
	}
	if ($Alerts -eq 3 -or $Alerts -eq 4){
		getVMHostDetails
		getNagiosPW
		$VMNameTL = ($script:VMName).ToLower()
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh $VMNameTL"
		write-host "Disabled notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_exec.sh ${VMNameTL}_drac"
		write-host "Disabled notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		Disable-osd-bp1 -Alerts $Alerts  -VMNameTL $VMNameTL
		getiDRACDetails
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " & " -foreground "magenta" -nonewline
		write-host $script:HostNameDRAC -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Suspend-Monitor.ps1 $script:HostNameCONS $script:HostNameDRAC
		write-host "====================================="
	}
}
Function Set-Host-Enable {
	[CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,HelpMessage="VMHost")]$VMHost
	)
	#https://www.dotcom-monitor.com/wiki/knowledge-base/api-postman-http-requests-content-types/
	#https://www.dotcom-monitor.com/wiki/knowledge-base/api/
	cd "C:\Program Files (x86)\PuTTY"
	
	if ($VMHost){
		$Alerts = 1
	}else{
		do {
			write-host "To Enable Alarm(s):" -foreground "Yellow" -backgroundcolor "Black"
			write-host "`n[1]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host Only"
			write-host "`n[2]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host & iDRAC"
			write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host, iDRAC & BPHost"
			write-host "`n[4]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Host, iDRAC, BPHost & OSD"
			#write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			#write-host " Firewall"
			
			$Alerts = read-host "`nEnter your selection"
		} until ($Alerts -eq 1 -or $Alerts -eq 2 -or $Alerts -eq 3 -or $Alerts -eq 4)
	}
	
	$DC = $null
	$VMName = $null
	$IP = $null
	$HostNameCONS = $null
	$HostNameDRAC = $null
	$pwMon = $null
	$VMNameFull = $null
	
	Function getVMHostDetails {
		if (!$VMHost){$VMHost = SelectHostFast}
		$script:DC = ($VMHost | Get-Datacenter).Name.ToUpper()
		if ($script:DC -Like "IL"){
			$script:VMName = $VMHost.Name.ToUpper().Split('-')[0] -replace 'VM00','VM' -replace 'VM0','VM'
			$script:VMNameFull = $VMHost.Name.ToUpper().Split('-')[0]
		}else{
			$script:VMName = $VMHost.Name.ToUpper().Split('-')[0]
			$script:VMNameFull = $script:VMName
		}
		$script:IP = $VMHost.Name.Split('-')[-1]
		
		$script:HostNameCONS = $script:DC + "-" + $script:VMNameFull + "-CONS-" + $script:ip + "_ping"	
	}
	
	Function getiDRACDetails {
		[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
		$regex = [regex] "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
		do {$iDRACIP = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Host iDRAC IP to Add to disable alerts in Site24x7-Monitor.", "Host iDRAC IP")}
		until (($regex.Matches($iDRACIP) | %{ $_.value }))
		$script:HostNameDRAC = $script:DC + "-" + $script:VMNameFull + "-DRAC-" + $iDRACIP + "_ping"
	}
	
	Function getNagiosPW {	
		do {
			while (!$pwMonRH){
				write-host "Please enter ROOT password for " -foreground "green" -nonewline
				write-host "monitor.omc.co.il - 77.247.180.45/185.167.99.99" -foreground "Yellow" -backgroundcolor "Black" -nonewline
				$pwMonRH = read-host " " -AsSecureString
				$script:pwMon = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwMonRH))
			}
			write-host "Checking SSH connection..."
			$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il -nc monitor.omc.co.il:22 | select -Last 2
			$pwMonRH = $null
		} until ($connStatus -like '*SSH*OpenSSH*')
		echo "Password is OK."
	}
	
	Function Enable-osd-bp1 {
		param (
			[int]$Alerts,
			[string]$VMNameTL
		)
		$vmNumber = [regex]::Match($VMNameTL, "vm(\d+)").Groups[1].Value
		$region = [math]::Floor([int]$vmNumber / 100)
		$regionName = $script:DC.ToLower()
	
		if ($vmNumber.Length -lt 3) {
			$vmNumber = $vmNumber.PadLeft(3, "0")
		}
	
		$regionName = $script:DC.ToLower()
	
		if ($Alerts -eq 3){
			$bphostPattern = "${regionName}-bphost-vm${vmNumber}"
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $bphostPattern"
			write-host "Enable notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $bphostPattern
		}elseif ($Alerts -eq 4){
			$osdPattern = "osd${vmNumber}.vsan001.${regionName}.cloudwm.com"
			$bphostPattern = "${regionName}-bphost-vm${vmNumber}"
		
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $bphostPattern"
			write-host "Enable notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $bphostPattern
			$connStatus = echo y | .\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $osdPattern"
			write-host "Enable notifications to "
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
			Write-Host $osdPattern
		}
	}

	if ($Alerts -eq 1){
		if ($VMHost){
			getVMHostDetails
		}else{
			getVMHostDetails
			getNagiosPW
			$VMNameTL = ($script:VMName).ToLower()
			$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $VMNameTL"
			write-host "====================================="
			write-host "Enabled notifications to " -foreground "magenta" -nonewline
			write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
			write-host "====================================="
		}
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Enable-Monitor.ps1 $script:HostNameCONS
		write-host "====================================="
	}
	if ($Alerts -eq 2){
		getVMHostDetails
		getNagiosPW
		$VMNameTL = ($script:VMName).ToLower()
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $VMNameTL"
		write-host "Enable notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh ${VMNameTL}_drac"
		write-host "Enable notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		getiDRACDetails
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " & " -foreground "magenta" -nonewline
		write-host $script:HostNameDRAC -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Enable-Monitor.ps1 $script:HostNameCONS $script:HostNameDRAC
		write-host "====================================="
	}
	if ($Alerts -eq 3 -or $Alerts -eq 4){
		getVMHostDetails
		getNagiosPW
		$VMNameTL = ($script:VMName).ToLower()
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh $VMNameTL"
		write-host "Enable notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		$connStatus = echo y |.\plink.exe -ssh -l root -pw $script:pwMon monitor.omc.co.il "/usr/local/scripts/host_svc_execup.sh ${VMNameTL}_drac"
		write-host "Enable notifications to "
		write-host $connStatus -foreground "Yellow" -backgroundcolor "Black"
		write-host "====================================="
		Enable-osd-bp1 -Alerts $Alerts  -VMNameTL $VMNameTL
		getiDRACDetails
		write-host "Searching Site24x7 for " -foreground "magenta" -nonewline
		write-host $script:HostNameCONS -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " & " -foreground "magenta" -nonewline
		write-host $script:HostNameDRAC -foreground "Yellow" -backgroundcolor "Black" -nonewline
		write-host " to postpone..." -foreground "magenta"
		C:\script\Monitor\Site24x7\site24x7-Enable-Monitor.ps1 $script:HostNameCONS $script:HostNameDRAC
		write-host "====================================="
	}
}

function Get-Hosts-Status
{            
            Get-Datacenter |  Get-VMHost |

                    Select Name,

                        @{N='CPU GHz Capacity';E={[math]::Round($_.CpuTotalMhz/1024)}},

                        @{N='CPU GHz Used';E={[math]::Round($_.CpuUsageMhz/1024)}},

                        @{N='CPU GHz Free';E={[math]::Round(($_.CpuTotalMhz - $_.CpuUsageMhz)/1024)}},
            
                        @{N='CPU Percent Usage';E={[math]::Round(($_.CpuUsageMhz/$_.CpuTotalMhz)*100)}},

                        @{N='Memory Capacity GB';E={[math]::Round($_.MemoryTotalGB)}},

                        @{N='Memory Used GB';E={[math]::Round($_.MemoryUsageGB)}},

                        @{N='Memory Free GB';E={[math]::Round(($_.MemoryTotalGB - $_.MemoryUsageGB))}},

                        @{N='Memory Percent Usage';E={[math]::Round(($_.MemoryUsageGB/$_.MemoryTotalGB)*100)}},

                        @{N='Timestemp';E={Get-Date -Format yyyy-MM-HH:mm}} |
                                         
                   Out-GridView -PassThru
            
}  

function IsValidEmail { 
    param([string]$EmailAddress)

    try {
        $null = [mailaddress]$EmailAddress
        return $true
    }
    catch {
        return $false
    }
}
Function Get-DR-Replications-Details {
	[CmdletBinding()]
    param(
		[Parameter(Mandatory=$false,HelpMessage="Enter your eMail to send DR report to.")][ValidateNotNullOrEmpty()][mailaddress]$eMail2Send,
		[Parameter(Mandatory=$false,HelpMessage="Enter user's mail to generate DR report, or enter 'ALL' to generate all users reports.")][ValidateNotNullOrEmpty()]$UserMail
    )
	if ((IsValidEmail($eMail2Send)) -Like "False" -and $eMail2Send){
		$ErrorActionPreference= 'SilentlyContinue'
		do {$eMail2Send = read-host "Enter your eMail to send DR report to"}
		until ($eMail2Send -and (IsValidEmail($eMail2Send)) -Like "True")
		$ErrorActionPreference= 'Continue'
		Write-Host "Mail will be sent to:" $eMail2Send -foreground "yellow" -backgroundcolor "Black"
	}
	if ($UserMail -notLike "ALL" -and $UserMail -and (IsValidEmail($UserMail)) -Like "False"){
		$ErrorActionPreference= 'SilentlyContinue'
		do {$UserMail = read-host "Enter user's mail to generate DR report, or enter 'ALL' to generate all users reports"}
		until ($UserMail -Like "ALL" -or (IsValidEmail($UserMail)) -Like "True")
		$ErrorActionPreference= 'Continue'
	}
	& 'C:\Program Files\PowerShell\7\pwsh.exe' C:\script\API\DR\DR-Replication-REST-API-Details.ps1 $eMail2Send $UserMail
}

function Get-Subnet {
    param ( 
        [parameter(ValueFromPipeline)]
        [String]
        $IP,

        [ValidateRange(0, 32)]
        [int]
        $MaskBits,

        [switch]
        $SkipHosts
    ) 
    Begin {
        function Convert-IPtoINT64 ($ip) { 
            $octets = $ip.split(".") 
            [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3]) 
        } 
 
        function Convert-INT64toIP ([int64]$int) { 
            (([math]::truncate($int / 16777216)).tostring() + "." + ([math]::truncate(($int % 16777216) / 65536)).tostring() + "." + ([math]::truncate(($int % 65536) / 256)).tostring() + "." + ([math]::truncate($int % 256)).tostring() )
        } 

        If (-not $IP -and -not $MaskBits) { 
            $LocalIP = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -ne 'WellKnown'})

            $IP = $LocalIP.IPAddress
            $MaskBits = $LocalIP.PrefixLength
        }
    }
    Process {
        If ($IP -match '/\d') { 
            $IPandMask = $IP -Split '/' 
            $IP = $IPandMask[0]
            $MaskBits = $IPandMask[1]
        }
        
        $IPAddr = [Net.IPAddress]::Parse($IP)

        $Class = Switch ($IP.Split('.')[0]) {
            {$_ -in 0..127} { 'A' }
            {$_ -in 128..191} { 'B' }
            {$_ -in 192..223} { 'C' }
            {$_ -in 224..239} { 'D' }
            {$_ -in 240..255} { 'E' }
            
        }
        
        If (-not $MaskBits) {
            $MaskBits = Switch ($Class) {
                'A' { 8 }
                'B' { 16 }
                'C' { 24 }
                default { Throw 'Subnet mask size was not specified and could not be inferred.' }
            }

            Write-Warning "Subnet mask size was not specified. Using default subnet size for a Class $Class network of /$MaskBits."
        }

        If ($MaskBits -lt 16 -and -not $SkipHosts) {
            Write-Warning "It may take some time to calculate all host addresses for a /$MaskBits subnet. Use -SkipHosts to skip."
        }
    
        $MaskAddr = [Net.IPAddress]::Parse((Convert-INT64toIP -int ([convert]::ToInt64(("1" * $MaskBits + "0" * (32 - $MaskBits)), 2))))
        
        $NetworkAddr = New-Object net.ipaddress ($MaskAddr.address -band $IPAddr.address) 
        $BroadcastAddr = New-Object net.ipaddress (([system.net.ipaddress]::parse("255.255.255.255").address -bxor $MaskAddr.address -bor $NetworkAddr.address))
     
        $HostStartAddr = (Convert-IPtoINT64 -ip $NetworkAddr.ipaddresstostring) + 1
        $HostEndAddr = (Convert-IPtoINT64 -ip $broadcastaddr.ipaddresstostring) - 1
        
        If (-not $SkipHosts) {
            $HostAddresses = for ($i = $HostStartAddr; $i -le $HostEndAddr; $i++) {
                Convert-INT64toIP -int $i
            }
        }

    
        [pscustomobject]@{
            IPAddress        = $IPAddr
            MaskBits         = $MaskBits
            NetworkAddress   = $NetworkAddr
            BroadcastAddress = $broadcastaddr
            SubnetMask       = $MaskAddr
            NetworkClass     = $Class
            Range            = "$networkaddr ~ $broadcastaddr"
            HostAddresses    = $HostAddresses
        }
    }
    End {}
}

Function Host-MigrateVMs {
	Function Get-VMs2Chk {
		write-Host "`n******************************" -foreground "Magenta" 
		Write-Host "Sorting VMs on " -foreground "yellow" -backgroundcolor "Black" -nonewline
		Write-Host $VMHostName -foreground "Yellow" -backgroundcolor "Red" -nonewline
		Write-Host "..." -foreground "yellow" -backgroundcolor "Black"
		write-Host "******************************" -foreground "Magenta"
		#$script:VMhost = Get-VMhost ${VMHostName}-*
		$uuidVMhost = $VMhost.ExtensionData.hardware.systeminfo.uuid
		if ((((Invoke-WebRequest -Uri "https://staging.cloudwm.com/cwmqueue/cwmstatus/$uuidVMhost" -UseBasicParsing).Content | ConvertFrom-Json).SyncRoot | sls allowProvisioning) -Match "True"){$PerMulti = 0.69}else{$PerMulti = 0.88}
		$script:DC = $VMHost.Parent.ParentFolder.Parent.Name
		$AllVMHostsVMs = $VMhost | Get-VM | Select-Object Name,@{N="UsedSpace";E={[Math]::Round(($_.UsedSpaceGB),0)}},@{N="CPU Usage";E={[int]((Get-Stat -Realtime -Stat cpu.usagemhz.average -Entity $_ -Start (get-date).addminutes(-1)-IntervalMins 1 -MaxSamples 1).Value | Sort | Select -last 1)}},NumCPU,@{N='CPU%';E={[Math]::Round((Get-Stat -Realtime -Stat cpu.usage.average -Entity $_ -Start (get-date).addminutes(-1)-IntervalMins 1 -MaxSamples 1 | ? {$_.Unit -Like "%"}).Value)}},@{N="Mem Usage";E={[math]::Round((get-stat -realtime -stat mem.usage.average -entity $_ -start (get-date).addminutes(-1)-IntervalMins 1 -MaxSamples (1)).Value / 100 * $_.MemoryMB)}},PowerState,Notes
		$AllVMHostsVMsSel = $AllVMHostsVMs | ? {$_.Name -notMatch "-bphost-.*.cloudwm.com" -and $_.Name -notMatch "osd.*.vsan001.*.cloudwm.com" -and $_.Name -notMatch "_dr$" -and $_.Name -notMatch "_replica" -and $_.Name -notMatch "^Z-VRA-" -and $_.Notes -notmatch "nomigrate=true" -and $_.Notes -notmatch "cpuReserve=true" -and $_.Notes -notmatch "withvm="}
		$script:VMs2Chk = $AllVMHostsVMsSel | ? {$_.UsedSpace -le $MaxUsedSpace}
		if ($ResourceName -Like "CPU"){
			if ($UsagePref -Like "H"){
				$script:VMsChoose = $script:VMs2Chk | ? {$_.PowerState -Like "PoweredOn"} | Sort-Object -Property @{expression = 'CPU Usage';descending = $false},@{expression = 'UsedSpace';descending = $false},@{expression = 'Mem Usage';descending = $false}
				#$script:AmountNew = [Math]::Round((($AllVMHostsVMs."CPU Usage" | Measure -sum | % sum) / $Amount * ($Amount - 88)))
				$script:AmountNew = [Math]::Round($VMhost.CpuTotalMhz * "0.$amount" - $VMhost.CpuTotalMhz * $PerMulti)
			}
			if ($UsagePref -Like "L"){
				$script:VMsChoose = $script:VMs2Chk | ? {$_.PowerState -Like "PoweredOn"} | Sort-Object -Property @{expression = 'CPU Usage';descending = $false},@{expression = 'UsedSpace';descending = $false},@{expression = 'NumCPU';descending = $true},@{expression = 'Mem Usage';descending = $false}
				$script:AmountNew = $Amount
			}
		}
		if ($ResourceName -Like "Memory"){
			if ($UsagePref -Like "H"){$script:VMsChoose = $script:VMs2Chk | ? {$_.PowerState -Like "PoweredOn"} | Sort-Object -Property @{expression = 'Mem Usage';descending = $true},@{expression = 'UsedSpace';descending = $false},@{expression = 'CPU Usage';descending = $false}}
			if ($UsagePref -Like "L"){$script:VMsChoose = $script:VMs2Chk | ? {$_.PowerState -Like "PoweredOn"} | Sort-Object -Property @{expression = 'Mem Usage';descending = $false},@{expression = 'UsedSpace';descending = $false},@{expression = 'CPU Usage';descending = $false}}
			$script:AmountNew = $Amount
		}
		$script:VMs = @()
		$SumNumRes = $null
		Foreach ($VMChoose in $script:VMsChoose){
			$script:VMs += $VMChoose
			if ($ResourceName -Like "CPU" -and $UsagePref -Like "H"){$SumNumRes = $SumNumRes + $VMChoose."CPU Usage"}
			if ($ResourceName -Like "CPU" -and $UsagePref -Like "L"){$SumNumRes = $SumNumRes + $VMChoose.NumCPU}
			if ($ResourceName -Like "Mem"){$SumNumRes = $SumNumRes + $VMChoose."Mem Usage"}
			if ($SumNumRes -ge $script:AmountNew){$Done=1;break}
		}
		if (!$Done){$VMs = $null}
	}
	
	Function Get-VMHostsSort {
		write-Host "`n******************************" -foreground "Magenta" 
		Write-Host "Sorting VMHosts in " -foreground "yellow" -backgroundcolor "Black" -nonewline
		Write-Host $DC -foreground "Yellow" -backgroundcolor "Red" -nonewline
		Write-Host "..." -foreground "yellow" -backgroundcolor "Black"
		write-Host "******************************" -foreground "Magenta"
		$VMhostSub = $VMHostName.Substring(0,4)
		if (($VMhostSub -replace "[^0-9]" , '').Substring(0,1) -eq 0){$VMHostCheck = $VMHostName -replace '^vm0', 'vm'}else{$VMHostCheck = $VMHostName}
		$VMHostsNagiosAll = ((Invoke-WebRequest http://monitor.omc.co.il/scripts/host-vmmigrate.php?check=$ResourceName -UseBasicParsing).Content).trim()
#echo VMHostsNagiosAll
#$VMHostsNagiosAll
		if ($VMHostsNagiosAll){
			#$VMHostsNagios = @()
			if ($VMHostCheck.Length -eq 4){
				$VMHostsNagios = ($VMHostsNagiosAll -Split "`n" | ? {$_.Length -Like $VMHostCheck.Length}) -replace '^vm', 'vm0'
			}elseif ($VMHostCheck.Length -eq 5){
				$VMHostsNagios = $VMHostsNagiosAll -Split "`n" | ? {$_.Length -eq 5 -and $_ -Match $VMHostCheck.Substring(0,3)}
			}else{
				$VMHostsNagios = $VMHostsNagiosAll -Split "`n" | ? {$_.Length -eq 6 -and $_ -Match $VMHostCheck.Substring(0,4)}
			}
		}
		if ($VMHostsNagios){
			$VMhostsDC = Get-VMhost -Location $DC | ? {$_.Name | sls $VMHostsNagios -NotMatch} | ? {$_.Name | sls $VMHostName -NotMatch} | ? {$_.ConnectionState -ne "Maintenance" -and $_.ExtensionData.Summary.Runtime.ConnectionState -eq 'connected' -and ($_ | Get-Annotation | ? {$_.Name -Like "Dedicated Customer Host"}).Value.trimEnd() -eq "" -and ($_ | Get-VM | ? {$_.Name -notLike "*cloudwm.com*"})} | 
						Select-Object Name,@{N="CPU%";E={[Math]::Round(($_.CpuUsageMhz / $_.CpuTotalMhz * 100),0)}},@{N="Mem%";E={[Math]::Round(($_.MemoryUsageMB / $_.MemoryTotalMB * 100),0)}},@{N="SpaceGB";E={Get-Datastore -VMHost $_ vm[0-9]*:storage[0-9]*}},@{N="UUID";E={$_.ExtensionData.hardware.systeminfo.uuid}},ProcessorType,CpuTotalMhz,CpuUsageMhz,@{N="MemoryTotalMB";E={[Math]::Round(($_.MemoryTotalMB))}},@{N="MemoryUsageMB";E={[Math]::Round(($_.MemoryUsageMB))}} | 
						Foreach {$_ | Select-Object Name,@{N="Storages";E={(($_.SpaceGB | Measure-Object FreeSpaceGB).Count)}},@{N="FreeSpace";E={[Math]::Round((($_.SpaceGB | Measure-Object FreeSpaceGB -Sum).Sum),0)}},@{N="Capacity";E={[Math]::Round((($_.SpaceGB | Measure-Object CapacityGB -Sum).Sum),0)}},"CPU%","Mem%",CpuTotalMhz,CpuUsageMhz,MemoryTotalMB,MemoryUsageMB,UUID,ProcessorType,@{N="VMs Migrated";E={[int]0}}} | ? {$_.Storages -eq 1 -and $_.Capacity -gt (2048 + $MaxUsedSpace)}
		}else{
			$VMhostsDC = Get-VMhost -Location $DC | ? {$_.Name | sls $VMHostName -NotMatch} | ? {$_.ConnectionState -ne "Maintenance" -and $_.ExtensionData.Summary.Runtime.ConnectionState -eq 'connected' -and ($_ | Get-Annotation | ? {$_.Name -Like "Dedicated Customer Host"}).Value.trimEnd() -eq "" -and ($_ | Get-VM | ? {$_.Name -notLike "*cloudwm.com*"})} |
						Select-Object Name,@{N="CPU%";E={[Math]::Round(($_.CpuUsageMhz / $_.CpuTotalMhz * 100),0)}},@{N="Mem%";E={[Math]::Round(($_.MemoryUsageMB / $_.MemoryTotalMB * 100),0)}},@{N="SpaceGB";E={Get-Datastore -VMHost $_ vm[0-9]*:storage[0-9]*}},@{N="UUID";E={$_.ExtensionData.hardware.systeminfo.uuid}},ProcessorType,CpuTotalMhz,CpuUsageMhz,@{N="MemoryTotalMB";E={[Math]::Round(($_.MemoryTotalMB))}},@{N="MemoryUsageMB";E={[Math]::Round(($_.MemoryUsageMB))}} | 
						Foreach {$_ | Select-Object Name,@{N="Storages";E={(($_.SpaceGB | Measure-Object FreeSpaceGB).Count)}},@{N="FreeSpace";E={[Math]::Round((($_.SpaceGB | Measure-Object FreeSpaceGB -Sum).Sum),0)}},@{N="Capacity";E={[Math]::Round((($_.SpaceGB | Measure-Object CapacityGB -Sum).Sum),0)}},"CPU%","Mem%",CpuTotalMhz,CpuUsageMhz,MemoryTotalMB,MemoryUsageMB,UUID,ProcessorType,@{N="VMs Migrated";E={[int]0}}} | ? {$_.Storages -eq 1 -and $_.Capacity -gt (2048 + $MaxUsedSpace)}
		}
#echo "VMhostsDC:"
#$VMhostsDC | ft -au
		$VMhostsDCAnnot = @()
		Foreach ($VMhostDC in $VMhostsDC){
			$uuidVMhost = $VMhostDC.UUID
			if ((((Invoke-WebRequest -Uri "https://staging.cloudwm.com/cwmqueue/cwmstatus/$uuidVMhost" -UseBasicParsing).Content | ConvertFrom-Json).SyncRoot | sls allowProvisioning) -Match "True"){
				$VMhostDCAnnot = $VMhostDC | Select-Object *,@{N="Provisioning";E={echo "Allow"}}
				$VMhostsDCAnnot += $VMhostDCAnnot
			}else{
				$VMhostsDCAnnot += $VMhostDC | Select-Object *,@{N="Provisioning";E={echo ""}}
			}
		}
#echo "VMhostsDCAnnot:"
#$VMhostsDCAnnot | ft -au
		$VmsCpuUsageCheck = ($script:VMs."CPU Usage" | Measure -sum | % sum) / $script:VMs.Count
		$VmsMemUsageCheck = ($script:VMs."Mem Usage" | Measure -sum | % sum) / $script:VMs.Count
#Write-Host "VmsCpuUsageCheck: " $VmsCpuUsageCheck
#Write-Host "VmsMemUsageCheck: " $VmsMemUsageCheck
		if ($ResourceName -Like "CPU"){
			if ($UsagePref -Like "H"){$script:VMhostsMatch = $VMhostsDCAnnot | ? {$_."CPU%" -lt (($_.CpuTotalMhz - $VmsCpuUsageCheck + 10) / $_.CpuTotalMhz * 100) -and $_."CPU%" -lt 88 -and $_."Mem%" -lt 93 -and $_."Mem%" -lt (($_.MemoryTotalMB - $VmsMemUsageCheck) / $_.MemoryTotalMB * 100) -and $_.FreeSpace -gt ([int]$MaxUsedSpace + 500) -and $_.Provisioning -eq ""} | 
															Sort-Object -Property @{expression = 'CPU%';descending = $false}, @{expression = 'Mem%';descending = $false}, @{expression = 'FreeSpace';descending = $true}}
			if ($UsagePref -Like "L"){$script:VMhostsMatch = $VMhostsDCAnnot | ? {$_."CPU%" -lt (($_.CpuTotalMhz - $VmsCpuUsageCheck + 10) / $_.CpuTotalMhz * 100) -and $_."CPU%" -lt 88 -and $_."Mem%" -lt 95 -and $_."Mem%" -lt (($_.MemoryTotalMB - $VmsMemUsageCheck) / $_.MemoryTotalMB * 100) -and $_.FreeSpace -gt ([int]$MaxUsedSpace + 500) -and $_.Provisioning -eq ""} | 
															Sort-Object -Property @{expression = 'CPU%';descending = $false}, @{expression = 'Mem%';descending = $false}, @{expression = 'FreeSpace';descending = $true}}
		}
		if ($ResourceName -Like "Memory"){
			if ($UsagePref -Like "H"){$script:VMhostsMatch = $VMhostsDCAnnot | ? {$_."Mem%" -lt (($_.MemoryTotalMB - $VmsMemUsageCheck) / $_.MemoryTotalMB * 100) -and $_."Mem%" -lt 93 -and $_."CPU%" -lt (($_.CpuTotalMhz - $VmsCpuUsageCheck) / $_.CpuTotalMhz * 100) -and $_."CPU%" -lt 88 -and $_.FreeSpace -gt ([int]$MaxUsedSpace + 500) -and $_.Provisioning -eq ""} | 
															Sort-Object -Property @{expression = 'Mem%';descending = $false},@{expression = 'FreeSpace';descending = $true},@{expression = 'CPU%';descending = $false}}
			if ($UsagePref -Like "L"){$script:VMhostsMatch = $VMhostsDCAnnot | ? {$_."Mem%" -lt (($_.MemoryTotalMB - $VmsMemUsageCheck) / $_.MemoryTotalMB * 100) -and $_."Mem%" -lt 90 -and $_."CPU%" -lt (($_.CpuTotalMhz - $VmsCpuUsageCheck) / $_.CpuTotalMhz * 100) -and $_."CPU%" -lt 95 -and $_.FreeSpace -gt ([int]$MaxUsedSpace + 500) -and $_.Provisioning -eq ""} | 
															Sort-Object -Property @{expression = 'Mem%';descending = $false},@{expression = 'FreeSpace';descending = $true},@{expression = 'CPU%';descending = $false}}
		}
#echo "script:VMhostsMatch:"
#$script:VMhostsMatch | ft -au
	}
	
	Function Run-Migrate {
		$VMhostCount = [int]$script:VMhostsMatch.Count
		if ($VMhostCount -eq 0){
			$script:VMhostsMatch | ft -au
			Write-Host "Only 1 VMhost match to migrate found!`n" -foreground "Yellow" -backgroundcolor "Red"
			do {
				$AnswerVMhostCount = Read-Host "Do you want to continue? [Y/N]"
			} until ($AnswerVMhostCount -Like "Y" -or $AnswerVMhostCount -Like "N")
			if ($AnswerVMhostCount -Like "Y"){$VMhostCount = 1}
			if ($AnswerVMhostCount -Like "N"){break}
		}
		
		#$ErrorActionPreference= 'SilentlyContinue'
		if ($ResourceName -Like "CPU"){
			if ($UsagePref -Like "H"){$VMsRes2Host = [int]([Math]::Ceiling(($script:VMs.Count / $VMhostCount)));if ($VMsRes2Host -lt 1){$VMsRes2Host = 1}}
			if ($UsagePref -Like "L"){$VMsRes2Host = [int]([Math]::Ceiling(($Amount / $VMhostCount)));if ($VMsRes2Host -lt 1){$VMsRes2Host = 1}}
		}elseif ($ResourceName -Like "Memory"){$VMsRes2Host = [int]([Math]::Ceiling(($script:VMs.Count / $VMhostCount)));if ($VMsRes2Host -lt 1){$VMsRes2Host = 1}}
		#$ErrorActionPreference= 'Continue'
		#$y=@();$n=1;$x=1;do{$x = $n + $x;$y+=$x;$n++}until($x -ge $Amount)
	
		do {
			$VMhostCount = [int]$script:VMhostsMatch.Count
			if ($VMhostCount -eq 0){$VMhostCount = 1}
			write-Host "`n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" -foreground "Yellow"
			$VMsCount = $VMs.Count
			write-Host "VMs left:" $VMsCount
			$VMs | ft -AutoSize
			write-Host "`nVMHosts left:" $VMhostCount
			$script:VMhostsMatch | ft -AutoSize # | Select-Object Name,Storages,FreeSpace,Capacity,"CPU%","Mem%",MemoryTotalMB,MemoryUsageMB,"VMs Migrated"
			write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" -foreground "Yellow"
			
			
			$script:VMhost2Mig = $script:VMhostsMatch | Select -First 1
			$VMs2Mig = @()
			$VMs2MigNumRes = @()
			$CountMig = 1;$CountMigSelect = 1
			do {
				if ($CountMig%2){$VMs2Mig += $script:VMs | Select -First $CountMigSelect | Select -Last 1}else{$VMs2Mig += $script:VMs | Select -Last $CountMigSelect | Select -First 1}
				if ($ResourceName -Like "CPU"){
					if ($UsagePref -Like "H"){$VMs2MigNumRes = $CountMig}
					if ($UsagePref -Like "L"){$VMs2MigNumRes = $VMs2Mig.NumCpu}
				}elseif ($ResourceName -Like "Memory"){$VMs2MigNumRes += $VMs2Mig."Mem Usage"}
				$CountMig++
				if ($VMs2Mig.Count%2){}else{$CountMigSelect++}
				if ($script:VMs.Count -le 1 -and $VMs2Mig){break}
				#Write-Host "VMs2MigNumRes: " $VMs2MigNumRes
				#Write-Host "Out of: " $VMsRes2Host
				#Write-Host "CountMig:" $CountMig
				#Write-Host "CountMigSelect:"$CountMigSelect
			} until (($VMs2MigNumRes | Measure -sum | % sum) -ge $VMsRes2Host)
			
			if (($VMhost2Mig.CpuTotalMhz - $VMhost2Mig.CpuUsageMhz) -gt (($VMs2Mig."CPU Usage" | Measure -sum | % sum) + 10) -and ($VMhost2Mig.MemoryTotalMB - $VMhost2Mig.MemoryUsageMB) -gt (($VMs2Mig."Mem Usage" | Measure -sum | % sum) + 50) -and $VMhost2Mig.FreeSpace -gt (($VMs2Mig.UsedSpace | Measure -sum | % sum) + 500)){
				if ($ResourceName -Like "CPU"){
					if ($UsagePref -Like "H"){$VMsNumResCount = $script:VMs."CPU Usage" | Measure -sum | % sum}
					if ($UsagePref -Like "L"){$VMsNumResCount = $script:VMs.NumCPU | Measure -sum | % sum}
				}
				if ($ResourceName -Like "Memory"){$VMsNumResCount = $script:VMs."Mem Usage" | Measure -sum | % sum}
				write-Host "`n******************************************************************************************" -foreground "Magenta"
				write-Host "VMhosts targets to migrate left:" $VMhostCount
				if ($ResourceName -Like "CPU"){
					if ($UsagePref -Like "H"){write-Host "VMs' CPU Usage (MHz) left to migrate:" $VMsNumResCount;write-Host "Calculated number of VMs in " -nonewline;Write-Host $VMhostName -foreground "Yellow" -backgroundcolor "Red" -nonewline;Write-Host " to each host:" $VMsRes2Host}
					if ($UsagePref -Like "L"){write-Host "VMs' vCPUs left to migrate:" $VMsNumResCount;write-Host "Calculated number of VMs' vCPUs in " -nonewline;Write-Host $VMhostName -foreground "Yellow" -backgroundcolor "Red" -nonewline;Write-Host " to each host (more or equal to):" $VMsRes2Host}
				}
				if ($ResourceName -Like "Memory"){write-Host "VMs' memory usage left to migrate:" $VMsNumResCount;write-Host "Calculated number of VMs' memory usage in " -nonewline;Write-Host $VMhostName -foreground "Yellow" -backgroundcolor "Red" -nonewline;Write-Host " to each host (with more or equal to):" $VMsRes2Host}
				
				write-Host "=============================================================================="
				if ($ResourceName -Like "CPU" -and $UsagePref -Like "H"){$VMs2Mig | Sort "CPU Usage" | ft -AutoSize}
				if ($ResourceName -Like "CPU" -and $UsagePref -Like "L"){$VMs2Mig | Sort NumCpu | ft -AutoSize}
				if ($ResourceName -Like "Memory"){$VMs2Mig | Sort "Mem Usage" | ft -AutoSize}
				$script:VMhost2Mig | ft -AutoSize # | Select-Object Name,Storages,FreeSpace,Capacity,"CPU%","Mem%",MemoryTotalMB,MemoryUsageMB,"VMs Migrated" | ft -AutoSize
				write-Host "*******************************************************************" -foreground "Magenta"
				
				Foreach ($VM2Mig in $VMs2Mig){
				#storagetype
				#host
					$Note2Check = "hostcpumodel"
					if ($VM2Mig.Notes -Match "$Note2Check="){			
						$CPUType = (((($VM2Mig.Notes.Split(',') | sls "$Note2Check=") -replace "`n","") -split '=' | sls -NotMatch $Note2Check) | Sort -Unique | Select -First 1 | Out-String).Trim()
						Get-VMhostMatchNote $Note2Check $CPUType
					}
					
					$Note2Check = "withoutvm"
					if ($VM2Mig | ? {$_.Notes -Match $Note2Check}){
						$VM2MigWithout = ((($VM2Mig.Notes.Split(',') | sls $Note2Check) -replace "`n","") -split '=' | sls -NotMatch "withoutvm") -replace "`n",""
						Get-VMhostMatchNote $Note2Check $VM2MigWithout
					}
					
					$VM2MigName = $VM2Mig.Name
					$VMhost2MigName = $script:VMhost2Mig.Name
					###Write-Host "C:\script\vMigrate\Migrate-VM.ps1 $DC $VM2MigName $VMhost2MigName 1"
					Write-Host "Setting migration:" -foregroundcolor "Green"
					C:\script\vMigrate\Migrate-VM.ps1 $DC $VM2MigName $VMhost2MigName 1
					#C:\script\vMigrate\Migrate-VM2Host.ps1 $DC $VM2Mig $script:VMhost2Mig 1
					$script:VMs = $script:VMs | ? {$_ -notLike $VM2Mig}
					$script:VMhostsMatch | ForEach-Object {if ($_.Name -Like $script:VMhost2Mig.Name){$_."VMs Migrated" = [int]$_."VMs Migrated" + 1}}
					write-Host "*******************************************************************" -foreground "Green"
				}
				#$script:VMhost2Mig | Select-Object Name,Storages,FreeSpace,Capacity,"CPU%","Mem%",MemoryTotalMB,MemoryUsageMB,"VMs Migrated" | ft -AutoSize
				#$script:VMhostsMatch | ? {$_."VMs Migrated" -gt 0} | Select-Object Name,Storages,FreeSpace,Capacity,"CPU%","Mem%","VMs Migrated"| ft -AutoSize
				$script:VMhostsMatch = $script:VMhostsMatch | ? {$_ -notLike $script:VMhost2Mig}
			}else{
				$script:VMhostsMatch = $script:VMhostsMatch | ? {$_ -notLike $script:VMhost2Mig}
				$script:VMhostsMatch = $script:VMhostsMatch + $VMhost2Mig
				$VMs2Mig
				$VMhost2Mig
				do {
					$AnswerLess = Read-Host "$VMhost2Mig resources are less than the VMs' to migrate. Continue to next VMhost (No=Exit)? [Y/N]"
				} until ($AnswerLess -Like "Y" -or $AnswerLess -Like "N")
				if ($AnswerLess -Like "Y"){continue}else{Write-Host "Exiting...";break}
			}
		} until (!$VMs -or !$script:VMhostsMatch)
	}
	
	Function Get-VMhostMatchNote {
		[CmdletBinding()]
		param(
			[Parameter(Mandatory=$true,HelpMessage="Note")]$Note,
			[Parameter(Mandatory=$true,HelpMessage="Note Value")]$NoteValues
		)
	
		do {$CountHosts++
			if ($Note -Like "hostcpumodel"){$NoteCheck = $script:VMhost2Mig | ? {(($_.ProcessorType.Split(' ') | sls [0-9][0-9][0-9][0-9]) -replace "[^0-9]") -ge $NoteValues}}
			if ($Note -Like "withoutvm"){$VMsNameHostMig = (Get-VMhost $script:VMhost2Mig.Name | Get-VM).Name;$NoteCheck = Foreach ($NoteValue in $NoteValues){if ($VMsNameHpstMig | ? {$_ -Like $NoteValue}){$NoteValue;break}}}
			if ($NoteCheck){
				$VMhost2MigOK = 1
			}else{
				$CountHosts++
				$script:VMhost2Mig = $script:VMhostsMatch | Select -First $CountHosts | Select -Last 1
			}
		} until ($VMhost2MigOK -or $CountHosts -ge $VMhostCount)
		$VMhost2MigOK = $null;$CountHosts = $null
		if ($CountHosts -ge $VMhostCount){
			Write-Host "Unable to find host matching " -foreground "Red" -backgroundcolor "Black" -nonewline
			Write-Host $VM2Mig.Name -foreground "Yellow" -backgroundcolor "Black" -nonewline
			Write-Host "'s note '" -foreground "Red" -backgroundcolor "Black" -nonewline
			Write-Host $Note2Check  -foreground "Yellow" -backgroundcolor "Black" -nonewline
			Write-Host "'" -foreground "Red" -backgroundcolor "Black"
			Write-Host "Skipping VM!" -foreground "Yellow" -backgroundcolor "Black"
			continue
		}
	}
	
	#Run script
	do {
		do {
			$VMHostName = read-host "Enter VMHost name to migrate from (e.g. vm019)"
			$VMHost = Get-VMHost ${VMHostName}-*
		} until ($VMHost) #($VMHostName -Match "^VM[0-9][0-9][0-9]")
		
		do {
			write-host "`nChoose Resource to fix" -foreground "Yellow" -backgroundcolor "Black"
			write-host "`n[1]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " CPU"
			write-host "`n[2]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Memory"
			write-host "`n[3]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " Free Space"
			write-host "`n[4]" -foreground "Yellow" -backgroundcolor "Black" -nonewline
			write-host " VMs Amount"
			$Resource = read-host "`nEnter your selection"
		} until ($Resource -eq 1 -or $Resource -eq 2 -or $Resource -eq 3 -or $Resource -eq 4)
		
		Write-Host ""
	
		if ($Resource -eq 1){
			$ResourceName = "CPU"
			do {$UsagePref = read-host "Enter usage priorty: [H]igh (Small VMs amount with high ${ResourceName} usage {CPU%}) / [L]ow (Large VMs amount with low ${ResourceName} usage {vCPUs})"} until ($UsagePref -Like "H" -or $UsagePref -Like "L")	
			if ($UsagePref -Like "H"){do {$Amount = read-host "Enter amount (%) [69-99]"} until ($Amount -Match '^[0-9]+$' -and $Amount -ge 69 -and $Amount -lt 100)}
			if ($UsagePref -Like "L"){do {$Amount = read-host "Enter amount (vCPU) [1-999]"} until ($Amount -Match '^[0-9]+$' -and $Amount -gt 0 -and $Amount -le 999)}
			
	:BEGIN  while (!$END){
				do {
					$MaxUsedSpace = read-host "Enter maximum VM size (GB) for migration [1-500]"
				} until ($MaxUsedSpace -match "^\d+$" -and $MaxUsedSpace -gt 0 -and $MaxUsedSpace -le 500)
	#$Amount
				Get-VMs2Chk
				if ($script:VMs.Count -eq 0){
					Write-Host "No VMs found matching data entered!!!"  -foreground "Yellow" -backgroundcolor "Red"
					continue BEGIN
				}
				if ($UsagePref -Like "H"){$VMsNumResCount = $script:VMs."CPU Usage" | measure -sum | % sum}
				if ($UsagePref -Like "L"){$VMsNumResCount = $script:VMs.NumCPU | measure -sum | % sum}
	#$VMsNumResCount
	#$script:AmountNew
	#exit
				if ($VMsNumResCount -lt $script:AmountNew){
					write-Host "`n************************************************************" -foreground "Magenta"
					write-Host "Not enough VMs found on VMhost matching maximum VM size entered!" -foreground "Yellow" -backgroundcolor "Red"
					write-Host "Amount required: " -nonewline
					write-Host $script:AmountNew -foreground "Yellow" -backgroundcolor "Red"
					if ($UsagePref -Like "H"){write-Host "VMs' CPU Usage found: " -nonewline}
					if ($UsagePref -Like "L"){write-Host "VMs' NumCPU found: " -nonewline}
					write-Host $VMsNumResCount -foreground "Yellow" -backgroundcolor "Red"
					if ($UsagePref -Like "H"){$script:VMs | Sort "CPU Usage" -Descending | ft -AutoSize}
					if ($UsagePref -Like "L"){$script:VMs | Sort NumCpu -Descending | ft -AutoSize}
					write-Host "`n************************************************************" -foreground "Magenta"
					do {
						$Answer = read-Host "Do you want to [C]ontinue or choose [N]ew VM size (Old: $MaxUsedSpace)? [C/N]"
					} until ($Answer -Like "C" -or $Answer -Like "N")
					if ($Answer -Like "N"){write-Host "************************************************************" -foreground "Magenta";continue BEGIN}
				}
				Get-VMHostsSort
				if ($script:VMhostsMatch.Count -eq 0){
					$script:VMs | ft -au
					Write-Host "No VMHosts found matching data entered!!!"  -foreground "Yellow" -backgroundcolor "Red"
					continue BEGIN
				}
				Run-Migrate
				$END = "END"
			}
		}
	
		if ($Resource -eq 2){
			$ResourceName = "memory"
			#Write-Host "Not Applicable yet.`n";break
			do {$UsagePref = read-host "Enter usage priorty: [H]igh (Small VMs amount with high ${ResourceName} usage) / [L]ow (Large VMs amount with low ${ResourceName} usage)"} until ($UsagePref -Like "H" -or $UsagePref -Like "L")	
			do {$Amount = read-host "Enter Host Free Memory amount [0-~]"} until ($Amount -Match '^[0-9]+$')
			#if ($UsagePref -Like "L"){do {$Amount = read-host "Enter Host Free Memory amount [0-~]"} until ($Amount -Match '^[0-9]+$')}
			$Amount = [int]$Amount + 5120
			
	:BEGIN  while (!$END){
				do {
					$MaxUsedSpace = read-host "Enter maximum VM size (GB) for migration [1-500]"
				} until ($MaxUsedSpace -match "^\d+$" -and $MaxUsedSpace -gt 0 -and $MaxUsedSpace -le 500)
	#$Amount
				Get-VMs2Chk
				if ($script:VMs.Count -eq 0){
					Write-Host "No VMs found matching data entered!!!"  -foreground "Yellow" -backgroundcolor "Red"
					continue BEGIN
				}
				$VMsNumResCount = $script:VMs."Mem Usage" | measure -sum | % sum
				#if ($UsagePref -Like "L"){$VMsNumResCount = $script:VMs.NumCPU | measure -sum | % sum}
	#$VMsNumResCount
	#$script:AmountNew
	#exit
				if ($VMsNumResCount -lt $script:AmountNew){
					write-Host "`n************************************************************" -foreground "Magenta"
					write-Host "Not enough VMs found on VMhost matching maximum VM size entered!" -foreground "Yellow" -backgroundcolor "Red"
					write-Host "Amount required: " -nonewline
					write-Host $script:AmountNew -foreground "Yellow" -backgroundcolor "Red"
					write-Host "VMs' Mem Usage found: " -nonewline
					#if ($UsagePref -Like "L"){write-Host "VMs' NumCPU found: " -nonewline}
					write-Host $VMsNumResCount -foreground "Yellow" -backgroundcolor "Red"
					$script:VMs | Sort "Mem Usage" -Descending | ft -AutoSize
					#if ($UsagePref -Like "L"){$script:VMs | Sort NumCpu -Descending | ft -AutoSize}
					write-Host "`n************************************************************" -foreground "Magenta"
					do {
						$Answer = read-Host "Do you want to [C]ontinue or choose [N]ew VM size (Old: $MaxUsedSpace)? [C/N]"
					} until ($Answer -Like "C" -or $Answer -Like "N")
					if ($Answer -Like "N"){write-Host "************************************************************" -foreground "Magenta";continue BEGIN}
				}
				Get-VMHostsSort
				if ($script:VMhostsMatch.Count -eq 0){
					$script:VMs | ft -au
					Write-Host "No VMHosts found matching data entered!!!"  -foreground "Yellow" -backgroundcolor "Red"
					continue BEGIN
				}
				Run-Migrate
				$END = "END"
			}
		}
		if ($Resource -eq 3){
			$ResourceName = "Free Space"
			Write-Host "Not Applicable yet.`n";break	
		}
		
		if ($Resource -eq 4){
			$ResourceName = "VMs Amount"
			Write-Host "Not Applicable yet.`n";break	
		}
	} until (!$script:VMs -or !$script:VMhostsMatch)
}