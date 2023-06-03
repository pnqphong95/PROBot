#include-once

Global $CmdLineParams = ObjCreate("Scripting.Dictionary")

Func ProBot_ParseCmdLineParams(Const $CmdLine)
	If $CmdLine[0] > 0 Then
		For $i = 1 To $CmdLine[0]
			Local $paramPrefix = StringLeft($CmdLine[$i], 1)
			If $paramPrefix = "-" Then
				Local $paramName = StringTrimLeft($CmdLine[$i], 1)
				If $i + 1 <= $CmdLine[0] Then
					Local $nextParamPrefix = StringLeft($CmdLine[$i + 1], 1)
					If $nextParamPrefix <> "-" Then
						$CmdLineParams.Item($paramName) = $CmdLine[$i + 1]
					Else
						$CmdLineParams.Item($paramName) = ""
					EndIf
				Else
					$CmdLineParams.Item($paramName) = ""
				EndIf
			EndIf
		Next
	EndIf
	Local $log = "[CommandLine Params] "
	For $key In $CmdLineParams
		$log = $log & $key & "=" & $CmdLineParams.Item($key) & "; "
	Next
	ConsoleWrite($log & @CRLF)
EndFunc

Func ProBot_ValidateCmdLineParams()
	If Not $CmdLineParams.Exists("vf") Then
		ConsoleWriteError("[Bot] Aborted, param -vf must be present!" & @CRLF)
		Exit
	EndIf
	If Not FileExists($CmdLineParams.Item("vf")) Then
		ConsoleWriteError("[Bot] Aborted, given variable file " & $CmdLineParams.Item("vf") & " not exist!" & @CRLF)
		Exit
	EndIf
EndFunc
