
/*
    allow adding geometry in random tile fashion
    orientation type attributes...
    
    Load LFT   Line Following Tile Format
    Save LFT   
   
      
    Move mouse to select tiles
    
    SPACE select pattern
    Arrows LEFT RIGHT  rotate pattern
    L R   Left Right pattern (rarely needed AFAIK)
    
    W  cycle width of lines
    J  cycle jog  left,right,none
    I  toggle invert
    
    C  clear
    
    
    
    
*/ 


PShape logo,stain20,stain40,stain60,stain80;
PShape logoRing;




TileArray tiles = null;

void createTileArray()
{
  if (tiles==null) 
    tiles = new TileArray();  // one instance of TileArray  -- read parameters before init
      
}  

class TileArray {
  
  Tile[][] tileList;
  
  int rows;   // copied from par on init
  int cols;

  TileArray () {
     // special svg  shapes imported then exported  
     println ("loading SVG files (stains & logo)");
     stain20 = loadShape("/svgLogoStains/Stain20.svg");   //   /data  folder 
     stain40 = loadShape("/svgLogoStains/Stain40.svg");   //   /data  folder 
     stain60 = loadShape("/svgLogoStains/Stain60.svg");   //   /data  folder 
     stain80 = loadShape("/svgLogoStains/Stain80.svg");   //   /data  folder
     logo    = loadShape("/svgLogoStains/DPRGLogo.svg");
     logoRing= loadShape("/svgLogoStains/DPRGLogoRing.svg");   // logo drawn with final course geometry (gate)
  
     println ("finished loading SVG Stains / Logo ");
    
    
     tileList = new Tile[50][50];   // row col
     
     //initTileList(); 
  }  
     
