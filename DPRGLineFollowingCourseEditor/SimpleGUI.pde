/* A Few Simple GUI Controls to suit application with a few simple needs

   Ron Grant April 6, 2019

   Very Light-Weight GUI Controls  
   
     Buttons   SimpleButton
     TextBox   SimpleTextBox
     
   
   
   
   click test returned on draw (drawPressedCheck)
   
   Example Code 
   
   SimpleButton b1;
   
   void setup () {
     size(500,500);
     b1 = new SimpleButton ("Load",10,50,140,30); // text,xywh
   }
   
   draw() { 
     background(0);
     if (b1.drawPressedCheck())   
        println ("Load Pressed");
   }     
  
*/


color buttonDefaultBGColor      = color(30,30,60);
color buttonDefaultHoverColor   = color(50,50,80);
color buttonDefaultPressedColor = color (255);
color buttonDefaultTextColor    = color (220,220,255);
float buttonDefaultTextSize     = 18;

// consider RectBox for buttons

class RectBox {   // helper box for drawing rectangles (with optional radius corner)  with consultable parameters
                  // not implementing get() set() to keep lightweight for small projects
   
   float x,y,w,h,r;
   
   RectBox(float x, float y, float w, float h, float r)
   { this.x = x; this.y=y; this.w=w; this.h=h; this.r =r; }
   RectBox(float x, float y, float w, float h)
   { this(x,y,w,h,0.0); }
   
   // consider adding methods for centering box in box in x or y... 
   
   float getCenterBoxInBoxX (RectBox rb)
     { return x + (w-rb.w)*0.5; }
         
   void draw()
   { if (r==0.0) gc.rect(x,y,w,h); else gc.rect(x,y,w,h,r);
   }
}  // end RectBox  
   
  


class SimpleButton {
  float x,y,w,h;
  String caption;
  float textH;
  color bgColor;
  color textColor;
  color bgHoverColor;
  color bgPressedColor;
  
  boolean wasPressed;
  
  SimpleButton()
  {
    
    x = 0;    // some default values to be overidden 
    y = 0;
    w = 100;
    h = 50;
    caption   = "Caption";
    
    bgColor   = buttonDefaultBGColor;
    bgHoverColor= buttonDefaultHoverColor;
    bgPressedColor= buttonDefaultPressedColor;
    textColor = buttonDefaultTextColor;
    textH     = buttonDefaultTextSize;
    wasPressed = false;
  }
  
  SimpleButton (String caption, float x, float y, float w, float h)
  {
    this();    // invoke default constructor 
    this.caption = caption;
    
    
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
 
  }
  
  SimpleButton (String caption, float x, float y)
  {
    this();
    float w = 100;  // need calc 
    float h = 20;
    this.caption = caption;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  
  }
    
  void setTextSize  (float textHeight) { this.textH = textHeight; }
  void setX (float x)                  { this.x = x; }
  void setY (float y)                  { this.y = y; }
  
  void centerInRectBoxOnX(RectBox b)  // center button within RectBox in X (horizontal) direction
  {
    x = b.x + (b.w-w)*0.5;  
  }
  
  
  boolean drawPressedCheck()
  {
    boolean pressed = false;
    
    gc.stroke(textColor);
    gc.fill (bgColor);
    
    // If window has focus then focused (Processing function) is true.
    
    
    if ((focused) && (mouseX>x) && (mouseY > y) && (mouseX<x+w) && (mouseY<y+h))
    { 
      gc.fill (bgHoverColor);
      
      if (mousePressed == true)
      { pressed = true;
        gc.fill (255);
      }  
      else pressed = false;
      
    }
    
    gc.rect (x,y,w,h,4);  // xywh, radi
    gc.fill (textColor);
    gc.textSize(textH);
    gc.textAlign(CENTER);
    gc.text (caption,x+w/2,y+textH+3);
   
    boolean clicked = !pressed && wasPressed;
   
    wasPressed = pressed;
    
    return clicked;
       
  }   
    
}




class SimpleLabel {
  float x,y,w,h;
  String caption;
  float textH;
  color bgColor;
  color textColor;
  
  SimpleLabel()
  {
    
    x = 0;    // some default values to be overidden 
    y = 0;
    w = 100;
    h = 50;
    caption   = "Caption";
    
    bgColor   = buttonDefaultBGColor;
    textColor = buttonDefaultTextColor;
    textH     = buttonDefaultTextSize;
  
  }
  
  SimpleLabel(String caption, float x, float y, float w, float h)
  {
    this();    // invoke default constructor 
    this.caption = caption;
       
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
 
  }
    
  void draw()
  {
    
    //gc.stroke(textColor);
    //gc.fill (bgColor);
    //gc.rect (x,y,w,h,4);  // xywh, radi
    
    gc.fill (textColor);
    
    gc.textSize(textH);
    gc.textAlign(LEFT);
    gc.text (caption,x,y+textH+3);
      
  }   
    
}

class SimpleTextBox {
  
  RectBox parentBox;     // optional parent rectangle   null OK
  float x,y,w,h;         // x,y offset within parent (if defined)
  float textH;
  color bgColor;
  color textColor; 
  ArrayList <String> lines = new ArrayList <String>();
  
  SimpleTextBox (float textH, RectBox parentBox, float x, float y, float w, float h  )  // textSize, parent RectBox, offset xy  width,height
  {
    bgColor   = buttonDefaultBGColor;
    textColor = buttonDefaultTextColor;
    //textH     = buttonDefaultTextSize;
    this.textH = textH;
    this.parentBox = parentBox; 
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
   
  }
  
  void addText (String s) { lines.add(s);  }
  void clearText()        { lines.clear(); } 
  
  
  void draw()
  {
    float xorg = 0;
    float yorg = 0;
    if (parentBox != null) { xorg = parentBox.x; yorg = parentBox.y; }
 
    gc.stroke(textColor);
    gc.fill (bgColor);
    gc.rect (xorg+x,yorg+y,w,h,4);  // xywh, radi
    
    gc.fill (textColor);
    gc.textSize(textH);
    gc.textAlign(LEFT);
    float xp = xorg + x + 10;  // +10 left margin
    float yp = yorg + y;
    for (String s: lines)
    {
       if (s.contains("\\")) yp += textH/2+3;
       else
       {
         gc.text (s,xp,yp+textH+3);
         yp += textH+3;
       }  
    }

  }

}

class SimplePopUpDialog {
  
  String caption; 
  float x,y,w,h;         // x,y offset within parent (if defined)
  float textH;
  color bgColor;
  color textColor;  
  boolean visible;
  
  SimplePopUpDialog (float x,float y, float w, float h)
  {
    caption = "";
    bgColor = buttonDefaultBGColor;
    textColor = buttonDefaultTextColor;
    visible = false;
    textH = 16;
    
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
      
  }
  
  void popUp(String s)
  {
    visible = true;
    caption = s;
  }
  
  void drawTestOK()
  {
    if ((mousePressed==true) &&(mouseX>x) && (mouseY > y) && (mouseX<x+w) && (mouseY<y+h))
      visible = false; 
    
    if (!visible) return;
       
    gc.stroke (textColor);
    gc.fill (bgColor); 
    gc.rect (x,y,w,h,8);  // xywh, radi
    gc.fill (textColor);
    gc.textSize(textH);
    
    gc.textAlign(LEFT);
    gc.text (caption,x,y+textH+3); 
    
    gc.textAlign(CENTER);
    gc.text ("click box to close",x+w/2,y+h-textH*2);
    
    
    
  }
  
} // end SimplePopUpDialog 
  
  