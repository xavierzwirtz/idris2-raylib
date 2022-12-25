#include <stdlib.h>
#include <raylib.h>
#include <string.h>

void *idris2_raylib_ext_nullPtr();
void* idris2_raylib_ext_mkString(char* str);
void idris2_raylib_ext_set_Model_materials_maps(Model model,
                                                int materialIndex,
                                                int mapIndex,
                                                Texture texture);
