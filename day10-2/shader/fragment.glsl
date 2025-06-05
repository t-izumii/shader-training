uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;
varying float vHeight;



void main() {
    vec2 uv = vUv;

    gl_FragColor = vec4(vec3(vHeight), 1.0);
}
