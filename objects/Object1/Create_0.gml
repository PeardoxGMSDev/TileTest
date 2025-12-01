/*

var _t = new stack();
for(var _i=0; _i < 10; _i++) {
    _t.push(_i);
}
_t.push(10);
_t.pop();
for(var _i=9; _i >= 0; _i--) {
    if(_t.pop() != _i) {
        throw("Check stack error")
    }
}
show_debug_message("Max Stack = " + string(_t.max_stack));

*/

use_maze = true;

// Initialise vars
tset = undefined;
tmap = undefined;
tcount = 0;
active = global.active;
if(active == DRAW_MODE.TILEMAP_DYNAMIC_DRAW) {
    show_debug_message("Break");
}
msg = "";

lookat_x = 20;
lookat_y = 20;
rot = 0;

virtual_width = 0;
virtual_height = 0;
virtual_scale = global.zoom;

view = 0;
cam = view_get_camera(view);
bounce_x = -1;
bounce_y = 1;
bounce_rot = 1;

minx =  9999999999;
maxx = -9999999999;
miny =  9999999999;
maxy = -9999999999;
game_set_speed(display_get_frequency(), gamespeed_fps);

do_bounce = false;
do_rotate = false;

unbound = false;

// Special for check screen
if(active == DRAW_MODE.TILEMAP_CHECK) {
    virtual_scale = 1;
    do_bounce = false;
    do_rotate = false;
}

if(global.show_debug) {
    show_debug_overlay(true, false);    
}


