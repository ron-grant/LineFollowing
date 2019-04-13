/*
   Tile Patterns - as tile opcodes are decoded by Path Reader, the tile pattern (tp___) functions here
   are used to generate path points in local tile coordinates for traveling north case and turning left case if arc
   or 90 degree bend case. 
   
   These coordinates are then paseed to tileFeatureXForm() which handles mirroring for right turn case and rotation for
   headings (east west south).
   
   pathPointAdd() stores points in list after transforming to world coordinates based on current row and column of tile.
   
   nextTile() included in this module, is used to keep track of current row and column based on turn direction and current
   path direction. Each tp___ function informs nextTile of heading modification affected by the tile, i.e. straight left,right
   
   tp functions included  
    
   tpForwardHalf()           1/2 tile travel - used for start 
   tpForwardWhole()          straight line whole tile
   tpGap()                   line with gap
   tpArc(dir)                turn arc   dir turn direction  'L' Left  Right 'R'    
   tpAcute(dir)              acute angle special case 2x2 tile region
   tpTurn (dir)              turn 90 hard
   tpSine(dir)               broken sine wave like pattern
   tpNotch(dir)              straight, 45 turn, straight, bend 90, straight, 45 turn, straight  pattern 
   tp45TurnHalfTile(dir)     turn 45 degrees and travel ~ 1/2 tile   - hack for current course finish

*/

boolean roundSquareCorner = true;

float widthThin   = 0.325;  // line Widths inches    correct?  
float widthNormal = 0.75;
float widthWide   = 1.5;

boolean thinLine;
boolean wideLine;
boolean invertTile;
boolean jogLeftTile;
boolean jogRightTile;

float curLineWidth()
{
  if (thinLine) return (widthThin);
  if (wideLine) return (widthWide);
  return (widthNormal);
}


String cms = "";  // command string   description used for diagnostic 


 

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
  
  if ((curRow>rows) || (curCol>cols) || (curRow<1) || (curCol<1))
  { println ("OUT OF BOUNDS ERROR! - set to A1");
    curRow = 1;
    curCol = 1;
  }  
  
}


// Tile Pattern Commands 


void tpForwardHalf()   {
  cms = "Forward Half Tile" ;    // assmption is robot is in middle of tile
 
  float y=0;   
  while (y<tileSize/2)  // generate points in standard orientation of pattern   
  { 
    PVector p =  tileFeatureXform (0,y,curHeading,false,tileSize);  // transform pattern x,y into current tile
    pathPointAdd(p,invertTile, false,curLineWidth());               // add coord to list (point,invert,gap,lineWidth)   
    y+=pathPointSpacing;
  }
  nextTile('S');
}


// PVector tileFeatureXform (float x, float y, int heading, boolean mirrorX, float tileSize)

