#include-once
#include "..\Constant\StateConstant.au3"
#include "GlobalStateObject.au3"

Func BattleState_setOn(Const $bool)
    $BattleState.Item($state_client_battle_on) = $bool 
EndFunc

Func BattleState_isOn()
    Return $BattleState.Item($state_client_battle_on) 
EndFunc

Func BattleState_setBegin(Const $bool)
    $BattleState.Item($state_client_battle_begin) = $bool 
EndFunc

Func BattleState_isBegin()
    Return $BattleState.Item($state_client_battle_begin) 
EndFunc

Func BattleState_setEnd(Const $bool)
    $BattleState.Item($state_client_battle_end) = $bool 
EndFunc

Func BattleState_isEnd()
    Return $BattleState.Item($state_client_battle_end) 
EndFunc

Func BattleState_setTitle(Const $value)
    $BattleState.Item($state_client_battle_title) = $value
EndFunc

Func BattleState_title()
    Return $BattleState.Item($state_client_battle_title) 
EndFunc

Func BattleState_setTitleRaw(Const $value)
    $BattleState.Item($state_client_battle_title_raw) = $value 
EndFunc

Func BattleState_titleRaw()
    Return $BattleState.Item($state_client_battle_title_raw) 
EndFunc

Func BattleState_setDecision(Const $value)
    $BattleState.Item($state_client_battle_decision) = $value 
EndFunc

Func BattleState_setDecisionRunAway()
    BattleState_setDecision("RUN_AWAY")
EndFunc

Func BattleState_setDecisionOnHold()
    BattleState_setDecision("HOLD_ON")
EndFunc

Func BattleState_setDecisionActionChain()
    BattleState_setDecision("ACTION_CHAIN")
EndFunc

Func BattleState_decision()
    Return $BattleState.Item($state_client_battle_decision) 
EndFunc

Func BattleState_setActionReady(Const $bool)
    $BattleState.Item($state_client_battle_action_ready) = $bool 
EndFunc

Func BattleState_isActionReady()
    Return $BattleState.Item($state_client_battle_action_ready) 
EndFunc