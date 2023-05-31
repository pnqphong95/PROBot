# PROBot
Pokemon Revolution Online Bot (PROBot), a tool used to automate actions of the game. Scan the screen periodly, extract the game data with OCR. With collected data, player easily to write script to simulate press key. Hence, the bot requires to install few 3rd softwares:  

- Tesseract OCR (Window version at [UB Mannheim](https://github.com/UB-Mannheim/tesseract/wiki))
- AutoIT (https://www.autoitscript.com/site/autoit/) 

## Usage
```bash
./Probot.exe -vf catch_magikarp.ini
```
## Sample script
```ini
# catch_magikarp.ini
[SessionVariables]
bot.session.battle.accepted-opponent=Magikarp ikarp Magi
bot.session.battle.rejected-opponent=
bot.session.battle.actions-on-accept=p.2|f.2|i.1|i.1|i.1
bot.session.spawn.direction=
bot.session.spawn.min=600
bot.session.spawn.max=900
```