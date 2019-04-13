/* Tile Class
   Ron Grant Apr 2019
   
   


*/

boolean mouseInTile;  // set when drawing tile   -- maybe could return value ...   

final String[] tileTypeName = {"EMPTY", "START","GAP","F","ARC","CORNER","SCURVE","NOTCH","DCURVE","CROSS","ACUTE","GATE"};
//final String[] typeTypeCurves = {"ARC","CORNER","SCURVE","NOTCH"};  // features that turn Left or Right on start,  default "Left"
//concern for above was jog -- Apr 9,2019  -- looking at Tile object transform


final int wideTileIndex = 10;  // tiles from 10 on are 2x2 wide (consideration when displaying tile dictionary 


class Tile {
  

 int     tileType;       // 0=empty, see tileTypeName array above
 int     dir;            // feature direction 0,1,2,3   90 degree rotation
 char    leftRight;      // left/right (mirror in X -- may not be needed for most all layouts)
 int     lineWidth;      // line width 0..2  0=Normal, 1=Thin 2=Wide
 boolean invert;         // white on black when true
 int     jog;            // 0=NO 1=LEFT 2=RIGHT
 char    stain;          // stain background  'X' = none  '2' = 20% stain... 



 
 private float   dScale;         // vars copied from par  (short hand save from having to qualify as par.
 private float   tileSize;
 private int     curCol,curRow;
 private float   t2;
 private boolean L;              // loaded with leftRight=='L'
 
 String  cms;
 boolean forceThinLine;
 int     curHeading;         // normally tile dir   gets override when drawing gate
  
int screenPosX;                    // special location set before drawing tile with drawAtScreenXYPosition set
int screenPosY;                    // used for drawing at mouse position or for dictionary tile draw at bottom of screen
boolean  drawAtScreenXYPosition;   
       
  
 Tile() { setDefault(); }     // constructor 
         
  void setDefault ()
  {
    tileType=0;
    dir = 0;
    leftRight = 'S';
    lineWidth = 0; // normal
    invert = false;
    jog = 0;
    stain = 'X';  
      
    drawAtScreenXYPosition = false;
  }
  
  void copy(Tile src)
  {
    tileType  = src.tileType; 
    dir       = src.dir;            // feature direction 0,1,2,3
    leftRight = src.leftRight; 
    lineWidth = src.lineWidth;
    invert    = src.invert;
    jog       = src.jog;           // 0=NO 1=LEFT 2=RIGHT
    stain     = src.stain;
  }
  
  
  void drawAtScreenPosition (int x, int y)
  {
   // println ("drawTileAt mouse position");
   drawAtScreenXYPosition = true;
   screenPosX = x;
   screenPosY = y;
   drawAtRowCol(0,0);               // draw at row col -- overrides row,col 
   drawAtScreenXYPosition = false;
      
  }
    
