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
for(var _y = 0; _y <  _h; _y++) {
    for(var _x = 0; _x < _w; _x++) {
        var _tile = tcount mod 48;
        tilemap_set(map_id, _tile, _x, _y);
        tcount++; 
    }
}

