class Face {
  /*
   |    0       z
   |  0---1     ^
   |  |   |     |  
   |3 |   | 1   |
   |  |   |     +---->x
   |  3---2     y
   |    2    
   
   */
  //Create the four vertices for this face
  PVector[] vertices;
  //Create the normal and position of these faces
  PVector normal, position;
  //Returns true if the normal is initialized
  boolean normalIsInitialized = false;
  //The adjacent faces
  Face[] adjacentFaces;

  public Face(int numberOfSides) {
    vertices = new PVector[numberOfSides];
    adjacentFaces = new Face[numberOfSides];
  }


  //Recalculates the normal and position vectors
  void recalculateNormalAndPosition() {
    if (vertices.length<3) throw new IllegalStateException("Attempting to get the normal of an edge or point");
    position = vertices[0];
    normal = PVector.sub(vertices[0], vertices[1]);
    normal = normal.cross(PVector.sub(vertices[0], vertices[2]));
    normal.normalize();
    normalIsInitialized = true;
  }

  //Gets the intersection of a line in the direction of segmentDirection and containing the point at segmentPosition
  PVector intersectionWithSegment(PVector segmentPosition, PVector segmentDirection) {
    if (!normalIsInitialized) {
      recalculateNormalAndPosition();
      normalIsInitialized = true;
    }
    float t = PVector.sub(position, segmentPosition).dot(normal)/segmentDirection.dot(normal);
    return new PVector(segmentPosition.x+t*segmentDirection.x, 
      segmentPosition.y+t*segmentDirection.y, 
      segmentPosition.z+t*segmentDirection.z);
  }

  //Gets the intersection of a line created by "e"
  PVector intersectionWithMovement(Movement e) {
    if (!normalIsInitialized) {
      recalculateNormalAndPosition();
      normalIsInitialized = true;
    }
    float t = PVector.sub(position, e.position).dot(normal)/e.direction.dot(normal);
    return new PVector(e.position.x+t*e.direction.x, 
      e.position.y+t*e.direction.y, 
      e.position.z+t*e.direction.z);
  }

  //Returns true if the face intersects the segment with endpoints at point1 and point2
  boolean intersectsSegment(PVector point1, PVector point2) {
    PVector direction = point2.copy().sub(point1);
    PVector intersection = intersectionWithSegment(point1, direction);
    return intersection.dist(point1)<point2.dist(point1);
  }

  //Gets the y-value of the face at a point on the xz plane
  float getYAt(PVector point) {
    if (!normalIsInitialized) recalculateNormalAndPosition();
    return (PVector.dot(position, normal)-normal.x*point.x-normal.z*point.z)/normal.y;
  }

  //Gets the face that the point is currently above, assuming the y-axis is up
  Face getFace(PVector point) {
    PVector middle = center();
    /*
    -+--------+
     |\  0   /|
     | \    / |
     |  \  /  |
     |3  \/  1|
     |  mid   |
     |  /  \  |
     | /    \ |
     |/  2   \|
     +--------+
     
     
     
     
     */

    //Get the total area of this face and compare it to the one whose center is located at
    //the point parameter
    float expectedArea = 0.0, actualArea = 0.0;
    for (int i = 0; i < vertices.length; i++) {
      expectedArea += areaOfTriangleXZ(middle, vertices[i], vertices[(i+1)%vertices.length]);

      actualArea += 
        areaOfTriangleXZ(point, vertices[i], vertices[(i+1)%vertices.length]);
    }

    //If the point is inside the face, the expected area should be about the same as the actual area,
    //assuming no concave polygons
    if (actualArea<expectedArea*1.001) return this;

    //Find the angle formed by the x-axis, the center point, and the segment created by the 
    //center and the point parameter
    float[] angles = new float[vertices.length];
    int i;
    for (i = 0; i < vertices.length; i++) {
      angles[i]=atan2(vertices[i].x-middle.x, vertices[i].z-middle.z);
    }
    float pointAngle = atan2(point.x-middle.x, point.z-middle.z);
    int clipIndex = -1;
    for (i = 0; i < vertices.length; i++) {
      float delta = abs(angles[i]-angles[(i+1)%vertices.length]);
      float minAngle = min(angles[i], angles[(i+1)%vertices.length]);
      float maxAngle = max(angles[i], angles[(i+1)%vertices.length]);
      if (delta>PI) {
        delta = TAU-delta;
        if ((pointAngle<=minAngle&&pointAngle+TAU>=maxAngle) || (pointAngle-TAU<=minAngle&&pointAngle>=maxAngle)) return adjacentFaces[i];
      } else {
        if (pointAngle>=minAngle&&pointAngle<=maxAngle) return adjacentFaces[i];
      }
    }

    return adjacentFaces[clipIndex];

    //Get the area of each triangle
    //If the smallest computed area of all the triangles is greater than its expected
    //area, that means the point is off of this plane in the direction of that 
    //triangle
    /*
    float minArea = Float.POSITIVE_INFINITY;
     int index = -1;
     for (int i = 0; i < vertices.length; i++) {
     expectedArea = areaOfTriangleXZ(middle, vertices[i], vertices[(i+1)%vertices.length])*1.01;
     actualArea = 
     areaOfTriangleXZ(point, vertices[i], vertices[(i+1)%vertices.length]);
     actualArea += areaOfTriangleXZ(middle, point, vertices[(i+1)%vertices.length]);
     actualArea += areaOfTriangleXZ(middle, vertices[i], point);
     
     float ratio = actualArea/expectedArea;
     if (ratio < minArea) {
     minArea = ratio;
     index = i;
     }
     }
     
     assert index>=0: "The point shouldn't be inside the face!";
     assert (minArea>1.0): "The point shouldn't be inside the face!";
     
     println(index);
     return adjacentFaces[index];
     */
  }

