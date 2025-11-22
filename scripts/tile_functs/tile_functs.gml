// Whether to use dynamic tilesets at start (switch over with SPACE)
if(!variable_global_exists("active")) {
    global.active = false;
}

/* 
 * The following is a very basic tileset object
 * There are many ways toi iumprove it but for now we're only interested in 
 * the draw speed as if this is poor then dynamic tilesets are pointless
 */

/// @function tileset
/// @description Dynamically creates a tileset
/// @param {Asset.GMSprite} sprite - Source sprite
/// @param {Real} tile_width - Width of each tile
/// @param {Real} tile_height - Height of each tile  
/// @param {Real} columns - Number of columns in sprite
/// @param {Real} rows - Number of rows in sprite
/// @param {Real} tile_count - Number of tiles in tileset if < columns * rows

function tileset(sprite, tile_width, tile_height, columns, rows, tile_count = 0) constructor {
        if(!sprite_exists(sprite)) {
           throw("Bad sprite passed to tileset");  
        } 
        else if((sprite_get_width(sprite) mod columns) != 0) {
            throw("Bad tileset width");
        }
        else if((tile_width * columns) != sprite_get_width(sprite)) {
            throw("Bad tileset width");
        }
        else if((sprite_get_height(sprite) mod rows) != 0) {
            throw("Bad tileset height");
        }
        else if((tile_height * rows) != sprite_get_height(sprite)) {
            throw("Bad tileset height");
        }
        else if(tile_count > (columns * rows)) {
            throw("Bad tileset count");
        }
        else {
            self.sprite = sprite;
            self.tile_width = tile_width;
            self.tile_height = tile_height;
            self.columns = columns;
            self.rows = rows;
            if(tile_count < 1) {
                self.total_tiles = columns * rows;
            } else {
                self.total_tiles = tile_count;
            }
        }
            

    /// @function draw_tile_from_system
    /// @description Draws a specific tile from the tile system
    /// @param {Real} tile_index - Which tile to draw (0-based)
    /// @param {Real} x - X position to draw at
    /// @param {Real} y - Y position to draw at
    
    static draw = function(tile_index, x, y) {
    if (tile_index >= self.total_tiles) return;
    
    var source_x = (tile_index mod self.columns) * self.tile_width;
    var source_y = (tile_index div self.columns) * self.tile_height;
    
    draw_sprite_part(self.sprite, 0, 
        source_x, source_y, 
        self.tile_width, self.tile_height,
        x * self.tile_width, y * self.tile_height);
    }
}

