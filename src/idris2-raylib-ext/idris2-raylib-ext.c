#include <idris2-raylib-ext.h>

void *idris2_raylib_ext_nullPtr() {
    return 0;
}

void* idris2_raylib_ext_mkString(char* str) {
    return (void*)str;
}

void idris2_raylib_ext_set_Model_materials_maps(Model model,
                                                int materialIndex,
                                                int mapIndex,
                                                Texture texture) {
    model.materials[materialIndex].maps[mapIndex].texture = texture;
}

