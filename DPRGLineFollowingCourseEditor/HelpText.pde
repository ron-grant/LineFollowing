/*

DPRG Line Following Course Editor - Help

This program provides for interactive production of DPRG Novice,Advanced and Challenge Line Following
Course / course variants. 

It is designed to be run as a Processing sketch. Also, procesing provides the ability to export the sketch
as an application (albeit a large ~180 MB file due to including a snaphot of Java runtime environment
bundled with processing).

Program Usage Steps

Invoke program and press [Load Template] (.LT) file - OR - load an existing course file pressing 
[Load LFT].  Templates are located in the application /data
folder and are named with .LT extension. A template file contains a number of parameters all in text file
format, hence can be imported into a text editor, e.g. notepad++ is recommended. LFT files include parameters 
and tile geometry. See: FileFormats.txt 

Tiles may be dragged from the dictionary which appears at the bottom of the screen. Move mouse onto dictionary
tile until it is highlighted then press and hold left mouse button to keep the tile "in hand", move to the tile
array and release the button to drop the tile on to the array, overwriting any existing tile.

Large patterns like the acute angle and gate occupy multiple tiles. These patterns when placed may require
clearing adjacent tiles to make room for the large pattern. Invert is not supported for these tiles.

Tile properties may be modified using single key stroke commands while holding a tile OR while hovering over
a time in the array (with mouse button not pressed). The key summary appears on the screen.

C - Clear Tile
I - Invert Toggle 
J - Jog Left Right None
M - Mirror Tile Toggle
R - Rotate Tile 90 Degrees
W - Width  Thin / Thick / Normal

2 - 20% Stain Background              Note once stain or logo applied, remove by dragging new tile over
4 - 40% Stain Background              or clearing tile to remove all geometry.
6 - 60% Stain Background
8 - 80% Stain Background
L - Logo Display 

Vert Arrows - display scale up/dn

B - Border Coordinates on/off Toggle  This setting affects how tile array appears on screen and also
                                      how it appears when exported. 


Tiles in array may be dragged to new location. Move mouse over tile, press and hold mouse move to 
new location and drop. Also, pressing and holding then clicking and holding left mouse button down
makes a copy of the tile vs clearing the tile.


After editing tile array press [Save LFT] to bring up save dialog. Filename must have .LFT extension OR
no extension, in which case it is added by the program.

Press [Generate SVG] to generate a SVG (Scalable Vector Format) file suitable for a drawing program
like inkscape. See notes on SVG scaling below.

[Clear All], clears the tile array. Warning: No undo or warning prompt.


HEADER PARAMETERS 
Template File (.LT file) contains just the following parmeter value pairs
The .LFT Data file includes these parameters and tile geometry

Example Data                            Description

#Rows 6                      Tile Array Rows (lettered when BorderLetters 1)
#Cols 12                     Tile Array Columns
#GridLineWidth 0.1250        Tile Border Line Width in inches (or svg units if SVGScale = 1.0)
#GridLineColor 255,200,200   RGB color of grid  0..255 range on each channel. The example here 
                             creates a faded pastel red vs. 255,0,0 which would be saturated Red
                                        
#BorderLetters 0             0=No Map Border Letters (Map Coordinate Labels)  1=Show Border Letters
                             (increases array by 1 col, 1 row) 
#Scale 1.0000                output scale usually 1.0  number like 0.98 can be used to scale tiles down just
                             a bit to allow creating a course without BorderLetters
                             
#TileSize 12.0000            tile size in inches typically 12.0
#ThinWidth 0.3750            thin line width in inches  (W key pressed repetitively changes line width on tile)
#WideWidth 1.5000            fat line width in inches 
#NormalWidth 0.7500          default line width
#SVGScale 1.0000             output SVGScale 

Note on SVGScale: Inkscape (for one example) recognizes SVG data output by this program as pixel units.
That is, at 1.00 a 3x3 12" tile array is output as a drawing that is 36x36 pixel units.
Applying a scale factor of desired resolution e.g. 200.0 for banner production appears to be the most
helpful when attempting to export a PNG raster file from Inkscape.

Two example parameter configurations for export to Inkscape (other than Rows,Cols...)

Example to produce banner without map coordinate edges

#scale 0.98
#SVGScale 200.0     desired output DPI
#BorderLetters 0

Export PNG accepting default 96 dpi 
For example a 5 x 5 tile course with each tile 12" would be 60" x 60"
At SVGScale 200.0, output is (60x200) x (60x200) = 12000 x 12000 pixels.

#scale 1.0
#SVGScale 200.0
#BorderLetters 1

5x5 tile course would become 6x6 due to border lettering (1/2 tile expansion along each border)
Output 6x6 tiles  72" x 72"
At SVGScale 200.0  output is (72x200) x (72x200) = 14400 x 14400 pixels.

Of course, handy to use windows Preview to look at exported PNG.
Also handy to right click on the .PNG file and look at details to make sure scaled properly.





*/