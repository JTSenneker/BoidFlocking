import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BoidFlocking extends PApplet {

Flock flock;
Camera cam;
ArrayList<Kelp> kelp = new ArrayList<Kelp>();
float cageSize = 1000;
float sphereOfInfluence = 150;
public void setup() {
  
  cam = new Camera();
  flock = new Flock();

  for (int i = 0; i < 100 ; i++) {
    flock.addBoid(new Boid(new PVector(random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2), random(-cageSize/2, cageSize/2))));
  }
  for (int i = 0; i < 500; i++) {
    kelp.add(new Kelp(new PVector( random(-cageSize/2,cageSize/2), cageSize/2, random(-cageSize/2,cageSize/2))));
  }
}

public void draw() {
  println(keyCode);
  //lights();
  background(0);
  cam.update();
  //println(cam.position);


  flock.update();
  //debugText();

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
  //box(cageSize);
  flock.update();
  for (Kelp k : kelp) { 
    k.update();
    k.draw();
  }


  
  //println(flock.boids.size());
}

public float deltaTime() {
  float time = 0.0f;
  float deltaTime = 1/frameRate;

  float currentTime = millis()/1000.0f;


  float newTime = millis()/1000.0f;
  float frameTime = newTime - currentTime;
  currentTime = newTime;

  //deltaTime = min(frameTime,deltaTime);
  return deltaTime;
}

public void debugText(){
 textAlign(LEFT);
 text("FPS: " + frameRate,cam.position.x + width/5,cam.position.y-height/3,cam.position.z - 300);
}

class AABB {
  float W;//width
  float H;//height
  float D; //depth

  float halfW;//half width
  float halfH;//half height
  float halfD;//half depth

  float top;//(0,-1,0)
  float bottom;//(0,1,0)
  float left;//(-1,0,0)
  float right;//(1,0,0)
  float front;//(0,0,1)
  float back;//(0,0,-1)

   

  public AABB(float W, float H, float D) {
    this.W = W;
    this.H = H;
    this.D = D;

    halfW = W/2;
    halfH = H/2;
    halfD = D/2;
  }
  
  public void update(float W, float H, float D, PVector position){
    halfW = W/2;
    halfH = H/2;
    halfD = D/2;
    
    top = position.y - halfH;
    bottom = position.y + halfH;
    
    left = position.x - halfW;
    right = position.x + halfW;
    
    front = position.z + halfD;
    back = position.z - halfD;
  }
  
  public boolean checkCollide(AABB other){
   if (bottom < other.top || top > other.bottom || left > other.right || right < other.left || front < other.back || back > other.front) return false;
   else return true; 
  }
}

class Boid {
  AABB collider;
  //breeding varialbes
  boolean foundMate;
  float labido;
  float sexDrive;//the point where they'll want to breed
  float gender;
  ////breeding variables

  //hunger variables
  boolean foundPrey = false;
  float appetite;
  float maxAppetite;
  float predatory = 0;//determins where they'll eat fish or kelp
  //hunger variables

  PVector prevPosition;
  PVector position;
  PVector velocity;
  PVector force;
  PVector acceleration;


  float mass;
  float radius;
  float maxForce; //max steering force
  float maxSpeed; //max steering speed
  int tint;



  boolean dead = false;
  float age = 1;
  float lifeExpectancy;
  boolean dying = false;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  int trailLimit = 200;

  Boid(PVector pos, float mass, float lifeExpectancy, float sexDrive, float childMaxAppetite, float childPredatory) {
    position = pos;
    this.maxAppetite = childMaxAppetite;
    this.predatory = childPredatory;
    this.mass = mass;
    this.lifeExpectancy = lifeExpectancy;
    this.sexDrive = sexDrive;
    //gender determination
    gender = random(100);
    if (gender > 50) {
      //the boid is female
      //and will be represented a green node
      colorMode(HSB);
      tint = color(random(100, 110), 255, 255);
    } else {
      //the boid is male
      //and will be represented a blue node
      colorMode(HSB);
      tint = color(random(140, 150), 255, 255);
    }
    //gender determination

    //hunger stats
    predatory = random(100);
    appetite = 0;
    maxAppetite = random(60, 120);
    //hunger stats
    force = new PVector();
    acceleration = new PVector();
    velocity = PVector.random3D();

    radius = 50.0f;
    maxSpeed = 2.0f;
    maxForce = 0.03f;

    float angle = random(TWO_PI);
    collider = new AABB(mass, mass, mass);
  }

  Boid(PVector pos) {
    age = random(1, 10);
    gender = random(100);
    // predatory = random(100);
    if (gender > 50) {
      //the boid is female
      //and will be represented a green node
      colorMode(HSB);
      tint = color(random(100, 110), 255, 255);
    } else {
      //the boid is male
      //and will be represented a blue node
      colorMode(HSB);
      tint = color(random(140, 150), 255, 255);
    }
    lifeExpectancy = random(120, 300);
    force = new PVector();
    //mass = random(15, 30);
    acceleration = new PVector();
    velocity = PVector.random3D();
    position = pos;
    sexDrive = random(60, 180);
    radius = 50.0f;
    maxSpeed = 2.0f;
    maxForce = 0.03f;
    maxAppetite = random(120, 240);
    float angle = random(TWO_PI);
    collider = new AABB(mass, mass, mass);
  }

