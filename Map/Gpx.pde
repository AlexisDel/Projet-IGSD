public class Gpx {

  PShape track;
  PShape posts;
  PShape thumbtacks;
  StringList descriptions;
  Integer selectedThumbtack;

/**
   * Returns a Gpx object.
   * Prepares trail with interactive thumbtacks
   * @param map associated elevation Map3D object
   * @param gpxFileName trail's path coordinates associated geojson file  
   * @return Gpx object
   */

  Gpx(Map3D map, String gpxFilename) {
    
    //Setting the selected thumbtack to no thumbtack
    this.selectedThumbtack = null;

    // Check ressources
    File ressource = dataFile(gpxFilename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + gpxFilename + " not found.");
      return;
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(gpxFilename);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return;
    }

    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return;
    }
    //Begins drawing the track
    this.track = createShape();
    this.track.beginShape();
    this.track.noFill();
    this.track.stroke(127, 80, 127);
    this.track.strokeWeight(5);
    
    //Begins drawing each thumbtack's post
    this.posts = createShape();
    this.posts.beginShape(LINES);
    this.posts.stroke(255);
    this.posts.strokeWeight(1);
    
    //Begins drawing the thumbtacks
    this.thumbtacks = createShape();
    this.thumbtacks.beginShape(POINTS);
    this.thumbtacks.stroke(240, 90, 90);
    this.thumbtacks.strokeWeight(10);
    
    //Initializes a StringList to store each Thumbtack description
    this.descriptions = new StringList();
    
    //Evaluates each feature's geometry in the JSON
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

      case "LineString": 
        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null)
          //Adds a line the trail
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
            Map3D.ObjectPoint op = map.new ObjectPoint(gp);
            this.track.vertex(op.x, op.y, op.z);
          }
        break;

      case "Point":        
        // GPX WayPoint
        if (geometry.hasKey("coordinates")) {

          JSONArray point = geometry.getJSONArray("coordinates");
          String description = "Pas d'information.";
          if (feature.hasKey("properties")) {
            description = feature.getJSONObject("properties").getString("desc", 
              description);
          }
          //adds the description of each waypoint to the StringList
          this.descriptions.append(description);
          
          //Adds a thumbtack and it's post.
          Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          Map3D.ObjectPoint op = map.new ObjectPoint(gp);
          this.posts.vertex(op.x, op.y, op.z);
          this.posts.vertex(op.x, op.y, op.z+50);
          this.thumbtacks.vertex(op.x, op.y, op.z+50);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometrytype not handled.");
        break;
      }
    }

    this.track.endShape();
    this.posts.endShape();
    this.thumbtacks.endShape();

    // Shapes initial visibility
    this.track.setVisible(true);
    this.posts.setVisible(true);
    this.thumbtacks.setVisible(true);
  }

/**
   * Update Gpx display
   * @param camera used to update the current camera position
   */
  public void update(Camera camera) {
    shape(this.track);
    shape(this.posts);
    shape(this.thumbtacks);
    displayDescription(this.selectedThumbtack, camera);
  }
  
/**
   * Toggle track, thumbtacks and posts.
   */
  public void toggle() {
    this.track.setVisible(!this.track.isVisible());
    this.posts.setVisible(!this.posts.isVisible());
    this.thumbtacks.setVisible(!this.thumbtacks.isVisible());
    resetThumbtack();
  }

/**
   * Verifies if any thumbtack has been clicked on,
   * if so changes its color and assigns it to the
   * selectedThumbtack attribut.
   * @params x,y expected to be mouseX, mouseY 
   * when function is called.
   */
  public void clic(int x, int y) {
  
    this.selectedThumbtack = null;
    for (int i=0; i <this.thumbtacks.getVertexCount(); i++) {     
      PVector v = this.thumbtacks.getVertex(i);
      float xOnScreen = screenX(v.x, v.y, v.z);
      float yOnScreen = screenY(v.x, v.y, v.z);

      if ( dist(x, y, xOnScreen, yOnScreen) < 10) {
        this.selectedThumbtack = i;
        this.thumbtacks.setStroke(i, 0xFF3FFF7F);
      }
      else {
        this.thumbtacks.setStroke(i, 0xFFFF3F3F);
      }
    }
  }
  
  /**
   * displays the description of the selected thumbtack
   * @param index of the selected thumbtack
   * @param camera
   */
  private void displayDescription(Integer index, Camera camera) {
    if (index != null) {
      //Vector of the selected thumbtack
      PVector hit = this.thumbtacks.getVertex(index);
      //Displays the description 
      pushMatrix();
      lights();
      fill(0xFFFFFFFF);
      translate(hit.x, hit.y, hit.z + 10.0f);
      rotateZ(camera.sphericalCoordinates.longitude-HALF_PI);
      rotateX(-camera.sphericalCoordinates.colatitude);
      g.hint(PConstants.DISABLE_DEPTH_TEST);
      textMode(SHAPE);
      textSize(48);
      textAlign(LEFT, CENTER);
      text(descriptions.get(index), 50, 0);
      g.hint(PConstants.ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
  /**
  * Resets all the thumbtacks to their unselected state.
  */
  private void resetThumbtack(){
    this.selectedThumbtack = null;
    for (int i=0; i <this.thumbtacks.getVertexCount(); i++) {
      this.thumbtacks.setStroke(i, 0xFFFF3F3F);      
    }      
  }
}
