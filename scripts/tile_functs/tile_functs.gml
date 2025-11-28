// Whether to use dynamic tilesets at start (switch over with SPACE)
enum DRAW_MODE {
    TILEMAP_BUILTIN,
    TILEMAP_CHECK,
    TILEMAP_DYNAMIC_DRAW,
    TILEMAP_DYNAMIC_BUFFER
}

if(!variable_global_exists("active")) {
    global.active = DRAW_MODE.TILEMAP_BUILTIN;
}

if(!variable_global_exists("zoom")) {
    global.zoom = 1;
}

if(!variable_global_exists("show_debug")) {
    global.show_debug = false;
}


/* 
 * The following is a very basic tileset object
 * There are many ways toi iumprove it but for now we're only interested in 
 * the draw speed as if this is poor then dynamic tilesets are pointless
 */

enum TILE_TEXTURE_DRAW_MODE {
    TRIANGLE_STRIP,
    TRIANGLE_LIST
 }

function draw_set_colour_alpha(c) {
    draw_set_colour(c);
    draw_set_alpha((c >> 24) / 255);

}

/// @function tileset_data
/// @description Tileset data
/// @param {Real} tile_x - x offset of tile
/// @param {Real} tile_y - y offset of tile  

function tileset_rect(tile_x, tile_y, tile_width, tile_height) constructor {
    self.left= int64(tile_x);
    self.top = int64(tile_y);
    self.right = int64(tile_x + tile_width);
    self.bottom = int64(tile_y + tile_height);
}

/// @function tileset_uv
/// @description Tileset data
/// @param {Real} tile_x - x offset of tile
/// @param {Real} tile_y - y offset of tile  

function tileset_uv(tile_x, tile_y, tile_width, tile_height, texture_width, texture_height) constructor {
    self.left= tile_x / texture_width;
    self.top = tile_y / texture_height;
    self.right = (tile_x + tile_width) / texture_width;
    self.bottom = (tile_y + tile_height) / texture_height;
}


/// @description Dynamically creates a tileset
/// @param {Asset.GMSprite} sprite - Source sprite
/// @param {Real} tile_width - Width of each tile
/// @param {Real} tile_height - Height of each tile  
/// @param {Real} columns - Number of columns in sprite
/// @param {Real} rows - Number of rows in sprite
/// @param {Real} [tile_count] - Number of tiles in tileset if < columns * rows

