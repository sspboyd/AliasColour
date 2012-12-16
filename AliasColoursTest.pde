// new boxes sketch
/* 
 This sketch reads colours from a pixel array (PImage) and displays the most prevalent colour(s)
 in one or more boxes. I'm calling them boxes but they could be circles, triangles, whatever.
 Might be better to call them cells? Then I could have cells within cells?
 
 */

// Import Libraries
// import processing.pdf.*;
import toxi.color.*;
import toxi.math.*;
import java.util.List;

// Source Image
PImage baseSrc;


void setup() {
  // load the source image from a file
  // baseSrc = loadImage("P1060666-Cropped-smaller.jpg");
  // baseSrc = loadImage("P1040862-small.jpg");
  // baseSrc = loadImage("P1030205.JPG");
  baseSrc = loadImage("image2.jpg");
  // baseSrc = loadImage("P1090881.jpg");

  // baseSrc = loadImage("F1000012.jpg");
  // baseSrc = loadImage("P1030557.png");

  // Size of the sketch is based on the size of the source image
  // size(baseSrc.width, baseSrc.height); 
  size(1000,618);
  //  size(800,800, PDF, "boxes.pdf"); // does this size matter if I'm drawing to a pdf? Only the w to h ratio matters?
  background(255); // sets background colour to white
  //noLoop(); // no need to run the draw method

  noStroke(); // don't want lines around the boxes
makeNewHist();
}

void makeNewHist(){
  background(255);
  // these are used when grabbing a subsection of the baseSrc image in the loop below
  int baseSrcGridW = 100; 
  int baseSrcGridH = 100;
 PVector baseSrcPos = new PVector(int(random(width-baseSrcGridH)),int(random(height-baseSrcGridH))); 
 // PVector baseSrcPos = new PVector(width/2, height/2); 

 PImage histArchetypeSrc = baseSrc.get(int(baseSrcPos.x), int(baseSrcPos.y), baseSrcGridW, baseSrcGridH);

  // tolerance is defines how close colours in the src image have to be to be grouped as one colour 
  float tolerance = 0.1;

  // create a color histogram of image, using only 50% of its pixels and the given tolerance
  Histogram hist=Histogram.newFromARGBArray(histArchetypeSrc.pixels, histArchetypeSrc.pixels.length/2, tolerance, true);
  List<HistEntry> f = hist.getEntries();
  int counter = 0;
  for (HistEntry he : f){
    color currentClr = he.getColor().toARGB();
    float currFreq = he.getFrequency();

    // PVector clrSqr = new PVector(0,0);
    if(counter < 30){
    float clrSqrx = map(counter, 0, 30, 50, width-50);
    float clrSqry = height-50;
    float clrSqrH = map(currFreq, 0, 1, 0, -350);
    
    fill(currentClr);
    
    rect(clrSqrx, clrSqry, 20, clrSqrH);
  }
    counter++;
    //println("HistEntry #" + counter + ": [" + red(currentClr) + ", " + green(currentClr) + ", " + blue(currentClr) + "], " + currFreq);
    
  }

  image(histArchetypeSrc, 50,50);


}

void draw() {
  // everything is drawn in the setup method, no need to run draw()
  //  c1.render();
}


// This class holds a bunch of info to help define location, size and colour of the ColourCell objects
class ColourGroup { 
  int x, y, w, h;
  int depth; // the number of boxes/cells/whatever deep that the group should display
  ColourCell[] cells;

  ColourGroup(int _x, int _y, int _w, int _h, PImage _src, int _depth) {
    w = _w; 
    h = _h; 
    x = _x; 
    y = _y;
    depth = _depth; 
    PImage src = _src;
    cells = new ColourCell[depth];
    println("new ColourGroup data: x, y, w, h, depth = [" + x + ", " + y + ", " + w + ", " + h + ", " + depth + "]");

    // tolerance is defines how close colours in the src image have to be to be grouped as one colour 
    float tolerance = 0.005;

    // create a color histogram of image, using only 50% of its pixels and the given tolerance
    Histogram hist=Histogram.newFromARGBArray(src.pixels, src.pixels.length/2, tolerance, true);
    List<HistEntry> f = hist.getEntries();

    // I like phi. Used to scale the size of the ColourCell boxes
    float invPHI= 1 / 1.618033988749895;

    for(int i=0; i<depth; i++) {
      // do this with recursion
      // create a tile/cell/frame at a location with a size etc and a color
      // calculate histogram first
      // while depth > 1 create a new tile/cell based on a counter

      // set width of current cell
      // int cellW = int((1.0*depth-i)/depth * w); // need to figure this part out
      // int cellH = int((1.0*depth-i)/depth * h);
      int cellW = (i>=1) ? int(w*pow(invPHI,i)) : w;
      int cellH = (i>=1) ? int(h*pow(invPHI,i)) : h;


      // grab a colour from the histogram for the ColourCell constructor coming up
      HistEntry ff = f.get(i);
      color currentClr = ff.getColor().toARGB();

      // create new Colour cell 
      cells[i]= new ColourCell(x, y, cellW, cellH, currentClr);

      // println("x, y, cellW, cellH, currentClr: " + x + ", " + y + ", " + cellW + ", " + cellH + ", " + currentClr);

      // draw the ColourCell
      cells[i].render();
    }
  }
}


class ColourCell {
  int w, h, x, y;
  color clr;

  ColourCell(int _x, int _y, int _w, int _h, color _clr) {
    w = _w; 
    h = _h; 
    x = _x; 
    y = _y;
    clr = _clr;
  }

  void render() {
    fill(clr);
    rectMode(CENTER);
    rect(x,y,w*1+1,h*1+1);
    // ellipse(x,y,w*2,h*2);
  }
}
void keyPressed() {
  if (key == 'n') makeNewHist();
}

