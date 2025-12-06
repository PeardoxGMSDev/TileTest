// Whether to use dynamic tilesets at start (switch over with SPACE)
enum DRAW_MODE {
    TILEMAP_CHECK,
    TILEMAP_BUILTIN,
    TILEMAP_DYNAMIC_DRAW,
    TILEMAP_DYNAMIC_BUFFER_ROW,
    TILEMAP_DYNAMIC_BUFFER_STRIP
}

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_color();
virtual_tilemap_vertex_format = vertex_format_end();    

tileset_sprite = gmsmap;
break_on_true = false;

layout_consts = [
    {   // Native - Passthru
        width: 7, height: 7, tiles: 48
    },{ // SBS Floor - 8 x 6
        width: 8, height: 6, tiles: 48
    },{ // SBS Wall - 8 x 6
        width: 8, height: 6, tiles: 47
    },{ // GMS World - 8 x 6
        width: 8, height: 6, tiles: 48
    }
];

bitmap_remap = [
    [   // Native - Passthru
         1,  2,  3,  4,  5,  6,  7,  8,
         9, 10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, 32,
        33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48
    ],[ // SBS Floor - 8 x 6
        36,  38,  33,  24,  32,  46,  45,  16,
        42,  40,  34,  20,  28,  43,  44,  35,
         5,   9,  13,   4,  17,  25,  48,  41,
         3,   2,   7,  10,  21,  29,  47,  37,
        12,   8,  18,  27,  23,  22,   6,  39,
        14,  15,  19,  26,  30,  31,  11,   1 
    ],[ // SBS Wall - 8 x 6
        36,  38,  33,  24,  32,  46,  45,  16,
        42,  40,  34,  20,  28,  43,  44,  35,
         5,   9,  13,   4,  17,  25,   1,  41,
         3,   2,   7,  10,  21,  29,  47,  37,
        12,   8,  18,  27,  23,  22,   6,  39,
        14,  15,  19,  26,  30,  31,  11,  48    
    ],[
         1,  2,  3,  4,  5,  6,  7,  8,
         9, 10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, 32,
        33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48
    ]
    
];

enum BITMAP_LAYOUT {
    NATIVE,     // 7 x 7 - 48 tile with tile0 transparent
    SBS_FLOOR,  // 8 x 8 - 48 tile with 1 + 47 as Wall, Floor
    SBS_WALL,   // 8 x 8 - 48 tile with 1 + 47 as Floor, Wall
    GMS_WORLD
}

if(!variable_global_exists("active")) {
//    global.active = DRAW_MODE.TILEMAP_CHECK;
    global.active = DRAW_MODE.TILEMAP_DYNAMIC_DRAW;
}

if(!variable_global_exists("zoom")) {
    global.zoom = 1;
}

if(!variable_global_exists("show_debug")) {
    global.show_debug = false;
}


/* 
 * The following is a very basic tileset object
 * There are many ways to iumprove it but for now we're only interested in 
 * the draw speed as if this is poor then dynamic tilesets are pointless
 */

enum TILE_TEXTURE_DRAW_MODE {
    TRIANGLE_STRIP,
    TRIANGLE_LIST
 }

/// @function draw_set_colour_alpha
/// @description Set both colour and alpha from 32bit ARGB
/// @param {Real} colour
function draw_set_colour_alpha(colour) {
    draw_set_colour(colour);
    draw_set_alpha((colour >> 24) / 255);
}


function load_tileset() {
    var _fn = get_open_filename("Image File|*.png", "");
    return _fn;
}

/// @function load_bitmap
/// @description Convert tileset bitmap to same layout as GameMaker uses internally
/// @param {String} bitmap_order BIRMAP_LAYOUT enum
/// @return {GMAsset.Sprite} New sprite or false
function load_bitmap(fn) {
    if(file_exists(fn)) {
        return sprite_add(fn, 0, false, false, 0, 0);
    }
    
    return false;
}

/// @function vector_pos
/// @description Create vector
/// @param {Real} xpos - Vertical position
/// @param {Real} ypos - Horizontal position
function vector_pos(xpos = 0, ypos = 0) constructor {
    self.xpos = xpos;
    self.ypos = ypos;
}

