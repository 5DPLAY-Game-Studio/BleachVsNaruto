# Sets Animate Application.xml so Open-JSFL uses Run without prompting.
# Keys: DontPromptForJSFLOpen, RunJSFLAsCommand
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:APPDATA 'Adobe\Animate'
if (-not (Test-Path $root)) {
	exit 0
}

Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
	$f = Join-Path $_.FullName 'Application.xml'
	if (-not (Test-Path $f)) {
		return
	}

	$t = [IO.File]::ReadAllText($f)
	$n = $t

	$n = [regex]::Replace($n, '(?s)(<key>DontPromptForJSFLOpen</key>\s*)<false\s*/>', '${1}<true/>')
	if ($n -notmatch '<key>DontPromptForJSFLOpen</key>') {
		$insert = "<prop.pair>`r`n<key>DontPromptForJSFLOpen</key>`r`n<true/>`r`n</prop.pair>`r`n"
		$n = $n -replace '(?s)(</prop\.list>)', ($insert + '$1')
	}

	$n = [regex]::Replace($n, '(?s)(<key>RunJSFLAsCommand</key>\s*)<false\s*/>', '${1}<true/>')
	if ($n -notmatch '<key>RunJSFLAsCommand</key>') {
		$insert = "<prop.pair>`r`n<key>RunJSFLAsCommand</key>`r`n<true/>`r`n</prop.pair>`r`n"
		$n = $n -replace '(?s)(</prop\.list>)', ($insert + '$1')
	}

	if ($n -ne $t) {
		[IO.File]::WriteAllText($f, $n)
		Write-Host ("Updated JSFL prefs: " + $f)
	}
}
