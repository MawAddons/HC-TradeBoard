# TradeBoard 0.3.3 live-network prototype

TradeBoard is a lightweight peer-synced market board for World of Warcraft 1.12.1. It has no central server: online clients exchange active listings and trade chains through a hidden custom chat channel named `TradeBoard`.

## Install

1. Copy the `TradeBoard` folder into `World of Warcraft\Interface\AddOns\`.
2. Confirm the final path is `Interface\AddOns\TradeBoard\TradeBoard.toc`.
3. Start the 1.12.1 client and enable **TradeBoard** on the character-selection AddOns screen.
4. Log in. TradeBoard stays closed until you open it.

Use `/tb`, `/tradeboard`, or left-click the coin icon beside the minimap to hide or show it. Hold Ctrl and left-drag the coin to move it around the minimap.

## Using it

- Open TradeBoard with `/tb`, `/tradeboard`, or the minimap coin.
- Use `/tb probe`, `/tb sync`, or the **Sync** button to re-run peer discovery and request current listings.
- With TradeBoard open, Shift-left-click a bag item to load it into **My Listings**. You can also drag it onto the sale slot or arm one normal bag click. TradeBoard never opens the bags automatically.
- A character can publish any number of active sale listings. Mouse-wheel the five-row **My Active Sales** view, then select one and click **Remove Selected** to withdraw it.
- In **Trade Chains**, use **List / Edit My Chain** to publish your chain or **Delete My Chain** to withdraw it.
- In **Professions**, use **List / Edit Mine** to publish services learned by the current character, including skill rank and an optional short note.
- Press Enter to open normal chat, then Shift-left-click a listed item to insert its real item link.

## Features

- Browse, My Listings, Trade Chains, and Professions tabs.
- A classic minimap coin button for opening and closing TradeBoard.
- Search, category, rarity, trader-level, online, listing-type, and item-level filters.
- Simple Armor and Weapons subcategories without the full Auction House category tree.
- Toggle between Required Level and Item Level by clicking the level-type button.
- Click any table header to sort ascending or descending, including numeric unit-price sorting.
- Mouse-wheel scrolling over the result table.
- Hover a Browse result to see the normal WoW item-stat tooltip stacked above the TradeBoard listing summary.
- Real bag-backed sale listings with quantity and gold/silver/copper unit pricing.
- Saved personal listings and a saved 12-slot level 5-60 trade chain.
- Peer discovery, sync requests, paced announcements, removals, periodic refreshes, and stale-peer expiry.
- Listing broadcasts include the seller's current character level and item icon texture, with local item-cache refresh as a fallback.
- Peer-synced profession services with profession filters, current skill rank, optional service notes, online status, and direct whispering.
- The custom protocol channel is removed from the visible chat windows after joining.
- Visible network state and peer count in the TradeBoard status bar.
- Select a listing to open a whisper to its trader or request to add that trader to the friend list.
- The minimap-button position is saved between sessions.

## Current limitations

- Every player who wants to see or publish listings needs TradeBoard installed and must be able to join the same custom channel. Whether Horde and Alliance share that custom channel depends on the server implementation.
- Listings are an advertisement only. TradeBoard does not move items, money, or automate trades.
- Only online/regularly refreshed peer data is retained; remote data expires after ten minutes without a refresh.
- The first live build publishes sale listings. Wanted-order creation is planned but not yet in the posting form.
