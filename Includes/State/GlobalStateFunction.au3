#include-once
#include "GlobalStateObject.au3"
#include "UserScriptFunction.au3"
#include "BotStateFunction.au3"
#include "SlotStateFunction.au3"
#include "BattleStateFunction.au3"

Func GlobalState_init()
    UserScript_init()
    SlotState_resetAll()
    SlotState_fromUser($UserScript)
    BotState_overwriteByUser($UserScript)
EndFunc