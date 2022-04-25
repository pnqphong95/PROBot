#include-once

Func pro_NotifyPokemon(Const $pokemon)
    If $pokemon <> "" Then
        pro_SendMessage('Yayy! Found one ' & $pokemon)
    EndIf
EndFunc

Func pro_SendMessage(Const $message)
	If $message <> "" Then
		Local $chatId = ""
	    Local $botToken = ""
		If $chatId <> "" And $botToken <> "" Then
			pro_SendTelegramMessage($chatId, $botToken, $message, True)
		EndIf
	EndIf
EndFunc

Func pro_SendTelegramMessage(Const $chatId, Const $botToken, Const $message = "", Const $showPopup = False)
	Local $apiUrl = "https://api.telegram.org/bot" & $botToken & "/sendMessage"
	Local $header = "Content-Type: application/json"
	Local $disableNotification = 'true'
	If $showPopup Then
		$disableNotification = 'false'
	EndIf
	Local $body = '{ \"chat_id\": \"' & $chatId & '\", \"text\": \"' & $message & '\", \"disable_notification\": ' & $disableNotification & ' }'
	ShellExecute(@SystemDir & "\curl.exe", '-XPOST -H "' & $header & '" -d "' & $body & '" ' & $apiUrl, "", "", @SW_HIDE)
EndFunc