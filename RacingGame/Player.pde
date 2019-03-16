class ControlledPlayer extends Player {  //<>//
  //Moving limits
  float MAX_HORIZONTAL_VELOCITY = 0.5;
  float MAX_VERTICAL_VELOCITY = 1.0;
  float MAX_JUMP_VELOCITY = 1.0;
  float HORIZONTAL_ACCELERATION = 0.05;
  float VERTICAL_ACCELERATION = 0.08;

  //Control
  boolean left = false, right = false, up = false, down = false, jump = false;

  //Reference to ground
  Face floor = null;

  //Image database with various views
  /*
  Images are placed in rows and columns based on the rotation of the view
   
   The first index is the altitude of the camera (i.e. rotation in the YZ plane),
   starting from a bottom view and ending at the top views. NOTE: this is one 
   HALF ROTATION
   
   The next index refers to the horizontal rotation of the model 
   (i.e. rotation in the XZ plane), starting in the direction of the positive X axis
   and rotating COUNTER CLOCKWISE a full rotation.
   
   The final index refers to an index in an animation.
   //TODO implement
   */
  PImage[][][] images;
  int animationIndex = 0;

  //Get the name of the player
  String name;

  public ControlledPlayer(Face floor) {
    super(floor.center());
    this.acceleration.y=VERTICAL_ACCELERATION;
    spriteColor = color(255, 0, 0); //Debug
  }

  public ControlledPlayer() {
    super(new PVector(0.0, 0.0, 0.0));
    this.acceleration.y=VERTICAL_ACCELERATION;
    spriteColor = color(255, 0, 0); //Debug
  }

  public ControlledPlayer(PImage sprite, Face floor) {
    this(floor);
    this.sprite = sprite;
  }

  public void jumpToFace(Face f) {
    this.position = f.center();
    this.position.y-=1;
    floor=f;
  }



  int a = 0, b=0;

  //Update the player's position
  @Override
    public void update() {

    //Stop at the floor or move to another floor if necesary
    if (floor!=null) {
      //Update the current floor
      floor = floor.getFace(position);
      //If not free-falling
      if (floor!=null) {
        //Get where the player should be at
        PVector t = PVector.add(position,velocity);
        //Check if the player fell through the floor
        float faceY = floor.getYAt(t);
        if (t.y>=faceY) {
          //Stop the player from falling
          /*if (abs(t.y-faceY)<abs(velocity.y)) {
            position.y=faceY;
            velocity.y=t.y-faceY;
          } else {
            velocity.y=-abs(t.y-faceY);
            position.y=faceY;
          }*/
          
          velocity.y=faceY-position.y;
        }//End if
      }//End if
    }//End if

    //Update the position
    previousPosition=position.copy();
    super.update();
  }//End update()



  void draw() {
    if (images!=null && direction!=null && camera.direction!=null) {
      animationIndex = (animationIndex+1)%images[0][0].length;
      //Get direction angle theta on the XZ plane
      float theta = atan2(camera.direction.z, camera.direction.x);
      //Get direction angle theta on the YZ plane
      /*
      float phi = atan2(camera.direction.z-direction.z, 
       sqrt(camera.direction.x*camera.direction.x+camera.direction.y*camera.direction.y)-
       sqrt(direction.x*direction.x+direction.y*direction.y));
       */
      float phi = atan2(camera.direction.y-0.0, 
        sqrt(camera.direction.x*camera.direction.x+camera.direction.z*camera.direction.z)-
        0.0);
      if (phi<-HALF_PI) phi+=PI;
      if (phi>HALF_PI) phi-=PI;
      a = int((phi+atan2(sqrt(direction.x*direction.x+direction.z+direction.z),direction.y)+PI)*images.length/PI)%images.length;
      println(a);
      if (theta<0)theta+=TAU;
      b = int((theta-atan2(direction.z,direction.x)+9.0*HALF_PI)/TAU*images[a].length)%images[a].length;
      //a=constrain(a,0,images.length-1);
      //b=constrain(b,0,images[a].length-1);
      sprite = images[a][b][animationIndex];
      //TODO
      super.draw(phi, theta);
    } else super.draw();
  }//End draw()
}//End Player()

class ThirdPersonPlayer extends ControlledPlayer {

  public ThirdPersonPlayer(Face floor) {
    super(floor);
  }

  public ThirdPersonPlayer() {
    super();
  }

  public ThirdPersonPlayer(PImage sprite, Face floor) {
    super(sprite, floor);
  }

  //Update the player's position
  @Override
    public void update() {
    //Jump if requested
    if (jump) {
      jump=false;
      velocity.y=-MAX_JUMP_VELOCITY;
    }

    //Move according to the direction requested
    if (left) {
      velocity.x=-MAX_HORIZONTAL_VELOCITY;
    } else if (right) {
      velocity.x=MAX_HORIZONTAL_VELOCITY;
    } else {
      velocity.x = 0.0;
    }
    if (up) {
      velocity.z=MAX_HORIZONTAL_VELOCITY;
    } else if (down) {
      velocity.z=-MAX_HORIZONTAL_VELOCITY;
    } else {
      velocity.z = 0.0;
    }
    super.update();
  }
}

class DirectionalPlayer extends ControlledPlayer {

  float speed = 0.0, directionXZ = 0.0;

  public DirectionalPlayer(Face floor) {
    super(floor);
    MAX_HORIZONTAL_VELOCITY=2.0;
  }

  public DirectionalPlayer() {
    super();
    MAX_HORIZONTAL_VELOCITY=2.0;
  }

  public DirectionalPlayer(PImage sprite, Face floor) {
    super(sprite, floor);
    MAX_HORIZONTAL_VELOCITY=2.0;
  }

