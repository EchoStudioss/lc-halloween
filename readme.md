# Features:
- **Group Creation System**: Players can form Trick or Treat groups, with options to invite other players.
- **Interaction with NPC**: A customizable NPC (Ped) acts as the group interaction point, offering the ability to start a group.
- **Looting System**: Players in a group can trick-or-treat at various locations and receive random loot, which is customizable in the configuration.
- **Target Integration**: The script uses `ox_target` for interaction

# Installation Guide:

### 1. Download and Install Dependencies:
Ensure you have the following resources installed on your FiveM server:

- [QBCore Framework/Qbox](https://docs.qbox.re/converting)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)

### 2. Add the Script Files:
Place the `client.lua`, `server.lua`, and `config.lua` files into a new folder in your resources directory (e.g., `lc-halloween`).

### 3. Configure the Script:
Open the `config.lua` file and customize the settings as needed. You can set the loot pool, NPC properties, and other options.

### 4. Add to Server Config:
In your `server.cfg`, add the following line to ensure the script is loaded:
```plaintext
ensure lc-halloween
