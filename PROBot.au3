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
#include "BattleDispatcher.au3"
#include "SpawnDispatcher.au3"
Global $BotPaused = True, $LogFile

pbInit()

Func pbInit()
	Opt("TrayMenuMode", 3)
	Opt("TrayOnEventMode", 1)
	Local $pauseControl = TrayCreateItem("Paused")
	TrayItemSetOnEvent($pauseControl, "pbBotStateSwitch")
	TrayCreateItem("")
	Local $exitControl = TrayCreateItem("Exit")
	TrayItemSetOnEvent($exitControl, "pbBotExit")
	TraySetState($TRAY_ICONSTATE_SHOW)
	While 1
		Sleep(5000)
		pbBotStart()
	WEnd
EndFunc

Func pbBotStart()
	$LogFile = FileOpen(@ScriptDir & "\Logs\Spawns_" & StringReplace(_NowCalcDate(), "/", "") & ".txt", $FO_APPEND)
	If Not $BotPaused Then
		pbSettingLoad()
		Local $appTitle = pbAppSettingGet($APP_TITLE)
		While Not $BotPaused
			Local $app = pbGetApp($appTitle, True)
			pbBattleScreenDispatch($app, $LogFile)
			pbSpawnDirectionRelease()
			If pbStateGet($APP_IN_BATTLE) Then
				pbBattleRivalEvaluationDispatch($app)
				pbBattleHandler($app)
				ContinueLoop
			Else
				pbSpawnMoving()
			EndIf
		WEnd
	EndIf
	FileClose($LogFile)
EndFunc

Func pbSettingLoad()
	pbAppSettingInit(@ScriptDir & "\PROBot.ini")
	pbBotSettingInit(@ScriptDir & "\Default-Bot.ini")
	pbBotSettingParseActionChain()
EndFunc

Func pbBotStateSwitch()
	$BotPaused = Not $BotPaused
	If $BotPaused Then
		ConsoleWrite("[BOT] PAUSED ...")
	Else
		ConsoleWrite("[BOT] STARTING ...")
	EndIf
EndFunc

Func pbBotExit()
	Exit
EndFunc