function tileset(sprite, tile_width, tile_height, columns, rows, tile_count = 0) constructor {
    if(!sprite_exists(sprite)) {
    throw("Bad sprite passed to tileset");  
    } 
    else if((sprite_get_width(sprite) mod columns) != 0) {
        throw("Tileset width not divisible by columns");
    }
    else if((tile_width * columns) != sprite_get_width(sprite)) {
        throw("Bad tileset width");
    }
    else if((sprite_get_height(sprite) mod rows) != 0) {
        throw("Tileset height not divisible by rows");
    }
    else if((tile_height * rows) != sprite_get_height(sprite)) {
        throw("Bad tileset height");
    }
    else if(tile_count > (columns * rows)) {
        throw("Bad tileset count");
    }
    else {
        var _tt = 0;
        if(tile_count < 1) {
            _tt = columns * rows;
        } else {
            _tt = tile_count;
        }
        
        self.sprite = sprite;
        self.border_sprite = noone;
        self.tile_width = tile_width;
        self.tile_height = tile_height;
        self.columns = columns;
        self.rows = rows;
        self.total_tiles = _tt;
        self.offset = array_create(_tt);
        self.uv = array_create(_tt);
        self.textureDrawMethod = TILE_TEXTURE_DRAW_MODE.TRIANGLE_STRIP;
        self.tile_border_x = 0;
        self.tile_border_y = 0;
        self.border = 0;
        self.has_border = false;
        
        self.calculate_offsets();
        self.calculate_uvs();
    }
        
    /// @function get_width
    /// @description Returns tilemap width (border aware)
    static get_width = function() {
        return (self.tile_width * self.columns) + (2 * border) + (2 * self.columns * tile_border_x);
    }
    
    /// @function get_height
    /// @description Returns tilemap height (border aware)
    static get_height = function() {
        return  (self.tile_height * self.rows) + (2 * border) + (2  * self.rows * tile_border_y);
    }
    
    /// @function calculate_offsets
    /// @description Calculates tile offsets (border aware)
    static calculate_offsets = function() {
        // Precalculate all legal offsets
        for(var _ti = 0; _ti < self.total_tiles; _ti++) {
            var _x = (((_ti mod columns)) * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x;
            var _y = (((_ti div columns)) * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y;

            var _pos = new tileset_rect(_x,
                                        _y,
                                        self.tile_width, self.tile_height);
            self.offset[_ti] = _pos;
        }
    }
    
    /// @function calculate_uvs
    /// @description Calculates tile uvs (border aware)
    static calculate_uvs = function() {
        // Precalculate all legal offsets
        for(var _ti = 0; _ti < self.total_tiles; _ti++) {
            var _x = (((_ti mod columns)) * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x;
            var _y = (((_ti div columns)) * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y;
            var _width = (self.tile_width * self.columns) + (2 * border) + (2 * self.columns * tile_border_x);
            var _height = (self.tile_height * self.rows) + (2 * border) + (2  * self.rows * tile_border_y);
            
            var _pos = new tileset_uv(_x, _y, self.tile_width, self.tile_height, _width, _height);
            
            self.uvs[_ti] = _pos;
        }
    }
    
    /// @function draw_tile_from_system
    /// @description Draws a specific tile from the tile system
    /// @param {Real} tile_index - Which tile to draw (0-based)
    /// @param {Real} x - X position to draw at
    /// @param {Real} y - Y position to draw at
    static draw_tile = function(tile_index, x, y) {
        if (tile_index >= self.total_tiles) return;
    
        var o = self.offset[tile_index];
        if(self.has_border) {
            draw_sprite_part(self.border_sprite, 0, 
                o.left, o.top,
                self.tile_width, self.tile_height,
                x, y);
        } else {
            draw_sprite_part(self.sprite, 0, 
                o.left, o.top,
                self.tile_width, self.tile_height,
                x, y);
            }
    }
    
    /// @function set_border
    /// @description Sets dynamic tileset to match GMS tileset layout
    /// @param {Real} [tile_border_x] - Horizontal size of border aroound tile
    /// @param {Real} [tile_border_y] - Vetical size of border aroound tile
    /// @param {Real} [border] - Size of border aroound tileset
    static set_border = function(tile_border_x = 2, tile_border_y = 2, border = 0) {
        var _rv = false;
        if (!sprite_exists(self.sprite)) return _rv;
        if(border < 0) return  _rv;
        if(tile_border_x < 0) return  _rv;
        if(tile_border_y < 0) return  _rv;
        if(self.has_border) return  _rv;

        var _width = sprite_get_width(self.sprite) + (2 * border) + (2 * self.columns * tile_border_x);
        var _height = sprite_get_height(self.sprite) + (2 * border) + (2  * self.rows * tile_border_y);
        var _surf = surface_create(_width, _height);
        try {    
            self.tile_border_x = tile_border_x;
            self.tile_border_y = tile_border_y;
            self.border = border;
            
            surface_set_target(_surf);
            draw_clear_alpha(c_black, 0);
            
            var _ox = self.tile_border_x + self.tile_width;
            var _oy = self.tile_border_y + self.tile_height;
    
            for(var _y = 0; _y < self.rows; _y++) {
                for(var _x = 0; _x < self.columns; _x++) {
                    // Copy sprite to new position
                    draw_sprite_part(self.sprite, 0, 
                        (_x * self.tile_width), (_y * self.tile_height),
                        self.tile_width, self.tile_height,
                        (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                        (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                        
                    var _c_tl = surface_getpixel_ext(_surf,(_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                        (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                    var _c_tr = surface_getpixel_ext(_surf,(_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width - 1, 
                        (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                    var _c_bl = surface_getpixel_ext(_surf,(_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                        (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y + self.tile_height - 1);
                    var _c_br = surface_getpixel_ext(_surf,(_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width - 1, 
                        (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y + self.tile_height - 1);
                                    
                    // Extend tile border left
                    for(var _b = 0; _b < self.tile_border_x; _b++) {
                        draw_sprite_part(self.sprite, 0, 
                            (_x * self.tile_width), (_y * self.tile_height),
                            1, self.tile_height,
                            (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x -1 - _b, 
                            (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                    }
            
                    // Extend tile border right
                    for(var _b = 0; _b < self.tile_border_x; _b++) {
                        draw_sprite_part(self.sprite, 0, 
                            (_x * self.tile_width) + self.tile_width - 1, (_y * self.tile_height),
                            1, self.tile_height,
                            (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width + _b, 
                            (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                    }
            
                    // Extend tile border top
                    for(var _b = 0; _b < self.tile_border_x; _b++) {
                        draw_sprite_part(self.sprite, 0, 
                            (_x * self.tile_width), (_y * self.tile_height),
                            self.tile_width, 1,
                            (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                            (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y -1 - _b);
                    }
            
                    // Extend tile border bottom
                    for(var _b = 0; _b < self.tile_border_x; _b++) {
                        draw_sprite_part(self.sprite, 0, 
                            (_x * self.tile_width), (_y * self.tile_height) + self.tile_height - 1,
                            self.tile_width, 1,
                            (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                            (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y  + self.tile_height + _b);
                    }
    
                        var _lx = (_x * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x;
                        var _ly = (_y * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y;
                    
                    draw_set_colour_alpha(_c_tl);
                    draw_rectangle(_lx - self.tile_border_x, _ly - self.tile_border_y, _lx, _ly, false);
                    
                    draw_set_colour_alpha(_c_tr);
                    draw_rectangle(_lx + _ox - self.tile_border_x, _ly - self.tile_border_y, _lx + _ox , _ly, false);
                        
                    draw_set_colour_alpha(_c_bl);
                    draw_rectangle(_lx - self.tile_border_x, _ly + _oy - self.tile_border_y, _lx, _ly + _oy, false);
                        
                    draw_set_colour_alpha(_c_br);
                    draw_rectangle(_lx + _ox - self.tile_border_x, _ly + _oy - self.tile_border_y, _lx + _ox , _ly + _oy, false);
                    draw_set_alpha(1.0);
            }
    
            }
            
            self.border_sprite = sprite_create_from_surface(_surf, 0, 0, _width, _height, false, false, 0, 0);
            self.has_border = true;
// sprite_save(self.border_sprite, 0, "C:\\video\\check.png")            
            // Recalculate offsets + uvs with borders
            self.calculate_offsets();
            self.calculate_uvs();
            
             _rv = true;
                
        } finally {  
            // Set things back to normal
            surface_reset_target();
            // Free the surface
            surface_free(_surf);
        }        
        // Reset draw colour
        draw_set_colour(c_white);
        return  _rv;
    }
    

}

function tilemap(width, height) constructor {
    self.width = width;
    self.height = height;
    self.tiles = array_create(width * height);
    self.count = width * height;
    self.tileset = noone;
    
    /// @function setTile
    /// @description Assign a tile to a specific row and column
    /// @param {Real} x - X position to draw at
    /// @param {Real} y - Y position to draw at
    /// @param {Real} tile_index - Which tile to draw (0-based)
    static setTile = function(x, y, tile_index) {
        var _index = x + (y * self.width);
        if((_index >= 0) && (_index < self.count)) {
            self.tiles[_index] = tile_index;
            return true;
        }
        return false;
    }
    
    /// @function assignTileset
    /// @description Assign a Tileset to a Tilemap
    /// @param {Struct.tileset} atileset - Which tile to draw (0-based)
    static assignTileset = function(atileset) {
        self.tileset = atileset;
    }    
    
    static draw = function() {
        var _count = 0;
        if(self.tileset == noone) return _count;
        // Loop over rows in dynamic tileset
        for(var _y = 0; _y < self.height; _y++) {
            // Loop over columns in dynamic tileset
            for(var _x = 0; _x < self.width; _x++) {
                var _index = _x + (_y * self.width);
                var _tile = self.tiles[_index];
                // Draw the dynamic tile
                self.tileset.draw_tile(_tile, _x * self.tileset.tile_width, _y  * self.tileset.tile_height);
                _count++;
            }
        }
        return _count;
    }
}

/*
function create_floor_from_tile_layer(layer_id)
{
    function vertex_add_point(vbuffer, _x, _y, _z, nx, ny, nz, utex, vtex, color = c_white, alpha = 1)
    {
        vertex_position_3d(vbuffer, _x, _y, _z);
        vertex_texcoord(vbuffer, utex, vtex);
        vertex_normal(vbuffer, nx, ny, nz);
        vertex_color(vbuffer, color, alpha);
    }
   
    var tmap = layer_tilemap_get_id(layer_id);
    var tset = tilemap_get_tileset(tmap);
    var info = tileset_get_info(tset);
    var uvs = tileset_get_uvs(tset);// space the tileset uses in texture (of other tilesets too)
    var tex = info.texture;
    var tsw = info.width;
    var tsh = info.height;
    var tw = info.tile_width;
    var th = info.tile_height;
    var tc = info.tile_columns; // 8 for me (my tileset shows 8x16 tiles)
    var tr = info.tile_count / tc; // 16
    var ths = info.tile_horizontal_separator;
    var tvs = info.tile_vertical_separator;
    var hp = tw / tsw;
    var vp = th / tsh;
   
    // normalized texture space coordinates (0...1)
    var x1 = uvs[0]; var x2 = uvs[2];
    var y1 = uvs[1]; var y2 = uvs[3];
   
    var z = layer_get_depth(layer_id);
    var vb = vertex_create_buffer();
    vertex_begin(vb, global.vertex_format);
   
    for (var i = 0; i <  room_width; i += tw) {
    for (var j = 0; j < room_height; j += th) {
       
        var tdata = tilemap_get(tmap, i / tw, j / th);
        if (tdata != 0)
        {
            var tind = tile_get_index(tdata);
           
            // tile index for hor and ver
            var tile_x = tind mod tc;
            var tile_y = tind div tc;
           
            // pixel pos
            var txp = tile_x * (tw + 2 * ths) + ths;
            var typ = tile_y * (th + 2 * tvs) + tvs;
           
            // percentage
            var xframe = txp / tsw;
            var yframe = typ / tsh;
       
            // normalized pos
            var u1 = lerp(x1, x2, xframe);
            var v1 = lerp(y1, y2, yframe);
            var u2 = lerp(x1, x2, xframe + hp);
            var v2 = lerp(y1, y2, yframe + vp);
           
            vertex_add_point(vb, i,            j,        z, 0, 0, -1, u1, v1);
            vertex_add_point(vb, i + tw,    j,        z, 0, 0, -1, u2, v1);
            vertex_add_point(vb, i + tw,    j + th,    z, 0, 0, -1, u2, v2);
           
            vertex_add_point(vb, i + tw,    j + th, z, 0, 0, -1, u2, v2);
            vertex_add_point(vb, i,            j + th,    z, 0, 0, -1, u1, v2);
            vertex_add_point(vb, i,            j,        z, 0, 0, -1, u1, v1);
        }
    }}
   
    vertex_end(vb);
    vertex_freeze(vb);
    layer_set_visible(layer_id, false);
   
    return {vbuffer: vb, texture: tex};
}
*/