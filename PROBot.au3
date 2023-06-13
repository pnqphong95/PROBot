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
#include "Includes\RtAutoRunAwayHandler.au3"

; Exit when another bot instance is running
If _Singleton(@ScriptName, 1) = 0 Then
    ProBot_Log("Aborted, close other instances and retry!")
	Exit
EndIf

ProBot_LoadExternalSettings(@WorkingDir & "\Probot.ini")
ProBot_LoadPokemonTypeData(@WorkingDir & "\GameData\pokemon_types.csv")
ProBot_LoadPokemonTypeChartData(@WorkingDir & "\GameData\type_chart.csv")
ProBot_LoadPokemonMoves(@WorkingDir & "\GameData\moves.csv")
ProBot_ParseCmdLineParams($CmdLine)
ProBot_ValidateCmdLineParams()
ProBot_LoadSessionVariables($CmdLineParams.Item("vf"))
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
			ProBot_EvaluateGameState($hwnd)
			ProBot_DelegateActionHandler($hwnd)
			$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = TimerInit()
			ContinueLoop
		Else
			Local $hBattleEnd = $SessionVariables.Item($RT_LAST_BATTLE_END_TIME)
			If $hBattleEnd And TimerDiff($hBattleEnd) > 20000 Then
				$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = TimerInit()
				ProBot_CloseEvolveDialogIfAppeared($hwnd)
			EndIf
			ProBot_PressSpawnKey()
		EndIf
	EndIf
WEnd

Func ProBot_DelegateActionHandler(Const $hwnd)
	Switch $SessionVariables.Item($RT_ACTION)
		Case $RT_ACTION_RUNAWAY
			ProBot_HandleAutoRunAway($hwnd)
		Case $RT_ACTION_AUTO_LEVEL
			ProBot_HandleAutoLevel($hwnd)
	EndSwitch
EndFunc