// Just show some info about performance - fpr_real is the big deal
draw_text(20, 20, "FPS = " + string(fps) + ", FPSReal = " + string(fps_real));
if(active == DRAW_MODE.TILEMAP_DYNAMIC) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Dymanic Tiles)");
} else if (active == DRAW_MODE.TILEMAP_BUILTIN) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Tilemap Tiles)");    
}
draw_text(20, 60, "View = " + string(view) + ", ViewCam = " + string(view_camera[view]) + ", Cam = " + string(cam) + " " + msg);
draw_text(20, 80, "View X = " + string(view_xport[view]) + ", Y = " + string(view_yport[view]) + ", W = " + string(view_wport[view]) + ", H = " + string(view_hport[view]));
draw_text(20,100, "Room = " + string(room_width) + " x " + string(room_height) + ", Virtual = " + string(virtual_width) + " x " + string(virtual_height));
draw_text(20,120, "LookAt = " + string(lookat_x) + " , " + string(lookat_y) + ", Dir = " + string(bounce_x) + " x " + string(bounce_y) + ", Rot = " + string(rot));
draw_text(20,140, "MinMax = " + string(minx) + " / " + string(maxx) + " : " + string(miny) + " / " + string(maxy));
