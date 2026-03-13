# Flash Cards Project Notes

## Architecture
- **Language**: ArkTS / ArkUI
- **Framework**: HarmonyOS SDK 6.0.0
- **Build System**: hvigor (hvigorfile.ts, build-profile.json5)
- **Module Structure**:
    - `AppScope/`: App-wide configurations.
    - `entry/`: Main HAP module.
- **Component Design**: Atomic Design (Atoms, Molecules, Organisms, Templates).
    - Atoms: `CustomText`, `RectangularText`, `RemainingBox`
    - Molecules: `CardBack`, `CardFront`, `Word`
    - Organisms: `FlashCard`
    - Templates: `Cards`
- **Pages**:
    - `Index.ets`: Home page for selecting word lists.
    - `FlashCardsPage.ets`: Learning interface with cards.

## Data Management
- **Persistence**: Relational Database (RDB) via `@kit.ArkData`.
- **Database Name**: `WordLists.db` (Version 1).
- **Schema**:
    - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
    - `article`: TEXT
    - `word`: TEXT NOT NULL
    - `meaning`: TEXT
    - `example`: TEXT
    - `learned`: INTEGER (0 or 1)
- **Initial Load**: Word lists are imported from `entry/src/main/resources/rawfile/wordLists/*.json`.

## Key Logic
- **DatabaseManager.ets**: Handles RDB operations (create, insert, query, update).
- **Random Selection**: `getRandomUnlearnedWord` uses a custom random generator `doRand()` based on `cryptoFramework`.
- **Learning Flow**: Cards are swiped right (learned) or left (study again). Learning status is updated in RDB.

## Environment Observations
- `ohpm` and `hvigor` command-line tools are missing from the current environment's PATH.
- `package.json` was initially absent, and manually creating one was deemed unnecessary for the core project structure.
