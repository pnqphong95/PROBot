#include-once

Global Const $BATTLE_INDICATOR_LEFT = "bot.battle.indicator.left"
Global Const $BATTLE_INDICATOR_TOP = "bot.battle.indicator.top"
Global Const $BATTLE_INDICATOR_RIGHT = "bot.battle.indicator.right"
Global Const $BATTLE_INDICATOR_BOTTOM = "bot.battle.indicator.bottom"
Global Const $BATTLE_INDICATOR_COLOR_HEX= "bot.battle.indicator.colorhex"
Global Const $ACTION_INDICATOR_LEFT = "bot.battle.action.indicator.left"
Global Const $ACTION_INDICATOR_TOP = "bot.battle.action.indicator.top"
Global Const $ACTION_INDICATOR_RIGHT = "bot.battle.action.indicator.right"
Global Const $ACTION_INDICATOR_BOTTOM = "bot.battle.action.indicator.bottom"
Global Const $ACTION_INDICATOR_COLOR_HEX= "bot.battle.action.indicator.colorhex"
Global Const $TITLE_INDICATOR_LEFT = "bot.battle.title.indicator.left"
Global Const $TITLE_INDICATOR_TOP = "bot.battle.title.indicator.top"
Global Const $TITLE_INDICATOR_RIGHT = "bot.battle.title.indicator.right"
Global Const $TITLE_INDICATOR_BOTTOM = "bot.battle.title.indicator.bottom"
Global Const $LOG_INDICATOR_LEFT = "bot.battle.log.indicator.left"
Global Const $LOG_INDICATOR_TOP = "bot.battle.log.indicator.top"
Global Const $LOG_INDICATOR_RIGHT = "bot.battle.log.indicator.right"
Global Const $LOG_INDICATOR_BOTTOM = "bot.battle.log.indicator.bottom"
Global Const $ACTION_KEY_1 = "bot.battle.action.keybinding1"
Global Const $ACTION_KEY_2 = "bot.battle.action.keybinding2"
Global Const $ACTION_KEY_3 = "bot.battle.action.keybinding3"
Global Const $ACTION_KEY_4 = "bot.battle.action.keybinding4"
Global Const $REPORT_BOT_URL = "bot.report.telegram-bot-url"
Global Const $REPORT_CHAT_ID = "bot.report.telegram-chat-id"
Global $Settings = ObjCreate("Scripting.Dictionary")

;Default battle indicator coordinators
$Settings.Item($BATTLE_INDICATOR_LEFT) = 360
$Settings.Item($BATTLE_INDICATOR_TOP) = 176
$Settings.Item($BATTLE_INDICATOR_RIGHT) = 1000
$Settings.Item($BATTLE_INDICATOR_BOTTOM) = 178
$Settings.Item($BATTLE_INDICATOR_COLOR_HEX) = 0x282528

;Default battle action indicator coordinators
$Settings.Item($ACTION_INDICATOR_LEFT) = 1020
$Settings.Item($ACTION_INDICATOR_TOP) = 595
$Settings.Item($ACTION_INDICATOR_RIGHT) = 1025
$Settings.Item($ACTION_INDICATOR_BOTTOM) = 596
$Settings.Item($ACTION_INDICATOR_COLOR_HEX) = 0x7F7F7F

;Default battle title indicator coordinators
$Settings.Item($TITLE_INDICATOR_LEFT) = 480
$Settings.Item($TITLE_INDICATOR_TOP) = 240
$Settings.Item($TITLE_INDICATOR_RIGHT) = 1180
$Settings.Item($TITLE_INDICATOR_BOTTOM) = 290

;Default battle log indicator coordinators
$Settings.Item($LOG_INDICATOR_LEFT) = 320
$Settings.Item($LOG_INDICATOR_TOP) = 900
$Settings.Item($LOG_INDICATOR_RIGHT) = 920
$Settings.Item($LOG_INDICATOR_BOTTOM) = 1000

;Default battle action key bindings
$Settings.Item($ACTION_KEY_1) = "Z"
$Settings.Item($ACTION_KEY_2) = "X"
$Settings.Item($ACTION_KEY_3) = "C"
$Settings.Item($ACTION_KEY_4) = "V"

;Default report channel
$Settings.Item($REPORT_BOT_URL) = ""
$Settings.Item($REPORT_CHAT_ID) = ""

Func ProBot_LoadExternalSettings(Const $file)
	If Not FileExists($file) Then
		ConsoleWrite("[Settings] Use default setting, external file not exist " & $file & @CRLF)
        For $key In $Settings
            IniWrite($file, "Settings", $key, $Settings.Item($key))
        Next
		Return
	EndIf
	Local $externalSettings = IniReadSection($file, "Settings")
	If @error Or $externalSettings[0][0] = 0 Then
		ConsoleWrite("[Settings] Use default setting, external file corrupted or empty " & $file & @CRLF)
        For $key In $Settings
			IniWrite($file, "Settings", $key, $Settings.Item($key))
        Next
		Return
	EndIf
	For $i = 1 To $externalSettings[0][0]
		Local $key = $externalSettings[$i][0]
		If $Settings.Exists($key) Then
			Local $newValue = $externalSettings[$i][1]
			Local $oldValue = $Settings.Item($key)
			$Settings.Item($key) = $newValue
		EndIf
	Next
	ConsoleWrite("[Settings] External setting loaded from " & $file & @CRLF)
EndFunc



