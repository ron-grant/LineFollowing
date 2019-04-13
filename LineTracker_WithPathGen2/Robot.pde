TricycleRobot robot;                // robot is single instance of TricycleRobot 

// This file includes only TricycleRobot class and its methods

class TricycleRobot     
{
    // parameters 
    float wheelSep = 4.0;          // rear wheel separation (for display)
    float bodyLength = 5.0;        // distance from rear axle center to front wheel contact point
    float wheelDia = 2.0;          // wheel diameter (for display only)
    float sensorDist = 0.0;        // distance from front wheel to sensor
                                    // had to make shorter 
    float virtualSensorDist = 2;   // distance from rear wheels (robot xpos,ypo) to virtual sensor that determines heading to nearest crumb
                                   // with some absolute minimum distance to prevent singularity problem   
    float virtualSensorWidth = 6.0; // virtual sensor width (linear sensor at right angle to robot heading)
    
    float defaultDriveSpeed = 7.0;
    float slowMultiplier = 0.2;    // when running in slow mode this is the speed multipler
    
    boolean slow = false;
    boolean crumbsFrontWheel = false;   // crumbs for display - no impact on line following
    boolean crumbsRearAxle = true;
    boolean showTurnCenter = false;     // show projected center of turn - diagnostic 
    
    
    // state info
    
    float xpos = 0.0;            // location of robot (midpoint of rear wheel axle) in world coordinates
    float ypos = 0.0;
    
    float heading = 0.0;         // heading in world coordinates 0 = drive along Y+ axis
                                 // sign  (+ to "right" - to "left") e.g.  +PI/2 heading along X+ axis
    
    float distToPath;            // valid after calling findHeadingToSensorCrumbNearestRobotVirtualSensor() 
    
    // inputs to control motion of robot
     
    float steeringAngle = 0.0;  //e.g.  0 straight   +PI/2 = 90 hard right   -- can be changed instantaneously 
    float vel = 2;
    
        
    float icX;                   // calculated center of turn in robot coordinates. Where center of rear axle is origin (0,0)
    float icR;                   // calculated radius of turn 
  
    float frontWheelXPos;             // calculated world coordinates of front wheel incase of interest, e.g. sensor at front wheel
    float frontWheelYPos;
      
  
  TricycleRobot() {}  // constructor - do nothing for now 
  
  
  
  /* method updatePos - update  position and heading  of tricycle robot  based on  steering angle, speed and some small delta time dt
  
     Front wheel is driven  assumed to roll at velocity (vel) traveling constant linear distance d (vel*dt) per update which is typically
     1/30th to 1/60th of second.
     
     Body of robot allowed to turn about rear wheels center point which is xpos,ypos in world coordinates
     in robot coordinates this point (center of rear "axle") is robot origin (0,0).
     
     bodyLength (L) is length of robot from rear axle center point to front wheel contact point called
     
     when wheel is turned, center of turn point is calculated such that robot drives around that point in a circle whose radius is function 
     of steeringAngle and bodyLength.
     
     Example cases (helpful to sketch) 
     wheel turned 90, tricycle rotates about robot origin (rear axle center)
     
     wheel turned at arbitrary angle, intersection of wheel perpendicular with line through real wheels.
     Triangle is formed, e.g. for turn right at 45, project line from front wheel to line extended along rear axle axis.
     Length of line =  L * tan(45) = L * 1.0.
     
     Therefore when wheel turned 45 degrees, front wheel will drive through circle with radius L for total distance of 2PI*L in one 
     turn around a 360 degree circle.
     
     With a distance d per update (1*dt) heading angle of robot changes    2PI * d/(2PI*L) radins =   d/L radians
     
  */
  
