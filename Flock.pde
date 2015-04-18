class Flock{
  ArrayList<Boid> boids = new ArrayList<Boid>();
  
  Flock(){ 
  }
  
  void update(){
   for (Boid b : boids){
     //updates boids in the array
    b.update(boids);
   } 
  }
  
  void addBoid(Boid b){
   boids.add(b); 
  }
}
