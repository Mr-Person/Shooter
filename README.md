# Shooter

To take into consideration:
Enemies and bosses will lose HP depending on how close the player's projectile is to their center
height is the height of the whole canvas, where 'Height' is only the height of the game screen
A pre-death timer is implemented into the character superclass: All character types will have a '0 health' state

/////////////////////////////////////////////////////////////////////////////

At low health:
- Enemy's eyes change angle and color
- Boss attacks more frequently

There is a level scale in the game. As level increases:
- A new wave of enemies approach, where there are two more enemeies than before
- Average speed of boss and enemies are faster
- Boss and enemies attack more frequently

Enemies also attack more frequently if there are fewer left
Enemies eyes point to the direction they're moving to
Boss only appears every 3rd level after the wave of enemies is cleared
Boss entry is staggered
Added a pause feature to the game

Achievements have been added: Same format from the second assignment:
- Hit 15 enemies in a row
- Don't get hit for a level after level 2
- Finish off an enemy by hitting it right at the center
- Clear the level before a certain amount of time passes
- Defeat the boss while the player's health is less than 10%
- Take the "Instant Sweeper" Power-up
- Defeat an enemy by only hovering the player's shield over them
- Do not move for 5 minutes
- Make it to level 16
- At the end of any level 20 or over, the player needs over 25 consecutive hits with at least 80% of their health remaining

/////////////////////////////////////////

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
