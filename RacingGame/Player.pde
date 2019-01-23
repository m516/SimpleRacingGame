class ControlledPlayer extends Player {
  //Moving limits
  float MAX_HORIZONTAL_VELOCITY = 0.5;
  float MAX_VERTICAL_VELOCITY = 1.0;
  float MAX_JUMP_VELOCITY = 1.0;
  float HORIZONTAL_ACCELERATION = 0.05;
  float VERTICAL_ACCELERATION = .1;

  //Control
  boolean left = false, right = false, up = false, down = false, jump = false;

  //Reference to ground
  Face floor = null;


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





  //Update the player's position
  @Override
    public void update() {

    //Update the position
    previousPosition=position.copy();
    super.update();

    //Stop at the floor or move to another floor if necesary
    if (floor!=null) {
      //Update the current floor
      floor = floor.getFace(position);
      //If not free-falling
      if (floor!=null) {
        //Check if the player fell through the floor
        float faceY = floor.getYAt(position);
        if (position.y>=faceY) {
          //Stop the player from falling
          position.y=faceY;
          velocity.y=0;
        }//End if
      }//End if
    }//End if
  }//End update()

  void draw() {
    super.draw();
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
    MAX_HORIZONTAL_VELOCITY=1.0;
  }

  public DirectionalPlayer() {
    super();
    MAX_HORIZONTAL_VELOCITY=1.0;
  }

  public DirectionalPlayer(PImage sprite, Face floor) {
    super(sprite, floor);
    MAX_HORIZONTAL_VELOCITY=1.0;
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
      if(speed<MAX_HORIZONTAL_VELOCITY) speed+=0.02;
    } else if (down) {
      speed-=0.1;
    } else {
      speed-=0.002;
    }
    if(speed<0.0)speed=0.0;
    velocity.x = speed*cos(directionXZ);
    velocity.z = speed*sin(directionXZ);
    super.update();
  }
}
