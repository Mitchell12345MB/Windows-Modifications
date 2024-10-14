# Define paths
$isoPath = "C:\Path\To\Your\ISO\W7.Ultimate.September.2024.iso"
$extractedPath = "C:\Temp\W7ISO"
$driversPath = "C:\Temp\Drivers"
$newIsoPath = "C:\Path\To\Your\ISO\W7.Ultimate.Updated.iso"

# Full path to oscdimg executable
$oscdimgPath = "C:\Path\To\Oscdimg\oscdimg.exe"

# Full path to WinRAR executable
$winrarPath = "C:\Path\To\WinRAR\WinRAR.exe"

# Path to UEFI7 boot files
$uefi7Path = "C:\Path\To\UEFI7"

# Ensure directories exist
if (-Not (Test-Path $extractedPath)) {
    New-Item -ItemType Directory -Path $extractedPath
}
if (-Not (Test-Path $driversPath)) {
    New-Item -ItemType Directory -Path $driversPath
}

# Step 1: Extract the ISO
& "$winrarPath" x -ibck $isoPath $extractedPath

# Step 2: Export current drivers
Write-Host "Exporting drivers to $driversPath..."
Export-WindowsDriver -Online -Destination $driversPath
Write-Host "Driver export completed."

# Step 3: Integrate drivers into the Windows image
$wimPath = Join-Path -Path $extractedPath -ChildPath "sources\install.wim"

# Debugging output
Write-Host "Checking for install.wim at: $wimPath"

# Check if install.wim exists
if (-Not (Test-Path $wimPath)) {
    Write-Host "Error: install.wim not found at $wimPath"
    exit
}

$index = 1 # Assuming the first index, adjust if necessary

# Ensure mount directory exists
$mountPath = "C:\Temp\Mount"
if (-Not (Test-Path $mountPath)) {
    New-Item -ItemType Directory -Path $mountPath
}

# Mount the image
Mount-WindowsImage -ImagePath $wimPath -Index $index -Path $mountPath

# Add drivers
Add-WindowsDriver -Path $mountPath -Driver $driversPath -Recurse

# Commit changes and unmount
Dismount-WindowsImage -Path $mountPath -Save

# Step 4: Create UEFI boot structure
$efiBootPath = Join-Path -Path $extractedPath -ChildPath "EFI\BOOT"
if (-Not (Test-Path $efiBootPath)) {
    New-Item -ItemType Directory -Path $efiBootPath -Force
}

# Copy UEFI7 boot files to the EFI\BOOT directory
Copy-Item -Path "$uefi7Path\*" -Destination $efiBootPath -Recurse

# Step 5: Repackage the ISO using oscdimg with UEFI support
& "$oscdimgPath" -m -o -u2 -udfver102 -bootdata:2#p0,e,b"$extractedPath\boot\etfsboot.com"#pEF,e,b"$efiBootPath\bootx64.efi" $extractedPath $newIsoPath

# Cleanup temporary directories
Remove-Item -Path $extractedPath -Recurse -Force
Remove-Item -Path $driversPath -Recurse -Force
Remove-Item -Path $mountPath -Recurse -Force