#include-once
#include "Session.au3"

Func ProBot_LoadSessionVarFile(Const $dir)
	If FileExists($dir) Then
		Local $sessionVars = IniReadSection($dir, "SessionVariables")
		If Not @error And $sessionVars[0][0] > 0 Then
			ConsoleWrite("[Variables] Start overriding.. File dir = " & $dir & @CRLF)
			For $i = 1 To $sessionVars[0][0]
				Local $key = $sessionVars[$i][0]
				Local $newValue = $sessionVars[$i][1]
				Local $oldValue = $SessionVariables.Item($key)
				ConsoleWrite("[Variables] " & $key & " is overrided by " & $oldValue & "," & $newValue & @CRLF)
				$SessionVariables.Item($key) = $newValue
			Next
		Else
			ConsoleWrite("[Variables] file is empty. File dir = " & $dir & @CRLF)
		EndIf
	Else
		ConsoleWrite("[Variables] file not exist. File dir = " & $dir & @CRLF)
	EndIf
EndFunc
