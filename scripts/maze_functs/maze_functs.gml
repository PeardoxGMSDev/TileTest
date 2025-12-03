
maze_default_wall = [
      -1,   0,   8,   2,  // 0 = 3
      10, 128, 136, 130,  // 4 - 7
     138,  32,  40,  34,  // 8 - 11
      42, 160, 168, 162,  // 12 - 15
     170,  56,  58, 184,  // 16 - 19
     186,  14, 142,  46,  // 20 - 23
     174, 131, 163, 139,  // 24 - 27
     171, 224, 232, 226,  // 28 - 31
     234, 187, 238,  62,  // 32 - 35
     190, 143, 175, 227,  // 36 - 39
     235, 248, 250, 191,  // 40 - 43
     254, 251, 239, 255, 511   // 44 - 47
    ];

enum FaceDirection { NONE = -1, EAST, NORTHEAST, NORTH, NORTHWEST, WEST, SOUTHWEST, SOUTH, SOUTHEAST };
enum CompassPointBitmapOR {
    EAST = 1, 
    NORTHEAST = 2, 
    NORTH = 4, 
    NORTHWEST = 8, 
    WEST = 16, 
    SOUTHWEST = 32, 
    SOUTH = 64, 
    SOUTHEAST = 128
};
enum CompassPointBitmapAND {
    EAST = 0xFE, 
    NORTHEAST = 0xFD, 
    NORTH = 0xFB, 
    NORTHWEST = 0xF7, 
    WEST = 0xEF, 
    SOUTHWEST = 0xDF, 
    SOUTH = 0xBF, 
    SOUTHEAST = 0x7F
};

break_on_true = false;

function __bsearch(_array, _value, _compare) {
    var _l = 0;
    var _r = array_length(_array) - 1;
    while(_l <= _r) {
        var _m = _l + (floor(_r - _l) div 2);
        if(_compare(_array[_m], _value) < 0) {
            _l = _m + 1;
        } else if(_compare(_array[_m], _value) > 0) {
            _r = _m - 1;
        } else {
            return _m;
        }
    }
    return -1;
}

function binary_tile(tile = undefined, bits = undefined) constructor {
    self.tile = tile;
    self.bits = bits;

}

function binary_map() constructor {
    self.map = array_create(0);

    static bsearch = function(value) {
        var _offset = __bsearch(self.map, value, self._map_find);
        if(_offset == -1) {
            return -1;
        }
        if(_offset >= array_length(self.map)) {
            return -1;
        }
        
        return self.map[_offset].tile;
    }
    
    static _map_compare = function(_current, _next) { // current, next
        if(_current.bits < _next.bits)
            return -1;
        if(_current.bits > _next.bits)  
            return 1;
        // Width + Height are equal
        return 0;
    }
    
    static _map_find = function(_current, _val) { // current, next
        if(_current.bits < _val)
            return -1;
        if(_current.bits > _val)  
            return 1;
        // Width + Height are equal
        return 0;
    }
    
    static add = function(data) {
        var _alen = array_length(data);
        array_resize(self.map, _alen);
        for(var _i = 0; _i < _alen; _i++) {
            self.map[_i] = new binary_tile(_i, data[_i]);
        }
            
        array_sort(self.map, _map_compare);
    }
}

function stack_data() constructor {
    self.data = array_create(0);
    self.top = -1;
    self.capacity = -1;
    self.empty = true;
    
    static grow = function(newsize) {
        if(newsize > self.capacity) {
            array_resize(self.data, newsize);
            self.capacity = newsize;
        } else {
            throw("Trying to grow maze_stack to a smaller size");
        }
    }

    static push = function(obj) {
        if(self.top >= self.capacity) {
            var _growsize =  self.capacity;
            // Grow an empoty stack to 1
            if(_growsize < 1) {
                _growsize = 1;
            // Or double it's size
            } else {
                _growsize = _growsize * 2;
            }
            self.grow(_growsize);
        }
        self.top++;
        self.data[self.top] = obj;
        self.empty = false;
    }
    
    static pop = function() {
        if(self.top < 0) {
            throw("Stack Underflow");
        }
        var _rval = self.data[self.top];
        if(self.top >=0) {
            array_resize(self.data, self.top);
        } else {
            throw("Stack Underflow");
        }
        self.top--;
        self.capacity = self.top;
        if(self.top < 0) {
            self.empty = true;
        }
        return _rval;
    }
    
    static flush = function() {
        array_resize(self.data, 0);
        self.top = -1;
        self.capacity = -1;
        self.empty = true;
    }
    
    static random = function() {
        return self.data[irandom(self.top)];
    }
    static peek = function() {
        return self.data[self.top];
    }
}

