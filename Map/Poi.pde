public class Poi {
  
  public ArrayList<Map3D.ObjectPoint> getPoints(String filename){
    
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
    
    for (int f=0; f<features.size(); f++) {
      JSONObject feature = features.getJSONObject(f);
      if (!feature.hasKey("geometry"))
        break;
      JSONObject geometry = feature.getJSONObject("geometry");
      switch (geometry.getString("type", "undefined")) {

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
