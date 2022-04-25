#include-once

Func activateWindow(Const $hnwd)
	If Not WinActive($hnwd) Then
		WinActivate($hnwd)
	EndIf
EndFunc