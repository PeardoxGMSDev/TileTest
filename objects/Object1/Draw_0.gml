if(view_current == view) {
    // If we're drawing Dynamic Tiles...
    if(active == DRAW_MODE.TILEMAP_DYNAMIC) {
        //  tcount = tset.draw();
        tcount = tmap.draw();
    }    
}
