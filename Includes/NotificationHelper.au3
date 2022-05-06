#include-once
#include "Storage\AppConstant.au3"
#include "Storage\AppSetting.au3"
#include "Storage\BotSetting.au3"

Func pbNotifyPokemonActionChainProcessing(Const $pokemon)
    If $pokemon <> "" Then
        pbSendMessage($pokemon & " attacks! Action chain process..")
    EndIf
EndFunc

Func pbNotifyPokemonCaught(Const $pokemon, Const $photoPath = "")
    If $pokemon <> "" Then
        pbSendMessage("Gotcha! " & $pokemon & " caught.", $photoPath)
    EndIf
EndFunc

Func pbNotifyPokemonUncaught(Const $pokemon)
    If $pokemon <> "" Then
        pbSendMessage("Can not catch " & $pokemon & " automatically! Hold-on")
    EndIf
EndFunc

Func pbSendMessage(Const $message, Const $photo = "")
	Local $enable = pbAppSettingGet($APP_NOTIFICATION_ENABLE)
	Local $botEnable = pbBotSettingGet($APP_NOTIFICATION_ENABLE)
	If ($enable = 1 Or $botEnable = 1) And $message <> "" Then
		Local $chatId = pbAppSettingGet($APP_NOTIFICATION_TELEGRAM_CHAT_ID)
	    Local $botToken = pbAppSettingGet($APP_NOTIFICATION_TELEGRAM_BOT_TOKEN)
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