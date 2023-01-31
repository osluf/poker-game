# poker-game 🃏
A simple poker game (without UI).

- For running, just `./run`
- For testing, make sure to `bundle` (only `rspec` as dependency), then `bundle exec rspec .`

The game logic is separated in two main classes (that have proper documentation on top of each):
- `PokerMatch` - Which compares poker hands, using `PokerHand` methods (and includes the `poker.txt` file reading logic).
- `PokerHand`  - Which holds core logic (comparison, ranks, etc).

Run example (comparing hands from the `poker.txt` file:

```
› ./run
---
Player 1 wins: 376
Player 2 wins: 624
Draws: 0
---
```
