Flock flock;
Camera cam;
float cageSize = 1000;
float sphereOfInfluence = 150;
void setup() {
  size(800, 480, P3D);
  cam = new Camera();
  flock = new Flock();

  for (int i = 0; i < 50 ; i++) {
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

class Boid {
  PVector prevPosition;
  PVector position;
  PVector velocity;
  PVector force;
  PVector acceleration;
  
  float mass;
  float radius;
  float maxForce; //max steering force
  float maxSpeed; //max steering speed
  color tint;
  
  boolean dead = false;
  float age = 1;
  float lifeExpectancy;

    Boid(PVector pos) {
    lifeExpectancy = random(60,120);
    force = new PVector();
    mass = 20;
    acceleration = new PVector();
    velocity = PVector.random3D();
    position = pos;
    colorMode(HSB);
    tint = color(random(100,151),255,255);
    colorMode(RGB);
    radius = 50.0;
    maxSpeed = 2.0;
    maxForce = 0.03;
    
    float angle = random(TWO_PI);
  }

  void update(ArrayList<Boid> boids) {
     radius = sphereOfInfluence;
    float deltaTime = 0;
    float time = millis()/1000.0;
    age = time;
    println(age);
    if (age > lifeExpectancy) dead = true;
    deltaTime *= 0;
    flock(boids);
    updateLocation();
    borders();
    draw();
  }

  //Function used to add force
  void addForce(PVector f) {
    force.add(f);
  }

  //gain acceleration based on three rules
  //separation
  //alignment
  //cohesion
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);

    //weigh the forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);

    //add forces to acceleration
    addForce(sep);
    addForce(ali);
    addForce(coh);
  }

  //updating location
  void updateLocation() {
    prevPosition = position.get();
    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    velocity.limit(maxSpeed);

    position.add(velocity);

    acceleration.mult(0);
  }

  //Method for steering towards a target
  //TARGET - VELOCITY = STEER
  PVector steer(PVector t) {
    PVector  target = PVector.sub(t, position);
    target.setMag(maxSpeed);

    //steering = target - velocity
    PVector steer = PVector.sub(target, velocity);
    steer.limit(maxForce);//limits max steering force
    return steer;
  }

  // Wraparound
  void borders() {
    if (position.x < -cageSize/2) addForce(new PVector(maxForce*5,0));
    if (position.y < -cageSize/2) addForce(new PVector(0,maxForce*5));
    if (position.x > cageSize/2) addForce(new PVector(-maxForce*5,0));
    if (position.y > cageSize/2) addForce(new PVector(0,-maxForce*5));
    if (position.z < -cageSize/2) addForce(new PVector(0,0,maxForce*5));
    if (position.z > cageSize/2) addForce(new PVector(0,0,-maxForce*4));
  }

  //separation method
  //check for nearby boids and steer away
  PVector separate(ArrayList<Boid> boids) {
    float desiredSeparation = 30.0;//how separated we want our birds
    PVector steer = new PVector();
    int i = 0;

    //for every boid in the system, check to see if it's too close
    for (Boid other : boids) {
      if (other == this) continue;
      float dis = PVector.dist(position, other.position);
      if (dis < desiredSeparation) {
        //calculate vector pointing away from the other
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(dis);//weigh by distance
        steer.add(diff);
        i++;
      }
    }
    //Average
    if (i > 0) {
      steer.div((float) i);
    }

    //as long as the vector's greater than 0
    if (steer.mag() > 0) {
      steer.setMag(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  //alignment method
  //for every nearby boid, calculate average velocity
  PVector align(ArrayList<Boid> boids) {
    float neighborDist = radius; //range for neighbor inclusion
    PVector sum = new PVector();

    int i = 0;

    for (Boid other : boids) {
      if (other == this) continue;
      float dis = PVector.dist(position, other.position);
      if (dis < neighborDist) {
        sum.add(other.velocity);
        i++;
      }
    }
    if (i > 0) {
      sum.div((float)i);
      sum.setMag(maxSpeed);

      //steering = target - velocity
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } else return new PVector();
  }

  //cohesion method
  //for the average location of all nearby boids, calculate steering vector towards that location
  PVector cohesion(ArrayList<Boid> boids) {
    float neighborDist = radius; //range for neighbor inclusion
    PVector sum = new PVector();

    int i = 0;

    for (Boid other : boids) {
      if (other == this) continue;
      float dis = PVector.dist(position, other.position);
      if (dis < neighborDist) {
        sum.add(other.position);
        i++;
      }
    }
    if (i > 0) {
      sum.div((float)i);
      return steer(sum);
    } else return new PVector();
  }

  //draw method
  void draw() {

    float angle = velocity.heading() + (PI/2);

    fill(tint);
    noStroke();

    pushMatrix();
    translate(position.x, position.y,position.z);
    rotate(angle);
  
      stroke(tint);
    strokeWeight(10);
   
    noStroke();
    box(10);
    popMatrix();
   
  }
  
 
}
 void mouseWheel(MouseEvent e){
   sphereOfInfluence += e.getCount();
  } 
class Camera {
  PVector position = new PVector(0, 0, 500);
  PVector target = new PVector();
  PVector up = new PVector(0, 1, 0);
  PVector mouse = new PVector();
  float speed = 5;
  float speedTurn = 1/100.0;

  Camera() {
  }
  void update() {

    if (KEY_W) moveForward(speed);
    if (KEY_A) moveLeft(speed);
    if (KEY_S) moveBack(speed);
    if (KEY_D) moveRight(speed);
    handleMouse();

    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
  }
  void handleMouse() {
    float dx = mouseX - mouse.x;
    float dy = mouseY - mouse.y;
    if (mousePressed && mouseButton == RIGHT) {
      lookFree(dx * speedTurn, -dy * speedTurn);
    }
    if (mousePressed && mouseButton == LEFT) {
      moveLeft(dx);
      moveDown(dy);
    }
    mouse = new PVector(mouseX, mouseY);
  }
  void lookFree(float dx, float dy) {
    PVector v = PVector.sub(target, position);

    float len = v.mag();
    float a1 = dx + atan2(v.z, v.x);
    float a2 = dy + atan2(sqrt(v.x * v.x + v.z * v.z), v.y);
    
    
    a2 = constrain(a2, 0.01, PI*.999);
    
    float cosA1 = cos(a1);
    float sinA1 = sin(a1);
    float cosA2 = cos(a2);
    float sinA2 = sin(a2);
    
    float x = len * sinA2 * cosA1;
    float z = len * sinA2 * sinA1;
    float y = len * cosA2;
    
    v.x = x;
    v.y = y;
    v.z = z;
    
    target = PVector.add(position, v);
  }
  PVector getForward() {
    PVector v = PVector.sub(target, position);
    v.normalize();
    return v;
  }
  PVector getRight() {
    return getForward().cross(up);
  }
  void move(PVector dir, float amt) {
    dir = dir.get();
    dir.mult(amt);
    position.add(dir);
    target.add(dir);
  }
  void moveUp(float amt) {
    move(up, amt);
  }
  void moveDown(float amt) {
    move(up, -amt);
  }
  void moveRight(float amt) {
    move(getRight(), amt);
  }
  void moveLeft(float amt) {
    move(getRight(), -amt);
  }
  void moveForward(float amt) {
    move(getForward(), amt);
  }
  void moveBack(float amt) {
    move(getForward(), -amt);
  }
}

boolean KEY_W = false;
boolean KEY_A = false;
boolean KEY_S = false;
boolean KEY_D = false;

void handleKey(int keyCode, boolean state) {
  switch(keyCode) {
  case 65:
    KEY_A = state;
    break;
  case 87:
    KEY_W = state;
    break;
  case 68:
    KEY_D = state;
    break;
  case 83:
    KEY_S = state;
    break;
  }
}
void keyPressed() {
  //println(keyCode);
  handleKey(keyCode, true);
}
void keyReleased() {
  handleKey(keyCode, false);
}

class Flock{
  ArrayList<Boid> boids = new ArrayList<Boid>();
  
  Flock(){ 
  }
  
  void update(){
   for (int i = boids.size() - 1; i >= 0; i--){
     //updates boids in the array
    boids.get(i).update(boids);
    if (boids.get(i).dead) boids.remove(i);
   } 
  }
  
  void addBoid(Boid b){
   boids.add(b); 
  }
}

