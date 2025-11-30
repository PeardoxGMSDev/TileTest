if(view_current == view) {
    // If we're drawing Dynamic Tiles...
    if(active != DRAW_MODE.TILEMAP_BUILTIN) {
        if(!tset.has_border) {
            tset.set_border(16, 16, 0);
        }
    }
    if(active == DRAW_MODE.TILEMAP_DYNAMIC_DRAW) {
        if(unbound) {
            msg = tmap.remap_tiles();
            tcount = tmap.draw(active);
        } else {
            msg = tmap.remap_tiles(lookat_x - (virtual_width div 2), lookat_y - (virtual_height div 2), lookat_x + (virtual_width div 2), lookat_y + (virtual_height div 2));
            tcount = tmap.draw(active, lookat_x - (virtual_width div 2), lookat_y - (virtual_height div 2), lookat_x + (virtual_width div 2), lookat_y + (virtual_height div 2));
        }
    } else if(active == DRAW_MODE.TILEMAP_CHECK) {
        draw_sprite(tset.sprite, 0, 0, 40);
        draw_sprite(tset.border_sprite, 0, sprite_get_width(tset.sprite) + 64, 40);
        draw_sprite(gms_16border, 0, sprite_get_width(tset.sprite) + 64 + sprite_get_width(tset.border_sprite) + 64, 40);
    } else if(active == DRAW_MODE.TILEMAP_DYNAMIC_BUFFER_ROW) {
        tcount = tmap.draw(active);
    }
}

draw_set_colour(c_red);
draw_line(lookat_x, lookat_y - 50, lookat_x ,lookat_y + 50);
draw_line(lookat_x -50 ,lookat_y, lookat_x + 50 ,lookat_y);
