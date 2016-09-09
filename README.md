# Space Shooter
A space shooter game where the player defeats waves of enemies.

Power-up Implementation:
These power-ups can be acquired by the player or an enemy; not a boss. The character's gauge will max out and slowly lower to zero.
Once the gauge is at zero, the effect ends. Certain power-ups will not change the gauge (health-pickups count as a power-up)
If another power-up is acquired, the previous one will be replaced, and the gauge will not max out until it is empty.

- Super Speed:
By "speeding up", the background, enemies, and boss will be 3 times slower
If the enemy gets it, it will be 3 times faster

- Shockwave:
If the player's shot hits something, it creates a shockwave that will damage the surrounding enemies. Gives double damage to the character that was hit.
If an enemy get it, the player will lose 3 times more health, in contact

- Homing:
The player's shot will aim for the closest enemy (from x-axis)
The enemy will directly chase the player when it charges

- Shield:
Player will be protected; any enemy in contact will take damage
Enemy's shield deflects away the player's shots (Deflected shots will give a lot of damage to the player, so dodge them)

- Extra Points:
The player will obtain more points by shooting enemies
If an enemy gets it, you will lose 1000 points on the spot (There is no negative score)

- Health Boost:
Fully recovers the character's health

- Gauge Boost:
Any power-up currently in effect will stop and the character's max gauge will increase by 2.5x for the next power-up obtained
In addition, enemies will also chase any power-up that will spawn

- Instant Sweep: (Only has a 1 in 200 chance of appearing)
Player automatically fires large projectiles from all angles, immediately wiping out the field of enemies (It will instantly K.O. a boss)
If an enemy gets it, The player will be defeated in contact
