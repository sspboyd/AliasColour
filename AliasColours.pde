// Import Libraries
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

// these are used when grabbing a subsection of the arctyp image in the loop below
int arctypGridW = 50; 
int arctypGridH = 50;
// these are used when grabbing a subsection of the medium image in the loop below
int medGridW = 150; 
int medGridH = 150;

void setup() {
  size(1000,618);
  

  // load the source image from a file
  arctyp =  loadImage("F1000012.jpg");
  media =   loadImage("P1060666-Cropped-smaller.jpg");

  font = createFont("Helvetica", 10);  //requires a font file in the data folder
  textFont(font);

  maxScore = 2;
  minScore = 0;
  // maxScore = MIN_FLOAT;
  // minScore = MAX_FLOAT;
  max_bins = 24; // probably not the right spot for this value. Should be passed in maybe?


  // this is duplicate code. Should be moved into the compareImgs() function
  // Grab random square from archetype and medium image
  PVector arctypTilePos = new PVector(int(random(arctyp.width-arctypGridW)),int(random(arctyp.height-arctypGridH))); 
  PVector medTilePos = new PVector(int(random(media.width-medGridW)),int(random(media.height-medGridH))); 

  histArchetypeSrc = arctyp.get(int(arctypTilePos.x), int(arctypTilePos.y), arctypGridW, arctypGridH);
  histMedSrc = media.get(int(medTilePos.x), int(medTilePos.y), medGridW, medGridH);
  compareImgs(histArchetypeSrc, histMedSrc);
}

void draw() {
  // everything is drawn in the setup method, no need to run draw()
  //  c1.render();
}

// for each tile in a layer...
void compareImgs(PImage a, PImage m){
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

  // Image Comparison
  // tolerance defines how close colours in the src image have to be to be grouped as one colour 
  float tolerance = 0.025;

  // create a color histogram of image, using only 50% of its pixels and the given tolerance
  Histogram aFreqHist = Histogram.newFromARGBArray(a.pixels, a.pixels.length/2, tolerance, true);
  Histogram mFreqHist = Histogram.newFromARGBArray(m.pixels, m.pixels.length/2, tolerance, true);

  List<HistEntry> aFreqHistEnt = aFreqHist.getEntries();
  List<HistEntry> mFreqHistEnt = mFreqHist.getEntries();

  float[] aBin = histToBins(aFreqHistEnt);
  float[] mBin = histToBins(mFreqHistEnt);

  float fit = getFit(aBin, mBin);
  String strFit = nf(fit,1,2);

  if(fit>maxScore) maxScore = fit;
  if(fit<minScore) minScore = fit;

  //render section  
  background(255);

  image(a, 50, height/2 - 25 - 150,150,150);
  image(m, 50, height/2 + 25,150,150);

  fill(0);
  textSize(14);
  stroke(0);
  line(50, height-75, width-50, height-75);
  PVector scoreMarker = new PVector(0,0);
  scoreMarker.x = map(fit, minScore, maxScore, 50, width-50);
  scoreMarker.y = height-75-5;
  rect(scoreMarker.x, scoreMarker.y, 3, 10);
  text(nf(minScore,1,2), 50, scoreMarker.y-5);
  text(nf(maxScore,1,2), width-50-textWidth("1.0"), scoreMarker.y-5);
  text(strFit, scoreMarker.x-textWidth(strFit)/2, scoreMarker.y-25);
    text("same", 50, height-50);
  text("different", width-50-textWidth("different"), height-50);

  // too much duplicate code below
  float binW = 20;
  for (int i = 0; i<aBin.length; i++){
    // draw rect for frequency
    float binH = map(aBin[i], 0, 1, 0, -height/2 + 50);
    float binY = height/2 - 25;
    float binX = map(i, 0, max_bins, 250, width-50);
    stroke(126);
    strokeWeight(0.5);
    fill(color((1.0*i/max_bins)*255)); // create grey scale colour gradient
    rect(binX, binY, binW, binH);
    textSize(10);
    fill(47); 
    text(nf(aBin[i],1,2), binX, binY +18);
  }
  for (int i = 0; i<mBin.length; i++){
    // draw rect for frequency
    //float binW = 18;
    float binH = map(mBin[i], 0, 1, 0, height/2 - 50);
    float binY = height /2 +25;
    float binX = map(i, 0, max_bins, 250, width-50);
    stroke(126);
    fill(color((1.0*i/max_bins)*255)); // create grey scale colour gradient
    rect(binX, binY, binW, binH);
    textSize(10);
    fill(47); 
    text(nf(mBin[i],1,2), binX, binY -15);
  }
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

void keyPressed() {
  if (key == 'S') screenCap();

  if(key == 'c'){
    // Grab random square from archetype image then media image(s)
    PVector arctypTilePos = new PVector(int(random(arctyp.width-arctypGridW)),int(random(arctyp.height-arctypGridH))); 
    PVector medTilePos = new PVector(int(random(media.width-medGridW)),int(random(media.height-medGridH))); 
    
    histArchetypeSrc = arctyp.get(int(arctypTilePos.x), int(arctypTilePos.y), arctypGridW, arctypGridH);
    histMedSrc = media.get(int(medTilePos.x), int(medTilePos.y), medGridW, medGridH);
    compareImgs(histArchetypeSrc, histMedSrc);
  }
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
