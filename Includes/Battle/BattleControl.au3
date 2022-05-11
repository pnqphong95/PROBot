#cs ----------------------------------------------------------------------------

 NOTICE: To avoid complexity,
 Please don't use pbStateSet to dispatch state inside this script.
 Recommend: Only use pbStateSet inside *Dispatcher script.

#ce ----------------------------------------------------------------------------
#include-once
#include <File.au3>
#include <ScreenCapture.au3>
#include <StringConstants.au3>
#include "..\WndHelper.au3"
#include "..\Libs\Tesseract.au3"
#include "..\Storage\GlobalStorage.au3"
#include "..\Storage\BotSetting.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleIsDisplayed
 Description: Search if battle dialog is displayed on given window screen.
 Settings: Read settings coordinator x, y, width, height from PROBot.ini

#ce ----------------------------------------------------------------------------
Func pbBattleIsDisplayed($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $color = getBotSetting($CLIENT_BATTLE_TOPBAR_COLOR)
        Local $xCoor = getBotSetting($CLIENT_BATTLE_TOPBAR_X)
        Local $yCoor = getBotSetting($CLIENT_BATTLE_TOPBAR_Y)
        Local $width = getBotSetting($CLIENT_BATTLE_TOPBAR_WIDTH)
        Local $height = getBotSetting($CLIENT_BATTLE_TOPBAR_HEIGHT)
        Local $resultCoor = PixelSearch($xCoor, $yCoor, $xCoor + $width, $yCoor + $height, $color, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRivalGet
 Description: Get battle rival. e.g: Wild pokemon,..
 Settings: Read settings coordinator x, y, width, height from PROBot.ini

#ce ----------------------------------------------------------------------------
Func pbBattleRivalGet($hnwd)
	If IsHWnd($hnwd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Local $xCoor = getBotSetting($CLIENT_BATTLE_TITLE_X)
        Local $yCoor = getBotSetting($CLIENT_BATTLE_TITLE_Y)
        Local $width = getBotSetting($CLIENT_BATTLE_TITLE_WIDTH)
        Local $height = getBotSetting($CLIENT_BATTLE_TITLE_HEIGHT)
		Return _TesseractWinCapture(WinGetTitle($hnwd), "", 0, "", 1, 2, $xCoor, $yCoor, $xCoor + $width, $yCoor + $height, 0)
	EndIf
	Return ""
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleMessageGet
 Description: Get last battle message. e.g: ability now Marvel Scale,..
 Settings: Read settings coordinator x, y, width, height from PROBot.ini

#ce ----------------------------------------------------------------------------
Func pbBattleMessageGet($hnwd)
	If IsHWnd($hnwd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Local $xCoor = 350
        Local $yCoor = 910
        Local $width = 480
        Local $height = 60
		Return _TesseractWinCapture(WinGetTitle($hnwd), "", 0, "", 1, 2, $xCoor, $yCoor, $xCoor + $width, $yCoor + $height, 0)
	EndIf
	Return ""
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleWildPokemonNameExtract
 Description: Extract Pokemon name from Raw captured by pbBattleRivalGet

#ce ----------------------------------------------------------------------------
Func pbBattleWildPokemonNameExtract(Const $battleRivalName)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($battleRivalName, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $battleRivalName
	Else
		ConsoleWrite("[Rival] Raw: " & $stripText & @CRLF)
		Local $includeKeyword = StringRight($stripText, StringLen($stripText) - $keywordPosition + 1)
		Local $nonKeyword = StringRight($includeKeyword, StringLen($includeKeyword) - StringLen($keyword) - 1)
		Return $nonKeyword
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleControlable
 Description: Check if battle is able to receive input from PROBot
 Settings: Read settings coordinator x, y, width, height from PROBot.ini

#ce ----------------------------------------------------------------------------
Func pbBattleControlable($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $color = getBotSetting($CLIENT_BATTLE_ACTION_COLOR)
        Local $xCoor = getBotSetting($CLIENT_BATTLE_ACTION_X)
        Local $yCoor = getBotSetting($CLIENT_BATTLE_ACTION_Y)
        Local $width = getBotSetting($CLIENT_BATTLE_ACTION_WIDTH)
        Local $height = getBotSetting($CLIENT_BATTLE_ACTION_HEIGHT)
        Local $resultCoor = PixelSearch($xCoor, $yCoor, $xCoor + $width, $yCoor + $height, $color, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRivalQualified
 Description: Compare rival name with name in wishlist and skiplist.

#ce ----------------------------------------------------------------------------
Func pbBattleRivalQualified(Const $rivalName)
	If $rivalName = "" Then
		Return True
	EndIf
	Local $wishlist = pbBotSettingGet($APP_BATTLE_RIVAL_WISHLIST)
	Local $notIgnoreList = pbBotSettingGet($APP_BATTLE_RIVAL_IGNORELIST)
	If $wishlist = "" And $notIgnoreList = "" Then
		Return True
	EndIf
	Local $wish = StringInStr($wishlist, $rivalName)
	Local $notIgnore = Not StringInStr($notIgnoreList, $rivalName)
	If $wish Or ($notIgnore And $wishlist = "")  Then
		Return True
	EndIf
	Local $extractedWishList = StringSplit($wishlist, " ")
	For $i = 1 To $extractedWishList[0]
		Local $keywordInRivalName = StringInStr($rivalName, $extractedWishList[$i])
		If $keywordInRivalName Then
			Return True
		EndIf
	Next
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleLastMessageMatch
 Description: Compare last message with keyword in wish last message list.

#ce ----------------------------------------------------------------------------
Func pbBattleLastMessageMatch(Const $lastMsg)
	If $lastMsg = "" Then
		Return True
	EndIf
	Local $wishLastMsg = pbBotSettingGet($APP_BATTLE_RIVAL_WISHLASTMSG)
	If $wishLastMsg = "" Then
		Return True
	EndIf
	If StringInStr($wishLastMsg, $lastMsg) Then
		Return True
	EndIf
	Local $extractedWishList = StringSplit($wishLastMsg, " ")
	For $i = 1 To $extractedWishList[0]
		Local $keywordInList = StringInStr($lastMsg, $extractedWishList[$i])
		If $keywordInList Then
			Return True
		EndIf
	Next
	Return False
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattlePokePreview
 Description: Capture the pokemon preview dialog

#ce ----------------------------------------------------------------------------
Func pbBattlePokePreview(Const $app)
	Local $tempPreviewFile = _TempFile(@TempDir & "\", "proPreview_", ".jpg", Default)
	_ScreenCapture_CaptureWnd($tempPreviewFile, $app, 880, 260, 1300, 650)
	Return $tempPreviewFile
EndFunc