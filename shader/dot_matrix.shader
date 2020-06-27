shader_type canvas_item;
render_mode blend_mix;

uniform float dot_size = 4.0;

uniform vec4 pallete_color1: hint_color;
uniform vec4 pallete_color2: hint_color;

uniform bool use_image_for_lcd = true;
uniform sampler2D lcd_back: hint_albedo;

uniform float border_size = 40.0;
uniform bool enable_dot_matrix = true;

uniform float glare_amount = 0.15;
uniform float brightness : hint_range(0, 1) = 0.4;
uniform float pixel_shadow_amount : hint_range(0, 1) = 0.3;

uniform float lcd_dark_square_transparency : hint_range(0, 1) = 0.03;

void fragment(){
	vec4 previous_pass = texture(TEXTURE, UV);
	vec3 glare = vec3((FRAGCOORD.x / (1.0 / TEXTURE_PIXEL_SIZE.x)) / 2.0 + (FRAGCOORD.y / (1.0 / TEXTURE_PIXEL_SIZE.y)) / 2.0);
	
	// SETUP LCD BACK
	vec4 lcd_back_tex;
	if(use_image_for_lcd){
		lcd_back_tex = texture(lcd_back, UV) * pallete_color1;
	}else{
		lcd_back_tex = pallete_color1;
	}
	
	COLOR = lcd_back_tex;

	int modulusX = int(mod(FRAGCOORD.x - (1.0 / TEXTURE_PIXEL_SIZE.x), dot_size));
	int modulusY = int(mod(FRAGCOORD.y - (1.0 / TEXTURE_PIXEL_SIZE.x), dot_size));
	
	// SETUP LCD SQUARES
	if(enable_dot_matrix){
		if(	FRAGCOORD.x < (1.0/TEXTURE_PIXEL_SIZE.x) - border_size
			&& FRAGCOORD.x > border_size
			&& FRAGCOORD.y > border_size
			&& FRAGCOORD.y < (1.0/TEXTURE_PIXEL_SIZE.y) - border_size){
			
			if((modulusX != 0 && modulusY != 0)){
				COLOR.xyz = mix(COLOR.xyz, vec3(0.0,0.0,0.0), lcd_dark_square_transparency);
			}
		}
	}

	// SETUP COLORED PIXELS
	float pixel_whiteness = previous_pass.x;
	vec4 colored_frame = vec4(pallete_color2.x - 0.3, pallete_color2.y - 0.3, pallete_color2.z - 0.3, brightness * (1.0 - previous_pass.x) * previous_pass.a);
	
	if(abs(pixel_whiteness - 248.0/255.0) < 0.01 || COLOR.a == 0.0){

	}else{
		if(enable_dot_matrix){
			if((modulusX != 0 && modulusY != 0)){
				COLOR = mix(colored_frame, COLOR, 1.0 - colored_frame.a);
			}else{
				//PRIMITIVE SHADOW
				if(colored_frame.a > 0.0){
					COLOR = mix(COLOR, vec4(0.0,0.0,0.0,1.0), pixel_shadow_amount * brightness * (1.0 - pixel_whiteness * 0.4));
				}
			}
		}else{
			COLOR = mix(colored_frame, COLOR, 1.0 - colored_frame.a);
		}
	}
	
	COLOR.xyz += glare * glare_amount;
}