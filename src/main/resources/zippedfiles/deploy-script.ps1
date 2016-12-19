$_TempPath = $($deployed.container.TempPath)
$_TargetPath = $($deployed.container.TargetPath)

function ExecuteDeployment()
{
	Write-Host "Target path: $_TargetPath" 

	# Call function to delete all previous files from temp folder
	DeleteTempFolder
	
	# Call function to copy all deployables to target directory
	ExtractAndCopyDeployables
}

function DeleteTempFolder
{
	PrintMessage "Deleting all files from temp folder..."
	if (Test-Path $_TempPath) 
	{
		Get-ChildItem -Path $_TempPath -Recurse | Remove-Item -Force -Recurse | Out-Null
		Remove-Item $_TempPath -Force | Out-Null
	}
	Write-Host "Done!"
}

function ExtractAndCopyDeployables
{
	PrintMessage "Extracting files to temp directory..."
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($deployed.file)
	$x = New-Item -Path $_TempPath -ItemType directory
	foreach($item in $zip.items()) 
	{
		Write-Host "Extracting new file $($item.name) to temp directory..."		
		$shell.Namespace($_TempPath).copyhere($item)		
	}
	Write-Host "Done!"

	PrintMessage "Extracting and copying new files to target directory..."	
	Get-ChildItem $_TempPath -Filter *.* | 
	Foreach-Object {	
		$fileName = Split-Path -Path $($_.FullName) -Leaf -Resolve
		$fileOnTempPath = $_TempPath + $fileName
		$fileOnTargetPath = $_TargetPath + $fileName		
		
		If (Test-Path $fileOnTargetPath)
		{
			Write-Host "Removing previous file $($fileName) from target directory..."
			Remove-Item $($fileOnTargetPath) -Force | Out-Null
		}

		Write-Host "Copying new file $($fileName) to target directory..."
		Copy-Item $fileOnTempPath -Destination $_TargetPath
		
		Write-Host "Done!"
		Write-Host ""
	}
	Write-Host "-----------------------------------------------------------------------------------------------------"
}

function PrintMessage($message)
{
	Write-Host "-----------------------------------------------------------------------------------------------------"
	Write-Host "---- $message"	
}

ExecuteDeployment