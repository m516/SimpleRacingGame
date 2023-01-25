

void render(){
  background(0);
  
  //Disable default lights
  noLights();
  //Manually add lights
  pointLight(512, 255, 200, player.position.x, player.position.y-20, player.position.z);
  directionalLight(32, 16, 8, player.position.x, player.position.y, player.position.z);
  lightSpecular(255, 255, 255);
  ambientLight(8, 16, 128);
  shininess(1.0);
  // Material properties (usually overwritten, see DrawableFace.draw() in Mechanics tab)
  specular(255, 255, 255);
  emissive(0, 0, 0);
  ambient(8, 16, 128);
  
  //Draw test faces
  //stroke(32, 64, 255);
  //strokeWeight(4);
  if(debug==0) noStroke();
  pushMatrix();

//  face.draw();
//  face2.draw(); // Debugging face rendering
  
  for(int i = 0; i < ground.length; i++){
    if(debug>0){
    if(ground[i]==player.floor) {
      stroke(255);
      strokeWeight(4);
    }
    else noStroke();
    }
    ground[i].draw();
  }
  
  
  if (debug==1) {
    stroke(255, 0, 0);
    //strokeWeight(1);
    //drawLine(player.position, player.direction);
    stroke(64, 0, 0);
    strokeWeight(16);
    if (player.floor!=null)drawIntersection(player.floor, player.position, player.direction);
  }
  strokeWeight(16);
  stroke(255);
  if(controlledByAI)ai.controlEntity();
  player.update();
  player.draw();
  popMatrix();

  if (player.position.y>500.0) {
    player.jumpToFace(ground[0]);
    player.speed=0.0;
  }
  
  camera.update();
}

class Camera{
  PVector position, positionTarget, track, direction;
  float phi = 0.0, theta = 0.0;
  
  Camera(PVector initialPosition){
    position = initialPosition.copy();
    positionTarget = initialPosition.copy();
    track = new PVector();
  }
  
  Camera(){
    this(new PVector());
  }
  
  void update(){
    /*
  positionTarget.x = player.position.x    +10.0*sin((float)time/500.0);
  positionTarget.y = player.position.y-5.0-5.0*player.velocity.mag()-3.0*cos((float)time/800.0);
  positionTarget.z = player.position.z+11.0+10.0*cos((float)time/700.0)+player.velocity.mag();
  position.lerp(positionTarget, 0.1);
  camera(position.x, position.y, position.z, player.position.x, player.position.y-0.5, player.position.z, 0.0, 1.0, 0.0);
  */
  
  //Third person
  
  
  positionTarget.x = player.position.x-cos(player.directionXZ);
  positionTarget.y = lerp(positionTarget.y, player.position.y-4.0, player.velocity.y>0.1?0.02:0.5);
  positionTarget.z = player.position.z-sin(player.directionXZ);
  position.lerp(positionTarget, 0.05);
  
  
  //if(player.position!=null)track.lerp(player.position,0.6);
  track.x=lerp(track.x, player.position.x, 0.2);
  track.y=lerp(track.y, player.position.y-0.5, player.velocity.y>0.01?0.1:0.4);
  track.z=lerp(track.z, player.position.z, 0.2);
  
  direction=PVector.sub(position,track).normalize();
  
  perspective(QUARTER_PI/4.0+constrain((250.0-PVector.sub(position,player.position).mag())/200.0, 0.0, HALF_PI+QUARTER_PI), width/height, 0.001, 10000.0);
  camera(position.x, position.y, position.z, track.x, track.y, track.z, 0.0, 1.0, 0.0);
  
  
  
  
  //First person
  //camera(player.position.x, player.position.y-2.0, player.position.z, player.position.x+cos(player.directionXZ), player.position.y-2.0, player.position.z+sin(player.directionXZ), 0.0, 1.0, 0.0);
  
  //Controls
  
  //if(key=='j') theta-=0.04;
  //if(key=='k') theta+=0.04;
  //if(key=='u') phi-=0.04;
  //if(key=='i') phi+=0.04;
  //phi+=((float(mouseY)/height)-0.5)/10.0;
  //theta+=((float(mouseX)/width)-0.5)/10.0;
  //position.x=player.position.x+4.0*sin(phi)*cos(theta);
  //position.y=player.position.y+4.0*cos(phi);
  //position.z=player.position.z+4.0*sin(phi)*sin(theta);
  //track=player.position;
  //direction=PVector.sub(track,position).normalize();
  //camera(position.x, position.y, position.z, track.x, track.y, track.z, 0.0, 1.0, 0.0);
  
  
  }
}
