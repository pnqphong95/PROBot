#include <Date.au3>
#include <Misc.au3>
#include <Array.au3>
#include <FileConstants.au3>
#include <TrayConstants.au3>
#include "Includes\Storage\AppConstant.au3"
#include "Includes\Storage\AppSetting.au3"
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\WndHelper.au3"
#include "Includes\BattleControl.au3"
#include "BattleControlDispatcher.au3"
#include "SpawnControlDispatcher.au3"
Global $BotPaused = True, $LogFile

mknInit()

Func mknInit()
	Opt("TrayMenuMode", 3)
	Opt("TrayOnEventMode", 1)
	Local $pauseControl = TrayCreateItem("Paused")
	TrayItemSetOnEvent($pauseControl, "mknBotStateSwitch")
	TrayCreateItem("")
	Local $exitControl = TrayCreateItem("Exit")
	TrayItemSetOnEvent($exitControl, "mknBotExit")
	TraySetState($TRAY_ICONSTATE_SHOW)
	While 1
		Sleep(5000)
		mknBotStart()
	WEnd
EndFunc

Func mknBotStart()
	$LogFile = FileOpen(@ScriptDir & "\Logs\Spawns_" & StringReplace(_NowCalcDate(), "/", "") & ".txt", $FO_APPEND)
	If Not $BotPaused Then
		mknSettingLoad()
		Local $appTitle = mknAppSettingGet($APP_TITLE)
		While Not $BotPaused
			Local $app = mknGetApp($appTitle, True)
			mknBattleScreenDispatch($app, $LogFile)
			mknSpawnDirectionRelease()
			If mknStateGet($APP_IN_BATTLE) Then
				mknBattleRivalEvaluationDispatch()
				mknBattleHandler($app)
				ContinueLoop
			Else
				mknSpawnMoving()
			EndIf
		WEnd
	EndIf
	FileClose($LogFile)
EndFunc

Func mknSettingLoad()
	mknAppSettingInit(@ScriptDir & "\MonKnife.ini")
	mknBotSettingInit(@ScriptDir & "\Default-Bot.ini")
	mknBotSettingParseActionChain()
EndFunc

Func mknBotStateSwitch()
	$BotPaused = Not $BotPaused
	If $BotPaused Then
		ConsoleWrite("[BOT] PAUSED ...")
	Else
		ConsoleWrite("[BOT] STARTING ...")
	EndIf
EndFunc

Func mknBotExit()
	Exit
EndFunc