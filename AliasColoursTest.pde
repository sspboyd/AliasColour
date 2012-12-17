// Import Libraries
// import processing.pdf.*;
import toxi.color.*;
import toxi.math.*;
import java.util.List;

PFont font;

// Source Image
PImage arctyp;
PImage media;
PImage histArchetypeSrc;
PImage histMedSrc;
int max_bins;
float maxScore;
float minScore;

void setup() {
  size(1000,618);
  background(255); // sets background colour to white

  // load the source image from a file
  arctyp =  loadImage("F1000012.jpg");
  media =   loadImage("P1060666-Cropped-smaller.jpg");

  font = createFont("Helvetica", 10);  //requires a font file in the data folder
  textFont(font);

  maxScore = MIN_FLOAT;
  minScore = MAX_FLOAT;

  // Notes
  // for each?/every? image
  // make freq histogram
  // use colordist put into 0-256 'bins' based on brightness
  // add up freqs of each color going into each bin

  // idea: use different types of matching algorithms.
  // - similarity of top colours
  // - full spectrum match
  // - spectrum biased matching


// new image = archtyp, medium, PImage output, output w & h, layers, type of matching)

// layers is another way of specifcying number of subdivisions


// binNumber = map brightness value of a freq hist entry color, 
// current range 0 , max dist between black and white blk.distanceToRGB(wht))
// output range 0, 256 (bins)
// float[] bins = new Array[256];
// bins[binNumber]+= currHistEntry.getFrequency();
// (or maybe need redBin, blueBin, greenbin to create color separated histograms)



  // these are used when grabbing a subsection of the arctyp image in the loop below
  int arctypGridW = 150; 
  int arctypGridH = 150;
  // these are used when grabbing a subsection of the medium image in the loop below
  int medGridW = 150; 
  int medGridH = 150;

  max_bins = 32; // probably not the right spot for this value. Should be passed in maybe?


    // Grab random square from archetype image
  PVector arctypTilePos = new PVector(int(random(arctyp.width-arctypGridW)),int(random(arctyp.height-arctypGridH))); 

  // Grab random square from medium image
  PVector medTilePos = new PVector(int(random(media.width-medGridW)),int(random(media.height-medGridH))); 

  histArchetypeSrc = arctyp.get(int(arctypTilePos.x), int(arctypTilePos.y), arctypGridW, arctypGridH);
  histMedSrc = media.get(int(medTilePos.x), int(medTilePos.y), medGridW, medGridH);
  compareImgs(histArchetypeSrc, histMedSrc);
  // makeNewHist(histArchetypeSrc);
}

float[] histToBins(List<HistEntry> fhe){
  float[] bins = new float[max_bins];
  TColor blk = TColor.BLACK.copy(); // create black and white values as references
  TColor wht = TColor.WHITE.copy();
  float max_dist = blk.distanceToRGB(wht);

    for (HistEntry e : fhe){ // for each  HistEntry e in fhe
      float d = blk.distanceToRGB(e.getColor());
      // bin number equals distance from black / max distance * max bins
      int binNum = int((d / max_dist) * max_bins);
      bins[binNum] += e.getFrequency();
    }
    return bins;
  }




  float getFit(float[] a, float[] m){
  float score=0; // 0 is a perfect match
  for (int i = 0; i<a.length; i++){
    score += abs(a[i]-m[i]);
  }
  return score;
}