function stack(capacity = 0) constructor {
    self.capacity = capacity;
    self.data = new stack_data();
    self.max_stack = -1;
    
    if (capacity > 0) {
    	self.data.grow(capacity);
    }
    
    static push = function(obj) {
        self.data.push(obj);
        if(self.data.top > self.max_stack) {
            self.max_stack = self.data.top;
        }
    }

    static pop = function() {
        return self.data.pop();
    }

    static random = function() {
        return self.data.random();
    }    
    
    static peek = function() {
        return self.data.peek();
    }    
    
    static flush = function() {
        return self.data.flush();
    }    
    
    static isempty = function() {
        return (self.data.empty == true);
    }
}

function maze(width, height, default_tile = 1, capacity = 0) constructor {
    self.width = width;
    self.height = height;
    self.seed = 0;
    self.data = array_create(width * height, default_tile);
    self.stack = new stack(capacity);
    self.wallmap = global.maze_default_wall;
    self.bitmap = new binary_map();
    self.bitmap.add(self.wallmap);
    
    static remap_cell = function(xpos, ypos) {
        if( (xpos < 0) || (xpos >= self.width) || (ypos < 0) || (ypos >= self.height) ) {
            throw("Bad cell index passed to maze.remap()");
        }
        return xpos + (ypos * width);
    }
    
    static find_tile = function(tile) {
        var _res = -1;
        for(var _i = 0; _i < array_length(self.bitmap.map); _i++) {
            var _o = self.bitmap.map[_i];
            if(_o.bits == tile) {
                _res = _o.tile;
                break;
            }
        }
        return _res;
    }
    
    static add_wall = function(xpos, ypos, dir) {
        var _index = self.remap_cell(xpos, ypos);
        var _tile = self.data[_index];
        var _bitmap = self.wallmap[_tile];
        
        switch(dir) {
            case FaceDirection.NORTH:
                _bitmap = _bitmap | CompassPointBitmapOR.NORTHEAST | CompassPointBitmapOR.NORTHWEST | CompassPointBitmapOR.NORTH;
                break;
            case FaceDirection.EAST:
                _bitmap = _bitmap | CompassPointBitmapOR.NORTHEAST | CompassPointBitmapOR.SOUTHEAST | CompassPointBitmapOR.EAST;
                break;
            case FaceDirection.SOUTH:
                _bitmap = _bitmap | CompassPointBitmapOR.SOUTHEAST | CompassPointBitmapOR.SOUTHWEST | CompassPointBitmapOR.SOUTH;
                break;
            case FaceDirection.WEST:
                _bitmap = _bitmap | CompassPointBitmapOR.NORTHWEST | CompassPointBitmapOR.SOUTHWEST | CompassPointBitmapOR.WEST;
                break;
            default:
                throw("");
                break;
        }

        var _new_tile = self.bitmap.bsearch(_bitmap);
        if(_new_tile == -1) {
            throw("Binary Search Error : " + string(_new_tile));
        }

        self.data[_index] = _new_tile;
    }
    
    static add_door = function(xpos, ypos, dir) {
        var _index = self.remap_cell(xpos, ypos);
        var _tile = self.data[_index];
        var _bitmap = self.wallmap[_tile];
        
        switch(dir) {
            case FaceDirection.NORTH:
                _bitmap = (_bitmap | CompassPointBitmapOR.NORTHEAST | CompassPointBitmapOR.NORTHWEST) & CompassPointBitmapAND.NORTH ;
                break;
            case FaceDirection.EAST:
                _bitmap = (_bitmap | CompassPointBitmapOR.NORTHEAST | CompassPointBitmapOR.SOUTHEAST) & CompassPointBitmapAND.EAST;
                break;
            case FaceDirection.SOUTH:
                _bitmap = (_bitmap | CompassPointBitmapOR.SOUTHEAST | CompassPointBitmapOR.SOUTHWEST) & CompassPointBitmapAND.SOUTH;
                break;
            case FaceDirection.WEST:
                _bitmap = (_bitmap | CompassPointBitmapOR.NORTHWEST | CompassPointBitmapOR.SOUTHWEST) & CompassPointBitmapAND.WEST;
                break;
            default:
                throw("");
                break;
        }

        var _new_tile = self.bitmap.bsearch(_bitmap);
        if(_new_tile == -1) {
            throw("Binary Search Error : " + string(_new_tile));
        }

        self.data[_index] = _new_tile;
    }
    
    static add_enclosing_border = function() {
        for(var _i=0; _i < self.width; _i++) {
            self.add_wall(_i, 0, FaceDirection.NORTH);
        }
        for(var _i=0; _i < self.width; _i++) {
            self.add_wall(_i, self.height - 1, FaceDirection.SOUTH);
        }
        for(var _i=0; _i < self.height; _i++) {
            self.add_wall(0, _i, FaceDirection.WEST);
        }        
        for(var _i=0; _i < self.height; _i++) {
            self.add_wall(self.width - 1, _i, FaceDirection.EAST);
        }      
    }
        
    static create = function(seed = 0) {
        add_enclosing_border();
    }
    
    static get_cell_tile = function(xpos, ypos) {
        return self.data[self.remap_cell(xpos, ypos)];
    }
    
    static get_cell_bitmap = function(xpos, ypos) {
        return self.wallmap[self.data[self.remap_cell(xpos, ypos)]];
    }

}
     
