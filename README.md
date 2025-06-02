Pac-Man Emulation

This is my very own take on the original Pac-Man arcade game; made in Godot.
 
## <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span>
### Movement
Up <span class="symbol">↑</span>, Left <span class="symbol">←</span>, Down <span class="symbol">↓</span>, Right <span class="symbol">→</span>
- If <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span> is captured by a ghost, a life is lost, the ghosts are returned to their pen, and a new <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span> is placed at the starting position before play continues.
- When the maze is cleared of all dots, the board is reset, and a new round begins. 
- If Pac-Man gets caught by a ghost when he has no extra lives, the game is over.

### Points

#### Dots
● Small dots are worth 10 points each
◯ Big dots or energizers are worth 50 points each

Points table for each eaten Ghost
<table>
	<tr>
		<td class="tint">1</td>
		<td class="tint">2</td>
		<td class="tint">3</td>
		<td class="tint">4</td>
	</tr>
	<tr>
		<td>200</td>
		<td>400</td>
		<td>800</td>
		<td>1600</td>
	</tr>
</table>

#### Fruit 🍉
- Two per level
- They appear directly below the monster pen
- First appears after **70 dots** have been eaten
- Second appears after **170 points** have been eaten
- Fruit always stays between 9 and 10 seconds before disappearing

<table class="center">
	<tr>
		<th>Icon</th>
		<td><img src="/readme_images/apple.png"></td>
		<td><img src="/readme_images/strawberry.png"></td>
		<td><img src="/readme_images/orange.png"></td>
		<td><img src="/readme_images/apple.png"></td>
		<td><img src="/readme_images/melon.png"></td>
		<td><img src="/readme_images/galaxian.png"></td>
		<td><img src="/readme_images/bell.png"></td>
		<td><img src="/readme_images/key.png"></td>
	</tr>
	<tr>
		<th>Name<br><small>(points)</small></th>
		<td>Cherry<br><small>(100)</small></td>
		<td>Strawnerry<br><small>(300)</small></td>
		<td>Orange<br><small>(500)</small></td>
		<td>Apple<br><small>(700)</small></td>
		<td>Melon<br><small>(1000)</small></td>
		<td>Galaxian<br><small>(2000)</small></td>
		<td>Bell<br><small>(3000)</small></td>
		<td>Key<br><small>(5000)</small></td>
	</tr>
	<tr>
		<th>Level</th>
		<td>1</td>
		<td>2</td>
		<td>3 & 4</td>
		<td>5 & 6</td>
		<td>7 & 8</td>
		<td>9 & 10</td>
		<td>11 & 12</td>
		<td>13+</td>
	</tr>
</table>

#### <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span> Cornering
In short, Pac-Man is able to navigate the turns in the maze faster or slower than his enemies. He does not have to wait until he reaches the middle of a turn to change direction as the ghosts do (see picture below). Instead, he may start turning several pixels before he reaches the center of a turn and for several pixels after passing it.

<img src="/readme_images/cornering_example2_sm.webp" alt="Cornering example">

## Miscellaneous

### Grid

<img src="/readme_images/Pasted image 20250508184324.png">

Each tile is 8 pixels square
Screen is 224 x 288 pixels
Grid has 28 x 36 tiles

<img src="/readme_images/Pasted image 20250513121558.png">

There are 244 dots in the maze
● Small dots - 240
◯ Big dots - 4

Occupied tile is based on the center point of a character

<img src="/readme_images/Pasted image 20250513122044.png">

This is the reason why Pac-Man can go through a Ghost

<img src="/readme_images/passthrubug.webp">

### Speed

- Every time Pac-Man eats a Small dot ●, he stops moving for one frame (1/60th of a second)
- Eating an energizer dot ◯ causes Pac-Man to stop moving for three frames

Blinky <span style="color: red;">◉</span> turns into Elroy depending on the remaining dots

| Level     | Pac-Man | Pac-Man while ghosts are frightened | Ghost  | Frightened Ghost | Ghost Moving Through Tunnel | Blinky Speed-Up 1 | Blinky Speed-Up 2 |
| --------- | ------- | ----------------------------------- | ------ | ---------------- | --------------------------- | ----------------- | ----------------- |
| 1         | 1       | 1.125                               | 0.9375 | 0.625            | 0.5                         | 1                 | 1.0625            |
| 2-4       | 1.125   | 1.1875                              | 1.0625 | 0.6875           | 0.5625                      | 1.125             | 1.1875            |
| 5-16, 18  | 1.25    | 1.25                                | 1.1875 | 0.75             | 0.625                       | 1.25              | 1.3125            |
| 17, 19-20 | 1.25    | --                                  | 1.1875 | --               | 0.625                       | 1.25              | 1.3125            |
| 21+       | 1.125   | --                                  | 1.1875 | --               | 0.625                       |                   |                   |


