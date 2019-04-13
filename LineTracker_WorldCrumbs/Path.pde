/* This code module with associated methods Generates Path for robot to follow using caller specified way points which are specified in 
   setup() function. 
 
   The path points are spaced using pathStep, e.g. 0.5 inches apart.
   
   The path points are considered invisible to the robot until it detects them using a sensor which then places a cookie crumb on the path.
   
   An assumption is made that the robot can do a good (perfect) job locating itself in world coordinates for the duration of this simulation. 
   The reality might be quite different, e.g. wheel based odometry. Still. the idea that the robot can detect points on a path and generate cookie crumbs
   with a short lifetime is quite valid. 
 
   When the program is run, the path points show up as small yellow dots.

*/   


ArrayList<PVector> path = new ArrayList<PVector>();  // list of path points (2D) in world coordinates 
                                                     // use pathStart(x,y)  and pathTo(x,y) to add points this list
                                                      
float pathStep = 0.5;   // step in inches between path points 
float pathX = 0;        // default pathStart at origin 
float pathY = 0;

void pathErase() { path.clear(); }    // erase all path points 

void pathStart(float x, float y) { pathX = x; pathY = y; }   // call with coordinates of path starting point

void pathTo (float xEnd, float yEnd)  // call with coordinates of path ending point -- generates intermediate points with pathStep spacing
{
  float dx = xEnd-pathX;
  float dy = yEnd-pathY;
  float d = dist(xEnd,yEnd,pathX,pathY);
  float u = 0.0;
  
  float du = pathStep/d;
  
  while (u <=1.0)
  {
    float x = pathX + u*dx; 
    float y = pathY + u*dy;
    path.add (new PVector(x,y));   // add intermediate point to path list
    u += du;
  }  
  
  pathX = xEnd;
  pathY = yEnd;
    
} // end pathTo

void pathCircle(float r, float subtendAngle)    // circle path from current waypoint
{
  float cx = pathX;
  float cy = pathY-r;
  
  float sa = radians(subtendAngle);
  
  int N = (int) (sa*r/pathStep);
  
  for (int i=0; i<N; i++)
  {
    float a = sa*i/N;
    float x = cx + r* sin(a);
    float y = cy + r*cos(a);
  
    path.add (new PVector(x,y));   // add circlre point to path list 
  }
    
}

void pathDraw()
{
  // assume current transformation set up that maps ellipse x,y from world to screen coordinates 
  // where lower-left of screen is 0,0 and screen is Quadrant I of world
  
  ellipseMode(CENTER);
  for (PVector p : path) ellipse (p.x,p.y,0.1,0.1);    // draw list using world to screen transform
}


// Nearst point To Forward Sensor
// This method used by look ahead sensor. We might visualize as video camera image where we could search for path geometry nearest say center of 
// image where the results could be interpreted based on robot location (camera location) to give us world coordinate results. (xNear,yNear)
// In the simulation, geometry is stored in world coordinates, saving the compute world coordinates step.
//
// This function is called at robot draw time (30 to 60 fps)


float xNear;       // results (global here) being too lazy to return say a vector... 
float yNear;

void pathLocateNearestPointOnPath (float x, float y, float drawScale)  // search for path point nearest x,y and set xNear,yNear and dirDir
{
  float minD = 999;
  xNear = 999;
   
  for (int i=0; i<path.size(); i++)
  {
    PVector p = path.get(i);         // get ith coordinate from path list 
    float d = dist(x,y,p.x,p.y);
    
    if (d< minD) {
      minD = d;
      xNear = p.x;
      yNear = p.y;
    }
  }
  
  // below is code to draw circle at located point
 
  if (xNear != 999)
  {
    noFill();
    ellipseMode(CENTER);
    stroke (255,0,0);
    strokeWeight(2.0/drawScale);
    ellipse (xNear,yNear,2,2);
  }  
  
}