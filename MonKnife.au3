#include <Misc.au3>
#include <Array.au3>
#include "Includes\Storage\AppConstant.au3"
#include "Includes\Storage\AppSetting.au3"
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\WndHelper.au3"
#include "Includes\BattleControl.au3"
#include "BattleControlDispatcher.au3"
#include "SpawnControlDispatcher.au3"

Func mknBotStart()
	mknAppSettingInit(@ScriptDir & "\MonKnife.ini")
	mknBotSettingInit(@ScriptDir & "\Default-Bot.ini")
	Local $appTitle = mknAppSettingGet($APP_TITLE)
	While 1
		Local $app = mknGetApp($appTitle, True)
		mknBattleScreenDispatch($app)
		mknSpawnDirectionRelease()
		If mknStateGet($APP_IN_BATTLE) Then
			mknBattleRivalEvaluationDispatch()
			mknBattleHandler($app)
			ContinueLoop
		Else
			mknSpawnMoving()
		EndIf
	WEnd
EndFunc

mknBotStart()