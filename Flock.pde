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
