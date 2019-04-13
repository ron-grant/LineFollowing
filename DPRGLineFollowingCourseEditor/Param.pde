/*
   parameters for line following course 
   
   


*/


ParamManager par = new ParamManager();

 
char getRowName (int row)     // convert row# to letter 1=A 2=B ... 
  { return char ('A'+row-1); }
 


class ParamManager {    // Parameter Manager  - one instance "par" 
  
  int   cols;
  int   rows;
   
  float widthThin;     // line Widths inches   verify.     
  float widthNormal;
  float widthWide;

  float tileSize;         // Tile Size in inches    
  float dScale;
  color gridColor;        // default light red
  float gridLineWidth;    // default width inches
  int   borderLettering;  // adde 6" border with map style grid coords - like Carl Ott's course rendition 

 
  float svgScale;         // 200 OK for banner print  except  Inkscape says 96 dpi 
                          // but 4x4 tile (48"x48") exported as 9600x9600 units which is correct
                          // at 1.0  need to specify 96x200 = 19200 dpi to get 
                          // 200 dpi output  9600x9600 units




  ParamManager()
  {
    setDefaults();
  }
  
  void setDefaults()
  {
    cols = 0;  //  program will not display tile array until parameters or file loaded ... 
    rows = 0;

    widthThin   = 0.325;   // line Widths inches for patterns      
    widthNormal = 0.75;
    widthWide   = 1.5;
  
    tileSize = 12;                   // Tile Size in inches    
    dScale   = 1.0;
    gridColor = color (255,200,200); // default light red
    gridLineWidth = 0.125;           // default width inches  1/8" inch
    
    borderLettering = 1;
   
    svgScale = 200.0;
    
  }

 

  // parseXXXX below  used by decode Param   for #Parameter Value Pairs before BEGIN

  float parseNum (String s) { return Float.valueOf(s); }
  int   parseNumInt(String s) { return Integer.valueOf(s); }

  color parseRGB (String rgbList) {
    String[] s = rgbList.split(",");
    //println ("parseRGB  --- ",s[0],"  ",s[1],"  ",s[2]);
    return color(Integer.valueOf(s[0]),Integer.valueOf(s[1]),Integer.valueOf(s[2]));   
  }
 
  private String pstr;
  private boolean pckMatch;
  
  private boolean pck(String s) {  // shorthand for key value match
    if  (pstr.equals(s)) pckMatch = true;
    return pstr.equals(s);
  }  
 
  void decodeParam (String pline)      // key value pairs   e.g.  #Scale 1.0 
  {
     if ((pline.length()==0) || (pline.charAt(0) != '#')) return;  // only lines with leading #
     
     pline = pline.substring(1);         // strip off #
     String[] s = pline.split("\\s+");   // split allowing 1 or more spaces between fields
     String p    = s[0].toUpperCase();
     String d    = s[1].toUpperCase();   // data 
      
     print (String.format("# PARAM %s = %s ",p,d)); 
     
     // string match using shorthand pck function  (p.contains("key"))
     
     pstr = p;
     pckMatch = false;
     
     if (pck("ROWS"))           rows = parseNumInt(d);  
     if (pck("COLS"))           cols = parseNumInt(d);  
     if (pck("GRIDLINEWIDTH"))  gridLineWidth = parseNum(d);   // LineWidth
     if (pck("GRIDLINECOLOR"))  gridColor = parseRGB(d);
  
     if (pck("BORDERLETTERS"))  borderLettering = parseNumInt(d);
     if (pck("TILESIZE"))       tileSize = parseNum(d); 
     if (pck("THINWIDTH"))      widthThin = parseNum(d);
     if (pck("WIDEWIDTH"))      widthWide = parseNum(d); 
     if (pck("NORMALWIDTH"))    widthNormal=parseNum(d);
     if (pck("SVGSCALE"))       svgScale =parseNum(d);
     if (pck("SCALE"))          dScale = parseNum(d);
     
     
     if (!pckMatch) print ("  <<< ERROR Parameter Not Recognized - Ignored");
     println();
     
  }
  
  
  void readParameters(String fname)  // load file and read parameters
  {
     this.setDefaults();
      
     println ("load course data file and read #parameter value pairs");
   
     String[] sL =  loadStrings(fname);  // load file into sL
     
     for (String s : sL)
       decodeParam(s);       // read all lines looking for parameters
  }
  
  
  
  
}
  
  
  
   