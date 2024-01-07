shader_type canvas_item;

void fragment() {
	// Place fragment code here.
	COLOR = texture(TEXTURE, UV); //read from texture
	COLOR.r = 0.2; //set blue channel to 1.0
	COLOR.g = 0.1;
}
