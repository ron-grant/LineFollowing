/* 
Path Reader for code that is described below which should be placed in separate file
encapsulated in comment as described unless being read as text file.

;Note this command file looks like a comment to Processing (Java) Program
;Hence starts with slash star and ends with star slash
;The file appears as PathData.pde
;TileCoords DriveCommands
; DPRG Challenge Course Program
; DCCPL = Dprg Challenge Course Programming Language
;
;
;Comments follow semicolons
; 
; [#TileCoord]<whitespace>[Modifier(s).]Command 
;
; TileCoord = Tile Coordinates before command
; these values may be checked by path generator - OR they might be optional
; 
;
; Modifiers (one or more modifiers followed by .
; L  Jump Left 1.5"
; R  Jump Right 1.5"
; T  Thin Line
; W  Wide Line
; I  Inverted Tile
; .  Modifier Terminator
;
; Command
; SH Forward Half Tile (6")  
; SW Forward Whole Tile
; SG Forward with Gap
; LA Left Arc 90
; RA Right Arc 90
; AR Acute Angle with Right Turn 
; AL Acute Angle with Left Turn (may not be implemented)
; LT Left Turn 90  
; RT Right Turn 90
; SL Sine Left (jagged sine/saw wave)
; SR Sine Right  
; NR Notch Right  45 right 90 left 45 right
; NL Notch Left   45 left 90 right 45 left
; R4 Right 45 Half Tile    -- hacks for finish 
; L4 Left 45 Half Tile 

#C12         ; starting coordinate (recommended if not specified in program steps)
#C12 SH      ; straight half tile  robot starts in center of tile  
#D12 SW      ; forward
#E12 R.SH    ; jog right forward
#F12 LA      ; left arc 
#F11 LA      ; left arc
#E11 N.SW    ; narrow straight 
#D11 AR      ; acute angle special case covers 2x2 tiles 
#E10 I.SW

*/




String [] courseProg;
String [] headingName = {"north","east","south","west"};
String [] rowName ={"X","A","B","C","D","E","F","G"};       // map curRow 1..6 to A..F

int curHeading = 0;              // default direction    0..3 North East South West  
int curRow;
int curCol;

int startRow;   // decoded from NC program
int startCol; 

 
void pathDecodeInstruction(String s)  
{
  
 thinLine = false;
 wideLine  = false;
 invertTile = false;
 jogLeftTile = false;
 jogRightTile = false;
 cms = "NO Instruction";
  
  String tileCoord = "";
  
   
  while (s.length()>0 && s.charAt(0)==' ') s = s.substring(1); // delete leading whitespace
  if (s.length()==0) return;
  
   
   
   
  // shift to uppercase - not done - maybe problem with code?
  // char[] sa = s.toCharArray();
  // for (int i=0; i<sa.length; i++) if ((sa[i]>= 'a') && (sa[i]<= 'z')) sa[i]-=32;
  // s = sa.toString();
    
     
  if (s.charAt(0)== '#')
  { // extract tile coordinates -- if just tile coordinate, assume starting tile coordinate being specified 
  
    //int firstSpace = s.contains(" ");
    
    String [] seqCmd = s.split(" ",2);      // array of strings seqCmd receives s split based on white space
                                            // with limit of two strings - without doing so, result was 
                                            // empty on F9 E9 E8... 
    tileCoord = seqCmd[0].substring(1); 
    if (seqCmd.length >1)
    { s = seqCmd[1];
      s= s.replaceAll(" ","");
    }
    else
    { s = "";
    }
    
  } 
  
  if (s.length() == 0)
  {
   
    curRow = 1 + int(tileCoord.charAt(0)-int('A'));
    curCol = parseInt(tileCoord.substring(1));
    print ( String.format("[%s%d] ",rowName[curRow],curCol));  // map row# to letter for display
    println ("   Setting Tile Coordinates");
    
    startRow = curRow;
    startCol = curCol;
        
    return;
  }
  
  pathAddTile(curRow,curCol); // add tile to display list 
    
  print ( String.format("[%s%2d] %5s    ",rowName[curRow],curCol,headingName[curHeading]));  // map row# to letter for display   
     
  if (s.length() == 0) return;
  
  String opCode = s;    
  if (s.contains("."))  // decode instruction modifiers 
  {
   
    while (s.charAt(0) != '.')
    {
      switch (s.charAt(0))
      {
      case 'I' : invertTile = true;  break;
      case 'T' : thinLine = true;    break;
      case 'W' : wideLine = true;    break;
      case 'R' : jogRightTile = true; break;
      case 'L' : jogLeftTile = true; break;
      }
      s = s.substring(1);
   }
   s = s.substring(1);   // strip '.'
  }
  
 
 
 
  if (s.contains("SH")) tpForwardHalf();
  else
  if (s.contains("SW")) tpForwardWhole();
  else
  if (s.contains("SG")) tpGap();
  else
  if (s.contains("LA")) tpArc('L');     
  else
  if (s.contains("RA")) tpArc('R');
  else
  if (s.contains("AL")) tpAcute('L');
  else
  if (s.contains("AR")) tpAcute('R');
  else
  if (s.contains("LT")) tpTurn ('L');
  else
  if (s.contains("RT")) tpTurn ('R');
  else 
  if (s.contains("SL")) tpSine('L');
  else
  if (s.contains("SR")) tpSine('R');
  else 
  if (s.contains("NR")) tpNotch('R');
  else
  if (s.contains("NL")) tpNotch('L');
  else
  if (s.contains("R4")) tp45TurnHalfTile('R');   // finish hacks
  else
  if (s.contains("L4")) tp45TurnHalfTile('L');
  else
  if (s.contains("END")) stop=true;
  else
  { println ("ERROR  ILLEGAL OPCODE !!!! ");
    return;
  }

  print (String.format("%8s %24s  ",opCode,cms));
   
  if (invertTile)   print ("invert ");
  if (thinLine)     print ("thin ");
  if (wideLine)     print ("wide ");
  if (jogLeftTile)  print ("jogLeft");
  if (jogRightTile) print ("jogRight");
  println();

 
 
    
}





boolean stop;

void pathRead()
{
  // iterate over entire tile file for now vs as needed by robot 
  
  courseProg = loadStrings("PathData.pde");
   
  println ("loaded PathData");
  println ("Tile coordinates [] and heading direction are listed before each tile command");
  println ("e.g. heading north implies entering tile at south");
  println ("");
 
  
  stop = false;
  for (String s:courseProg)
    if (!stop)
    if ((s.length()>0) && (!s.contains("/*")) && (!s.contains("*/")))
    {
      // delete everything after ;  (perhaps a bit of a hack with java strings
      
      if ((s.length()>0) && s.charAt(0)==';') s = "";
      
      if ((s.length()>1) && s.contains(";"))     
      {String[] sa = s.split(";");
       //printArray(sa);  // diagnostic    
       if (sa.length>1) s = sa[0];
       else s="";
      }  
       
      if (s.length()>1) 
      {
       //println ("valid string ----->> ",s);
       pathDecodeInstruction(s);
      } 
      
   }  
}
