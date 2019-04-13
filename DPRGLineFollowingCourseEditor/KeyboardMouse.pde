/*
   Keyboard commands
   
   Most operate on tile in hand or tile that mouse pointer is over.
   
   Tile in hand is tile picked up from dictionary at bottom of screen.
   Move over press down and hold left mouse button.
   
   UP/DOWN arrows change scale of on screen tile array 

*/

char keyCmd = 0;

void keyPressed()
{
  if ((key>='a') && (key<='z')) key-=32;
  
  if (key == 'B') par.borderLettering ^= 1;
  
  
  if (keyCode == LEFT) key = '<';
  if (keyCode == RIGHT) key = '>';
  
  if (keyCode == UP) screenScale += 1;
  if (keyCode == DOWN) screenScale -=1;
  
  if (screenScale < 3.0) screenScale = 3.0;
  if (screenScale > 8.0) screenScale = 8.0;
  
  keyCmd = key;   // set global that will be procesed by processKeyCommand
  key = 0;
  
  //println ("keyCmd = ",keyCmd);
  
}


Tile processKeyCommand(Tile t)
{
  // this method is called only for tile in hand, or if no tile in hand  (null) then for 
  // current tile in tile array that mouse pointer is in. 
  
  switch(keyCmd) {
    case 0   : break; // no key
    case 'C' :  t.setDefault(); break; // clear 
    case ' ' :  t.tileType += 1;
                if (t.tileType>tileTypeName.length-1) t.tileType = 0;
                break;
       
    case 'M' :  if (t.leftRight == 'L') t.leftRight = 'R';
                if (t.leftRight == 'R') t.leftRight = 'L';
                break;
                
    case 'R' :  t.dir++; if (t.dir<0) t.dir=3; if (t.dir>3) t.dir=0; break; 
    
    case 'J' :  t.jog = (t.jog + 1) % 3; break;
    case 'W' :  t.lineWidth = (t.lineWidth+1) % 3; break;
    case 'I' :  t.invert = !t.invert; break;
    case '2' :
    case '4' :
    case '6' :
    case '8' :  t.stain = keyCmd; break;
    case 'L' :  t.stain = 'E'; break;      // including logo as a stain use E (Ensignia) vs L  due to LR used for jog in LCT file
    
  }  
  keyCmd = 0;
  
  return t;
  
}     