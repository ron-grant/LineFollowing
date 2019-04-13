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

String VERSION = "Feb 19 NC Program working - crum sensor/control issues (NC prog listing printed in console)";
boolean followLine = true;   // F to start  SPACE stop


float worldToScreen;   // see setup()  -- scale world to screen 
float screenToWorld;   // and reciprocal, made dependent on screen resolution 


void resetRobot()
{
  
  // note: course lower left tile = row 1 col 1
  
  robot.xpos = (startCol-1)*tileSize + tileSize/2;               // place robot near to pathStart defined in setup()
  robot.ypos = (startRow-1)*tileSize;
  
  robot.heading = 0;   //  radians() converts degrees to radians 
  
  robot.vel =  robot.defaultDriveSpeed;
  
  robot.clearCrumbs();   // clear cookie crumbs

}


void setup() {  // called by "system" at program start

  size(1200,760,P3D);       // canvas width,height in pixels, renderer P2D or P3D as optional 3rd parameter
                            // global variables width and height now set with these values 
 
  worldToScreen = tileScale;              // tileScale set in PathReader now  6 for now   6x12 = 72 pixels 
  screenToWorld = 1.0/ worldToScreen;
  
  pathRead();             // PathReader provided module  reads NC program stored PathData    
    
    
  robot = new TricycleRobot();   // new instance of robot
  resetRobot();                  // see above, reset robot parameters. 
  
}


boolean erasedPathToCircle = false;
int circleRadius = 14;


void draw() {   // called at 30 or 60 times per sec by "system"

  background (0,0,20);      // erase backround
  textSize(20);
  
  int yo = 20;
  fill (240); // gray  240=almost white 
  text ("Version "+VERSION,50,yo); yo+=25;
  text (cmdSummary1 ,50,yo); yo+=25;
  text (cmdSummary2 ,50,yo); yo+=25;
  text ("Click mouse to set robot position and enter manual drive mode. G-Go ",50,yo); yo+=25;
  text ("  Manual drive Mouse Left Right move set steering angle",50,yo); yo+=25;
  text (String.format(" pos (%4.1f %4.1f)  heading  %4.1f   steeringAngle %5.0f  eDist %5.1f  ",
        robot.xpos,robot.ypos,degrees(robot.heading),degrees(robot.steeringAngle),  curEDist),40,yo); yo+=25;  
    
    // this program redraws waypoints, robot and entire cookie crumb trail every frame
  // might bog on slower computer 
  
  float dt = 1/frameRate;  // seconds elapsed since last frame  e.g. 1/30th or 1/60th sec
  
  if (robot.slow) dt = robot.slowMultiplier * dt;    //  slow down robot  e.g. 0.1 or 0.2 speed - 
  
  resetMatrix();
  camera();
  
  drawPath();  // new path reader NC code course pattern 
  
  float t1 = tileScale*tileSize;      // offset 1 tile from origin
  translate (t1,height-t1);
  scale(tileScale,-tileScale);
   
     
  stroke (200,200,0);                 // yellow
  strokeWeight(2.0/worldToScreen);    // scale line thickness 
  
    
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
  
   
 
}
