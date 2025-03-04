// http://www.shadertoy.com/view/MtfXRN
#version 330 core

#define RATE 0.02f
#define MIN_SIZE 2.0f
#define MAX_SIZE 18.0f

uniform float time;
uniform sampler2D imageData;
uniform vec2 screenSize;

#define USE_TILE_BORDER
#define USE_ROUNDED_CORNERS

float ease(float p) {
  return smoothstep(0.0, RATE, p);
}

void main(void) {

  const float textureSamplesCount = 10.0;
  const float textureEdgeOffset = 0.005;
  const float borderSize = 0.75;

  float parameter = ease(clamp(time,0,RATE));
  float tileSize =  mix(MIN_SIZE, MAX_SIZE, parameter);

  tileSize += mod(tileSize, 2.0);
  vec2 tileNumber = floor(gl_FragCoord.xy / tileSize);

  vec4 accumulator = vec4(0.0);
  for (float y = 0.0; y < textureSamplesCount; ++y) {
    for (float x = 0.0; x < textureSamplesCount; ++x) {
      vec2 textureCoordinates = (tileNumber + vec2((x + 0.5)/textureSamplesCount, (y + 0.5)/textureSamplesCount)) * tileSize / screenSize;
      textureCoordinates.y = 1.0 - textureCoordinates.y;
      textureCoordinates = clamp(textureCoordinates, 0.0 + textureEdgeOffset, 1.0 - textureEdgeOffset);
      accumulator += texture(imageData, textureCoordinates);
     }
  }
  
  gl_FragColor = accumulator / vec4(textureSamplesCount * textureSamplesCount);

#if defined(USE_TILE_BORDER) || defined(USE_ROUNDED_CORNERS)
  vec2 pixelNumber = floor(gl_FragCoord.xy - (tileNumber * tileSize));
  pixelNumber = mod(pixelNumber + borderSize, tileSize);
  
#if defined(USE_TILE_BORDER)
  float pixelBorder = step(min(pixelNumber.x, pixelNumber.y), borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#else
  float pixelBorder = step(pixelNumber.x, borderSize) * step(pixelNumber.y, borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#endif
  gl_FragColor *= pow(gl_FragColor, vec4(pixelBorder));
#endif
}
//