  public void update(ArrayList<Boid> boids) {

    mass = age/10;
    if (mass < 10) mass = 10;
    radius = sphereOfInfluence;
    appetite += deltaTime();
    age += deltaTime();
    labido += deltaTime();
    if (appetite >= maxAppetite) {
      lifeExpectancy -= deltaTime()/3;
      maxAppetite -= deltaTime()/3;
      eat(boids, kelp);
    }
    if (age > lifeExpectancy) dead = true;
    if (labido >= sexDrive) breed(boids);
    if (!dying || labido < sexDrive || appetite < maxAppetite) {
      updateLocation();
      flock(boids);
      borders();
    }
    collider.update(mass, mass, mass, position);
    draw();
  }

  //Function used to add force
  public void addForce(PVector f) {
    force.add(f);
  }

  //gain acceleration based on three rules
  //separation
  //alignment
  //cohesion
  public void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);

    //weigh the forces
    sep.mult(1.5f);
    ali.mult(1.0f);
    coh.mult(1.0f);

    //add forces to acceleration
    addForce(sep);
    addForce(ali);
    addForce(coh);
  }

  //updating location
  public void updateLocation() {
    trail.add(position.get());
    force.div(mass);
    acceleration.add(force);
    velocity.add(acceleration);
    velocity.limit(maxSpeed);

    position.add(velocity);

    acceleration.mult(0);
  }

  //Method for steering towards a target
  //TARGET - VELOCITY = STEER
  public PVector steer(PVector t) {
    PVector  target = PVector.sub(t, position);
    target.setMag(maxSpeed);

    //steering = target - velocity
    PVector steer = PVector.sub(target, velocity);
    steer.limit(maxForce);//limits max steering force
    return steer;
  }

  // Wraparound
  public void borders() {
    if (position.x < -cageSize/2) addForce(new PVector(maxForce*5, 0));
    if (position.y < -cageSize/2) addForce(new PVector(0, maxForce*5));
    if (position.x > cageSize/2) addForce(new PVector(-maxForce*5, 0));
    if (position.y > cageSize/2 - 20) addForce(new PVector(0, -maxForce*5));
    if (position.z < -cageSize/2) addForce(new PVector(0, 0, maxForce*5));
    if (position.z > cageSize/2) addForce(new PVector(0, 0, -maxForce*4));
  }

  //separation method
  //check for nearby boids and steer away
  public PVector separate(ArrayList<Boid> boids) {
    float desiredSeparation = 30;//how separated we want our birds
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
  public PVector align(ArrayList<Boid> boids) {
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
  public PVector cohesion(ArrayList<Boid> boids) {
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
  public void draw() {

    float angle = velocity.heading() + (PI/2);

    fill(tint);
    noStroke();

    pushMatrix();
    translate(position.x, position.y, position.z);
    rotate(angle);

    stroke(tint);
    strokeWeight(1);


    noStroke();
    box(mass);

    popMatrix();
    stroke(tint);
    strokeWeight(1);
    //drawTrail();
  }

  public void drawTrail() {
    for (int i =0; i < trail.size ()-1; i++) {
      PVector p1 = trail.get(i);
      if (i > 0) {
        PVector p2 = trail.get(i - 1);

        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
      }
    }
    if (trail.size() > trailLimit) trail.remove(0);
  }


  //method for breeding
  //finds a mate, then when they pair up, spawn a child with new stats based off eachother's parents.
  public void breed(ArrayList<Boid> boids) {
    for (int i = boids.size ()-1; i >=0; i--) {
      Boid b = boids.get(i);
      Boid mate = b;
      if (b == this) continue;
      if (!foundMate) {
        if (gender <= 50 && b.gender > 50 || gender > 50 && b.gender < 50) {
          if (b.labido > sexDrive) {
            mate = b;
            foundMate = true;
          }
        }
      } else {
        addForce(steer(mate.position));
        if (collider.checkCollide(mate.collider)) {
          
          PVector childPosition = new PVector(b.position.x, b.position.y, b.position.z-10);
          float childMass = ((mass + b.mass)/2) + random(-5, 5);
          float childLifeExpectancy = ((lifeExpectancy + b.lifeExpectancy)/2) + random(-5, 5);
          float childSexDrive = ((sexDrive + b.sexDrive)/2) + random(-5, 5);
          float childMaxAppetite = ((maxAppetite + b.maxAppetite)/2) + random(-5, 5);
          float childPredatory =  ((predatory + b.predatory)/2) + random(-5, 5);
          flock.addBoid(new Boid(childPosition, childMass, childLifeExpectancy, childSexDrive, childMaxAppetite, childPredatory));
          //foundMate = false;
          b.labido = 0;
          labido = 0;
          velocity = PVector.random3D();
        }
      }
    }
  }
  //end of breed method

  //hunger method
  public void eat(ArrayList<Boid> boids, ArrayList<Kelp> kelp) {
    //Boid prey = /*new Boid(new PVector(0,0,0))*/ null;
    predatory += deltaTime();
    if (predatory > 100) {
      for (int i = boids.size () - 1; i >= 0; i--) {
        Boid b = boids.get(i);
        if (b == this || b.mass > this.mass) continue;
        Boid prey = b;
        //println(PVector.dist(this.position,prey.position));

        addForce(steer(prey.position));
        if (collider.checkCollide(prey.collider)) {
          
          prey.dead = true;  
          appetite = 0;
          //foundPrey = false;
          maxAppetite +=10;
          lifeExpectancy += 10;
          velocity = PVector.random3D();
        }
      }
    } else {
      int kelpIndex = (int)random(kelp.size());
      
        Kelp targetKelp = kelp.get(kelpIndex);
        if (targetKelp.edible) {
          addForce(steer(targetKelp.position));

          if (collider.checkCollide(targetKelp.collider)) {
            
            appetite = 0;
            targetKelp.amount = 0;
            targetKelp.edible = false;
            maxAppetite+=10;
            lifeExpectancy += 10;
            velocity = PVector.random3D();
          }
        }else kelpIndex = (int)random(kelp.size());
      
    }
  }
}


public void mouseWheel(MouseEvent e) {
  sphereOfInfluence += e.getCount();
} 

class Camera {
  PVector position = new PVector(0, 0, 500);
  PVector target = new PVector();
  PVector up = new PVector(0, 1, 0);
  PVector mouse = new PVector();
  float speed = 5;
  float speedTurn = 1/100.0f;

  Camera() {
  }
  public void update() {

    if (KEY_W) moveForward(speed);
    if (KEY_A) moveLeft(speed);
    if (KEY_S) moveBack(speed);
    if (KEY_D) moveRight(speed);
    handleMouse();

    camera(position.x, position.y, position.z, target.x, target.y, target.z, up.x, up.y, up.z);
    
  }
  public void handleMouse() {
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
  public void lookFree(float dx, float dy) {
    PVector v = PVector.sub(target, position);

    float len = v.mag();
    float a1 = dx + atan2(v.z, v.x);
    float a2 = dy + atan2(sqrt(v.x * v.x + v.z * v.z), v.y);
    
    
    a2 = constrain(a2, 0.01f, PI*.999f);
    
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
  public PVector getForward() {
    PVector v = PVector.sub(target, position);
    v.normalize();
    return v;
  }
  public PVector getRight() {
    return getForward().cross(up);
  }
  public void move(PVector dir, float amt) {
    dir = dir.get();
    dir.mult(amt);
    position.add(dir);
    target.add(dir);
  }
  public void moveUp(float amt) {
    move(up, amt);
  }
  public void moveDown(float amt) {
    move(up, -amt);
  }
  public void moveRight(float amt) {
    move(getRight(), amt);
  }
  public void moveLeft(float amt) {
    move(getRight(), -amt);
  }
  public void moveForward(float amt) {
    move(getForward(), amt);
  }
  public void moveBack(float amt) {
    move(getForward(), -amt);
  }
 
}

boolean KEY_DEL = false;
boolean KEY_F = false;
boolean KEY_LEFT = false;
boolean KEY_RIGHT = false;

boolean KEY_W = false;
boolean KEY_A = false;
boolean KEY_S = false;
boolean KEY_D = false;

public void handleKey(int keyCode, boolean state) {
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
  case 127:
    KEY_DEL = state;
    break;
  case 70:
    KEY_F = state;
    break;
  case 37:
    KEY_LEFT = state;
    break;
  case 39:
    KEY_RIGHT = state;
    break;
  }
}
public void keyPressed() {
  //println(keyCode);
  handleKey(keyCode, true);
}
public void keyReleased() {
  handleKey(keyCode, false);
}

class Flock{
  ArrayList<Boid> boids = new ArrayList<Boid>();
  
  Flock(){ 
  }
  
  public void update(){
   for (int i = boids.size() - 1; i >= 0; i--){
     //updates boids in the array
    boids.get(i).update(boids);
    if (boids.get(i).dead) boids.remove(i);
   } 
  }
  
  public void addBoid(Boid b){
   boids.add(b); 
  }
  public void clearBoids(){
   boids.clear(); 
  }
}
class Kelp{
 public float amount;
 public PVector position;
 public float growth;
 public float maxGrowth;
 public boolean edible;
 
 public AABB collider;
 
 public Kelp(PVector pos){
   position = pos;
   amount = random(100);
   maxGrowth = random(100,200);
   growth = (1/frameRate)/30;
   collider = new AABB(10,amount,10);
 }
 
 public void update(){
   amount += growth;
   position.y = cageSize/2 - amount/2;
   if (amount >= maxGrowth) amount = maxGrowth;
   if (amount >= maxGrowth/2) edible = true;
   collider.update(10,amount,10,position);
 }
 public void draw(){
  fill(100,255,100);
  noStroke();
  pushMatrix();
  translate(position.x,position.y,position.z);
  box(10,amount,10); 
  popMatrix();
 }
}
  public void settings() {  size(800, 480, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BoidFlocking" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
