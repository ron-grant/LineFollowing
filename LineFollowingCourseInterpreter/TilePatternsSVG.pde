/*
   Tile Patterns - as tile opcodes are decoded by Path Reader, the tile pattern (tp___) functions here
   are used to generate  SVG geometry for output to SVG file.
   
   Similar to path generation, except simple geometry output vs stream of cookie crumbs in original
   PathReader
      
   All geometry is generated in local tile coordinate system assuming entering tile at south and traveling north.
   Other cases handled with rotation of tile 
  
   Possibly only incremental path generation case:
   Right turn case for turning geometry is handled with mirror in X transform, so only left turn case needed.
            
   In path generation case (vs Tile Mode of interactive editor)    
   nextTile() included in this module, is used to keep track of current row and column based on turn direction and current
   path direction. Each tp___ function informs nextTile of heading modification affected by the tile, i.e. straight left,right
   
   tp functions included  
  
   tpStartFin()              straigh line across tile, with start/finish line across middle 
   tpForwardWhole()          straight line whole tile
   tpGap()                   line with gap
   tpArc(dir)                turn arc   dir turn direction  'L' Left  Right 'R'    
   tpAcute(dir)              acute angle special case 2x2 tile region
   tpTurn (dir)              turn 90 hard
   tpSCurve(dir)             broken sine wave like pattern
   tpNotch(dir)              straight, approx  45 turn, straight, bend 90, straight, 45 turn, straight
                             pattern.
 
   tpGate1()                 custom gate code, might also consider building in inkscape with import similar to stains..
   tpDoubleCurve()
   
   tpGenerateTileGrid()      grid of long lines extending across tile array defining tile boundaries
                             generated just after BEGIN
  
*/

// tile attributes

float widthThin   = 0.325;  // line Widths inches   verify.     
float widthNormal = 0.75;
float widthWide   = 1.5;

boolean thinLine;
boolean wideLine;
boolean invertTile;
boolean jogLeftTile;
boolean jogRightTile;
char    stainTile;

boolean tileVisited[][] = new boolean[100][100];

boolean mouseInTile;     // set true when drawing tile which mouse pointer is currently within boundaries 
float t2;                // short hand for 1/2 tileSize e.g. 6"

void initTilePatterns()  // clear tileVisited flags (used to limit background fill to one time)
{
  for (int x=0; x<100; x++)
  for (int y=0; y<100; y++) tileVisited[x][y]=false;
  t2 = tileSize/2;
}


float curLineWidth()
{
  if (thinLine) return (widthThin);
  if (wideLine) return (widthWide);
  return (widthNormal);
}


String cms = "";  // command string   description used for diagnostic/annotation 


void borderOffsetTranslation()
{
  float borderOffsetX  = cols*tileSize*(1.0-dScale)*0.5;   // center undersized drawing, do nothing for 
  float borderOffsetY  = rows*tileSize*(1.0-dScale)*0.5;   // dScale = 1.0
  
  if (borderLettering) {
    borderOffsetX = dScale * tileSize/2;
    borderOffsetY = borderOffsetX;
  }
  
  
  svg.translate (borderOffsetX,borderOffsetY);
}


void tpGenerateTileGrid()
{
  
 if (gridLineWidth == 0.0) return;   // skip grid if zero width 
  
 float gridW = cols * tileSize * dScale;
 float gridH = rows * tileSize * dScale;
 
 svg.resetMatrix();
 svg.stroke(gridColor);
 svg.strokeWeight(gridLineWidth*dScale);
 
 borderOffsetTranslation();
  
 float s = tileSize*dScale;
  
 for (int x=0; x<=cols; x++) svg.line (x*s,0,x*s,gridH);
 for (int y=0; y<=rows; y++) svg.line (0,y*s,gridW,y*s);
}



