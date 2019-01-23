import java.util.Properties;
import java.io.*;
String assetPath = "assets.txt";


void loadGameAssets() {
  Properties props = new Properties();
  try {
    props.load(createReader(assetPath));
    println(props);
    player.sprite = loadImage(props.getProperty("playerTexture"));
    PImage groundImage = loadImage(props.getProperty("floorTexture"));
    face.img = groundImage;
    face2.img = groundImage;
    parseWavefrontIntoLevel("Route64Sqrares.obj", groundImage);
  }
  catch(IOException e) {
    e.printStackTrace();
  }

  /*
  BufferedReader reader = createReader(assetPath);
   String line = null;
   try {
   //Parse the game assets
   while ((line = reader.readLine()) != null) {
   String[] pieces = split(line, TAB);
   Properties p;
   if(pieces[0].equals("image")){
   if(pieces[1].equals("player")){
   if(pieces[2].equals("size")){
   player.sprite = new PImage[int(pieces[3])];
   }
   else{
   player.sprite[int(pieces[2])] = loadImage(pieces[3]);
   }
   }
   }
   
   image = loadImage("block.png");
   }
   reader.close();
   } catch (IOException e) {
   e.printStackTrace();
   }
   */
}

void parseWavefrontIntoLevel(String filename, PImage texture) {
  //TODO
  ArrayList<PVector> verts = new ArrayList<PVector>(200);
  ArrayList<PVector> normals = new ArrayList<PVector>(200);
  ArrayList<PVector> textureCoordinates = new ArrayList<PVector>(200);
  ArrayList<DrawableFace> faces = new ArrayList<DrawableFace>();

  // Open the file from the createWriter() example
  BufferedReader reader = createReader(filename);
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
      String[] s = splitTokens(line);

      //Parse each line
      if (s[0].equals("v")) {
        PVector vector = new PVector(float(s[1]), float(s[2]), float(s[3]));
        verts.add(vector);
      } else if (s[0].equals("vt")) {
        PVector vector = new PVector(float(s[1]), float(s[2]));
        textureCoordinates.add(vector);
      } else if (s[0].equals("vn")) {
        PVector vector = new PVector(float(s[1]), float(s[2]), float(s[3]));
        normals.add(vector);
      } else if (s[0].equals("f")) {
        DrawableFace face = new DrawableFace(s.length-1);
        for (int i = 0; i < s.length-1; i++) {
          String[] vert = split(s[i+1], '/');
          face.vertices[i]=verts.get(int(vert[0])-1); //<>//
          face.uv[i]=textureCoordinates.get(int(vert[1])-1); //<>//
        }
        face.img = texture;
        face.recalculateNormalAndPosition();
        faces.add(face);
      }
    }
    reader.close();

    //Output face array into global face array
    ground = faces.toArray(new DrawableFace[faces.size()]);
    
    //Find all matching vertices
    for(int i = 0; i < ground.length; i++){
      DrawableFace f1 = ground[i];
      
      for(int j = 0; j < ground.length; j++){
        if(i==j) continue;
        
        DrawableFace f2 = ground[j];
        if(f2==f1)continue;
        
        boolean[] found = new boolean[f1.vertices.length];
        for(int k = 0; k < f1.vertices.length; k++){
          found[k]=false;
          for(int l = 0; l < f2.vertices.length; l++){
            if(f1.vertices[k]==f2.vertices[l]) found[k]=true;
          }
        }
        for(int k = 0; k < found.length-1; k++){
          if(found[k]&&found[k+1]) f1.adjacentFaces[k]=f2;
        }
        if(found[found.length-1]&&found[0]) f1.adjacentFaces[found.length-1]=f2;//FIXME
      }
    }
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}
