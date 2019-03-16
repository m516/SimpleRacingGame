boolean textured = true;
boolean outlines = false;

Camera camera;

DrawableFace face;
DrawableFace face2;
DrawableFace[] ground;

DirectionalPlayer[] players;


DirectionalPlayer player;
AI ai;
boolean controlledByAI = false;


int time = 0;
int debug = 0; //Used to draw lines

PVector cameraPosition;
PVector cameraPositionTarget;


void initializeGlobals() {
  face = new DrawableFace(4);
  face.vertices[0]=new PVector(-10, 10, -10);
  face.vertices[1]=new PVector(-10, 10, 10);
  face.vertices[2]=new PVector( 10, 10, 10);
  face.vertices[3]=new PVector( 10, 10, -10);
  face.recalculateNormalAndPosition();


  face2 = new DrawableFace(4);
  face2.vertices[0]=new PVector(-30, 20, 10);
  face2.vertices[1]=new PVector(-30, 20, -10);
  face2.vertices[2]=new PVector(-10, 10, -10);
  face2.vertices[3]=new PVector(-10, 10, 10);
  face2.recalculateNormalAndPosition();

  face.adjacentFaces[0]=face2;
  face2.adjacentFaces[2]=face;

  camera = new Camera();

  player = new DirectionalPlayer();
}