  void initTileList()
  {
    rows = par.rows;
    cols = par.cols;
        
    println ("initTileList rows cols : ",rows,cols);    
        
    for (int r=1; r<=rows; r++)
    for (int c=1; c<=cols; c++)
    tileList[r][c] = new Tile();
  }




void drawTileList()
{
  // println ("drawTileList() ");
  
  if (rows==0) return;
  
  for (int r=1; r<=par.rows; r++)
  for (int c=1; c<=par.cols; c++)
  {
    Tile t = tileList[r][c];
    t.drawAtRowCol(r,c); 
  
    // prepare to draw tile filling in info for TilePatternsSVG  
    
    Tile modTile =  tileDragDropCheck(t,mouseInTile);
    if (modTile != null)
    {
      tileList[r][c] = modTile;
      
      println ("OK dropped tile   type ",t.tileType);
      
    }        
    // draw and set mouseInTile
    
    if (mouseInTile && (tileInHand==null))
    {
      t = processKeyCommand(t);
      //tileList[r][c] = t;            // t is already element this statement not needed 
    }
    
    
    // allow picking up a tile from array and moving to new location 
    
    if (mouseInTile && (tileInHand==null) && (mousePressed==true))
    {
       tileInHand = t;
       
       if (keyPressed)   // erase old tile unless key is pressed   - Shift?
       {
         Tile nt = new Tile();
         nt.copy(t);               // copy t's attributes to nt 
         tileInHand = nt;
         // tileList[r][c] = nt;
       }
       else 
       {
         Tile nt = new Tile();
         tileInHand = t;
         tileList[r][c] = nt;  // clear old 
         
       }
       
    }
    
  }  // end for c,r
    
}


PrintWriter fsave;


void fWriteStr(String s) { fsave.println (s); }
void fWritePar(String s) { fWriteStr("#"+s);  }

void fWriteInt(String par, int i)     {fWritePar(par+" "+String.format("%d",i));    }
void fWriteFloat(String par, float v) {fWritePar(par+" "+String.format("%6.4f",v)); }

String saveFilename = "";



void saveFileLFT(String saveFilename)
{
  //saveFilename = "/data/test.LFT";
  
  fsave = createWriter(saveFilename);
  println ("Saving to ",saveFilename);
  
  color gc = par.gridColor;  // tile borders
    
  fWriteInt("Rows",par.rows);
  fWriteInt("Cols",par.cols);
  fWriteFloat("GridLineWidth",par.gridLineWidth);
  // break Grid line color into R,G,B
  fWritePar(String.format("GridLineColor %d,%d,%d ",gc >> 16 & 0xFF,gc >> 8 & 0xFF,gc & 0xFF));
  
  if (par.borderLettering>0)  fWritePar("BorderLetters 1");
  else                        fWritePar("BorderLetters 0");
  
  fWriteFloat("Scale",par.dScale);
  fWriteFloat("TileSize",par.tileSize);
  fWriteFloat("ThinWidth",par.widthThin);
  fWriteFloat("WideWidth",par.widthWide);
  fWriteFloat("NormalWidth",par.widthNormal);
  fWriteFloat("SVGScale",par.svgScale);
    
  fWriteStr("BEGIN");  
  for (int r=1; r<=rows; r++)
  for (int c=1; c<=cols; c++)
  {
    Tile t = tileList[r][c];
    if ((t.tileType ==0) && (t.stain == 'X') && (!t.invert)) continue;
    
    char lrc = 'S';
    if ((t.leftRight == 'L') || (t.leftRight=='R')) lrc = t.leftRight; 
    
    char rn = getRowName(r);
    
    String s = "*";
    if (t.lineWidth == 1) s +=  "T";
    if (t.lineWidth == 2) s += "W";
    if (t.invert)         s += "I";
    if (t.jog == 1)       s += "JL";
    if (t.jog == 2)       s += "JR";
    if (t.stain != 'X')   s += t.stain;
        
    fWriteStr(String.format("%c%02d dir%d %6s D%c %s",rn,c  ,t.dir,tileTypeName[t.tileType],lrc,s)); 
  }  
  fWriteStr("END");
  
  fsave.flush();
  fsave.close();
 

  }
  
 
private void loadTile(String ts)  // parse tile string
{
  
 if ((ts.length()==0) || (ts.charAt(0) == '#')) return; // skip  #parameter value line 
 
  if (ts.contains(";")) ts = ts.split(";")[0];   // delete everything after comment ;
  if (ts.length()==0) return;
    
  String[] s = ts.split("\\s+");    // split line 1 or more blanks between fields
 
  println ("line split ");
  if (s.length == 0 ) return;
  printArray(s);
 
  
 if (s[0].contains("BEGIN")) { } 
 else
 if (s[0].contains("END")) { }
 else
 {
   // first parse row,col numbers 
   
   int r    = s[0].charAt(0)-'A'+1;  
   int c    = Integer.parseInt(s[0].substring(1));
 
   // use row,col to get access to tileList element
   // t = tileList element (shorthand)
    
   println ("parsed r c ",r,c);   
      
   Tile t = tileList[r][c]; 
   
   println (String.format("read tileList[%d][%d]",r,c));
   
   t.dir  = Integer.parseInt(s[1].substring(3)); // strip dir
  
   String cmd = s[2];
   int cmdId = 0;

   for (int i=0; i<tileTypeName.length; i++)
     if (cmd.equals(tileTypeName[i])) cmdId = i;
   
   t.tileType = cmdId;
       
   t.leftRight = 0;                              // DS DL DR  
   if (s[3].contains("L")) t.leftRight = 'L';   
   if (s[3].contains("R")) t.leftRight = 'R';
  
   // s[4] contains attributes   thin,wide, jog (L/R) , invert
   
   t.invert = s[4].contains("I");
   
   t.lineWidth = 0;
   if (s[4].contains("T")) t.lineWidth = 1;
   if (s[4].contains("W")) t.lineWidth = 2;
   
   
   t.jog = 0;
   if (s[4].contains("L")) t.jog = 1;
   if (s[4].contains("R")) t.jog = 2;
   
   t.stain = 'X';
   if (s[4].contains("2")) t.stain = '2';
   if (s[4].contains("4")) t.stain = '4';
   if (s[4].contains("6")) t.stain = '6';
   if (s[4].contains("8")) t.stain = '8';
   if (s[4].contains("E")) t.stain = 'E';
       
   println ("loadTile ----- ",getRowName (r),c," cmdID ",t.tileType);
   
 }
}
 
  
void loadLFTfile(String filename)
{
  // initTileList(); // resetProgram();  // clears tileList
  
  // do we insure default parmeters set before loading new file ?
  // i.e. missing params..   resulting in leftover values?   not good
  
  par.readParameters(filename);
  createTileArray();         // create new empty array
  tiles.initTileList();      // clear rows x cols (as specified in parameters 
  
  
  println ("loadLFTfile ",filename);
  String[] sL = loadStrings(filename);
  println ("line count ",sL.length);
  
  for (String s: sL)
    loadTile(s);
  
  println ("finished loading LFT file ");
  
   
}



} // end TileArray class