# ObbyLegends

Jeu d'obby Roblox en 3 mondes de 50 niveaux (150 niveaux au total), avec
checkpoints, sauvegarde automatique, économie (Coins/Gems), boutiques,
auras, trails, pets, quêtes et récompenses quotidiennes.

Développement actuel : directement dans Roblox Studio (pas encore de Rojo).
Le dossier `src/` reflète l'organisation du jeu et sert de source de vérité
versionnée ; `default.project.json` est déjà prêt pour le jour où on branche
Rojo.

## Etat actuel : V0.1

- [x] Leaderstats (Stage, Coins, Gems)
- [x] Checkpoints (Monde 1, niveaux 1 à 10)
- [x] Sauvegarde automatique (DataStore)
- [x] HUD (généré par script)
- [x] Lobby (généré par script)
- [x] 10 premiers niveaux (générés par script)

Prochaines versions : voir la section "Roadmap" plus bas.

## Comment tester dans Roblox Studio (sans Rojo pour l'instant)

Chaque fichier `.lua` de `src/` correspond à une instance à créer dans
l'explorateur de Studio, au même chemin, avec le même contenu.

1. Ouvre ton jeu dans Roblox Studio.
2. Active **Model > Enable Studio Access to API Services** (nécessaire pour
   que DataStoreService fonctionne, même en test).
3. Crée les instances suivantes et colle le contenu du fichier correspondant :

| Fichier | Type d'instance | Emplacement dans Studio |
|---|---|---|
| `src/ReplicatedStorage/Modules/GameConfig.lua` | ModuleScript | `ReplicatedStorage > Modules > GameConfig` |
| `src/ServerScriptService/DataManager.lua` | ModuleScript | `ServerScriptService > DataManager` |
| `src/ServerScriptService/Main.server.lua` | Script | `ServerScriptService > Main` |
| `src/ServerScriptService/CheckpointService.server.lua` | Script | `ServerScriptService > CheckpointService` |
| `src/ServerScriptService/LevelBuilder.server.lua` | Script | `ServerScriptService > LevelBuilder` |
| `src/StarterPlayer/StarterPlayerScripts/HUDController.client.lua` | LocalScript | `StarterPlayer > StarterPlayerScripts > HUDController` |

Note : dans Studio, `Modules` est un Folder à créer dans `ReplicatedStorage`
(clic droit > Insert Object > Folder, renommer "Modules"), pareil pour
`StarterPlayerScripts` qui existe déjà par défaut sous `StarterPlayer`.

4. Appuie sur **Play**. Tu dois voir :
   - ton personnage apparaître sur la plateforme verte (Lobby) ;
   - un panneau "MONDE 1 - LES PLAINES" ;
   - une rangée de 10 plateformes avec une dalle dorée (checkpoint) sur
     chacune ;
   - le HUD en haut de l'écran affichant Stage / Coins / Gems ;
   - en touchant une dalle dorée : Stage et Coins qui augmentent.
5. Quitte le Play (Stop) puis relance : tes gains ne sont **pas** conservés
   en test local à moins de publier le jeu (DataStoreService ne persiste
   réellement qu'en jeu publié, ou via le mode "Studio API access" avec le
   même Place ID).

## Structure du projet

```
ObbyLegends/
├── README.md
├── .gitignore
├── default.project.json
└── src/
    ├── ReplicatedStorage/
    │   └── Modules/
    │       └── GameConfig.lua
    ├── ServerScriptService/
    │   ├── DataManager.lua
    │   ├── Main.server.lua
    │   ├── CheckpointService.server.lua
    │   └── LevelBuilder.server.lua
    ├── StarterGui/
    ├── StarterPlayer/
    │   └── StarterPlayerScripts/
    │       └── HUDController.client.lua
    └── Workspace/
```

## Roadmap

**V0.2**
- Les 40 niveaux suivants du Monde 1
- Système de téléportation (menu de sélection de niveau / raccourcis)
- Monde 2

**V0.3**
- Monde 3
- Boutique Coins
- Boutique Robux
- Auras
- Trails

**V0.4**
- Pets
- Coffres
- Quêtes
- Récompenses quotidiennes
- Classements mondiaux (OrderedDataStore)
