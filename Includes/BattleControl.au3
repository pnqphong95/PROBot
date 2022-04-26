#cs ---------------------------------------------------------------------------- 
 
 NOTICE: To avoid complexity, 
 Please don't use mknStateSet to dispatch state inside this script.
 Recommend: Only use mknStateSet inside *Dispatcher script.
 
#ce ----------------------------------------------------------------------------
#include-once
#include <StringConstants.au3>
#include "WndHelper.au3"
#include "Libs\Tesseract.au3"
#include "Storage\AppSetting.au3"
#include "Storage\AppState.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleIsDisplayed
 Description: Search if battle dialog is displayed on given window screen.
 Settings: Read settings coordinator x, y, width, height from MonKnife.ini

#ce ----------------------------------------------------------------------------
Func mknBattleIsDisplayed($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $color = mknAppSettingGet($APP_BATTLE_IDENTIFIER_COLOR)
        Local $xCoor = mknAppSettingGet($APP_BATTLE_IDENTIFIER_X)
        Local $yCoor = mknAppSettingGet($APP_BATTLE_IDENTIFIER_Y)
        Local $width = mknAppSettingGet($APP_BATTLE_IDENTIFIER_W)
        Local $height = mknAppSettingGet($APP_BATTLE_IDENTIFIER_H)
        Local $resultCoor = PixelSearch($xCoor, $yCoor, $xCoor + $width, $yCoor + $height, $color, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleRivalGet
 Description: Get battle rival. e.g: Wild pokemon,..
 Settings: Read settings coordinator x, y, width, height from MonKnife.ini

#ce ----------------------------------------------------------------------------
Func mknBattleRivalGet($hnwd)
	If IsHWnd($hnwd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Local $xCoor = mknAppSettingGet($APP_BATTLE_RIVAL_IDENTIFIER_X)
        Local $yCoor = mknAppSettingGet($APP_BATTLE_RIVAL_IDENTIFIER_Y)
        Local $width = mknAppSettingGet($APP_BATTLE_RIVAL_IDENTIFIER_W)
        Local $height = mknAppSettingGet($APP_BATTLE_RIVAL_IDENTIFIER_H)
		Return _TesseractWinCapture(WinGetTitle($hnwd), "", 0, "", 1, 2, $xCoor, $yCoor, $xCoor + $width, $yCoor + $height, 0)
	EndIf
	Return ""
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleWildPokemonNameExtract
 Description: Extract Pokemon name from Raw captured by mknBattleRivalGet

#ce ----------------------------------------------------------------------------
Func mknBattleWildPokemonNameExtract(Const $battleRivalName)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($battleRivalName, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $battleRivalName
	Else
		Return StringRight($stripText, StringLen($stripText) - ($keywordPosition + StringLen($keyword)))
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleControlable
 Description: Check if battle is able to receive input from MonKnife
 Settings: Read settings coordinator x, y, width, height from MonKnife.ini

#ce ----------------------------------------------------------------------------
Func mknBattleControlable($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $color = mknAppSettingGet($APP_BATTLE_CONTROLABLE_IDENTIFIER_COLOR)
        Local $xCoor = mknAppSettingGet($APP_BATTLE_CONTROLABLE_IDENTIFIER_X)
        Local $yCoor = mknAppSettingGet($APP_BATTLE_CONTROLABLE_IDENTIFIER_Y)
        Local $width = mknAppSettingGet($APP_BATTLE_CONTROLABLE_IDENTIFIER_W)
        Local $height = mknAppSettingGet($APP_BATTLE_CONTROLABLE_IDENTIFIER_H)
        Local $resultCoor = PixelSearch($xCoor, $yCoor, $xCoor + $width, $yCoor + $height, $color, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleRivalQualified
 Description: Compare rival name with name in wishlist and skiplist.

#ce ----------------------------------------------------------------------------
Func mknBattleRivalQualified(Const $rivalName)
	Local $wish = StringInStr(mknStateGet($APP_BATTLE_OPPONENT_WISH), $rivalName)
	; Local $notSkip = Not StringInStr(mknStateGet($APP_BATTLE_OPPONENT_SKIP, $name)
	; Temporarily set skip all if not wish
	Local $notSkip = False
	Return $rivalName = "" Or $wish Or $notSkip
EndFunc