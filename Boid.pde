class Boid {

  //breeding varialbes
  boolean foundMate;
  float labido;
  float sexDrive;//the point where they'll want to breed
  float gender;
  ////breeding variables

  //hunger variables
  boolean foundPrey;
  float appetite;
  float maxAppetite;
  float predatory;//determins where they'll eat fish or kelp
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
  color tint;



  boolean dead = false;
  float age = 1;
  float lifeExpectancy;
  boolean dying = false;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  int trailLimit = 200;

  Boid(PVector pos, float mass, float lifeExpectancy, float sexDrive) {
    position = pos;
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

    radius = 50.0;
    maxSpeed = 2.0;
    maxForce = 0.03;

    float angle = random(TWO_PI);
  }

  Boid(PVector pos) {
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
    lifeExpectancy = random(60, 120);
    force = new PVector();
    mass = random(15, 30);
    acceleration = new PVector();
    velocity = PVector.random3D();
    position = pos;
    sexDrive = random(30, 50);
    radius = 50.0;
    maxSpeed = 2.0;
    maxForce = 0.03;

    float angle = random(TWO_PI);
  }

  void update(ArrayList<Boid> boids) {
    radius = sphereOfInfluence;

    age += deltaTime();
    labido += deltaTime();
    if (age > lifeExpectancy) dead = true;
    if (labido >= sexDrive) {
      breed(boids);
    }
    if (!dying || labido < sexDrive) {
      updateLocation();
      flock(boids);
      borders();
    }
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
    if (position.x < -cageSize/2) addForce(new PVector(maxForce*5, 0));
    if (position.y < -cageSize/2) addForce(new PVector(0, maxForce*5));
    if (position.x > cageSize/2) addForce(new PVector(-maxForce*5, 0));
    if (position.y > cageSize/2) addForce(new PVector(0, -maxForce*5));
    if (position.z < -cageSize/2) addForce(new PVector(0, 0, maxForce*5));
    if (position.z > cageSize/2) addForce(new PVector(0, 0, -maxForce*4));
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

  void drawTrail() {
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
  void breed(ArrayList<Boid> boids) {
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
        if (PVector.dist(position, b.position) < 10) {
          PVector childPosition = new PVector(b.position.x, b.position.y, b.position.z-10);
          float childMass = ((mass + b.mass)/2) + random(-5, 5);
          float childLifeExpectancy = ((lifeExpectancy + b.lifeExpectancy)/2) + random(-5, 5);
          float childSexDrive = ((sexDrive + b.sexDrive)/2) + random(-5, 5);

          flock.addBoid(new Boid(childPosition, childMass, childLifeExpectancy, childSexDrive));
          b.labido = 0;
          labido = 0;
        }
      }
    }
  }
  //end of breed method

  //hunger method
  void eat(ArrayList<Boid> boids) {
    Boid prey = new Boid();
    if (predatory > 90) {
      if (!foundPrey) {
        for (int i = boids.size () - 1; i >= 0; i--) {
          Boid b = boids.get(i);
          if (b == this) continue;
          if (b.mass < mass) {
            prey = b;
            foundPrey = true;
          }
        }
      }
      else{
        addForce(steer(prey.position));
      }
    }
  }
}


void mouseWheel(MouseEvent e) {
  sphereOfInfluence += e.getCount();
} 

