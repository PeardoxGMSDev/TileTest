// Whether to use dynamic tilesets at start (switch over with SPACE)
if(!variable_global_exists("active")) {
    global.active = false;
}

/* 
 * The following is a very basic tileset object
 * There are many ways toi iumprove it but for now we're only interested in 
 * the draw speed as if this is poor then dynamic tilesets are pointless
 */


/// @function tileset_data
/// @description Tileset data
/// @param {Real} tile_x - x offset of tile
/// @param {Real} tile_y - y offset of tile  

function tileset_data(tile_x, tile_y) constructor {
    self.x = int64(tile_x);
    self.y = int64(tile_y);
}

/// @function tileset
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
            self.tile_width = tile_width;
            self.tile_height = tile_height;
            self.columns = columns;
            self.rows = rows;
            self.total_tiles = _tt;
            self.offset = array_create(_tt);
            // Precalculate all legal offsets
            for(var _ti = 0; _ti < _tt; _ti++) {
                var source_x = (_ti mod columns) * tile_width;
                var source_y = (_ti div columns) * tile_height;
                self.offset[_ti] = new tileset_data(source_x, source_y);
            }
            
        }
            

    /// @function draw_tile_from_system
    /// @description Draws a specific tile from the tile system
    /// @param {Real} tile_index - Which tile to draw (0-based)
    /// @param {Real} x - X position to draw at
    /// @param {Real} y - Y position to draw at
    
    static draw = function(tile_index, x, y) {
        
        if (tile_index >= self.total_tiles) return;
    
        var o = self.offset[tile_index];
        var source_x = o.x; // (tile_index mod self.columns) * self.tile_width;
        var source_y = o.y; // (tile_index div self.columns) * self.tile_height;
        
        draw_sprite_part(self.sprite, 0, 
            source_x, source_y,
            self.tile_width, self.tile_height,
            x * self.tile_width, y * self.tile_height);
        }
}

