#include-once
#include <MsgBoxConstants.au3>

Global $PROBotSetting = ObjCreate("Scripting.Dictionary")

;~ Game client title
Global Const $CLIENT_TITLE = "client.title"
$PROBotSetting.Add($CLIENT_TITLE, "PROClient")


;~ Bot notification setting group
Global Const $BOT_NOTIFICATION_ENABLE = "bot.notification.enable"
Global Const $BOT_NOTIFICATION_TELEGRAM_CHAT_ID = "bot.notification.telegram.chatid"
Global Const $BOT_NOTIFICATION_TELEGRAM_BOT_TOKEN = "bot.notification.telegram.bottoken"
$PROBotSetting.Add($BOT_NOTIFICATION_ENABLE, 0)
$PROBotSetting.Add($BOT_NOTIFICATION_TELEGRAM_CHAT_ID, "")
$PROBotSetting.Add($BOT_NOTIFICATION_TELEGRAM_BOT_TOKEN, "")


;~ Game client, battle dialog topbar coordinator
;~ Used to check if the battle dialog displayed on the screen
Global Const $CLIENT_BATTLE_TOPBAR_X = "client.battle.topbar.x"
Global Const $CLIENT_BATTLE_TOPBAR_Y = "client.battle.topbar.y"
Global Const $CLIENT_BATTLE_TOPBAR_WIDTH = "client.battle.topbar.width"
Global Const $CLIENT_BATTLE_TOPBAR_HEIGHT = "client.battle.topbar.height"
Global Const $CLIENT_BATTLE_TOPBAR_COLOR = "client.battle.topbar.color"
$PROBotSetting.Add($CLIENT_BATTLE_TOPBAR_X, 380)
$PROBotSetting.Add($CLIENT_BATTLE_TOPBAR_Y, 155)
$PROBotSetting.Add($CLIENT_BATTLE_TOPBAR_WIDTH, 620)
$PROBotSetting.Add($CLIENT_BATTLE_TOPBAR_HEIGHT, 5)
$PROBotSetting.Add($CLIENT_BATTLE_TOPBAR_COLOR, "0x282528")


;~ Game client, battle title coordinator
;~ Used to scan the battle rival name
Global Const $CLIENT_BATTLE_TITLE_X = "client.battle.title.x"
Global Const $CLIENT_BATTLE_TITLE_Y = "client.battle.title.y"
Global Const $CLIENT_BATTLE_TITLE_WIDTH = "client.battle.title.width"
Global Const $CLIENT_BATTLE_TITLE_HEIGHT = "client.battle.title.height"
$PROBotSetting.Add($CLIENT_BATTLE_TITLE_X, 743)
$PROBotSetting.Add($CLIENT_BATTLE_TITLE_Y, 225)
$PROBotSetting.Add($CLIENT_BATTLE_TITLE_WIDTH, 350)
$PROBotSetting.Add($CLIENT_BATTLE_TITLE_HEIGHT, 38)


;~ Game client, battle actions state
;~ Used to check if can make action in the battle
Global Const $CLIENT_BATTLE_ACTION_X = "client.battle.action.x"
Global Const $CLIENT_BATTLE_ACTION_Y = "client.battle.action.y"
Global Const $CLIENT_BATTLE_ACTION_WIDTH = "client.battle.action.width"
Global Const $CLIENT_BATTLE_ACTION_HEIGHT = "client.battle.action.height"
Global Const $CLIENT_BATTLE_ACTION_COLOR = "client.battle.action.color"
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_X, 920)
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_Y, 575)
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_WIDTH, 2)
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_HEIGHT, 1)
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_COLOR, "0x8f8f8f")

Func settingSectionInit(Const $path, Const $section)
    If Not FileExists($path) Then
        ConsoleWrite($path & @CRLF & "File doesn't exist. Auto-create " & $section & " with default value!" & @CRLF)
        For $key In $PROBotSetting
            IniWrite($path, $section, $key, $PROBotSetting.Item($key))
        Next
        Return
    EndIf
    Local $settingSection = IniReadSection($path, $section)
    If @error Or $settingSection[0][0] = 0 Then
        ConsoleWrite($path & @CRLF & $section & " is corrupted or empty. Auto-create " & $section & " setting with default value!" & @CRLF)
        For $key In $PROBotSetting
            IniWrite($path, $section, $key, $PROBotSetting.Item($key))
        Next
        Return
    EndIf
    For $i = 1 To $settingSection[0][0]
        Local $key = $settingSection[$i][0]
        Local $overwrittenValue = $settingSection[$i][1]
        Local $oldValue = $PROBotSetting.Item($key)
        If $overwrittenValue <> "" And $overwrittenValue <> $oldValue Then
            Local $oldValue = $PROBotSetting.Item($key)
            $PROBotSetting.Item($key) = $overwrittenValue
            ConsoleWrite("Resolved [" & $section & "] " & $key & " = " & $overwrittenValue & @CRLF)
        Else
            ConsoleWrite("Resolved [" & $section & "] " & $key & " = " & $oldValue & @CRLF)
        EndIf
    Next
EndFunc

Func settingInit(Const $path)
    settingSectionInit($path, "BotSettings")
EndFunc

Func getBotSetting(Const $settingKey)
    Return $PROBotSetting.Item($settingKey)
EndFunc