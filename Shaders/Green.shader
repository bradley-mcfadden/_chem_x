shader_type canvas_item;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb = vec3(COLOR.r, 255, COLOR.b);
}