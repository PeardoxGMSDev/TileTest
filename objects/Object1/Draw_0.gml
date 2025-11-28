if(view_current == view) {
    // If we're drawing Dynamic Tiles...
    if(active != DRAW_MODE.TILEMAP_BUILTIN) {
        if(!tset.has_border) {
            tset.set_border(16, 16, 0);
        }
    }
    if(active == DRAW_MODE.TILEMAP_DYNAMIC_DRAW) {
        tcount = tmap.draw();
    } else if(active == DRAW_MODE.TILEMAP_CHECK) {
        draw_sprite(tset.sprite, 0, 0, 40);
        draw_sprite(tset.border_sprite, 0, sprite_get_width(tset.sprite) + 64, 40);
        draw_sprite(gms_16border, 0, sprite_get_width(tset.sprite) + 64 + sprite_get_width(tset.border_sprite) + 64, 40);
    }    
}