  //Computes the center of the face
  PVector center() {
    PVector c = new PVector();
    for (int i = 0; i < vertices.length; i++) {
      c.add(vertices[i]);
    }
    c.div(vertices.length);
    return c;
  }
  //public static FloorElement fillHoleBetween(FloorElement a, FloorElement b){
  //TODO
  //}
}

class DrawableFace extends Face {
  PVector[] uv;
  color imgColor;
  PImage img;

  public DrawableFace(int numberOfSides) {
    super(numberOfSides);
    uv = new PVector[numberOfSides];
  }

  void draw() {
    textureMode(NORMAL);
    switch(vertices.length) {
    case 3:
      beginShape(TRIANGLE);
      break;
    case 4:
      beginShape(QUADS);
      break;
    default:
      beginShape(TRIANGLE_FAN);
    }

    if (img==null) {
      specular(imgColor);
      emissive(0);
      ambient(0);
    } else {
      //noStroke();
      emissive(255);
      texture(img);
    }

    if (uv==null || uv[0]==null) {
      vertex(vertices[0].x, vertices[0].y, vertices[0].z, 0.0, 0.0);
      vertex(vertices[1].x, vertices[1].y, vertices[1].z, 0.0, 1.0);
      vertex(vertices[2].x, vertices[2].y, vertices[2].z, 1.0, 1.0);
      if (vertices[3]!=null)vertex(vertices[3].x, vertices[3].y, vertices[3].z, 1.0, 0.0);
    } else {
      //assert vertices[0]!=null: "Vertex at 0 is null";
      //assert vertices[1]!=null: "Vertex at 1 is null";
      //assert vertices[2]!=null: "Vertex at 2 is null";
      //assert vertices[3]!=null: "Vertex at 3 is null";
      //assert uv[0]!=null: "UV at 0 is null";
      //assert uv[1]!=null: "UV at 1 is null";
      //assert uv[2]!=null: "UV at 2 is null";
      //assert uv[3]!=null: "UV at 3 is null";
      for (int i = 0; i < vertices.length; i++) {
        vertex(vertices[i].x, vertices[i].y, vertices[i].z, uv[i].x, uv[i].y);
      }
      //vertex(vertices[0].x, vertices[0].y, vertices[0].z, uv[0].x, uv[0].y);
      //vertex(vertices[1].x, vertices[1].y, vertices[1].z, uv[1].x, uv[1].y);
      //vertex(vertices[2].x, vertices[2].y, vertices[2].z, uv[2].x, uv[2].y);
      //vertex(vertices[3].x, vertices[3].y, vertices[3].z, uv[3].x, uv[3].y);
    }


    endShape();
  }
}


float areaOfTriangle(PVector p1, PVector p2, PVector p3) {
  PVector v1 = PVector.sub(p2, p1), v2 = PVector.sub(p3, p1);
  return v1.cross(v2).mag()/2.0;
}

//Compresses a triangle into the XZ plane and finds its area
float areaOfTriangleXZ(PVector p1, PVector p2, PVector p3) {
  float product = ((p2.x-p1.x)*(p3.z-p1.z)-(p3.x-p1.x)*(p2.z-p1.z))/2.0;
  return abs(product);
}

class Movement {
  PVector position, direction;
  public Movement() {
    this(new PVector(0.0, 0.0, 0.0));
  }
  public Movement(PVector position) {
    this(position, new PVector(1.0, 0.0, 0.0));
  }
  public Movement(PVector position, PVector direction) {
    this.position = position;
    this.direction = direction;
  }
  public void addToPosition(PVector velocity) {
    position = position.add(velocity);
    direction = velocity.normalize();
  }
  void draw() {
    drawPoint(position);
  }
}

class Player extends Movement {
  //Placement and motion values
  PVector previousPosition;
  PVector velocity;
  PVector acceleration;

  //Movement control
  private boolean accelerationEnabled = true;
  private boolean velocityEnabled = true;

  //Display
  color spriteColor;
  PImage sprite;
  int spriteIndex;

