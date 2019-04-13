int tileSize = 12;
int displayScale = 6;

char tLINE = 'L';        // geometry type in a given tile 
char tARC  = 'A';
char curType;            // default type 

int rows = 4;            // size of tile array
int cols = 6;

int mouseRow = -1;
int mouseCol = -1;
boolean waitingForMouseRelease = false;  // tile added when mouse pressed, must wait for release
                                         // to prevent adding more than one tile


void keyPressed()
{
  if ((key>='a')&&(key<='z')) key-=32; // shift to upper case ASCII if key lowercase
   
  Tile ct = null;
 
  // search tile list for tile mouse is currently in, assign ct to the tile 
  for (Tile t: tiles)
    if ((t.row == mouseRow) && (t.col == mouseCol))
      ct = t;
  

   switch (key) {   // commands not dependent on tile    
   case 'L' : curType = 'L'; break;
   case 'A' : curType = 'A'; break;
   }
      
  // if mouse is in a tile with geometry, then act on it        
  if (ct != null)
  switch (key) {
  case 'R' : ct.dir = ((ct.dir)+1) %4;  break;
  case 'C' : tiles.remove(ct); break;
  }
}


void drawGrid() 
{  
  stroke(20,200,20); // green
  
  float sc = tileSize * displayScale;
  
  scale (sc); // apply scale to following line draws
  strokeWeight (1/sc);
  
  mouseRow = -1;
  mouseCol = -1;
  
  for (int r=1; r<= rows; r++) //line (1,r,cols,r);  // draw horizontal grid lines
  for (int c=1; c<= cols; c++)// line (c,1,c,rows);  // draw vertical grid lines
  {
    rect (c,r,1,1);  // rectangle with upper left at c,r with size 1x1 unit
                     // transformed by above scale function 
                     // to tile world coordinates 
    
    float  mx = (mouseX / sc);   // calculate tile coordinates of mouse (whole# part = tile coord)
    float  my = (mouseY / sc);
        
    if (((mx-c)>0) && ((mx-c)<1.0) && ((my-r)>0) && ((my-r)<1.0))
    {
      // mouse in this row,col tile 
      mouseCol = c;
      mouseRow = r;
      
      if (mousePressed)
      {
        if (!waitingForMouseRelease)
        {
          waitingForMouseRelease = true;
          tiles.add(new Tile (mouseCol,mouseRow,0,curType));   // col row dir type
          println ("add new tile at   col",mouseCol,"  row ",mouseRow);    
        } 
      } else  waitingForMouseRelease = false;  // not mouse pressed
    }
  }
  
}

void setup () // called when sketch starts up
{ size (640,480);
 
  tiles.add(new Tile (2,3,0,tARC));   // col row dir type 
  tiles.add(new Tile (2,2,0,tLINE));
  tiles.add(new Tile (1,2,0,tLINE));
  tiles.add(new Tile (1,3,1,tARC)); 
  
  curType = tARC; // current feature type to add to grid on click
  
}

void draw ()  // called at frame rate e.g. 30 to 60 times per second
{ background (20);
  textSize(18);
  text ("Simplified Model Of DPRG Line Following Course Editor ",20,40);


  strokeCap(SQUARE); // or ROUND  or PROJECT( like added 1/2 width distance with round, but square)
  ellipseMode(CENTER);
  drawGrid();
  for (Tile t: tiles) t.draw();
}
