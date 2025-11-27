if(view_current == view) {
    // If we're drawing Dynamic Tiles...
    if(active == DRAW_MODE.TILEMAP_DYNAMIC) {
        if(!tset.has_border) {
        //    tset.set_border(16, 16, 8);
            tset.set_border(2,2);
        }
        tcount = tmap.draw();
        /*
        draw_sprite(tset.sprite, 0, 0, 0);
        draw_sprite(tset.border_sprite, 0, sprite_get_width(tset.sprite) + 64, 0);
        draw_sprite(gms_16border, 0, sprite_get_width(tset.sprite) + 64 + sprite_get_width(tset.border_sprite) + 64, 0);
         */
    }    
}
