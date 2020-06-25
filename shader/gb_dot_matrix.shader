shader_type canvas_item;
render_mode blend_mix;

//define sizes in pixels
uniform bool enable_dot_matrix = true;
uniform float dot_size = 5.0;

uniform vec4 pallete_color1: hint_color;
uniform vec4 pallete_color2: hint_color;
uniform float contrast = 0.75;

uniform sampler2D lcd_back: hint_albedo;

void fragment() {
	vec4 lcd_back_tex = texture(lcd_back, UV) * pallete_color1;
	vec4 pixels;
	
	int modulusX = int(mod(FRAGCOORD.x, dot_size));
	int modulusY = int(mod(FRAGCOORD.y, dot_size));
	
	vec4 dot_core = vec4(0.0,  0.0, 0.0, 1.0);
	
	vec4 foreground = texture(TEXTURE, UV);
	vec4 foreground_colored = vec4(pallete_color2.x, pallete_color2.y, pallete_color2.z, 1.0 - foreground.x);
	foreground_colored.a *= contrast;
	
	if(enable_dot_matrix){
		if(modulusX == 0 || modulusY == 0){
			foreground_colored.a = 0.0;
		}
	}
	
	COLOR = mix(foreground_colored, lcd_back_tex, (1.0 - foreground_colored.a));
}