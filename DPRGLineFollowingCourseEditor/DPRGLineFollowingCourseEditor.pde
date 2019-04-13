/* DPRG Line Following Course Editor 
   Ron Grant 
   April 6, 2019
   
   Original course concept and tiles designed by Doug Paradis.
   Work in producing alternate courses and Map Coordinate format by Carl Ott.
    
     
      
   This application sketch (program) written using Processing 3.5.3 (see: processing.org)
   
   Every Processing sketch is actually a subclass of the PApplet Java class
   (formerly a subclass of Java's built-in Applet) which implements most of the Processing
   language features.
   
      
   setup() is called first one time, then draw() is called at frame rate,
   i.e. 60 times per second if possible.
   
   Processing provides some very handy methods including most notably, graphics primatives and
   supporting 2D (and 3D) cooridnate transformations.
  
   This application draws to screen and also to SVG file so all graphics functions are qualified 
   with a graphics context (PGraphics object) named  gc. (terse name since used frequently). For
   example,  gc.line(x1,y1,x2,y2) vs line(x1,y1,x2,y2)
   
   Note that processing graphics context is g. where  g.line  and line are the same 
   
   
   
   After optionally loading a template file which includes a number of parameters including 
   tile array size, line widths, tile border colors, etc. The user is able to drag tiles from
   the tile dictionary to the tile array.
   
   Position mouse on dictionary tile press and hold mouse button move tile to target position on
   course
   
   Then keyboard commands can be used to modify the tile
      R Rotate rotate
      M Mirror tile (applies to SCurve , arcs)
      W cycle line width from normal to thin to thick.
      J cycle line jog left, right, none on straight lines and single arcs
      I togle invert
      
   The tile array can be then saved to .LCT file and optionally to SVG file
   Later the .LCT file can be reloaded and saved
 
 
  Future feature, multi-select tiles and move.
 
 
  SVG Export at 1:1  1 unit = 1 inch problem is 
  getting SVG scaled on PNG Export
  changing dpi manually   19200    48x48 unit (4' x 4') 2400 x 4 = 9600..
  
  
   
  To Do List
  
  + On screen command key summary
  + Title author credit  (About needs to credit Doug Paradis and Carl Ott
  + 2x2 acute pattern dictionary fit  
  + gate dictionary fit
  + inverted start finish not showing main line 
  + Jog Inverted Tile BG Shifted 
  + Position logo  using L key 
  
  + Save LFT  save to current default 
  + Logic for loading template file   TPF ?
  + Cross Missing
  + Possible to hover over window without it having focus where key commands , click in window
  + SVG out lettering off OK -- tile highlight should be disabled 
  + Lettering Turned Off Problems   verify
      TileDict shift border letter on off
  + Save to SVG with name of LFT  using save dialog 
  + Logo Ring not displayed properly -- still not perfect separated ring from rest of logo...
  
  + Help Crude help screen, invokes notepad. File is HelpText.pde from project.
    Formatted as a java comment 
   
  + test 0.98 scale & document
      problem involving svgScale in border offset calculations
        tried svgScale unity, worked-- added svgScale to offsets when output to svg 
  
  + test build challenge course and note time required
       Jog arc problem -- all other features OK   required 10 minutes to create course
      
  + Click and drag tiles in array. Hold down shift before clicking and holding on tile
    to make a copy of it
  
  - Clear All should have verify dialog
  
  + OK -- dictionary not loaded with current startup 
  
  + Problem loading LFT without loading Template Problem  nothing displayed
  + Attempt to save with no extension add .LFT  (not added -- not perfect detector)
  
  + few more words on Help on generating a banner print 
   
*/   

//import processing.svg.*;  // library that supports drawing to SVG using   line arc shape methods..  

boolean allowSVGOut = false;

String PROGRAM_TITLE = "DPRG Line Following Course Editor 0.95";
boolean showTitle = true;

PGraphics gc = null;    

SimpleButton bLoadTemplate,bLoad,bSave,bHelp,bGen,bClr;   // on-screen GUI buttons 

RectBox buttonPanel;
SimpleTextBox tbKeys;
SimpleTextBox tbTitle;
SimplePopUpDialog popUpDialog;


float screenScale = 5.0;      // if drawing to screen (not generateSVG)

