#include-once
#include <MsgBoxConstants.au3>
#include "IniDictHelper.au3"

Global $BOT_SCRIPTING_PATH
Global $PROBotScripting = ObjCreate("Scripting.Dictionary")

Func setBotScriptingPath(Const $path)
    $BOT_SCRIPTING_PATH = $path
EndFunc

; Bot scripting, battle controller
; Used to automate action in the battle dialog 
Global Const $BOT_BATTLE_DESIRED_OPPONENT = "bot.battle.desired_opponent"
Global Const $BOT_BATTLE_DESIRED_MESSAGE = "bot.battle.desired_message"
Global Const $BOT_BATTLE_IGNORED_OPPONENT = "bot.battle.ignored_opponent"
Global Const $BOT_BATTLE_ACTION_EXIT = "bot.battle.action.exit"
Global Const $BOT_BATTLE_ACTION_SCRIPTING = "bot.battle.action.scripting"
$PROBotScripting.Add($BOT_BATTLE_DESIRED_OPPONENT, "")
$PROBotScripting.Add($BOT_BATTLE_DESIRED_MESSAGE, "")
$PROBotScripting.Add($BOT_BATTLE_IGNORED_OPPONENT, "")
$PROBotScripting.Add($BOT_BATTLE_ACTION_EXIT, "")
$PROBotScripting.Add($BOT_BATTLE_ACTION_SCRIPTING, "")

; Bot scripting, spawn controller
; Used to automate spawn
Global Const $BOT_SPAWN_START_DIRECTION = "bot.spawn.start_direction"
Global Const $BOT_SPAWN_SHORT_PRESS = "bot.spawn.short_press"
Global Const $BOT_SPAWN_LONG_PRESS = "bot.spawn.long_press"
$PROBotScripting.Add($BOT_SPAWN_START_DIRECTION, "LEFT")
$PROBotScripting.Add($BOT_SPAWN_SHORT_PRESS, 600)
$PROBotScripting.Add($BOT_SPAWN_LONG_PRESS, 1000)

Func initScripting()
    If $BOT_SCRIPTING_PATH = "" Then
        MsgBox($MB_SYSTEMMODAL, "Initializing Error", "$BOT_SCRIPTING_PATH is empty. Please set a value")
        Exit
    EndIf
    loadIniSection($PROBotScripting, $BOT_SCRIPTING_PATH, "Scriptings")
EndFunc

Func getBotScripting(Const $settingKey)
    Return $PROBotScripting.Item($settingKey)
EndFunc