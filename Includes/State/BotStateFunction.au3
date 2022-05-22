#include-once
#include "..\Constant\StateConstant.au3"
#include "GlobalStateObject.au3"
#include "UserScriptFunction.au3"

Func BotState_overwriteByUser(Const $UserScript)
    BotState_overwriteField($UserScript, $state_bot_enable_notification)
    BotState_overwriteField($UserScript, $state_bot_pokemon_review)
    BotState_overwriteField($UserScript, $state_bot_autoswap_usable)
    BotState_overwriteField($UserScript, $state_bot_battle_desired_opponent)
    BotState_overwriteField($UserScript, $state_bot_battle_ignored_opponent)
    BotState_overwriteField($UserScript, $state_bot_battle_desired_message)
    BotState_overwriteField($UserScript, $state_bot_spawn_start_direction)
    BotState_overwriteField($UserScript, $state_bot_spawn_short_press)
    BotState_overwriteField($UserScript, $state_bot_spawn_long_press)
EndFunc

Func BotState_overwriteField(Const $UserScript, Const $key)
    If $UserScript.Exists($key) Then
        Switch $UserScript.Item($key)
            Case "true", "True", "TRUE"
                $BotState.Item($key) = True        
            Case "false", "False", "FALSE"
                $BotState.Item($key) = False
            Case Else
                $BotState.Item($key) = $UserScript.Item($key)
        EndSwitch
    EndIf
EndFunc

Func BotState_setAutoSwapUsable(Const $bool)
    $BotState.Item($state_bot_autoswap_usable) = $bool
EndFunc

Func BotState_isAutoSwapUsable()
    Return $BotState.Item($state_bot_autoswap_usable)
EndFunc

Func BotState_setFirstLoad(Const $bool)
    $BotState.Item($state_bot_session_firstload) = $bool
EndFunc

Func BotState_isFirstLoad()
    Return $BotState.Item($state_bot_session_firstload)
EndFunc

Func BotState_setSessionScript(Const $value)
    $BotState.Item($state_bot_session_script) = $value
EndFunc

Func BotState_sessionScript()
    Return $BotState.Item($state_bot_session_script)
EndFunc

Func BotState_setScriptInUse(Const $bool)
    $BotState.Item($state_bot_session_script_inuse) = $bool
EndFunc

Func BotState_isScriptInUse()
    Return $BotState.Item($state_bot_session_script_inuse)
EndFunc

Func BotState_setReloadSessionScript(Const $bool = True)
    $BotState.Item($state_bot_session_script_attemp_reload) = $bool
EndFunc

Func BotState_isReloadSessionScript()
    Return $BotState.Item($state_bot_session_script_attemp_reload)
EndFunc

Func BotState_setSessionState(Const $state)
    $BotState.Item($state_bot_session_state) = $state
EndFunc

Func BotState_sessionState()
    Return $BotState.Item($state_bot_session_state)
EndFunc

Func BotState_isSessionRunning()
    Return BotState_sessionState() = "RUNNING"
EndFunc

Func BotState_isSessionStopped()
    Return BotState_sessionState() = "STOPPED"
EndFunc

Func BotState_setAttemptSessionState(Const $state)
    $BotState.Item($state_bot_session_state_attempt) = $state
EndFunc

Func BotState_attemptingSessionState()
    Return $BotState.Item($state_bot_session_state_attempt)
EndFunc

Func BotState_setNotificationEnable(Const $bool)
    $BotState.Item($state_bot_enable_notification) = $bool
EndFunc

Func BotState_isNotificationEnable()
    Return $BotState.Item($state_bot_enable_notification)
EndFunc

Func BotState_setPokemonPreviewEnable(Const $bool)
    $BotState.Item($state_bot_pokemon_review) = $bool
EndFunc

Func BotState_isPokemonPreviewEnable()
    Return $BotState.Item($state_bot_pokemon_review)
EndFunc

Func BotState_setLastSpawnDirection(Const $value)
    $BotState.Item($state_bot_spawn_last_direction) = $value
EndFunc

Func BotState_lastSpawnDirection()
    Return $BotState.Item($state_bot_spawn_last_direction)
EndFunc

Func BotState_setDesiredOpponent(Const $value)
    $BotState.Item($state_bot_battle_desired_opponent) = $value
EndFunc

Func BotState_desiredOpponent()
    Return $BotState.Item($state_bot_battle_desired_opponent)
EndFunc

Func BotState_setIgnoredOpponent(Const $value)
    $BotState.Item($state_bot_battle_ignored_opponent) = $value
EndFunc

Func BotState_ignoredOpponent()
    Return $BotState.Item($state_bot_battle_ignored_opponent)
EndFunc

Func BotState_setDesiredMessage(Const $value)
    $BotState.Item($state_bot_battle_desired_message) = $value
EndFunc

Func BotState_desiredMessage()
    Return $BotState.Item($state_bot_battle_desired_message)
EndFunc

Func BotState_setSpawnStartDirection(Const $value)
    $BotState.Item($state_bot_spawn_start_direction) = $value
EndFunc

Func BotState_spawnStartDirection()
    Return $BotState.Item($state_bot_spawn_start_direction)
EndFunc

Func BotState_setSpawnShortPress(Const $value)
    $BotState.Item($state_bot_spawn_short_press) = $value
EndFunc

Func BotState_spawnShortPress()
    Return $BotState.Item($state_bot_spawn_short_press)
EndFunc

Func BotState_setSpawnLongPress(Const $value)
    $BotState.Item($state_bot_spawn_long_press) = $value
EndFunc

Func BotState_spawnLongPress()
    Return $BotState.Item($state_bot_spawn_long_press)
EndFunc