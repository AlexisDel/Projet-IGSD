class Hud {
  private PMatrix3D hud;
  Hud() {
    // Should be constructed just after P3D size() or fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
  }
  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }

  private void displayFPS() {
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, height-30, 60, 20, 5, 5, 5, 5);
    // Value
    fill(0xF0);
    textMode(SHAPE);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(String.valueOf((int)frameRate) + " fps", 40, height-20);
  }
  
  private void displayCamera(Camera camera){
    // Bottom left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 10, 150, 100, 5, 5, 5, 5);
    
    fill(0xF0);
    textMode(SHAPE);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Camera",10, 10, 150, 30);
    
    textSize(14);
    textAlign(LEFT, TOP);
    text("Longitude",15, 40, 150, 60);
    textAlign(RIGHT, TOP);
    text(String.valueOf(round(camera.sphericalCoordinates.longitude*180/PI) + "°"), 15, 40, 140, 60);
    
    textAlign(LEFT, CENTER);
    text("Latitude",15, 40, 150, 60);
    textAlign(RIGHT, CENTER);
    text(String.valueOf(round((PI/2.0-camera.sphericalCoordinates.colatitude)*180/PI) + "°"), 15, 40, 140, 60);
    
    textAlign(LEFT, BOTTOM);
    text("Radius",15, 40, 150, 60);
    textAlign(RIGHT, BOTTOM);
    text(String.valueOf(round(camera.sphericalCoordinates.radius)) + "m", 15, 40, 140, 60);
            
  }
  
  public void update(Camera camera){
    this.begin();
    this.displayFPS();
    displayCamera(camera);
    this.end();
  }
}
