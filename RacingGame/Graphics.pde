void render(){
  background(0);
  
  //Disable default lights
  noLights();
  //Manually add lights
  pointLight(0.0, 0.0, 255.0, player.position.x, player.position.y-20, player.position.z);
  lightSpecular(0, 0, 0);
  ambientLight(0, 0, 0);
  shininess(1.0);
  specular(255, 255, 255);
  emissive(0, 0, 0);
  ambient(0, 0, 0);
  
  //Draw test faces
  //stroke(32, 64, 255);
  //strokeWeight(4);
  if(debug==0) noStroke();
  pushMatrix();

  face.draw();
  face2.draw();
  
  for(int i = 0; i < ground.length; i++){ //<>// //<>//
    if(debug>0){
    if(ground[i]==player.floor) {
      stroke(255);
      strokeWeight(4);
    }
    else noStroke();
    }
    ground[i].draw();
  }
  
  
  if (debug>0) {
    stroke(255, 0, 0);
    strokeWeight(1);
    drawLine(player.position, player.direction);
    stroke(64, 0, 0);
    strokeWeight(16);
    if (player.floor!=null)drawIntersection(player.floor, player.position, player.direction);
  }
  strokeWeight(16);
  stroke(255);
  player.update();
  player.draw();
  popMatrix();

  if (player.position.y>500.0) {
    player.jumpToFace(ground[0]);
    println("You died");
    println(player.position.y);
  }

/*
  cameraPositionTarget.x = player.position.x    +10.0*sin((float)time/500.0);
  cameraPositionTarget.y = player.position.y-5.0-5.0*player.velocity.mag()-3.0*cos((float)time/800.0);
  cameraPositionTarget.z = player.position.z+11.0+10.0*cos((float)time/700.0)+player.velocity.mag();
  cameraPosition.lerp(cameraPositionTarget, 0.1);
  camera(cameraPosition.x, cameraPosition.y, cameraPosition.z, player.position.x, player.position.y-0.5, player.position.z, 0.0, 1.0, 0.0);
  */
  
  cameraPositionTarget.x = player.position.x-4.0*cos(player.directionXZ);
  cameraPositionTarget.y = player.position.y-5.0;
  cameraPositionTarget.z = player.position.z-4.0*sin(player.directionXZ);
  cameraPosition.lerp(cameraPositionTarget, 0.1);
  camera(cameraPosition.x, cameraPosition.y, cameraPosition.z, player.position.x, player.position.y-0.5, player.position.z, 0.0, 1.0, 0.0);
  
}
