#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
smooth in vec4 vertColor;
smooth in vec4 vertTexCoord;
smooth in vec2 vertHeat;

void main() {
  gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  if (vertHeat[0] < 500) {
    gl_FragColor.g += 255/(vertHeat[0]*10);
  }
  if (vertHeat[1] < 500) {
    gl_FragColor.r += 255/(vertHeat[1]*10);
  }
}
