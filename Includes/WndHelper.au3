#include-once
#include <MsgBoxConstants.au3>

Func activateWindow(Const $hnwd)
	If Not WinActive($hnwd) Then
		WinActivate($hnwd)
	EndIf
EndFunc

Func pbGetApp(Const $appTitle, Const $activate = False)
	Local $hnwds = WinList($appTitle)
	Local $instanceNum = $hnwds[0][0]
	If $instanceNum = 1 Then
		Local $appHnwd = $hnwds[1][1]
		activateWindow($appHnwd)
		Return $appHnwd
	EndIf
EndFunc