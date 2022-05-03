#include-once
#include "Storage\AppConstant.au3"
#include "Storage\AppSetting.au3"
#include "Storage\BotSetting.au3"

Func mknNotifyPokemonActionChainProcessing(Const $pokemon)
    If $pokemon <> "" Then
        mknSendMessage($pokemon & " attacks! Action chain process..")
    EndIf
EndFunc

Func mknNotifyPokemonCaught(Const $pokemon)
    If $pokemon <> "" Then
        mknSendMessage("Gotcha! " & $pokemon & " caught.")
    EndIf
EndFunc

Func mknNotifyPokemonUncaught(Const $pokemon)
    If $pokemon <> "" Then
        mknSendMessage("Can not catch " & $pokemon & " automatically! Hold-on")
    EndIf
EndFunc

Func mknSendMessage(Const $message)
	Local $enable = mknAppSettingGet($APP_NOTIFICATION_ENABLE)
	Local $botEnable = mknBotSettingGet($APP_NOTIFICATION_ENABLE)
	If ($enable = 1 Or $botEnable = 1) And $message <> "" Then
		Local $chatId = mknAppSettingGet($APP_NOTIFICATION_TELEGRAM_CHAT_ID)
	    Local $botToken = mknAppSettingGet($APP_NOTIFICATION_TELEGRAM_BOT_TOKEN)
		If $chatId <> "" And $botToken <> "" Then
			mknTelegramSend($chatId, $botToken, $message, True)
		Else
			ConsoleWrite("[WARN] Chat ID and token is empty.")
		EndIf
	EndIf
EndFunc

Func mknTelegramSend(Const $chatId, Const $botToken, Const $message = "", Const $showPopup = False)
	Local $apiUrl = "https://api.telegram.org/bot" & $botToken & "/sendMessage"
	Local $header = "Content-Type: application/json"
	Local $disableNotification = 'true'
	If $showPopup Then
		$disableNotification = 'false'
	EndIf
	Local $body = '{ \"chat_id\": \"' & $chatId & '\", \"text\": \"' & $message & '\", \"disable_notification\": ' & $disableNotification & ' }'
	ShellExecute(@SystemDir & "\curl.exe", '-XPOST -H "' & $header & '" -d "' & $body & '" ' & $apiUrl, "", "", @SW_HIDE)
EndFunc