  //Update the player's position
  @Override
    public void update() {
    //Jump if requested
    if (jump) {
      jump=false;
      velocity.y=-MAX_JUMP_VELOCITY;
    }

    //Move according to the direction requested
    if (left) {
      directionXZ-=0.04;
    } else if (right) {
      directionXZ+=0.04;
    } 
    if (up) {
      if (speed<MAX_HORIZONTAL_VELOCITY) speed+=0.02;
    } else if (down) {
      speed-=0.1;
    } else {
      speed-=0.002;
    }
    if (speed<0.0)speed=0.0;
    velocity.x = speed*cos(directionXZ);
    velocity.z = speed*sin(directionXZ);
    super.update();
  }
}


interface AI {
  public void controlEntity();
}

class DirectionalAI implements AI {
  DirectionalPlayer entity;
  Face target;

  public DirectionalAI(DirectionalPlayer entity) {
    this.entity=entity;
  }

  @Override public void controlEntity() {
    //Reset controls
    entity.left=false;
    entity.right=false;
    entity.jump=false;
    entity.down=false;
    entity.up = true;

    //Constrain direction values between 0 and tau
    entity.directionXZ%=TAU;
    while (entity.directionXZ<0.0)entity.directionXZ+=TAU;
    if (entity.directionXZ>PI)entity.directionXZ-=TAU;

    //Don't do anything if the player is falling out
    if (entity.floor==null) return;



    Face target = entity.floor;
    float delta;
    PVector targetPosition;
    float targetDirection;

    /*
    //Search with a depth relative to the speed of the player
     for (int i = 0; i < int(entity.speed*3.0)+5; i++) {
     //If no potential target can be found, nothing can be done
     if (potentialTarget==null) break;
     parentTarget = potentialTarget;
     //Search adjacent faces for the smallest amount of rotation
     for (int j = 0; j < parentTarget.adjacentFaces.length; j++) {
     potentialTarget = parentTarget.adjacentFaces[j];
     //Avoid null faces at all costs
     if (potentialTarget==null) continue;
     targetPosition = potentialTarget.center();
     targetDirection = atan2(targetPosition.z-entity.position.z, targetPosition.x-entity.position.x);
     currentDelta = targetDirection-entity.directionXZ;
     //Constrain delta values to find minimum amount of turn
     currentDelta = abs(currentDelta);
     if (currentDelta>PI) currentDelta=TAU-currentDelta;
     if (currentDelta<delta) {
     delta = currentDelta;
     target = potentialTarget;
     }
     }
     }*/


    if (target==entity.floor) target = findTarget(target, 5+int(entity.speed));


    //Reset the target position, direction and delta values
    targetPosition = target.center();
    targetDirection = atan2(targetPosition.z-entity.position.z, targetPosition.x-entity.position.x);
    delta = targetDirection-entity.directionXZ;

    if (debug==2) {
      stroke(255);
      strokeWeight(16);
      drawPoint(targetPosition);
      //strokeWeight(1);
      //drawLine(entity.position, new PVector(cos(targetDirection), 0.0, sin(targetDirection)));
    }


    //Compare the target direction and the actual direction
    //If it's uneccessary to turn, don't do so
    if (abs(delta)<0.1 || abs(delta)>TAU-0.1) return;
    if (abs(delta)<PI) {
      if (entity.directionXZ<targetDirection) {
        entity.right = true;
      } else {
        entity.left = true;
      }
    } else {
      if (entity.directionXZ<targetDirection) {
        entity.left = true;
      } else {
        entity.right = true;
      }
    }

    if (abs(delta)>0.3&&abs(delta)<TAU-0.3) {
      entity.up=false;
      entity.down=true;
    }

    if (debug==2) {
      print("\tDelta: ");
      print(delta);
      print("\ttargetDirection: ");
      print(targetDirection);
      print("\tDirection: ");
      print(entity.directionXZ);
      print("\t");
      if (entity.up)print("u");
      if (entity.down)print("d");
      if (entity.left)print("l");
      if (entity.right)print("r");
      println();
    }
  }

  private Face findTarget(Face toSearch, int depth) {
    //Don't search anymore if not required
    if (depth<=0) return toSearch;

    //Don't do anything with null faces
    if (toSearch==null) return null;

    //Search for the target position
    Face t = toSearch;

    PVector targetPosition = toSearch.center();
    float targetDirection = atan2(targetPosition.z-entity.position.z, targetPosition.x-entity.position.x);
    float delta = targetDirection-entity.directionXZ;

    if (t==target) {
      delta = 100.0;
    } else {
      targetPosition = t.center();
      targetDirection = atan2(targetPosition.z-entity.position.z, targetPosition.x-entity.position.x);
      delta = targetDirection-entity.directionXZ;

      delta = abs(delta);
      if (delta>PI) delta=TAU-delta;
      delta*=1.2;//Penalize close faces
    }


    //Search adjacent faces for the smallest amount of rotation
    for (int j = 0; j < toSearch.adjacentFaces.length; j++) {
      Face potentialTarget = findTarget(toSearch.adjacentFaces[j], depth-1);
      //Avoid null faces at all costs
      if (potentialTarget==null) continue;
      //Find the change in direction of this current face
      targetPosition = potentialTarget.center();
      targetDirection = atan2(targetPosition.z-entity.position.z, targetPosition.x-entity.position.x);
      float currentDelta = targetDirection-entity.directionXZ;
      //Constrain delta values to find minimum amount of turn
      currentDelta = abs(currentDelta);
      if (currentDelta>PI) currentDelta=TAU-currentDelta;
      if (currentDelta<delta) {
        delta = currentDelta;
        t = potentialTarget;
      }
    }
    return t;
  }
}
