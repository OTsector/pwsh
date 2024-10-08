if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Output "error: you should run this script as Administrator"
	exit 1
}
$jsonFile = "$home\AppData\Roaming\Code\User\globalStorage\storage.json"
if (-Not (Test-Path -Path $jsonFile -PathType Leaf)) {
	$profile = Read-Host "error: profile name is not fount (may VScode is not installed at default location).`nenter your profile name"
} else {
	$profile = (Get-Content -Raw -Path $jsonFile | ConvertFrom-Json).userDataProfiles.name
}
if (-Not $profile) {
	$profile = Read-Host "error: profile name is not fount (it seems you are not using profile).`nenter your profile name"
}
$pathArray = @()
$valueArray = @()
(Get-Item -LiteralPath 'Registry::HKEY_CLASSES_ROOT').GetSubKeyNames()
	| ForEach-Object { "Registry::HKEY_CLASSES_ROOT\"+$_+"\shell\open\command" }
	| Select-String -Pattern 'VScode' -Raw 
	| ForEach-Object {
			if(((Get-ItemProperty -LiteralPath "$_" -ErrorAction SilentlyContinue).'(default)' -ne $null)) {
				$valueArray += (Get-ItemProperty -LiteralPath $_).'(default)'
				$pathArray += $_
			}
		}
foreach ($i in 0..($valueArray.Length -1 )) {
	if ($valueArray[$i].Substring($valueArray[$i].LastIndexOf('\') + 1) -eq 'Code.exe" "%1"') {
		$value = ($valueArray[$i]).ToString().Substring(0, ($valueArray[$i]).ToString().LastIndexOf('\')+1) + 'Code.exe" --profile ' + $profile + ' "%1"'
		$path=$pathArray[$i]; $valueName='(Default)'
		Set-ItemProperty -Path "$path" -Name '(Default)' -Value "$value"
		if($?) {
			Write-Output "=====START`nregistry value is changed`npath: $path;`nvalueName: $valueName;`nvalue: $value`npathArray: $($pathArray[$i])`n=======END`n"
		}
	}
}
$pathArray = @()
$valueArray = @()
(Get-Item -LiteralPath 'Registry::HKEY_USERS').GetSubKeyNames()
	| ForEach-Object { "Registry::HKEY_USERS\"+$_ }
	| ForEach-Object { $path=$_; ((Get-Item -LiteralPath ($_)).GetSubKeyNames())
	| ForEach-Object { $path+"\"+$_+"\shell\open\command" } }
	| Select-String -Pattern 'VScode' -Raw
	| ForEach-Object {
			if(((Get-ItemProperty -LiteralPath "$_" -ErrorAction SilentlyContinue).'(default)' -ne $null)) {
				$valueArray += (Get-ItemProperty -LiteralPath $_).'(default)'
				$pathArray += $_
			}
		}
foreach ($i in 0..($valueArray.Length -1 )) {
	if ($valueArray[$i].Substring($valueArray[$i].LastIndexOf('\') + 1) -eq 'Code.exe" "%1"') {
		$value = ($valueArray[$i]).ToString().Substring(0, ($valueArray[$i]).ToString().LastIndexOf('\')+1) + 'Code.exe" --profile ' + $profile + ' "%1"'
		$path=$pathArray[$i]; $valueName='(Default)'
		Set-ItemProperty -Path "$path" -Name '(Default)' -Value "$value"
		if($?) {
			Write-Output "=====START`nregistry value is changed`npath: $path;`nvalueName: $valueName;`nvalue: $value`npathArray: $($pathArray[$i])`n=======END`n"
		}
	}
}
$pathArray = @(
	'HKEY_CLASSES_ROOT\Applications\Code.exe\shell\open\command',
	'HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode\command',
	'HKEY_CLASSES_ROOT\Directory\shell\VSCode\command',
	'HKEY_CLASSES_ROOT\Drive\shell\VSCode\command',
	'HKEY_CLASSES_ROOT\tpl_auto_file\shell\open\command',
	'HKEY_CLASSES_ROOT\vscode\shell\open\command',
	'HKEY_CLASSES_ROOT\VSCodeSourceFile\shell\open',
	'HKEY_CLASSES_ROOT\VSCodeSourceFile\shell\open\command',
	'HKEY_CURRENT_USER\Software\Classes\*\shell\VSCode\command',
	'HKEY_CURRENT_USER\Software\Classes\vscode\shell\open\command'
)
foreach ($path in $pathArray) {
	if ((Test-Path $path) -and -not ((Get-ItemProperty -LiteralPath ('Registry::'+$path)).'(default)' -match '--profile '+ $profile)) {
		$value = ((Get-ItemProperty -LiteralPath ('Registry::'+$path)).'(default)' + ' --profile ' + $profile)
		Set-ItemProperty -Path ('registry::' + $path) -Name '(Default)' -Value $value
		if($?) {
			Write-Output "=====START`nregistry value is changed`npath: $path;`nvalueName: (Default);`nvalue: $value`n=======END`n"
		}
	}
}
exit 0
