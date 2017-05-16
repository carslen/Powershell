function get-RPAPPhash ([string[]]$Path) {
    foreach ($item in $Path) {
        $FileList = Get-ChildItem -Path $item -Recurse -Exclude "*.pdf" -File
        foreach ($file in $FileList) {
            $Name = $file.Name
            $Hash = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
            Write-Host -ForegroundColor Yellow ""$Name": " -NoNewline
            Write-Host  "$Hash"
        }
    }
}

