#include-once
#include "..\Constant\ClientSetting.au3"
#include "..\State\GlobalStateFunction.au3"
#include "..\State\BotStateFunction.au3"

Func pbNotifyBattleClosed(Const $pokemon, Const $photoPath = "")
	If BotState_isNotificationEnable() Then
		pbSendMessage("[" & $pokemon & "] Battle successfully closed.", $photoPath)
	EndIf
EndFunc

Func talkToPlayer(Const $message)
	pbSendMessage($message)
EndFunc

Func pbSendMessage(Const $message, Const $photo = "")
	If $message <> "" Then
		Local $chatId = "-1001626967452"
	    Local $botToken = "5366195277:AAHpoLtN7QUO1Gm7ZbxtYnztGDqa-nwCI0s"
		If $photo <> "" And FileExists($photo) Then
			pbTelegramSendPhoto($chatId, $botToken, $photo, $message)
		Else
			pbTelegramSend($chatId, $botToken, $message, True)
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