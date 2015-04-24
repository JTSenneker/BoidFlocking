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
    float time += millis()/1000.0;
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
    buffer.stroke(tint);
    //buffer.line(position.x, position.y,position.z, prevPosition.x, prevPosition.y,prevPosition.z);
    
    /*beginShape(TRIANGLES);
    vertex(0, -radius*2);
    vertex(-radius, radius*2);
    vertex(radius, radius*2);
    endShape();
    */
      stroke(tint);
    strokeWeight(10);
    //line(position.x, position.y,position.z, prevPosition.x, prevPosition.y,prevPosition.z);
    
    noStroke();
    box(10);
    popMatrix();
   
  }
  
 
}
 void mouseWheel(MouseEvent e){
   sphereOfInfluence += e.getCount();
  } 
