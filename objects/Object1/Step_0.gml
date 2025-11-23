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