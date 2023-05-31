#include-once
#include <StringConstants.au3>

Func ProBot_OpponentExtractText(Const $opponentRaw)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($opponentRaw, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $opponentRaw
	Else
		Local $includeKeyword = StringRight($stripText, StringLen($stripText) - $keywordPosition + 1)
		Local $nonKeyword = StringRight($includeKeyword, StringLen($includeKeyword) - StringLen($keyword) - 1)
		Return $nonKeyword
	EndIf
EndFunc

Func ProBot_IsOpponentQualified(Const $input, Const $acceptTexts = "", Const $rejectTexts = "")
	Return Not ProBot_TextRejected($input, $rejectTexts) And ProBot_TextAccepted($input, $acceptTexts)
EndFunc

Func ProBot_TextRejected(Const $input, Const $rejectTexts = "")
	If $rejectTexts = "" Then
		Return False
	EndIf
	If StringInStr($rejectTexts, $input) Then
		Return True
	EndIf
	Local $splitWords = StringSplit($rejectTexts, " ")
	For $i = 1 To $splitWords[0]
		If StringInStr($input, $splitWords[$i]) Then
			Return True
		EndIf
	Next
	Return False
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

Func ProBot_SendKeys($key1 = '', $key2 = '')
	If $key1 <> "" And $key2 <> "" Then
		Send("{" & $key1 &" 1}")
		Sleep(Random(500, 1000, 1))	
		Send("{" & $key2 &" 1}")
		Sleep(Random(500, 1000, 1))
	EndIf
EndFunc