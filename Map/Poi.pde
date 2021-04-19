public class Poi {

  /**
   * Returns an ArrayList with all points of interest
   * @param filename trail's path coordinates associated geojson file  
   * @return ArrayList of Map3D.ObjectPoint  
   */
  public ArrayList<Map3D.ObjectPoint> getPoints(String filename) {

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
  
  /**
   * Returns the distance between a point and it's closest neighbor in an Arraylist of points
   * @param float x, y coordinates of the point 
   * @param points ArrayList of Map3D.ObjectPoint points
   * @return int nearestDistance (distance to nearest neighbor)  
   */
  public int nearestDistance(float x, float y, ArrayList<Map3D.ObjectPoint> points) {
    int nearestDistance = (int) dist(x, y, points.get(0).x, points.get(0).y);
    for (Map3D.ObjectPoint p : points) {
      if (dist(x, y, p.x, p.y) < nearestDistance) {
        nearestDistance = (int)dist(x, y, p.x, p.y);
      }
    }
    return nearestDistance;
  }
  
   /**
   * Returns a JSONArray containing the Poi Distances for every point in the map
   * If the JSONArray exists it loads it and returns it
   * If not, it creates it, calculates and adds to it the poiDistance for each point in the map 
   * @param float w,h width and height of the Map3D 
   * @param BykeParkingd, Bench_picninc_Tables ArrayLists
   * @return JSONArray poiDistances
   */
  public JSONArray getPoiDistances(float w, float h, float tileSize, ArrayList<Map3D.ObjectPoint> BykeParkings, ArrayList<Map3D.ObjectPoint> Bench_Picnic_Tables) {
    File ressource = dataFile("poi_distances.json");
    
    // If "poi_distances.json" doesn't exist
    if (!ressource.exists() || ressource.isDirectory()) {
      //Creates the JSONArray, initilizing it to an empty state
      JSONArray poiDistances = new JSONArray();
      
      //Calculates the nearest distance to both Poi for each point in the Map and adds it to the JSONArray
      int index = 0;
      for (float i=-w/2.0f; i<w/2.0f; i+=tileSize) {
        for (float j=-h/2.0f; j<h/2.0f; j+=tileSize) {

          JSONObject point = new JSONObject();
          point.setInt("nearestBykeParkingDistance", nearestDistance(i, j, BykeParkings));
          point.setInt("nearestBench&Picnic_TableDistance", nearestDistance(i, j, Bench_Picnic_Tables));

          poiDistances.setJSONObject(index, point);
          index++;
        }
      }
      //Saves the JSONArray and returns it
      saveJSONArray(poiDistances, "data/poi_distances.json");
      return poiDistances;
    }
    
    // If "poi_distances.json" exists
    else {
      return loadJSONArray("poi_distances.json");      
    }
  }
}
