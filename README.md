# SpriteKit Games
I've written a couple if games apps; one for the MAC and one for the iPad. Both were relatively simple, low graphics game compendiums. While they were fun to write and I still play them now, there was nothing __arcade__ about them. The graphics content was just enough to make the game look good.

I felt the urge to make something more graphical and Apple's 2D graphical game engine is the old (very old)
SpriteKit framework. So I figured I should have a go at something more arcade like using SpriteKit.

I started with Paul Hudson's tutorials which game me a basic grounding in SpriteKit and led to four games. The first of these was a space game that has kept me amused and challenged for a while now.

## Asteroids

On the face of it, Asteroids is a simple game. It is, however, frustratingly difficult to play and involves a healthy level of panic!

![Asteroids](Images/AsteroidsOniPad.png)

When the game starts, a star field will be generated that moves from right to left. This creates the feeling of movement for the space craft. The game then starts generating asteroids for the player to avoid. By pressing on the space ship, you can move it around the screen and avoid colliding with the asteroids.

Once I had the basic game sorted out, I set about enhancing it to make it more appealing and to inject a level of difficulty.

The original version of this game was produced by Paul Hudson in his [Dive Into Spritekit](https://www.hackingwithswift.com/store/dive-into-spritekit) book. I extended the game to include;

* A variable gap between generating asteroids so they were not evenly spaced.
* Made the asteroids variable size and gave them a spin.
* Changed the icon for the energy boost to something more 'atomic'.
* Changed the scoring system. You now have a limit on your fuel reserves which you must replenish with energy boosts.
* Track the time you are playing.
* Added a toolbar to control whether sounds are playing and to allow the player to pause/resume the game.
* Added a popup window to track high scores.
* Creating SpriteKit 'components' to encapsulate game play functionality

I'm still new to SpriteKit, so don't expect perfect code. Learning takes time!
