class Earth {


  PImage earthTexture;
  PShape earth;


  Earth() {
    earthTexture = loadImage("Earth.png");
    createShape();
    sphereDetail(80);
    earth = createShape(SPHERE, EARTHRADIUS / SCALAR);
    earth.setTexture(earthTexture);
    endShape();
  }

  void display(float lng, float lat) {
    pushMatrix();  
    rotateY(radians(lng));
    rotateX(radians(lat));
    earth.setStrokeWeight(0.0);
    shape(earth);
    popMatrix();
  }
}