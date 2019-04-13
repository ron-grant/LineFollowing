
// Keyboard interaction and mouse interaction handled in this file (Tab)

int mPressX = -1;
int mPressY = -1;

String cmdSummary1 = "C-ClearCrumbs R-Reset SPACE-Toggle Follow (freeze when off) S-Slow Toggle";
String cmdSummary2 = "";

boolean fullCourseView = true;

void keyPressed()
{
  if ((key>='a') && (key<'z')) key -=32;  // upshift if lowercase
   
  switch (key)
  {
   case 'F' : fullCourseView = !fullCourseView; break;
    
   case ' ' : followLine = !followLine; 
             if (!followLine) robot.vel=0;
             else robot.vel = robot.defaultDriveSpeed;
             break;
    
  case 'C' : robot.clearCrumbs(); break;
  case 'R' : resetRobot(); break;
   
  case 'S' : robot.slow = !robot.slow;  break;  // stop 
  
  case 'G' : robot.vel = robot.defaultDriveSpeed; 
             followLine = false;  // go 
             break;
              
  }
}


void mousePressed()
{
  // after mouse press move mouse left/right to steer robot manually 
  
  robot.xpos = screenToWorld * (mouseX);
  robot.ypos = screenToWorld * (height-mouseY);
 // robot.heading = 0;
  
  followLine = false;
  
  robot.steeringAngle = 0;
  //robot.vel = 0;
 
  mPressX = mouseX;
  mPressY = mouseY;
 
}
