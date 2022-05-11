#include <Date.au3>
#include <Misc.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <TrayConstants.au3>
#include "Includes\Storage\AppConstant.au3"
#include "Includes\Storage\GlobalStorage.au3"
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\WndHelper.au3"
#include "Includes\Battle\BattleControl.au3"
#include "Includes\Battle\BattleDispatcher.au3"
#include "SpawnDispatcher.au3"
Global $openScriptControl, $pauseControl
Global $BotPaused = True, $LogFile
Global $BotScript = @ScriptDir & "\Default-Bot.ini"

pbInit()

Func pbInit()
	Opt("TrayMenuMode", 3)
	Opt("TrayOnEventMode", 1)
	$pauseControl = TrayCreateItem("▶ BOT START")
	TrayItemSetOnEvent($pauseControl, "pbBotStateSwitch")
	$openScriptControl = TrayCreateItem($BotScript)
	TrayItemSetOnEvent($openScriptControl, "pbBotScriptOpen")
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
		Local $appTitle = getBotSetting($CLIENT_TITLE)
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
	setBotSettingPath(@ScriptDir & "\PROBot.ini")
	initPROBotStorage()
	pbBotSettingInit($BotScript)
	pbBotSettingParseActionChain()
EndFunc

Func pbBotStateSwitch()
	$BotPaused = Not $BotPaused
	If $BotPaused Then
		TrayItemSetText($pauseControl, "▶ BOT START")
		TrayItemSetState($openScriptControl, $TRAY_ENABLE)
	Else
		TrayItemSetText($pauseControl, "⏸ BOT PAUSE")
		TrayItemSetState($openScriptControl, $TRAY_DISABLE)
	EndIf
EndFunc

Func pbBotScriptOpen()
	If $BotPaused Then
		Const $dialogMessage = "Select script to be executed"
		Local $config = FileOpenDialog($dialogMessage, @ScriptDir & "\", "Bot configuration (*.ini)", $FD_FILEMUSTEXIST)
		If @error Then
			MsgBox($MB_SYSTEMMODAL, "", "No file was selected.")
			FileChangeDir(@ScriptDir)
		Else
			FileChangeDir(@ScriptDir)
			$BotScript = $config
			TrayItemSetText($openScriptControl, $BotScript)
		EndIf
	EndIf
EndFunc

Func pbBotExit()
	Exit
EndFunc