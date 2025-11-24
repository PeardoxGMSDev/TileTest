// Initialise vars
tcount = 0;
active = global.active;
msg = "";

lookat_x = 20;
lookat_y = 20;
virtual_width = 0;
virtual_height = 0;
virtual_scale = 0;
cam = 0;
view = 0;
bounce_x = -1;
bounce_y = 1;
minx =  9999999999;
maxx = -9999999999;
miny =  9999999999;
maxy = -9999999999;

game_set_speed(display_get_frequency(), gamespeed_fps);

/*
var _old_cam = view_get_camera(view);
if(_old_cam != -1) {
    msg = "Deleted Camera #" + string(_old_cam);
    camera_destroy(_old_cam);
}
*/
