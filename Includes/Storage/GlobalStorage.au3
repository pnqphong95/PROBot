#include-once
#include "Settings.au3"
#include "Scripting.au3"
#include "BattleAutomateAction.au3"

Func initPROBotStorage()
    initSetting()
    initScripting()
    loadBattleAutomateAction(getBotScripting($BOT_BATTLE_ACTION_SCRIPTING))
EndFunc