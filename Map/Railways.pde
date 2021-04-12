public class Railways {

  PShape railways;

  Railways(Map3D map, String filename) {

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
    

    this.railways = createShape(GROUP);


    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

      case "LineString": 
        JSONArray coordinates = geometry.getJSONArray("coordinates");
        if (coordinates != null) {
          ArrayList<PVector> path = new ArrayList();
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
            if (gp.inside()) {
              gp.elevation += 7.5d;
              Map3D.ObjectPoint op = map.new ObjectPoint(gp);
              path.add(op.toVector());
            }
          }

          float laneWidth = 3.0f;
          PShape section = createShape();
          section.beginShape(QUAD_STRIP);
          section.noStroke();
          section.fill(255);
          section.emissive(0xFF);
          
          PVector A = path.get(0);
          PVector C = path.get(path.size()-1);
          PVector vA = new PVector(A.x, A.y, A.z).normalize().mult(laneWidth/2.0f);
          PVector vC = new PVector(C.x, C.y, C.z).normalize().mult(laneWidth/2.0f);
          
          // 1st vertex
          section.normal(0,0,1);
          section.vertex(A.x - vA.x, A.y - vA.y, A.z);
          section.normal(0,0,1);
          section.vertex(A.x + vA.x, A.y + vA.y, A.z);
          
          // Intermediate vertices
          for (int i=1; i < path.size()-1; i++) {
            PVector B = path.get(i);
            PVector vB = new PVector(A.y - C.y, C.x - A.x).normalize().mult(laneWidth/2.0f);
            section.normal(0.0f, 0.0f, 1.0f);
            section.vertex(B.x - vB.x, B.y - vB.y, B.z);
            section.normal(0.0f, 0.0f, 1.0f);
            section.vertex(B.x + vB.x, B.y + vB.y, B.z);
          }
          
          // Last vertex
          section.normal(0,0,1);
          section.vertex(C.x - vC.x, C.y - vC.y, C.z);
          section.normal(0,0,1);
          section.vertex(C.x + vC.x, C.y + vC.y, C.z);

          section.endShape();         
          railways.addChild(section);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometrytype not handled.");
        break;
      }
    }

    // Shapes initial visibility
    this.railways.setVisible(true);
  }

  public void update() {
    shape(this.railways);
  }

  public void toggle() {
    this.railways.setVisible(!this.railways.isVisible());
  }
}
