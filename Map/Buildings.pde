public class Buildings {

  PShape buildings;

  Buildings(Map3D map) {
    this.buildings = createShape(GROUP);
  }

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

    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

      case "Polygon": 
        // GPX Track
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        float top = 0;
        if (feature.hasKey("properties")) {
            int levels = feature.getJSONObject("properties").getInt("building:levels", 1);
            top = Map3D.heightScale * 3.0f * (float)levels;
          }        
        if (coordinates != null) {
          ArrayList<PVector> floorCoordinates = new ArrayList();
          for (int poly=0; poly < coordinates.size(); poly++) {
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
          }

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
          roof.endShape();         
          buildings.addChild(roof);
          
          
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
        break;
      }
    }
  }

  public void update() {
    shape(this.buildings);
  }

  public void toggle() {
    this.buildings.setVisible(!this.buildings.isVisible());
  }
}
