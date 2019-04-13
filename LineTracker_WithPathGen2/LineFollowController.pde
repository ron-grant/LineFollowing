/*  Line Follower Controller 
    Called every display frame  i.e. 30/60fps

*/

float kP = 0.7;    // turn proportional constant
float kD = 0.1;    // turn derivative constant

boolean limitedTurnRate = true;   // set true to emulate servo limited slew rate

float prevEDist = 0;    // previous distance error - used for PD controller derivative term
float curEDist  = 0;

void lineFollowControllerUpdate(float dt, float worldToScreen)
{
   // xNear,yNear closest point on path
   // determine distance from virtual sensor to path crumb
   
   float edist = robot.findDistanceFromLinearVirtualSensorToCrumb();
   
   if (!followLine) return;
   
   float sa = 0.0;
   float a = 0.0;
   
   if (edist==999) 
   {
     // no crumb found -- drive straight ahead   
     robot.vel = robot.defaultDriveSpeed;
     prevEDist = edist;
     robot.steeringAngle = a;
   }
   else 
   {  // PD controller defines steering angle based of error distance and change in error distance 
      robot.vel =  robot.defaultDriveSpeed;
      float deltaE = edist-prevEDist;
      sa = kP*edist+kD*deltaE;
      prevEDist=edist;                 // save error distance from line for next time (derivative calc) 
   }
   
   curEDist = edist; // for display text (beginning of draw function)    
   
   
   //if (sa>PI/2) sa = PI/2;
   //if (sa<-PI/2) sa = -PI/2;
   
   
   // steering angle in radians   sa=0 straight ahead
   // PI/2  = 90 degree right turn
   // -PI/2 = 90 degree left turn
        
   if (limitedTurnRate)
   {  
     // turn front wheel at slew rate da
     // degrees/sec rate * update delta time 
       
     float da = radians(75)/0.15 *dt;         // define slew rate (max change in angle per update)
     a = robot.steeringAngle; 
     if (a<sa) { a+=da; if (a>sa) a = sa; }   // turn with slew rate limited by stop point at desired steering angle
     if (a>sa) { a-=da; if (a<sa) a = sa; }
     robot.steeringAngle = a;
   }  
   else
     robot.steeringAngle = sa;
     
  
}
