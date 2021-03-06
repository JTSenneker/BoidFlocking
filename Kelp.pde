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
