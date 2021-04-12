public class Hud {
  
  private PMatrix3D hud;
  
  /**
   * Returns Hud object
   */
  Hud() {
    // Should be constructed just after P3D size() or fullScreen()
    this.hud = g.getMatrix((PMatrix3D) null);
  }
  
  /**
   * Save the initial matrix and prepare the new one for Hud tweaks
   */
  private void begin() {
    g.noLights();
    g.pushMatrix();
    g.hint(PConstants.DISABLE_DEPTH_TEST);
    g.resetMatrix();
    g.applyMatrix(this.hud);
  }
  
  /**
   * Restore initial matrix with Hud tweaks
   */
  private void end() {
    g.hint(PConstants.ENABLE_DEPTH_TEST);
    g.popMatrix();
  }
  
  /**
   * Display FPS counter
   */
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
  
  /**
   * Display Camera Position
   */
  private void displayCamera(Camera camera){
    // Top left area
    noStroke();
    fill(96);
    rectMode(CORNER);
    rect(10, 10, 150, 100, 5, 5, 5, 5);
    
    // Tittle : Top box (10, 10, 150, 30) 
    fill(0xF0);
    textMode(SHAPE);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Camera",10, 10, 150, 30);
    
    // Data : Bottom box (15, 40, 150, 60)
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
  
  /**
   * Update Hud display
   */
  public void update(Camera camera){
    this.begin();
    this.displayFPS();
    displayCamera(camera);
    this.end();
  }
}