void compareImgs(PImage a, PImage m){
// for each tile in a layer...
// get colour list of the archetype and media
// use ColorList.createFromARGBArray(int[] pixels, int pixels.length, boolean false)
// get average colour of the two image's colours
// get brightness of the average colour from both images
// get hue of the average colour from both images
// get hue delta between two colours
// get brightness delta between two brightnesses
// apply weighting to hue delta based on current layer/resolution
// apply weighting to brightness delta based on current layer/resolution
// add em up and get the fitness score
// if the fitness score is higher than a certain threshold, 
//    use 'media' tile to recreate 'archetype' image in new 'painting'









  // tolerance is defines how close colours in the src image have to be to be grouped as one colour 
  float tolerance = 0.075;

  // create a color histogram of image, using only 50% of its pixels and the given tolerance
  Histogram aFreqHist = Histogram.newFromARGBArray(a.pixels, a.pixels.length/2, tolerance, true);
  Histogram mFreqHist = Histogram.newFromARGBArray(m.pixels, m.pixels.length/2, tolerance, true);

  List<HistEntry> aFreqHistEnt = aFreqHist.getEntries();
  List<HistEntry> mFreqHistEnt = mFreqHist.getEntries();

  float[] aBin = histToBins(aFreqHistEnt);
  float[] mBin = histToBins(mFreqHistEnt);

  float fit = getFit(aBin, mBin);
  String strFit = nf(fit,1,1);

  if(fit>maxScore){
    maxScore = fit;
  }
  if(fit<minScore){
    minScore = fit;
  }

  int counter = 0;

  //render section  
  background(255);

  image(a, 50, height/2 - 25 - 150);
  fill(0);
  textSize(14);
  stroke(0);
  line(50, height-75, width-50, height-75);
  PVector scoreMarker = new PVector(0,0);
  scoreMarker.x = map(fit, minScore, maxScore, 50, width-50);
  scoreMarker.y = height-75-5;
  rect(scoreMarker.x, scoreMarker.y, 3, 10);
  text(nf(minScore,1,1), 50, scoreMarker.y-25);
  text(nf(maxScore,1,1), width-50, scoreMarker.y-25);
  text(strFit, scoreMarker.x, scoreMarker.y-25);

  text("Fitness Score: " + strFit, 50, height/2);

  image(m, 50, height/2 + 25);

  float binW = 10;
  for (int i = 0; i<aBin.length; i++){
    // draw rect for frequency
    float binH = map(aBin[i], 0, 2, 0, -500);
    float binY = height/2 - 25;
    float binX = map(i, 0, max_bins, 250, width-50);
    stroke(126);
    strokeWeight(0.5);
    fill(color((1.0*i/max_bins)*255)); // create grey scale colour gradient
    //fill(0); 
    rect(binX, binY, binW, binH);
    textSize(10);
    text(nf(aBin[i],1,2), binX, binY +18);
  }
  for (int i = 0; i<mBin.length; i++){
    // draw rect for frequency
    //float binW = 18;
    float binH = map(mBin[i], 0, 2, 0, 500);
    float binY = height /2 +25;
    float binX = map(i, 0, max_bins, 250, width-50);
    noStroke();
    // fill(color((1.0*i/max_bins)*255)); // create grey scale colour gradient
    fill(0); // create grey scale colour gradient
    rect(binX, binY, binW, binH);
    textSize(10);
    text(nf(mBin[i],1,2), binX, binY -15);
  }
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
  if (key == 'S') screenCap();

  if (key == 'n'){
      // these are used when grabbing a subsection of the arctyp image in the loop below
      int arctypGridW = 50; 
      int arctypGridH = 50;

      PVector arctypTilePos = new PVector(int(random(width-arctypGridH)),int(random(height-arctypGridH))); 
  // PVector arctypTilePos = new PVector(width/2, height/2); 

  histArchetypeSrc = arctyp.get(int(arctypTilePos.x), int(arctypTilePos.y), arctypGridW, arctypGridH);
//compareImgs(arctyp, medium)
makeNewHist(histArchetypeSrc);

}

if(key == 'c'){
    // these are used when grabbing a subsection of the arctyp image in the loop below
    int arctypGridW = 150; 
    int arctypGridH = 150;
  // these are used when grabbing a subsection of the medium image in the loop below
  int medGridW = 150; 
  int medGridH = 150;


  // Grab random square from archetype image
  PVector arctypTilePos = new PVector(int(random(arctyp.width-arctypGridW)),int(random(arctyp.height-arctypGridH))); 

  // Grab random square from medium image
  PVector medTilePos = new PVector(int(random(media.width-medGridW)),int(random(media.height-medGridH))); 
  
  histArchetypeSrc = arctyp.get(int(arctypTilePos.x), int(arctypTilePos.y), arctypGridW, arctypGridH);
  histMedSrc = media.get(int(medTilePos.x), int(medTilePos.y), medGridW, medGridH);
  compareImgs(histArchetypeSrc, histMedSrc);

}
}

void makeNewHist(PImage a){
  background(255);


  // tolerance is defines how close colours in the src image have to be to be grouped as one colour 
  float tolerance = 0.075;

  // create a color histogram of image, using only 50% of its pixels and the given tolerance
  Histogram hist=Histogram.newFromARGBArray(a.pixels, a.pixels.length/2, tolerance, true);
  List<HistEntry> f = hist.getEntries();
  int counter = 0;
  TColor blk = TColor.BLACK.copy();
  for (HistEntry he : f){
    color currentClr = he.getColor().toARGB();
    float currFreq = he.getFrequency();

    // PVector clrSqr = new PVector(0,0);
    if(counter < 30){
      float clrSqrx = map(counter, 0, 30, 50, width-50);
      float clrSqry = height-75;
      float clrSqrH = map(currFreq, 0, 1, 0, -325);
      float d = blk.distanceToRGB(he.getColor());

      fill(0);
      text(d, clrSqrx, clrSqry+25);
      fill(currentClr);


      rect(clrSqrx, clrSqry, 20, clrSqrH);
    }
    counter++;
    //println("HistEntry #" + counter + ": [" + red(currentClr) + ", " + green(currentClr) + ", " + blue(currentClr) + "], " + currFreq);
    
  }

  image(a, 50,50);


}

void screenCap() {
  // save functionality in here
  String outputDir = "out/";
  String sketchName = "aliasColoursTest-";
  String dateTime = "" + year() + month() + day() + hour() + minute() + second();
  String fileType = ".tif";
  String fileName = outputDir + sketchName + dateTime + fileType;
  save(fileName);
  println("Screen shot taken and saved to " + fileName);
}

/* 
Misc / Slush 
  TColor blk = TColor.BLACK.copy();
  TColor wht = TColor.WHITE.copy();
  TColor rd = TColor.RED.copy();
  TColor bl = TColor.BLUE.copy();
  TColor gr = TColor.GREEN.copy();

  println("dist between black and white: " + blk.distanceToRGB(wht));
  println("dist between black --> red: " + blk.distanceToRGB(rd));
  println("dist between white --> red: " + wht.distanceToRGB(rd));
  println("dist between black --> blue: " + blk.distanceToRGB(bl));
  println("dist between white --> blue: " + wht.distanceToRGB(bl));
  println("dist between black --> green: " + blk.distanceToRGB(gr));
  println("dist between red --> green: " + rd.distanceToRGB(gr));


  */


