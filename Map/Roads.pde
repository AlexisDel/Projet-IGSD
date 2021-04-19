public class Roads {

  PShape roads;
  
  /**
   * Returns a Roads object
   */
  Roads(Map3D map, String filename) {

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

    this.roads = createShape(GROUP);
    
    //Evaluates each feature in the file and adds it to roads if it's geometry correponds to a LineString
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      
      // Get roads segement (represented by Linestring in geojson file)
      case "LineString":
        // Get segment points coordinates as an array
        JSONArray coordinates = geometry.getJSONArray("coordinates");

        String laneKind = "unclassified";
        color laneColor = 0xFFFF0000;
        double laneOffset = 1.50d;
        float laneWidth = 0.5f;
        
        // Set lane properties according to road type
        if (feature.hasKey("properties")) {
          laneKind = feature.getJSONObject("properties").getString("highway", "unclassified");
        }

        switch (laneKind) {
        case "motorway":
          laneColor = 0xFFe990a0;
          laneOffset = 3.75d;
          laneWidth = 8.0f;
          break;
        case "trunk":
          laneColor = 0xFFfbb29a;
          laneOffset = 3.60d;
          laneWidth = 7.0f;
          break;
        case "trunk_link":
        case "primary":
          laneColor = 0xFFfdd7a1;
          laneOffset = 3.45d;
          laneWidth = 6.0f;
          break;
        case "secondary":
        case "primary_link":
          laneColor = 0xFFf6fabb;
          laneOffset = 3.30d;
          laneWidth = 5.0f;
          break;
        case "tertiary":
        case "secondary_link":
          laneColor = 0xFFE2E5A9;
          laneOffset = 3.15d;
          laneWidth = 4.0f;
          break;
        case "tertiary_link":
        case "residential":
        case "construction":
        case "living_street":
          laneColor = 0xFFB2B485;
          laneOffset = 3.00d;
          laneWidth = 3.5f;
          break;
        case "corridor":
        case "cycleway":
        case "footway":
        case "path":
        case "pedestrian":
        case "service":
        case "steps":
        case "track":
        case "unclassified":
          laneColor = 0xFFcee8B9;
          laneOffset = 2.85d;
          laneWidth = 1.0f;
          break;
        default:
          laneColor = 0xFFFF0000;
          laneOffset = 1.50d;
          laneWidth = 0.5f;
          println("WARNING: Roads kind not handled : ", laneKind);
          break;
        }

        if (coordinates != null) {
          ArrayList<PVector> segment = new ArrayList();
          
          // Convert each point of this segment to vector and add it to "segment" variable
          for (int p=0; p < coordinates.size(); p++) {
            JSONArray point = coordinates.getJSONArray(p);
            Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
            if (gp.inside() && gp.elevation > 0) {
              gp.elevation += 5d;
              Map3D.ObjectPoint op = map.new ObjectPoint(gp);
              segment.add(op.toVector());
            }
          }

          PShape section = createShape();
          section.beginShape(QUAD_STRIP);
          section.noStroke();
          section.fill(laneColor);
          section.emissive(0x7F);

          for (int i=0; i < segment.size(); i++) {

            // Handles all vectors except the last one (because we need 2 vectors, i and i+1 )
            if (i<segment.size()-1) {
              PVector A = segment.get(i);
              PVector B = segment.get(i+1);
              PVector V = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
              section.normal(0.0f, 0.0f, 1.0f);
              section.vertex(A.x - V.x, A.y - V.y, A.z);
              section.normal(0.0f, 0.0f, 1.0f);
              section.vertex(A.x + V.x, A.y + V.y, A.z);

              // Handles the last vector
            } else 
            // If segment is not a single point (then we can find a vector preceding the last one)
            if (segment.size() > 1) {
              PVector A = segment.get(i);
              PVector B = segment.get(i-1);
              PVector V = new PVector(A.y - B.y, B.x - A.x).normalize().mult(laneWidth/2.0f);
              section.normal(0.0f, 0.0f, 1.0f);
              section.vertex(A.x + V.x, A.y + V.y, A.z);
              section.normal(0.0f, 0.0f, 1.0f);
              section.vertex(A.x - V.x, A.y - V.y, A.z);
            }
          }
          section.endShape();         
          roads.addChild(section);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometrytype not handled.");
        break;
      }
    }

    // Shapes initial visibility
    this.roads.setVisible(true);
  }
  
  /**
   * Update roads display
   */
  public void update() {
    shape(this.roads);
  }
  
  /**
   * Toggle roads visibility.
   */
  public void toggle() {
    this.roads.setVisible(!this.roads.isVisible());
  }
}