void tpForwardWhole()  {        // generate tile points
  cms = "Forward Whole Tile";
 
  float y=-tileSize/2;   // for this case y moves from -tileSize/2 to +tileSize/2
  float x=0;             // x constant 0
     
  while (y<tileSize/2)  // generate points in standard orientation of pattern   
  { 
    // at this point x,y in tile coordinates with origin at center of tile
    // now apply rotation and left right turn  mirroring (for turn cases - false for this line which is symmetrical
    // about x axis)  

    PVector p =  tileFeatureXform (x,y,curHeading,false,tileSize);  // transform pattern x,y into current tile
    pathPointAdd(p,invertTile, false,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   
                                                            
    y+=pathPointSpacing;
  }
  
  nextTile('S');
}

void tpGap()           { 
  cms = "Forward with Gap"; 
  
  float y=-tileSize/2;   // for this case y moves from -tileSize/2 to +tileSize/2
  float x=0;             // x constant 0
     
  while (y<tileSize/2)  // generate points in standard orientation of pattern   
  { 
    boolean gap = abs(y)<tileSize/4;
    
    PVector p =  tileFeatureXform (x,y,curHeading,false,tileSize);  // transform pattern x,y into current tile
    pathPointAdd(p,invertTile, gap,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   
                                                            
    y+=pathPointSpacing;
  }
  
  
  
  
  nextTile('S');
}

void tpArc(char dir)   {
  boolean L = (dir=='L');
  
  if (L) cms = "Arc Left"; else cms = "Arc Right";
  
  float cx = -tileSize/2;
  float cy = -tileSize/2;
     
  float y=0;
  float x=6;
  float a=0;
  float r = tileSize/2;
  float da = pathPointSpacing/r;  // delta theta      arc length (spacing)  = r x theta
  while (a<PI/2)  // generate points in standard orientation of pattern   
  { 
    x = cx+r*cos(a);
    y = cy+r*sin(a);
    
    PVector p =  tileFeatureXform (x,y,curHeading,(!L),tileSize);  // transform pattern x,y into current tile
   
    // at this point x,y in tile coordinates with origin at center of tile
    // now apply rotation and left right turn  mirroring (for right turn case (!L) 
    // about x axis)  
        
    pathPointAdd(p,invertTile, false,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   gap=false most often   

    a+=da;
  }
  
   
  nextTile(dir); 
}




void tpAcute(char dir)
{
  boolean L = (dir=='L');
  if (L) cms = "Acute Left"; else cms = "Acute Right";
 
    
  // Acute Line   path code not done  !!!! 
   
  
   
  // special 2x2 tile  -- cases should be checked !!!!
 
  if (L)
  switch(curHeading) {  // north 0  east 1 south 2 west 3
  case 0 : curCol--; curRow--;  curHeading = 2;  break;
  case 1 : curCol--; curRow++;  curHeading = 3;  break;
  case 2 : curCol++; curRow--;  curHeading = 0;  break;   
  case 3 : curCol++; curRow--;  curHeading = 1;  break; 
  }
  else // right turn
  switch(curHeading) {  // north 0  east 1 south 2 west 3
  case 0 : curCol++; curRow--;  curHeading = 2;  break;
  case 1 : curCol--; curRow--;  curHeading = 3;  break;
  case 2 : curCol--; curRow++;  curHeading = 0;  break;    // contest course case
  case 3 : curCol--; curRow++;  curHeading = 1;  break; 
  }

  // quick code for turn left using 180 arc
    
  float cx = tileSize/2;
  float cy = -tileSize/2;
     
  float y=0;
  float x=0;
  float a=0;
  float r = tileSize/2;
  float da = pathPointSpacing/r;  // delta theta      arc length (spacing)  = r x theta
  while (a<PI)  // generate points in standard orientation of pattern   
  { 
    x = cx+r*cos(a);
    y = cy-r*1.5*sin(a);  // stretch in y a bit to mimic acute angle
    
    PVector p =  tileFeatureXform (x,y,curHeading,false,tileSize);  // transform pattern x,y into current tile
   
    // at this point x,y in tile coordinates with origin at center of tile
    // now apply rotation and left right turn  mirroring (for right turn case (!L) 
    // about x axis)  
        
    pathPointAdd(p,invertTile, false,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   gap=false most often   

    a+=da;
  }
  




  
}

void tpTurn(char dir)  {
  
  boolean L = (dir=='L');
 
  float y=-tileSize/2;
  float x=0;
  
  // need rouded off corner 
  
  if (roundSquareCorner)
  {
    tpArc(dir);  // just use arc turn 
    return;  
  
  }
  else
  {
      while (y<0)  // generate points in standard orientation of pattern   
      { 
        PVector p =  tileFeatureXform (x,y,curHeading,(!L),tileSize);   // transform pattern x,y into current tile
        pathPointAdd(p,invertTile,false,curLineWidth());                // add coord to list (point,invert,gap,lineWidth)  
     
        y+=pathPointSpacing;
      }
      while (x>-tileSize/2)  // generate points in standard orientation of pattern   
      { 
        PVector p =  tileFeatureXform (x,y,curHeading,(!L),tileSize);   // transform pattern x,y into current tile
        pathPointAdd(p,invertTile,false,curLineWidth());                // add coord to list (point,invert,gap,lineWidth) 
        x-=pathPointSpacing;
      }
  } // end square corner
  
  if (L) cms = "Turn 90 Left"; else cms = "Turn 90 Right";
  nextTile(dir);
}

void tpSine(char dir)
{ boolean L = (dir=='L');
  if (L) cms = "Sine start Left"; else cms = "Sine start Right";
  
  // Include Will's piecewise smooth arc code here 
   
  float   sgn =  1.0;
  if (!L) sgn = -1.0;
   
  float y=-tileSize/2;   // for this case y moves from -tileSize/2 to +tileSize/2
  float x=0;            
  
  while (y<tileSize/2)  // generate points in standard orientation of pattern   
  { 
    float amp = 0.15;   // SINE PATTERN AMPLITUDE  
    x = tileSize*sgn*amp*sin(y*2*PI/tileSize);  // stand in  
    
    
    PVector p =  tileFeatureXform (x,y,curHeading,false,tileSize);  // transform pattern x,y into current tile
    pathPointAdd(p,invertTile, false,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   
                                                            
    y+=pathPointSpacing;
  }
  
  
  
  
  
  
  nextTile('S');
} 

void tpNotch(char dir)
{ boolean L = (dir=='L');
  if (L) cms = "Notch Left"; else cms = "Notch Right";
  
  float y=-tileSize/2;
  float x=0;

  while (y<tileSize/2)  // generate points in standard orientation of pattern   
  { 
    float yp = tileSize/2-abs(y);    // hack for notch path
                                     // yp varies from 0 to 6 to 0
     
    x = -2+2*exp(-yp*yp*0.2);        // ideally enter exit straight    quick hack on exponential function for fun
 
    PVector p =  tileFeatureXform (x,y,curHeading,(!L),tileSize);  // transform pattern x,y into current tile
 
    pathPointAdd(p,invertTile, false,curLineWidth()); // add coord to list (point,invert,gap,lineWidth)   gap=false most often   
    y+=pathPointSpacing;
  }
 
  
  nextTile('S');
} 

void tp45TurnHalfTile(char dir)
{
  boolean L= (dir=='L');
  
  if (L) cms = "Turn 45 Left Half Tile"; else cms = "Turn 45 Right Half Tile";
  
  // next tile not computed 
  
} 
