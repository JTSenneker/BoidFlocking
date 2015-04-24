Flock flock;
Camera cam;
float cageSize = 1000;
float sphereOfInfluence = 150;
void setup() {
  size(800, 480, P3D);
  cam = new Camera();
  flock = new Flock();

  for (int i = 0; i < 500 ; i++) {
    flock.addBoid(new Boid(new PVector(random(-cageSize/2,cageSize/2), random(-cageSize/2,cageSize/2), random(-cageSize/2,cageSize/2))));
  }
  
}

void draw() {
  //lights();
  background(0);
  cam.update();


  flock.update();

  
  stroke(255);
  noFill();
  box(cageSize);
  
 
}