## Ghosts ᗣ

<table style="width: 300px">
	<tr>
		<th>Name</th>
		<th>Color</th>
	</tr>
	<tr>
		<td>Blinky</td>
		<td style="color: red">Red</td>
	</tr>
	<tr>
		<td>Pinky</td>
		<td style="color: hotpink">Pink</td>
	</tr>
	<tr>
		<td>Inky</td>
		<td style="color: cyan">Cyan</td>
	</tr>
	<tr>
		<td>Clyde</td>
		<td style="color: orange">Orange</td>
	</tr>
</table>

### Movement
- Target-based system <span class="symbol">⨶</span>
	- Ghosts target their chosen point <span class="symbol">◈</span>
- As soon as they step on a new tile... <span class="symbol">▢</span>
	- Figure next best tile to move to
		- The decision is always between three tiles (ghosts cannot turn back 180°)
		- If the tile is a wall, it is automatically discarded
		- From the remaining options, the one closest to the target gets chosen
		- If the distance is the same, the tile is chosen based on priority:
			- Up <span class="symbol">↑</span>, Left <span class="symbol">←</span>, Down <span class="symbol">↓</span>, Right <span class="symbol">→</span>

Whenever a ghost enters a new tile, it looks ahead to the next tile along its current direction of travel and decides which way it will go when it gets there.

### Ghost House

<img src="/readme_images/startpositions.png">

The ghosts are returned to starting positions when:
- a level is completed
- a life is lost
  
#### Exit Order

- Each Ghost has a personal counter of dots Pac-Man ate.
- There can only be one personal counter active at a time.
- Personal counter is reset to zero when new level begins.
- Only active inside the Ghost House
- Counter is deactivated but not reset when Ghost exits
- Whenever a life is lost, the system disables (but does not reset) the ghosts' individual dot counters and uses a global dot counter instead. This counter is enabled and reset to zero after a life is lost, counting the number of dots eaten from that point forward.
	- Pinky is released when the counter value is equal to 7
	- Inky is released when it equals 17
	- The only way to deactivate the counter is for Clyde to be inside the house when the counter equals 32
	- If Clyde is present at the appropriate time, the global counter is reset to zero and deactivated, and the ghosts' personal dot limits are re-enabled and used as before
- Exit Timer
	- Always counting, but gets reset when a Dot is eaten
	- If it reaches zero, the most-preferred Ghost exits the Ghost House
		- Then the timer starts over
	- Time limit: 
		- 4 seconds
		- 3 seconds starting from level 5

**Order and dot counter**
<table style="width: 100%">
	<tr>
		<th>Ghost</th>
		<th>Order</th>
		<th>Level 1</th>
		<th>Level 2</th>
		<th>Level 3+</th>
	</tr>
	<tr>
		<td ><span style="color: red;">◉</span> <span>Blinky</span></td>
		<td><span>Always outside</span></td>
		<td>-</td>
		<td>-</td>
		<td>-</td>
	</tr>
	<tr>
		<td><span style="color: hotpink;">◉</span> <span>Pinky</span></td>
		<td><span>First</span></td>
		<td>0</td>
		<td>0</td>
		<td>0</td>
	</tr>
	<tr>
		<td><span style="color: cyan;">◉</span> <span>Inky</span></td>
		<td><span>Second</span></td>
		<td>30</td>
		<td>0</td>
		<td>0</td>
	</tr>
	<tr>
		<td><span style="color: orange;">◉</span> <span>Clyde</span></td>
		<td><span>Third</span></td>
		<td>60</td>
		<td>50</td>
		<td>0</td>
	</tr>
</table>

### 4 States
<img src="/readme_images/Pasted image 20250508153233.png" width="500px">

#### Scatter & Chase

