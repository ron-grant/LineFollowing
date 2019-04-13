/* Processing.org Sketch to translate DPRG Advanced/Challenge Line Following contest course path
   format (Line Following Course Format .LFC file) to SVG (Scalable Vector Format)
   
   AN INTERACTIVE TILE BASED EDITOR HAS REPLACED THIS PROGRAM
   
   
   
   A vector based program such as Inkscape can then read SVG and produce PNG at desired DPI
   resolution e.g. 200 dpi for Banner Production 
     
   Ron Grant
   Apr 1,2019
  
   Parameters define tile array size, starting tile and heading.
   Each LFC instruction generates one tile.
   The LFC interpreter tracks current tile row,col and heading so instructions specify relative moves
   which can be a bit tricky if a mistake is made. Recommendation is to write a few instructions at a time
   and/or place temporary END to help debug.  Interactive drawing and single step tile instruction processing
   would help cure this.
   
   Stain files and logo are imported from /data subfolder as SVG file using instruction modifier 2 4 6 or 8.
   
   Gate is hard coded for now. Might be better option to allow it to be imported as SVG.
   
   Sample LFC program in PathData tab contains description of LFC format  
   
   
   To Do
   
   + Map Coordinate Border Option (Like Carl's Course)
   + Variable Scale e.g. 0.98 micro border with 2% tile shrink, save adding row&col
   + Read Path Program Header before Processing size call allowing variable rows and cols in course
   - LFC extension may be case sensitive, use uppercase.
   - Lettering not working on 3x3 sample 
   
   April 5
   - Working on making interactive 
       Development stopped on this program
       interactive version now uses only tile based description format!
       
       
   + Display graphics on screen mode vs output to SVG file
   
     
     
     Note Stain Orientation is fixed - stains copied from /data folder SVG 
   
   + Resize Course +1 row/col if using Carl's Border Lettering 
   + Read External Path Data Program vs Sketch Tab File PathData 
   
   - Allow Import SVG at tile location to allow Inkscape to generate gate geometry vs hardcoding into this program
     as was done for current 2019 challenge course
   - Logo location hard coded see above, use that to allow custom positioning 
   
   + Acute Angle now working for other than orientation in 2019 course, enter heading south
   
   
   
   
*/

import processing.svg.*;

// parameters that can be overidden by # parameter modifiers in LFC File 

int maxRows = 6;       
int maxCols = 12;
float tileSize = 12;   // Tile Size in inches    
int rows = 6;
int cols = 12;
float dScale = 1.0;
color gridColor = color (255,200,200); // default light red
float gridLineWidth = 0.125;           // default width inches
boolean borderLettering = false;       // added 6" border with map style grid coords

boolean interactiveEdit = false;  // !!! Temp leave false -- development stopped on this version of program 

boolean svgOutput = false;        // normally true -- working with toggle to screen


boolean showPathParam = true;     // when reading # params 


PGraphics svg;
PShape logo,stain20,stain40,stain60,stain80;
PShape logoRing;  // problem with blue background ring rendering solid, covering robot
                  // kludge - ring as separate svg loaded first,  robot feet outside ring and few other minor
                  // problems with logo.


boolean inputSelected = false;
String inputFilename = "";
boolean svgDone = false;
String outputFilename = "";
float screenScale = 6;

void setup() {

  size (1000,800); 
 
  // special svg  shapes imported then exported  
  println ("loading SVG files (stains & logo)");
  
  stain20 = loadShape("/svgLogoStains/Stain20.svg");   //   /data  folder 
  stain40 = loadShape("/svgLogoStains/Stain40.svg");   //   /data  folder 
  stain60 = loadShape("/svgLogoStains/Stain60.svg");   //   /data  folder 
  stain80 = loadShape("/svgLogoStains/Stain80.svg");   //   /data  folder
  logo    = loadShape("/svgLogoStains/DPRGLogo.svg");
  logoRing= loadShape("/svgLogoStains/DPRGLogoRing.svg");   // logo drawn with final course geometry (gate)
  
  println ("finished loading SVG Stains / Logo ");
  println ();
  resetProgram();
}


