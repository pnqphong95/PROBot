#include-once
#include "AppConstant.au3"
Global $pbState = ObjCreate("Scripting.Dictionary")

; Default initiated state
; =======================
$pbState.Add($APP_IN_BATTLE, False)
$pbState.Add($APP_BATTLE_BEGIN, False)
$pbState.Add($APP_BATTLE_END, False)
$pbState.Add($APP_BATTLE_TITLE, "")
$pbState.Add($APP_BATTLE_TITLE_RAWTEXT, "")
$pbState.Add($APP_BATTLE_DECISION, "RUN_AWAY")
$pbState.Add($APP_BATTLE_ACTION_START_STEP, 1)
$pbState.Add($APP_BATTLE_CONTROLLER_READY, False)
$pbState.Add($APP_BATTLE_CONTROLLER_STATE, "")
$pbState.Add($APP_BATTLE_CONTROLLER_STATE_FIGHT, "")
$pbState.Add($APP_BATTLE_CONTROLLER_STATE_POKEMON, "")
$pbState.Add($APP_BATTLE_CONTROLLER_STATE_ITEM, "")
$pbState.Add($APP_SPAWN_LAST_DIRECTION, "")

; Functions to handle app state
; =============================
#Region App state functions

Func pbStateGet(Const $key)
	Return $pbState.Item($key)
EndFunc

Func pbStateSet(Const $key, Const $value)
	$pbState.Item($key) = $value
EndFunc

#EndRegion