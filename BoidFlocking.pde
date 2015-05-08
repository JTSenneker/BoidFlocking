Flock flock;
Camera cam;
ArrayList<Kelp> kelp = new ArrayList<Kelp>();
float cageSize = 1000;
float sphereOfInfluence = 150;
void setup() {
  size(800, 480, P3D);
  cam = new Camera();
  flock = new Flock();

  for (int i = 0; i < 100 ; i++) {
    flock.addBoid(new Boid(new PVector(random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2))));
  }
  for (int i = 0; i < 500; i++) {
    kelp.add(new Kelp(new PVector( random(-cageSize/2,cageSize/2), cageSize/2, random(-cageSize/2,cageSize/2))));
  }
}

void draw() {
  println(keyCode);
  //lights();
  background(0);
  cam.update();
  //println(cam.position);


  flock.update();
  debugText();

  if (KEY_DEL){//remove all fish
     flock.clearBoids(); 
  }
  if (KEY_F){//add fish
     flock.addBoid(new Boid(new PVector(0,0,0))); 
  }
  if (KEY_LEFT){//remove kelp
     if (kelp.size() > 0) kelp.remove(0); 
  }
  if (KEY_RIGHT){//add kelp
     kelp.add(new Kelp(new PVector( random(-cageSize/2,cageSize/2), cageSize/2, random(-cageSize/2,cageSize/2)))); 
  }

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

