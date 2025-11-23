// Just show some info about performance - fpr_real is the big deal
draw_text(20, 20, "FPS = " + string(fps) + ", FPSReal = " + string(fps_real));
if(active == DRAW_MODE.TILEMAP_DYNAMIC) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Dymanic Tiles)");
} else if (active == DRAW_MODE.TILEMAP_BUILTIN) {
    draw_text(20, 40, "Tiles = " + string(tcount) + " (Tilemap Tiles)");    
}
