/*  LFC_Reader - Line Following Course Format Read then use
    TilePatternsSVG module to generate output SVG tile patterns and track 
    tile row,column position and direction.
    
    Ron Grant
    May 30,2019
        
*/


/*
; Language Description Reference for LFC format which can be embedding in LFC source 
; as documentation if desired 
;
; All text after semicolon on a line is reguarded as a comment, ignored by instruction parser
; 
; Instruction Format
; [Modifier(s).]Command    
;
; Modifiers (one or more modifiers followed by) .
; L  Jump Left 1.5"
; R  Jump Right 1.5"
; T  Thin Line
; W  Wide Line
; I  Inverted Tile
; 
; Commands  Description 
; BEGIN     
; START     Forward Whole tile with start/end line across tile 
;
; F         Forward Whole Tile
; FG        Forward with Gap
;
;        Note Following Instruction All Have Left Right Variants 
;
; LA    Left Arc 90
; RA    Right Arc 90
; LV    Acute Angle with Left Turn 
; RV    Acute Angle with Right Turn 
; LT    Left Turn 90 (hard turn)  
; RT    Right Turn 90 (hard turn)
; LS    S-Curve  Start to Left (jagged sine/saw wave)    - see spec.  0.75x1.5" bars except start end
; RS    S-Curve  Start to Right 
; LN    Notch Right  approx: 45 left 90 right 45 left    - see spec.
; RN    Notch Left   approx: 45 right 90 left 45 right
; END   Final Instruction 
;
; Sample Program (except leading ; making comment)
; #Parameter Value  List Appears First 
; #Rows 6
; #Cols 12
; #GridLineWidth 0.125
; #GridColor 255,0,0
; #StartRow C
; #StartCol 12
; #StartDir N
; #BorderLetters 1  ; 1 or 0   if 1 (enabled) 
;                   ; 12 must be added to width and height of Document Properties Page Tab
; #Scale 1.00       ; handy to allow small border if BorderLetters not being used.  e.g. try 0.98
; #TileSize 12      ; Set Tile size (square) in inches 
; #ThinWidth   0.375; Thin Line Width  T modifier
; #WideWidth 1.5    ; Wide Line Width  W modifier 
; #NormalWidth 0.75 ; Normal (default) line width
;
; Below is sample program, again commented out with leading ; to allow embed in program as documentation.
;
; BEGIN   ; required after #parameters, before path instructions 
; START   ; straight full tile (with start/finish cross line)  
; F       ; forward
; R.F     ; jog right forward
; LA      ; left arc 
; LA      ; left arc
; N.F     ; narrow forward 
; RV      ; acute angle special case covers 2x2 tiles 
; I.F     ; invert forward  
; END     ; END program 
*/

String [] courseProgram;  // string list containing entire course program source file

String [] headingName = {"north","east","south","west"};

int curHeading = 0;              // default direction    0..3 North East South West  
int curRow;
int curCol;

int startRow;   // decoded from NC program
int startCol; 

boolean encounteredBegin;
boolean stop;
int pathDataLine;

boolean showDecode = true;   // set true to see instruction decode

void initPathReader()
{
  startRow = 0;   // param specified 
  startCol = 0;  
  curRow = 1;
  curCol = 1;
  curHeading = 0;
  encounteredBegin = false;
  stop = false;
  pathDataLine = 0;
  dScale = 1.0;
}


char getRowName (int row)     // convert row# to letter 1=A 2=B ... 
{ return char ('A'+row-1); }
 

// parseXXXX below  used by decode Param   for #Parameter Value Pairs before BEGIN

float parseNum (String s) { return Float.valueOf(s); }
int parseNumInt(String s) { return Integer.valueOf(s); }

color parseRGB (String rgbList) {
  String[] s = rgbList.split(",");
  //println ("parseRGB  --- ",s[0],"  ",s[1],"  ",s[2]);
  return color(Integer.valueOf(s[0]),Integer.valueOf(s[1]),Integer.valueOf(s[2]));  
}

int parseHeading (String s) {   // North East South West
  s.toUpperCase();
  
  int h = 0;
  
  switch (s.charAt(0)) {
    case 'N' : h = 0;  break; 
    case 'E' : h = 1;  break;
    case 'S' : h = 2;  break;
    case 'W' : h = 3;  break;
  }

  return h;
}

int parseLetterInt(String s)  // convert Row letter to number  'A'=1 'B'=2 ... 
{
  return int (s.charAt(0)-'A'+1);  
}


String pstr;
boolean pck(String s) { return pstr.contains(s); }  // shorthand for key value match
 
