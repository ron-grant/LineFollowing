/*
; BE SURE TO SAVE THIS FILE AFTER EDIT

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
; END stop program -- handy for debug

#C12         ; starting coordinate (recommended if not specified in program steps)
#C12 SH      ; straight half tile  robot starts in center of tile  
#D12 SW      ; forward
#E12 R.SW    ; jog right forward
#F12 LA      ; left arc 
#F11 LA      ; left arc
#E11 T.SW    ; thin straight 
#D11 AR      ; acute angle special case covers 2x2 tiles 
#E10 I.SW
#F10 I.LA    ; inverted tile left arc 
#F9  LA      ; left arc
#E9  RT
#E8  I.RA
#F8  I.LA    ; inverted left arc
#F7  IT.LA   ; inverted thin left arc
#E7  I.LA    ; 
#E8  I.RA    ;
#D8  I.RA
#D7  RA
RA           ; code gets less commented here -- just started writing commands then checking
I.LA         ; one problem is turns are relative so one wrong turn instruction and everything becomes a mess
RA
I.LT
LA
LA
RA
RA
W.RT
LA
SW
I.NL
SG       ; gap in E2
IW.RT
RT
SW
SL      ; sinewave in 
RA
SW      ;    straight whole
W.NL    ; d4 wide notch left
SW      ; c4
LA
SW
N.SL
I.SW
LA
T.RA
RA     ; c9 right arc
LA   ; bad op code need to fix
LT
LA
RA
RT.LA  ; right jog on left arc thin
LA
T.RA
IT.NL  ; c7 notch left thin (inverted tiles above stain) 
SW
SW
I.SW
IW.RA
LT
SL     ; d2 sine wave
LA
R.LA   ; c1 right arc with jog right
RA
W.RA
LA
T.LT
T.LT
W.RA    ; a2 thick right arc by robot logo
SW      ; b3 stain 
RA
LA
NR     ; a5 notch right
SW
SW
SW
SW
SW     ; a10
SW     ; a2  hack for finish  1/2 col too far   
LA
SW     
END    ; place END anywhere in code to stop - for debug - make sure to save before running
       
*/  // block comment terminator needed for file existing as tab in processing as this code (giant comment)
    // is included in source, but also the Tab is saved as a file PathData.pde which is read by the program
    
