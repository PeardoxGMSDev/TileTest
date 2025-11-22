// ESC = Exit
if(keyboard_check(vk_escape)) {
    game_end();
}

// Space = Restart in other tile draw mode
if(keyboard_check(vk_space)) {
    global.active = !global.active;
    game_restart();
}