void setup() {
  //size (1920,1080);
  
  size(1000,700);
  surface.setResizable(true);  // resizable main window
  surface.setTitle(PROGRAM_TITLE+"     Ron Grant 2019");
   
  buttonPanel = new RectBox (width-270,10,225,550,8);      // xywhr - simple box 
  float bL = width-220;
  
  bLoadTemplate = new SimpleButton ("Load Template",bL,20,140,30);      // text,xywh
  bLoad = new SimpleButton ("Load LFT",bL,100-20,140,30);      // text,xywh
  bSave = new SimpleButton ("Save LFT",bL,150-20,140,30);
  bGen  = new SimpleButton ("Generate SVG",bL,200-20,140,30);
  bHelp = new SimpleButton ("Help",bL,250-20,140,30);
  bClr  = new SimpleButton ("Clear ALL",bL,520,140,30);

 // tbKeys = new SimpleTextBox (14,buttonPanel,16,200, buttonPanel.w-50,200  ); // textSize, parent RectBox, offset xy  width,height
  
  tbKeys = new SimpleTextBox (14,buttonPanel,14,300-28,buttonPanel.w-20,220  ); // textSize, parent RectBox,
  
  tbTitle = new SimpleTextBox (24,null,5,5,width-300,40);
  tbTitle.addText(PROGRAM_TITLE); 
  
  tbKeys.addText ("Selected Tile Key Cmds");
  tbKeys.addText ("\\"); // half line space
  tbKeys.addText (" C - Clear");
  tbKeys.addText (" I - Invert");
  tbKeys.addText (" J - Jog LeftRightNone");
  tbKeys.addText (" M - Mirror LeftRight");
  tbKeys.addText (" R - Rotate");
  tbKeys.addText (" W - Width ThinThickNorm");
  tbKeys.addText (" 2 - 20% Stain (also 4,6,8)");
  tbKeys.addText (" L - Logo");
  tbKeys.addText ("\\"); // half line space
  tbKeys.addText ("    Vert Arrows Screen Scale");
  tbKeys.addText ("B - Border Coords on/off");
  
  popUpDialog = new SimplePopUpDialog(100,100,500,300);

}  

String  inputFilename;
boolean generateSVG = false;



void inputParameterFileSelectedCallback(File f)
{
 if (f== null) println("Window was closed or the user hit cancel.");
 else {
    inputFilename = f.getAbsolutePath();
    println ("inputFile = ",inputFilename);
      
    par.readParameters(inputFilename);
    createTileArray();         // create new empty array
    tiles.initTileList();      // clear rows x cols (as specified in parameters 
    
    //inputFilename = inputFilename.replace(".LT",".LFT");  // parameter file name becomes default filename?
    inputFilename = ""; // force save to create name?
       
  }
  
}



void inputFileSelectedCallback(File f)
{
 if (f== null) println("Window was closed or the user hit cancel.");
 else {
    inputFilename = f.getAbsolutePath();
    println ("inputFile = ",inputFilename);
       
    par.readParameters(inputFilename);
    createTileArray();
    tiles.loadLFTfile(inputFilename);
    
  }
  
}

String outputFilename;

void outputLFTFileSelectedCallback(File f)
{
  if (f== null) println("Window was closed or the user hit cancel.");
  else {
    outputFilename = f.getAbsolutePath();
    
    if (!outputFilename.contains(".lft")) outputFilename = outputFilename.replace(".lft",".LFT");
    
    // if no extension add .LFT
       
    
    if (!outputFilename.contains(".LFT"))
    {
     outputFilename += ".LFT"; // popUpDialog.popUp("Ouptut File Not Saved. Must have .LFT extension (all uppercase)"); 
    }
    
    println ("Saving LFT File  ",outputFilename);
    if (tiles != null) tiles.saveFileLFT(outputFilename);
    
  }
  
  
}


