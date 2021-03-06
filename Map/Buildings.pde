public class Buildings {

  PShape buildings;

  /**
   * Returns a Buildings object
   */
  Buildings(Map3D map) {
    //Initilize the building group Shape that will group all the buildings in the file 
    this.buildings = createShape(GROUP);
  }

  /**
   * Adds a group of buildings to the Map 
   * @param filename of the GeoJSON with the building's data
   * @param building_color code in hexadecimal
   */
  public void add(String filename, int building_color) {

    // Check ressources
    File ressource = dataFile(filename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + filename + " not found.");
      return;
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(filename);
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

    //Evaluates each feature in the file and adds it to buildings if it's geometry correponds to a polygon
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

        //Adds each polygon (building) to the group Buildings
      case "Polygon": 
        // Gets building coordinates and levels to set the height of the structure
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        float top = 0;
        if (feature.hasKey("properties")) {
          int levels = feature.getJSONObject("properties").getInt("building:levels", 1);
          //height of the structure
          top = Map3D.heightScale * 3.0f * (float)levels;
        }        
        if (coordinates != null) {
          for (int poly=0; poly < coordinates.size(); poly++) {
            ArrayList<PVector> floorCoordinates = new ArrayList();
            JSONArray polygon = coordinates.getJSONArray(poly);
            for (int p=0; p < polygon.size(); p++) {
              JSONArray point = polygon.getJSONArray(p);
              Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
              if (gp.inside() && gp.elevation > 0) {
                gp.elevation += 5d;
                Map3D.ObjectPoint op = map.new ObjectPoint(gp);
                floorCoordinates.add(op.toVector());
              }
            }

            //Adds the floor of the building to the group Buildings
            PShape floor = createShape();
            floor.beginShape();
            floor.noStroke();
            floor.fill(building_color);
            for (int i=0; i < floorCoordinates.size(); i++) {
              PVector v = floorCoordinates.get(i);
              floor.vertex(v.x, v.y, v.z);
            }
            floor.endShape();         
            buildings.addChild(floor);

            //Adds the roof of the building to the group Buildings
            PShape roof = createShape();
            roof.beginShape();
            roof.noStroke();
            roof.fill(building_color);
            roof.emissive(0x60);
            roof.normal(0, 0, 1);
            for (int i=0; i < floorCoordinates.size(); i++) {
              PVector v = floorCoordinates.get(i);
              roof.vertex(v.x, v.y, v.z+top);
            }
            roof.endShape(CLOSE);         
            buildings.addChild(roof);

            //Adds the walls of the building to the group Buildings
            PShape walls = createShape();
            walls.beginShape(QUAD);
            walls.noStroke();
            walls.fill(building_color);
            walls.emissive(0x30);
            for (int i=0; i < floorCoordinates.size()-1; i++) {
              PVector v1 = floorCoordinates.get(i);
              PVector v2 = floorCoordinates.get(i+1);
              PVector v3 = v1.cross(v2);
              walls.normal(v3.x, v3.y, v3.z);
              walls.vertex(v1.x, v1.y, v1.z);
              walls.vertex(v2.x, v2.y, v2.z);
              walls.vertex(v2.x, v2.y, v2.z+top);
              walls.vertex(v1.x, v1.y, v1.z+top);
            }
            walls.endShape();         
            buildings.addChild(walls);
          }
        }
        break;
      }
    }
  }

  /**
   * Update buildings display
   */
  public void update() {
    shape(this.buildings);
  }

  /**
   * Toggle buildings visibility.
   */
  public void toggle() {
    this.buildings.setVisible(!this.buildings.isVisible());
  }
}
