public class Poi {
  
  /**
   * Returns an ArrayList with all points of interest
   * @param filename trail's path coordinates associated geojson file  
   * @return ArrayList of Map3D.ObjectPoint  
   */
  public ArrayList<Map3D.ObjectPoint> getPoints(String filename){
  
    //Initialize the ArrayList 
    ArrayList<Map3D.ObjectPoint> pointsList = new ArrayList();
    
    // Check ressources
    File ressource = dataFile(filename);
    if (!ressource.exists() || ressource.isDirectory()) {
      println("ERROR: GeoJSON file " + filename + " not found.");
      return null;
    }

    // Load geojson and check features collection
    JSONObject geojson = loadJSONObject(filename);
    if (!geojson.hasKey("type")) {
      println("WARNING: Invalid GeoJSON file.");
      return null;
    } else if (!"FeatureCollection".equals(geojson.getString("type", "undefined"))) {
      println("WARNING: GeoJSON file doesn't contain features collection.");
      return null;
    }

    // Parse features
    JSONArray features = geojson.getJSONArray("features");
    if (features == null) {
      println("WARNING: GeoJSON file doesn't contain any feature.");
      return null;
    }
    
    //Evaluates each feature in the file and adds it to pointsList if it's geometry correponds to a point
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {
      
       //Adds each point of interest to the ArrayList pointsList
       case "Point":        
        if (geometry.hasKey("coordinates")) {
          JSONArray point = geometry.getJSONArray("coordinates");
          Map3D.GeoPoint gp = map.new GeoPoint(point.getDouble(0), point.getDouble(1));
          Map3D.ObjectPoint op = map.new ObjectPoint(gp);
          pointsList.add(op);
        }
        break;

      default:
        println("WARNING: GeoJSON '" + geometry.getString("type", "undefined") + " geometrytype not handled.");
        break;
      }
    }
    return pointsList;  
  }    
}
