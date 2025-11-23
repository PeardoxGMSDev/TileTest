// Resize the room to be full screen borderless 
room_width = display_get_width();
room_height = display_get_height();
window_enable_borderless_fullscreen(true);
window_set_fullscreen(true);
surface_resize(application_surface, room_width, room_height);

// Rewrite the tilemap so it matches the dynamic one we're testing
var lay_id = layer_get_id("Tiles_1");
var map_id = layer_tilemap_get_id(lay_id);
var _w = room_width div tilemap_get_tile_width(map_id);
var _h = room_height div tilemap_get_tile_height(map_id);
tilemap_set_width(map_id, _w);
tilemap_set_height(map_id, _h);
tcount = 0;

// If we're drawing Dynamic Tiles...
if(active) {
    // Don't need a Tileset so delete the layer measning it won't be drawn
    layer_destroy("Tiles_1");
    // Create out own dynamic tileset from the same sprite
    tset = new tileset(GrassMap49, 64, 64, 7, 7);
    
    var _cell_width = room_width div tset.tile_width;
    var _cell_height = room_height div tset.tile_height;
    
    tmap = new tilemap(_cell_width, _cell_height);
    // Loop over rows in dynamic tileset
    for(var _y = 0; _y < _cell_height; _y++) {
    // Loop over columns in dynamic tileset
        for(var _x = 0; _x < _cell_width; _x++) {
    // Pick a tile - here it's the full (extended) set
            var _tile = tcount mod tset.total_tiles;
    // Draw the dynamic tile
            tmap.setTile(_x, _y, _tile);
            tcount++;
        }
    }
    tmap.assignTileset(tset);
} else {
    for(var _y = 0; _y <  _h; _y++) {
        for(var _x = 0; _x < _w; _x++) {
            var _tile = tcount mod 48;
            tilemap_set(map_id, _tile, _x, _y);
            tcount++; 
        } 
    }    
}
