/* Tile Dictionary and Drag

   Show dictionary of tiles on screen.
   
   Highlight tiles on mouse hover.
   If mouse button press animate copy of tile (holding selected tile)
   
   If mouse button release while over tile array set that tile to tile being held
   While holding tile can be rotated with keys, i.e. vert line can be rotated in preparation for
   dropping one or more copies on the course.
 
 */
 
 
 int mouseOverDict;
 
 
 Tile tileDropRequest = null;
 Tile tileInHand = null;
 
 
 void drawTileDictionary()
 {
   Tile t = new Tile();
   
   float screenScaleSave = screenScale;
   screenScale = 5.0;
    
   mouseOverDict = -1;
   
   float sc = par.tileSize * screenScale;
   
   for (int tt=1; tt<tileTypeName.length; tt++)
   {
      t.tileType = tt;
      mouseInTile = false; // should not be needed before Draw
      
      float xoff = int(tt*sc*1.1); 
      if (tt>=wideTileIndex) xoff = tt*sc*1.1+ (tt-wideTileIndex+1)*sc*2;
      
      t.drawAtScreenPosition(int(xoff),int(height-sc-onScreenOffsetY));  // x,y
      
      if (!generateSVG)
      {
        // draw tile border around tile
        float t2 = par.tileSize *0.5;
        gc.noFill();               
        gc.stroke(0,0,100);
        gc.strokeWeight(0.25);
        gc.rect (-t2,-t2,par.tileSize,par.tileSize);
      }  
               
      
      if ((mouseInTile) && (tileInHand == null)) mouseOverDict = tt;
   }
  
   if (mouseOverDict != -1)
   {
     //println ("mouseOverDict ",mouseOverDict);
     
     if (mousePressed == true)
     {
       tileInHand = new Tile(); 
       tileInHand.tileType = mouseOverDict;   // new tile, with same type as dictionary tile
       
       if (tileTypeName[mouseOverDict].contains("ARC")) tileInHand.leftRight = 'L';   // assign direction to ARC - needed if Jog set to non-zero value 
       
       
       
       println ("tileInHand = ",tileInHand);
     }
     else
     {  tileInHand = null;       // experiment  Apr 8
        tileDropRequest = null;
     }   
   }
   
   if ((tileInHand != null) && !mousePressed)
   {
     println ("need test to see if we are over tile array, drop tileInHand ",tileInHand," if so. ");
     tileDropRequest = tileInHand;
     tileInHand = null;
   }
   
   if (tileInHand!=null)                                 
    tileInHand = processKeyCommand(tileInHand);    // allow command keys to effect tile in hand
   
   
   screenScale=screenScaleSave;
   
 }
 
  
Tile tileDragDropCheck(Tile t,boolean mouseInThisTile)    // called when drawing tile array
{
  if (!mouseInThisTile) return null;   
    
  if (tileDropRequest != null)
  {
    println ("Dropping Tile into ARRAY");
    t = tileDropRequest;       // copy attributes ?  
    tileDropRequest = null;    // drop complete   OK for Java,  destroy?
    return t;                  // dropped tile
  }
  
  return null;  // no drop
}  


void drawTileInHand()
{
   // works if border letters (mouseX,mouseY- int(onScreenOffsetY))
  
   if (tileInHand != null) tileInHand.drawAtScreenPosition(mouseX,mouseY- int(onScreenOffsetY));
   // draw tile centered at current mouse position  
}
   
   
   