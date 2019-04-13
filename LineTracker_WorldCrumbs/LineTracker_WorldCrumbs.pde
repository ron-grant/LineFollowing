/*
    Simulate Control of Will Kuhnle's T2LS Robot  (orignal intent)
    T2LS is Tricycle Robot with line sensor between rear wheels.
          
    Robot Kinematics & Controller  - Will Kuhnle
    Simulation / Code - Ron Grant
    
    
    This simulation is departing from original robot, where goal, now, is to use a sensor more like a video camera
    looking ahead of robot able to percieve the line and locate it in
    world coordinates saving the point as a cookie crumb which remains stationary in the world as the robot moves
    forward.
    
    Given the robot is performing odometry using steering angle and wheel motion its perception of world
    coordinates will accumulate error, but crumbs recently percieved will be accurately placed within this
    "perceived world coordinate system".
    
    A virtual sensor is then used to react to the sensor cookie crumbs which will indicate good approximation of the
    location of the line.
    
    The line sensor and virtual sensor are defined in TricycleRobot class (see Robot tab)
    
    sensorDist = 8.0;              distance in inches from front wheel to sensor (generates cookie crumbs)
    virtualSensorDist = 1.0;       distance in inches from rear wheel axle midpoint to virtual sensor  (processes or senses cookie crumbs)
    
    
    
    Original Code Jan 7,2019
    Feb 12, 2019                   working on cookie crumb sensor
    
     
*/

String VERSION = "Feb 12 2019 working on crumb follow";
boolean followLine = true;   // F to start  SPACE stop


float worldToScreen;   // see setup()  -- scale world to screen 
float screenToWorld;   // and reciprocal, made dependent on screen resolution 


void resetRobot()
{
  robot.xpos = 10;               // place robot near to pathStart defined in setup()
  robot.ypos = 10;
  robot.heading = radians(45);   //  radians() converts degrees to radians 
  
  robot.vel =  robot.defaultDriveSpeed;
  
  robot.clearCrumbs();   // clear cookie crumbs
  pathSetup();  
}

void pathSetup() {        // define path from using way points in world coordinates              quadrant I displayed by default 
  pathErase();  
  pathStart(10,10);     
  pathTo(30,30);          // where pathTo and CircleTo generate intermediate points
  pathTo(50,44);          // suitable for simple query. 

  pathTo(70,30);
  pathCircle(14,360);     // draw circle(radius)  with current path point at 12 o'clock  
}

void setup() {  // called by "system" at program start

  size(1600,900,P3D);     // canvas width,height in pixels, renderer P2D or P3D as optional 3rd parameter
                         // global variables width and height now set with these values 
 
  worldToScreen = width/100;  // 8 for something like 800x600, hence width/100 is reasonable scale for our chosen way points
  screenToWorld = 1.0/ worldToScreen;
   
  pathSetup();
    
  robot = new TricycleRobot();   // new instance of robot
  resetRobot();                  // see above, reset robot parameters. 
  
}


boolean erasedPathToCircle = false;
int circleRadius = 14;


void draw() {   // called at 30 or 60 times per sec by "system"

  background (0,0,20);      // erase backround

  // following code erases path leading to circle once robot is at circle then
  // also shrinks circle for each robot turn around circle

  if (!erasedPathToCircle &&  (dist(robot.xpos,robot.ypos,pathX,pathY) < 2))
  { pathErase();
    pathStart(70,30);
    pathCircle(circleRadius,360);
    if (circleRadius>3) circleRadius -=2;   // shrink circle 
    erasedPathToCircle = true;
  }
  
  // after departed from circle start point at pathX,pathY shrink circle
  if (erasedPathToCircle && (dist(robot.xpos,robot.ypos,pathX,pathY)>4))
  {
    erasedPathToCircle = false;
    // !!! might want to shorten crumb life when circle gets really small 
  }
 
 
  textSize(20);
  
  int yo = 20;
  fill (240); // gray  240=almost white 
  text ("Version "+VERSION,50,yo); yo+=25;
  text (cmdSummary ,50,yo); yo+=25;
  text ("Click mouse to set robot position and enter manual drive mode. G-Go ",50,yo); yo+=25;
  text ("  Manual drive Mouse Left Right move set steering angle",50,yo); yo+=25;
  text (String.format(" pos (%4.1f %4.1f)  heading  %4.1f   steeringAngle %5.0f  eDist %5.1f  ",
        robot.xpos,robot.ypos,degrees(robot.heading),degrees(robot.steeringAngle),  curEDist),40,yo); yo+=25;  
    
    
   

  // this program redraws waypoints, robot and entire cookie crumb trail every frame
  // might bog on slower computer 
  
  float dt = 1/frameRate;  // seconds elapsed since last frame  e.g. 1/30th or 1/60th sec
  
  if (robot.slow) dt = robot.slowMultiplier * dt;    //  slow down robot  e.g. 0.1 or 0.2 speed - 
  
                                                     //  compose world to screen transformation 
  translate (0,height);                              //  make lower-left screen origin with 
  scale(worldToScreen,-worldToScreen);               //  screen showing quadrant I (positive coordinates)
                                                     //  effects all drawing functions e.g. line() ellipse()
 
 
 
 stroke (200,200,0);                 // yellow
 strokeWeight(2.0/worldToScreen);    // scale line thickness 
  
 pathDraw();                         // draw path using defined in world coordinates using current transform
  
  
 robot.drawRobot(dt,worldToScreen);  // draw robot
  
 
  
 lineFollowControllerUpdate(dt,worldToScreen);   // delta time , worldToScreen scale for sensor drawing 
                                                  // internally checks to see if followLine active 


 
  // add cookie crumb every ~7 frames unless running in slow mode then allow more frames
  // includes crumbs detected and optional crumbs that show wheel path  
  
  if (robot.slow)
  {
    if(frameCount % (4/robot.slowMultiplier) ==0) robot.addCrumbs();  // note frame count fudged here to increase crumb rate over initial 7/slowMultipler 
  }  
  else
    if (frameCount % 5 == 0) robot.addCrumbs();
    
      
  robot.updatePos(dt);       // move using vel,heading,steeringAngle
   
   
 
  if (mPressX != -1)    // mouse has been pressed                  mouse side to side steer
  {
    if (!followLine)
     robot.steeringAngle = -(mouseX-mPressX)*PI/width;
      
  }

  
  // draw world coordinate axes with slight offset from 0,0 (lower left corner of screen)
  stroke(255,0,0);
  strokeWeight(2/worldToScreen);
  fill(255,0,0);
  line (2,2,10,2); // x axis  slight offset from screen origin lower left
  textSize(20/worldToScreen);
  text ("X",11,2.5);
  stroke(0,255,0);
  fill(0,255,0);
  line (2,2,2,10); // y axis
 
}
