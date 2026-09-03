# HC TradeBoard 0.4.8

HC TradeBoard is a lightweight peer-synced market board for World of Warcraft 1.12.1. It has no central server: online clients exchange active listings and trade chains through a hidden custom chat channel named `TradeBoard`.

## Screenshots

| Browse and filter listings | Create and manage sale listings |
| --- | --- |
| ![Browse tab showing item, level, rarity, and trader filters](screenshots/browse.png) | ![My Listings tab showing the sale editor and active listings](screenshots/my-listings.png) |

| Build community trade chains | Find profession providers |
| --- | --- |
| ![Trade Chains tab showing the level 5 through 60 handoff path](screenshots/trade-chains.png) | ![Professions tab showing an online Alchemy provider](screenshots/professions.png) |

## Install

1. Copy the `HC-Tradeboard` folder into `World of Warcraft\Interface\AddOns\`.
2. Confirm the final path is `Interface\AddOns\HC-Tradeboard\HC-Tradeboard.toc`.
3. Start the 1.12.1 client and enable **HC TradeBoard** on the character-selection AddOns screen.
4. Log in. HC TradeBoard stays closed until you open it.

Use `/tb`, `/tradeboard`, or left-click the coin icon beside the minimap to hide or show it. Hold Ctrl and left-drag the coin to move it around the minimap.

Press **Esc** or the enlarged **X** button to close TradeBoard immediately, including during combat. Esc also closes the full window when one of TradeBoard's text fields has keyboard focus.

## Using it

- Open HC TradeBoard with `/tb`, `/tradeboard`, or the minimap coin.
- Opening HC TradeBoard automatically requests current peer data and repeats that request every minute while the window remains open. `/tb probe` and `/tb sync` remain available as diagnostic commands.
- With HC TradeBoard open, Shift-left-click a bag item to load it into **My Listings**. You can also drag it onto the sale slot or arm one normal bag click. HC TradeBoard never opens the bags automatically.
- A character can publish any number of active sale listings. Mouse-wheel the five-row **My Active Sales** view, then select one and click **Remove Selected** to withdraw it.
- In **Trade Chains**, use **List / Edit My Chain** to publish your chain or **Delete My Chain** to withdraw it.
- In **Professions**, use **List / Edit Mine** to publish services learned by the current character, including skill rank and an optional short note.
- The Professions tab includes the three guilds with the most distinct providers. Click a guild sigil to filter the service table; click it again to clear the filter.
- Press Enter to open normal chat, then Shift-left-click a listed item to insert its real item link.

## Features

- Browse, My Listings, Trade Chains, and Professions tabs.
- A classic minimap coin button for opening and closing HC TradeBoard.
- Search, category, rarity, trader-level, online, listing-type, and item-level filters.
- Simple Armor and Weapons subcategories without the full Auction House category tree.
- Toggle between Required Level and Item Level by clicking the level-type button.
- Click any table header to sort ascending or descending, including numeric unit-price sorting.
- Mouse-wheel scrolling over the result table.
- Hover a Browse result to see the normal WoW item-stat tooltip stacked above the HC TradeBoard listing summary.
- Item-stat tooltips pass raw `item:...` hyperlinks for compatibility with AtlasLoot tooltip hooks.
- Real bag-backed sale listings with quantity and gold/silver/copper unit pricing.
- Saved personal listings and a saved 12-slot level 5-60 trade chain.
- Peer discovery, sync requests, paced announcements, removals, periodic refreshes, and persistent offline caching.
- Listing broadcasts include the seller's current character level and item icon texture, with local item-cache refresh as a fallback.
- Offline listings remain available when **Online only** is unchecked, with dimmed rows and last-seen information.
- Peer-synced profession services with profession and guild filters, current skill rank, guild name, optional service notes, online/last-seen status, and direct whispering.
- Published profession rank changes are detected locally, debounced for 45 seconds, and coalesced so only professions whose rank changed are announced.
- Top-three guild provider cards count distinct characters and use a deterministic shared shield sigil derived from the guild name.
- Browse and Professions tables include Guild columns.
- The custom protocol channel is removed from the visible chat windows after joining.
- Visible network state and peer count in the HC TradeBoard status bar.
- Select a listing to open a whisper to its trader or request to add that trader to the friend list.
- The minimap-button position is saved between sessions.
- Combat-safe direct closing through Esc, the top-level X button, `/tb`, or the minimap coin.

## Current limitations

- Every player who wants to see or publish listings needs HC TradeBoard installed and must be able to join the same custom channel. Whether Horde and Alliance share that custom channel depends on the server implementation.
- Listings are an advertisement only. HC TradeBoard does not move items, money, or automate trades.
- Remote listings and profession services are cached locally and become offline after ten minutes without a refresh. They remain until an explicit withdrawal is received or the saved cache is cleared, so an undelivered withdrawal can leave an old offline advertisement visible.
- Guild names and rankings appear only for records broadcast by TradeBoard protocol clients 0.4.0 or newer; older peer versions remain compatible but have no guild field.
- The first live build publishes sale listings. Wanted-order creation is planned but not yet in the posting form.
