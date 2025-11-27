// Resize the room to be full screen borderless 
room_width = display_get_width();
room_height = display_get_height();
window_enable_borderless_fullscreen(true);
window_set_fullscreen(true);


// Rewrite the tilemap so it matches the dynamic one we're testing
tcount = 0;

// If we're drawing Dynamic Tiles...
if(active == DRAW_MODE.TILEMAP_DYNAMIC) {
    // Don't need a Tileset so delete the layer measning it won't be drawn
    layer_destroy("Tiles_1");
    // Create out own dynamic tileset from the same sprite
    tset = new tileset(GrassMap49, 64, 64, 7, 7, 48);
    
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
    room_width = _cell_width * tset.tile_width;
    room_height = _cell_height * tset.tile_height;
    surface_resize(application_surface, room_width, room_height);
} else if(active == DRAW_MODE.TILEMAP_BUILTIN) {
    var lay_id = layer_get_id("Tiles_1");
    var map_id = layer_tilemap_get_id(lay_id);
    var _w = room_width div tilemap_get_tile_width(map_id);
    var _h = room_height div tilemap_get_tile_height(map_id);
    tilemap_set_width(map_id, _w);
    tilemap_set_height(map_id, _h);
        
    for(var _y = 0; _y <  _h; _y++) {
        for(var _x = 0; _x < _w; _x++) {
            var _tile = tcount mod 48;
            tilemap_set(map_id, _tile, _x, _y);
            tcount++; 
        } 
    }    
    room_width = _w * tilemap_get_tile_width(map_id);
    room_height = _h * tilemap_get_tile_height(map_id);
    surface_resize(application_surface, room_width, room_height);
}

virtual_width = display_get_width() / virtual_scale;
virtual_height = display_get_height() / virtual_scale;

lookat_x = virtual_width div 2;
lookat_y = virtual_height div 2;

cam = camera_create();
view_set_camera(view, cam);
var _viewmat = matrix_build_lookat(lookat_x, lookat_y, -10, lookat_x, lookat_y, 0, 0, 1, 0);
var _projmat = matrix_build_projection_ortho(virtual_width, virtual_height, 1.0, 32000.0);
camera_set_view_mat(cam, _viewmat);
camera_set_proj_mat(cam, _projmat);
view_enabled = true;
view_set_visible(view, true);
view_set_wport(view, virtual_width);
view_set_hport(view, virtual_height);
