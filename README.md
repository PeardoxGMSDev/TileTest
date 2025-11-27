# TileTest

This repo emulates a Gamemaker Tileset using a single sprite (GrassMap49)

There is also a Gamemaker Tileset with autotile etc defined using the same source sprite

The app initially rewrites the Tiles_1 layer to make it occupy full screen showing each tile in order as a filler

[Esc] will exit the app and [Space] will swap the method used to draw the tileset

When the tileset is drawn programatically (active / global.active is true) the Tiles_1 layer is deleted for that run to prevent it being drawn and the tileset is drawn programatically in the draw event

There is a tileset object defined in tile_functs that creates and draws the tileset as required. This is at the moment extremely basic (stupidly so) having only the constructor and draw method defined

When the app is run a small amount of performance data is displayed during the GUI draw event

The thing to take note of is the RealFPS number. This is dramatically better when using Gamemaker's inbuilt tileset rather than the dynamic one. YYC does improve the situation but is still a lot worse than native.

Before spending any more time on this it is very important to increase the draw speed to something approaching the inbuilt functionality or dynamic tilesets are pointless.

It is possible that some different drawing method or some advanced gm feature such as disabling depth may improve things but tests show no significant improvements so far

This repo is a simple example in support of the associated [GM Feature Request](https://github.com/YoYoGames/GameMaker-Bugs/issues/12948)

### Updates

0.4.0 Match GMS Border tile padding pixel extension

0.3.4 Add Rotate Option

0.3.3 Fix gap

0.3.2 Screen Saver Bounce Tilemap (with gap)

0.3.1 Add capability to switch between more than two test states

0.3.0 Add tilemap and use it to draw

0.2.0 Add tileset_data and precalc offsets (slower???)

0.1.0 Initial