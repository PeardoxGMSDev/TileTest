// ESC = Exit
if(keyboard_check(vk_escape)) {
    game_end();
}

// Space = Restart in other tile draw mode
if(keyboard_check(vk_space)) {
    switch (global.active) {
        case DRAW_MODE.TILEMAP_BUILTIN:
            global.active = DRAW_MODE.TILEMAP_DYNAMIC;
            break;
        case DRAW_MODE.TILEMAP_DYNAMIC:
            global.active = DRAW_MODE.TILEMAP_BUILTIN;
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

lookat_x += bounce_x;
lookat_y += bounce_y;

lookat_x = clamp(lookat_x, 0, room_width - (virtual_width div 2));
lookat_y = clamp(lookat_y, 0, room_height - (virtual_height div 2));

if(minx > lookat_x) { minx = lookat_x };
if(maxx < lookat_x) { maxx = lookat_x };
if(miny > lookat_y) { miny = lookat_y };
if(maxy < lookat_y) { maxy = lookat_y };

var _viewmat = matrix_build_lookat(lookat_x, lookat_y, -10, lookat_x, lookat_y, 0, 0, 1, 0);
var _projmat = matrix_build_projection_ortho(virtual_width, virtual_height, 1.0, 32000.0);
camera_set_view_mat(cam, _viewmat);
camera_set_proj_mat(cam, _projmat);
