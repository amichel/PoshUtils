workflow Run-RemoteParallelScript {
   param([string]$scriptFile="",[string]$scriptCommand="",[string[]]$computers)
   $scriptContent=""

   if($scriptFile -ne "") {
        $scriptContent = gc $scriptFile
   }

   foreach –parallel ($computer in $computers){    
         InlineScript {            
            $VerbosePreference = [System.Management.Automation.ActionPreference]$Using:VerbosePreference
            $DebugPreference = [System.Management.Automation.ActionPreference]$Using:DebugPreference

            if($Using:scriptContent -ne "") {
                $tempFile = "$env:TMP\{0}.ps1" -f [Guid]::NewGuid()
                $Using:scriptContent | Out-File -FilePath $tempFile -Force
                Write-Verbose ("Created File $tempFile length {0}" -f (gc $tempFile).Length)
                .$tempFile 
                Remove-Item $tempFile -Force
                Write-Verbose ("Deleted File $tempFile")
            }


            if($Using:scriptCommand -ne "") {
                Write-Verbose "Executing Script Command: $Using:scriptCommand"
                 &([scriptblock]::Create($Using:scriptCommand))
            }
            
        } -PSComputerName $computer
    }
}