/// @function vector_mapping
/// @description Create vector mapping
/// @param {Real} width - Width of each poly
/// @param {Real} height - Height of each poly
function vector_mapping(width, height) : vector_pos() constructor {
    self.width = width;
    self.height = height;
    
    static from_index = function(index) {
        if((index < 0) || (index >= (self.width * self.height))) {
            throw("Bad index for vector_mapping.from_index");
        }
        self.xpos = index mod self.width;
        self.ypos = index div self.width;
    }
    
    static set = function(xpos, ypos) {
        if((xpos < 0) || (xpos >= self.width) || (ypos < 0) || (ypos >= self.height)) {
            throw("Bad index for vector_mapping.from_index");
        }
        self.xpos = xpos;
        self.ypos = ypos;
    }
    
    static move = function(direction) {
        switch(direction) {
            case FaceDirection.EAST:
                self.xpos++;
                break;
            case FaceDirection.WEST:
                self.xpos--;
                break;
            case FaceDirection.NORTH:
                self.ypos--;
                break;
            case FaceDirection.SOUTH:
                self.ypos++;
                break;
            default:
                throw("Bad direction for vector_mapping.move");
                break;
            }
    }
}


/// @function tileset_data
/// @description Tileset data
/// @param {Real} x - x for degenerate triangle
/// @param {Real} y - x for degenerate triangle
/// @param {Real} z - z for degenerate triangle
/// @param {Real} u - u for degenerate triangle
/// @param {Real} v - v for degenerate triangle
function degenerate_point(x, y, z, u, v) constructor {
    self.x = x;
    self.y = y;
    self.z = z;
    self.u = u;
    self.v = v;
    
}

/// @function tileset_data
/// @description Tileset data
/// @param {Real} tile_x - x offset of tile
/// @param {Real} tile_y - y offset of tile  

