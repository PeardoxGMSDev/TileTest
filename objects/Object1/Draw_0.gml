// If we're drawing Dynamic Tiles...
if(active) {
    // Reset tile count
    tcount = 0;
    // Loop over rows in dynamic tileset
    for(var _y = 0; _y < room_height div tset.tile_height; _y++) {
    // Loop over columns in dynamic tileset
        for(var _x = 0; _x < room_width div tset.tile_width; _x++) {
    // Pick a tile - here it's the full (extended) set
            var _tile = tcount mod tset.total_tiles;
    // Draw the dynamic tile
            tset.draw(_tile, _x, _y);
            tcount++;
        }
   }
}