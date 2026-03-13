# Agent Guide - Flash Cards Project

This guide is intended for AI agents to quickly understand the project structure, logic, and environment constraints.

## Project Overview
**Flash Cards** is a HarmonyOS wearable application for learning foreign words.
- **Tech Stack**: ArkTS, ArkUI (HarmonyOS SDK 6.0.0)
- **Build System**: hvigor (Requires `hvigorfile.ts` and `build-profile.json5`)
- **Package Manager**: ohpm (Uses `oh-package.json5`)

## Directory Structure
- `AppScope/`: Global application configurations.
- `entry/`: Main application module.
    - `src/main/ets/`: Source code.
        - `common/`: Shared utilities (e.g., `DatabaseManager.ets`).
        - `components/`: UI components following Atomic Design.
            - `atoms/`, `molecules/`, `organisms/`, `templates/`
        - `models/`: Data models (`WordData.ets`, `WordList.ets`).
        - `pages/`: Application pages (`Index.ets`, `FlashCardsPage.ets`).
    - `src/main/resources/`: Resources.
        - `rawfile/wordLists/`: JSON files containing word data.

## Environment Constraints
- **Missing Tools**: Standard HarmonyOS CLI tools like `ohpm` and `hvigor` are NOT currently in the PATH.
- **Initialization**: Project "initialization" usually involves `ohpm install`, but since it's missing, treat the environment as pre-initialized or manual. Do not attempt to install these tools unless specifically instructed.

## Core Logic & Data
### 1. Persistence (RDB)
- **Location**: `entry/src/main/ets/common/DatabaseManager.ets`
- **Database**: `WordLists.db`
- **Schema**:
    - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
    - `article`: TEXT (e.g., "der", "die", "das")
    - `word`: TEXT NOT NULL
    - `meaning`: TEXT (translation)
    - `example`: TEXT (example sentence)
    - `learned`: INTEGER (0 for false, 1 for true)

### 2. Word Loading
Words are imported from JSON files in `entry/src/main/resources/rawfile/wordLists/` when a word list is first selected in `Index.ets`.

### 3. Random Selection
`DatabaseManager.getRandomUnlearnedWord` uses a custom `doRand()` function based on `cryptoFramework.createRandom()` to select words that haven't been marked as learned.

## Component Hierarchy
- `Index.ets` (Page) -> Menu for list selection.
- `FlashCardsPage.ets` (Page) -> Main learning view.
    - `Cards.ets` (Template) -> Manages a stack of 3 `FlashCard` organisms.
        - `FlashCard.ets` (Organism) -> Individual card with flip and swipe logic.
            - `CardFront.ets` / `CardBack.ets` (Molecules)
            - `RectangularText.ets` (Atom) -> "Got it" / "Study again" overlays.

## Future Tasks Tips
- When adding new words, update the JSON files in `rawfile/wordLists/`.
- UI changes should respect the Atomic Design structure in `components/`.
- Database changes require updating `getSQLCreateTableString` and potentially incrementing `DB_VERSION` (though migration logic is minimal).
