WorkSpace workspace;
Camera camera;
Hud hud;

void setup() {

  // Display setup
  fullScreen(P3D);
  //size(1000, 1000, P3D);
  this.hud = new Hud();  // Setup Head Up Display
  smooth(8);
  frameRate(60);

  hint(ENABLE_KEY_REPEAT);  // Make camera move easier

  // Initial drawing
  background(0x40);

  // Prepare local coordinate system grid & gizmo
  this.workspace = new WorkSpace(100, 250);
  this.camera = new Camera();
}

void draw() {

  this.camera.update();

  //Clear
  background(0x40);
  
  this.workspace.update();
  this.hud.update(this.camera);
}

void keyPressed() {

  if (key == CODED) {
    switch (keyCode) {
    case UP:
      this.camera.adjustColatitude(-PI/52.0);
      break;
    case DOWN:
      this.camera.adjustColatitude(PI/52.0);
      break;
    case LEFT:
      this.camera.adjustLongitude(PI/24.0);
      break;
    case RIGHT:
      this.camera.adjustLongitude(-PI/24.0);
      break;
    }
  } else {
    switch (key) {
    case 'w':
    case 'W':
      // Hide/Show grid & Gizmo
      this.workspace.toggle();
      break;
    case '+':
      this.camera.adjustRadius(width*0.25);
      break;
    case '-':
      this.camera.adjustRadius(-width*0.25);
      break;
    }
  }
}


void mouseWheel(MouseEvent event) {
  float ec = event.getCount();
  this.camera.adjustRadius(ec*width*0.25);
}
void mouseDragged() {
  if (mouseButton == CENTER) {

    // Camera Horizontal
    float dx = mouseX - pmouseX;
    this.camera.adjustLongitude(dx*PI/256.0);

    // Camera Vertical
    float dy = mouseY - pmouseY;
    this.camera.adjustColatitude(dy*PI/512.0);
  }
}
