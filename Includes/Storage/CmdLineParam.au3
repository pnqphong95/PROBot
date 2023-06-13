#include-once
#include "..\Storage\BotSetting.au3"
#include "..\Functions\Logger.au3"

Func ProBot_LoadCmdLineParams()
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
EndFunc
