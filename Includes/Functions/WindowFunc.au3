#include-once

Func ProBot_ActivateWindow(Const $hwnd)
	If Not WinActive($hwnd) Then
		WinActivate($hwnd)
	EndIf
EndFunc

Func ProBot_ClientWindow(Const $title, Const $activate = True)
	Local $hwnds = WinList($title)
	Local $instanceNum = $hwnds[0][0]
	If $instanceNum = 1 Then
		Local $hwnd = $hwnds[1][1]
		If $activate Then
			ProBot_ActivateWindow($hwnd)
		EndIf
		Return $hwnd
	EndIf
EndFunc

Func ProBot_IsMouseHoverGameClient(Const $title) 
	Local $window = WinGetPos($title)
	Local $mouse = MouseGetPos()
	Return $mouse[0] > $window[0] And $mouse[0] < ($window[0] + $window[2]) And $mouse[1] > $window[1] And $mouse[1] < ($window[1] + $window[3]) 
EndFunc