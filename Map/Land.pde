public class Land {

  PShape shadow;
  PShape wireFrame;
  PShape satellite;

  /**
   * Returns a Land object.
   * Prepares land shadow, wireframe and textured shape
   * @param map Land associated elevation Map3D object
   * @return Land object
   */
  Land(Map3D map, String textrueFilename) {

    final float tileSize = 25.0f;

    float w = (float)Map3D.width;
    float h = (float)Map3D.height;

    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();
    this.shadow.vertex(-w/2.0f, -h/2.0f, 0);
    this.shadow.vertex(w/2.0f, -h/2.0f, 0);
    this.shadow.vertex(w/2.0f, h/2.0f, 0);
    this.shadow.vertex(-w/2.0f, h/2.0f, 0);
    this.shadow.endShape();

    // Wireframe shape
    this.wireFrame = createShape();
    this.wireFrame.beginShape(QUADS);
    this.wireFrame.noFill();
    this.wireFrame.stroke(#888888);
    this.wireFrame.strokeWeight(0.5f);

    for (float i=-w/2.0f; i<w/2.0f; i+=tileSize) {
      for (float j=-h/2.0f; j<h/2.0f; j+=tileSize) {   

        Map3D.ObjectPoint onw = map.new ObjectPoint(i, j);
        Map3D.ObjectPoint one = map.new ObjectPoint(i+tileSize, j);
        Map3D.ObjectPoint ose = map.new ObjectPoint(i+tileSize, j+tileSize);
        Map3D.ObjectPoint osw = map.new ObjectPoint(i, j+tileSize);

        this.wireFrame.vertex(onw.x, onw.y, onw.z);
        this.wireFrame.vertex(one.x, one.y, one.z);
        this.wireFrame.vertex(ose.x, ose.y, ose.z);
        this.wireFrame.vertex(osw.x, osw.y, osw.z);
      }
    }
    this.wireFrame.endShape();


    //Texutre
    File ressource = dataFile(textrueFilename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Land texture file " + textrueFilename + " not found.");
      exitActual();
    }
    PImage uvmap = loadImage(textrueFilename);
    
    this.satellite = createShape();
    this.satellite.beginShape(QUAD);
    this.satellite.noFill();
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    this.satellite.texture(uvmap);
    
    for (float i=-w/2.0f; i<w/2.0f; i+=tileSize) {
      for (float j=-h/2.0f; j<h/2.0f; j+=tileSize) {   

        Map3D.ObjectPoint onw = map.new ObjectPoint(i, j);
        float ionwx = ( (onw.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float ionwy = ( (onw.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nonw = onw.toNormal();
        this.satellite.normal(nonw.x, nonw.y, nonw.z);
        this.satellite.vertex(onw.x, onw.y, onw.z, ionwx, ionwy);
        
        Map3D.ObjectPoint one = map.new ObjectPoint(i+tileSize, j);
        float ionex = ( (one.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float ioney = ( (one.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector none = one.toNormal();
        this.satellite.normal(none.x, none.y, none.z);
        this.satellite.vertex(one.x, one.y, one.z, ionex, ioney);
        
        Map3D.ObjectPoint ose = map.new ObjectPoint(i+tileSize, j+tileSize);
        float iosex = ( (ose.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float iosey = ( (ose.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nose = ose.toNormal();
        this.satellite.normal(nose.x, nose.y, nose.z);
        this.satellite.vertex(ose.x, ose.y, ose.z, iosex, iosey);
        
        Map3D.ObjectPoint osw = map.new ObjectPoint(i, j+tileSize);
        float ioswx = ( (osw.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float ioswy = ( (osw.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nosw = osw.toNormal();
        this.satellite.normal(nosw.x, nosw.y, nosw.z);
        this.satellite.vertex(osw.x, osw.y, osw.z, ioswx, ioswy);
        
      }
    }
    
    this.satellite.endShape();


    // Shapes initial visibility
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }

  public void update() {
    shape(this.shadow);
    shape(this.wireFrame);
    shape(this.satellite);
  }

  /**
   * Toggle wireFrame & shadow visibility.
   */
  public void toggle() {
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());
  }
}
