global.maze_default_wall = [
      -1,   0,   8,   2,  
      10, 128, 136, 130, 
     138,  32,  40,  34,
      42, 160, 168, 162,
     170,  56,  58, 184,
     186,  14, 142,  46,
     174, 131, 163, 139,
     171, 224, 232, 226,
     234, 187, 238,  62,
     190, 143, 175, 227,
     235, 248, 250, 191,
     254, 251, 239, 255
    ];

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
    
    static empty = function() {
        return self.data.empty;
    }
}

function maze(width, height, default_tile = 1, capacity = 0) constructor {
    self.width = width;
    self.height = height;
    self.data = array_create(width * height, default_tile);
    self.stack = new stack(capacity);
    self.wallmap = global.maze_default_wall;
    
    static remap_cell = function(xpos, ypos) {
        if( (xpos < 0) || (xpos >= self.width) || (ypos < 0) || (ypos >= self.height) ) {
            throw("Bad cell index passed to maze.remap()");
        }
        return xpos + (ypos * width);
    }
    
    static add_enclosing_border = function() {
        self.data[self.remap_cell(0, 0)] = 35;
        self.data[self.remap_cell(self.width - 1, 0)] = 37;
        self.data[self.remap_cell(0, self.height - 1)] = 41;
        self.data[self.remap_cell(self.width - 1, self.height - 1)] = 39;
        for(var _i=1; _i < self.width - 1; _i++) {
            self.data[self.remap_cell(_i, 0)] = 21;
            self.data[self.remap_cell(_i, self.height - 1)] = 29;
        }
        for(var _i=1; _i < self.height - 1; _i++) {
            self.data[self.remap_cell(0, _i)] = 17;
            self.data[self.remap_cell(self.width - 1, _i)] = 25;
        }
    }
        
    static get_cell_tile = function(xpos, ypos) {
        return self.data[self.remap_cell(xpos, ypos)];
    }
    
    static get_cell_bitmap = function(xpos, ypos) {
        return self.wallmap[self.data[self.remap_cell(xpos, ypos)]];
    }

}
     

