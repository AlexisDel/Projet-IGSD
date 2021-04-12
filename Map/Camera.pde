public class Camera {

  /**
   * Camera position in Cartesian coordinate system
   */
  CartesianCoordinates cartesianCoordinates;
  /**
   * Camera position in spherical coordinate system
   */
  SphericalCoordinates sphericalCoordinates;
  /**
   * Set sunny light (true) or default light (false)
   */
  boolean lightning;

  /**
   * Returns Camera object
   */
  Camera() {
    this.cartesianCoordinates = new CartesianCoordinates(0, 2500, 1000);
    this.sphericalCoordinates = cartesianCoordinates.toSphericalCoordinates();
    this.lightning = false;
  }

  /**
   * Update camera position and lightning
   */
  public void update() {

    //Compute cartesian coordinates
    this.cartesianCoordinates = this.sphericalCoordinates.toCartesianCoordinates();

    // 3D camera (X+ right / Z+ top / Y+ Front)
    camera(
      this.cartesianCoordinates.x, this.cartesianCoordinates.y, this.cartesianCoordinates.z, 
      0, 0, 0, 
      0, 0, -1
      );

    // Default lightning settings
    ambientLight(0x7F, 0x7F, 0x7F);
    lightFalloff(0.0f, 0.0f, 1.0f);
    lightSpecular(0.0f, 0.0f, 0.0f);

    // Sunny vertical lightning
    if (lightning)
      directionalLight(0xA0, 0xA0, 0x60, 0, 0, -1);
  }

  /**
   * Toggle lightning effects.
   */
  public void toggle() {
    this.lightning = !this.lightning;
  }

  /**
   * Allow camera radius to be adjust (with limits)
   */
  public void adjustRadius(float offset) {   
    if ( (this.sphericalCoordinates.radius + offset >= width*0.5) && (this.sphericalCoordinates.radius + offset <= width*3) ) {
      this.sphericalCoordinates.radius += offset;
    }
  }

  /**
   * Allow camera longitude to be adjust (with limits)
   */
  public void adjustLongitude(float delta) {    
    if ( (this.sphericalCoordinates.longitude + delta >= -3*(PI/2.0)) && (this.sphericalCoordinates.longitude + delta <= PI/2.0) ) {
      this.sphericalCoordinates.longitude += delta;
    }
  }

  /**
   * Allow camera colatitude to be adjust (with limits)
   */
  public void adjustColatitude(float delta) {
    if ( (this.sphericalCoordinates.colatitude + delta >= EPSILON) && (this.sphericalCoordinates.colatitude + delta <= PI/2.0) ) {
      this.sphericalCoordinates.colatitude += delta;
    }
  }
}


/**
 * CartesianCoordinates class
 * Handle Cartesian coordinate system
 */
class CartesianCoordinates {
  float x, y, z;

  /**
   * Returns CartesianCoordinates object
   * @param x : abcissa
   * @param y : ordinate
   * @param z : applicate
   */
  CartesianCoordinates(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  /**
   * Convert Cartesian coordinates to spherical coordinates
   */
  private SphericalCoordinates toSphericalCoordinates() {
    float r = sqrt(pow(this.x, 2) + pow(this.y, 2) +pow(this.z, 2));
    float l = atan2(this.y, this.x);
    float c = acos(this.z/r);
    return new SphericalCoordinates(r, l, c);
  }
}


/**
 * SphericalCoordinates class
 * Handle spherical coordinate system
 */
class SphericalCoordinates {
  float radius, longitude, colatitude;

  /**
   * Returns SphericalCoordinates object
   * @param r : radius
   * @param l : longitude
   * @param c : colatitude
   */
  SphericalCoordinates(float r, float l, float c) {
    this.radius = r;
    this.longitude = l;
    this.colatitude = c;
  }

  /**
   * Convert spherical coordinates to Cartesian coordinates
   */
  private CartesianCoordinates toCartesianCoordinates() {
    float x = this.radius*sin(this.colatitude)*cos(this.longitude);
    float y = this.radius*sin(this.colatitude)*sin(this.longitude);
    float z = this.radius*cos(this.colatitude);
    return new CartesianCoordinates(x, y, z);
  }
}