void decodeParam (String par)         // key value pairs   e.g.  #Scale 1.0 
{
   par = par.substring(1);            // strip off #
   String[] s = par.split("\\s+");    // multiple blanks
   String p    = s[0].toUpperCase();
   String d    = s[1].toUpperCase();   // data 
    
   if (showPathParam) println (String.format("# PARAM %s = %s ",p,d)); 
   
   // string match using shorthand pck function  (p.contains("key"))
   
   pstr = p;
   if (pck("ROWS"))           rows = parseNumInt(d);  
   if (pck("COLS"))           cols = parseNumInt(d);  
   if (pck("GRIDLINEWIDTH"))  gridLineWidth = parseNum(d);   // LineWidth
   if (pck("GRIDCOLOR"))      gridColor = parseRGB(d);
   if (pck("STARTROW"))       curRow = parseLetterInt(d);  // A=1 B=2... 
   if (pck("STARTCOL"))       curCol = parseNumInt(d);
   if (pck("STARTDIR"))       curHeading = parseHeading(d);
   if (pck("BORDERLETTERS"))  borderLettering = parseNumInt(d) == 1;
   if (pck("SCALE"))          dScale = parseNum(d);
   if (pck("TILESIZE"))       tileSize = parseNum(d); 
   if (pck("THINWIDTH"))      widthThin = parseNum(d);
   if (pck("WIDEWIDTH"))      widthWide = parseNum(d); 
   if (pck("NORMALWIDTH"))    widthNormal=parseNum(d);
}
 
 
void pathDecodeInstruction(String s)  
{
  s = s.toUpperCase();
  
  thinLine = false;
  wideLine  = false;
  invertTile = false;
  jogLeftTile = false;
  jogRightTile = false;
  stainTile = 'X';
  cms = "NO Instruction";
  
  String tileCoord = "";
  
   
  while (s.length()>0 && s.charAt(0)==' ') s = s.substring(1); // delete leading whitespace
  if (s.length()==0) return;
  
  if (s.contains(";")) s = s.split(";")[0];   // delete everything after comment ;
  if (s.length()==0) return;
      
  if (s.charAt(0)== '#')
  { // extract tile coordinates -- if just tile coordinate, assume starting tile coordinate being specified 
    decodeParam(s);
    return;
  }  
  
//  pathAddTile(curRow,curCol); // add tile to display list   OLD !!! 
  
  if (showDecode)  
    print ( String.format("[%c%2d] %5s    ",getRowName(curRow),curCol,headingName[curHeading]));  // map row# to letter for display   
     
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
      case '2' :
      case '4' :
      case '6' : 
      case '8' : stainTile = s.charAt(0); break;
      }
      s = s.substring(1);
   }
   s = s.substring(1);   // strip '.'
  }
  
 
  pstr = s; // set for pck function
  if (pck("BEGIN")) 
  { 
    encounteredBegin = true;
    cms = "Encountered BEGIN - end of parameters"; 
  
  }
  else if (pck("START")) tpStartFin();
  else if (pck("FG")) tpGap();              // this test FG done before below F
  else if (pck("F"))  tpForwardWhole();     // short opcode no others can contain F after this test!
  else if (pck("LA")) tpArc('L');     
  else if (pck("RA")) tpArc('R');
  else if (pck("LV")) tpAcute('L');
  else if (pck("RV")) tpAcute('R');
  else if (pck("LT")) tpTurn ('L');
  else if (pck("RT")) tpTurn ('R');
  else if (pck("LS")) tpSCurve('L');
  else if (pck("RS")) tpSCurve('R');
  else if (pck("RN")) tpNotch('R');
  else if (pck("LN")) tpNotch('L');
  else if (pck("G1")) tpGate1();
  else if (pck("END")) stop=true;
  else
  { println ("ERROR  ILLEGAL OPCODE !!!!  >"+s);
    return;
  }

  if (showDecode)
  {
    print (String.format("%8s %24s  ",opCode,cms));
   
    if (invertTile)   print ("invert ");
    if (thinLine)     print ("thin ");
    if (wideLine)     print ("wide ");
    if (jogLeftTile)  print ("jogLeft");
    if (jogRightTile) print ("jogRight");
    println();
  }  

 
 
    
}



void processPathProgramLine(String s)
{
    // println ("processPathProgramLine >>",s);   // verbose normally comment out
  
    if ((s.length()>0))
    {
      // delete everything after ;  (perhaps a bit of a hack with java strings)
      
      if ((s.length()>0) && s.charAt(0)==';') s = "";
      
      if ((s.length()>1) && s.contains(";"))     
      {String[] sa = s.split(";");
       //printArray(sa);  // diagnostic    
       if (sa.length>1) s = sa[0];
       else s="";
      }  
       
      if (s.length()>0) 
      {
       //println ("valid string ----->> ",s);
       pathDecodeInstruction(s);
      } 
      
   }  
  
}
   

void pathProgramReadParameters()
{

   initPathReader();
   initTilePatterns();  // clear tiles visited...
  
   if (showDecode) println ("Load CourseProgram and read #parameter value pairs");
   courseProgram = loadStrings(inputFilename);
   pathDataLine = 1;
   encounteredBegin = false;
   
   while (!encounteredBegin && (pathDataLine< courseProgram.length))
     processPathProgramLine(courseProgram[pathDataLine++ -1]);  // read lines up to and including BEGIN
  
   if (showDecode)
   {
     println("");
     println("------------------------------------------------");
     println("");
   }  
  
  
}

void pathRead()
{
  // iterate over entire tile file for now vs as needed by robot 
  
  if (!svgOutput) dScale = screenScale;
  
  tpGenerateTileGrid();
  
  if (interactiveEdit) return;  
    
  if (showDecode)
  {
    println ("Course Program Instruction Decode  BEGIN END block.");
    println ("Computed Tile coordinates [] and heading direction are listed before each tile command");
    println ("e.g. heading north implies entering tile at south");
    println ("");
  }  
 
  // iterate until END or end of pathDataLine string array
 
  stop = false;
  while (!stop && (pathDataLine< courseProgram.length))
   processPathProgramLine(courseProgram[pathDataLine++ -1]);

}
