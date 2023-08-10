function move-Contacts {
    # Set the error action preference to SilentlyContinue
    $ErrorActionPreference = "SilentlyContinue"
    Copy-Item C:\testAlexeym\Ronii\MoveContactFromMontior\MoveFromMonitor.txt.bak C:\testAlexeym\Ronii\MoveContactFromMontior\MoveFromMonitor.txt -ErrorAction Ignore
    Set-Location "C:\Program Files (x86)\PuTTY"

        $connStatus = ""
        $pwMon = "nag45259790"


    echo "Password is OK."
	$fileNameMon = "C:\testAlexeym\Ronii\MoveContactFromMontior\MoveFromMonitor.txt"
	echo "y" | .\plink.exe -ssh -l root -pw $pwMon monitor.omc.co.il -m $fileNameMon
}