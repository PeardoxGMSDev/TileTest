/*
for (var i = 0; i < instance_count; i++) {
    if(is_struct(instance_id[i])) {
        // var _struct = instance_id[i];
        if(struct_exists(instance_id[i], "ClassName")) {
            show_debug_message("Found instance of " + instance_id[i].ClassName)    
        }
    }
}
*/
if(typeof(tset) == "struct") {
    tset.free();
    delete(tset);
}

if(typeof(tmap) == "struct") {
    tmap.free();
    delete(tmap);
}


