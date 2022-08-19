# Pokémon MMORPG Bot (_Deprecated_)
Script for effortlessly hunting Pokémon in MMORPG game.  
Automate action by AutoIT and extract game data with optical character recognition (Tesseract)
## Game Plays
The game is about Ash adventures through multiple regions, from Kanto, Johto to Hoenn and Sinnoh. During the journey, there will be spots on the screen where the main character run back-and-forth to randomly meet a pokemon. That process is not easy, especially for extremely rare or shiny pokemon, the chance to meet them about 1/8192 so we really need __much effort to run back-and-forth several rounds__.  But never give up, we won't be able to imagine the feeling of catching a special pokemon.  
  
Once we meet any pokemon, we have to __make the decision between fight it, catch it or run away__. This also take much time to do it manually. 
  
## Minimize Effort Spending
Depend on how you enjoy the game. But for me, I'm interested in pokemon battle only, so just simply think the way to `have pokemon effortless prior to do battling`.

### Run back-and-forth automatically.
AutoIt provide all needed functions to interact with Keyboard. The bot will press and hold key `left`, `right`, `up`, `down` with a random duration. This function help to reduce a lot of time just staying in front of machine, pressing the key.
https://github.com/pnqphong95/Pokemon-MMORPG-Bot/blob/b7c256930f8c52df6bf0e2edad93ca61b112d229/Includes/Entrypoint.au3#L93-L120

### Recognize desired pokemon and perform proper action.
There are few options to tweak a Unity game in client-server model but since the game client and communication packet client-server are encrypted. So making bot able to see/recognize the content on screen is only possible solution. In this case, I used Tesseract OCR.
https://github.com/pnqphong95/Pokemon-MMORPG-Bot/blob/b7c256930f8c52df6bf0e2edad93ca61b112d229/Includes/Battle/BattleControl.au3#L44-L64

This will capture a pre-defined area on the screen and extract the text using OCR method.  
The text is a pokemon name, then evaluate if it's desired one. If yes, we fill the the key to perform needed action.  
If not desired one, the bot will automatically send key to run away of battle to continue `run back-and-forth`.

![PROBot Main screen](Extras/main.png)

## Warning
I was caught by the game master before I catch enough pokémon for battling :).  
Publish this project for sharing my inspiration on optimizing the effort.