function growing_tree_maze(width, height, default_tile = 1, capacity = 0) :  maze(width, height, default_tile, capacity) constructor {
    self.start = undefined;
    static pick_exit = function(cell) {
        var _exits = new stack();
        if(cell.ypos < self.height - 1) {
            if(get_cell_bitmap(cell.xpos, cell.ypos + 1) == 0) {
                _exits.push(FaceDirection.SOUTH);
            }
        }
        if(cell.xpos > 0) {
            if(get_cell_bitmap(cell.xpos - 1, cell.ypos)== 0) {
                _exits.push(FaceDirection.WEST);
            }
        }
        if(cell.ypos > 0) {
            if(get_cell_bitmap(cell.xpos, cell.ypos - 1) == 0) {
                _exits.push(FaceDirection.NORTH);
            }
        }
        if(cell.xpos < self.width - 1) {
            if(get_cell_bitmap(cell.xpos + 1, cell.ypos) == 0) {
                _exits.push(FaceDirection.EAST);
            }
        }
        
        var _rval = FaceDirection.NONE;
        if(!_exits.isempty()) {
            _rval =_exits.random();
        }
        _exits.flush();
        delete(_exits);
        
        return _rval;
    }
    
    static create = function(seed = 0) {
        var _rval = "";
        var _mazesize = array_length(self.data);
        if((self.width < 1) || (self.height < 1) || (_mazesize == 0)) {
            throw("Maze is empty");
        }
        
        var _all_wall = self.bitmap.bsearch($FF);
        var _blocking = self.bitmap.bsearch($1FF);
        if(seed == 0) {
            randomise();
            //random_set_seed(148905283);
            self.seed = random_get_seed();
        } else {
            random_set_seed(seed);
            self.seed = seed;
        }
        show_debug_message("Seed = " + string(self.seed));
        
        var _cell = new vector_mapping(self.width, self.height);        
        if(self.stack.isempty()) {
//            _cell.from_index(irandom(_mazesize - 1));
            _cell.from_index(_mazesize - 1);
            self.start = new vector_pos(_cell.xpos,_cell.ypos);
            self.stack.push(new vector_pos(_cell.xpos,_cell.ypos));
        } else {
            var _tos = self.stack.peek();
            _cell.set(_tos.xpos, _tos.ypos);
        }
        
        if(self.get_cell_bitmap(_cell.xpos, _cell.ypos) = 0) {
            self.data[self.remap_cell(_cell.xpos, _cell.ypos)] = _all_wall;
        }
        
//        for(var _i=0; _i<1; _i++) {
        while(!self.stack.isempty()) {
            var _dir = self.pick_exit(_cell);
            if(_dir == FaceDirection.NONE) {
                if(self.stack.isempty()) {
                    break;
                }
                var _old_cell = self.stack.pop();
                _cell.set(_old_cell.xpos, _old_cell.ypos);
            } else {
                
                self.add_door(_cell.xpos, _cell.ypos, _dir);
                _cell.move(_dir);
                if(self.get_cell_bitmap(_cell.xpos, _cell.ypos) = 0) {
                    self.data[self.remap_cell(_cell.xpos, _cell.ypos)] = _all_wall;
                }
    
                switch(_dir) {
                    case FaceDirection.NORTH:
                        self.add_door(_cell.xpos, _cell.ypos, FaceDirection.SOUTH);
                        break;
                    case FaceDirection.EAST:
                        self.add_door(_cell.xpos, _cell.ypos, FaceDirection.WEST);
                        break;
                    case FaceDirection.SOUTH:
                        self.add_door(_cell.xpos, _cell.ypos, FaceDirection.NORTH);
                        break;
                    case FaceDirection.WEST:
                        self.add_door(_cell.xpos, _cell.ypos, FaceDirection.EAST);
                        break;
                    default:
                        throw("Bad Direction in growinto_tree_maze.create");
                        break;
                }
                self.stack.push(new vector_pos(_cell.xpos,_cell.ypos));
            }
           
        }
        
        
    }
    
}
