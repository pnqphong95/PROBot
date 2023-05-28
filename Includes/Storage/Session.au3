#include-once
#include "SessionConstant.au3"

Global $SessionVariables = ObjCreate("Scripting.Dictionary")

; Static config from config file
$SessionVariables.Item($ACCEPTED_OPPONENT) = ""
$SessionVariables.Item($REJECTED_OPPONENT) = ""
$SessionVariables.Item($ACCEPTED_LOG) = ""
$SessionVariables.Item($SPAWN_INITIAL_DIRECTION) = "Left"
$SessionVariables.Item($SPAWN_MIN) = 600
$SessionVariables.Item($SPAWN_MAX) = 1000

; Runtime variables
$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = ""
$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = False
$SessionVariables.Item($RT_ON_BATTLE_START) = False
$SessionVariables.Item($RT_ON_BATTLE_STOP) = False
$SessionVariables.Item($RT_RAW_TEXT) = ""
$SessionVariables.Item($RT_RAW_LOG) = ""
$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ""
$SessionVariables.Item($RT_IS_ACTIONABLE) = False
$SessionVariables.Item($RT_ACTION) = ""