##### Timing ⏱️
<table style="width: 100%;">
	<tr>
		<th>Mode</th>
		<th>Level 1</th>
		<th>Levels 2-4</th>
		<th>Levels 5+</th>
	</tr>
	<tr style="background: hsl(120, 40%, 20%);">
		<td>Scatter</td>
		<td>7</td>
		<td>7</td>
		<td>5</td>
	</tr>
	<tr style="background: hsl(0, 80%, 27%);">
		<td>Chase</td>
		<td>20</td>
		<td>20</td>
		<td>20</td>
	</tr>
	<tr style="background: hsl(120, 40%, 20%);">
		<td>Scatter</td>
		<td>7</td>
		<td>7</td>
		<td>5</td>
	</tr>
	<tr style="background: hsl(0, 80%, 27%);">
		<td>Chase</td>
		<td>20</td>
		<td>20</td>
		<td>20</td>
	</tr>
	<tr style="background: hsl(120, 40%, 20%);">
		<td>Scatter</td>
		<td>5</td>
		<td>5</td>
		<td>5</td>
	</tr>
	<tr style="background: hsl(0, 80%, 27%);">
		<td>Chase</td>
		<td>20</td>
		<td>1033 + 14/60</td>
		<td>1037 + 14/60</td>
	</tr>
	<tr style="background: hsl(120, 40%, 20%);">
		<td>Scatter</td>
		<td>5</td>
		<td>1/60</td>
		<td>1/60</td>
	</tr>
	<tr style="background: hsl(0, 80%, 27%);">
		<td>Chase</td>
		<td>indefinite</td>
		<td>indefinite</td>
		<td>indefinite</td>
	</tr>
</table>

The Scatter/Chase Timer is reset whenever a life is lost or a level is completed.

###### Special Case - Blinky <span style="color: red;">◉</span>
<p class="shortly">Always chases depending on the dots remaining. Also named Elroy.</p>
<table style="width:100%; color: orange;">
  <tr>
    <th style="color: royalblue">Level</th>
    <td>1</td>
    <td>2</td>
    <td>3-5</td>
    <td>6-8</td>
    <td>9-11</td>
    <td>12-14</td>
    <td>15-18</td>
    <td>19+</td>
  </tr>
  <tr>
    <th style="color: royalblue">Dots Remaining</th>
    <td>20</td>
    <td>30</td>
    <td>40</td>
    <td>50</td>
    <td>60</td>
    <td>80</td>
    <td>100</td>
    <td>120</td>
  </tr>
</table>

- When entering either state, they turn around 180° <span class="symbol">↶</span>

##### Scatter
Each Ghost has an assigned Target to which they move to in this state
<table style="width: 300px">
	<tr>
		<td ><span style="color: red;">◉</span> <span>Blinky</span></td>
		<td class="flex space-between"><span>Top-Right</span><span class="symbol">◳</span></td>
	</tr>
	<tr>
		<td><span style="color: hotpink;">◉</span> <span>Pinky</span></td>
		<td class="flex space-between"><span>Top-Left</span><span class="symbol">◰</span></td>
	</tr>
	<tr>
		<td><span style="color: cyan;">◉</span> <span>Inky</span></td>
		<td class="flex space-between"><span>Bottom-Right</span><span class="symbol">◲</span></td>
	</tr>
	<tr>
		<td><span style="color: orange;">◉</span> <span>Clyde</span></td>
		<td class="flex space-between"><span>Bottom-Left</span><span class="symbol">◱</span></td>
	</tr>
</table>

<img src="/readme_images/scatter.webp">

##### Chase
Each Ghost calculates the Target based on the position of <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span>

<table style="width: 100%; vertical-align: middle;">
	<tr>
		<th>Ghost</th>
		<th>Target</th>
	</tr>
	<tr>
		<td ><span style="color: red;">◉</span> <span>Blinky</span></td>
		<td><span style="color: yellow">Pac-Man</span>'s Position</td>
	</tr>
	<tr>
		<td><span style="color: hotpink;">◉</span> <span>Pinky</span></td>
		<td><p>4 tiles in front of <span style="color: yellow">Pac-Man</span>.</p><p class="tint">Except when Pac-Man looks up; then it is 4 tiles up and 4 tiles to the left</p></td>
	</tr>
	<tr>
		<td><span style="color: cyan;">◉</span> <span>Inky</span></td>
		<td><p>Takes a position 2 tiles in front of <span style="color: yellow">Pac-Man</span> -> <span class="vector">𝓪</span></p><p class="tint">Except when facing up, when it is 2 tiles up and 2 tiles to the left</p><p>Takes the position of <span style="color: red">Blinky</span> -> <span class="vector">𝓫</span></p><p>Calculates a vector <span class="vector">𝓬 = 𝓪 - 𝓫</span> and adds it to <span class="vector">𝓪</span></p><p>This <span class="vector">𝓬 + 𝓪</span> is the Target</p><p class="tint">The target is essentially 2*𝓪 + 𝓫</p></td>
	</tr>
	<tr>
		<td><span style="color: orange;">◉</span> <span>Clyde</span></td>
		<td><span style="color: yellow">Pac-Man</span>'s Position when 8 or more tiles away from <span style="color: yellow">Pac-Man</span><p>When within 8 tiles, the Target is the same as the one in the Scatter Mode</p></td>
	</tr>