void drawAndTestButtons()
{
  // button draw and check for click
  // do with default transform matrix e.g. before  rotate,scale,translate...
 
  gc.resetMatrix();
  
  gc.fill(20);
  buttonPanel.draw();
    
  // window can be resized, SimpleButton position must be manually set
  buttonPanel.x = width - 230;
  
  RectBox b = buttonPanel;     // shorthand for below
  bLoadTemplate.centerInRectBoxOnX(b);
  bLoad.centerInRectBoxOnX(b);
  bSave.centerInRectBoxOnX(b);
  bGen.centerInRectBoxOnX(b);
  bHelp.centerInRectBoxOnX(b);
  bClr.centerInRectBoxOnX(b);
  
 tbKeys.draw();
  
  if (bLoadTemplate.drawPressedCheck())
  {
    println ("Load Template LT");
    selectInput("Select a Line Following Course Tile File (LFT File) ",
                "inputParameterFileSelectedCallback", // callback when dialog completes
                dataFile("/data/*.LT"));     // initial folder /data   
    
    
  }
  if (bLoad.drawPressedCheck())  // could create list, but explicit draw for now
  {
    println ("Load");
    selectInput("Select a Line Following Course Tile File (LFT File) ",
                "inputFileSelectedCallback", // callback when dialog completes
                dataFile("/data/*.LFT"));  // initial folder /data 
    
  }
  
  if (bSave.drawPressedCheck())
  {
    println ("Save LFT File ");
    
     
    String fn =  "/data/*.LFT";
    if ((inputFilename != null) && (inputFilename.length() >0)) fn = inputFilename;
        
    selectOutput("Save a Line Following Course File (LFT File)",
                "outputLFTFileSelectedCallback", // callback when dialog completes
                //dataFile("/data/*.LFT")
                dataFile(fn)
                );  // initial folder /data 
  }
   
  if (bGen.drawPressedCheck())
  {
    println ("GEN SVG");
    generateSVG = true;
  }
 
  if (bHelp.drawPressedCheck()) {
     launch ("notepad.exe "+sketchPath("HelpText.pde")+"  "); 
  }
 
  if (bClr.drawPressedCheck())
    if (tiles!=null) tiles.initTileList();
 
}


void draw()
{
  if (gc==null) gc = g;  // display graphics context
  
  if (generateSVG)  // draw this frame using SVG context 
  {
     float sc = par.tileSize * par.svgScale;
    
      
     int r = par.rows;
     int c = par.cols;
     if (par.borderLettering >0) {r++; c++; }
  
     println (String.format("SVG total rows %d cols %d",r,c)); 
    
     String fn = "unnamed.svg";
     if ((outputFilename != null) && outputFilename.contains(".LFT"))
       fn = outputFilename.replace(".LFT",".svg");
     else  if ((inputFilename != null) && inputFilename.contains(".LFT")) 
       fn = inputFilename.replace(".LFT",".svg");
       
    
     gc = createGraphics (int(c*sc),int(r*sc),   // temporary (1 frame) SVG output for graphics drawing
     SVG,dataPath(fn));  
    
     println (String.format("Writing File : %s  (%d x %d) ",dataPath(fn),int(c*sc),int(r*sc)));
     
  }
  
  
  gc.beginDraw();
  gc.resetMatrix();
  
 
  gc.strokeCap(SQUARE); // or ROUND  or PROJECT( like added 1/2 width distance with round, but square)
  gc.ellipseMode(CENTER);
  gc.background(255);
 
  if (!generateSVG) 
  { gc.fill(20);
    buttonPanel.draw();
    // gc.rect (width-200,0,200,400);
  }  
  gc.noFill();
   
 
  if (par.borderLettering>0) drawBorderLetters();
  drawTileGrid(); // Border tab  // was before letters   Apr 8  10PM
  
  if (tiles != null)
  { tiles.drawTileList();
    if (!generateSVG)
    {
      drawTileDictionary();
      drawTileInHand();         // if holding a dictionary tile, draw at current mouse location
    }  
  }  
  
  boolean skipButtons = false;
  
  if (generateSVG)  // terminate SVG generation - save file, next frame will be drawn to screen
  {
    gc.endDraw();
    gc.dispose();
    // gc = null;     
    generateSVG = false;     // if was set true
    gc = g;
    skipButtons = true;
  } 
  
  if (!skipButtons)
  {
    gc.resetMatrix();
    if (showTitle) tbTitle.draw();
    drawAndTestButtons();  // buttons not drawn just after rendering SVG file
    
    popUpDialog.drawTestOK();  // if modal dialog has been invoked, check for click of OK and stop drawing
    
    gc.endDraw();
  }  
  
  
}