  void updatePos(float dt)
  {
    // update location of tricyle robot origin (point between rear wheels)
    // front wheel is driven and can turn +/- 90 degrees (or greater?)   steeringAngle = 0  for straight ahead driving
    // turn right positive angle, left negative angle
    // 
    // calculations based on approximation of motion in a small interval of time
    //
        
        
  
    float d = vel * dt;    // calculate linear distance traveled d (by front wheel) in dt time  (assume constant velocity over dt)
  
    float L = bodyLength;  // L =  shorthand  distance between rear axle mid point (between 2 wheels) and front wheel center point
                           // or point of contact
        
    // move in the direction of the heading based on the steering angle
    
    float md = d * cos(steeringAngle);    // wheel straight  md =d   wheel at 90  no movement
    
    xpos += md*sin(heading);    // advance position along direction of heading
    ypos += md*cos(heading);
    
         
    // determine 
    // instantaneous center of rotation when turning,  along line through rear weels
    // robot will turn (rotate) about that point (when turning)
    // consider mid point between wheels as robot origin (0,0) in robot coordinates
    //             /             
    //           +  center of front wheel, wheel turned to right  
    //         / |a .            dot . . . line is perpendicular from wheel center to point at icX,0
    //          L|     .
    //           |        .
    //      |----+----|     + center of turn 
    //          org           (icX,0) in robot coords 
    //        (0,0) in robot coords
    //        (xoff,yoff) in world coords
    //
    //   robot shown with heading 0, but with center of turn such that robot will turn about that point
    //   where heading will change.
    //    
    //   right triangle formed: robot org, center of front wheel, center of turn
    //   leg of triange  from org to icX computed using tangent function of known angle a (90 - steering angle)  
    //   and leg L (distance from org to front wheel center)
    //   (tangent a = length opposite side/length adjacent)
    //
    //   radius of turn icR  is distance from center of turn to wheel 
    
    
    icX = L * tan (PI/2-steeringAngle);  // zero when not turning     note when 45 deg (tan a = 1.0) : icx=L
         
    // coordinates of instantaneous center are (icX,0) in robot coordinates  
        
    icR = dist(icX,0,0,L);      // distance from IC to wheel    point ICX to wheel sweeping out circular
    if (icX<0) icR = -icR;            
   
    float dh =  d/icR; 
      
    heading += dh;    // change in heading equates to portion of circle turned as we advance d along curve, where 
                      // d is small fraction of circle and can be approximated as arc length 
                      // e.g.  radius*delta_theta = arc length,   delta_theta = arc length / radius,  delta_theta  =  d/icR
   
    // Note : Will's simpler method of calculating heading delta not requiring finding center of rotation
    // as done above where heading += d*sin(steeringAngle)/L;
       
    if (heading>PI*2) heading -= PI*2;  // keep heading in 0..2PI range
    if (heading<0) heading += PI*2;
    
    
    frontWheelXPos = xpos + L*sin(heading);  // calculate wheel position, to be used in case of following line by using sensor located at front wheel
    frontWheelYPos = ypos + L*cos(heading); 
    
     
  }
  
  void addCrumbs() {   // add crumbs including sensor crumbs used for line following  and optional visualization crumbs    
    
    float sd = bodyLength+sensorDist;     
    
    float xs = xpos + sd*sin(heading);  // calculate sensor position some distance infront of robot using robot heading
    float ys = ypos + sd*cos(heading);  // i.e. not affected by wheel turn angle
    
    // search for path closest to this point and use that position as crumb position
    // could do line intersection test  to simulate line sensor, but this should suffice for now  
    
    pathLocateNearestPointOnPath(xs,ys);  // sets  (xNear,yNear) after one draw cycle 
     
    if (xNear != 999)      
      sCrumbs.add(new Crumb(xNear,yNear));  // new sensor crumb - these are used for line following
    
    // wheel crumbs - optional for visualization of path only - robot cannot "see" these crumbs
    if (crumbsRearAxle)  
      rCrumbs.add(new Crumb(xpos,ypos));                          // add cookie crumb to list
    if (crumbsFrontWheel)
      fCrumbs.add(new Crumb(frontWheelXPos,frontWheelYPos));

  }   
  
    
  // this is sensor located typically near rear wheels
  // it detects crumbs located on the line in front of the robot that are now near
  // the rear axle 
  
