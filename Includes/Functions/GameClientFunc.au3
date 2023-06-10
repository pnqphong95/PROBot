#include-once
#include <StringConstants.au3>
#include <Array.au3>
#include <Math.au3>
#include "Logger.au3"

Func ProBot_PokemonExtractName(Const $rawText)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($rawText, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $rawText
	Else
		Local $includeKeyword = StringRight($stripText, StringLen($stripText) - $keywordPosition + 1)
		Local $nonKeyword = StringRight($includeKeyword, StringLen($includeKeyword) - StringLen($keyword) - 1)
		Return $nonKeyword
	EndIf
EndFunc

Func ProBot_TextAccepted(Const $input, Const $acceptTexts = "")
	If $acceptTexts = "" Then
		Return True
	EndIf
	If StringInStr($acceptTexts, $input) Then
		Return True
	EndIf
	Local $splitWords = StringSplit($acceptTexts, " ")
	For $i = 1 To $splitWords[0]
		If StringInStr($input, $splitWords[$i]) Then
			Return True
		EndIf
	Next
	Return False
EndFunc

Func ProBot_SendKey($key = '')
	If $key <> "" Then
		Send("{" & $key &" 1}")
		Sleep(Random(500, 1000, 1))
	EndIf
EndFunc

Func ProBot_PickEffectiveMove(Const $aTypeCharts, Const $aUsableMoves, Const $sType1 = "", Const $sType2 = "")
	Local $nArrayLenght= UBound($aUsableMoves)
	Local $nSelectedMove = Random(0, $nArrayLenght - 1, 1)
	Local $nSelectedMoveDamage = 0
	If $sType1 = "" Then
		; If opponent doesn't have type 1, skip all evaluations.
		Return $nSelectedMove
	EndIf 
	
	; aTypeCharts[chart_id, effectiveness]
	; aUsableMoves[name, point, key, id, type, power, accuracy]
	For $i = 0 To $nArrayLenght - 1
		If $aUsableMoves[$i][1] = 0 Then
			; If move point = 0, skip other evaluations.
			ContinueLoop
		EndIf

		; Lookup effectiveness of move against type 1
		Local $nEffectiveness = 0.5
		_ArrayDisplay($aTypeCharts)
		Local $nFoundType1 = _ArrayBinarySearch($aTypeCharts, StringLower($aUsableMoves[$i][4] & ";" & $sType1))
		If Not @error Then
			$nEffectiveness = Number($aTypeCharts[$nFoundType1][1])
		EndIf
		
		; If not effective against type 1, then verify against type 2
		If $sType2 <> "" Then
			Local $nFoundType2 = _ArrayBinarySearch($aTypeCharts, StringLower($aUsableMoves[$i][4] & ";" & $sType2))
			If Not @error Then
				Local $nType2Effectiveness = Number($aTypeCharts[$nFoundType2][1])
				If $nType2Effectiveness = 0 Then
					$nEffectiveness = 0
				ElseIf $nEffectiveness < $nType2Effectiveness Then
					$nEffectiveness = $nType2Effectiveness
				EndIf
			EndIf
		EndIf

		

		; Calculate damage based on effectiveness and power
		Local $nMovePower = Number($aUsableMoves[$i][5])
		Local $nCurrentMoveDamage = $nMovePower * $nEffectiveness
		If $nCurrentMoveDamage > $nSelectedMoveDamage Then
			$nSelectedMove = $i
			$nSelectedMoveDamage = $nCurrentMoveDamage
		EndIf
		
	Next
	ProBot_Log("Selected move --> " & $aUsableMoves[$nSelectedMove][0] & " (point = " & $aUsableMoves[$nSelectedMove][1] _
		& ", type = " & $aUsableMoves[$nSelectedMove][4] & ", damage = " & $nSelectedMoveDamage & ")")
	Return $nSelectedMove
EndFunc

Func ProBot_CreateUsableMoveArray(Const $aMoveData, Const $sPokemonMoveRaw, Const $sMovePointRaw)
	; aUsableMoves[name, point, key, id, type, power, accuracy]
	Local $aUsableMoves[0][7]
	Local $aPokemonMoves = StringSplit(StringStripWS($sPokemonMoveRaw, 7), @LF, 1)
	Local $aMovePoints = StringSplit(StringStripWS($sMovePointRaw, 7), @LF, 1)
	For $i = 1 To _Min($aPokemonMoves[0], $aMovePoints[0])
		Local $nPoint = Number(StringLeft($aMovePoints[$i], 2))
		If $nPoint > 0 Then
			Local $sMoveId = StringLower(StringReplace($aPokemonMoves[$i], " ", "-"))
			Local $nFoundMove = _ArrayBinarySearch($aMoveData, $sMoveId)
			If Not @error Then
				Local $item[1][7] = [[$aPokemonMoves[$i], $nPoint, $i, _
					$aMoveData[$nFoundMove][0], $aMoveData[$nFoundMove][1], _
					$aMoveData[$nFoundMove][2], $aMoveData[$nFoundMove][3]]]
				_ArrayAdd($aUsableMoves, $item)
			Else
				Local $item[1][3] = [[$aPokemonMoves[$i], $nPoint, $i]]
				_ArrayAdd($aUsableMoves, $item)
			EndIf
		EndIf
	Next
	Return $aUsableMoves
EndFunc

Func ProBot_LookupPokemonData(Const $aPokemonTypeData, Const $lookupName)
	Local $sIdentifier = StringLower(StringReplace($lookupName, " ", "-"))
	Local $nFoundPokemonType = _ArrayBinarySearch($aPokemonTypeData, $sIdentifier, 0, 0, 1)
	If Not @error Then
		Return $nFoundPokemonType
	EndIf
EndFunc