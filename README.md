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

---

# Zero G

A second single-file game in this repo: `zero-g.html`. You fly the aeroplane the
weightless-flight operators actually use — a Boeing 727-200, stripped out and padded —
and earn your zero gravity the way they do, by throwing the whole aircraft down a
parabola and riding the free fall.

Open `zero-g.html` in a browser. No build step, no libraries, no assets: every polygon
is generated in code, every sound is synthesised, and the sky is arithmetic.

## The parabola

| Phase | What you do |
| --- | --- |
| **Set up** | 24,000 ft, 300 kt indicated, wings level. |
| **Pull** | Ease back to 1.8 g and hold it until the nose is 45° high. |
| **Float** | Push over the top and keep pushing. Come back on the throttle so drag stops pressing you forward. The cabin is now in orbit. |
| **Recover** | By 30° nose down, pull out at about 1.8 g. Do not go past 2.6 g or the speed limit. |

The profile is five parabolas: one Martian (0.38 g), one Lunar (0.17 g), then three at
zero. You are scored on the seconds you hold inside tolerance, how smooth you kept it,
and whether anybody in the back hit the ceiling.

**Keep the ball in the ring.** The ball is your accelerometer — up-down is what presses
you into the floor, left-right is thrust against drag. Centre it and you are weightless.

## The cabin

Eight people float in the padded tube behind you, and they are not decoration: they only
ever feel gravity, so in the aeroplane's frame they accelerate by exactly minus whatever
the airframe is being pushed by. Fly it well and they hang there. Fly it badly and they
hit the wall, which costs you points. The corner window shows them live; press the camera
button to climb in with them.

## Controls

**Phone or tablet** — the left thumb is the stick, and it appears wherever you press:
drag **down** to pull the nose up. The right edge is the throttle. Buttons top right for
camera, pause, sound and help. It works in either orientation, though landscape gives you
more sky. If the frame rate sags the game quietly renders fewer pixels rather than fewer
frames.

**Keyboard**

| | |
| --- | --- |
| Pitch | `↑` / `W` push, `↓` / `S` pull |
| Roll | `←` `→` or `A` `D` |
| Rudder | `Q` `E` |
| Throttle | `SHIFT` / `CTRL`, or the mouse wheel |
| Camera | `C` — chase, flight deck, cabin |
| Help / pause / sound / restart | `H` / `P` / `M` / `R` |

You can also hold the left mouse button anywhere and fly it like a stick.

## Assist

Pick a level on the title screen. **Rookie** gives you a flight director and an
auto-throttle, and calms the air down. **Pilot** keeps the director only. **Astronaut** is
you, the ball, and real turbulence.

## Notes on the flight model

Lift and drag come off an aerofoil curve against the standard atmosphere, thrust off the
throttle and the air density, and everything the cabin feels is that sum minus gravity —
which is why a good parabola reads 0.00 g. The stick asks for an angle of attack rather
than a rotation rate, which is what a trimmed aeroplane actually gives you: let go and it
settles back to level flight, and holding the nose down through the arc is a steady
forward push, exactly as it is in the real thing.