  public Player() {
    this(new PVector(0, -100, 0));
  }
  public Player(PVector position) {
    super(position);
    velocity = new PVector(0, 0, 0);
    acceleration = new PVector(0, 0, 0);
  }
  void update() {
    if (accelerationEnabled) velocity.add(acceleration);
    if (velocityEnabled) position.add(velocity);
    if (velocity.magSq()>0.01)velocity.normalize(direction);
  }
  void enableAccleration() {
    accelerationEnabled=true;
  }
  void disableAcceleration() {
    accelerationEnabled=false;
  }
  boolean accelerationEnabled() {
    return accelerationEnabled;
  }
  void enableVelocity() {
    velocityEnabled=true;
  }
  void disableVelocity() {
    velocityEnabled=false;
  }
  boolean velocityEnabled() {
    return velocityEnabled;
  }

  @Override void draw() {
    //pushMatrix();
    textureMode(NORMAL);
    beginShape(QUADS);
    blendMode(BLEND);
    if (sprite==null) {
      specular(spriteColor);
      emissive(0);
      ambient(0);
    } else {
      noStroke();
      emissive(255);
      texture(sprite);
    }
    vertex(position.x+0.5, position.y, position.z, 1.0, 1.0);
    vertex(position.x+0.5, position.y-1.0, position.z, 1.0, 0.0);
    vertex(position.x-0.5, position.y-1.0, position.z, 0.0, 0.0);
    vertex(position.x-0.5, position.y, position.z, 0.0, 1.0);
    endShape();
    //popMatrix();
  }

  void draw(float phi, float theta) {
    //strokeWeight(4);
    //stroke(255);
    textureMode(NORMAL);
    blendMode(BLEND);
    pushMatrix();
    translate(position.x, position.y, position.z);
    //scale(2.0);
    beginShape(QUADS);
    if (sprite==null) {
      specular(spriteColor);
      emissive(0);
      ambient(0);
    } else {
      noStroke();
      emissive(255);
      texture(sprite);
    }

    float[][] verts = {
      {-1.0, -1.0, 0.0}, 
      {-1.0, 1.0, 0.0}, 
      { 1.0, 1.0, 0.0}, 
      { 1.0, -1.0, 0.0}};

    float mag = sqrt(2);


    for (int i = 0; i < 4; i ++) {
      //Constrain vectors to magnitudes of 1
      verts[i][0]/=mag;
      verts[i][1]/=mag;
      verts[i][2]/=mag;

      //Rotate locking the x-axis
      if (verts[i][1]<0) {
        verts[i][1]=sin(phi+HALF_PI);
        verts[i][2]=cos(phi+HALF_PI);
      } else {
        verts[i][1]=sin(phi+3.0*HALF_PI);
        verts[i][2]=cos(phi+3.0*HALF_PI);
      }

      //Rotate locking the y-axis
      float dir = atan2(verts[i][2], verts[i][0])-HALF_PI;
      verts[i][0] = cos(dir+theta);
      verts[i][2] = sin(dir+theta);
    }

    vertex(verts[0][0], verts[0][1] - 0.5, verts[0][2], 1.0, 1.0);
    vertex(verts[1][0], verts[1][1] - 0.5, verts[1][2], 1.0, 0.0);
    vertex(verts[2][0], verts[2][1] - 0.5, verts[2][2], 0.0, 0.0);
    vertex(verts[3][0], verts[3][1] - 0.5, verts[3][2], 0.0, 1.0);

    /*
    float cosPhi = cos(-cos(phi)*QUARTER_PI+HALF_PI),
     sinPhi = sin(-cos(phi)*QUARTER_PI+HALF_PI),
     cosTheta = cos(theta),
     sinTheta = sin(theta);
     
     
     vertex(sinPhi*cos(theta+QUARTER_PI),cosPhi-0.5,sinPhi*sin(theta+QUARTER_PI),0.0,1.0);
     vertex(sinPhi*cos(theta+3.0*QUARTER_PI),-cosPhi-0.5,sinPhi*sin(theta+3.0*QUARTER_PI),0.0,0.0);
     vertex(sinPhi*cos(theta+5.0*QUARTER_PI),-cosPhi-0.5,sinPhi*sin(theta+5.0*QUARTER_PI),1.0,0.0);
     vertex(sinPhi*cos(theta+7.0*QUARTER_PI),cosPhi-0.5,sinPhi*sin(theta+7.0*QUARTER_PI),1.0,1.0);
     */

    //vertex(position.x-2.5*cos(phi)*cos(theta), position.y+2.5*sin(phi), position.z+2.5*cos(phi)*sin(theta), 1.0, 1.0);
    //vertex(position.x-2.5*cos(phi)*cos(theta), position.y-2.5*sin(phi), position.z-2.5*cos(phi)*sin(theta), 1.0, 0.0);
    //vertex(position.x+2.5*cos(phi)*cos(theta), position.y-2.5*sin(phi), position.z-2.5*cos(phi)*sin(theta), 0.0, 0.0);
    //vertex(position.x+2.5*cos(phi)*cos(theta), position.y+2.5*sin(phi), position.z+2.5*cos(phi)*sin(theta), 0.0, 1.0);
    endShape();
    popMatrix();
  }
}
