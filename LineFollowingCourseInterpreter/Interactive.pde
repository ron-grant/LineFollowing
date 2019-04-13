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

class Tile {
  
 int     tileType;       // 0=empty
 int     dir;            // feature direction 0,1,2,3
 char    leftRight; 
 int direction;
 int lineWidth;
 boolean invert;
 int     jog;         // 0=NO 1=LEFT 2=RIGHT
 char    stain;

 Tile() { tileType=0;
          dir = 0;
          leftRight = 'L';
          lineWidth = 0; // normal
          invert = false;
          jog = 0;
          stain = 'x';
        }
 
}

Tile[][] tileList = new Tile[100][100];   // row col
String[] cmdName = {"EMPTY", "START","GAP","F","ARC","CORNER","ACUTE","SCURVE","NOTCH","DCURVE","GATE",};


void initTileList()
{
   
  for (int r=1; r<=rows; r++)
  for (int c=1; c<=cols; c++)
    tileList[r][c] = new Tile();
}




char keyCmd = 0;

void keyPressed()
{
  if ((key>='a') && (key<='z')) key-=32;


  if (key =='S') saveTileList();
  if (key =='G') loadTileList ("test.LFT");    // TEMP !!!!
  
  if (keyCode == LEFT) key = '<';
  if (keyCode == RIGHT) key = '>';
  
  keyCmd = key;  
  key = 0;
}

/*
void mousePressed()
{
  if (mouseButton == RIGHT) keyCode = '>'; 
  
}
*/


void drawTileList()
{
  
  for (int r=1; r<=rows; r++)
  for (int c=1; c<=cols; c++)
  {
       
    Tile t = tileList[r][c];
    
    char LR = t.leftRight;

  
    // prepare to draw tile filling in info for TilePatternsSVG  

    curRow = r;
    curCol = c;
    curHeading = t.dir;
           
    thinLine     = t.lineWidth==1;
    wideLine     = t.lineWidth==2;
    
    invertTile   = t.invert;
    
    jogLeftTile  = t.jog==1;
    jogRightTile = t.jog==2;
    
    stainTile    = t.stain;
    
   // tpHighlightTile(mouseX,mouseY);
    
    switch (t.tileType)
    { case 0 : tpEmpty();    break;  // still do calc for mouse test
      case 1 : tpStartFin(); break;
      case 2 : tpGap(); break;
      case 3 : tpForwardWhole(); break;
      
      case 4 : tpArc(LR);    break;
      case 5 : tpTurn(LR);   break;
      case 6 : tpAcute(LR);  break;
      case 7 : tpSCurve(LR); break;
      case 8 : tpNotch(LR);  break;
      case 9  : tpDoubleCurve(); break;  
      case 10 : tpGate1();    break;
    
      case 11: tpEmpty();
    } // end switch
    
    // draw and set mouseInTile
    
    if (mouseInTile && (keyCmd != 0))
    {
      switch(keyCmd) {
        case 'C' :  t.tileType =0; break; // clear 
        case ' ' :  t.tileType += 1;
                    if (t.tileType>cmdName.length-1) t.tileType = 0;
                    break;
        case 'L' :
        case 'R' :  t.leftRight = keyCmd; break;
       
        case '<' :  t.dir--; if (t.dir<0) t.dir=3; if (t.dir>3) t.dir=0; break;
        case '>' :  t.dir++; if (t.dir<0) t.dir=3; if (t.dir>3) t.dir=0; break; 
        
        case 'J' :  t.jog = (t.jog + 1) % 3; break;
        case 'W' :  t.lineWidth = (t.lineWidth+1) % 3; break;
        case 'I' :  t.invert = !t.invert; break;
        case '2' :
        case '4' :
        case '6' :
        case '8' :  t.stain = keyCmd; break;
       
                    
      }  
      
      keyCmd = 0;
      
      //stileList[r][c] = t; // t is already element this statement not needed 
          
    }
      
  }  // end for c,r
    
}


PrintWriter fsave;


void fWriteStr(String s) { fsave.println (s); }
void fWritePar(String s) { fWriteStr("#"+s);  }