  float findDistanceFromLinearVirtualSensorToCrumb()
  {
    float v = virtualSensorDist;
    float vx = xpos + v*sin(heading);   // calculate virtual sensor position in world coords 
    float vy = ypos + v*cos(heading);   // e.g. typically 0 to few inches in front robot xpos,ypos located center of of rear wheels
    
   
    float halfSensorW = virtualSensorWidth/2.0;  // half sensor width  
       
    
    float minD = 999;       // prepare for min distance calculation
    int   signMinD = 0;      // sign of minimum distance (+1 or -1) 
     
    boolean sensorShown = false;    // draw sensor points one time
    boolean didDraw = false;
     
    stroke (255,0,255); // RGB  sensor magenta 
    noFill();
    fill(255,0,255);
    ellipseMode(CENTER);
    strokeWeight(0.5/worldToScreen);
       
    for (Crumb c : sCrumbs)  // iterate over all crumbs detected by forward sensor 
    {
      // if crumb is alive and its distance is 1/2 Sensor width MAX then
      // iterate over sensor positions looking left at about 10 samples along sensor line (dir=-1)
      // then looking right about 10 samples along sensor line (dir =1)
      
      if (c.lifeLeft != 0)
      if (dist(c.x,c.y,vx,vy)< halfSensorW)           // only consider crumbs very close to sensor for distance test   must be 1/2 sensorWidth away
      {
        for (int dir = -1; dir<2; dir++)              // testing all points on sensor for distance to this crumb  looking left then right (dir -1, dir +1) 
        if (dir!=0)  // exclude dir=0
        {
          float h   = heading + (PI/2.0)*dir;        // sensor perpendicular to robot heading  (don't think we care about exceeding 2PI (wrap OK for sin,cos)
          
          if (h<PI*2) h-=PI*2; 
          if (h<0) h+=PI*2;
          
          float ux  = sin(h);                        // unit vector pointing along sensor line 
          float uy  = cos(h);
          
          int N = 10;
          
          
          for (int r=0; r<N+1; r++)             // for each of 10 points along line of sensor 
          {
            float sd = r * halfSensorW/N;      // sensor distance along sensor 0 to 1/2 SensorWidth in 1/10th of 1/2 width increments
            
            float xp = vx+ sd*ux;              // calcualte point on sensor along line of sensor using unit vector scaled by incremental distance 
            float yp = vy+ sd*uy;
            
            if (!sensorShown)
            {
              // plot xp,yp which are sensor sample points in world coordinates
              // note this is only done one time, requiring at least one crumb to be within 1/2 width distance, else sensor bar not drawn
              
              ellipse(xp,yp,0.2,0.2);  // circle in world coords of diameter in world coordinates
              didDraw=true;
            }  
            
            float d = 0;
            if ( (c.x != xp) || (c.y != yp))
              d = dist(c.x,c.y,xp,yp);                      // distance from point on sensor to crumb
            
            if (d< 1.5*halfSensorW/N)
            {
              d = d + sd;                                   // add current distance from sensor center 
              if (d<minD) { minD = d;  signMinD = dir; }    // update minimum and remember sign (the side of the sensor -1 or +1)
            }  
              
          }
        }   // end for dir -1 to +1 
      }
      
      if (didDraw) sensorShown = true;
      
     } // end for c:sCrumbs
          
     
     if (minD != 999)
     {  minD *= signMinD;   // sign the distance if valid distance, i.e. make distance negative for detect on left side of robot
      // println (minD);
     }
        
     
     return minD;
    
   }  
  
 
  
  
  void drawCrumbs(float dia,color f, color r) {                                               // draw entire list of cookie crumbs
     
    // draw crumbs - if not immortal drawCrumb will return false when crumb expired
    // could be removed from list -- not done 
    
    if (fCrumbs.size()>0)
    for (Crumb c : fCrumbs) c.drawCrumb(dia,f);
    if (rCrumbs.size() >0)
      for (Crumb c : rCrumbs) c.drawCrumb(dia,r);
      
    for (Crumb c : sCrumbs) c.drawCrumb(dia,color(0,255,0));  // green   
  } 
  
  void clearCrumbs() {fCrumbs.clear(); rCrumbs.clear(); sCrumbs.clear(); }
  
  
  void drawRobot(float dt,float sc)
  {
     
    
     pushMatrix(); // save world to screen transform, restore at function end
    
     rectMode(CENTER);                 // draw rectangles with center at x1,y1 e.g. rect(x1,y1,width,height)
     noFill();
                                       // draw robot components - with using transformation stack 
         
     
     drawCrumbs(0.5,color(0,0,255),color(255,0,0));  // size inches  front crumbs Blue color, rear Red crumbs color 
                                                     // sensor crumbs also included,  color not specified here 
     
     stroke (0,200,200);
     
     translate(xpos,ypos);     
     strokeWeight(2.0/sc);
    
     rotate (-heading);            // transform now with concatinated   rotate and translate
                                   // from robot local coordinates to world 
         
     float d2 = wheelSep/2.0;
     float ww = wheelDia/5.0;
     
     rect(-d2,0,ww,wheelDia);      // left rear wheel    robot local
     rect( d2,0,ww,wheelDia);      // right rear wheel
      
     
     line (-d2,0,d2,0);            // axle - robot local
     
     if (showTurnCenter) {
      pushStyle();
      stroke (100,0,50);
      line (0,bodyLength,icX,0);   // line to instan center
      ellipse (icX,0,1,1);
      stroke (20,20,20);
      ellipseMode(CENTER);
      ellipse(icX,0,icR*2,icR*2);      
      popStyle();
     }
     
     line (0,0,0,bodyLength);     // line from center rear axle to front axle - specified in robot local coords
  
     stroke(240);
     ellipse (0,bodyLength+sensorDist,2,2);  // draw forward sensor disc 
  

     translate(0,bodyLength);
     rotate (-steeringAngle);       // radians
     
     rect (0,0,ww,wheelDia);       // front wheel -- in local wheel coordinates now transformed  to robot then to global coordinates then to screen
               
    
     popMatrix(); // restore current world to screen transformation 
   }   // end drawRobot method 
     
    
        
}  // end class TricycleRobot
  

  
  
