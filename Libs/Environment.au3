#include-once
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include "ProConstant.au3"

Global $PROEnv
$PROEnv = ObjCreate("Scripting.Dictionary")
$PROEnv.Add($APP_TITLE, "PROClient")
$PROEnv.Add($APP_IN_BATTLE, False)
$PROEnv.Add($APP_BATTLE_HOLD_ON_NOTIFICATION, False)
$PROEnv.Add($APP_BATTLE_BEGIN, False)
$PROEnv.Add($APP_BATTLE_END, False)
$PROEnv.Add($APP_BATTLE_TITLE, "")
$PROEnv.Add($APP_BATTLE_TITLE_RAWTEXT, "")
$PROEnv.Add($APP_BATTLE_DECISION, "RUN_AWAY")
$PROEnv.Add($APP_BATTLE_OPPONENT_WISH, "")
$PROEnv.Add($APP_BATTLE_OPPONENT_SKIP, "")
$PROEnv.Add($APP_IN_SPAWN, False)
$PROEnv.Add($APP_SPAWN_LAST_DIRECTION, "")
$PROEnv.Add($APP_SPAWN_LAST_PRESS, 0)

;; ====================================================================================
;; Environment variable functions
Func _getApp(Const $activate = False)
	Local $appTitle = _penv($APP_TITLE)
	Local $hnwds = WinList($appTitle)
	Local $instanceNum = $hnwds[0][0]
	If ($instanceNum > 1) Then
		MsgBox($MB_SYSTEMMODAL, "Error", "More than 1 instance of " & $appTitle &" is running. Please exit them.")
		Exit
	ElseIf ($instanceNum < 1) Then
		MsgBox($MB_SYSTEMMODAL, "Error", "Look like you didn't start " & $appTitle & " yet.")
		Exit
	Else
		Local $appHnwd = $hnwds[1][1]
		If $activate Then
			WinActivate($appHnwd)
		EndIf
		Return $appHnwd
	EndIf
EndFunc

Func _penv(Const $key)
	Return $PROEnv.Item($key)
EndFunc

Func _penvSet(Const $key, Const $value)
	$PROEnv.Item($key) = $value
EndFunc