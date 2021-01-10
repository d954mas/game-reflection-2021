   varying mediump vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;
varying mediump vec4 var_light;

uniform highp sampler2D tex0;
uniform lowp vec4 tint;
uniform highp vec4 line;
uniform highp vec4 screen;
void main()
{
    // Pre-multiply alpha since all runtime textures already are
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    highp vec4 color = texture2D(tex0, var_texcoord0.xy) * tint_pm;
    if(line.x != 0.0 ||  line.y != 0.0  || line.z != 0.0){
        highp float coord_x = var_texcoord0.x*screen.x, coord_y = var_texcoord0.y*screen.y;
    highp float number = line.x *coord_x + line.y * coord_y + line.z;
   // float scale_x =640/540;
    //float scale_y =1260/960;

   // float scale_x =1;
   // float scale_y =1;
    
        if(number > 0.0){
            highp float x0 = coord_x, y0 = coord_y;
            highp float a = line.x, b = line.y, c = line.z;
            highp float calc_1 = (a * x0 + b*y0 + c);
            highp float calc_2 = (a*a + b*b);
            highp float x = x0 - (2.0 * a * calc_1)/calc_2;
            highp float y = y0 - (2.0 * b * calc_1)/calc_2;
            color = texture2D(tex0, vec2(x/screen.x,y/screen.y)) * tint_pm;
            if (color.r == 1.0 && color.g == 0.0 && color.b == 0.0) {
                gl_FragColor =  vec4(color.rgb, tint.w);
            }else{
                gl_FragColor =  vec4(vec3(1), tint.w);
            }
           //gl_FragColor =  vec4(vec3(0,0,1), 0.5);
        }else{
           if (color.r == 1.0 && color.g == 0.0 && color.b == 0.0 ) {
                gl_FragColor =  color;
            }else{
               discard;
            }
           // gl_FragColor =  vec4(vec3(0,1,0), 0.5);
        }
   }else{
        if (color.r == 1.0 && color.g == 0.0 && color.b == 0.0 ) {
            gl_FragColor =  color;
        }else{
           discard;
        }
    }

   // }else{
    //    discard;
    //}
}

