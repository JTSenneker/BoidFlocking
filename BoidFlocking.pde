Flock flock;
Camera cam;
float cageSize = 1000;

PGraphics buffer;
void setup() {
  size(1280, 720, P3D);
  cam = new Camera();
  buffer = createGraphics(width, height);
  flock = new Flock();

  for (int i = 0; i < 500; i++) {
    flock.addBoid(new Boid(new PVector(i* random(-1,2), i* random(-1,2), i* random(-1,2))));
  }
  
}

void draw() {
  lights();
  background(0);
  cam.update();

  buffer.beginDraw();
  flock.update();
  buffer.endDraw();
  
  stroke(255);
  noFill();
  box(cageSize);
  
  //image(buffer, 0, 0);
  /*buffer.beginDraw();
  buffer.fill(0, 0, 0, 2);
  buffer.noStroke();
  buffer.rect(0, 0, width, height);
  buffer.endDraw();
  */
}

