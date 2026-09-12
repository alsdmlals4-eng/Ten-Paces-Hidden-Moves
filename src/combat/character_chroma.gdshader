shader_type canvas_item;
render_mode unshaded;

// Display-only keying. The source PNG remains an unmodified RGB generation.
void fragment() {
    vec4 pixel = COLOR;
    float excess_green = pixel.g - max(pixel.r, pixel.b);
    float key = smoothstep(0.10, 0.42, excess_green);
    pixel.a *= 1.0 - key;
    pixel.g = min(pixel.g, max(pixel.r, pixel.b) + 0.07);
    COLOR = pixel;
}
