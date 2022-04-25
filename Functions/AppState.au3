#include-once
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include "ProConstant.au3"

Global $mknState = ObjCreate("Scripting.Dictionary")
; These variables is the state and will be modified while app run
$mknState.Add($APP_IN_BATTLE, False)
$mknState.Add($APP_BATTLE_BEGIN, False)
$mknState.Add($APP_BATTLE_END, False)
$mknState.Add($APP_BATTLE_TITLE, "")
$mknState.Add($APP_BATTLE_TITLE_RAWTEXT, "")
$mknState.Add($APP_BATTLE_DECISION, "RUN_AWAY")
$mknState.Add($APP_BATTLE_CONTROLLER_FREE, False)
$mknState.Add($APP_BATTLE_CONTROLLER_STATE, "")
$mknState.Add($APP_BATTLE_CONTROLLER_STATE_FIGHT, "")
$mknState.Add($APP_BATTLE_CONTROLLER_STATE_POKEMON, "")
$mknState.Add($APP_BATTLE_CONTROLLER_STATE_ITEM, "")
$mknState.Add($APP_BATTLE_OPPONENT_WISH, "")
$mknState.Add($APP_BATTLE_OPPONENT_SKIP, "")
$mknState.Add($APP_IN_SPAWN, False)
$mknState.Add($APP_SPAWN_LAST_DIRECTION, "")
$mknState.Add($APP_SPAWN_LAST_PRESS, 0)

Func mknStateGet(Const $key)
	Return $mknState.Item($key)
EndFunc

Func mknStateSet(Const $key, Const $value)
	$mknState.Item($key) = $value
EndFunc