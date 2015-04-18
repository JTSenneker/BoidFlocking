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

