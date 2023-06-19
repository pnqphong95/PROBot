#include-once
#include <Array.au3>
#include "HandlerHelper.au3"
#include "Functions\Constant.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoHunt(Const $hwnd)
	Local $sTargetPokemon = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
	ProBot_Log("Found pokemon " & $sTargetPokemon)

	ProBot_WaitActionReady($hwnd, 2, 30)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
		; When battle suddenly closed.
		ProBot_svSetNextAction("")
		Return
	EndIf
			
	If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		; When battle not ready after 30s
		ProBot_Log("Battle not ready after a while, please take action.")
		ProBot_Notify("Battle not ready after a while, please take action.", True)
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
		Return
	EndIf

	Local $sExpectedMessage = $SessionVariables.Item($LATEST_MESSAGE)
	If $sExpectedMessage <> "" Then
		Local $sLatestLog = ProBot_CaptureLatestLog($hwnd)
		If Not ProBot_TextAccepted($sLatestLog, $sExpectedMessage, True) Then
			; When target component doesn't have expected message
			; Using Trace ability to produce ability message.
			ProBot_Log(StringFormat("Target pokemon %d doesn't have expected message, actual=%s", $sTargetPokemon, $sLatestLog))
			ProBot_Notify(StringFormat("Target pokemon %d doesn't have expected message, actual=%s", $sTargetPokemon, $sLatestLog), True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY)
			Return
		EndIf
	EndIf
	
	Local $nUserManualCatch = $SessionVariables.Item($USER_MANUAL_CATCH)
	If $nUserManualCatch = 1 Then
		ProBot_Log(StringFormat("Please manual catch %s", $sTargetPokemon))
		ProBot_Notify(StringFormat("Please manual catch %s", $sTargetPokemon), True)
		Exit
	EndIf
	
	; Validate synchronize pokemon
	Local $nSyncer = $SessionVariables.Item($SYNC_POKEMON_SLOT_NUMBER)
	If Not $nSyncer Or Number($nSyncer) <> 1  Then
		ProBot_Log("Hunt without synchronize pokemon as lead.")
	EndIf

	; Validate false swiper pokemon
	Local $nFalseSwiper = $SessionVariables.Item($FALSE_SWIPE_POKEMON_SLOT_NUMBER)
	If Not $nFalseSwiper Or Number($nFalseSwiper) < 1 Or Number($nFalseSwiper) > 6 Then
		ProBot_Log("Hunt without false swiper pokemon in team.")
	EndIf

	If Not ProBot_IsAliveParty($hwnd, Number($nFalseSwiper) - 1) Then
		ProBot_Log("False swiper not alive, please take action.")
		ProBot_Notify("False swiper not alive, please take action.", True, ProBot_MakeScreenshot($hwnd))
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
		Return
	EndIf

	Local $aUsableMoves = ProBot_GetAndCacheUsableMoves($hwnd, $nFalseSwiper - 1)
	$aUsableMoves = _FilterMoves($aUsableMoves, "False Swipe")
	If UBound($aUsableMoves) < 1 Then
		ProBot_Log("False swipe is not an usable move, please take action.")
		ProBot_Notify("False swipe is not an usable move, please take action.", True)
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
		Return
	EndIf

	; Switch on pokemon false swiper
	Local $nFirstAliveParty = ProBot_GetFirstAliveParty($hwnd)
	If Number($nFirstAliveParty) <> Number($nFalseSwiper - 1) Then
		Local $pokemonKey = ProBot_KeyBinding($nFalseSwiper)
		ProBot_PressPokemonButton($pokemonKey)
	EndIf 

	ProBot_WaitActionReady($hwnd, 2, 30)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
		; When battle suddenly closed.
		ProBot_svSetNextAction("")
		Return
	EndIf
			
	If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		; When battle not ready after 30s
		ProBot_Log("Battle not ready after a while, please take action.")
		ProBot_Notify("Battle not ready after a while, please take action.", True)
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
		Return
	EndIf

	; Repeatly use false swipe until hp get low
	While ProBot_IsHighHp($hwnd)
		Local $moveName = $aUsableMoves[0][0]
		Local $movePoint = $aUsableMoves[0][1]
		ProBot_Log(StringFormat("Use move %s (%d)", $moveName, $movePoint))
		Local $moveKey = $aUsableMoves[0][2]
		ProBot_PressFightButton(ProBot_KeyBinding($moveKey))
		$aUsableMoves[0][1] = $movePoint - 1
		If $aUsableMoves[0][1] = 0 Then
			ProBot_Log("False swipe is not an usable move, please take action.")
			ProBot_Notify("False swipe is not an usable move, please take action.", True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
			Return
		EndIf

		ProBot_svSetPartyUsableMoves($aUsableMoves, $nFalseSwiper - 1)
		ProBot_WaitActionReady($hwnd, 2, 30)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; When battle suddenly closed.
			ProBot_MoveMouseIntoGameClient("PROClient")
			ProBot_Log(StringFormat("Pokemon %s got faint before throwing pokeball.", $sTargetPokemon))
			ProBot_Notify(StringFormat("Pokemon %s got faint before throwing pokeball.", $sTargetPokemon), True)
			ProBot_svSetNextAction("")
			ProBot_Log("")
			Return
		EndIf
				
		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			; When battle not ready after 30s
			ProBot_Log("Battle not ready after a while, please take action.")
			ProBot_Notify("Battle not ready after a while, please take action.", True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
			Return
		EndIf
	WEnd

	; Repeatly throwing pokeball until caught it or exceed limit
	Local $pokeballCounter = 0, $limitPokeball = 10
	While $pokeballCounter < $limitPokeball 
		Local $pokeballKey = ProBot_KeyBinding(1)
		ProBot_PressItemButton($pokeballKey)
		$pokeballCounter = $pokeballCounter + 1

		ProBot_WaitActionReady($hwnd, 2, 30)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; When battle suddenly closed.
			ProBot_MoveMouseIntoGameClient("PROClient")
			ProBot_Log(StringFormat("Congrats! Got new caught %s (%d pokeballs)", $sTargetPokemon, $pokeballCounter))
			ProBot_Notify(StringFormat("Congrats! Got new caught %s (%d pokeballs)", $sTargetPokemon, $pokeballCounter), True)
			ProBot_svSetNextAction("")
			Return
		EndIf
				
		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			; When battle not ready after 30s
			ProBot_Log("Battle not ready after a while, please take action.")
			ProBot_Notify("Battle not ready after a while, please take action.", True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
			Return
		EndIf

		If $pokeballCounter = $limitPokeball Then
			ProBot_Log(StringFormat("Reached limit pokeballs (%d) but still not caught.", $limitPokeball))
			ProBot_Notify(StringFormat("Reached limit pokeballs (%d) but still not caught.", $limitPokeball), True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
			Return
		EndIf
	WEnd
EndFunc

Func _FilterMoves(Const $aMoves, Const $sMoveList = "")
	; aMoves[name, point, key, id, type, power, accuracy, disabled_by_user]
	Local $result[0][8]
	If $sMoveList And $sMoveList <> "" Then
		For $i = 0 To UBound($aMoves) - 1
			If StringInStr($sMoveList, $aMoves[$i][0]) > 0 Then
				Local $item[1][8] = [[$aMoves[$i][0], $aMoves[$i][1], $aMoves[$i][2], $aMoves[$i][3], _
					$aMoves[$i][4], $aMoves[$i][5], $aMoves[$i][6], $aMoves[$i][7]]]
				_ArrayAdd($result, $item)
			EndIf 
		Next
	EndIf
	Return $result
EndFunc