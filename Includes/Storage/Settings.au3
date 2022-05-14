#include-once
#include <MsgBoxConstants.au3>
#include "IniDictHelper.au3"

Global $BOT_SETTING_PATH
Global $PROBotSetting = ObjCreate("Scripting.Dictionary")

Func setBotSettingPath(Const $path)
    $BOT_SETTING_PATH = $path
EndFunc

;~ Bot notification setting group
Global Const $BOT_NOTIFICATION_TELEGRAM_CHAT_ID = "bot.notification.telegram.chatid"
Global Const $BOT_NOTIFICATION_TELEGRAM_BOT_TOKEN = "bot.notification.telegram.bottoken"
$PROBotSetting.Add($BOT_NOTIFICATION_TELEGRAM_CHAT_ID, "")
$PROBotSetting.Add($BOT_NOTIFICATION_TELEGRAM_BOT_TOKEN, "")


;~ Game client title
Global Const $CLIENT_TITLE = "client.title"
$PROBotSetting.Add($CLIENT_TITLE, "PROClient")


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


;~ Game client, keyboard setting
;~ Bot used to send correct key to game client
Global Const $CLIENT_BATTLE_ACTION_KEY = "client.battle.action.key"
Global Const $CLIENT_BATTLE_ACTION_KEY_1 = $CLIENT_BATTLE_ACTION_KEY & ".1"
Global Const $CLIENT_BATTLE_ACTION_KEY_2 = $CLIENT_BATTLE_ACTION_KEY & ".2"
Global Const $CLIENT_BATTLE_ACTION_KEY_3 = $CLIENT_BATTLE_ACTION_KEY & ".3"
Global Const $CLIENT_BATTLE_ACTION_KEY_4 = $CLIENT_BATTLE_ACTION_KEY & ".4"
Global Const $CLIENT_BATTLE_ACTION_KEY_5 = $CLIENT_BATTLE_ACTION_KEY & ".5"
Global Const $CLIENT_BATTLE_ACTION_KEY_6 = $CLIENT_BATTLE_ACTION_KEY & ".6"
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_1, "Z")
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_2, "X")
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_3, "C")
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_4, "V")
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_5, "B")
$PROBotSetting.Add($CLIENT_BATTLE_ACTION_KEY_6, "N")

Func initSetting()
    If $BOT_SETTING_PATH = "" Then
        MsgBox($MB_SYSTEMMODAL, "Initializing Error", "$BOT_SETTING_PATH is empty. Please set a value")
        Exit
    EndIf
    loadIniSection($PROBotSetting, $BOT_SETTING_PATH, "BotSettings")
EndFunc

Func getBotSetting(Const $settingKey)
    Return $PROBotSetting.Item($settingKey)
EndFunc