  void drawAtRowCol (int row, int col)
  {
    L = leftRight=='L';
    
    if (generateSVG)
      dScale = par.dScale * par.svgScale;
    else 
      dScale = screenScale;
    
    
   // cols = par.cols;
   // rows = par.rows;
    tileSize = par.tileSize;
    t2 = tileSize * 0.5;
    curCol = col;
    curRow = row;
    cms = "illegal tileType";
    forceThinLine = false; // used for start finish
    curHeading = dir;
    
    
    switch (tileType)
    { case 0 :  tpEmpty();    break;  // still do calc for mouse test
      case 1 :  tpStartFin(); break;
      case 2 :  tpGap(); break;
      case 3 :  tpForwardWhole(); break;
      
      case 4 :  tpArc();    break;
      case 5 :  tpTurn();   break;
  
      case 6 :  tpSCurve(); break;
      case 7 :  tpNotch();  break;
      case 8 :  tpDoubleCurve(); break;
      case 9 : tpCross();  break;

      case 10:  tpAcute();  break;
      case 11 : tpGate1();    break;
      case 12: tpEmpty();
    } // end switch
    
  }
  



void tpGenerateTileGrid()
{
  
 if (par.gridLineWidth == 0.0) return;   // skip grid if zero width 
  
 float gridW = par.cols * tileSize * dScale;
 float gridH = par.rows * tileSize * dScale;
 
 gc.resetMatrix();
 gc.stroke(par.gridColor);
 gc.strokeWeight(par.gridLineWidth*dScale);
 
 borderOffsetTranslation();
  
 float s = tileSize*dScale;
  
 for (int x=0; x<=par.cols; x++) gc.line (x*s,0,x*s,gridH);
 for (int y=0; y<=par.rows; y++) gc.line (0,y*s,gridW,y*s);
}



void drawStain(char t)  // 2 4 6 8
{
   gc.pushMatrix();   // save current transformation 
   gc.resetMatrix();  // building custom transform for stain geometry 
   gc.pushStyle();
  
   borderOffsetTranslation();        // provision for border letters
    
   gc.scale(dScale);
   
   gc.translate ((curCol-1)*tileSize,(par.rows-curRow)*tileSize);
  
   gc.shapeMode(CORNER);
   
   switch (t) {
     case '2' : gc.shape(stain20,0,0,12,12); break;
     case '4' : gc.shape(stain40,0,0,12,12); break;
     case '6' : gc.shape(stain60,0,0,12,12); break;
     case '8' : gc.shape(stain80,0,0,12,12); break;
     case 'E' : gc.shape(logoRing,0,0,12,12);
                gc.shape(logo,0,0,12,12);   
                break;    // use E  Ensignia vs L logo due to jog  JL JR
     
   } 
   
   gc.popStyle();
   gc.popMatrix();
   
}

/* tile coordinates letter number   e.g. E5
  
      0        North
    3   1    West  East
      2        South   
 
    
   SAMPLE COURSE  12 colums wide, 6 rows tall (A..F) 
    
   Tile Designated by Row,Col  Letter Number e.g.   F1 is North West Corner 
                                                    F12 is North East Corner 
                                                    A1  is South West Corner 
                                                    A12 is South East Corner 
   North Increments Row     Letter 
   East Increments Col      Number 
    
   Robot Starts in C12 heads north incrementing row letters  C12 E12 F 12
   then turns right (West) decremting column number, then turns again right (South) 
   
  
*/  
  


void checkForMousePointerInCurrentTile()  // relies on current transformation matrix   
{   
  // when working interactively, determine if mouse is in current tile
  // transform current tile extents to screen coordinates then check if mouse within
  // those extents
  
  PMatrix pm = gc.getMatrix();           // current tile to screen transformation matrix
  
  PVector p1 = new PVector (-t2,-t2);     // transform extents  
  PVector p2 = new PVector (t2,t2);
  PVector px1 = new PVector (0,0);
  PVector px2 = new PVector (0,0);
  
  pm.mult(p1,px1);                        // transform extents of tile to screen coords
  pm.mult(p2,px2);
  
  float x = mouseX;    // current mouse position in screen coords.
  float y = mouseY; 
  
  float y1 = px1.y;
  float y2 = px2.y;
  
  if (y1>y2) { float t = y1; y1=y2; y2=t; }  // order ascending y (in case reversed)
    
  mouseInTile = false;    
  
   // If window has focus then focused (Processing variable) is true.
   // Helps avoid confusion where without testing in case of window not focued,
   // tiles would light up (as mouse passed over them) , but keyboard commands
   // would not work until window is clicked in.
   
   // try getting focus instead 
    
  if (focused &&  (x>px1.x) && (x<px2.x) && (y>y1) && (y<y2))
  {
    
    mouseInTile = true;
    // println ("mouse in ",curRow,curCol);  // diagnostic 
    
    if (!generateSVG)
    {
      gc.fill (20,20,100,30);                 // tint current tile
      gc.stroke(0,0,100);
      gc.strokeWeight(0.25);
      gc.rect (-t2,-t2,tileSize,tileSize);
    }  
    
  }
}  




void composeXformRowCol(int row,int col)   // setup render/draw transform for current row,col
{
  curRow = row;
  curCol = col;
  composeXform('S'); 
}


void composeXform(char turnDir)   // compose transform for tp__ feature,  rotate and mirror if right turn
{
   gc.resetMatrix();
   
 
 
    borderOffsetTranslation();                // offset for border lettering if enabled 
  
   if  (drawAtScreenXYPosition)              // ONLY for tile being dragged from dictionary
   {                                         // usually drawAtMousePosition is false!
   
     gc.translate (screenPosX,screenPosY);           
     if (par.borderLettering>0) gc.translate (-t2*dScale,-t2*dScale);   
     scale(1,-1); 
   } 
              
  
  
   
   gc.scale(dScale);                   // scale from 1" = 1.0 units to output  normally 1.0
                                       // in case of screen drawing scale will be around 5 to 10
                                       // in case of undersizing just a bit for banner print with tiny
                                       // border 0.98 might be used.
 
   if (!drawAtScreenXYPosition)         // below translation & scale used for drawing tiles in array
   {
     gc.translate (0,par.rows*tileSize);    // transform our grid which has origin lower left corner
     gc.scale (1,-1);                   // to SVG coords with origin at upper left corner.
   
     gc.translate ((curCol-1)*tileSize+t2,(curRow-1)*tileSize+t2);
   }
   
   checkForMousePointerInCurrentTile();  // relies on current transformation matrix 
                                         // unrotated or mirrored  
   
   //   0        North          heading values
   // 3   1    West  East
   //   2        South   
  
  int curHeading = dir;
  gc.rotate (-(PI/2)*curHeading);  
 

 
  if (invert) // black background
  {
    //if (!tileVisited[curRow][curCol])
    {
      gc.noStroke();
      gc.fill (0);
      gc.rect (-t2,-t2,tileSize,tileSize);
      
      if (stain != 'X') drawStain(stain);
      
      //tileVisited [curRow][curCol] = true;
    }  
    
    gc.stroke (255);
   
  } else // normal white tile 
  {
    
    if (stain != 'X') drawStain(stain);
    gc.stroke(0);
  }  
  
  if (turnDir=='S')   // jog cases for straight pattern e.g. straight line 
  {
    if (jog==1)  gc.translate (-1.5,0);
    if (jog==2) gc.translate (1.5,0);
  }  
 
  
  if (turnDir == 'R') gc.scale (-1,1);  // mirror in X  
  
  
 
  gc.noFill();  // prevents arcs from being filled (like pie slices... )
                // strokwWeight provides thickness for lines and arc 
      
  gc.strokeWeight(par.widthNormal);
  if (lineWidth==1) gc.strokeWeight(par.widthThin);  
  if (lineWidth==2) gc.strokeWeight(par.widthWide); 
  
  if (forceThinLine)
    gc.strokeWeight(par.widthThin);  // start/finish line   
}  



// Tile Pattern Commands 

void tpEmpty()
{
  composeXform('S');  // do compose on empty -- detects mouse pointer in tile for edit
  
}
  
void tpStartFin()
{
  cms = "Straight Line with start/finish line " ;    // assmption is robot is in middle of tile
  composeXform('S');    // no turn
  gc.line (0,-t2,0,t2);
  gc.strokeWeight(par.widthThin);
  gc.line (-3,0,3,0);
}



// PVector tileFeatureXform (float x, float y, int heading, boolean mirrorX, float tileSize)

void tpForwardWhole()  {        // generate tile points
  cms = "Forward Whole Tile";
  composeXform('S');
  gc.line (0,-t2,0,t2);
}

void tpCross() {
  cms = "Forward Whole Tile";
  composeXform('S');
  gc.line (0,-t2,0,t2);
  gc.line (-t2,0,t2,0);  
}


void tpGap()           { 
  cms = "Forward with Gap"; 
  composeXform('S');
  gc.line (0,-t2,0,-t2+3);
  gc.line (0,t2-3,0,t2);
}

void tpArc()   {

  if (L) cms = "Arc Left"; else cms = "Arc Right";
  
  composeXform(leftRight);      // turn dir   mirror if 'R'
  
  float dd = 0;                 // delta diameter
  
  boolean jogL  = jog==1;
  boolean jogR  = jog==2;
   
  if ((jogL && !L) || (jogR && L))  dd = 3;
  if ((jogL && L) || (jogR && !L))  dd = -3;
  
    
  gc.arc (-t2,-t2,tileSize+dd,tileSize+dd,0,PI/2);

}




void tpAcute()
{
  if (L) cms = "Acute Left"; else cms = "Acute Right";
  invert = false;  // invert not supported for 2x2 acute angle tiles (would require recognizing all tiles part of acute angle... )   
  
  composeXform(leftRight);
  
  gc.beginShape();
  gc.vertex (0,-t2);
  gc.vertex (0,0);
  gc.vertex (-t2,tileSize);
  gc.vertex (-tileSize,0);
  gc.vertex (-tileSize,-t2);
  gc.endShape();
}

void tpTurn()  {
 
  composeXform(leftRight);  // mirror if 'R'
  
  gc.beginShape();
  gc.vertex (0,-t2);
  gc.vertex (0,0);
  gc.vertex (-t2,0);
  gc.endShape();
  if (L) cms = "Turn 90 Left"; else cms = "Turn 90 Right";
} 


void tpSCurve()
{ 
  if (L) cms = "Sine start Left"; else cms = "Sine start Right";
  composeXform(leftRight);  // mirror if 'R' 

  float y = -t2;
  float x = 0;
  
  gc.line (0,y,0,y+0.75);
  x-= 1.5;
  y+= 0.75;
  
  for (int i=0; i<7; i++)
  {
    gc.line (x,y,x,y+1.5);  y+= 1.5;
    
    if ((i>0) && (i<5)) x+= 1.5;
    else                x-= 1.5;
    
  }
 
  gc.line (0,y,0,y+0.75);  
} 


void tpNotch()
{ 
  if (L) cms = "Notch Left"; else cms = "Notch Right";
  composeXform(leftRight);  // mirror if 'R'
  
  gc.beginShape();             // use shape vs lines for mitered corners
  gc.vertex (0,-t2);
  gc.vertex (0,-t2+0.75);
  gc.vertex (-t2+2,0);
  gc.vertex (0,t2-0.75);
  gc.vertex (0,t2);
  gc.endShape();
} 

void tpDoubleCurve()
{
  cms = "Double Curve";
  composeXform('S');            // turn dir   mirror if 'R'
  gc.arc (-t2,-t2,tileSize,tileSize,0,PI/2);
  gc.arc ( t2, t2,tileSize,tileSize,PI,3*PI/2);
}


void tpGate1()
{
    cms = "Custom Gate G1 ";
    invert = false;           // Invert not allowed on gate 
    composeXform('S');  
  
    float t=tileSize; // shorthand
  
    // gate in coordinate system with respect to entry facing east
    // where east = +y axis and course north = - x axis
    
     gc.line (0,-t2,0,0);             // first 6 inch segment (center of this tile is 0,0)
                                   // hence line enters the tile at 0,-t2 and ends at 0,0
                                   
     gc.arc (-t2,0,t,t,0,PI/2);       // turn left 90  (ending on tile border)
     gc.line (-t2,t2,-t2-t,t2);       // travel 1 tile length
     gc.arc (-t2-t,0,t,t,PI/2,PI);    // turn left  center x,y  diameter x,y, start end,angle 
     gc.beginShape();                 // turn left (and travel back to path -- this completes the loop of the path
       gc.vertex (-2*t,0);
       gc.vertex (-t,0);
       gc.vertex (-t2-2,t2);
     gc.endShape();
     gc.beginShape ();                // right gate 
       gc.vertex(-t,t2);
       gc.vertex(-t-t2+1.5,t);
       gc.vertex(-t-t2,t);
     gc.endShape();
     
     gc.line (-2*t,-0.3,-2*t,+0.375);  // fill gate loop where arc meets long line 
                                        // which is not mitered
}

        
 
} // end Tile class