void drawStain(char t)  // 2 4 6 8
{
   svg.pushMatrix();   // save current transformation 
   svg.resetMatrix();  // building custom transform for stain geometry 
   svg.pushStyle();
  
   borderOffsetTranslation();        // provision for border letters
    
   svg.scale(dScale);
   
   svg.translate ((curCol-1)*tileSize,(rows-curRow)*tileSize);
  
   svg.shapeMode(CORNER);
   switch (t) {
     case '2' : svg.shape(stain20,0,0,12,12); break;
     case '4' : svg.shape(stain40,0,0,12,12); break;
     case '6' : svg.shape(stain60,0,0,12,12); break;
     case '8' : svg.shape(stain80,0,0,12,12); break;
     
   } 
   
   svg.popStyle();
   svg.popMatrix();
   
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
  

void nextTile(char dir)  // S-straight L-left R-right
{
  int oldH = curHeading; 
  
  if (dir == 'L')   curHeading= (curHeading-1) & 3;
  if (dir == 'R')   curHeading= (curHeading+1) & 3;
 
 // diagnostic print 
 //println();
 //println (String.format("nextTile  %c  heading %s  new Heading %s ",dir,headingName[oldH],headingName[curHeading]));
  
  switch(curHeading) {
  case 0 : curRow++; break;
  case 1 : curCol++; break;
  case 2 : curRow--; break;
  case 3 : curCol--; break; 
  }
  
  if (svgOutput)
  {
    if ((curRow>rows) || (curCol>cols) || (curRow<1) || (curCol<1))
    { println ("OUT OF BOUNDS ERROR! - set to A1");
      curRow = 1;
      curCol = 1;
    }
  }  
  
  
}


void checkForMousePointerInCurrentTile()  // relies on current transformation matrix   
{   
  // when working interactively, determine if mouse is in current tile
  // transform current tile extents to screen coordinates then check if mouse within
  // those extents
  
  PMatrix pm = svg.getMatrix();           // current tile to screen transformation matrix
  
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
  
  if ( (x>px1.x) && (x<px2.x) && (y>y1) && (y<y2))
  {
    mouseInTile = true;
    // println ("mouse in ",curRow,curCol);  // diagnostic 
    
    svg.fill (20,20,100,30);                 // tint current tile 
    svg.rect (-t2,-t2,tileSize,tileSize); 
    
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
   svg.resetMatrix();
   
   borderOffsetTranslation();          // offset for border lettering if enabled 
   
   svg.scale(dScale);                  // scale from 1" = 1.0 units to output  normally 1.0
                                       // in case of screen drawing scale will be around 5 to 10
                                       // in case of undersizing just a bit for banner print with tiny
                                       // border 0.98 might be used.
   
   svg.translate (0,rows*tileSize);    // transform our grid which has origin lower left corner
   svg.scale (1,-1);                   // to SVG coords with origin at upper left corner.
   
   
   svg.translate ((curCol-1)*tileSize+t2,(curRow-1)*tileSize+t2);
 
   checkForMousePointerInCurrentTile();  // relies on current transformation matrix 
                                         // unrotated or mirrored  
   
   //   0        North          heading values
   // 3   1    West  East
   //   2        South   
  
  svg.rotate (-(PI/2)*curHeading);  
 
  if (turnDir=='S')   // jog cases for straight pattern e.g. straight line 
  {
    if (jogLeftTile)  svg.translate (-1.5,0);
    if (jogRightTile) svg.translate (1.5,0);
  }  
 
  
  if (turnDir == 'R') svg.scale (-1,1);  // mirror in X  
 
  if (invertTile) // black background
  {
    if (!tileVisited[curRow][curCol])
    {
      svg.noStroke();
      svg.fill (0);
      svg.rect (-t2,-t2,tileSize,tileSize);
      
      if (stainTile != 'X') drawStain(stainTile);
      
      tileVisited [curRow][curCol] = true;
    }  
    
    svg.stroke (255);
   
  } else // normal white tile 
  {  if (stainTile != 'X') drawStain(stainTile);
    svg.stroke(0);
  }  
 
  svg.noFill();  // prevents arcs from being filled (like pie slices... )
                // strokwWeight provides thickness for lines and arc 
      
  svg.strokeWeight(widthNormal);
  if (thinLine) svg.strokeWeight(widthThin);  
  if (wideLine) svg.strokeWeight(widthWide); 
  
}  



// Tile Pattern Commands 

void tpEmpty()
{
  composeXform('S');  // do compose on empty -- detects mouse pointer in tile for edit
  
}
  
void tpStartFin()
{
  cms = "Enter Tile 1/2 Size and generate finish line" ;    // assmption is robot is in middle of tile
  composeXform('S');    // no turn
  svg.line (0,-t2,0,t2);
  
  thinLine = true;      // start/finish line 
  composeXform('S');    // recompose to set line width
  svg.line (-3,0,3,0);
  
  nextTile('S'); 
  
}



// PVector tileFeatureXform (float x, float y, int heading, boolean mirrorX, float tileSize)

void tpForwardWhole()  {        // generate tile points
  cms = "Forward Whole Tile";
  composeXform('S');
  svg.line (0,-t2,0,t2);
  nextTile('S');
}

void tpGap()           { 
  cms = "Forward with Gap"; 
  composeXform('S');
  svg.line (0,-t2,0,-t2+3);
  svg.line (0,t2-3,0,t2);
  nextTile('S');
}

void tpArc(char dir)   {
   
  boolean L = (dir=='L');
  if (L) cms = "Arc Left"; else cms = "Arc Right";
  
  composeXform(dir);  // turn dir   mirror if 'R'
  
  float dd = 0;                 // delta diameter
  
  if ((jogLeftTile && !L) ||  (jogRightTile && L))  dd = 3;
  if ((jogLeftTile && L) || (jogRightTile && !L))  dd = -3;
  
    
  svg.arc (-t2,-t2,tileSize+dd,tileSize+dd,0,PI/2);

  nextTile(dir); 
}




void tpAcute(char dir)
{
  boolean L = (dir=='L');
  if (L) cms = "Acute Left"; else cms = "Acute Right";
 
  composeXform(dir);
  
  svg.beginShape();
  svg.vertex (0,-t2);
  svg.vertex (0,0);
  svg.vertex (-t2,tileSize);
  svg.vertex (-tileSize,0);
  svg.vertex (-tileSize,-t2);
  svg.endShape();
    
  // Acute Line  (row,col,heading after feature added)  
  // special 2x2 tile 
  // cases for each initial direction and Left/Right turn on acute angle
  // a bit tricky.  remember Row A  "bottom" of array counting up B,C,D as progress to North (or up
  // when looking down at course as drawn in InkScape
 
  if (L)
  switch(curHeading) {  // north 0  east 1 south 2 west 3
  case 0 : curCol--; curRow--;  curHeading = 2;  break;  
  case 1 : curCol--; curRow++;  curHeading = 3;  break;
  case 2 : curCol++; curRow++;  curHeading = 0;  break;  
  case 3 : curCol++; curRow--;  curHeading = 1;  break; 
  }
  else // right turn
  switch(curHeading) {  // north 0  east 1 south 2 west 3
  case 0 : curCol++; curRow--;  curHeading = 2;  break;  
  case 1 : curCol--; curRow--;  curHeading = 3;  break;
  case 2 : curCol--; curRow++;  curHeading = 0;  break;    
  case 3 : curCol++; curRow++;  curHeading = 1;  break; 
  }
  
}

void tpTurn(char dir)  {
  
  boolean L = (dir=='L');
  composeXform(dir);  // mirror if 'R'
  
  svg.beginShape();
  svg.vertex (0,-t2);
  svg.vertex (0,0);
  svg.vertex (-t2,0);
  svg.endShape();
  
  //else   line (0,0, t2,0);  // taken care of by mirror
   
  if (L) cms = "Turn 90 Left"; else cms = "Turn 90 Right";
  nextTile(dir);
}


void tpSCurve(char dir)
{ boolean L = (dir=='L');
  if (L) cms = "Sine start Left"; else cms = "Sine start Right";
  composeXform(dir);  // mirror if 'R' 

  float y = -t2;
  float x = 0;
  
  svg.line (0,y,0,y+0.75);
  x-= 1.5;
  y+= 0.75;
  
  for (int i=0; i<7; i++)
  {
    svg.line (x,y,x,y+1.5);  y+= 1.5;
    
    if ((i>0) && (i<5)) x+= 1.5;
    else                x-= 1.5;
    
  }
 
  svg.line (0,y,0,y+0.75);  
     
  nextTile('S');
} 


void tpNotch(char dir)
{ boolean L = (dir=='L');
  if (L) cms = "Notch Left"; else cms = "Notch Right";
  composeXform(dir);  // mirror if 'R'
  
  svg.beginShape();             // use shape vs lines for mitered corners
  svg.vertex (0,-t2);
  svg.vertex (0,-t2+0.75);
  svg.vertex (-t2+2,0);
  svg.vertex (0,t2-0.75);
  svg.vertex (0,t2);
  svg.endShape();
  
  nextTile('S');
} 

void tp45TurnHalfTile(char dir)
{
  boolean L= (dir=='L');
  
  if (L) cms = "Turn 45 Left Half Tile"; else cms = "Turn 45 Right Half Tile";
  
  // next tile not computed 
  
} 


void tpDoubleCurve()
{
  cms = "Double Curve";
  composeXform('S');            // turn dir   mirror if 'R'
  svg.arc (-t2,-t2,tileSize,tileSize,0,PI/2);
  svg.arc ( t2, t2,tileSize,tileSize,PI,3*PI/2);
}


void tpGate1()
{
    cms = "Custom Gate G1 ";
    composeXform('S');  
  
    float t=tileSize; // shorthand
  
    // gate in coordinate system with respect to entry facing east
    // where east = +y axis and course north = - x axis
    
     svg.line (0,-t2,0,0);             // first 6 inch segment (center of this tile is 0,0)
                                   // hence line enters the tile at 0,-t2 and ends at 0,0
                                   
     svg.arc (-t2,0,t,t,0,PI/2);       // turn left 90  (ending on tile border)
     svg.line (-t2,t2,-t2-t,t2);       // travel 1 tile length
     svg.arc (-t2-t,0,t,t,PI/2,PI);    // turn left  center x,y  diameter x,y, start end,angle 
     svg.beginShape();                 // turn left (and travel back to path -- this completes the loop of the path
       svg.vertex (-2*t,0);
       svg.vertex (-t,0);
       svg.vertex (-t2-2,t2);
     svg.endShape();
     svg.beginShape ();                // right gate 
       svg.vertex(-t,t2);
       svg.vertex(-t-t2+1.5,t);
       svg.vertex(-t-t2,t);
     svg.endShape();
     
     svg.line (-2*t,-0.3,-2*t,+0.375);  // fill gate loop where arc meets long line 
                                        // which is not mitered
            
     // draw DPRG logo
     int saveRow = curRow;
     int saveCol = curCol;
     
     curRow = 1;
     curCol = 3;
     curHeading = 2;
     composeXform('R');   // mirror in X
    
     svg.shapeMode(CENTER);
     svg.shape(logoRing,0,0,12,12);
     svg.shape(logo,0,0,12,12);
     
     curRow = saveRow;
     curCol = saveCol;
     composeXform('S');  // for mouse 
}
