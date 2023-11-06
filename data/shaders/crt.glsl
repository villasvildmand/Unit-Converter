varying vec4 vertTexCoord;

uniform float curvature = 6.0;
uniform float vignetteWidth = 20.0;
uniform float scanFalloff = 0.5;
uniform highp float time;
uniform sampler2D texture;
uniform ivec2 screenSize;

float rand(vec2 coord){
    return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    //crt effect inspired by https://www.youtube.com/watch?v=aWdySZ0BtJs
    vec2 uv = vertTexCoord.st;
    uv = uv * 2.0 - 1.0; //puts uv in range -1 to 1
    vec2 offset = uv.yx / curvature;
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5; //puts uv back in range 0 to 1

    vec4 color = texture2D(texture, uv);
    if (uv.x <= 0.0 || uv.x >= 1.0 || uv.y <= 0.0 || uv.x >= 1.0) {
        color = vec4(0.0);
    }

    uv = uv * 2.0 - 1.0;
    vec2 vignette = vignetteWidth / screenSize.xy;
    vignette = smoothstep(vec2(0.0), vignette, 1.0 - abs(uv));
    vignette = clamp(vignette, 0.0, 1.0);

    color.g *= (sin(vertTexCoord.st.y * screenSize.y * 2.0) + 1.0) * 0.15 + 1.0;
    color.rb *= (cos(vertTexCoord.st.y * screenSize.y * 2.0) + 1.0) * 0.1 + 1.0;

    //scanline is original
    float scan = 1.0 - (int(time*2.0) % screenSize.y)/float(screenSize.y)*(1+2*scanFalloff) + scanFalloff;
    float val = max(scan - vertTexCoord.st.y, 0.0)*(1.0/scanFalloff);
    if (val > 1.0) {
        val = 0.0;
    }
    gl_FragColor = clamp(color, 0.0, 1.0) * vignette.x * vignette.y * (val*val*0.35+1.0);
}