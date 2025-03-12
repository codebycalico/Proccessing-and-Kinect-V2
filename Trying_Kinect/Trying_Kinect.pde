import KinectPV2.*;
import com.cage.zxing4p3.*;

ZXING4P zxing4p;
String decodedText;
String latestDecodedText = "";
int txtWidth;

KinectPV2 kinect;

// track the coordinate corner[x][y]
int[][] corner = {{0, 0}, {0, 0}, {0, 0}, {0, 0}};
boolean callibrated = false;

int [] depthIndex;

// amount to rotate
int a = 0;

// buffer array to clea the pixels
PImage depthToColorImg;
PImage depth_img;
PImage color_img;

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
  
  zxing4p = new ZXING4P();
  // display version information
  zxing4p.version();
}

void draw() {
  background(0);
  callibrated = callibrateCorners();
  
  // get the raw data from the depth and color
  float [] mapDepthToColor = kinect.getMapDepthToColor();
  int [] colorRaw = kinect.getRawColor();
  
  // clean the depthIndex pixels
  PApplet.arrayCopy(depthIndex, depthToColorImg.pixels);
  
  depth_img = kinect.getDepthImage();
  color_img = kinect.getColorImage();
  
  //image(depth_img, 0, 0);
  //image(color_img, 0, 0, color_img.width*0.267, color_img.height*0.267);
  //image(depth_img, 0, 0);
  
  // translate and rotate
  pushMatrix();
  translate(width/2, height/2, -2250);
  rotateY(a);
  int [] depthRaw = kinect.getRawDepthData();
  int skip = 2;
  strokeWeight(5);
  beginShape(POINTS);
  
  // look at every single depth pixel
  for (int x = 0; x < depth_img.width; x+=skip) {
    for (int y = 0; y < depth_img.height; y+=skip) {
      int offset = x + y * depth_img.width;
      // d largest = 7996
      // d smallest = 0
      int d = depthRaw[offset];
      //calculte the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, d);
      
      // d is the depth distance, use to calculate the 
      // color mapping
      if( x > 100 && y > 100 && x < (width - 150) && y < (height - 100)) {   
        if(d <= 1675 && d > 1500) {
          stroke(255, 0, 0);
        } else if(d > 1675 && d <= 1700) {
          stroke(255, 255, 0);
        } else if(d > 1700 && d <= 1810) {
          stroke(0, 255, 0);
        } else if(d > 1810 && d <= 2000) {
          stroke(0, 0, 255);
        }
        // Draw a point
        vertex(point.x, point.y, point.z);
      }
    }
  }
  endShape();

  popMatrix();

  fill(255);
  text(frameRate, 50, 50);

  // Rotate
  a += 0.0015;
  
  //image(colimg, 0 - corner[0][0], 0 - corner[0][1], colimg.width + corner[1][0], colimg.height);
  //image(img, 0, 0);
  ////have to display the video capture
  //set(0, 0, color_img);
  
  ////display latest decoded text
  //if(!latestDecodedText.equals("")) {
  // txtWidth = int(textWidth(latestDecodedText));
  // fill(0, 150);
  // rect((width>>1) - (txtWidth>>1) - 5, 15, txtWidth + 10, 36);
  // fill(255, 255, 0);
  // text(latestDecodedText, width>>1, 43);
  //}
  
  //// TRY TO DETECT AND DECODE A QRCODE IN THE VIDEO CAPTURE
  //// QRCodeReader(PImage img, boolean tryHarder)
  //// tryHarder: false => fast detection (less accurate)
  ////            true  => best detection (little slower
  //try {
  //  decodedText = zxing4p.QRCodeReader(depth_img, false);
  //}
  //catch (Exception e) {
  //  decodedText = "";
  //}
  
  //if(!decodedText.equals("")) {
  //  // found a QR code
  //  if(latestDecodedText.equals("") || (!latestDecodedText.equals(decodedText))) {
  //    println("Zxing4pprocessing detected: " + decodedText);
  //  }
  //  latestDecodedText = decodedText;
  //}
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

//void mouseClicked() {
//  if(!callibrated) {
//    for (int i = 0; i < corner.length; i++) {
//      if(corner[i][0] == 0) {
//        corner[i][0] = mouseX;
//        corner[i][1] = mouseY;
//        break;
//      }
//    }
//  }
//}
