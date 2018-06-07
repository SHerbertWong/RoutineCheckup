
Function Start-RoutineCheckupBootstrapping
{
	Param
	(
		[Parameter(Mandatory = $TRUE, Position = 0)]
		[String] $RootPath,
		[Parameter(Mandatory = $FALSE)]
		[String] $WgetPath = "wget.exe"
	)

	$PkgDirName = "Packages"
	$PkgDirPath = Join-Path -Path $RootPath -ChildPath $PkgDirName

	$InfoZipDirName = "InfoZip"
	$InfoZipUnzipName = "Unzip.exe"
	$InfoZipDirPath = Join-Path -Path $RootPath -ChildPath $InfoZipDirName
	$InfoZipUnzipPath = Join-Path -Path $InfoZipDirPath -ChildPath $InfoZipUnzipName

	$Packages = `
			(
				[PSCustomObject]`
				@{
					Name = "unz600xn"
					Caption = "InfoZip utility package"
					FileName = "unz600xn.exe"
					Uri = "https://onedrive.live.com/download?resid=63B88D4120E75E9C!1273&authkey=!AHndM7a-w2fxFRs"
					ExtractionCommand = '& (Join-Path -Path $PkgDirPath -ChildPath $_.FileName) -d $InfoZipDirPath 2>&1'
				}
			), `
			(
				[PSCustomObject]`
				@{
					Name = "PSNtStatus"
					Caption = "PowerShell NTSTATUS module package"
					FileName = "PSNtStatus-1.0.zip"
					Uri = "https://github.com/SHerbertWong/PSNtStatus/archive/1.0.zip"
					ExtractionCommand = '& $InfoZipUnzipPath -j (Join-Path -Path $PkgDirPath -ChildPath $_.FileName) -d (Join-Path -Path $RootPath -ChildPath $_.Name) 2>&1'
				}
			), `
			(
				[PSCustomObject]`
				@{
					Name = "PSNtObjectManager"
					Caption = "PowerShell NT Object Manager module package"
					FileName = "PSNtObjectManager-1.0.zip"
					Uri = "https://github.com/SHerbertWong/PSNtObjectManager/archive/1.0.zip"
					ExtractionCommand = '& $InfoZipUnzipPath -j (Join-Path -Path $PkgDirPath -ChildPath $_.FileName) -d (Join-Path -Path $RootPath -ChildPath $_.Name) 2>&1'
				}
			), `
			(
				[PSCustomObject]`
				@{
					Name = "PSRoutineCheckup"
					Caption = "PowerShell Windows Desktop Routine Check-Up module package"
					FileName = "PSRoutineCheckup-1.0.zip"
					Uri = "https://github.com/SHerbertWong/PSRoutineCheckup/archive/1.0.zip"
					ExtractionCommand = '& $InfoZipUnzipPath -j (Join-Path -Path $PkgDirPath -ChildPath $_.FileName) -d (Join-Path -Path $RootPath -ChildPath $_.Name) 2>&1'
					ExecutionCommand = 'Import-Module (Join-Path -Path $RootPath -ChildPath $_.Name); Start-RoutineCheckup'
				}
			)

	# Create "root" directory
	New-Item -Path $RootPath -ItemType Container -Force -ErrorAction Stop > $NULL

	# Create package directory
	New-Item -Path $PkgDirPath -ItemType Container -Force -ErrorAction Stop > $NULL

	# Create InfoZip utility directory
	New-Item -Path $InfoZipDirPath -ItemType Container -Force -ErrorAction Stop > $NULL

	# Download and extract packages
	$Packages | ForEach-Object `
	{
		Write-Host -Object "Downloading " -NoNewline
		Write-Host -Object $_.Caption -NoNewline -ForegroundColor Cyan
		Write-Host -Object " (" -NoNewline
		Write-Host -Object $_.FileName -NoNewline -ForegroundColor Cyan
		Write-Host -Object ")... "
		& $WgetPath --no-check-certificate -O (Join-Path -Path $PkgDirPath -ChildPath $_.FileName) $_.Uri
		if ($LASTEXITCODE -ne 0)
		{
			break
		}

		if (-not ([Object]::ReferenceEquals($NULL, $_.ExtractionCommand)))
		{
			Write-Host -Object "Extracting " -NoNewline
			Write-Host -Object $_.Caption -NoNewline -ForegroundColor Cyan
			Write-Host -Object "... " -NoNewline
			$ErrorMessage = Invoke-Expression -Command $_.ExtractionCommand
			if ($LASTEXITCODE -ne 0)
			{
				Write-Host -Object "Failed." -ForegroundColor Red
				throw $ErrorMessage
			}
			Write-Host -Object "Done." -ForegroundColor Green > $NULL
		}
		
		if (-not ([Object]::ReferenceEquals($NULL, $_.ExecutionCommand)))
		{
			Write-Host -Object "Launching " -NoNewline
			Write-Host -Object $_.Caption -NoNewline -ForegroundColor Cyan
			Write-Host -Object "... "	
			Invoke-Expression -Command $_.ExecutionCommand 
		}
	}
}
