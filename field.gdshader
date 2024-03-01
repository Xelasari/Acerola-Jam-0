shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
	
}
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D distortionTexture;

void fragment() {
	// Called for every pixel the material is visible on.
	
	
	vec2 distoredUV = SCREEN_UV + texture(distortionTexture, UV).r;
	vec4 pixelColor = texture(screen_texture, distoredUV);
	COLOR = pixelColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