void fWriteInt(String par, int i)     {fWritePar(par+" "+String.format("%d",i));    }
void fWriteFloat(String par, float v) {fWritePar(par+" "+String.format("%6.4f",v)); }

String saveFilename = "";

void saveTileList()
{
  saveFilename = "/data/test.LFT";
  
  fsave = createWriter(saveFilename);
  println ("Saving to ",saveFilename);
  
  color gc = gridColor;  // tile borders
    
  fWriteInt("Rows",rows);
  fWriteInt("Cols",cols);
  fWriteFloat("GridLineWidth",gridLineWidth);
  // break Grid line color into R,G,B
  fWritePar(String.format("GridLineColor %d,%d,%d ",gc >> 16 & 0xFF,gc >> 8 & 0xFF,gc & 0xFF));
  
  if (borderLettering)  fWritePar("BorderLetters 1");
  else                  fWritePar("BorderLetters 0");
  
  fWriteFloat("Scale",dScale);
  fWriteFloat("TileSize",tileSize);
  fWriteFloat("ThinWidth",widthThin);
  fWriteFloat("WideWidth",widthWide);
  fWriteFloat("NormalWidth",widthNormal);
    
  fWriteStr("BEGIN");  
  for (int r=1; r<=rows; r++)
  for (int c=1; c<=cols; c++)
  {
    Tile t = tileList[r][c];
    if (t.tileType ==0) continue;
    
    char lrc = 'S';
    if ((t.tileType >3) && (t.tileType<9)) lrc = t.leftRight; 
    
    char rn = getRowName(r);
    
    String s = "*";
    if (t.lineWidth == 1) s +=  "T";
    if (t.lineWidth == 2) s += "W";
    if (t.invert)         s += "I";
    if (t.jog == 1)       s += "JL";
    if (t.jog == 2)       s += "JR";
        
    fWriteStr(String.format("%c%02d dir%d %6s D%c %s",rn,c  ,t.dir,cmdName[t.tileType],lrc,s)); 
  }  
  fWriteStr("END");
  
  fsave.flush();
  fsave.close();
 

  }
  
 
void loadTile(String tileStr)  // parse tile string
{
 String[] s = tileStr.split("\\s+");    // split line 1 or more blanks between fields
 
 if (s[0].contains("END")) { }
 else
 {
   // first parse row,col numbers 
   
   int r    = s[0].charAt(0)-'A'+1;  
   int c    = Integer.parseInt(s[0].substring(1));
 
   // use row,col to get access to tileList element
   // t = tileList element (shorthand)
      
   Tile t = tileList[r][c]; 
   
   t.dir  = Integer.parseInt(s[1].substring(3)); // strip dir
  
   String cmd = s[2];
   int cmdId = 0;

   for (int i=0; i<cmdName.length; i++)
     if (cmd.equals(cmdName[i])) cmdId = i;
   
   t.tileType = cmdId;
       
   t.leftRight = 0;                         // DS DL DR  
   if (s[3].contains("L")) t.leftRight = 1;   
   if (s[3].contains("R")) t.leftRight = 2;
  
   // s[4] contains attributes   thin,wide, jog (L/R) , invert
   
   t.invert = s[4].contains("I");
   
   t.lineWidth = 0;
   if (s[4].contains("T")) t.lineWidth = 1;
   if (s[4].contains("W")) t.lineWidth = 2;
   
   
   t.jog = 0;
   if (s[4].contains("L")) t.jog = 1;
   if (s[4].contains("R")) t.jog = 2;
    
   println ("loadTile ----- ",getRowName (r),c," cmdID ",t.tileType);
   
 }
}
 
  
void loadTileList (String filename)
{
  resetProgram();  // clears tileList
   
  inputFilename = "data/"+filename;
  
  // courseProgram = loadStrings(inputFilename);
  pathProgramReadParameters();  // read # parameters until BEGIN in string list
  
  while (pathDataLine< courseProgram.length)
   loadTile(courseProgram[pathDataLine++ -1]);
   
  inputSelected = true; // try this  
   
}
