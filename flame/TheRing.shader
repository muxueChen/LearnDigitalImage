// Modification of https://www.shadertoy.com/view/ldlXRS by Nimitz

#iUniform vec3 GlowColor = vec3(0.3, 0.3, 0.3) in {0.0, 1.0}
#iUniform float uScale = 4.0 in {1.0, 40.0}
#iUniform float uIntensity = 1.0 in {0.0, 2.0}
#iUniform float uFireThreshold = 1.0 in {0.5, 3.0}
#iUniform float uLineWidth = 0.1 in {0.0, 1.0}
mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}

float hash1(vec2 p) {
    p  = 50.0*fract( p*0.3183099 );
    return fract( p.x*p.y*(p.x+p.y) );
}

float noise( in vec2 x ) {
    vec2 p = floor(x);
    vec2 w = fract(x);
    vec2 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    float a = hash1(p+vec2(0,0));
    float b = hash1(p+vec2(1,0));
    float c = hash1(p+vec2(0,1));
    float d = hash1(p+vec2(1,1));
    
    return -1.0+2.0*(a + (b-a)*u.x + (c-a)*u.y + (a - b - c + d)*u.x*u.y);
}

float fbm(in vec2 p) {	
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 6.;i++) {
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.;
	}
	return rz;
}

float dualfbm(in vec2 p) {
	vec2 p2 = p*.7;
	vec2 basis = vec2(fbm(p2-iTime*1.6),fbm(p2+iTime*1.7));
	basis = (basis-.5)*0.76;
	p += basis;
	return fbm(p*makem2(iTime*0.15*0.72));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	//setup system
	vec2 p = (fragCoord.xy / iResolution.xy)-0.5;
	p.x *= iResolution.x/iResolution.y;
	p*=uScale;
	float pixleSize = 1.0/iResolution.x;
    float rz = dualfbm(p);
    rz = rz;
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
    
	float dy = abs(uv.y - 0.5)*abs(uv.x - 0.5);
	dy -= uLineWidth * 0.01;
	dy = max(pixleSize*0.1, dy);
    float line = sqrt(sqrt(dy));
    float sm = 1.0 - smoothstep(0.2, 0.5, line);
    float n = 1.0/(1.0 - rz) * uIntensity;
	vec3 col = sm * GlowColor*0.33*n;
	float ligth = uFireThreshold *sqrt(dy);
	col=abs(col)/ligth;
    col = clamp(col, 0.0, 1.0);
	fragColor = vec4(col, pow(line, 2.0));
}