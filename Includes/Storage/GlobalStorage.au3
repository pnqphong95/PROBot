#include-once
#include "Settings.au3"
#include <MsgBoxConstants.au3>

Global $BOT_SETTING_PATH
Func setBotSettingPath(Const $path)
    $BOT_SETTING_PATH = $path
EndFunc

Func initPROBotStorage()
    If $BOT_SETTING_PATH = "" Then
        MsgBox($MB_SYSTEMMODAL, "Initializing Error", "$BOT_SETTING_PATH is empty. Please set a value")
        Exit
    EndIf
    settingInit($BOT_SETTING_PATH)
EndFunc

