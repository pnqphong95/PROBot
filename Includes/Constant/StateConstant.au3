#include-once

;~ BattleState
Global Const $state_client_battle_action_ready = "client.battle.action.isready"
Global Const $state_client_battle_decision = "client.battle.decision"
Global Const $state_client_battle_title_raw = "client.battle.title.rawtext"
Global Const $state_client_battle_title = "client.battle.title"
Global Const $state_client_battle_begin = "client.battle.on.begin"
Global Const $state_client_battle_end = "client.battle.on.end"
Global Const $state_client_battle_on = "client.battle.on"

;~ SlotInfo
Global Const $state_client_slot_coorx = "client.slot.position.x"
Global Const $state_client_slot_coory = "client.slot.position.y"
Global Const $state_client_slot_usable_color = "client.slot.position.color.usable"
Global Const $state_client_slot_width = "client.slot.position.width"
Global Const $state_client_slot_height = "client.slot.position.height"

;~ SlotState
Global Const $state_client_slot_no_usable_move = "client.slot.no.usable.move"
Global Const $state_bot_battle_action_script = "bot.battle.action.scripting"

;~ BotState
Global Const $state_bot_enable_notification = "bot.notification.enable"
Global Const $state_bot_pokemon_review = "bot.notification.pokemon.preview" 
Global Const $state_bot_session_firstload = "bot.session.firstload"
Global Const $state_bot_session_script = "bot.session.script"
Global Const $state_bot_session_script_inuse = "bot.session.script.inuse"
Global Const $state_bot_session_script_attemp_reload = "bot.session.script.attempt.reload"
Global Const $state_bot_session_state = "bot.session.state"
Global Const $state_bot_session_state_attempt = "bot.session.state.attempt"
Global Const $state_bot_battle_desired_opponent = "bot.battle.opponent.desired"
Global Const $state_bot_battle_ignored_opponent = "bot.battle.opponent.ignored"
Global Const $state_bot_battle_desired_message = "bot.battle.message.desired"
Global Const $state_bot_spawn_last_direction = "bot.spawn.direction.last"
Global Const $state_bot_spawn_start_direction = "bot.spawn.direction.start"
Global Const $state_bot_spawn_short_press = "bot.spawn.press.short"
Global Const $state_bot_spawn_long_press = "bot.spawn.press.long"
Global Const $state_bot_autoswap_usable = "bot.autoswap.usable"

; BattleActionTypes
Global Const $CLIENT_BATTLE_ACTION_FIGHT = "f"
Global Const $CLIENT_BATTLE_ACTION_POKEMON = "p"
Global Const $CLIENT_BATTLE_ACTION_ITEM = "i"
Global Const $CLIENT_BATTLE_ACTION_SEPARATOR = "/"
Global Const $CLIENT_BATTLE_CHOICE_SEPARATOR = "@"