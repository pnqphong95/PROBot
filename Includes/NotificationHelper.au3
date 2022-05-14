#include-once
#include "Storage\AppConstant.au3"
#include "Storage\GlobalStorage.au3"
#include "Storage\AppState.au3"

Func pbNotifyBattleClosed(Const $pokemon, Const $photoPath = "")
    If $pokemon <> "" And pbStateGet($BOT_NOTIFICATION_ENABLE) Then
		pbSendMessage("[" & $pokemon & "] Battle successfully closed.", $photoPath)
    EndIf
EndFunc

Func pbNotifyBattleNotClosed(Const $pokemon)
    If $pokemon <> "" And pbStateGet($BOT_NOTIFICATION_ENABLE) Then
        pbSendMessage("[" & $pokemon & "] Battle not closed yet!")
    EndIf
EndFunc

Func pbSendMessage(Const $message, Const $photo = "")
	If $message <> "" Then
		Local $chatId = getBotSetting($BOT_NOTIFICATION_TELEGRAM_CHAT_ID)
	    Local $botToken = getBotSetting($BOT_NOTIFICATION_TELEGRAM_BOT_TOKEN)
		If $chatId <> "" And $botToken <> "" Then
			If $photo <> "" And FileExists($photo) Then
				pbTelegramSendPhoto($chatId, $botToken, $photo, $message)
			Else
				pbTelegramSend($chatId, $botToken, $message, True)
			EndIf
		Else
			ConsoleWrite("[WARN] Chat ID and token is empty.")
		EndIf
	EndIf
EndFunc

Func pbTelegramSend(Const $chatId, Const $botToken, Const $message = "", Const $showPopup = False)
	Local $apiUrl = "https://api.telegram.org/bot" & $botToken & "/sendMessage"
	Local $header = "Content-Type: application/json"
	Local $disableNotification = 'true'
	If $showPopup Then
		$disableNotification = 'false'
	EndIf
	Local $body = '{ \"chat_id\": \"' & $chatId & '\", \"text\": \"' & $message & '\", \"disable_notification\": ' & $disableNotification & ' }'
	ShellExecute(@SystemDir & "\curl.exe", '-XPOST -H "' & $header & '" -d "' & $body & '" ' & $apiUrl, "", "", @SW_HIDE)
EndFunc

Func pbTelegramSendPhoto(Const $chatId, Const $botToken, Const $photoPath, Const $caption = "")
	Local $apiUrl = "https://api.telegram.org/bot" & $botToken & "/sendPhoto"
	Local $params =  '-F "photo=@' & $photoPath & '" -F "chat_id=\"' & $chatId & '\"" -F "caption=\"' & $caption & '\""'
	ShellExecute(@SystemDir & "\curl.exe", '-XPOST "' & $apiUrl & '" ' & $params, "", "", @SW_HIDE)
EndFunc