/*  Border
    Methods (functions) for generating Tile borders and perimeter border numbering and lettering
    April 5, 2019
  
    output to screen or SVG   
    
    
    
    
    
    
*/    
   
float onScreenOffsetY = 50;   
  
void borderOffsetTranslation()
{
  
  float sc = par.dScale * par.svgScale;
  float yoff = 0;
  
  if (!generateSVG) {
    sc= screenScale; //  * par.dScale;
    yoff = onScreenOffsetY; 
  }
   
  float borderOffsetX  = par.cols*par.tileSize*(1.0-par.dScale)*0.5;          // center undersized drawing, do nothing for 
  float borderOffsetY  = yoff + par.rows*par.tileSize*(1.0-par.dScale)*0.5;   // dScale = 1.0
  
  if (generateSVG)
  {
    borderOffsetX *= par.svgScale;
    borderOffsetY *= par.svgScale;
  }  
 
  
  
  //  borderOffsetX = 0;     above effectively 0,yoff  if dScale = 1.0
  // borderOffsetY  = yoff;
  
  if (par.borderLettering > 0) {
    // assume dScale 1.0 (Scale parameter)
    borderOffsetX = sc * par.tileSize/2;
    borderOffsetY = borderOffsetX + yoff;
  }
  
  //println (par.dScale); 
  
   
  gc.translate (borderOffsetX,borderOffsetY);
}


void drawTileGrid()
{
  
 float sc = par.dScale * par.svgScale;
 if (!generateSVG)  sc= screenScale;  // yoff = onscreenOffsetY; }
  
 float ts = par.tileSize;
  
 if (par.gridLineWidth == 0.0) return;   // skip grid if zero width 
  
 float gridW = par.cols * ts * sc;
 float gridH = par.rows * ts * sc;
 
 gc.resetMatrix();
 gc.stroke(par.gridColor);
 gc.strokeWeight(par.gridLineWidth*sc);
 
 borderOffsetTranslation();
  
 float s = ts*sc;
 

  
 for (int x=0; x<=par.cols; x++) gc.line (x*s,0,x*s,gridH);
 for (int y=0; y<=par.rows; y++) gc.line (0,y*s,gridW,y*s);
}




void drawBorderLetters()
{
   float sc     = par.dScale * par.svgScale;    // get parameters 
   float cols   = par.cols;                 // shorthand
   float rows   = par.rows;
   float t      = par.tileSize;
   float yoff   = 0;
  
   if (!generateSVG)  { sc= screenScale; yoff = onScreenOffsetY/sc; }
  
   gc.resetMatrix();
   gc.scale(sc);
   gc.textSize(2);
  
   gc.textAlign(LEFT);
   gc.stroke(0);
   gc.fill(0);
   
    
   float nr =rows;
   float nc =cols;
   
   
   for (int c=1; c<=cols; c++)
   {
      gc.text(String.format("%d",c),t*c-2,yoff+3-t+t);                    // top line
      gc.text(String.format("%d",c),t*c-2,yoff+3+t*(nr-1)+t/2+t);         // bottom line 
   }
  
   for (int r=1; r<=rows; r++)
   {
      gc.text(String.format("%c",r+'A'-1),2             , yoff+t*(nr-r)+t);   // left col of text
      gc.text(String.format("%c",r+'A'-1),2+t*(nc+1)-t/2, yoff+t*(nr-r)+t);   // right col of text
   }
   
  
  
}