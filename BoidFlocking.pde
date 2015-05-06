Flock flock;
Camera cam;
ArrayList<Kelp> kelp = new ArrayList<Kelp>();
float cageSize = 1000;
float sphereOfInfluence = 100;
void setup() {
  size(800, 480, P3D);
  cam = new Camera();
  flock = new Flock();

  for (int i = 0; i < 20 ; i++) {
    flock.addBoid(new Boid(new PVector(random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2))));
  }
  for (int i = 0; i < 100; i++) {
    kelp.add(new Kelp(new PVector( random(-cageSize/2,cageSize/2), cageSize/2, random(-cageSize/2,cageSize/2))));
  }
}

void draw() {
  //lights();
  background(0);
  cam.update();



  flock.update();
  debugText();



  stroke(255);
  noFill();
  box(cageSize);
  flock.update();
  for (Kelp k : kelp) { 
    k.update();
    k.draw();
  }


  
  //println(flock.boids.size());
}

float deltaTime() {
  float time = 0.0;
  float deltaTime = 1/frameRate;

  float currentTime = millis()/1000.0;


  float newTime = millis()/1000.0;
  float frameTime = newTime - currentTime;
  currentTime = newTime;

  //deltaTime = min(frameTime,deltaTime);
  return deltaTime;
}

void debugText(){
 textAlign(LEFT);
 text("FPS: " + frameRate,cam.position.x + width/5,cam.position.y-height/3,cam.position.z - 300);
}

