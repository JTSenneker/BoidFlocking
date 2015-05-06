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

