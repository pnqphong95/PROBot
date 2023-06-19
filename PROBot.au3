#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_OutFile=Build\Probot.exe
#AutoIt3Wrapper_Icon=Metadata\Probot.ico

#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\SessionVariable.au3"
#include "Includes\Storage\CmdLineParam.au3"
#include "Includes\Functions\WinFunc.au3"
#include "Includes\Functions\Logger.au3"
#include "Includes\HandlerHelper.au3"
#include "Includes\RtSpawnHandler.au3"
#include "Includes\RtBattleHandler.au3"
#include "Includes\RtAutoLevelHandler.au3"
#include "Includes\RtAutoHuntHandler.au3"
#include "Includes\RtAutoRunAwayHandler.au3"

; Exit when another bot instance is running
If _Singleton(@ScriptName, 1) = 0 Then
    ProBot_Log("Aborted, close other instances and retry!")
	Exit
EndIf

Global Const $BOT_SETTING_FILE = @WorkingDir & "\Probot.ini"
Global Const $POKEMON_TYPE_CSV = @WorkingDir & "\GameData\pokemon_types.csv"
Global Const $TYPE_CHART_CSV = @WorkingDir & "\GameData\type_chart.csv"
Global Const $MOVE_CSV = @WorkingDir & "\GameData\moves.csv"

ProBot_LoadBotSettingFile($BOT_SETTING_FILE)
ProBot_LoadPokemonCsvDatabase()
ProBot_LoadCmdLineParams()
ProBot_LoadSessionVariables($CmdLineParams.Item("script"))
$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = TimerInit()

While 1
    Local $hwnd = ProBot_ClientWindow("PROClient", False)
	If Not $hwnd Or $hwnd = '' Then
		ProBot_Log("PENDING, waiting for PROClient get opened.")
        Sleep(10000)
	ElseIf Not ProBot_IsMouseHoverGameClient("PROClient") Then
        ProBot_ReleaseSpawnKey()
        ProBot_Log("PENDING, waiting for cursor place inside PROClient.")
        Sleep(5000)
	Else
		ProBot_CaptureGameState($hwnd)
		ProBot_ReleaseSpawnKey()
		If $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			ProBot_EvaluateBattleState($hwnd)
			ProBot_DelegateAutoBattleHandler($hwnd)
			ContinueLoop
		Else
			ProBot_DelegateOutBattleHandler($hwnd)
			ContinueLoop
		EndIf
	EndIf
WEnd

Func ProBot_DelegateAutoBattleHandler(Const $hwnd)
	Switch $SessionVariables.Item($RT_ACTION)
		Case $RT_ACTION_RUNAWAY
			ProBot_HandleAutoRunAway($hwnd)
		Case $RT_ACTION_AUTO_LEVEL
			ProBot_HandleAutoLevel($hwnd)
		Case $RT_ACTION_AUTO_HUNT
			ProBot_HandleAutoHunt($hwnd)
	EndSwitch
EndFunc

Func ProBot_DelegateOutBattleHandler(Const $hwnd)
	Local $hBattleEnd = $SessionVariables.Item($RT_LAST_BATTLE_END_TIME)
	If $hBattleEnd And TimerDiff($hBattleEnd) > 20000 Then
		$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = TimerInit()
		$SessionVariables.Item($RT_OUT_BATTLE_ACTION) = $RT_OUT_BATTLE_TIME_EXCEED
	EndIf

	Switch $SessionVariables.Item($RT_OUT_BATTLE_ACTION)
		Case $RT_OUT_BATTLE_SWAP_USABLE_LEAD
			ProBot_PromoteUsablePokemon($hwnd)
			$SessionVariables.Item($RT_OUT_BATTLE_ACTION) = ""
		Case $RT_OUT_BATTLE_TIME_EXCEED
			ProBot_CloseEvolveDialogIfAppeared($hwnd)
			$SessionVariables.Item($RT_OUT_BATTLE_ACTION) = ""
		Case Else
			ProBot_PressSpawnKey()
	EndSwitch
EndFunc

Func ProBot_LoadPokemonCsvDatabase()
	_btLoadPokemonTypeData($POKEMON_TYPE_CSV)
	_btLoadPokemonTypeChartData($TYPE_CHART_CSV)
	_btLoadPokemonMoves($MOVE_CSV)
EndFunc