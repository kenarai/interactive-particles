// @author brunoimbrizi / http://brunoimbrizi.com

precision highp float;

attribute float pindex;
attribute vec3 position;
attribute vec3 offset;
attribute vec2 uv;
attribute float angle;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

uniform float uTime;
uniform float uRandom;
uniform float uDepth;
uniform float uSize;
uniform vec2 uTextureSize;
uniform sampler2D uTexture;
uniform sampler2D uTouch;

varying vec2 vPUv;
varying vec2 vUv;

#pragma glslify: snoise2 = require(glsl-noise/simplex/2d)

float random(float n) {
	return fract(sin(n) * 43758.5453123);
}

void main() {
	vUv = uv;

	// particle uv
	vec2 puv = offset.xy / uTextureSize;
	vPUv = puv;

	// pixel color
	vec4 colA = texture2D(uTexture, puv);
	float grey = colA.r * 0.1 + colA.g * 0.1 + colA.b * 0.1;

	// displacement
	vec3 displaced = offset;
	// randomise
	displaced.xy += vec2(random(pindex) - 0.5, random(offset.x + pindex) - 0.5) * uRandom;
	float rndz = (random(pindex) + snoise_1_2(vec2(pindex * 0.9, uTime * 0.9)));
	displaced.z += rndz * (random(pindex) * 9.0 * uDepth);
	// center
	displaced.xy -= uTextureSize * 0.5;

	// touch
	float t = texture2D(uTouch, puv).r;
	displaced.z += tan(angle * t)* t * 20.0 * rndz;
	displaced.x += cos(angle * t) * t * 40.0 * rndz;
	displaced.y += sin(angle * t) * t * 40.0 * rndz;

	// particle size
	float psize = (snoise_1_2(vec2(uTime, pindex) * 0.5) + 2.0);
	psize *= max(grey, 0.5);
	psize *= uSize;

	// final position
	vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);
	mvPosition.xyz += position * psize;
	vec4 finalPosition = projectionMatrix * mvPosition;

	gl_Position = finalPosition;
}