function tileset_rect(tile_x, tile_y, tile_width, tile_height) constructor {
    self.left= round(tile_x);
    self.top = round(tile_y);
    self.right = round(tile_x + tile_width);
    self.bottom = round(tile_y + tile_height);
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


/// @description Dynamically creates a virtual_tileset
/// @param {Asset.GMSprite} sprite - Source sprite
/// @param {Real} tile_width - Width of each tile
/// @param {Real} tile_height - Height of each tile  
/// @param {Real} columns - Number of columns in sprite
/// @param {Real} rows - Number of rows in sprite
/// @param {Real} [tile_count] - Number of tiles in tileset if < columns * rows

function virtual_tileset(sprite, tile_width, tile_height, columns, rows, tile_count = 0) constructor {
    if(!sprite_exists(sprite)) {
    throw("Bad sprite passed to virtual_tileset");  
    } 
    else if((sprite_get_width(sprite) mod columns) != 0) {
        throw("virtual_ileset width not divisible by columns");
    }
    else if((tile_width * columns) != sprite_get_width(sprite)) {
        throw("Bad virtual_tileset width");
    }
    else if((sprite_get_height(sprite) mod rows) != 0) {
        throw("virtual_tileset height not divisible by rows");
    }
    else if((tile_height * rows) != sprite_get_height(sprite)) {
        throw("Bad virtual_tileset height");
    }
    else if(tile_count > (columns * rows)) {
        throw("Bad virtual_tileset count");
    }
    else {
        var _tt = 0;
        if(tile_count < 1) {
            _tt = columns * rows;
        } else {
            _tt = tile_count;
        }
        
        self.ClassName = "tileset";
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
    
    static set_sprite = function(sprite, layout = BITMAP_LAYOUT.NATIVE) {
        if(sprite_exists(self.border_sprite)) {
            sprite_delete(self.border_sprite);
        }
        self.sprite = sprite;
        self.border_sprite = noone;
        self.set_border();
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
    /// @description Sets tilemap border used by convert_bitmap
    /// @param {Real} [tile_border_x] - Horizontal size of border aroound tile
    /// @param {Real} [tile_border_y] - Vetical size of border aroound tile
    /// @param {Real} [border] - Size of border aroound tileset
    /// @return {bool} Succes flag (true if it changed anything)
    static set_border = function(tile_border_x = 2, tile_border_y = 2, border = 0) {
        var _rv = false;
        if (!sprite_exists(self.sprite)) return _rv;
        if(border < 0) return  _rv;
        if(tile_border_x < 0) return  _rv;
        if(tile_border_y < 0) return  _rv;
        if(self.has_border) return  _rv; 
        self.tile_border_x = tile_border_x;
        self.tile_border_y = tile_border_y;
        self.border = border;
        self.has_border = true;
        
        return true;
    }
    
    /// @function convert_bitmap
    /// @description Convert tileset bitmap to same layout as GameMaker uses internally
    /// @param {Real} bitmap_order BIRMAP_LAYOUT enum
    /// @return {bool} Succes flag (true if it changed anything)
    static convert_bitmap = function(bitmap_order = BITMAP_LAYOUT.NATIVE) {
        var _rv = false;
        if (!sprite_exists(self.sprite)) return _rv;
        
        self.tile_width = sprite_get_width(self.sprite) div global.layout_consts[bitmap_order].width;
        self.tile_height = sprite_get_height(self.sprite) div global.layout_consts[bitmap_order].height;

        var _width = (global.layout_consts[BITMAP_LAYOUT.NATIVE].width * self.tile_width) + (2 * border) + (2 * global.layout_consts[BITMAP_LAYOUT.NATIVE].width * tile_border_x);
        var _height = (global.layout_consts[BITMAP_LAYOUT.NATIVE].width * self.tile_height) + (2 * border) + (2  * global.layout_consts[BITMAP_LAYOUT.NATIVE].height * tile_border_y);
        var _surf = surface_create(_width, _height);
        try {    
            surface_set_target(_surf);
            draw_clear_alpha(c_black, 0);
            
            var _ox = self.tile_border_x + self.tile_width;
            var _oy = self.tile_border_y + self.tile_height;
            
            for(var _index = 0; _index < global.layout_consts[bitmap_order].tiles; _index++) {
                var _src_map = new vector_mapping(global.layout_consts[bitmap_order].width, global.layout_consts[bitmap_order].height);
                var _dst_map = new vector_mapping(global.layout_consts[BITMAP_LAYOUT.NATIVE].width, global.layout_consts[BITMAP_LAYOUT.NATIVE].height);
                var _remapped = global.bitmap_remap[bitmap_order][_index];
                _src_map.from_index(_index);
                _dst_map.from_index(_remapped);

                // Copy sprite to new position
                draw_sprite_part(self.sprite, 0, 
                    (_src_map.xpos * self.tile_width), (_src_map.ypos * self.tile_height),
                    self.tile_width, self.tile_height,
                    (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                    (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                    
                var _c_tl = surface_getpixel_ext(_surf,(_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                    (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                var _c_tr = surface_getpixel_ext(_surf,(_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width - 1, 
                    (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                var _c_bl = surface_getpixel_ext(_surf,(_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                    (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y + self.tile_height - 1);
                var _c_br = surface_getpixel_ext(_surf,(_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width - 1, 
                    (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y + self.tile_height - 1);
                                
                // Extend tile border left
                for(var _b = 0; _b < self.tile_border_x; _b++) {
                    draw_sprite_part(self.sprite, 0, 
                        (_src_map.xpos * self.tile_width), (_src_map.ypos * self.tile_height),
                        1, self.tile_height,
                        (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x -1 - _b, 
                        (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                }
        
                // Extend tile border right
                for(var _b = 0; _b < self.tile_border_x; _b++) {
                    draw_sprite_part(self.sprite, 0, 
                        (_src_map.xpos * self.tile_width) + self.tile_width - 1, (_src_map.ypos * self.tile_height),
                        1, self.tile_height,
                        (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x + self.tile_width + _b, 
                        (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y);
                }
        
                // Extend tile border top
                for(var _b = 0; _b < self.tile_border_x; _b++) {
                    draw_sprite_part(self.sprite, 0, 
                        (_src_map.xpos * self.tile_width), (_src_map.ypos * self.tile_height),
                        self.tile_width, 1,
                        (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                        (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y -1 - _b);
                }
        
                // Extend tile border bottom
                for(var _b = 0; _b < self.tile_border_x; _b++) {
                    draw_sprite_part(self.sprite, 0, 
                        (_src_map.xpos * self.tile_width), (_src_map.ypos * self.tile_height) + self.tile_height - 1,
                        self.tile_width, 1,
                        (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x, 
                        (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y  + self.tile_height + _b);
                }

                var _lx = (_dst_map.xpos * (self.tile_width + (2 * self.tile_border_x))) + self.border + self.tile_border_x;
                var _ly = (_dst_map.ypos * (self.tile_height + (2 * self.tile_border_y))) + self.border + self.tile_border_y;
                
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

            
            
            self.border_sprite = sprite_create_from_surface(_surf, 0, 0, _width, _height, false, false, 0, 0);
// sprite_save(self.border_sprite, 0, "C:\\video\\new_texture.png")            
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
    
    /// @function get_ref
    /// @description Returns reference to self
    /// @return {Struct.virtual_ileset} 
    static get_ref = function() {
        return self;
    }
    
    static free = function() {
        if(sprite_exists(self.border_sprite)) {
            sprite_delete(self.border_sprite);
        }
        
        if(is_array(self.offset)) {
            array_resize(self.offset, 0);
        }
        if(is_array(self.uv)) {
            array_resize(self.uv, 0);
        }
    }
    
    static vertex_add_point = function(vbuffer, _x, _y, _z, nx, ny, nz, utex, vtex, color = c_white, alpha = 1) {
        vertex_position_3d(vbuffer, _x, _y, _z);
        vertex_normal(vbuffer, nx, ny, nz);
        vertex_texcoord(vbuffer, utex, vtex);
        vertex_color(vbuffer, color, alpha);
    }
    
    static tile_test = function(idx, z, vf, tex) {

        var vb = vertex_create_buffer();
        
        vertex_begin(vb, vf);
        var i = 1000;
        var j = 700;
        var tw = 120;
        var th = 128;
        
        self.vertex_add_point(vb, i,      j,      z, 0, 0, 1, self.uvs[idx].left,  self.uvs[idx].top);
        self.vertex_add_point(vb, i,      j + th, z, 0, 0, 1, self.uvs[idx].left,  self.uvs[idx].bottom);
        self.vertex_add_point(vb, i + tw, j,      z, 0, 0, 1, self.uvs[idx].right, self.uvs[idx].top);
    
        self.vertex_add_point(vb, i + tw, j,      z, 0, 0, 1, self.uvs[idx].right,  self.uvs[idx].top);
        self.vertex_add_point(vb, i,      j + th, z, 0, 0, 1, self.uvs[idx].left,   self.uvs[idx].bottom);
        self.vertex_add_point(vb, i + tw, j + th, z, 0, 0, 1, self.uvs[idx].right,  self.uvs[idx].bottom);

        vertex_end(vb);
        vertex_freeze(vb);
       
        return vb;
    }    
}

function virtual_tilemap(width, height) constructor {
    self.ClassName = "tilemap";
    self.width = width;
    self.height = height;
    self.tiles = array_create(width * height);
    self.count = width * height;
    self.tileset = undefined;
    self.vertex_texture = undefined;
    self.vertex_buffer = undefined;
    self.vertex_format = global.virtual_tilemap_vertex_format;
    

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
    /// @param {Struct.virtual_tileset} atileset - Which tile to draw (0-based)
    static assignTileset = function(atileset) {
        self.tileset = atileset;
    }    
    
    static _draw_with_sprites = function(left = 0, top = 0, right = 0, bottom = 0) {
        var _count = 0;
        var _unbound = ((top == 0) && (left == 0) && (bottom == 0) && (right == 0));
        if(self.tileset == noone) return _count;
        // Loop over rows in dynamic tileset
        for(var _y = 0; _y < self.height; _y++) {
            // Loop over columns in dynamic tileset
            for(var _x = 0; _x < self.width; _x++) {
                var _index = _x + (_y * self.width);
                var _tile = self.tiles[_index];
                // Draw the dynamic tile
                var _pos_x = _x * self.tileset.tile_width;
                var _pos_y = _y * self.tileset.tile_height
                if(_unbound) {
                    self.tileset.draw_tile(_tile, _pos_x, _pos_y);
                    _count++;
                } else {
                    if(((_pos_x >= (left - self.tileset.tile_width)) && (_pos_y >= (top - self.tileset.tile_height))) && ((_pos_x <= right) && (_pos_y <= bottom))) {
                        self.tileset.draw_tile(_tile, _pos_x, _pos_y);
                        _count++;
                    }
                }
            }
        }
        return _count;
    }

    static _vertex_add_point = function(vbuffer, _x, _y, _z, nx, ny, nz, utex, vtex, color = c_white, alpha = 1) {
        vertex_position_3d(vbuffer, _x, _y, _z);
        vertex_normal(vbuffer, nx, ny, nz);
        vertex_texcoord(vbuffer, utex, vtex);
        vertex_color(vbuffer, color, alpha);
    }
    
    /// @function _vertex_add_quad
    /// @description Create two triangles in rect and add them to vertex buffer
    /// @param {Struct.tileset_rect} rect - Which tile to draw (0-based)
    /// @param {Struct.tileset_uv} uvs - Which tile to draw (0-based)
    /// @param {Real} z - Depth of vertex
    static _vertex_add_quad_list = function(rect, uvs, z) {
        self._vertex_add_point(self.vertex_buffer, rect.left,  rect.top,    z, 0, 0, 1, uvs.left,  uvs.top);
        self._vertex_add_point(self.vertex_buffer, rect.left,  rect.bottom, z, 0, 0, 1, uvs.left,  uvs.bottom);
        self._vertex_add_point(self.vertex_buffer, rect.right, rect.top,    z, 0, 0, 1, uvs.right, uvs.top);
        
        self._vertex_add_point(self.vertex_buffer, rect.right, rect.top,    z, 0, 0, 1, uvs.right,  uvs.top);
        self._vertex_add_point(self.vertex_buffer, rect.left,  rect.bottom, z, 0, 0, 1, uvs.left,   uvs.bottom);
        self._vertex_add_point(self.vertex_buffer, rect.right, rect.bottom, z, 0, 0, 1, uvs.right,  uvs.bottom);
    }
    
    /// @function _vertex_add_quad
    /// @description Create two triangles in rect and add them to vertex buffer
    /// @param {Struct.tileset_rect} rect - Which tile to draw (0-based)
    /// @param {Struct.tileset_uv} uvs - Which tile to draw (0-based)
    /// @param {Real} z - Depth of vertex
    static _vertex_add_quad_strip = function(rect, uvs, z, return_degenerate = false) {
        self._vertex_add_point(self.vertex_buffer, rect.left,  rect.top,    z, 0, 0, 1, uvs.left,  uvs.top);
        self._vertex_add_point(self.vertex_buffer, rect.left,  rect.bottom, z, 0, 0, 1, uvs.left,  uvs.bottom);
        self._vertex_add_point(self.vertex_buffer, rect.right, rect.top,    z, 0, 0, 1, uvs.right, uvs.top);
        self._vertex_add_point(self.vertex_buffer, rect.right, rect.bottom, z, 0, 0, 1, uvs.right,  uvs.bottom);
        
        if(return_degenerate) {
            return new degenerate_point(rect.right, rect.bottom, z, uvs.right,  uvs.bottom);
        }
    }
    
    static _vertex_construct_triangle_strip = function(depth) {

        self.vertex_buffer = vertex_create_buffer();
        
        vertex_begin(self.vertex_buffer, self.vertex_format);

        var _count = 0;
        var _degen = undefined;
        if(is_undefined(self.tileset)) return _count;
        var _tile_width = self.tileset.tile_width;
        var _tile_height = self.tileset.tile_height;
        // Loop over rows in dynamic tileset
        for(var _y = 0; _y < self.height; _y++) {
            // Loop over columns in dynamic tileset
            for(var _x = 0; _x < self.width; _x++) {
              //  if(_y != 10) {continue;}
                var _index = _x + (_y * self.width);
                var _tile = self.tiles[_index] + 1;
                var _rect = new tileset_rect(_x * _tile_width, _y * _tile_height, _tile_width, _tile_height);
                var _uvs = self.tileset.uvs[_tile];
                if(_x == (self.width - 1)) {
                    _degen = self._vertex_add_quad_strip(_rect, _uvs, depth, true);
                } else {
                    self._vertex_add_quad_strip(_rect, _uvs, depth);
                }
                delete(_rect);
            }
            if(!is_undefined(_degen)) {
                self._vertex_add_point(self.vertex_buffer, _degen.x, _degen.y, _degen.z, 0, 0, 1, _degen.u,  _degen.v);
                delete(_degen);
            }
        }
        vertex_end(self.vertex_buffer);
        vertex_freeze(self.vertex_buffer);
       
        return _count;
    }

    static _vertex_construct_triangle_list = function(depth) {

        self.vertex_buffer = vertex_create_buffer();
        
        vertex_begin(self.vertex_buffer, self.vertex_format);

        var _count = 0;
        if(is_undefined(self.tileset)) return _count;
        var _tile_width = self.tileset.tile_width;
        var _tile_height = self.tileset.tile_height;
        // Loop over rows in dynamic tileset
        for(var _y = 0; _y < self.height; _y++) {
            // Loop over columns in dynamic tileset
            for(var _x = 0; _x < self.width; _x++) {
                var _index = _x + (_y * self.width);
                var _tile = self.tiles[_index] + 1;
                var _rect = new tileset_rect(_x * _tile_width, _y * _tile_height, _tile_width, _tile_height);
                var _uvs = self.tileset.uvs[_tile];
                self._vertex_add_quad_list(_rect, _uvs, depth);
            }
        }
        vertex_end(self.vertex_buffer);
        vertex_freeze(self.vertex_buffer);
       
        return _count;
    }    

    static _draw_with_triangle_list = function(left = 0, top = 0, right = 0, bottom = 0) {
        var _rval = 0;
        if(is_undefined(self.tileset)) {
            throw("Trying to use __draw_with_triangle_list without an assigned tileset");
        }
        if(is_undefined(self.vertex_texture)) {
            self.vertex_texture = sprite_get_texture(self.tileset.border_sprite, 0);
            show_debug_message("Constructed texture");
        }
        if(is_undefined(self.vertex_buffer)) {
            self._vertex_construct_triangle_list(0);
            show_debug_message("Constructed buffer");
        }
        vertex_submit(self.vertex_buffer, pr_trianglelist, self.vertex_texture);
        return vertex_get_buffer_size(self.vertex_buffer); // self.width * self.height;
            
    }    
    
    static _draw_with_triangle_strip = function(left = 0, top = 0, right = 0, bottom = 0) {
        var _rval = 0;
        if(is_undefined(self.tileset)) {
            throw("Trying to use __draw_with_triangle_list without an assigned tileset");
        }
        if(is_undefined(self.vertex_texture)) {
            self.vertex_texture = sprite_get_texture(self.tileset.border_sprite, 0);
        }
        if(is_undefined(self.vertex_buffer)) {
            self._vertex_construct_triangle_strip(0);
        }
        vertex_submit(self.vertex_buffer, pr_trianglestrip, self.vertex_texture);
        return vertex_get_buffer_size(self.vertex_buffer); // self.width * self.height;
            
    }    
    
    static draw = function(draw_mode = DRAW_MODE.TILEMAP_DYNAMIC_DRAW, left = 0, top = 0, right = 0, bottom = 0) {
        var _rval = 0;
        switch (draw_mode) {
            case DRAW_MODE.TILEMAP_DYNAMIC_DRAW:
                _rval = self._draw_with_sprites(left, top, right, bottom);
                break;
            case DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_ROW:
                _rval = self._draw_with_triangle_list(left, top, right, bottom);
                break;
            case DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_STRIP:
                _rval = self._draw_with_triangle_strip(left, top, right, bottom);
                break;
            default:
                throw("Bad draw_mode specified in virtual_tileset.draw");
                break; 
        }
        
        return _rval;
    }
    
    static remap_tiles = function(left = 0, top = 0, right = 0, bottom = 0) {
        if((right < left) || (bottom < top)) {
            return false;
        }
        if(!is_struct(self.tileset)) {
            return false;
        }
        if(self.tileset.ClassName != "tileset") {
            return false;
        }

        var _tset = self.tileset;
        var _cells_x = _tset.columns;
        var _cells_y = _tset.rows;
        var _cell_width = _tset.tile_width;
        var _cell_height = _tset.tile_height;
        var _unbound = ((top == 0) && (left == 0) && (bottom == 0) && (right == 0));
        
        var _mapped_left = 0;
        var _mapped_top = 0;
        var _mapped_right = self.width;
        var _mapped_bottom = self.height;
        
        if(!_unbound) {
            _mapped_left = floor(left / _cell_width);
            _mapped_top = floor(top / _cell_height);
            _mapped_right = floor((right - 1) / _cell_width);
            _mapped_bottom = floor((bottom - 1) / _cell_height);
        }
        _mapped_left = clamp(_mapped_left, 0, self.width);
        _mapped_top = clamp(_mapped_top, 0, self.height);
        _mapped_right = clamp(_mapped_right, _mapped_left, self.width - 1);
        _mapped_bottom = clamp(_mapped_bottom, _mapped_top, self.height - 1);

        return("L: " + string(_mapped_left) + ", T: " + string(_mapped_top) + ", R: " + string(_mapped_right) + ", B: " + string(_mapped_bottom) + ", W: " + string(_mapped_right - _mapped_left) + ", H: " + string(_mapped_bottom - _mapped_top));
    }                        
 
    static free = function() {
        self.tileset = noone;
        if(is_array(self.tiles)) {
            array_resize(self.tiles, 0);
        }
    }
}

