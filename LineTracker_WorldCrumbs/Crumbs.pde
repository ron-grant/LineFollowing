

boolean immortalCrumbs = false;   // set false to limit life
final int CRUMB_LIFE = 300;       // total lifetime  // changed from 700



ArrayList<Crumb> sCrumbs = new ArrayList<Crumb>();  // list of sensor crumbs. In the real world detected with respect to robot then
                                                    // transformed into world coordinates

ArrayList<Crumb> fCrumbs = new ArrayList<Crumb>();  // list of frontWheel cookie crumbs of robot path 
ArrayList<Crumb> rCrumbs = new ArrayList<Crumb>();  // list of rearWheel (axle center)  cookie crumbs of robot path 



class Crumb 
{
  float x,y;       // world coordinates 
  int  lifeLeft;   // set to CRUMB_LIFE unless immortal 
                   // -1 live forever 
  
  Crumb (float xp, float yp)  // constructor 
  { x=xp; y=yp;
  
    lifeLeft = CRUMB_LIFE;
    if (robot.slow) lifeLeft /= robot.slowMultiplier; // increase lifetime when running slow 
    
    if (immortalCrumbs) lifeLeft = -1;
  }
  
  boolean drawCrumb(float dia, color crumbColor)
  {
    // assume transforms setup to map crumb's world x,y to screen coordinates (world 0,0 maps to screen lower left) 
    
    if (lifeLeft==0) return (false);   // don't display if life zero -- if node not removed when iterating through list
    
    ellipseMode(CENTER);
    
    if (lifeLeft<0)
      stroke(crumbColor);  // immortal case
    else
      stroke (crumbColor,255*lifeLeft/CRUMB_LIFE);      // display aging crumbs using rgb,alpha channel transparancy  -- fade out
                                                        // 255 = opaque ... 0 = transparent 
      
    ellipse (x,y,dia,dia);
    
    if (lifeLeft == -1) return true;         
    else return(lifeLeft-- >0);             // decrement life, return false when 0, indicating time to remove from list (optional)
                                            // for now not implemented
  }
   
}