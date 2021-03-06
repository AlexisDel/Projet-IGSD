WorkSpace workspace;
Camera camera;
Hud hud;
Map3D map;
Land land;
Gpx gpx;
Railways railways;
Roads roads;
Buildings buildings;
PShader myShader;

void setup() {

  // Initial drawing
  background(0x40);
  
  // Setup Head Up Display
  this.hud = new Hud();
  
  // Prepare local coordinate system grid & gizmo
  this.workspace = new WorkSpace();
  this.camera = new Camera();

  // Load Height Map
  this.map = new Map3D("paris_saclay.data");

  // Load texture
  this.land = new Land(this.map, "paris_saclay.jpg");
  
  // Load the trail data
  this.gpx = new Gpx(this.map, "trail.geojson");
  
  // Load the railways data
  this.railways = new Railways(this.map, "railways.geojson");
  
  // Load the roads data
  this.roads = new Roads(this.map, "roads.geojson");

  // Prepare buildings
  this.buildings = new Buildings(this.map);
  this.buildings.add("buildings_city.geojson", 0xFFaaaaaa);
  this.buildings.add("buildings_IPP.geojson", 0xFFCB9837);
  this.buildings.add("buildings_EDF_Danone.geojson", 0xFF3030FF);
  this.buildings.add("buildings_CEA_algorithmes.geojson", 0xFF30FF30);
  this.buildings.add("buildings_Thales.geojson", 0xFFFF3030);
  this.buildings.add("buildings_Paris_Saclay.geojson", 0xFFee00dd);
  
  /*
  * Config
  */
  hint(ENABLE_KEY_REPEAT);  // Make camera move easier
  
  /*
  * Display setup
  */
  myShader = loadShader("fragmentShader.glsl", "vertexShader.glsl");
  fullScreen(P3D);
  smooth(8);
  frameRate(60);
}

void draw() {
  //Update camera position
  this.camera.update();
  
  //Shader
  shader(myShader);
  
  //Clear the background
  background(0x40);
  
  //Draw PShapes
  this.workspace.update();
  this.land.update();
  this.railways.update();
  this.roads.update();
  this.buildings.update();

  this.gpx.update(this.camera);
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
      // Hide/Show Land
      this.land.toggle();
      break;
    case '+':
      this.camera.adjustRadius(width*0.25);
      break;
    case '-':
      this.camera.adjustRadius(-width*0.25);
      break;
    case 'l':
    case 'L':
      // Enable/Disable sunny vertical lightning
      this.camera.toggle();
      break;
    case 'x':
    case 'X':
      // Enable/Disable GPX track
      this.gpx.toggle();
      break;
    case 'r':
    case 'R':
      // Enable/Disable railways & roads
      this.railways.toggle();
      this.roads.toggle();
      break;
    case 'b':
    case 'B':
      // Enable/Disable buildings
      this.buildings.toggle();
      break;
    }
  }
}


void mouseWheel(MouseEvent event) {
  float ec = event.getCount();
  this.camera.adjustRadius(ec*width*0.1);
}
void mouseDragged() {
  if (mouseButton == CENTER) {

    // Camera Horizontal
    float dx = mouseX - pmouseX;
    this.camera.adjustLongitude(dx*PI/512.0);

    // Camera Vertical
    float dy = mouseY - pmouseY;
    this.camera.adjustColatitude(dy*PI/1024.0);
  }
}

void mousePressed() {
  if (mouseButton == LEFT)
    this.gpx.clic(mouseX, mouseY);
}
