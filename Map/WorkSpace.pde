/**
 * Handle Gizmo and grid
 */
public class WorkSpace {

  PShape gizmo;
  PShape grid;

  /**
   * Returns WorkSpace object built with default grid values
   */
  WorkSpace() {
    createWorkspace(250, 100);
  }

  /**
   * Returns WorkSpace object built with custom grid values
   */
  WorkSpace(int gridSize, int squareSize) {
    createWorkspace(gridSize, squareSize);
  }

  /**
   * Generate Gizmo and Grid
   * @param gridSize : number of square
   * @param squareSize : square size in meter
   */
  public void createWorkspace(int gridSize, int squareSize) {

    gridSize = int(gridSize/2.0);

    // Gizmo
    this.gizmo = createShape();
    this.gizmo.beginShape(LINES);
    this.gizmo.noFill();

    //Main Lines
    this.gizmo.strokeWeight(4.0f);
    // Red X
    this.gizmo.stroke(0xAAFF3F7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(100, 0, 0);
    // Green Y
    this.gizmo.stroke(0xAA3FFF7F);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, 100, 0);
    // Blue Z
    this.gizmo.stroke(0xAA3F7FFF);
    this.gizmo.vertex(0, 0, 0);
    this.gizmo.vertex(0, 0, 100);

    //Small lines
    this.gizmo.strokeWeight(1.0f);
    // Red X
    this.gizmo.stroke(0xAAFF3F7F);
    this.gizmo.vertex(-gridSize*squareSize, 0, 0);
    this.gizmo.vertex(gridSize*squareSize, 0, 0);
    // Green Y
    this.gizmo.stroke(0xAA3FFF7F);
    this.gizmo.vertex(0, -gridSize*squareSize, 0);
    this.gizmo.vertex(0, gridSize*squareSize, 0);


    this.gizmo.endShape();

    // Grid
    this.grid = createShape();
    this.grid.beginShape(QUADS);
    this.grid.noFill();
    this.grid.stroke(0x77836C3D);
    this.grid.strokeWeight(0.5f);
    for (int i=-gridSize*squareSize; i<gridSize*squareSize; i+=squareSize) {
      for (int j=-gridSize*squareSize; j<gridSize*squareSize; j+=squareSize) {

        //Build a box
        this.grid.vertex(i, j, 0); // Top left corner
        this.grid.vertex(i+squareSize, j, 0); // Top right corner
        this.grid.vertex(i+squareSize, j+squareSize, 0); //Bottom right corner
        this.grid.vertex(i, j+squareSize, 0); //Bottom left corner
      }
    }
    this.grid.endShape();
  }

  /**
   * Update Grid and Gizmo display
   */
  void update() {
    shape(this.gizmo);
    shape(this.grid);
  }

  /**
   * Toggle Grid & Gizmo visibility.
   */
  void toggle() {
    this.gizmo.setVisible(!this.gizmo.isVisible());
    this.grid.setVisible(!this.grid.isVisible());
  }
}
