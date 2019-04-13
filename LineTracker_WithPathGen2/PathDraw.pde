

int rows = 6;        // max for course array
int cols = 12;
int tileSize = 12;             // size inches
float pathPointSpacing = 1; // distance in inches between path points
float tileScale = 6.0;


class PathPoint {    // path point storage, global coordinates, point properties
  PVector p;         // x,y point
  boolean invert;
  boolean gap; 
  float lineWidth;

  PathPoint (PVector p, boolean invert, boolean gap, float lineWidth)
  {
    this.p = p;
    this.invert = invert;
    this.gap = gap;
    this.lineWidth = lineWidth;
  }  
}


ArrayList <PVector> tileList = new ArrayList <PVector>();
ArrayList <PathPoint> pathPointList = new ArrayList <PathPoint>(); 


/*   tileFeatureXform()
     
     PathReader's tile path generating functions, e.g. tcArc() tcForwardWhole()...  rely on this transform to
     handle orientation cases for tiles and also turn Left/ turn Right cases 
        
     Example tile  for hard 90 left turn (LT opcode)
     (ultimately this tile may be given two paths, one describing line location, the other decribing radiused curve
      for robot to follow)
          
   
         north 0
      ------------    b= tile generator data origin 
     |     Y      |      (0,0)
     |     |      |
west | c   b-->x  |east 1    tile data defined with origin at center of tile 
 3   |            |          path travel from south to north on straight paths   (heading 0)
     |     a      |               
     +------------           path generator order illustrated in crude fashion a to b (in small increments)          
   o'    south 2             then onto c in small increments   
                            
                             turning pattern default is left in tile coordinates
                             if right mirrorX used
         
   o' is location of translated tile origin (all tile points now positive coordinates  Quadrant I)      
         

  
   
   
*/

PVector tileFeatureXform (float x, float y, int heading, boolean mirrorX, float tileSize)
{
  if (mirrorX) x = -x;
  
  float xr=0;
  float yr=0;
  
  switch (heading) {                // heading enterFrom 
  case 0:  xr= x; yr= y; break;     // north   south        unrotated tile case - matches generator's pattern
  case 1:  xr= y; yr=-x; break;     // east    west
  case 2:  xr=-x; yr=-y; break;     // south   north
  case 3:  xr=-y; yr= x; break;     // west    east
  }
       
  return new PVector(xr+tileSize/2,yr+tileSize/2);  // perform translation (tile origin now "lower-left corner")
}




void pathPointAdd(PVector p, boolean invert, boolean gap, float lineWidth)
{ 
  
  p.x +=  (curCol-1)*tileSize;     // translate tile coordinates to world coordinates   
  p.y +=  (curRow-1)*tileSize;     // note row and col numbering 1..N  so need to subtract 1 
  
  pathPointList.add(new PathPoint(p,invert,gap,lineWidth));
}



void pathAddTile(int row,int col)  // for now tiles can overlap 
{ 
  tileList.add(new PVector(row,col));
  //println (String.format("ADD -----------------------   row %d col %d ",row,col));
}


void drawTileBorders()
{
  int s = tileSize;
  
  stroke (220,100,100);
  textSize(16);
  
   
  for (PVector v:tileList)
  { float row = v.x;
    float col = v.y;
    
    pushMatrix();
    
    float ts = tileSize*tileScale;
    ts = ts/2;
    translate (ts,height-ts);
    scale(tileScale,-tileScale);
    
    noFill();
    strokeWeight(1/tileScale);
    rectMode(CENTER);
    rect(col*s,row*s,s,s);
    popMatrix();
    pushMatrix();
      
    fill(120,100);
    ts = tileScale;
    text (String.format ("%s%d",rowName[int(row)],int(col)),col*s*ts+s/4,height-ts*(row*s+s/8));
    popMatrix();
    
  
  
  } 

  
}


 
float minD2 = 9999;     // min distance squared
int   minDIndex = 9999;

float xNear;            // results (global here) being too lazy to return say a vector... 
float yNear;

float xSearch;
float ySearch;



void drawPath()
{
  // draw path and update xNear,yNear as closest points to xSearch,ySearch using rectangle search
  
  drawTileBorders(); 
  
  pushMatrix();
  float ts = tileSize*tileScale;
  translate (ts,height-ts);
  scale(tileScale,-tileScale);
  noFill();
  
  int alpha = 255;
  
  minD2 = 9999;
  int crumbIndex =0;
  for (PathPoint pp: pathPointList)
  {
   crumbIndex++;
   
   if (pp.gap) alpha = 100;  // make gaps semi-transparent for now... 
   else alpha = 255;
   
   if (pp.invert) stroke(0,0,200,alpha);
   else stroke (100,240,100,alpha);
   
   // while drawing pattern update nearest to search(xy)
   float dx = pp.p.x-xSearch;
   float dy = pp.p.y-ySearch;
   float d2 = dx*dx+dy*dy;
   
   // locate closest crumb, must be within 10 crumbs of previous except on first time
   // this might be dangerous - review this code  !!!! 
   
   if ((d2<minD2) && ((abs(crumbIndex - minDIndex) < 10)) || (minDIndex==9999))
    { xNear = pp.p.x; yNear = pp.p.y; minD2 = d2; minDIndex = crumbIndex;}   // update new closest crumb 
       
     
   ellipse (pp.p.x,pp.p.y,pp.lineWidth,pp.lineWidth);
  }
  
  popMatrix();
  
}



// Nearst point To Forward Sensor
// This method used by look ahead sensor. We might visualize as video camera image where we could search for path geometry nearest say center of 
// image where the results could be interpreted based on robot location (camera location) to give us world coordinate results. (xNear,yNear)
// In the simulation, geometry is stored in world coordinates, saving the compute world coordinates step.
//
// This function is called at robot draw time (30 to 60 fps)


void pathLocateNearestPointOnPath (float x, float y) 
{
  xSearch = x;
  ySearch = y;
  
  // drawPath() performs computation (next frame)  
  // this data from previous frame
  
  if (minD2 != 9999)
  {
    noFill();
    ellipseMode(CENTER);
    stroke (255,0,0);
    //strokeWeight(2.0/drawScale);
    ellipse (xNear,yNear,2,2);
  }  
}
