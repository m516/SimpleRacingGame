









void setup() {
  size(640, 640, P3D);
  //fullScreen(P3D);
  noSmooth();
  perspective(0.75*PI, width/height, 0.001, 10000.0);
  blendMode(ADD);
  initializeGlobals();
  loadGameAssets();

  player=players[0];
  player.jumpToFace(ground[10]);
  ai = new DirectionalAI(player);
}

void draw() {
  time++;

  if (mousePressed) for (int i = 0; i < 4; i++) {
    //face.vertices[i]=PVector.random3D().mult(100);
    //face.normalIsInitialized=false;
    player.jump=true;
  }

  render();
}


void drawLine(PVector p, PVector d) {
  line(p.x+width*d.x, 
    p.y+width*d.y, 
    p.z+width*d.z, 
    p.x-width*d.x, 
    p.y-width*d.y, 
    p.z-width*d.z);
}

void drawIntersection(Face f, PVector p, PVector d) {
  PVector point = f.intersectionWithSegment(p, d);
  drawPoint(point);
}

void drawPoint(PVector point) {
  //noStroke();
  //pushMatrix();
  //translate(point.x,point.y-20,point.z);
  //sphere(20);

  beginShape(POINTS);
  vertex(point.x, point.y, point.z);
  endShape();


  //popMatrix();
}




/*
//Old Vector class, replaced by PVector
 static class Vec3{
 float x, y, z;
 public Vec3(float x, float y, float z){
 this.x=x;
 this.y=y;
 this.z=z;
 }
 public Vec3(){
 this(0,0,0);
 }
 public void addTo(Vec3 other){
 x+=other.x;
 y+=other.y;
 z+=other.z;
 }
 public static Vec3 crossProduct(Vec3 a, Vec3 b){
 return new Vec3(a.y*b.z-b.y*a.z,
 a.x*b.z-b.x*a.z,
 a.x*b.y-b.x*a.y);
 
 }
 public static Vec3 add(Vec3 a, Vec3 b){
 return new Vec3(a.x+b.x,
 a.y+b.y,
 a.z+b.z);
 
 }
 public static Vec3 divide(Vec3 a, float b){
 return new Vec3(a.x/b,
 a.y/b,
 a.z/b);
 
 }
 public static double magnitudeOf(Vec3 a){
 return sqrt(a.x*a.x+a.y*a.y+a.z*a.z);
 
 }
 public static double normalize(Vec3 a){
 return sqrt(a.x*a.x+a.y*a.y+a.z*a.z);
 
 }
 public static float dotProduct(Vec3 a, Vec3 b){
 return a.x*b.x+a.y*b.y+a.z*b.z;
 }
 }
 */

void keyPressed() {
  switch(key) {
  case 'a':
  case 'A':
    player.left=true;
    break;
  case 's':
  case 'S':
    player.down=true;
    break;
  case 'd':
  case 'D':
    player.right=true;
    break;
  case 'w':
  case 'W':
    player.up=true;
    break;
  }
}



void keyReleased() {
  switch(key) {
  case '1':
    debug = 1;
    break;
  case '2':
    debug = 2;
    break;
  case '0':
    debug = 0;
    break;
  case 'a':
  case 'A':
    player.left=false;
    break;
  case 's':
  case 'S':
    player.down=false;
    break;
  case 'd':
  case 'D':
    player.right=false;
    break;
  case 'w':
  case 'W':
    player.up=false;
    break;
  case 'q':
  case 'Q':
    controlledByAI = !controlledByAI;
    player.left=false;
    player.right=false;
    player.up=false;
    player.down=false;
    player.jump=false;
    break;
  case 'e':
  case 'E':
    player.b=(player.b+1)%player.images[player.a].length;
    if (player.b==0) player.a=(player.a+1)%player.images.length;
    break;
  }
}
