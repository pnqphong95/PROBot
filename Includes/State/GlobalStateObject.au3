#include-once
#include "..\Constant\ClientSetting.au3"
#include "..\Constant\StateConstant.au3"

Global $UserScriptPath
Global $UserScript = ObjCreate("Scripting.Dictionary")

;~ SlotInfo
Global $SlotInfo[6]
For $i = 0 To 5
    $SlotInfo[$i] = ObjCreate("Scripting.Dictionary")
    $SlotInfo[$i].Item($state_client_slot_coorx) = $CLIENT_TEAM_SLOT_X
    $SlotInfo[$i].Item($state_client_slot_coory) = $CLIENT_TEAM_FIRST_SLOT_Y + $CLIENT_TEAM_SLOT_MARGIN * $i
    $SlotInfo[$i].Item($state_client_slot_usable_color) = $CLIENT_TEAM_SLOT_USABLE_COLOR
    $SlotInfo[$i].Item($state_client_slot_width) = $CLIENT_TEAM_SLOT_USABLE_WIDTH
    $SlotInfo[$i].Item($state_client_slot_height) = $CLIENT_TEAM_SLOT_USABLE_HEIGHT
Next

;~ SlotState
Global $SlotState[6]
SlotState_initDefault()
Func SlotState_initDefault()
    For $i = 0 To 5
        $SlotState[$i] = ObjCreate("Scripting.Dictionary")
        $SlotState[$i].RemoveAll
        $SlotState[$i].Item($state_client_slot_no_usable_move) = False
        $SlotState[$i].Item($state_bot_battle_action_script) = ""
    Next
EndFunc


;~ SlotScript
Global $SlotScripting[6]
For $i = 0 To 5
    $SlotScripting[$i] = ObjCreate("Scripting.Dictionary")
Next


;~ BotState
Global $BotState = ObjCreate("Scripting.Dictionary")
$BotState.Item($state_bot_autoswap_usable) = False
$BotState.Item($state_bot_session_firstload) = True
$BotState.Item($state_bot_session_script) = ""
$BotState.Item($state_bot_session_script_inuse) = False
$BotState.Item($state_bot_session_script_attemp_reload) = False
$BotState.Item($state_bot_session_state) = "STOPPED"
$BotState.Item($state_bot_session_state_attempt) = ""
$BotState.Item($state_bot_enable_notification) = False
$BotState.Item($state_bot_pokemon_review) = False
$BotState.Item($state_bot_battle_desired_opponent) = ""
$BotState.Item($state_bot_battle_ignored_opponent) = ""
$BotState.Item($state_bot_battle_desired_message) = ""
$BotState.Item($state_bot_spawn_last_direction) = ""
$BotState.Item($state_bot_spawn_start_direction) = "LEFT"
$BotState.Item($state_bot_spawn_short_press) = 600
$BotState.Item($state_bot_spawn_long_press) = 1000

;~ BattleState
Global $BattleState = ObjCreate("Scripting.Dictionary")
$BattleState.Item($state_client_battle_on) = False
$BattleState.Item($state_client_battle_begin) = False
$BattleState.Item($state_client_battle_end) = False
$BattleState.Item($state_client_battle_title) = ""
$BattleState.Item($state_client_battle_title_raw) = ""
$BattleState.Item($state_client_battle_decision) = "RUN_AWAY"
$BattleState.Item($state_client_battle_action_ready) = False