</table>

###### Special Case
There are two areas where ghosts cannot turn up:
1. In front of the Ghost House
2. <span style="color: yellow;">Pac-Man</span>'s starting area
<img src="/readme_images/Pasted image 20250508192437.png" width="400px">

#### Frightened
- All ghosts simultaneously enter Frightened mode when <span style="color: yellow">Pac-Man</span> <span class="pacman">ᗤ</span> eats a Power Pellet on Level 1 - 16 and 18
- The Scatter/Chase Timer gets paused <span style="font-size: 24px">⏱️</span>
- Upon touching a Power Pellet, each Ghost makes a 180° turn, regardless if they entered Frightened mode or not <span class="symbol">↶</span>
	- They **don't** turn around when going back from Frightened state
- Movement: Ghost randomly chooses between eligible tiles
	- If a wall blocks a chosen direction, then chooses according to priority:
		- Up <span class="symbol">↑</span>, Left <span class="symbol">←</span>, Down <span class="symbol">↓</span>, Right <span class="symbol">→</span>
	- The identical random seed gets reset every new level and every new life


<table class="squeeze">
	<tr>
		<th>Level</th>
		<td>1</td>
		<td>2</td>
		<td>3</td>
		<td>4</td>
		<td>5</td>
		<td>6</td>
		<td>7-8</td>
		<td>9</td>
		<td>10</td>
		<td>11</td>
		<td>12-13</td>
		<td>14</td>
		<td>15-16</td>
		<td>17</td>
		<td>18</td>
		<td>19+</td>
	</tr>
	<tr>
		<th>Fright Time <small>(sec)</small></th>
		<td>6</td>
		<td>5</td>
		<td>4</td>
		<td>3</td>
		<td>2</td>
		<td>5</td>
		<td>2</td>
		<td>1</td>
		<td>5</td>
		<td>2</td>
		<td>1</td>
		<td>3</td>
		<td>1</td>
		<td>0</td>
		<td>1</td>
		<td>0</td>
	</tr>
</table>

#### Eaten
- When eaten, Ghost turns to eyeballs and returns to the Ghost House
- The Target is set right in front of the Gate
- Once they reach their Target, they go down into the Ghost House and revert to Scatter/Chase Mode

## Intermissions
<p class="shortly">A break from the action in the form of short intermissions (cutscenes).</p>
<table class="center">
	<tr>
		<th>Intermission I</th>
		<th>Intermission II</th>
		<th>Intermission III</th>
	</tr>
	<tr>
		<td>After level 2</td>
		<td>After level 5</td>
		<td>After level 9, 13, and 17</td>
	</tr>
</table>

- **Intermission I**: Pac-Man is chased by a quickly approaching Blinky to the left side of the screen. Blinky re-emerges, now scared, fleeing to the right; as a larger "super" Pac-Man quickly dashes towards Blinky.
- **Intermission II**: Pac-Man is once again chased by Blinky. This time, there is a nail sticking out in the path that Pac-Man and Blinky are crossing. Blinky's "clothing" gets caught on the nail as he passes by it, and the bottom right corner tears off, stuck to the nail. Shadow, whose foot is now visible, looks at the nail and then rolls his eyes.
- **Intermission III**: Pac-Man enters from the right, followed closely by Blinky, whose torn "clothing" is clearly sewn back together. After both Pac-Man and Blinky exit to the left, Shadow immediately reappears from the left, appearing disrobed and dragging his clothing on the floor behind him.

## Resources
[Arcade Game: Pac-Man (1980 Namco (Midway License for US release))](https://www.youtube.com/watch?v=dScq4P5gn4A)

[Pac-Man Ghost AI Explained](https://www.youtube.com/watch?v=ataGotQ7ir8)

[The Pac-Man Dossier](https://www.gamedeveloper.com/design/the-pac-man-dossier)

[The Pac-Man Dossier (PDF)](https://tralvex.com/download/forum/The%20Pac-Man%20Dossier.pdf)

[Pac-Man Wiki](https://pacman.fandom.com/wiki/Pac-Man_(game))

[Polished Tile-Based Movement in Godot 4 | Roguelike](https://www.youtube.com/watch?v=PZu6ZGLpui8)

[Pac-Man Sprites](https://www.spriters-resource.com/arcade/pacman/)
[Reddit Post About Pac-Man Speed](https://www.reddit.com/r/Pacman/comments/1cg2ogp/does_anyone_know_the_pixel_per_frame_speeds_of/)
