// Initialise vars
tcount = 0;
active = global.active;
// If we're drawing Dynamic Tiles...
if(active) {
    // Don't need a Tileset so delete the layer measning it won't be drawn
    layer_destroy("Tiles_1");
    // Create out own dynamic tileset from the same sprite
    tset = new tileset(GrassMap49, 64, 64, 7, 7);
}