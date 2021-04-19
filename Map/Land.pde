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
    final float tileSizeSatellite = 10.0f;

    float w = (float)Map3D.width;
    float h = (float)Map3D.height;

    // Shadow shape
    this.shadow = createShape();
    this.shadow.beginShape(QUADS);
    this.shadow.fill(0x992F2F2F);
    this.shadow.noStroke();
    
    this.shadow.normal(1,0,0);
    // Top left map corner
    this.shadow.vertex(-w/2.0f, -h/2.0f, 0);
    // Top right map corner
    this.shadow.vertex(w/2.0f, -h/2.0f, 0);
    // Bottom right map corner
    this.shadow.vertex(w/2.0f, h/2.0f, 0);
    // Bottom left map corner
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

        //Build box
        Map3D.ObjectPoint nw = map.new ObjectPoint(i, j); // Top left corner
        Map3D.ObjectPoint ne = map.new ObjectPoint(i+tileSize, j); // Top right corner
        Map3D.ObjectPoint se = map.new ObjectPoint(i+tileSize, j+tileSize); // Bottom right corner
        Map3D.ObjectPoint sw = map.new ObjectPoint(i, j+tileSize); // Bottom left corner

        // Add box to wireFrame
        this.wireFrame.vertex(nw.x, nw.y, nw.z);
        this.wireFrame.vertex(ne.x, ne.y, ne.z);
        this.wireFrame.vertex(se.x, se.y, se.z);
        this.wireFrame.vertex(sw.x, sw.y, sw.z);
      }
    }
    this.wireFrame.endShape();


    // Texutre
    File ressource = dataFile(textrueFilename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: Land texture file " + textrueFilename + " not found.");
      exitActual();
    }
    // Load texture
    PImage uvmap = loadImage(textrueFilename);

    this.satellite = createShape();
    this.satellite.beginShape(QUAD);
    this.satellite.noFill();
    this.satellite.noStroke();
    this.satellite.emissive(0xD0);
    // load texture to sattelite
    this.satellite.texture(uvmap);

    //Poi distance
    Poi pointsOfInterests = new Poi();
    ArrayList<Map3D.ObjectPoint> BykeParkingDistances = pointsOfInterests.getPoints("bicycle_parking.geojson");
    ArrayList<Map3D.ObjectPoint> Bench_Picnic_TableDistances = pointsOfInterests.getPoints("bench&picnic_table.geojson");
    
    JSONArray poiDistances = pointsOfInterests.getPoiDistances(w, h, tileSizeSatellite, BykeParkingDistances, Bench_Picnic_TableDistances);

    //Build satellite
    int index = 0;
    for (float i=-w/2.0f; i<w/2.0f; i+=tileSizeSatellite) {
      for (float j=-h/2.0f; j<h/2.0f; j+=tileSizeSatellite) {

        // Build tile

        // North West corner
        Map3D.ObjectPoint nw = map.new ObjectPoint(i, j);
        float nwU = ( (nw.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float nwV = ( (nw.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nnw = nw.toNormal();
        this.satellite.normal(nnw.x, nnw.y, nnw.z);
        this.satellite.attrib("heat", poiDistances.getJSONObject(index).getInt("nearestBykeParkingDistance"), poiDistances.getJSONObject(index).getInt("nearestBench&Picnic_TableDistance"));
        this.satellite.vertex(nw.x, nw.y, nw.z, nwU, nwV);

        // North Est corner
        Map3D.ObjectPoint ne = map.new ObjectPoint(i+tileSizeSatellite, j);
        float neU = ( (ne.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float neV = ( (ne.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nne = ne.toNormal();
        this.satellite.normal(nne.x, nne.y, nne.z);
        this.satellite.vertex(ne.x, ne.y, ne.z, neU, neV);

        // South Est corner
        Map3D.ObjectPoint se = map.new ObjectPoint(i+tileSizeSatellite, j+tileSizeSatellite);
        float seU = ( (se.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float seV = ( (se.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nse = se.toNormal();
        this.satellite.normal(nse.x, nse.y, nse.z);
        this.satellite.vertex(se.x, se.y, se.z, seU, seV);

        // South West corner
        Map3D.ObjectPoint sw = map.new ObjectPoint(i, j+tileSizeSatellite);
        float swU = ( (sw.x - -w/2.0f) / (w/2.0f - -w/2.0f) ) * uvmap.width;
        float swV = ( (sw.y - -h/2.0f) / (h/2.0f - -h/2.0f) ) * uvmap.height;
        PVector nsw = sw.toNormal();
        this.satellite.normal(nsw.x, nsw.y, nsw.z);
        this.satellite.vertex(sw.x, sw.y, sw.z, swU, swV);
        
        index++;
      }
    }

    this.satellite.endShape();


    // Shapes initial visibility
    this.shadow.setVisible(true);
    this.wireFrame.setVisible(false);
    this.satellite.setVisible(true);
  }

  /**
   * Update Land display
   */
  public void update() {
    shape(this.wireFrame);
    shape(this.satellite);
    resetShader();
    shape(this.shadow);
  }

  /**
   * Toggle wireFrame & shadow visibility.
   */
  public void toggle() {
    this.wireFrame.setVisible(!this.wireFrame.isVisible());
    this.satellite.setVisible(!this.satellite.isVisible());
  }
}
