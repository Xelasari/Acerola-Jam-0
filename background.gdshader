shader_type canvas_item;

uniform vec2 motion = vec2(1.0);
uniform float scale = 1.0;
uniform vec2 offset = vec2(160, 90);

void vertex() {
	UV = (VERTEX + offset + TIME * motion) * TEXTURE_PIXEL_SIZE * (1.0/scale);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
