# Caterpillar Life

A single-file browser game about the whole life of a caterpillar. You eat, you hide your
eggs, you pupate behind guns, you fly as a butterfly with claws and teeth — and then the
poison takes you and the next generation hatches from the clutch you left behind.

Death is not the end of the game. Losing the eggs is.

## Play

Open `index.html` in a browser. That's it — no build step, no dependencies, no assets on
disk. Every sprite is a pixel grid baked in code, and the whole game is one HTML file.

Or serve it locally:

```
python3 -m http.server 8000     # then open http://localhost:8000
```

## The loop

| Stage | You are | Goal |
| --- | --- | --- |
| **Larva** | a baby caterpillar | Eat 5 leaves. Jump between plants, dodge the bugs. |
| **Nesting** | still the caterpillar | Reach the log and lay the clutch inside it. |
| **Chrysalis** | nobody — you hang | Spend leaf points on guns and armour, then survive the waves. |
| **Butterfly** | winged, clawed, toothed | Kill bugs and keep them off the eggs. |
| **Rebirth** | the next caterpillar | Poison ends the butterfly; an egg cracks; generation +1. |

Each generation is harder than the last: more bugs, tougher bugs, more waves. Your score is
how many generations you carry the line through. If the bugs chew the clutch to nothing,
there is nothing left to hatch and the run is over for good.

## Controls

| | |
| --- | --- |
| Move | `←` `→` or `A` `D` |
| Jump | `W` / `↑` / `Space` — landing on a bug's back stuns it |
| Burrow | `S` / `↓` — you are untouchable underground, but the air runs out |
| Eat / lay | hold `E` |
| Fly | arrows or `WASD` |
| Claw | `Space`, or click where you want to swipe |
| Upgrades | `1`–`5` to buy, `Enter` to start the wave |
| Pause / restart / mute | `P` / `R` / `M` |

**The mouse makes everything faster.** Every timed action fills on its own but jumps forward
on each click, so mashing always beats waiting:

- Click a leaf to take a whole bite. Click one out of reach and the caterpillar walks over
  and hops up to it — the larva stage is playable with the mouse alone.
- Click the nest to lay faster, click the chrysalis to crack it open sooner.
- Click a bug as the butterfly to claw in that direction.
- Every upgrade row and button in the panel is a click target.

## Notes on the fight

- A bug only hurts you when it actually lunges, and it winds up with a visible `!` first.
  Jump it, stomp it, or dig in — a bug that bites you backs off afterwards.
- Burrowing makes ground bugs lose your scent and wander away, so it is an escape, not just
  a shield. Watch the AIR bar.
- Finishing a leaf puts a heart back.
- The guns belong to the chrysalis. When the shell cracks they come down with it, and the
  butterfly's claws and teeth are the only thing between the bugs and the clutch.
- A stunned bug that gets clawed is finished with a bite instead of chipped down.

## Debug

Add `?debug=1` to the URL: `[` and `]` step through the stages, `K` kills every bug on
screen, `G` fills the current stage's meter, `H` destroys the clutch.