void resetProgram()  
{
  inputSelected = false;
  inputFilename = "";
  outputFilename = "";
  svgDone = false;
  initTileList(); // new interactive experiment
}  


void drawBorderLetters()
{
   svg.resetMatrix();
   svg.scale(dScale);
   svg.textSize(2);
  
   svg.textAlign(LEFT);
   svg.stroke(0);
   svg.fill(0);
   
   
   if (showDecode)
   println ("draw border letters ");
   
   float t = tileSize;
   
   float nr =rows;
   float nc =cols;
   
   
   for (int c=1; c<=cols; c++)
   {
      svg.text(String.format("%d",c),t*c-2,3-t+t);                    // top line
      svg.text(String.format("%d",c),t*c-2,3+t*(nr-1)+t/2+t);         // bottom line 
   }
  
   for (int r=1; r<=rows; r++)
   {
      svg.text(String.format("%c",r+'A'-1),2             , t*(nr-r)+t);   // left col of text
      svg.text(String.format("%c",r+'A'-1),2+t*(nc+1)-t/2, t*(nr-r)+t);   // right col of text
   }
   
  
  
}


void fileSelected(File selection) {  // callback for selectInput used in keyPressed()
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    
  } else {
    
    inputFilename = selection.getAbsolutePath();
    println ("inputFile = ",inputFilename);
    
    inputSelected = true;
  }
}


void selectInput()
{ 
   if (svgDone) resetProgram();  // re-init for next file to translate
   
    selectInput("Select a Line Following Course Program (LFC File) to render to SVG file:",
                "fileSelected", // callback when dialog completes
                dataFile("/data/"));  // initial folder /data 
}                


void mousePressed()
{
  selectInput(); 
}




// note most drawing functions use svg PGraphics object context and not normal
// default context

void draw() {
 
  background(0);
  textSize (20);
  
 
  if (!svgDone)    
  {
    
    if (!inputSelected) 
    {
      text ("Select Line Following Course format file to read/interpret",10,20); 
      text ("generating .svg (scalable vector format) output file.",10,45);
      text ("Click on this window to invoke input file browser dialog. ",10,105);
      return;
      
    }  
      
    pathProgramReadParameters();  // read all #param value pairs from input LFC file
  
    maxCols = cols;
    maxRows = rows;
 
    if (borderLettering){  // expand 1 row and col  (geometry translation 1/2 tile also added) 
      maxCols++;
      maxRows++;
    }  
   
    String[] fn = inputFilename.split(".LFC");
    outputFilename = fn[0] + ".svg";
    if (showDecode) println ("outputFilename " + outputFilename);
    
    if (svgOutput)    
      svg = createGraphics (int(maxCols*tileSize),int(maxRows*tileSize), SVG, outputFilename);   // size in setting() allows variables to spec size
    else
      if (svg==null) svg = g; // display graphics context
 
    svg.beginDraw();
    svg.background(255);
    svg.noFill();
    svg.strokeCap(SQUARE); // or ROUND  or PROJECT( like added 1/2 width distance with round, but square)
    svg.ellipseMode(CENTER);
    
  
    pathRead();  // having read parameters in settings(), continue reading line following course
                 // instructions - and build SVG output
                 
    if (borderLettering) drawBorderLetters();
    
    if (showDecode)
    {
      println("Finished Generating SVG using path data");
      println("");
    }  
    
    if (!svgOutput)    // experiment add interactive random tile features vs LFC 
      drawTileList();
    
    
    svg.endDraw();
    
    if (svgOutput)
    {
      svg.dispose();
      svg = null; 
      svgDone = true;
    }  
    
  } // if !svgDone
  else 
  {
    textSize(16);
    text ("SVG file generation complete ",10,200);
    text ("output file : "+outputFilename,10,230);
    text ("in application's data sub-folder",10,260);
   }
}
