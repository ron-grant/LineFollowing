  
 ArrayList <Tile> tiles = new ArrayList <Tile> ();
 
class Tile {
  int row,col;     // tile location 
  int dir;         // rotation direction   0,1,2,3   0 90 180 270
  int type;

  
 Tile (int col, int row, int direction, char type)
  {
    this.row = row;
    this.col = col;
    this.dir = direction;
    this.type = type;
  }
  
  void draw()   // tile draw 
  {
    resetMatrix();
    float t2 = tileSize * 0.5;
  
    strokeWeight (1.0); 
    noFill();            // important for arc - keep from displaying pie slice ... 
    stroke (200);        // light gray color    
    
    // compose transformation for line and arc features
    // designed in a tile coordinate system with center of tile a 0,0
    // and extents 1/2 tileSize e.g.  +/- 6" default 
    
    // transformation are applied in reverse order, first rotation about tile center
    // then potentially rotated tile is scaled (magnified) then tile is translated to
    // column and row of grid.
    // Because row one and column one are offset 1 tile our row and column numbers are 
    // +1
    
    translate (((col+1)*tileSize-t2)*displayScale,((row+1)*tileSize-t2)*displayScale);
    scale  (displayScale);
    rotate (dir * PI/2);
  
   
    if (type == tLINE) line (0,-t2,0,t2);
    if (type == tARC)  arc  (-t2,-t2,tileSize,tileSize,0,PI/2);  // center xy  diameter xy  start end angle
  }
} // end Tile clas
