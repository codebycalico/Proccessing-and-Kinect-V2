import KinectPV2.*;

KinectPV2 kinect;

// track the coordinate corner[x][y]
int[][] corner = {{0, 0}, {0, 0}, {0, 0}, {0, 0}};
boolean callibrated = false;

int [] depthIndex;

int a = 0;

// buffer array to clea the pixels
PImage depthToColorImg;

void setup() {
  size (800, 600, P3D);
  smooth();
  
  depthToColorImg = createImage(512, 424, PImage.RGB);
  depthIndex = new int[KinectPV2.WIDTHDepth * KinectPV2.HEIGHTDepth];
  // initialize array to all zeroes
  for (int i = 0; i < KinectPV2.WIDTHDepth; i++) {
    for (int j = 0; j < KinectPV2.HEIGHTDepth; j++) {
      depthIndex[424*i + j] = 0;
    }
  }
  
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enableColorImg(true);
  kinect.init();
}

void draw() {
  background(0);
  callibrated = callibrateCorners();
  
  // get the raw data from the depth and color
  float [] mapDepthToColor = kinect.getMapDepthToColor();
  int [] colorRaw = kinect.getRawColor();
  
  // clean the depthIndex pixels
  PApplet.arrayCopy(depthIndex, depthToColorImg.pixels);
  
  PImage depth_img = kinect.getDepthImage();
  //look at every single depth pixel
  for (int x = 0; x < depth_img.width; x++) {
    for (int y = 0; y < depth_img.height; y++) {
      // find the index of the pixel in the array
      int index = x + y * depth_img.width;
      // pull out out the color at that pixel
      int col = depth_img.pixels[index];
    }
  }
  
  //image(depth_img, 0, 0);
  PImage color_img = kinect.getColorImage();
  //image(color_img, 0, 0, color_img.width*0.267, color_img.height*0.267);
  //image(depth_img, 0, 0);
  
  // translate and rotate
  pushMatrix();
  translate(width/2, height/2, -2250);
  rotateY(a);
  int [] depthRaw = kinect.getRawDepthData();
  int skip = 1;
  int heighest = 0;
  int lowest = 1000;
  strokeWeight(4);
  beginShape(POINTS);
  for (int x = 0; x < depth_img.width; x+=skip) {
    for (int y = 0; y < depth_img.height; y+=skip) {
      int offset = x + y * depth_img.width;
      int d = depthRaw[offset];
      //calculte the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, d);
      
      if( x > 100 && y > 100 && x < (width - 100) && y < (height - 50)) {   
        if(d <= 1700 && d > 1500) {
          stroke(255, 0, 0);
        } else if(d > 1700 && d <= 1810) {
          stroke(0, 255, 0);
        } else if(d > 1810 && d <= 2000) {
          stroke(0, 0, 255);
        }
        // Draw a point
        vertex(point.x, point.y, point.z);
      }
      
      if(d > heighest) {
        heighest = d;
      }
      if(d < lowest) {
        lowest = d;
      }
    }
  }
  endShape();

  popMatrix();

  fill(255);
  text(frameRate, 50, 50);

  // Rotate
  a += 0.0015;
  
  println("Heighest: ", heighest);
  println("Lowest: ", lowest);
  
  //image(colimg, 0 - corner[0][0], 0 - corner[0][1], colimg.width + corner[1][0], colimg.height);
  //image(img, 0, 0);
  
  // look at every single color pixel 
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}

boolean callibrateCorners() {
 if(corner[3][0] != 0.0) {
    return true;
  }
  
  return false;
}

void mouseClicked() {
  if(!callibrated) {
    for (int i = 0; i < corner.length; i++) {
      if(corner[i][0] == 0) {
        corner[i][0] = mouseX;
        corner[i][1] = mouseY;
        break;
      }
    }
  }
}
