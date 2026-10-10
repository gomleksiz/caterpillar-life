# Caterpillar Life

A single-file browser game about the whole life of a caterpillar. You eat, you hide your
eggs, you pupate under a ladybug guard, you fly as a butterfly and shoo the bugs off your
nest — and when you are finally too weary to fly, the next generation hatches from the
clutch you left behind.

Nothing in this garden gets hurt. There are no weapons and nothing is destroyed: bugs that
lose their nerve simply turn around and leave. The run ends only if the bugs carry off the
last egg.

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
| **Larva** | a baby caterpillar | Eat 5 leaves. Jump between plants, keep clear of the bugs. |
| **Nesting** | still the caterpillar | Reach the log and lay the clutch inside it. |
| **Chrysalis** | nobody — you hang | Spend leaf points on ladybug guards, sap and padding, then sit out the waves. |
| **Butterfly** | winged and quick | Flap gusts of wind to send bugs packing and keep them off the eggs. |
| **Rebirth** | the next caterpillar | Too weary to fly, the butterfly settles; an egg cracks; generation +1. |

Each generation is harder than the last: more bugs, more stubborn bugs, more waves. Your
score is how many generations you carry the line through.

## Controls

| | |
| --- | --- |
| Move | `←` `→` or `A` `D` |
| Jump | `W` / `↑` / `Space` — landing on a bug's back leaves it dizzy |
| Burrow | `S` / `↓` — you are untouchable underground, but the air runs out |
| Eat / lay | hold `E` |
| Fly | arrows or `WASD` |
| Flap | `Space`, or click where you want the gust to go |
| Upgrades | `1`–`5` to buy, `Enter` to start the wave |
| Pause / restart / mute | `P` / `R` / `M` |

**The mouse makes everything faster.** Every timed action fills on its own but jumps forward
on each click, so mashing always beats waiting:

- Click a leaf to take a whole bite. Click one out of reach and the caterpillar walks over
  and hops up to it — the larva stage is playable with the mouse alone.
- Click the nest to lay faster, click the chrysalis to crack it open sooner.
- Click a bug as the butterfly to flap a gust that way.
- Every upgrade row and button in the panel is a click target.

## How bugs are handled

Every bug has a nerve meter instead of health. Fluster it enough — a ladybug headbutt, a
wingbeat from the butterfly — and the bug gives up, turns tail and scurries out of the
garden on its own.

- A bug only barges into you when it actually lunges, and it winds up with a visible `!`
  first. Jump it, bounce off it, or dig in.
- Burrowing makes ground bugs lose your scent and wander away, so it is a real escape, not
  just a shield. Watch the AIR bar.
- Finishing a leaf puts a heart back.
- **Ladybugs** are the chrysalis guard. They perch on the branch and over the log, fly out
  to meet anything that comes near, bump it until it loses its nerve, and return. They are
  the pupa's friends, so their watch ends when the shell cracks — after that the butterfly
  is on its own.
- **Sticky sap** poured around the nest bogs intruders down so the guards can reach them.
- **Stink bugs** puff clouds that make the butterfly weary. That weariness is the butterfly's
  clock: when the WEARY bar fills, it glides down to rest and the eggs hatch.
- A bug caught off balance is sent off in a single gust.

## Debug

Add `?debug=1` to the URL: `[` and `]` step through the stages, `K` shoos every bug on
screen, `G` fills the current stage's meter, `H` empties the nest.
