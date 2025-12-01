// ESC = Exit
if(keyboard_check(vk_escape)) {
    game_end();
}

if(keyboard_check_pressed(ord("U"))) {
    unbound = !unbound;
}

if(keyboard_check_pressed(ord("D"))) {
    global.show_debug = !global.show_debug;
    if(global.show_debug) {
        show_debug_overlay(true, false);    
    }
}
    
if(keyboard_check_pressed(vk_pageup)) {
    if(global.zoom > 1) {
       if(global.zoom < 8) {
           //global.zoom++;
           global.zoom = int64(global.zoom + 1);
           game_restart();
       }
    } else {
        global.zoom = global.zoom * 2;
        game_restart();
    }
}

if(keyboard_check_pressed(vk_pagedown)) {
    if(global.zoom > 1) {
        global.zoom = int64(global.zoom - 1);
        game_restart();
    } else {
        if(global.zoom > (1/8)) {
            global.zoom = global.zoom / 2;
            game_restart();
        }
    }
}

if(keyboard_check_pressed(ord("B"))) {
    do_bounce = !do_bounce;
}
if(keyboard_check_pressed(ord("R"))) {
    do_rotate = !do_rotate;
    if(!do_rotate) {
        rot = 0;
    }
}

if(keyboard_check(vk_up)) {
    lookat_y--;
}
if(keyboard_check(vk_down)) {
    lookat_y++;
}
if(keyboard_check(vk_left)) {
    lookat_x--;
}
if(keyboard_check(vk_right)) {
    lookat_x++;
}


// Space = Restart in other tile draw mode
if(keyboard_check(vk_space)) {
    switch (global.active) {
         case DRAW_MODE.TILEMAP_CHECK:
            global.active = DRAW_MODE.TILEMAP_BUILTIN;
            break;
       case DRAW_MODE.TILEMAP_BUILTIN:
            global.active = DRAW_MODE.TILEMAP_DYNAMIC_DRAW;
            break;
        case DRAW_MODE.TILEMAP_DYNAMIC_DRAW:
            global.active = DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_ROW;
            break;
        case DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_ROW:
            global.active = DRAW_MODE.TILEMAP_CHECK;
            break;
    }

    game_restart();
}

if(keyboard_check(vk_f1)) {
    show_debug_message("Break");
}


if((lookat_x + bounce_x) < (virtual_width div 2)) {
    bounce_x = 1;
}
if((lookat_x + bounce_x) > (room_width - (virtual_width div 2))) {
    bounce_x = -1;
}
if((lookat_y + bounce_y) < (virtual_height div 2)) {
    bounce_y = 1;
}
if((lookat_y + bounce_y) > (room_height - (virtual_height div 2))) {
    bounce_y = -1;
}

if(do_bounce) {
    lookat_x += bounce_x;
    lookat_y += bounce_y;
}

if(virtual_scale >= 1) {
    lookat_x = clamp(lookat_x, (virtual_width div 2), room_width - (virtual_width div 2));
    lookat_y = clamp(lookat_y, (virtual_height div 2), room_height - (virtual_height div 2));
} else {
    lookat_x = virtual_width div 2;
    lookat_y = virtual_height div 2;
}

if(minx > lookat_x) { minx = lookat_x };
if(maxx < lookat_x) { maxx = lookat_x };
if(miny > lookat_y) { miny = lookat_y };
if(maxy < lookat_y) { maxy = lookat_y };

if(do_rotate) {
    rot += bounce_rot;
}
if(rot >= 360) {
    rot = 0;
}
var _rot_x = dsin(rot);
var _rot_y = dcos(rot);

var _viewmat = matrix_build_lookat(lookat_x, lookat_y, -10, lookat_x, lookat_y, 0, _rot_x, _rot_y, 0);
var _projmat = matrix_build_projection_ortho(virtual_width, virtual_height, 1.0, 32000.0);
// var _projmat = matrix_build_projection_ortho(room_width, room_height, 1.0, 32000.0);
camera_set_view_mat(cam, _viewmat);
camera_set_proj_mat(cam, _projmat);
