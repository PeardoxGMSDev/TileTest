// Just show some info about performance - fpr_real is the big deal
draw_set_colour(c_black);
draw_set_alpha(0.66);
draw_rectangle(10, 10, 420, 190,false);

draw_set_colour(c_white);
draw_set_alpha(1);
draw_rectangle(10, 10, 420, 190,true);
draw_set_colour(c_yellow);

draw_text(20, 20, "FPS = " + string(fps) + ", FPSReal = " + string(fps_real) + ", Zoom = " + string(virtual_scale));
if(active == DRAW_MODE.TILEMAP_DYNAMIC_DRAW) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Dymanic Tiles) (48 set)");
} else if (active == DRAW_MODE.TILEMAP_BUILTIN) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Tilemap Tiles) (47 set)");    
} else if (active == DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_ROW) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Dynamic Buffer (Row) (48 set)");    
} else if (active == DRAW_MODE.TILEMAP_CHECK) {
    draw_text(20, 40, "Tiles = N/A (Tilemap Check)");    
    draw_text(0, sprite_get_height(GrassMap49) + 64, "Builtin Tilemap");
    draw_text(sprite_get_width(tset.sprite) + 64, tset.get_height() + 64, "Dymamic Tilemap (Sprite - tile border = 16)");
    draw_text(sprite_get_width(tset.sprite) + 64 + sprite_get_width(tset.border_sprite) + 64, sprite_get_width(gms_16border) + 64, "Dymamic Tilemap (GMS version - tile border = 16)");
}

draw_text(20, 60, "View = " + string(view) + ", ViewCam = " + string(view_camera[view]) + ", Cam = " + string(cam) + " " + msg);
draw_text(20, 80, "View X = " + string(view_xport[view]) + ", Y = " + string(view_yport[view]) + ", W = " + string(view_wport[view]) + ", H = " + string(view_hport[view]));
draw_text(20,100, "Room = " + string(room_width) + " x " + string(room_height) + ", Virtual = " + string(virtual_width) + " x " + string(virtual_height));
draw_text(20,120, "LookAt = " + string(lookat_x) + " , " + string(lookat_y) + ", Dir = " + string(bounce_x) + " x " + string(bounce_y) + ", Rot = " + string(rot));
draw_text(20,140, "MinMax = " + string(minx) + " / " + string(maxx) + " : " + string(miny) + " / " + string(maxy));
var _switches = "";
if(unbound) {
    _switches += "[Unbound]";
} else {
    _switches += "         ";
}
if(do_bounce) {
    _switches += "[Bounce]";
} else {
    _switches += "        ";
}
if(do_rotate) {
    _switches += "[Rotate]";
} else {
    _switches += "        ";
}

draw_text(20,160, _switches);


draw_set_colour(c_black);
draw_set_alpha(0.66);
draw_rectangle(10, display_get_gui_height() - 50, 920, display_get_gui_height() - 10,false);

draw_set_colour(c_white);
draw_set_alpha(1);
draw_rectangle(10, display_get_gui_height() - 50, 920, display_get_gui_height() - 10,true);
draw_set_colour(c_yellow);

draw_text(20, display_get_gui_height() - 40,"PgUp/PgDn = Zoom In/Out, B = Bounce, R = Rotate, Space = Next Scrren, D = Debug Overlay, Esc = Quit");