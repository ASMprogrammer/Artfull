;;;Copyright 2023 by Z8AP

;;THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY  IMPLIED OR EXPRESS 
;;;WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF 
;;;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
;;;THE ABOVE APPLIES TO THE GAME SOURCE CODE OR THE GAME ROM
;;;;;;---------------------------------------------------------------------

;;;To add more images need to change UPPERLIMITNOARTWORKS EQU 15 to a number greater than 15
;;;;UPPERLIMITNOARTWORKS is changed 31,127 or 255 
;;;add artfullimage images after artfullimage8Bend  (at end of code) sonew artfullimage images will start end end with the labels
;;;artfullimage9A  ,  artfullimage9Bend  using the naming conventions
;;;artfullimage images are odding in pairs-for example if UPPERLIMITNOARTWORKS is chaned to 31 then 16 pains(32 images are added)
;;;the new artfullimage images may be added to end of rom code is a similar way to existing images
;;;add the answers to each image to draw over under the
;;;artworkanswers:
 
;;add the answers for the  artfullimage, as 31 character answer starting with code letter described under
;; artworkanswers:  and ending in 255
;;; M.D. is used as an abbrevition for MergeDraw in comments
;;;HH is used as an abbreviation for Hedgehog

;;It is summarised here an interesting parts of how the source ;;code/MergeDraw interpreter works.
;;the Mergedrawprogram is stored starting at &c900 Each all the Mergedraw instructions,except PENUP,  fits into
;;exactly one byte: the first three most significant bits of the byte encode the instruction, the last 5 bits of the byte 
;;encode the operand value of the instruction. Since there are 8 
;;bits there are 256 possibilities for MergeDraw instructions but actually less than 200 are used for 
;;actual MergeDraw instructions. An empty space for the instruction is encoded as a value that isnt any 
;;instruction (&08). A copy (in RAM) of the MergeDraw program is (starting at &CB90) made with the new 
;;instruction entered, this copy is checked for correctness for MergeDraws syntax rules-a repeat loop 
;;takes a lot of syntax checking. To check for loop syntax the copy of the MergeDraw program is copied again 
;;(i.e. a copy of  a copy (starting at &CA40) with all but the loop commands-the non loop commands are filtered out.
;;This copy of a copy is then expressed in a canonical form which results in a block of consecutive bytes, in 
;;the filtered copy of a copy,that have known patterns in some consecutive sub-block of bytes in the above immediately
;;described filtered block above if there is an error of some type for a MergeDraw loop command.
;;If there is an error in a MergeDrawloop the player is notified to correct it. If there are no syntax 
;;errors in the copy of the MergeDraw  program the copy writes over the actual MergeDraw program that is actually used
;;(in RAM). This all works because the Master System has enough built in RAM. For more technical details see the Z80 ASM 
;;source code, which has meaningful names. comments and  description of how source code words (at start of source  code) 
;;There is also a lot of other detail describes the interpreter.


UPPERLIMITNOARTWORKS EQU 15
MENUCHOICEGAMESTARTANDDRAWOVEREXISTING EQU 0
MENUCHOICEDRAWYOUDRAWEVERYTHING EQU 1
MENUINSTRUCTIONHWOTOPLAY EQU 2
MENUPROGLANGUAGE EQU 3
MENUINKCOLOUR EQU 4
MENUCREDITS EQU 5

P1TURN EQU &D840
P2TURN EQU &D841
P1SCORE EQU &D842
P2SCORE EQU &D843  
GAMEEND EQU &D844
NOOFPOINTPLAYEDSOFARINONEGAME EQU &D84C
MENUCOUNTERCHOICE EQU &D84D
MENUCOUNTERCHOICEASROUNDEDINTEGER EQU &D84E;;;converting the counter above into menu choice
CHOOSEDOALLTHEDRAWINGONLY EQU &D84F;;;FLAG this is for the drawing only game mode
CHOOSEPROGRAMMINGLANGFLAG EQU &D850
CHOOSEINKFLAG EQU &D851;;;0 is solid color 1 is multicoloured
INKCOUNTERPARITYCOLOUR EQU &D852;;;;use to oscillate between ink colours
DRAWWASSHOWN EQU &D855


REVEALANSWERFORPLAYERTOMEMORISE EQU &D845
LONGPRESS2TOENTERANSCOUNTER EQU &D846
DISABLEKEYSTOINITIALISE EQU &D847
NOTPASSEDTHROUGHMAINLOOPONCE equ &d848
LONGPRESS2TOEXITPROGMODEONLY EQU &D849
POINTSTOINGAME EQU 2;;2 point each maximum per game per player
LONGPRESS2TOENTERANSCOUNTERPROGMODE EQU &D856
TOGGLEGRIDONOROFF EQU &D857
LONGPRESSCOUNTERGRIDTOGGLE EQU &D858
GAMESTARTOVEFLAGINGAMEMODE EQU &D85E
P2TOP1MESSAGECORRECT EQU &D85F;;;for correct the first message p1 to p2 in draw over images

LENGTHOFTEXTATTOPANDBOTTOMADJACENTARTFULLIMAGE EQU 18
POSBCINIT EQU 50
SHIFTCONSTFORCHARSET EQU 272-256

MENUARROWPOINTSPRITE EQU 5
VDPcontrolport equ &BF
VDPdataport    equ &BE

PLAYERACROSSPOS EQU 40
TheNextCharacterX equ &C000
TheNextCharacterY equ &C001


seed2 equ &C002;;TW BYTES RNG SEED



VARTHEHHCURSORPOS EQU &C006
VARPLAYERPOSY EQU &C005


endofchar equ &C015


seed equ &C030

VARSONGCHOICEENCODEDASPOS EQU &c036


TOGGLEHHmetaspriteONOROFF EQU &c039
HHTITLEACROSSPOS EQU &C03A;;; tite screen  hh meta spritw 
HHTITLEVERTICALPOS EQU &C03C;;; tite screen  hh meta sprite 
HHTITLEACROSSSPEED EQU &C03B;;; tite screen  hh meta sprite 
HHTITLEVERTICALMOVEMENTFLAG EQU &C03D
HHDRAWINGBOTHPARTOFLFLAG EQU &C03E
HHDRAWINGFULLCUPFLAG EQU &C03F

;;;used for canvas
VPOKETHIS EQU &C040;
XPOSLOOPTILES2SCR EQU &C041
YPOSLOOPTILES2SCR EQU &C042
XPOSINPIXELS EQU &C044
XPOSINPIXELSI8 EQU &C045;;the integer part of x in pixels divide by 8
XPOSINPIXELSF8 EQU &C046;;the remainder part of x in pixels divide by 8
YPOSINPIXELS EQU &C047
YPOSINPIXELSI8 EQU &C048;;the integer part of x in pixels divide by 8
YPOSINPIXELSF8 EQU &C049;;the remainder part of x in pixels divide by 8
READ4TIMESTOADDLOWBYTE EQU &C04A;;for the vdp sent to vdp
READ4TIMESTOADDHUGHBYTE EQU &C04B
;;;screen buffer adres is simple abve adres divideb by 4 so it takes 1920 bytes
;;;becuase it a monpochrome there is less info to store compared to colour
SCREENBUFFERLOWBYTE EQU &C04C;;;
SCREENBUFFERHIGHBYTE EQU &C04D
SCREENBUFFERBYTE EQU &C04E;;;byte that is include and written to ram concerning a particular pixel bitored with this 
SCREENBUFFER EQU &C100
LINELENGTH EQU &C050;;;byte that is include and written to ram concerning a particular puxel bitored with this 
LINEDIRECTION EQU &C051
;;used for locating byte in canvas
;;;;between c100 and c900 is VRAM  in ram buffer
PENDOWNFLAG EQU &cADB
THECOLOURBYTE1 EQU &CC50;;master system uses 4 bytes to define colour for a group of 8 pixels 
THECOLOURBYTE2 EQU &CC51
THECOLOURBYTE3 EQU &CC52
THECOLOURBYTE4 EQU &CC53

ARTFULLIMAGEBASEADDRESSHIGHBYTE EQU &CC54
ARTFULLIMAGEBASEADDRESSLOWBYTE  EQU &CC55

MOVEGARBAGECOUNTER EQU &CC57
JUSTEXITEDPROGLANGMODE EQU &CC58
DELAYCOUNTERFORINKCHOCEMENU EQU &CC59
ONETIMEFLAGTOINVERTCOLOURMENUCHOICE  EQU &CC60

;;;;;;;;;;;;;;;;;;;;;;;;;;for the MergeDraw interpreter start at c900 since before c900 is its VRAM for overlay image
MergeDrawPROGRAMRAMTOP EQU &C900;;;start of M.D. Program
MergeDrawPCCOUNTER EQU &C981;;;MergeDraw program counter
COMMANDVALUEVAR EQU &C982
CURRENTCCONSTRUCTEDCOMMAND EQU &C983
MergeDrawPCCOUNTERFOREXECUTING EQU &C988;;;use a different program counter to users for running through program
MergeDrawLOOPSTARTPOSITION EQU &C989
MergeDrawLOOPVALUE EQU &C98A
MergeDrawLOOPDETECTED EQU &C98B
MergeDrawLOOPDETECTEDFLAG EQU &C98C
CIRCLEPTRCOUNTER EQU &C98D
CIRCLEDIAMETERCHOICE EQU &C990
CURRENTMergeDrawPAGESHOWINGINGGUI EQU &C99F
ENDVALUEOFMergeDrawPCCOUNTERFORGUI EQU &C99E
INSTRUCTIONMergeDrawPCCOUNTERFORERRORCHECK EQU &C9A0
PAGECHOSENTOBEVIEWEDINGUICOUNTER EQU &C9A1;;;for pressing right to view some page in gui

LASTCOMMANDISREPEATFLAG EQU &CAD8
ISBLANKARTFULLIMAGETOLOADFLAG EQU &CAD9
ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT EQU &CEE0
ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY EQU &CEE1 
ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY2 EQU &CEE3
LONGPRESSCOUNTERSTARTOVER EQU &CEE4

;;;;;;printing numbers routine
PRINTNUMBERXPOS EQU &C995
PRINTNUMBERYPOS EQU &C996
DIGIT1 EQU &C997
DIGIT2 EQU &C998
DIGIT3 EQU &C999
NUMTODISPLAY EQU &C99A

CORRECTCURSORIFSEMICIRCLEDRAWN EQU &CC9B;;;;this is reuired beciuase semi circle is drawn as circle by using penup for half of it

;;;;;;;;;;;;;;;;;;;;;;;;;;;;USE 3 of 4 bits 16 poisiibe commanda
CIRCLECOMMAND EQU 0
PENDOWNCOMMAND EQU 1
DRAWUPCOMMAND EQU 2
DRAWDOWNCOMMAND EQU 3
DRAWLEFTCOMMAND EQU 4
DRAWRIGHTCOMMAND EQU 7
REPEATCOMMAND EQU 6
ENDREPEATCOMMAND EQU 5
PENDOWNFALSE EQU 0
PENDOWNTRUE EQU 1
EMPTYMEMORYFORCMD EQU &08;;;%11101110 all 63 bytes of Mergedraw program are intially empty at this value 08 


  

  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    macro writetext,xpos , ypos , messagelabel
        ld b,\xpos
        ld c,\ypos
       ld hl,\messagelabel
         call Writetoscreenstringsub
    endm

    macro textloadHL,xpos , ypos
        ld b,\xpos
        ld c,\ypos
         call Writetoscreenstringsub
    endm



  


   macro STORESONGPOSASCHOICEVAR,thevalue
	ld hl,VARSONGCHOICEENCODEDASPOS;;;the position in the single song/music incbin encode different songs
	ld a,\thevalue;
	ld (HL),a 
    endm;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
;;;;------------------------------------------------------------------------------


    macro TimeDelay,delayvalue
        push de
        push hl
        push af
        push bc
 	ld b,10;  use registers a and b to give a delay built out of a double loop b=1 gives shortest delay
 	ld b,\delayvalue;b cant be zero since b=1 is smallest value
 	ld a,255;a can take any value between 1 and 255 here
\@delayinnersub:
	dec a;
 	jr nz,\@delayinnersub;
 	dec b;
 	ld a,b;
 	jr nz,\@delayinnersub;
        pop bc
        pop af
        pop hl
        pop de
  endm
 

      macro ReadPLAYERPOSYVAR,dummy1
	push  hl
	ld hl,VARPLAYERPOSY;
	ld a,(HL);
       pop hl
      endm;    

   macro StoreHHCURSORPOSYVAR,thevalue
       push de
       push hl
	ld hl,VARPLAYERPOSY;
	ld a,\thevalue;
	ld (HL),a;stores the value in the memory
          ld d,a
        sub 163;;;to HH cursor wrap properly from top to bottom
        jp c,\@restoreitY
        add a,24
        ld (HL),a
\@restoreitY:
        
	pop hl
        pop de
     endm;

    macro ReadHHCURSORPOSXVAR,dummy1
	push  hl
	ld hl,VARTHEHHCURSORPOS;
	ld a,(HL);
       pop hl
      endm;    


     macro StoreHHCURSORPOSXVAR,thevalue
       push de
       push hl
	ld hl,VARTHEHHCURSORPOS;
	ld a,\thevalue;
	ld (HL),a;
 ld d,a
        sub 163;;  
        jp c,\@restoreitX
        add a,24
        ld (HL),a
\@restoreitX:
        
	pop hl
        pop de
     endm;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 



  macro DefineTheTiles,endofGRAuncomopresses , endMINUSstartbytes , intotilenumberstart
 
    nop
   nop
  nop
  push iy
  pop iy
     ld hl,\intotilenumberstart
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL
    ADD HL,HL
    ld d,h
     ld e,l;;;computed de*32 via add hl,hl
  ld hl,\endofGRAuncomopresses; the tiles data here is shared with the sprites
  ld bc,\endMINUSstartbytes
  call TilestoVideoRAM
 endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

	org &0000
	jp BeginningofProgram	 
	ds 5,&C9			 
	ds 8,&C9			 
	ds 8,&C9			 
	ds 8,&C9			 
	ds 8,&C9			 
	ds 8,&C9			 
	ds 8,&C9			 
	jp Interrupthandler		
	ds 35,&C9			
	ds 26,&C9			
		
Interrupthandler:
  exx
  ex af,af'
 
   call domusicsubroutine
   
Interrupthandlerdone:
  in a,(VDPcontrolport)
  ex af,af'
  exx
  ei
  ret
 
BeginningofProgram:


     di      			
    im 1    			;mode 1 interrupts
    ld sp, &dff0
											

  ;;;initialise vars for menu on game on start up


  call resetmenubacktofirstoption
  ld hl,GAMESTARTOVEFLAGINGAMEMODE
    ld a,0
  ld (hl),a

  ld hl,P2TOP1MESSAGECORRECT
      ld a,0
  ld (hl),a
   
  ld hl,DELAYCOUNTERFORINKCHOCEMENU 
  ld a,0
  ld (hl),a

  ld hl,ONETIMEFLAGTOINVERTCOLOURMENUCHOICE
    ld a,1
  ld (hl),a

     ld hl,HHDRAWINGBOTHPARTOFLFLAG
     ld a,1;;
   ld (hl),a

       ld hl,HHDRAWINGFULLCUPFLAG
     ld a,0;;
   ld (hl),a

   

    ld hl,CHOOSEINKFLAG
  ld a,0
  ld (hl),a

     ld hl,HHTITLEVERTICALMOVEMENTFLAG
     ld a,0
   ld (hl),a

  ld hl,JUSTEXITEDPROGLANGMODE
       ld a,0
   ld (hl),a

  ld hl,HHTITLEVERTICALPOS
     ld a,0
   ld (hl),a


  ld hl,NOTPASSEDTHROUGHMAINLOOPONCE
   ld a,0
   ld (hl),a



  LD HL,TOGGLEGRIDONOROFF	
  ld a,0;;;TUrN OFF GRID A START it CAN BE TURNED ON programming ONLY MDOE
  ld (hl),a
  call showgridifchosen

  ld e,1
  STORESONGPOSASCHOICEVAR e
 


   ld hl,DISABLEKEYSTOINITIALISE
   ld a,1
   ld (hl),a

masterresetpoint:

  ld hl,P1SCORE;;; 
 ld a,0
 ld (hl),a
 ld hl,P2SCORE;;; 
 ld a,0
 ld (hl),a
 ld hl,P1TURN
 ld a,1
 ld (hl),a
 ld hl,P2TURN;;;not used
 ld a,0
 ld (hl),a
testpointresset:
 LD HL,NOOFPOINTPLAYEDSOFARINONEGAME 
 LD A,0
 LD (HL),a

 ld hl,GAMEEND
 ld a,1
 ld (hl),a
 ld hl,REVEALANSWERFORPLAYERTOMEMORISE
 ld a,0
 ld (hl),a

  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,0;;;assume it is not blank artfullimage to load
  ld (HL),a

  ld hl,LONGPRESSCOUNTERSTARTOVER
  ld a,0
  ld (HL),a


  ld hl,MergeDrawPCCOUNTERFOREXECUTING
  ld a,0
  ld (hl),a

  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
  ld (hl),a


    ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,0
   ld (hl),a


   ld hl,PENDOWNFLAG 
 ld a,1
 ld (hl),a


       ld hl,endofchar
   ld (hl),255
  ld hl,seed2
  ld (hl),43	

   call setSOUNDvolume
	ld hl,VdpInitData	 
    ld b,VDPinitialiseDataEnd-VdpInitData		 
    ld c,VDPcontrolport		 
        nop
		  nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    otir				 
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
 nop				 

    

	
    ld hl, &c000	    ;;;CRAM palette base addreess
    call SetupVRAM

    ld hl,Dataofpalette	 

		ld b,32		 

	ld c,VDPdataport		 
	    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    nop
 nop
    otir				 
 nop
 nop
 nop
 nop
 nop
   nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop				 
	
 
   


 													
  


waitfordown:
    
  



     ld hl, &c000	     
    call SetupVRAM

    ld hl,Dataofpalette 

		ld b,32		 

	ld c,VDPdataport		 
 
    otir				 
    call clearspritesoffscreen
 
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
  
 
  
  


  DefineTheTiles HHcursortiles,HHcursortilesend-HHcursortiles,9
    DefineTheTiles Twocharsnums,Twocharsnumsend-Twocharsnums,7
   DefineTheTiles menuTSarrow,menuTSarrowend-menuTSarrow,5
  DefineTheTiles Gridcrosspoint,Gridcrosspointend-Gridcrosspoint,14
   DefineTheTiles thefont,thefontend-thefont,288
    DefineTheTiles Viewingpageimage2,Viewingpageimage2end-Viewingpageimage2,391
    DefineTheTiles Viewingpageimage3,Viewingpageimage3end-Viewingpageimage3,398
    DefineTheTiles Twocharsemiword,Twocharsemiwordend-Twocharsemiword,337;;;needs to be below 25 for it to print
   DefineTheTiles CRCchar,CRCcharend-CRCchar,290;as CRC as ?
   DefineTheTiles TwocharUPEQUDOWNEQU,TwocharUPEQUDOWNEQUend-TwocharUPEQUDOWNEQU,339;
    DefineTheTiles Threecharscoreword,Threecharscorewordend-Threecharscoreword,341;
   DefineTheTiles frame,frameend-frame,344;
   DefineTheTiles arrowspagedivider,arrowspagedividerend-arrowspagedivider,350;the long red arrow that divides the screen
 DefineTheTiles Keysbanner1,Keysbanner1end-Keysbanner1,354;;
 DefineTheTiles Keysbanner2,Keysbanner2end-Keysbanner2,405;;;
  DefineTheTiles Keysbanner3,Keysbanner3end-Keysbanner3,428;;
    DefineTheTiles rightarrow,rightarrowend-rightarrow,439
   DefineTheTiles Keygridtoggle,Keygridtoggleend-Keygridtoggle,376
  DefineTheTiles Viewingpageimage1,Viewingpageimage1end-Viewingpageimage1,441
     DefineTheTiles Teapottitle,Teapottitleend-Teapottitle,355
  DefineTheTiles Charsayin1char,Charsayin1charend-Charsayin1char,440;
    DefineTheTiles CharsPLin1char,CharsPLin1charend-CharsPLin1char,427;
   DefineTheTiles Ahumangame,Ahumangameend-Ahumangame,404
 
 
   

  
       ld hl, &c000	 
    call SetupVRAM

    ld hl,Dataofpalette	 

		ld b,32		 

	ld c,VDPdataport		 
 
    otir				 
 


  



 
 ld b,28
blankscreeny:
 ld c,b
 push bc
 ld b,32
blankscreenx:
  push bc  
  dec b
  dec c 
  call drawaspacetileatbc
  pop bc
  djnz blankscreenx
  pop bc
  djnz blankscreeny


 



   call clearspritesoffscreen
   call setupsprites
   call initialiseplayerpos
   
   jp continuetostartofgameinit

 
  
 


Emptymessage: db 255,255
 
cursorlabel: db 'CURSR',255
draw0: db '0',255
draw1: db '1',255
Drawpendownlabel: db 'PEN',255
DrawpendownDOWNlabel: db 'UP   ',255 
DrawpendownUPlabel: db 'DOWN    ',255
Drawuplabel:        db 'UP     ',255
Drawdownlabel:      db 'DOWN   ',255
Drawleftlabel:      db 'LEFT   ',255
Drawrightlabel:     db 'RIGHT  ',255
Drawrepeatlabel:    db 'REPEAT   ',255
Drawrepeatendlabel: db 'END REPEAT  ',255
Circlelabel:        db 'CIRCLE  ',255
Emptylabel:         db 'EMPTY      ',255 
Circlelabelsemi: db 'xzCIRCLE',255;;xz encodes SEMI in 2 chars
Blanklabelforintterpretermessages:  db '                   ',255

genericmessage1: db  'YOU NEED TO DRAW ALL THE IMAGE      ',255 
genericmessage52: db  '  START DRAWING                     ',255 
genericmessage1b: db  '                                   ',255 

genericmessage2: db 'NESTING ERROR     ',255 
genericmessage3: db 'NO START ENDREPEAT',255 
genericmessage4: db 'USELESS ENDREPEAT ',255 
genericmessage5: db 'PENDOWN FOR CIRCLE',255 
genericmessage6: db ' ENTERING ANSWER  ',255 

genericmessage11:  db 'P1 WON  GAME                        ',255 
genericmessage12: db  'P2 WON  GAME                        ',255 
genericmessage13:  db 'DRAW GAME                           ',255 

genericmessage15: db 'EXIT  SCREEN         ',255 
                    
genericmessage7: db 'CANT USE REPEAT ab',255 
genericmessage8: db 'ANSWER ENTERED BY P1',255 
genericmessage9: db 'P2 TELL P1 YOUR ANSWER              ',255 
genericmessage10:db 'P1 IS P2 ANSWER CORRECT?uYES OR dNO',255


genericmessage8p2: db 'ANSWER ENTERED BY P2',255 
genericmessage9p2: db 'P1 TELL P2 YOUR ANSWER              ',255 
genericmessage10p2:db 'P2 IS P1 ANSWER CORRECT?uYES OR dNO',255
genericmessage30: Db '                    CLEARED          ', 255

genericmessage5b: db 'PENDOWN FOR xztqvw',255;;;tqvw encode circle (in semicircle) in 4 chars so it fits in message windows and doesnt collide wiith a poissible instruction

blankline : db '                                ',255

authorinfo:  db '?2023 Z8AP',255

menuchoice1: db 'GAME WITH DRAW OVER IMAGES      ',255 
menuchoice2: db 'GAME WITH YOU DRAW ALL          ',255 
menuchoice3: db 'INSTRUCTIONS HOW TO PLAY        ',255 
menuchoice4: db 'MERGEDRAW PROGRAMMING LANGUAGE  ',255 
menuchoice7: db 'USE SOLID INK COLOUR            ',255 
menuchoice6: db 'CREDITS AND GAME INFORMATION    ',255 
menuchoice5: db 'USE MULITCOLOUR INK             ',255 
 
ingamemessage1P1:db  'P1 PRESS 1 TO CHOOSE OR 2 FOR ACCEPT',255
ingamemessage2P1:db  ' P2 LOOK AWAY P1 PRESS TO SEE ANSWER',255
ingamemessage3P1:db  'P1 MEMORISE ANSWER AT BOTTOM PRESS 2',255
ingamemessage4P1:db  ' P2 NOW LOOK TO pl                  ',255

ingamemessage1P2:db  'P2 PRESS 1 TO CHOOSE OR 2 FOR ACCEPT',255
ingamemessage2P2:db  ' P1 LOOK AWAY P2 PRESS TO SEE ANSWER',255
ingamemessage3P2:db  'P2 MEMORISE ANSWER AT BOTTOM PRESS 2',255
ingamemessage4P2:db  ' P1 NOW LOOK TO pl                  ',255;;;pl=(PL)(AY)
ingamemgifendedL:db  'PRESS BUTTON TO CONTINUE'            ,255
scorelabelMergeDraw1:  db ' ',255
scorelabelMergeDraw2:  db 'scoPONE   .PTWO',255;;;sco=SCORE as 3 chars
generalMSGblankline:  db '                  ',255

Circlein4chars:
    incbin "E:\Artfullgraphics\CIRCLEWORD32PIXELWIDE.GRA"
Circlein4charsend:

Nowin2chars:
    incbin "E:\Artfullgraphics\NOWWORD16PIXELWIDE.GRA"
Nowin2charsend:

 
drawaspacetileatbc:
  
     ld hl,&0101;;
     ld d,0
     ld e,18 
     call TilesToVRAM
   ret

 

Writetoscreenstringsub:
  push hl
  push bc
  push de
  push af
 
Writetoscreenstring:

    ld a,(HL);letter          
  cp 255
  jp z,finishedstring
  cp '%';;;;% is an alternate end of line char instead of 255 that newlines every 16 chars so it can diplay a 32 char message in the neatly above the canvas GUI
  jp z,finishedstring
   push bc
   push hl
    
    call putcharbcxysub
   pop hl
   pop bc
   inc hl
   inc b;move across for NOT incresing C AFTER B>32 

  jp Writetoscreenstring
finishedstring:
 pop af
 pop de
 pop bc
 pop hl
 ret   
 
putcharbcxysub:
      ;;;the char set is defined from tile 288
      cp '0'
      jp z,load0
      cp '1'
      jp z,load1
      cp '2'
      jp z,load2
      cp '3'
      jp z,load3
      cp '4'
      jp z,load4
      cp '5'
      jp z,load5
      cp '6'
      jp z,load6
      cp '7'
      jp z,load7
      cp '8'
      jp z,load8
      cp '9'
      jp z,load9
      cp ' '
      jp z,loadspace
      cp '.'
      jp z,loadfullstop
      cp ':'
      jp z,loadcolon
      jp processAtoZ

load0:
    ld a,SHIFTCONSTFORCHARSET+64-15
   jp finishedloadingnotAtoZ
load1:
    ld a,SHIFTCONSTFORCHARSET+64-14
   jp finishedloadingnotAtoZ
load2:
    ld a,SHIFTCONSTFORCHARSET+64-13
   jp finishedloadingnotAtoZ
load3:
    ld a,SHIFTCONSTFORCHARSET+64-12
   jp finishedloadingnotAtoZ
load4:
    ld a,SHIFTCONSTFORCHARSET+64-11
   jp finishedloadingnotAtoZ
load5:
    ld a,SHIFTCONSTFORCHARSET+64-10
   jp finishedloadingnotAtoZ
load6:
    ld a,SHIFTCONSTFORCHARSET+64-9
   jp finishedloadingnotAtoZ
load7:
    ld a,SHIFTCONSTFORCHARSET+64-8
   jp finishedloadingnotAtoZ
load8:
    ld a,SHIFTCONSTFORCHARSET+64-5
   jp finishedloadingnotAtoZ
load9:
    ld a,SHIFTCONSTFORCHARSET+64-4
   jp finishedloadingnotAtoZ
loadspace:
    ld a,SHIFTCONSTFORCHARSET+19
   jp finishedloadingnotAtoZ
loadfullstop:
   
    ld a,333-256 
   jp finishedloadingnotAtoZ
loadcolon:
 
    ld a,288-256 
   jp finishedloadingnotAtoZ
processAtoZ:
     ld d,0;
      ld e,SHIFTCONSTFORCHARSET+20
    add a,e
    sub 65
finishedloadingnotAtoZ:
    ld e,a
    ld d,1
 
    ld hl,&0101 

    call TilesToVRAM  
    ret



 

  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;main  loop

continuetostartofgameinit:
    
   call moveHHcursorfordrawing; fixes player's corrupted sprites initaillly smultes a key press
      
   call setSOUNDvolume
  ei
mainloop: 
  di     



 

 
  call clearmostbutnotallofthescreen
  call clearscreenbuffer
  call clearMergeDrawprogramtoNONEcommands

  ld hl,PENDOWNFLAG 
   ld a,1
   ld (hl),a

  ld hl,MergeDrawPCCOUNTER  
  ld a,0
  ld (hl),a;;;set MergeDraw pc to zero

;;;work for placing canvas
CANVASXPOS EQU 2
CANVASYPOS EQU 4
  ld hl,XPOSLOOPTILES2SCR
  ld a,CANVASXPOS
  ld (hl),a
  ld hl,YPOSLOOPTILES2SCR
  ld a,CANVASYPOS
  ld (hl),a


  call drawcanvastoscreen


 
 

 

 
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 





 
drawaline:

 
PENPOINTX EQU &C052
PENPOINTY EQU &C053

 
 ld b,50;;;initialise HH or pen coordinates
 ld c,50

  
 

   
VPOKESTRINGPOSINSTRING EQU &CD00
VPOKEMESSAGEADDRESSLOWBYTE EQU &CD01
VPOKEMESSAGEADDRESSHIGHBYTE EQU &CD02


;;;vars for rendering Mergedraw program listing in GUI

MergeDrawPCCOUNTERFORGUI EQU &CC9B
EXTRACTEDCOMMANDGUI EQU &CC9C
EXTRACTEDVALUECOMMANDGUI EQU &CC9B
CURSORPOSITIONINPAGE EQU &CC9C;;;this is from 2 to 24 max;35 across in hex this is y pos
PAGENUMBERONSCREEN EQU &CC9D
VPOKESTRINGXPOS EQU &CC9E
VPOKESTRINGYPOS EQU &CC9F

 
 push hl
 ld hl,CURSORPOSITIONINPAGE
 ld a,8
 ld (hl),a;;init

 ld hl,MergeDrawPCCOUNTERFORGUI
 ld a,0
 ld (hl),a;;init

 ld hl,PAGENUMBERONSCREEN;;;this is changed sets MergeDrawPCCOUNTERFORGUI to 0 2
 ld a,0
 ld (hl),a;;init to zero
 pop hl

 
 ;;;least COMMANDVALUE=CCCCCVVV for a MergeDraw command
 ;;;for the page numr or for every commany enterd it simply includerew a block

;;;enter next istruction

INSTRUCTIONCHOICE EQU &CD03
INSTRUCTIONVALUE EQU &CD04
INSTRUCTIONPOINTER EQU &CD05 
INSTRUCTIONVALUEFOROUNDING EQU &CD06;;;used for command
INSTRUCTIONVALUEFOROUNDING2 EQU &CD07;;;used for value
INSTRUCTIONCURRENTLYCONSTRUCTED EQU &CD08

 ld a,%101;;;;draw right;;;in GUI NOT SHIFTED As it starts with a non shifted value counter
 ld (hl),a
 ld hl,INSTRUCTIONCHOICE
 ld a,%00010001;;;17
 ld (hl),a
  ld hl,INSTRUCTIONVALUE
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONVALUEFOROUNDING
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONPOINTER

;;;;;;;;;;;;;;;;;;  sets xy for command to enter;;;;;;;;;;;;;;;;;;;;;;;;;;;
MergeDrawPCCOUNTERFORGUIconstant EQU &C993;;;stops it scrolling down  

CMDTOENTERXPOS EQU 2
  push hl
  push af
 ld hl,MergeDrawPCCOUNTERFORGUIconstant
 ld a,1;;;the yppos
 ld (hl),a
  pop af
  pop hl
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;begin 48k paging code;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rompagealt EQU &FFFF;;;use for paging in image
loadimagehighpagespast64:
 
 
  
      
loadartfullimageorblankartfullimagewithcorrespondingMSG:
;;;;3 to 14 is are pictures proply load  by vasm 15  
;;;for finisheing make rng between 3 to 14 inclusinve and use dummy for 15 which is draw it all or 16 to 31 can be draw it all


;;;;;this part is like a 1 iteration unrolled loop of the main loop that deals with the title screen

  ld hl,GAMEEND
 ld a,(HL)
 cp 0;;game end false
 jp z,doinstructions
 
  
    ld hl,GAMEEND
 ld a,(HL)
 cp 1;;game end true
 call z,Titlescreen;;;
 




doinstructions:

  
   call show4blankcounters
   call show4blankcounters
    
 
  push hl
   ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
  cp MENUPROGLANGUAGE
  call z,showgridonofftogglebanner
 
 

  ld hl,NOOFPOINTPLAYEDSOFARINONEGAME 
  ld a,(hl)
  cp 4
 jp z,ignoreturnsifgamefinshed

 
  ;;;;;;;;no go on to MergeDraw interpreter related stuff;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ignoreturnsifgamefinshed:
 





skipimageloadingpages:
 
 call initialisehedgehogcursorposition;;moving in in plotxy
   
 
  ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
    ld a,1;;;;an empty program has no repeats in it so it is trivially true from strart
    ld (HL),a
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,0;;;there are no commands in progrm to start with thus 0
  ld (HL),0

   ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,0
   ld (hl),a


  ld hl,LASTCOMMANDISREPEATFLAG;;; 
   ld a,0
   ld (hl),a



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ei
inputinstructionloop:
 di

 
showtitlescreen:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;if passed the title screen goes back to this instruction loop here
  ld hl,GAMEEND
 ld a,(HL)
 cp 1
 call z,Titlescreen
 
   ld hl,GAMEEND
 ld a,(HL)
 cp 0
 jp z,doinstructionsv2;;;v1 was like the unrolled 1 iteration mentioned above




doinstructionsv2:

displayMergeDrawscoreassub:
 

   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START CHECK if max number of instruction entered/////////////////////
  push hl
   ld hl,CHOOSEPROGRAMMINGLANGFLAG
    ld a,(hl)
  pop hl
   cp 1
  jp z,ignoreennteringautomticallyifullandinprogmode
  
  ld hl,&CD05;;;number of M.D. prog entered so far
  ld a,(hl)
  sub 69;;max no on instructions in Mergedraw program
  call nc,startanewpoininexistinggame;;AUTO ENTERS WHEN ALL INSTRUCTION OF 69 USED
ignoreennteringautomticallyifullandinprogmode:

   ld hl,&CD05;;
  ld a,(hl)
  sub 69;;max no on instructions in Mergedraw program
  jp nc,donotenteranymoreinstrfullentrypointiffull;;;skip over instr entry loop
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END CHECK if max number of instruction entered/////////////////////
  call moveHHtosecondtolastpixelplottedbyHH
   call selectpagefromPCsize

 

 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DETECT START OVER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                     in a,(&DD);; this is paddle 2 left key
                      bit 0,a; button two enters answer;;; left on joypad 2 is start over   ;;0-u,1-d,2-l,3-r,4-TL,5-TR
                        jp nz,leftnotpressed
		push hl
		push af
			        or a
				xor a
                            ld hl,LONGPRESSCOUNTERSTARTOVER
                            ld a,(hl)
			    inc a
                             ld (hl),a
                             cp 59
                             call z,setgameSTARTOVERflagtotrue
		pop af
		pop hl
	                        or a
				xor a
				ld hl,GAMESTARTOVEFLAGINGAMEMODE;;;set above
				ld a,(hl)
				cp 1
                                call z,resetandloadnewartfullimageforonepoint;;;nested so this is called when both button pressedn
leftnotpressed:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;grid  button for programming mode
               push hl
               ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
              ld a,(hl)
               pop hl
                cp MENUPROGLANGUAGE
                 jp nz,ignoreshowinggridifnotinprogrammingmode
                     in a,(&DD);;this is paddle 2 right key
                      bit 1,a; button two enters answer;;; left on joypad 2 is start over
                        jp nz,rightnotpressed
				or a
				xor a
                             ld hl,LONGPRESSCOUNTERGRIDTOGGLE
                             ld a,(hl)
			     inc a
			     and 63
                             ld (hl),a
                             cp 60
                            jp nz,rightnotpressed
				or a
				xor a;;clear carry flag  set a to 0 ie clear eset 
				ld hl,TOGGLEGRIDONOROFF
				ld a,(hl)
				xor 1;;;nver a
				ld (hl),a
			       call showgridifchosen
				 						
rightnotpressed:
ignoreshowinggridifnotinprogrammingmode:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; END DETECT START OVER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

     call redrawentercmdbanner;;;this has delay built in so not aCTUALLY DONE EVERY CALL when it is called here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DETECT CHOOSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
   call ReadPlayerControlKeys
   ld a,h
   bit 4,a; button 1;choose cmd
  call z,setinstuctionchoice

  or a
  xor a
  ld a,r
  sub 3
 call c,viewchosenpage

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DETECT END CHOOSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


   call ReadPlayerControlKeys
   ld a,h
   bit 0,a; up key
  call z,setinstructionchoiceVALUEup

   call ReadPlayerControlKeys
   ld a,h
   bit 1,a; down key
  call z,setinstuctionchoiceVALUEdown


   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DETECT ENTER ARTFULLIMAGE ANSWER WITH LONGER PRESS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



   push hl
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  pop hl
  jp z,ignoreenteringanswermessagedisplayifinPROGmode
        call ReadPlayerControlKeys
         bit 1,a; down nutton;;;;0-u,1-d,2-l,3-r,4-TL,5-TR
         jp nz,downnotpressedhere
       call ReadPlayerControlKeys
          bit 4,a; button one enters answers
           jp nz,dontloadenterif1notpressed
   call holdtoentermessage
  push de
  push hl

  pop hl 
  pop de
dontloadenterif1notpressed:
downnotpressedhere:


   push de
  push hl
  
  cp 0
  jp z,skipthisblankingifanswerattemptdtoenter
  ld a,r
  cp 1
  jp nz,slowdownblankingtobevisibe;;;slows down rubbing out of entering answer so it is visible  
  call blankaboveifneedsbe
   push de
  push hl
  ld e,0

  pop hl 
  pop de
slowdownblankingtobevisibe:
skipthisblankingifanswerattemptdtoenter:
 pop hl
 pop de 
ignoreenteringanswermessagedisplayifinPROGmode:
   


   call removegarbagefromscreen;;;periodically called not in interrupt subroutine
   call ReadPlayerControlKeys
   ld a,h
   bit 5,a; button two enters answers
   call z,enterinstruction;;;this renders the insruction in list too

   push hl
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  pop hl
  jp z,ignorelongpresscodeifinPROGMODE

               xor a
              or a
      call ReadPlayerControlKeys
         bit 1,a; down button
         jp nz,downnotpressed
       call ReadPlayerControlKeys
          bit 4,a; button one enters answers
           jp nz,dontloadenterans
  di

  push hl
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  pop hl
  jp z,ignoreenterANSWERifinPROGmode2674 

              ld hl,LONGPRESS2TOENTERANSCOUNTER
              ld a,(hl)
              inc a
              and %00111111
              ld (hl),a
                cp 15;;need to do non zero value so it does a long press measured in secs
                  call z,startanewpoininexistinggame
         jp done62342
ignoreenterANSWERifinPROGmode2674:
  ;;;if down+2 pressed and in programming mode then exit back to title screen
 ld hl,GAMEEND
 ld a,1;;;forces back to title screen
 ld (hl),a
 call resettonormalfromflagsetFORprogmode;;;put it back into game start with images mode
  ei
done62342:
dontloadenterans:
downnotpressed:
ignorelongpresscodeifinPROGMODE:

donotenteranymoreinstrfullentrypointiffull:
;;;;;;;;;;;;;;;;;;;;;;;;;key for exiting progrmming only mode;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        xor a
              or a
      call ReadPlayerControlKeys
         bit 1,a; down button
         jp nz,downnotpressedprogmodeonly
       call ReadPlayerControlKeys
          bit 4,a; button one enters answers
           jp nz,dontloadenteransprogmodeonly
  di

  push hl
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 0
  pop hl;;;  
  jp z,ignoreenterANSifinprogrammingmode99

              ld hl,LONGPRESS2TOENTERANSCOUNTERPROGMODE
              ld a,(hl)
              inc a
              and %00111111
              ld (hl),a
                cp 15;;;call this every 15 of the counter to slow down entry
               ;;;nested so this is called when both button pressedn
                  call z,restbacktomenufrompromode;;; 
         jp done623428
ignoreenterANSifinprogrammingmode99:

  
done623428:
  ei
dontloadenteransprogmodeonly:
downnotpressedprogmodeonly:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END DETECT ENTER ARTFULLIMAGE ANSWER WITH LONGER PRESS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;need to check after answer is entered to know if it game ended thus show titlescreen
    ld hl,GAMEEND
   ld a,(HL)
   cp 1
   jp z,showtitlescreen


;;;update page view but not too fast as it not required 
  or a
  xor a
  ld a,r
  sub 3
  call c,viewchosenpage


    


donotenteranymoreinstrfull:
   
  

  ei
 jp inputinstructionloop




 
restbacktomenufrompromode:
    ;;;if down+2 pressed and in programming mode then exit back to title screen
 ld hl,GAMEEND
 ld a,1;;; 
 ld (hl),a
  ld hl,JUSTEXITEDPROGLANGMODE
  ld a,1
  ld (hl),a
 call resettonormalfromflagsetFORprogmode;;;put it back into game start with images mode
  call biggerdelay
  call biggerdelay
  call biggerdelay
  call biggerdelay
  call biggerdelay
  ret
   
resetscoreP1firstturn:
  ld hl,P1SCORE;;; 
 ld a,0
 ld (hl),a
 ld hl,P2SCORE;;; 
 ld a,0
 ld (hl),a
 ld hl,P1TURN
 ld a,1
 ld (hl),a
 ld hl,P2TURN;;;not used
 ld a,0
 ld (hl),a
  ret



startanewpoininexistinggame:

  push bc
  push de
  push hl
  push af
  call biggerdelay


  
  ld hl,REVEALANSWERFORPLAYERTOMEMORISE
  ld a,0
 ld (hl),a

  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,0;;;assume it is not blank artfullimage to load
  ld (HL),a

  ld hl,LONGPRESSCOUNTERSTARTOVER
  ld a,0
  ld (HL),a


  ld hl,MergeDrawPCCOUNTERFOREXECUTING
  ld a,0
  ld (hl),a

    ld hl,XPOSLOOPTILES2SCR
  ld a,CANVASXPOS
  ld (hl),a
  ld hl,YPOSLOOPTILES2SCR
  ld a,CANVASYPOS
  ld (hl),a


  call drawcanvastoscreen



  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
  ld (hl),a


    ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,0
   ld (hl),a


   ld hl,PENDOWNFLAG 
 ld a,1
 ld (hl),a
 




  call clearscreenbuffer
  call clearMergeDrawprogramtoNONEcommands

  ld hl,PENDOWNFLAG 
   ld a,1
   ld (hl),a

  ld hl,MergeDrawPCCOUNTER;;;this var is tested to check M.D. is not too large
  ld a,0
  ld (hl),a;;;set MergeDraw pc to zero

   
 ld b,50
 ld c,50
  push hl
 ld hl,CURSORPOSITIONINPAGE
 ld a,8
 ld (hl),a;;initialise  

 ld hl,MergeDrawPCCOUNTERFORGUI
 ld a,0
 ld (hl),a;;initialise 


 ld hl,PAGENUMBERONSCREEN;;
 ld a,0
 ld (hl),a;;init to zero
 pop hl

  ld a,%101;;;;draw right;;
 ld (hl),a
 ld hl,INSTRUCTIONCHOICE
 ld a,%00010001;;;17
 ld (hl),a
  ld hl,INSTRUCTIONVALUE
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONVALUEFOROUNDING
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONPOINTER
    push hl
  push af
 ld hl,MergeDrawPCCOUNTERFORGUIconstant
 ld a,1;;
 ld (hl),a
  pop af
  pop hl
  
   call biggerdelay
  call biggerdelay
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

   ld hl,P1TURN
   ld a,(hl) 
   cp 1
    jp z,doplayer1turn;;;
   ld hl,P1TURN
   ld a,(hl)
   cp 0
    jp z,doplayer2turn
  


 
doplayer1turn:

    call biggerdelay
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ld hl,genericmessage9;;;;show P2 TELL P1 YOUR ANSWER before p1 tell p2 he right answer so p2 cant cheat
  call genericmessaheinHL

   


playeranswerconfirmloop:
  di
    call ReadPlayerControlKeys
     bit 5,a; exits the loop with bit 5's button (button 2 on SMS paddle)
       jp z,exiplayeranswerconfirmloop
     call biggerdelay
    ei
 jp playeranswerconfirmloop
exiplayeranswerconfirmloop:


 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ld hl,genericmessage10;;;;show P2 TELL P1 YOUR ANSWER
  call genericmessaheinHL
checkplayeranswercorrectloop:
  di
     call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
    call ReadPlayerControlKeys
     bit 0,a; exits the loop
       jp z,exitifanswerYEScorrect
    call ReadPlayerControlKeys
     bit 1,a; exits the loop
       jp z,exitifanswerNOincorrect
     call biggerdelay
   ei
 jp checkplayeranswercorrectloop
exitifanswerYEScorrect:
  ld hl,P2SCORE
  ld a,(HL)
  inc a
  ld (HL),a
exitifanswerNOincorrect:

    call displayMergeDrawscoreatbottom
 jp donep1orp2turn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


doplayer2turn:
    call biggerdelay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ld hl,genericmessage9p2;;;;show P2 TELL P1 YOUR ANSWER
  call genericmessaheinHL
playeranswerconfirmloop2:
  di
    call ReadPlayerControlKeys
     bit 5,a; exits the loop
       jp z,exitplayeranswerconfirmloop2
     call biggerdelay
  ei
 jp playeranswerconfirmloop2
exitplayeranswerconfirmloop2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ld hl,genericmessage10p2;;;;show P2 TELL P1 YOUR ANSWER
  call genericmessaheinHL
checkplayeranswercorrectloop2:
  di
     call biggerdelay
   call biggerdelay
  ei
   call biggerdelay
   call biggerdelay
 
    call ReadPlayerControlKeys
     bit 0,a; exit
       jp z,exitifanswerYEScorrect2
    call ReadPlayerControlKeys
     bit 1,a; exit
       jp z,exitifanswerNOincorrect2
     call biggerdelay
 
 jp checkplayeranswercorrectloop2
exitifanswerYEScorrect2:
  ld hl,P1SCORE
  ld a,(HL)
  inc a
  ld (HL),a
  
exitifanswerNOincorrect2:

 call displayMergeDrawscoreatbottom
donep1orp2turn:
  
 
 call   chooserandomartfullimage
    call biggerdelay
  call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
  call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay
   call biggerdelay

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ld hl,GAMEEND
 ld a,(HL)
  cp 1
 jp z,ignorenextturnifgameended

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;clear instruction after cofirm yes or no andswer
       push de
      push bc
       push hl
       ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI 
       ld a,0;;;;;force to chosen page
       ld (hl),a
       call renderinstructionsonce;;
      pop hl
     pop bc
    pop de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END clear instruction after cofirm yes or no answer
 

    xor a;;;clear a
   or a
   ld hl,P1TURN
   ld a,(hl)
   xor 1
   ld (hl),a


   ld hl,P1TURN
   ld a,(hl) 
   cp 1
    call z,P1ingamestart;;;like pre initlisation by chosing image

   ld hl,P1TURN
   ld a,(hl)
   cp 0
    call z,P2ingamestart

ignorenextturnifgameended:





   ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
    ld a,1;;;;an empty program has no repeats in it so it is trivially true from start
    ld (HL),a
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,0;;;there are no commands in program to start with thus 0
  ld (HL),0

   ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,0
   ld (hl),a


  ld hl,LASTCOMMANDISREPEATFLAG;;;for last commeand 
   ld a,0
   ld (hl),a

  ;;check  if someone reach 2 points


;;;;;;;; play 4 games till the end sum 
  push bc
  ld hl,NOOFPOINTPLAYEDSOFARINONEGAME 
  ld a,(hl)
  inc a
  ld (hl),a;;;at this point a represent the numbe of games that have been played
  cp 4
  call z,decidegameoutcome
  pop bc

   call biggerdelay
 
   pop af
  pop hl
  pop de
  pop bc

  ret
 



P1wongame:
  ld hl,genericmessage11;;;;show P2 TELL P1 YOUR ANSWER
  call genericmessaheinHL
  ld hl,GAMEEND 
  ld a,1
  ld (hl),a
  call includeendgamemessage
  ld iyl,106;;NONCE used to acknowledge that this subroutine is called
  ret

P2wongame:
  ld hl,genericmessage12;;;;show P2 TELL P1 YOUR ANSWER
  call genericmessaheinHL
  ld hl,GAMEEND 
  ld a,1
  ld (hl),a
  call includeendgamemessage
   ld iyl,107
  ret




decidegameoutcome:
 call gameovermusic
 ld iyl,100

  push hl
   ld hl,DRAWWASSHOWN
  ld a,0
  ld (HL),a
  pop hl

  call compscoredifference
   cp 0
   call z,drawgameshow;;iyl is 105 if called

   ld a,iyl
   cp 105
   jp z,done2113

 
    call compscoredifference 
  call   c,P1wongame;;iyl is 106 if called
     ld a,iyl
   cp 106
   jp z,done2113

    call compscoredifference 
   call nc,P2wongame;;iyl is 107 if called
   ld a,iyl
   cp 107
   jp z,done2113



  ;;;possible scores  draw 2-0  2-1  0-2 1-2   1-0 0-1 
done2113:
 
  ret


compscoredifference:
  push de
    or a
  xor a
  ld hl,P1SCORE
   ld a,(hl)
  ld d,a
  ld hl,P2SCORE
   ld a,(hl)
   sub a,d;;P2-P1
  pop de
 ret

drawgameshow:
  ld hl,genericmessage13;;;;show P2 TELL P1 YOUR ANSWER  
  call genericmessaheinHL
  ld hl,GAMEEND 
  ld a,1
  ld (hl),a
  call includeendgamemessage
  ld iyl,105
  ld hl,DRAWWASSHOWN
  ld a,1
  ld (HL),a


  ret

gameovermusic:
 push bc
 push af
 push hl
 push de
 ld e,4
 STORESONGPOSASCHOICEVAR e;
 pop de
 pop hl
 pop af
 pop bc
 ret






includeendgamemessage:
  push bc
    call ReadPlayerControlKeys
     bit 5,a; exits the loop
       jp z,exitincludeendgamemessage
;;;include outcome delay
  ld b,2
loopfordelaytoincludemessage:
   push bc
     call biggerdelay
     call biggerdelay
     call biggerdelay
   pop bc
  djnz loopfordelaytoincludemessage
 jp includeendgamemessage
exitincludeendgamemessage:

  pop bc



  push bc

   includeendgamemessage2:
    call ReadPlayerControlKeys
     bit 4,a; exits
       jp z,exitincludeendgamemessage2
     call biggerdelay
 jp includeendgamemessage2
exitincludeendgamemessage2:

   pop bc
   ret

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



 
  
  call RANDOMnum
  and 63
  ld b,a
  push bc
   ld a,r
   sub 63
   jp c,skip33
   call RANDOMnum
   call RANDOMnum
skip33:
   call RANDOMnum
   call RANDOMnum
   call RANDOMnum

  
  pop bc
  and 63
  ld c,a
  push bc
  call computebufferadressfromxyinBC
  pop bc
  call plotxyinBC


  
;;; set pixel

   ;;;h has x pos in pixels
   ;;;l has y pos in pixelcomputebufferadressfromxyinBCs
  ;;;use to update specific byte which was updated in ram using bitor
    ld a,&FF
   out (&BF),a
    ld a,&01;; 
   out (&BF),a
 
  ld b,a
  ld c,a
  push bc
  push af

 pop af
 pop bc
 

 


     ld bc,&0000; 
    ld hl,cursorlabel
    call Writetoscreenstringsub

 
    
   
   
   
      
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 

 ei
  jp mainloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clearspritesoffscreen:
     
    call ReadPlayerControlKeys
   ld a,h
   bit 1,a; down key
   call z,moveallspritesoffscreen
  ret
  
initialiseplayerpos:
 ld e,50;
 StoreHHCURSORPOSXVAR e
 ld e,50;
 StoreHHCURSORPOSYVAR e
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  




domusicsubroutine:

    ld a,r
    cp 1
    jp z,ndel
   ld hl,song
   ld de,0
   add hl,de
   ld a,(hl)
   ld e,a
   ld a,r
   and 127
   ld e,a
   ld d,&1F
   ld ixl,1
   ld  d,&1F
    ld a,1
    push af
    push de
    ld a,d
    ld b,a
    pop de
   pop af
     or b
     ld b,%11101111
    and b  
    out (&7F),a
   

     and %00111111 
     out (&7F),a
   ld a,%10010000
         push af
    push de
    ld a,e
    ld b,a
    pop de
   pop af

   or b
   out (&7F),a

ndel:

  ret

;;;;;;;;;end music stuff


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end main loop;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
loadsong1title:
 ld e,1
 STORESONGPOSASCHOICEVAR e;;
 ret
loadsong2title:
 ld e,2
 STORESONGPOSASCHOICEVAR e;;
 ret
 
 
 


moveallspritesoffscreen:
 ld b,63; this subroutine moves all the other sprites off screen
clearingloop:; so there are only the A and B srites stuck together
 ld a,b;and displayed when dowmn is pressed
 push bc
 ld b,255
 ld c,200
 call moveHHcursor16by16sprite
 pop bc
 djnz clearingloop
 ret






 moveHHcursorfordrawing:
  ReadHHCURSORPOSXVAR 0;
  inc a
  ld c,a 
  StoreHHCURSORPOSXVAR c;
  ReadHHCURSORPOSXVAR 0;
  ld c,a
  
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,0; sprite zero
  call moveHHcursor16by16sprite
  ;;;;.............
  ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a;
  ld a,1
  call moveHHcursor16by16sprite
   ;;;......................................
  ReadHHCURSORPOSXVAR 0;
   add a,8
  ld c,a
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,2; sprite zero
  call moveHHcursor16by16sprite
  ;;;.....................................................
  ReadPLAYERPOSYVAR 0
  add a,8; 
  ld b,a;
  ld a,3
  call moveHHcursor16by16sprite
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveHHcursorfordrawingup:

  ReadHHCURSORPOSXVAR 0;
  dec a
  ld c,a 
  StoreHHCURSORPOSXVAR c;
  ReadHHCURSORPOSXVAR 0;
  ld c,a
  
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,0; 
  call moveHHcursor16by16sprite
  ;;;;..................
  ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a;
  ld a,1
  call moveHHcursor16by16sprite
   ;;;......................................
  ReadHHCURSORPOSXVAR 0;
   add a,8
  ld c,a
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,2; 
  call moveHHcursor16by16sprite
  ;;;.....................................................
  ReadPLAYERPOSYVAR 0
  add a,8; 
  ld b,a;
  ld a,3
  call moveHHcursor16by16sprite
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveHHcursorfordrawingright:
   

  ReadHHCURSORPOSXVAR 0;
  ld c,a 
  StoreHHCURSORPOSXVAR c;
  ReadHHCURSORPOSXVAR 0;
  ld c,a
  
    ReadPLAYERPOSYVAR 0;
  inc a;
  ld b,a 
  StoreHHCURSORPOSYVAR b;
  ReadPLAYERPOSYVAR 0;
  ld b,a

  ld a,0; 
  call moveHHcursor16by16sprite
  ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a;
  ld a,1
  call moveHHcursor16by16sprite
  ;'''''''''''''''''''''''''''
  ReadHHCURSORPOSXVAR 0;
   add a,8
  ld c,a
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,2; 
  call moveHHcursor16by16sprite
  ReadPLAYERPOSYVAR 0;
  ld b,a
  add a,8; 
  ld b,a;
  ld a,3
  call moveHHcursor16by16sprite
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

moveHHcursorfordrawingleft:
  ReadHHCURSORPOSXVAR 0;
  ld c,a 
  StoreHHCURSORPOSXVAR c;
  ReadHHCURSORPOSXVAR 0;
  ld c,a
  
    ReadPLAYERPOSYVAR 0;
  dec a;
  ld b,a 
  StoreHHCURSORPOSYVAR b;
  ReadPLAYERPOSYVAR 0;
  ld b,a

  ld a,0; 
  call moveHHcursor16by16sprite
  ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a;
  ld a,1
  call moveHHcursor16by16sprite
  ;'''''''''''''''''''''''''''
  ReadHHCURSORPOSXVAR 0;
   add a,8
  ld c,a
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,2; 
  call moveHHcursor16by16sprite
  ReadPLAYERPOSYVAR 0;
  ld b,a
  add a,8; 
  ld b,a;
  ld a,3
  call moveHHcursor16by16sprite
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restoreplayerpos:
  ReadHHCURSORPOSXVAR 0;
  ld c,a
  ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,0; 
  call moveHHcursor16by16sprite
  ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a;
  ld a,1
  call moveHHcursor16by16sprite
  ;opo
  ReadHHCURSORPOSXVAR 0;
   add a,8
  ld c,a
    ReadPLAYERPOSYVAR 0;
  ld b,a
  ld a,2; 
  call moveHHcursor16by16sprite
    ReadPLAYERPOSYVAR 0;
  add a,8; 
  ld b,a
  ld a,3
  call moveHHcursor16by16sprite
  ret



	
SetupVRAM:				
	    ld a,l
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
	    out (VDPcontrolport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    nop
 nop
 nop
 nop
   nop
	    ld a,h
	    or &40			
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
	    out (VDPcontrolport),a	
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
    ret							 							


VdpInitData:
	db %00000110,128+0 ;
	db %11100000,128+1 ;
	db &ff		,128+2 ; 
	db &ff		,128+3 ; 
	db &ff 		,128+4 ; 
	db &ff		,128+5 ; 
	db &00		,128+6 ; 
	db &00		,128+7 ; 
	db &00 		,128+8 ; 
	db &00		,128+9 ; 
	db &ff 		,128+10; 
VDPinitialiseDataEnd:								
	



Dataofpalette:
					


  	db &00;transparent
	db &02;darkred
	db &04;;;;;dark green 
	db &0B;dark yellow
	db &10;;;dark blue
        db &36;;    dark pruple
	db &20;;; medium blue
	db &14;; dark gray wron need light gray-14 looks like a dark blue
	db &15;; dark gray
	db &03;;;light red
	db &0C;;light green
	db &0F;;light yellow
	db &30;;daRK BLUYE WORNG NEED IT A BIT LIGHTER
	db &33; light purple
	db &3C;; cyan
	db &3F ;;white

 	db &00;transparent
	db &02;darkred
	db &04;;;;;dark green 
	db &0B;dark yellow
	db &10;;;dark blue
        db &36;;  dark pruple
	db &20;;; medium blue
	db &14;; dark gray wron need light gray-14 looks like a dark blue
	db &15;; dark gray
	db &03;;;light red
	db &0C;;light green
	db &0F;;light yellow
	db &30;;daRK BLUYE WORNG NEED IT A BIT LIGHTER
	db &33; light purple
	db &3C;; cyan
	db &3F ;;white



 											
SetupSprite:	
	push hl
	push de  
	push af	


			push af
				ld h,&3F			
				ld l,a				
				call SetupVRAM	
				ld a,c			
      nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
				out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
			pop af
			
			rlca					
			ld h,&3F
			add &80					
			ld l,a
			call SetupVRAM		
			
			ld a,b					
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
			out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
   nop
			ld a,e					;tile number
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
      nop
 nop
 nop
 nop
 nop
 nop
   nop
			out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
   nop
	pop af
	pop de
	pop hl
WaitForScreenRefresh:
	ret

moveHHcursor16by16sprite:	
	push hl
	push de  
	push af	


			push af
				ld h,&3F			
				ld l,a				
				call SetupVRAM	
				ld a,c				
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
				out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
   nop
			pop af
			
			rlca					
			ld h,&3F
			add &80					
			ld l,a
			call SetupVRAM		
			
			ld a,b					
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
     nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
			out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   
		
			
	pop af
	pop de
	pop hl
WaitFortheScreenRefresh:
	ret
 
ReadPlayerControlKeys:
   push bc
 
 push de
 





    
		push bc
			in a,(&DC)	
			ld b,a
			in a,(&DD)	
			rl b		
			rla
			rl b
			rla
			or %11000000	
		pop bc
	 
	ld l,a 
 	

	in a,(&DC)
	or %11000000		 

	ld h,a ; 
	
 
  pop de
  pop bc

	ret
 


VDPscreenpositioninclude:	
	push bc				

		ld h,c
	
		xor a			
		rr h			
		rra
		rr h
		rra
		rlc b			;
		or b
	
		ld l,a
		ld a,h
		add &38			;
		ld h,a				;
		call SetupVRAM
	pop bc
	ret
	
 

TilesToVRAM:
	ld a,h
	add b
	ld h,a
	
	ld a,l
	add c
	ld l,a
TilesToVRAM_Yagain:
	push bc
		push de
		push hl
			call VDPscreenpositioninclude			
		pop hl	
		pop de		
TilesToVRAM_Xagain:	
		ld a,e				
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
       nop
		out (VDPdataport),a	
        nop		
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
        nop
		ld a,d		
        nop		
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
       nop
		out (VDPdataport),a
		  nop
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop

		inc de
		inc b
		ld a,b
		cp h
		jr nz,TilesToVRAM_Xagain
	pop bc

	inc c
	ld a,c
	cp l
	jr nz,TilesToVRAM_Yagain

	ret

  
TilestoVideoRAM:	
	ex de,hl
	call SetupVRAM
	ex de,hl
TilestoVideoRAM2:
	ld a,(hl)
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
    nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
	out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,TilestoVideoRAM2
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;define tiles for B&W to RAM;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


getfulcolouraddressofpicbyteHLaddressDEoffset:
  push af
  push hl
  push de
  add hl,de
  ld de,THECOLOURBYTE1
  ld a,(hl)
  ld (de),a

  inc hl

  ld de,THECOLOURBYTE2
  ld a,(hl)
  ld (de),a

  inc hl

  ld de,THECOLOURBYTE3
  ld a,(hl)
  ld (de),a

  inc hl

  ld de,THECOLOURBYTE4
  ld a,(hl)
  ld (de),a

 
  
  pop de
  pop hl
 pop af

  push af
  push hl
  push de
  LD HL,ISBLANKARTFULLIMAGETOLOADFLAG
  LD A,(HL)
  cp 1
  call z,loadblankartfullimagecolourbytes
  pop de
  pop hl
 pop af
     
  ret

loadblankartfullimagecolourbytes:

 ld de,THECOLOURBYTE1
  ld a,0
  ld (de),a
  ld de,THECOLOURBYTE2
  ld a,0
  ld (de),a
  ld de,THECOLOURBYTE3
  ld a,0
  ld (de),a
  ld de,THECOLOURBYTE4
  ld a,255
  ld (de),a
  ret
 
TilestoVideoRAMBW:	
   push hl
  push de
  push bc
  push af


   ld a,&FF
   out (&BF),a
   ld a,&01
   out (&BF),a

 
  ld de,0
TilestoVideoRAM2BW:
	ld a,(hl)

  push de
  push af

   out (&BE),a


  pop af
   pop de


 
 
 
 
	inc hl
 
	dec bc
	ld a,b
	or c
	jp nz,TilestoVideoRAM2BW

  pop af
  pop bc
  pop de
  pop hl

	ret

 










WriteStringwithPrintCharacter:
	ld a,(hl)				
	cp 255
	ret z
	inc hl
	call WriteCharacter
	jr WriteStringwithPrintCharacter

WriteStringwithPrintCharacterv2:
	ld a,(hl)				
	cp 255
	jp z, done233
	inc hl
	call vpoke
	jr WriteStringwithPrintCharacter

done233:
  ret


Message: db 11,255
Nullmessage: db 255,255

NewLine:
	push af

		xor a			
		ld (TheNextCharacterX),a
		ld a,(TheNextCharacterY)
		inc a
		ld (TheNextCharacterY),a
	pop af
	ret

	

 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RANDOMnum:
 push bc
 or a
 xor a
 ld a,r
 and 1
 ld b,a
 ld a, (seed2)
 add a,b
 ld b, a 
 rrca ; multiply by 32
 rrca
 rrca
 xor 0x1f
 add a, b
 sbc a, 255 ; carry
 ld (seed2), a
 pop bc
 ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clearscreen:
 ld bc,&00
 ld hl,&0101
 call TilesToVRAM
 
blankHHsprites:
    push bc
    push de
    push hl
     ld bc,&7777 ;  x and y -can really be anything here since X ,y pos is redefined later
     ld de,&0000  ; 
     ld e,15
     ld h,0  
     ld a,0  
     call SetupSprite

    ld bc,&8888 ;
     ld de,&0001  ;
     ld e,15
     ld h,0  ;
     ld a,1  ;
     call SetupSprite

       ld bc,&7777 ;
     ld de,&0000  ; 
     ld e,15
     ld h,0  ;
     ld a,2  ;
     call SetupSprite

    ld bc,&8888 ; 
     ld de,&0001  ; 
     ld e,15
     ld h,0  ;
     ld a,3  ;
     call SetupSprite
   pop hl
   pop de
   pop bc
    ret

loadHHsprites:
     push bc
    push de
    push hl
         ld bc,&7777 ; x and y -can really be anything here since X ,y pos is redefined later
     ld de,&0000  ; 
     ld e,6+3
     ld h,0  ;
     ld a,0  ;
     call SetupSprite

    ld bc,&8888 ;
     ld de,&0001  ;
     ld e,7+3
     ld h,0  ;
     ld a,1  ;
     call SetupSprite

       ld bc,&7777 ;
     ld de,&0000  ; 
     ld e,8+3
     ld h,0  ;
     ld a,2  ;
     call SetupSprite

    ld bc,&8888 ; 
     ld de,&0001  ; 
     ld e,9+3
     ld h,0  
     ld a,3  ;
     call SetupSprite
     pop hl
   pop de
   pop bc
  ret


setupsprites:

  call loadHHsprites
  call initialisehedgehogcursorposition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;  0,1,2,3 are HH cursor sprites

   ;;;;;;;;;;;;;;;;this is the cursor
         ld bc,&8888 ;
     ld de,&0001  ; 
     ld e,7  
     ld h,0  ;
     ld a,4  ;
     call SetupSprite


  
  ret

  
showgridifchosen:
   push bc
SHIFTDOWN EQU 32-16+8-4+2-4+1
SHIFTRIGHT EQU 16-4
   ld c,8+SHIFTDOWN
    ld a,5
  call draw4gripoints32pixelsapartCpixelsdowninC
   call movedownaddtoC
    ld a,9+1
  call draw4gripoints32pixelsapartCpixelsdowninC
   call movedownaddtoC
    ld a,15
  call draw4gripoints32pixelsapartCpixelsdowninC
   call movedownaddtoC
    ld a,20
  call draw4gripoints32pixelsapartCpixelsdowninC
    call movedownaddtoC
    ld a,25
  call draw4gripoints32pixelsapartCpixelsdowninC
    pop bc

    ret

draw4gripoints32pixelsapartCpixelsdowninC:
      ld b,8+SHIFTRIGHT
    push af
    call setspritegridpointsprite
    call moveacrossaddtoB
    pop af
    inc a
    push af
    call setspritegridpointsprite
    call moveacrossaddtoB
    pop af
    inc a
    push af
    call setspritegridpointsprite
    call moveacrossaddtoB
    pop af
    inc a
    push af
    call setspritegridpointsprite
    call moveacrossaddtoB
    pop af
    inc a
    push af
    call setspritegridpointsprite
    call moveacrossaddtoB
    pop af
    ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start HH on title screen spites
showHHmetaspriteifchosen:
   push bc


SHIFTDOWNHH EQU 64
SHIFTRIGHTHH EQU 128
 

    push af
     push hl
      ld hl,HHTITLEVERTICALPOS
     ld a,(hl)
     ld l,a
        ld c,8+SHIFTDOWNHH
      ld a,c
       add a,l
       ld c,a
      pop hl
     pop af

    ld a,5
  call draw4HHspritetitlescreentiles8pixelsapartC;;;each sprite is 8 pixels apart
   call HHmovedownaddtoC
    ld a,9
  call draw4HHspritetitlescreentiles8pixelsapartC
   call HHmovedownaddtoC
    ld a,13
  call draw4HHspritetitlescreentiles8pixelsapartC
   call HHmovedownaddtoC
    ld a,17
  call draw4HHspritetitlescreentiles8pixelsapartC
    call HHmovedownaddtoC
    ld a,21
  call draw4HHspritetitlescreentiles8pixelsapartC
    call HHmovedownaddtoC
    ld a,25
  call draw4HHspritetitlescreentiles8pixelsapartC
    call HHmovedownaddtoC
    ld a,29
  call draw4HHspritetitlescreentiles8pixelsapartC
    call HHmovedownaddtoC
    ld a,33
  call draw4HHspritetitlescreentiles8pixelsapartC
    pop bc

    ret

draw4HHspritetitlescreentiles8pixelsapartC:
     push af
     push hl
      ld hl,HHTITLEACROSSPOS
     ld a,(hl)
     ld l,a
      ld b,8+SHIFTRIGHTHH
      ld a,b
       add a,l
       ld b,a
      pop hl
     pop af
      
    push af
    call setspriteHHmetaspritepointsprite
    call HHmoveacrossaddtoB
    pop af
    inc a
    push af
    call setspriteHHmetaspritepointsprite
    call HHmoveacrossaddtoB
    pop af
    inc a
    push af
    call setspriteHHmetaspritepointsprite
    call HHmoveacrossaddtoB
    pop af
    inc a
    push af
    call setspriteHHmetaspritepointsprite
    call HHmoveacrossaddtoB
    pop af

    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


setspriteHHmetaspritepointsprite:
   push hl
   push af
    
 
  ld ixh,a;;need to preserve a as t used to draw HHmetasprite
   ld hl,TOGGLEHHmetaspriteONOROFF
   ld a,(hl)
    cp 0
   jp z,dontshowHHmetasprite
   ld hl,TOGGLEHHmetaspriteONOROFF
   ld a,(hl)
    cp 1
   jp z,showHHmetasprite
dontshowHHmetasprite:
     ld a,ixh
          push bc
     ld h,0 
      ld d,0
     ld e,15
     push ix
    call SetupSprite
     pop ix
    pop bc
  jp done325327
showHHmetasprite:
    ld a,ixh
    add a,11
    ld e,a

    ld a,ixh
    
    push bc
     ld h,0 
      ld d,0
   
     push ix
    call SetupSprite
     pop ix
    pop bc
done325327:
  pop af
  pop hl
  ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 
setspritegridpointsprite:
   push hl
   push af
  ld ixh,a;;need to preserve a as t used to draw grid
   ld hl,TOGGLEGRIDONOROFF
   ld a,(hl)
    cp 0
   jp z,dontshowgrid
   ld hl,TOGGLEGRIDONOROFF
   ld a,(hl)
    cp 1
   jp z,showgrid
dontshowgrid:
     ld a,ixh
          push bc
     ld h,0 
      ld d,0
     ld e,15
     push ix
    call SetupSprite
     pop ix
    pop bc
  jp done32532
showgrid:
    ld a,ixh
    push bc
     ld h,0 
      ld d,0
     ld e,14
     push ix
    call SetupSprite
     pop ix
    pop bc
done32532:
  pop af
  pop hl
  ret
 



 

moveacrossaddtoB:
  ld a,b
  add a,31
  ld b,a
  ret

movedownaddtoC:
  ld a,c
  add a,31
  ld c,a
  ret

HHmoveacrossaddtoB:
  ld a,b
  add a,8
  ld b,a
  ret

HHmovedownaddtoC:
  ld a,c
  add a,8
  ld c,a
  ret




       
	
;;;;;;;;;;;;;;;;;;display numerb stuff
WriteCharacter:
 
  sub 0
  cp '8' 
  jp z, forshowing8and9
  sub 0
  cp '9' 
  jp z, forshowing8and9
  jp skipforshowing8and9
forshowing8and9:
   inc a
   inc a
skipforshowing8and9:

      
	push bc
	push hl
		push af
			ld a,(TheNextCharacterY)
			ld b,a			;
			ld a,(TheNextCharacterX)
			ld c,a				;
			
			xor a				;
			rr b		
			rra					;
			rr b
			rra					;
			
			rlc c				;			
			or c		
			ld c,a
			
			ld hl,&3800			
			 
			add hl,bc
			call SetupVRAM
		pop af
		
		push af

 			add a,193
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
       nop
			
			out (VDPdataport),a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
       nop
			xor a
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop				
			out (VDPdataport),a
		    nop
 nop
 nop
 nop
 nop
    nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop	
			ld a,(TheNextCharacterX)	
			inc a
			ld (TheNextCharacterX),a	
			
  
		pop af
	pop hl
	pop bc
        	
	ret

Displayscore:

	ld	bc,-10000
	call	NumberTypeofUnits1
	ld	bc,-1000
	call	NumberTypeofUnits1
	ld	bc,-100
	call	NumberTypeofUnits1
	ld	c,-10
	call	NumberTypeofUnits1
	ld	c,-1
NumberTypeofUnits1:	ld	a,'0'-1
NumberTypeofUnits2:	inc	a
	add	hl,bc
	jr	c,NumberTypeofUnits2
	sbc	hl,bc
	call WriteCharacter
  
	ret 
 

WriteCharacternumber:
         push af
           push hl
           ld hl,PRINTNUMBERXPOS
           ld a,(hl)
           ld b,a
             pop hl 
           push hl
           ld hl,PRINTNUMBERYPOS
           ld a,(hl)
           ld c,a
            pop hl 
          pop af
            
            sub 0
            cp '0'
            call z,write0
            jp done332
           cp '1'
            call z,write1
done332:
          ret


write0:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,321-256
  ld (hl),a
  call vpokeover255
  CALL movenumcursor
   pop af
  ret

writeblankchar:
  push af

  ld hl,VPOKETHIS
  ld a,321-256
  ld (hl),a
  call vpokeover255ver2
  CALL movenumcursor
   pop af
  ret



write1:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,322-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write2:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,323-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write3:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,324-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write4:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,325-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write5:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,326-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write6:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,327-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write7:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,328-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write8:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,329-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

write9:
  push af
  call loadcursorintobc
  ld hl,VPOKETHIS
  ld a,330-256
  ld (hl),a
  call vpokeover255
   CALL movenumcursor
   pop af
   ret

writeadigit:
  sub 0
  cp 0
  jp z,write0

  cp 1
  jp z,write1

  cp 2
 jp z,write2

  cp 3
  jp z,write3
 
  cp 4
  jp z,write4

  cp 5
  jp z,write5

  cp 6
  jp z,write6

  cp 7
  jp z,write7
 
  cp 8
  jp z,write8

  cp 9
  jp z,write9
 
done523:
 ret


loadcursorintobc:
                     push af
                   push hl
       ld hl,PRINTNUMBERXPOS
           ld a,(hl)
         ld b,a
       ld hl,PRINTNUMBERYPOS
           ld a,(hl)
         ld c,a
  
                 pop hl
                  pop af 
  ret


movenumcursor:
                 push af
                   push hl
           ld hl,PRINTNUMBERXPOS
           ld a,(hl)
           inc a
           ld (hl),a
  
                 pop hl
                  pop af 
             ret




WriteCharacternumver:
        cp '0'
        jp z,loadthe0v2
        cp '1'
        jp z,loadthe1v2
loadthe0v2:
    ld bc,&0200
    ld hl,&0101
    ld d,1
    ld e,321-256
    call TilesToVRAM
   jp end33
loadthe1v2:
    ld bc,&0300
    ld hl,&0101
    ld d,1
    ld e,321-256+1
    call TilesToVRAM
end33:  
   ret


 

;;;;;;;;end display number;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


blankrightmostedgesub:
    ld b,23
blankrightmostedgeloop:
 ld iyl,b
 push bc
  push iy
  writetext 31,iyl,blankchar;;the other text macro not desing for  blanking edge bu t writetext is
 pop iy
 pop bc
  djnz blankrightmostedgeloop
  ret

blankrightmostedgesub2:
    ld b,23
blankrightmostedgeloop2:
 ld iyl,b
 push bc
  push iy
  writetext 30,iyl,blankchar
 pop iy
 pop bc
  djnz blankrightmostedgeloop2
  ret



viewchosenpage:
       call ReadPlayerControlKeys
     ld a,h
     bit 3,a;right key
    jp nz,dontshowchosenpage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;change page to view in GUI
    push bc
  push hl
  push de
  call blankrightmostedgesub2
  pop de
  pop hl
  pop bc

          or a
	 xor a
          ld hl,PAGECHOSENTOBEVIEWEDINGUICOUNTER
          ld a,(hl)
          inc a
          and %00111111
          ld (hl),a;needs a 3 way deicison
         ld e,1;;;assume page 1  
        push af
        sub 21;;
        call c,view1stpagesetflag
        pop af;;;restore a for next comparison
        sub 48;;
        call nc,view3rdpagesetflag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI 
      ld a,(HL)
      ld d,a;;;store current programming page temporari;ly
      push de;;;onto stack
       
       ld a,e
       ld (hl),a
       call renderinstructionsonce;;chosen page
      
pausechosenGUIpagescgreenMergeDrawprog:;;;
     call ReadPlayerControlKeys;;;;any button exits   view
      bit 0,a
    jp z,exitpauseloop
      bit 1,a
    jp z,exitpauseloop
      bit 2,a
  jp z,exitpauseloop
      bit 3,a
  jp z,exitpauseloop
      bit 4,a
  jp z,exitpauseloop
      bit 5,a
  jp z,exitpauseloop
 call biggerdelay
 jp pausechosenGUIpagescgreenMergeDrawprog
exitpauseloop:
   pop de


dontshowchosenpage:
  push bc
  push hl
  push de
  call blankrightmostedgesub
 
  pop de
  pop hl
  pop bc
  ret
;;;;;;;;;;;

P1ingamestart:

  call loadHHsprites
  call initialisehedgehogcursorposition

  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  call z,progmodeflags



  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  jp z,ignoretextifinprogramminmode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if not in prog mode do the block below;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld hl,NOOFPOINTPLAYEDSOFARINONEGAME 
  ld a,(hl)
  ld (hl),a;;;at this point a represent the numbe of games that have bneen played
  cp 3
  jp z,innoreP1inggamstartIF4gamesplayed
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld hl,REVEALANSWERFORPLAYERTOMEMORISE
   ld a,0
   ld (hl),a;;


  ld hl,ingamemessage1P1
  call genericmessaheinHL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ld a,199
  ld hl,P2TOP1MESSAGECORRECT
  ld (hl),a

    call chooserandomartfullimage
chooserandomartfullimageloop2:
  di
    call ReadPlayerControlKeys
      bit 4,a; button select randomly slected picture

  
 call z,chooserandomartfullimage
     bit 5,a; exits the lopop
       jp z,exitlooptoartfullimagechosenSTEP2b
  ei
 jp chooserandomartfullimageloop2
exitlooptoartfullimagechosenSTEP2b:
   ld a,0
  ld hl,P2TOP1MESSAGECORRECT
  ld (hl),a


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
   ld hl,ingamemessage2P1
  call genericmessaheinHL




warnP2tolookawayloop3321:;;;doesnt show answert yet
  di
     call ReadPlayerControlKeys
       bit 4,a;;
     jp z,exitwarnP2tolookawayloop3321
    CALL biggerdelay
  ei
  jp warnP2tolookawayloop3321
exitwarnP2tolookawayloop3321:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld hl,REVEALANSWERFORPLAYERTOMEMORISE
   ld a,1
   ld (hl),a;;;
   ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(HL)
  call showchosenartfullimage;;redraw artfullimage with answer at bottom
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld hl,ingamemessage3P1;;;tell p1 to look at bottom of screen to  memorise
 
  call genericmessaheinHL
  call Drawthetwochardbottomleft
 




keepansweronscreensoP1canmemoriseitloopb:
  di
          call ReadPlayerControlKeys
            bit 5,a; exits button
       jp z,exitlooptoartfullimagechosenSTEP3b
     CALL biggerdelay
   ei
  jp keepansweronscreensoP1canmemoriseitloopb
exitlooptoartfullimagechosenSTEP3b:

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ld hl,REVEALANSWERFORPLAYERTOMEMORISE;;
 ld a,0
 ld (hl),a
  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(HL)
  call showchosenartfullimage;;;;;;;;;redrawartfullimage without answer at bottom

   ld hl,ingamemessage4P1
   call genericmessaheinHL

;;;;start delay to include message
  push bc
    ld b,10;;
delaytoincludemessgae:;;
         push bc
    call biggerdelay;;;creates about a 1 second delay
   call biggerdelay
   call biggerdelay
   call biggerdelay;;
   call biggerdelay;;
     pop bc
  djnz delaytoincludemessgae
  pop bc
;;;;end delay to include message

 
innoreP1inggamstartIF4gamesplayed:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END if not in prog mode do the block below''''''''''''''''''''''''''''''''''''''''''
ignoretextifinprogramminmode:
    call drawbuttonlabels
    ld hl,CHOOSEPROGRAMMINGLANGFLAG
    ld a,(hl)
    cp 1
    call z,showgridonofftogglebanner
  ret

blankoutanswerwith15spaces:
 push de
 push hl
 push bc
 push af
 writetext 01,22,blankoutanswe15char
 pop af
 pop bc
 pop hl
 pop de
 ret

blankoutanswerwith15spacesv2:;;same as above but goes to very edge
 push de;;;this is required to blank out of of the tiles left by the key labels
 push hl
 push bc
 push af
 writetext 0,22,blankoutanswe12char;;;rubs out reddish label -using 12 chaRS PRESERVRES THE PAGEVIEW LABEL
 pop af
 pop bc
 pop hl
 pop de
 ret


blankout6char: db '      %',255
blankoutanswe15char: db '                  %',255
blankoutanswe12char: db '            %',255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Drawthetwochardbottomleft:
  PUSH AF
   push de;;two chars from key labels to delete here
   push hl
  push bc
    writetext &00,23,blankchar;;
  writetext &00,22,blankchar;
  pop bc
  pop hl
  pop de
  POP AF
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;similar for P2 takes abot 230 bbytes
P2ingamestart:

    call loadHHsprites
  call initialisehedgehogcursorposition

  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  call z,progmodeflags;;;set the flags if programming only mode is chosen
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  jp z,ignorethetextifinprogramingmode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;if not in prog mode do the block below''''''''''''''''''''''''''''''''''''''''''
 

    ld hl,NOOFPOINTPLAYEDSOFARINONEGAME 
  ld a,(hl)
  ld (hl),a;;;at this point a represent the numbe of games that have bneen played
  cp 3
  jp z,ignoreP2ingamstartIF4gamesplayed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld hl,REVEALANSWERFORPLAYERTOMEMORISE
   ld a,0
   ld (hl),a;;

  ld hl,ingamemessage1P2
  call genericmessaheinHL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


chooserandomartfullimageloop:
  di
    call ReadPlayerControlKeys
      bit 4,a; 
 call z,chooserandomartfullimage
     bit 5,a; 
       jp z,exitlooptoartfullimagechosenSTEP2
  ei
 jp chooserandomartfullimageloop
exitlooptoartfullimagechosenSTEP2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ld hl,ingamemessage2P2
  call genericmessaheinHL



warnP2tolookawayloop:;;;doesnt show answer yet
  di
     call ReadPlayerControlKeys
       bit 4,a;;;
     jp z,exitwarnP2tolookawayloop
    CALL biggerdelay
   ei
  jp warnP2tolookawayloop
exitwarnP2tolookawayloop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld hl,REVEALANSWERFORPLAYERTOMEMORISE
   ld a,1
   ld (hl),a;;;
   ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(HL)
  call showchosenartfullimage;;redraw artfullimage with answer at bottomn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld hl,ingamemessage3P2;;;tell P2 to look at bottom of scrrenen to  memorise
  call genericmessaheinHL
 call Drawthetwochardbottomleft


keepansweronscreensoP2canmemoriseitloop:
   di
          call ReadPlayerControlKeys
            bit 5,a; exits
       jp z,exitlooptoartfullimagechosenSTEP3
     CALL biggerdelay
    ei
  jp keepansweronscreensoP2canmemoriseitloop
exitlooptoartfullimagechosenSTEP3:

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ld hl,REVEALANSWERFORPLAYERTOMEMORISE;;a fixed choce from randomly slected choces
 ld a,0
 ld (hl),a
  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(HL)
  call showchosenartfullimage;;;;;;;;;redrawartfullimage without answer at bottom

   ld hl,ingamemessage4P2
   call genericmessaheinHL
 
 ld b,30

delaybeforep1looktoplaymessage:
  push bc
  call biggerdelay
  pop bc
  djnz delaybeforep1looktoplaymessage

ignoreP2ingamstartIF4gamesplayed:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END if not in prog mode do the block below;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
ignorethetextifinprogramingmode:
  call drawbuttonlabels
  ret

clearmostbutnotallofthescreen:
  ld b,31
acrossloop:
      dec b
     ld iyl,b
     
  push iy
  push bc
  push de
  push hl
 ld b,23;;;23 instrction per page
blankveticallineofzeros:
 ld iyh,b;;;cant us b as it is used for across however we can use b for both bfor across and down used inner and outer and stack and iyh 
  push bc
   ld b,IYL;;across value
   ld c,iyh
   ld hl,VPOKETHIS
  ld a,334-256
  ld (hl),a
  call vpokeover255
  pop bc
 djnz blankveticallineofzeros
  pop hl
  pop de
  pop bc
   POP Iy
   ld a,b
   cp 0
   jp z,acrossloopexit
  jp acrossloop
acrossloopexit:

    ld b,23
blankleftmostedgeloop:
 ld iyl,b
 push bc
  push iy
  writetext &00,iyl,blankchar
 pop iy

 pop bc
  djnz blankleftmostedgeloop
  ret

  
blankgeneralmssgesarea:
       ld b,0
   ld c,1
  ld hl,generalMSGblankline
   call  writeHLstringwithvpokexyposBC

  
       ld b,0
   ld c,2
  ld hl,generalMSGblankline
   call  writeHLstringwithvpokexyposBC

  
       ld b,0
   ld c,3
  ld hl,generalMSGblankline
    call  writeHLstringwithvpokexyposBC
  ret



displayMergeDrawscoreatbottom:
  push bc
 push hl
 push de
 push af
  
 call blankoutanswerwith15spacesv2
     ld b,1
   ld c,21
   ld hl,scorelabelMergeDraw1
  call  writeHLstringwithvpokexyposBC
     ld b,1-1
   ld c,1+21
   ld hl,scorelabelMergeDraw2
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  ld b,7
   ld c,22
    ld hl,P1SCORE
    ld a,(hl)
  call display3digitnumberinAposinBCsetcurosor
   ld b,15
   ld c,22
    ld hl,P2SCORE
    ld a,(hl)
   ;;ld a,e
  call display3digitnumberinAposinBCsetcurosor

pauseforREADINGscore:;;;doesnt show answer yet up to this point

    
     call ReadPlayerControlKeys
       bit 4,a;;;
     jp z,exitpauseforREADINGscore
    CALL biggerdelay
  jp pauseforREADINGscore
exitpauseforREADINGscore:

  

    ld hl,P1SCORE
    ld a,(hl)
    cp 1
    call z,p1showscore1
    ld hl,P1SCORE
    ld a,(hl)
    cp 2
    call z,p1showscore2

    ld hl,P2SCORE
    ld a,(hl)
    cp 1
    call z,p2showscore1
    ld hl,P2SCORE
    ld a,(hl)
    cp 2
    call z,p2showscore2

  
   pop af
 pop de
  pop hl
  pop bc
  ret

show4blankcounters:

    PUSH HL
     ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
  cp MENUPROGLANGUAGE
  jp z,ignorecountersdraw
 
     writetext 0,0,blankplayercounterchar
   writetext 1,0,blankplayercounterchar
  writetext 3,0,blankplayercounterchar
   writetext 4,0,blankplayercounterchar
 
ignorecountersdraw:
 

  push af
  push hl
   ld hl,CHOOSEPROGRAMMINGLANGFLAG
    ld a,(hl)
  call z,showgridonofftogglebanner
 pop hl
  pop af


  ret

show4blankcountersub:;
    writetext 0,0,blankplayercounterchar
   writetext 1,0,blankplayercounterchar
  writetext 3,0,blankplayercounterchar
   writetext 4,0,blankplayercounterchar
  ret

p1showscore1:
      writetext 0,0,p1counter
   ret
p1showscore2:
      writetext 0,0,p1counter
      writetext 1,0,p1counter
   ret

p2showscore1:
      writetext 3,0,p2counter
   ret
p2showscore2:
      writetext 3,0,p2counter
      writetext 4,0,p2counter
   ret
vdpdelay:
     nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
 nop
   nop
      nop
 push ix 
 pop ix
  ret

setgameSTARTOVERflagtotrue:
  ld hl,GAMESTARTOVEFLAGINGAMEMODE
  ld a,1
  ld (hl),a
  ret

PAGE4TEXTINSTR1:  db 'WWW.UNSPLASH.COM                ',255
PAGE4TEXTINSTR2:  db 'FOR PUBLIC DOMAIN IMAGES        ',255
PAGE4TEXTINSTR3:  db '                                ',255
PAGE4TEXTINSTR4:  db 'ALL OTHER GRAPHICS BY Z8AP      ',255
PAGE4TEXTINSTR5:  db '                                ',255
PAGE4TEXTINSTR6:  db 'MUSIC BY NAOMI Z. NOSIPHO.      ',255
PAGE4TEXTINSTR7:  db '                                ',255
PAGE4TEXTINSTR8:  db 'ALL CODE CREATED IN 100 PERCENT ',255
PAGE4TEXTINSTR9:  db 'Z80 ASSEMBLY LANGUAGE USING VASM',255
PAGE4TEXTINSTR10: db 'ASSEMBLER ENTIRELY BY Z8AP      ',255
PAGE4TEXTINSTR11: db '                                ',255
PAGE4TEXTINSTR12: db '                                ',255
PAGE4TEXTINSTR13: db 'GAME VERSION 1.0 CREATED 20TH MA',255
PAGE4TEXTINSTR14: db 'RCH 2023                        ',255
PAGE4TEXTINSTR15: db '                                ',255
PAGE4TEXTINSTR16: db '                                ',255
PAGE4TEXTINSTR17: db '                                ',255
PAGE4TEXTINSTR18: db 'PRESS TO EXIT                   ',255

PAGE3bTEXTINSTR1:  db 'DRAW OVER EXISTING ART TO MAKE A',255
PAGE3bTEXTINSTR2:  db 'FULL PICTURE TO EXPRESS THE MEAN',255
PAGE3bTEXTINSTR3:  db 'ING OF THE WORDS TO BE GUESSED.I',255
PAGE3bTEXTINSTR4:  db 'N OTHER WORD MAKE THE ART FULL  ',255
PAGE3bTEXTINSTR5:  db 'BY BEING ARTFUL.                ',255
PAGE3bTEXTINSTR6:  db '                                ',255
PAGE3bTEXTINSTR7:  db '                                ',255
PAGE3bTEXTINSTR8:  db '                                ',255
PAGE3bTEXTINSTR9:  db '                                ',255
PAGE3bTEXTINSTR10: db '                                ',255
PAGE3bTEXTINSTR11: db '                                ',255
PAGE3bTEXTINSTR12: db '                                ',255
PAGE3bTEXTINSTR13: db '                                ',255
PAGE3bTEXTINSTR14: db '                                ',255
PAGE3bTEXTINSTR15: db '                                ',255
PAGE3bTEXTINSTR16: db '                                ',255
PAGE3bTEXTINSTR17: db '                                ',255
PAGE3bTEXTINSTR18: db 'PRESS TO EXIT                   ',255

 


PAGE3TEXTINSTR1:  db 'THE YOU DRAW ALL MODE IS SIMILAR',255
PAGE3TEXTINSTR2:  db 'TO ABOVE MODE EXCEPT THERE ARE  ',255
PAGE3TEXTINSTR3:  db 'NO EXISTING IMAGES TO DRAW OVER ',255
PAGE3TEXTINSTR4:  db 'TO START.ALSO THE PLAYERS DECIDE',255
PAGE3TEXTINSTR5:  db 'TWO SECRETLY CHOSEN ANSWERS FOR ',255
PAGE3TEXTINSTR6:  db 'THEIR DOODLES WHICH THEY WRITE  ',255
PAGE3TEXTINSTR7:  db 'BEFOREHAND ON PAPER TO REPRESENT',255
PAGE3TEXTINSTR8:  db 'BY THEIR DRAWING.THE ANSWERS NOT',255
PAGE3TEXTINSTR9:  db 'CHANGED DURING THE GAME.        ',255
PAGE3TEXTINSTR10: db 'THE PROGRAMMING LANGUAGE MODE   ',255
PAGE3TEXTINSTR11: db 'CAN BE USED TO PRACTICE DRAWING.',255
PAGE3TEXTINSTR12: db '                                ',255
PAGE3TEXTINSTR13: db '                                ',255
PAGE3TEXTINSTR14: db '                                ',255
PAGE3TEXTINSTR15: db '                                ',255
PAGE3TEXTINSTR16: db '                                ',255
PAGE3TEXTINSTR17: db '                                ',255
PAGE3TEXTINSTR18: db 'PRESS FOR NEXT                  ',255

PAGE2TEXTINSTR1:  db 'INSTRUCTIONS FOR A GAME WITH DRA',255
PAGE2TEXTINSTR2:  db 'W OVER IMAGES.ONE PLAYER CHOOSES',255
PAGE2TEXTINSTR3:  db 'AN EXISTING IMAGE TO DRAW OVER A',255
PAGE2TEXTINSTR4:  db 'ND MEMORISES THE ANSWER AT THE B',255
PAGE2TEXTINSTR5:  db 'OTTOM OF THE PAGE WHILE OTHER PL',255
PAGE2TEXTINSTR6:  db 'AYER LOOKS AWAY.ANSWER IS ONLY R',255
PAGE2TEXTINSTR7:  db 'EVEALED IF BUTTON PRESSED.WHEN T',255
PAGE2TEXTINSTR8:  db 'HE ANSWER IS CLEARED THE PLAYER ',255
PAGE2TEXTINSTR9:  db 'ATTEMPTS TO DRAW A REPERSENTATIO',255
PAGE2TEXTINSTR10: db 'N OF THE WORDS IN ANSWER AND SO ',255
PAGE2TEXTINSTR11: db 'ENTERS THE FINISHED IMAGE AS FIN',255
PAGE2TEXTINSTR12: db 'AL ANSWER. THE GUESSING PLAYER A',255
PAGE2TEXTINSTR13: db 'TTEMPS TO GUESS THE ANSWER FROM ',255
PAGE2TEXTINSTR14: db 'SEEING THE ENTERED ANSWER TO WIN',255
PAGE2TEXTINSTR15: db 'A POINT.PLAYERS ALTERNATE THE AS',255
PAGE2TEXTINSTR16: db 'AS ARTIST AND GUESSING PLAYER.  ',255
PAGE2TEXTINSTR17: db '                                ',255
PAGE2TEXTINSTR18: db 'PRESS FOR NEXT                  ',255

PAGE1TEXTINSTR1:  db 'GAME CONSISTS OF 4 DOODLES EACH.',255
PAGE1TEXTINSTR2:  db 'PLAYER WITH MOST POINTS AFTER 4 ',255
PAGE1TEXTINSTR3:  db 'DOODLES WINS GAME OTHERWISE A DR',255
PAGE1TEXTINSTR4:  db 'AW GAME.POINTS ARE SHOWN BY THE ',255
PAGE1TEXTINSTR5:  db 'NO. OF BLUE OR RED COUNTERS AT  ',255
PAGE1TEXTINSTR6:  db 'TOP LEFT.LONG PRESS LEFT ON 2ND ',255
PAGE1TEXTINSTR7:  db 'PADDLE DELETES YOUR DOODLE.LONG ',255
PAGE1TEXTINSTR8:  db 'PRESS 1 AND DOWN ON FIRST       ',255
PAGE1TEXTINSTR9:  db 'PADDLE ENTERS FINAL DOODLE.     ',255
PAGE1TEXTINSTR10: db 'FIRST PADDLE TO SELECT AND      ',255
PAGE1TEXTINSTR11: db 'ENTER DRAWING COMMANDS.PRESS 1  ',255
PAGE1TEXTINSTR12: db 'TO SELECT COMMAND.UP OR DOWN TO ',255
PAGE1TEXTINSTR13: db 'SELECT COMMAND VALUE. MAXIMUM   ',255
PAGE1TEXTINSTR14: db ' OF 69 DRAWING INSTRUCTIONS OR  ',255
PAGE1TEXTINSTR15: db '3 PAGES OF 23 INSTRUCTIONS.RIGHT',255
PAGE1TEXTINSTR16: db 'TO VIEW AN INSRUCTIONS PAGE     ',255
PAGE1TEXTINSTR17: db '                                ',255
PAGE1TEXTINSTR18: db 'PRESS FOR NEXT                  ',255


cluetypeI: db  '  IDIOM OR PROVERB',255;;;i (is the first char in message that encodes to show this message)
cluetypeO: db  '  OBJECT          ',255;;;o    
cluetypeP: db  '  PERSON          ',255;;;;p   
cluetypeC: db  '  CREATURE        ',255;;;;c     
cluetypeF: db  '  FOOD RELATED    ',255;;;;f   
cluetypeUSERDEFINED:db  '  ON YOUR PAPER   ',255;;;
blankoutwords:       db  '                  ',255
blankedanswer:     db 'i                            %',255;;;
	

thefont: 
      incbin "E:\Artfullgraphics\FONT.GRA"; 
thefontend:

Ahumangame:
      incbin "E:\Artfullgraphics\AHUMANGAME8CHARS.GRA"
Ahumangameend:

Viewingpageimage1:
    incbin "E:\Artfullgraphics\VIEWINGPAGE1.GRA"
Viewingpageimage1end:

Viewingpageimage2:
    incbin "E:\Artfullgraphics\VIEWINGPAGE2.GRA"
Viewingpageimage2end:

Viewingpageimage3:
    incbin "E:\Artfullgraphics\VIEWINGPAGE3.GRA"
Viewingpageimage3end:

arrowspagedivider:
      incbin "E:\Artfullgraphics\REDARROWSFORINSTR.GRA"
arrowspagedividerend

 org &400F




   ld hl,seed
 ld (hl),37
  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

 
frame:
    incbin "E:\Artfullgraphics\FRAME.GRA"
frameend:

menuTSarrow:
    incbin "E:\Artfullgraphics\MENUARROW.GRA"
menuTSarrowend:

CRCchar:;;;CopyRight Character
    incbin "E:\Artfullgraphics\CRC.GRA"
CRCcharend:

;;;buttons below for GUI in game or GUI in programming mode

Gridcrosspoint:
    incbin "E:\Artfullgraphics\GRIDCROSSPOINT.GRA"
Gridcrosspointend:

Keysbanner1:
    incbin "E:\Artfullgraphics\KEYSPART1.GRA"
Keysbanner1end:

Keysbanner2:
    incbin "E:\Artfullgraphics\KEYSPART2.GRA"
Keysbanner2end:

Keysbanner3:
    incbin "E:\Artfullgraphics\KEYSPART3.GRA"
Keysbanner3end:

Keygridtoggle:
    incbin "E:\Artfullgraphics\KEYGRIDTOGGLE.GRA"
Keygridtoggleend:

rightarrow:;;;different arrow from red one haS NO BEND IN IT
    incbin "E:\Artfullgraphics\NEXTPAGEINSTRARROW.GRA"
rightarrowend:


Twocharsnums:
      incbin "E:\Artfullgraphics\NUMS1AND2.GRA"
Twocharsnumsend:


Twocharsemiword:
    incbin "E:\Artfullgraphics\TWOCHARSEMIWORD.GRA"
Twocharsemiwordend:

TwocharUPEQUDOWNEQU:
  incbin "E:\Artfullgraphics\UPEQUDOWNEQU.GRA"
TwocharUPEQUDOWNEQUend:

Threecharscoreword:
    incbin "E:\Artfullgraphics\SCORE3CHARS.GRA"
Threecharscorewordend:

 
Charsayin1char:;;
      incbin "E:\Artfullgraphics\AYIN1CHAR.GRA"
Charsayin1charend:


CharsPLin1char:;
      incbin "E:\Artfullgraphics\PLIN1CHAR.GRA"
CharsPLin1charend:




HHcursortiles:
               
    incbin "E:\Artfullgraphics\HEDGEHOGCURSOR.GRA"
  
HHcursortilesend:

 	

song:db    'ABDECzABCDDxADDBCDEyAABCDEFxDAEACDEACDDEzDECAFFyDEAFFDACDEDFEDFDEFxDExDEDDEDyACDEFDFEDCCDEDAzCDEDEACDEACzFDECDEACFyDEACDDECADEFADCABCDFEACD',255;


circle24downshift:  db 1,1,1,1,1,1,1, 1,1,1,1,1,1,  1,2,1,2,2,3,255
circle24rightshift: db 2,2,2,2,2,1,1, 1,2,1,1,1,1,  1,1,1,1,1,1,255


circle16downshift:  db 1,1,1,1,1,1,1,1,2,2,1,3,255
circle16rightshift: db 2,2,1,2,1,1,1,2,1,1,1,1,255

circle8downshift:  db 1,2,2,3,255
circle8rightshift: db 2,2,2,2,255

circle4downshift:  db 1,2,255
circle4rightshift: db 2,2,255

 
pagein32Kto48Ktextforimages:
rompage48alias EQU &FFFF
   ld hl,&FFFC
 ld a,0
 ld (hl),a;;set it up for rom only

  ld hl,rompage48alias

  ld a,2
  ld (hl),a;;  ld hl,2 here pages in the bank at org &8001 
  ret



rng:
 push bc
 or a
 xor a
 ld a,r
 and 1
 ld b,a
 ld a, (seed2)
 add a,b
 ld b, a 
 rrca ; multiply by 32
 rrca
 rrca
 nop 
 xor 0x1f
 add a, b
 sbc a, 255 ; carry
 ld (seed2), a
 pop bc
 ret
; -----------------------------------------------------------------------------

setSOUNDvolume:
        	xor %11010100	;Set Volume
	out (&7F),a
    
   ret


doAdivisionof2:
   or a;reset carry
  and %1111110;
  rrca
  ret

drawcanvastoscreen:
   push de
 push bc
 push hl

    ld hl,VPOKETHIS
  ld a,16;;;the start tile to transfer to VDP
  ld b,CANVASXPOS;;x pos 
  ld c,CANVASYPOS;;y pos
  ld (hl),a

canvastoscreen:
  push ix
 pop ix
 push ix

  call vpoke

 pop ix

  
    ld hl,VPOKETHIS
    ld a,(hl)
    inc a
   ld (hl),a

    ld hl,XPOSLOOPTILES2SCR
    ld a,(hl)
       inc a
    ld (hl),a

    ld hl,XPOSLOOPTILES2SCR
    ld a,(hl)
    cp 16+CANVASXPOS
    call z,gotonextrow

    ;;;load x pos
    ld hl,XPOSLOOPTILES2SCR
    ld a,(hl)
    ld b,a

  ;;load y pos
   ld hl,YPOSLOOPTILES2SCR
   ld a,(hl)
   ld c,a
  ;;;test if end of whole canvas
   ld hl,YPOSLOOPTILES2SCR
   ld a,(hl)
   cp 16+CANVASYPOS
   jp z,finisheddrawing
   cp 16+CANVASYPOS-1
   call z,vpokeover255;;;
  jp canvastoscreen

finisheddrawing:
 call drawframe
 call drawarrowinstructions
 call renderinstructionsonce
  CALL blankleftedgePARTIAL
  call generecblankingforEVERYinstructionselect
  pop de
  pop bc
  pop hl



  ret

redrawinstructionafterplayersmessage:
    call renderinstructionsonce
    call generecblankingforEVERYinstructionselect
 ret

generecblankingforEVERYinstructionselect:
 push de
 push hl
 push bc
 push af

  push hl
 push af
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,(hl)
  cp 1
  jp z,skipfornotDRAWINGovertogglebuttonprogmode
  call delaysmallvdp
  writetext 5,0,blankout6char
skipfornotDRAWINGovertogglebuttonprogmode:
 pop af
 pop hl
 call delaysmallvdp
 CALL blankleftedgePARTIAL
 pop af
 pop bc
 pop hl
 pop de
  ret

delaysmallvdp:
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
 ret

blankleftedgePARTIAL:
    ld b,21
blankleftmostedgeloop2:
 ld iyl,b
 push bc
  push iy
  writetext &00,iyl,blankchar;
  push ix;;vdp delay
  pop ix
  nop
  writetext &01,iyl,blankchar;
  
  pop iy

 pop bc
  djnz blankleftmostedgeloop2
  ret



drawarrowinstructions:
  ld bc,&1217;;;the left arrow red
  ld hl,VPOKETHIS
  ld a,353-256
  ld (hl),a
  call vpokeover255

  ld bc,&1317;;;the right arrow red
  ld hl,VPOKETHIS
  ld a,351-256
  ld (hl),a
  call vpokeover255

  ld bc,&1301;;;the right arrow red
  ld hl,VPOKETHIS
  ld a,350-256
  ld (hl),a
  call vpokeover255

 ld b,21
verticalloopredarrowinnerpart:
  ld iyl,b
  push bc
  ld bc,&0113
  ld a,iyl
  add a,b
  ld b,a

;;;swap b and c
  ld a,c
  ld c,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,352-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz verticalloopredarrowinnerpart

  ret
  

drawframe:
  ld bc,&0103
  ld hl,VPOKETHIS
  ld a,344-256
  ld (hl),a
  call vpokeover255
  ld bc,&0103;;;
  ld b,18
  ld hl,VPOKETHIS
  ld a,345-256
  ld (hl),a
  call vpokeover255


 ld b,16
acroosloopframe:
  ld iyl,b
  push bc
  ld bc,&0103
  ld a,iyl
  add a,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,349-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz acroosloopframe

  ld bc,&0114;;; 
  ld hl,VPOKETHIS
  ld a,346-256
  ld (hl),a
  call vpokeover255
  ld bc,&0114;;; 
  ld b,18
  ld hl,VPOKETHIS
  ld a,347-256
  ld (hl),a
  call vpokeover255


 ld b,16
acroosloopframebottom:
  ld iyl,b
  push bc
  ld bc,&0114
  ld a,iyl
  add a,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,349-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz acroosloopframebottom


 ld b,16
downloopframebottom:
  ld iyl,b
  push bc
  ld bc,&0312
  ld a,iyl
  add a,b
  ld b,a

;;;swap b and c
  ld a,c
  ld c,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,348-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz downloopframebottom

 ld b,16
downloopframebottomleftside:
  ld iyl,b
  push bc
  ld bc,&0301;;
  ld a,iyl
  add a,b
  ld b,a

;;;swap b and c
  ld a,c
  ld c,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,348-256;;;
  ld (hl),a
  call vpokeover255
  pop bc
  djnz downloopframebottomleftside


  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shiftpositionfortileTitleScreenPicframe:
  
 
  push de
  push hl
  push af
  ld a,b
  add a,12
  ld b,a


  ld a,c
   dec a
   dec a
   dec a
  ld c,a

  pop af
  pop hl
  pop de
 
  ret

 

drawframonTITLESC:
 
  ld bc,&0103
    call shiftpositionfortileTitleScreenPicframe
   inc b
   inc b

  ld hl,VPOKETHIS
  ld a,344-256
  ld (hl),a
  call vpokeover255


 ld b,14
acroosloopframonTITLESC:
  ld iyl,b
  push bc
  ld bc,&0103
    call shiftpositionfortileTitleScreenPicframe
    inc b
    inc b
  ld a,iyl
  add a,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,349-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz acroosloopframonTITLESC

    ld bc,&0103;;;
  ld b,18
   call shiftpositionfortileTitleScreenPicframe
 

  ld hl,VPOKETHIS
  ld a,345-256
  ld (hl),a
  call vpokeover255



  ld bc,&0311;;; 
      call shiftpositionfortileTitleScreenPicframe
  ld hl,VPOKETHIS
  ld a,346-256
  ld (hl),a
  call vpokeover255
  ld bc,&0311;;; 
  ld b,18
 
      call shiftpositionfortileTitleScreenPicframe
  ld hl,VPOKETHIS
  ld a,347-256;;;
  ld (hl),a
  call vpokeover255

 


 ld b,14

acroosloopbottomoffreamonTITLETITLESC:
  ld iyl,b
  push bc
  ld bc,&0103;
    call shiftpositionfortileTitleScreenPicframe
    inc b
    inc b
   push af
    ld a,c
   add a,14
   ld c,a
  pop af
  ld a,iyl
  add a,b
  ld b,a
  ld hl,VPOKETHIS
  ld a,349-256;;
  ld (hl),a
  call vpokeover255
  pop bc
  djnz acroosloopbottomoffreamonTITLETITLESC


 ld b,13
downloopframonTITLESCbottom:
  ld iyl,b
  push bc
  ld bc,&0010

  ld a,iyl
  add a,b
  ld b,a

;;;swap b and c
  ld a,c
  ld c,b
  ld b,a
  dec b
  ld hl,VPOKETHIS
  ld a,348-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz downloopframonTITLESCbottom


 ld b,13
downloopframonTITLESCmostRIGHTonTITLE:
  ld iyl,b
  push bc
  ld bc,&0010
  ld a,iyl
  add a,b
  ld b,a

;;;swap b and c
  ld a,c
  ld c,b
  ld b,a
  push af
  ld a,b
  add a,14
  ld b,a
  pop af
  ld hl,VPOKETHIS
  ld a,348-256
  ld (hl),a
  call vpokeover255
  pop bc
  djnz downloopframonTITLESCmostRIGHTonTITLE
 
  ret



gotonextrow:
     ld a,CANVASXPOS;;;;doesnt start at 0
      ld hl,XPOSLOOPTILES2SCR
    ld (hl),a;;;reset xpos
     ld hl,YPOSLOOPTILES2SCR
    ld a,(hl)
     inc a
    ld (hl),a;;;inc x pos
  ret


write4VRAM:
 push de
 ld de,INKCOUNTERPARITYCOLOUR
 ld a,(de)
 inc a
 ld (de),a
 and 1;;make it 0 or 1 or its parity
 ld ixh,a
 pop de

 ld iyl,0;;reset nonce

 push de
 ld de,CHOOSEINKFLAG
 ld a,(de)
 pop de
 cp 0
 call z,solidinkcolor;;;0 is normal solid colour
 ld a,iyl
 cp 179
 jp z,done72130
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ld a,ixh
 cp 0;;ink parity
 call z,solidinkcolor
 ld a,iyl
 cp 179
 jp z,done72130

 ld a,ixh
 cp 1;;;ixh is 0 or 1
 call z,multicolourink
 ld a,iyl
 cp 180
 jp z,done72130


ignoreDOalterntingcolourink:
done72130:
   ret


solidinkcolor:
  

  push de
  ld de,THECOLOURBYTE1
  ld a,(de)
  pop de
   or h
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE2
  ld a,(de)
  pop de
   or h
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE3
  ld a,(de)
  pop de
    or h
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE4
  ld a,(de)
  pop de
   or h
  push hl
       out (&BE),a
  pop hl
  push af
  ld a,179
   ld iyl,a
  pop af
  ret



multicolourink:
 push de
  ld de,THECOLOURBYTE1
  ld a,(de)
  pop de
    or 0
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE2
  ld a,(de)
  pop de
   or h
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE3
  ld a,(de)
  pop de
    or h
  push hl
       out (&BE),a
  pop hl
  push de
  ld de,THECOLOURBYTE4
  ld a,(de)
  pop de
   or h
  push hl
       out (&BE),a
  pop hl
  push af
  ld a,180
  ld iyl,a
  pop af
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
computebufferadressfromxyinBC:
  ld hl,XPOSINPIXELS
  ld a,b
  ld (hl),a
  ld hl,YPOSINPIXELS
  ld a,c
  ld (hl),a

  ld a,b
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ld hl,XPOSINPIXELSI8
  ld (hl),a

  ld a,c
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ld hl,YPOSINPIXELSI8
  ld (hl),a

  ld hl,XPOSINPIXELS
  ld a,(hl)
  and %00000111
  ld hl,XPOSINPIXELSF8
  ld (hl),a

  ld hl,YPOSINPIXELS
  ld a,(hl)
  and %00000111
  ld hl,YPOSINPIXELSF8
  ld (hl),a



  ld hl,YPOSINPIXELSI8
  ld a,(hl)
  ld h,0
  ld l,a
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
 

  ld bc,XPOSINPIXELSI8
  ld a,(bc)
  ld b,0
  ld c,a
  add hl,bc


  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl



  ld bc,YPOSINPIXELSF8
  ld a,(bc)
   cp 0 
  jp z,dontdoloopcopy
 ld c,0
  ld b,a
addmuipltesof4yremaindercopy:
     inc hl
     inc hl
     inc hl
     inc hl
  djnz addmuipltesof4yremaindercopy
dontdoloopcopy:

 push hl
 ld bc,READ4TIMESTOADDLOWBYTE
 ld a,l
 ld (bc),a
 ld bc,READ4TIMESTOADDHUGHBYTE
 ld a,h
 ld (bc),a
 pop hl
   
 ld b,h
 ld c,l
 srl b
 rr c
 srl b
 rr c
 

 ld hl,SCREENBUFFERLOWBYTE;;;store adress for later manipulation it was divide b by 4 above
 ld a,c
 ld (hl),a
 ld hl,SCREENBUFFERHIGHBYTE
 ld a,b
 ld (hl),a
 ret
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 

initialisehedgehogcursorposition:
  
  ld b,POSBCINIT
  ld c,POSBCINIT
 push hl
  push af
  push de
  push bc

 ld hl,VARTHEHHCURSORPOS
 ld a,&52
 ld (hl),a
 ld hl,VARPLAYERPOSY
 ld a,&42
 ld (hl),a




 call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  pop bc
  pop de
  pop af
 pop hl
  ret
  


resetLOWy:
  ld c,24
  ret
resetLOWx:
  ld c,24
  ret


plotxyinBC:
   di 
 ;;;;;;;;;;;;;;;;;begin move hedgehog;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 push hl
  push af
  push bc

  ld hl,PENDOWNFLAG
  ld a,(hl)
  cp 0
   ld a,c
    and %01111111
    cp 0
    call z,resetLOWy
   add 32+5-8+4;;;y axis offset

   ld c,a
 StoreHHCURSORPOSXVAR c
   ld a,b
   and %01111111
   cp 0
    call z,resetLOWy
   add 32-16+5-8+3
  

   ld b,a
 StoreHHCURSORPOSYVAR b

 call moveHHcursorfordrawingleft;;;used to update hedge creates wiggle left to right
 call moveHHcursorfordrawingright

dontmovecursorifnotpixelsdrawn:
  pop bc
  pop af
 pop hl
 ;;;;;;;;;;;;;end move hedgehog;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ld hl,XPOSINPIXELS
  ld a,b
  ld (hl),a
  ld hl,YPOSINPIXELS
  ld a,c

   



  ld (hl),a

  ld a,b
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ld hl,XPOSINPIXELSI8
  ld (hl),a

  ld a,c
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ld hl,YPOSINPIXELSI8
  ld (hl),a

  ld hl,XPOSINPIXELS
  ld a,(hl)
  and %00000111
  ld hl,XPOSINPIXELSF8
  ld (hl),a

  ld hl,YPOSINPIXELS
  ld a,(hl)
  and %00000111
  ld hl,YPOSINPIXELSF8
  ld (hl),a


  ld hl,YPOSINPIXELSI8
  ld a,(hl)
  ld h,0
  ld l,a
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
 

  ld bc,XPOSINPIXELSI8
  ld a,(bc)
  ld b,0
  ld c,a
  add hl,bc


  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl
  add hl,hl

  

 LD BC,&0200;;;a base address
 add hl,bc
  dec hl
   

  ld bc,YPOSINPIXELSF8
  ld a,(bc)
   cp 0 
  jp z,dontdoloop
 ld c,0
  ld b,a
addmuipltesof4yremainder:
     inc hl
     inc hl
     inc hl
     inc hl
  djnz addmuipltesof4yremainder
dontdoloop:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ld a,l
   out (&BF),a
    ld a,H
   out (&BF),a

  

  ld hl,XPOSINPIXELSF8
  ld a,(hl)
  cp 7
  jp z,x7
  cp 6
  jp z,x6
  cp 5
  jp z,x5
  cp 4
  jp z,x4
  cp 3
  jp z,x3
  cp 2
  jp z,x2
  cp 1
  jp z,x1
  cp 0
  jp z,x0

x0:
  ld a,%10000000;;;byte representing pixel to be plotted
  jp finXoffset
x1:
  ld a,%01000000
  jp finXoffset
x2:
  ld a,%00100000
  jp finXoffset
x3:
  ld a,%00010000
  jp finXoffset
x4:
  ld a,%00001000
  jp finXoffset
x5:
  ld a,%00000100
  jp finXoffset
x6:
  ld a,%00000010
  jp finXoffset
x7:
  ld a,%00000001
  jp finXoffset

 
finXoffset:
  ld h,a
  ld d,h
 call includependownflag
 sub 0
 cp 0
 jp z,ignoredrawingbutmoveforPENUP
 
 ld hl,SCREENBUFFERLOWBYTE
  ld a,(hl)
 ld c,a
 ld hl,SCREENBUFFERHIGHBYTE
  ld a,(hl)
 ld b,a
  ld hl,SCREENBUFFER
 add hl,bc
  ld a,(hl)
  or d
  ld (hl),a
  ld d,a


 push hl
 push de
 push bc
 push af

  ld hl,SCREENBUFFERLOWBYTE
  ld a,(hl)
 ld e,a
 ld hl,SCREENBUFFERHIGHBYTE
  ld a,(hl)
 ld d,a

  ld h,d
  ld l,e
  add hl,hl
  add hl,hl
  ld d,h
  ld e,l

  
  push af
   push de

 
  ld de,ARTFULLIMAGEBASEADDRESSHIGHBYTE
  ld a,(de)
  ld h,a
  ld de,ARTFULLIMAGEBASEADDRESSLOWBYTE 
  ld a,(de)
  ld l,a
  pop de
  pop af

 call getfulcolouraddressofpicbyteHLaddressDEoffset
 pop af
 pop bc
 pop de
 pop hl


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld h,d
   call write4VRAM
ignoredrawingbutmoveforPENUP:
   ei
  ret

clearscreenbuffer:
 ld hl,SCREENBUFFER
loopclearscreenbuffer:
 ld a,0
 ld (hl),a
 inc hl
  ;;; cf00 is approx 53000
 ld a,h
 cp &CF
 jp z,finishedclearingscreenbuffer
 jp loopclearscreenbuffer
finishedclearingscreenbuffer:
 ret

plotxyBC:
   push bc
  call computebufferadressfromxyinBC
  pop bc
  push bc
  call plotxyinBC
  pop bc
  ret

drawr:
drawright:
 
 push de
 call plotxyBC
 pop de
 inc d
 ld a,d
 cp e
 jp z,finishdrawright
 inc b
 jp drawright
finishdrawright:

  ret

drawl:
drawleft:
 
 push de
 call plotxyBC
 pop de
 inc d
 ld a,d
 cp e
 jp z,finishdrawleft
 dec b
 jp drawleft
finishdrawleft:
 
  ret

drawu:
drawup:
 
 push de
 call plotxyBC
 pop de
 inc d
 ld a,d
 cp e
 jp z,finishdrawup
 dec c
 jp drawup
finishdrawup:

  ret

drawd:
drawdown:
 push de
 call plotxyBC
 pop de
 inc d
 ld a,d
 cp e
 jp z,finishdrawdown
 inc c
 jp drawdown
finishdrawdown:
  ret

includependownflag:
  push hl
  ld hl,PENDOWNFLAG
  ld a,(hl)
  pop hl
  ret

pendown:
  push af
   push hl
  ld hl,PENDOWNFLAG
  ld a,1
  ld (hl),a
  pop hl
  pop af
 ret

penup:
  push af
  push hl
  ld hl,PENDOWNFLAG;;;note there is no "PENUP" flag as its just the oppsite of this
  ld a,0
  ld (hl),a
  pop hl
  pop af
 
 ret
  
drawrr:
  ld d,0
  push af
  push de
 call drawr
 pop de
 pop af

  ret

drawll:;;drawllis like drawl that draw left e pixel (uses register e)
  ld d,0
  push af
  push de
 call drawl
 pop de
 pop af
  ret

drawuu:
  ld d,0
  push af
  push de
 call drawu
 pop de
 pop af
  ret

drawdd:
  ld d,0
  push af
  push de
 call drawd
 pop de
 pop af
  ret


  
  
constructcommandHLandaddtoMergeDrawprogram:
 ;;;l comtand the value -operand-of the command
 ;;;h contans the command (0 to 7)
 ld a,h
 add a,a
 add a,a
 add a,a
 add a,a
 add a,a;;;shift to left 5 bits
 add a,l
 ;;; a contains instrction
 ld hl,CURRENTCCONSTRUCTEDCOMMAND
 ld (hl),a;;;stores the current command constructed
 call addMergeDrawinstractioninAtoram

 ret

selectpagefromPCsize:
   ;;;0 23
   ;;;24 47
   ;;;48 71
     push hl
     push af
      
    ld hl,MergeDrawPCCOUNTERFOREXECUTING
    ld a,(hl)
    ld d,a
   sub 23;;compare for 1st page
   jp c,selectpage0;;;if it is from 0 to 23
   or a
   xor a
   or a
   xor a
  ld a,d
    sub 46;;;;compare for last page
    jp nc,selectpage2;;;by testing end pages first then second it quicker to code since last page is just simply a jump (no comparisons)
   jp selectpage1;;;must be the middle page
selectpage0: 
   ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,0
   ld (hl),a
   jp doneselectingMergeDrawpageusingPCsize
selectpage1: 
   ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,1
   ld (hl),a
   jp doneselectingMergeDrawpageusingPCsize
selectpage2:
   ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,2
   ld (hl),a
   jp doneselectingMergeDrawpageusingPCsize
doneselectingMergeDrawpageusingPCsize:
    pop af
    pop hl
  ret



addMergeDrawinstractioninAtoram:
  push bc
  ld hl,MergeDrawPCCOUNTER
  ld a,(hl)
  inc a
  ld (hl),a;;; inc the MergeDraw PC
  ld bc,0
  ld c,a;;;clear bc set it to a the PC 
  dec bc;;;compensates for  pc such that Mergedraw progrmas starts at c900
  ld hl,MergeDrawPROGRAMRAMTOP
  add hl,bc;;;hl now contans where to store the program instruction
    ld bc,CURRENTCCONSTRUCTEDCOMMAND
      ld a,(bc);;;store the inst to store
   ld (hl),a;;;stores the instruction
  pop bc
  ret 


clearMergeDrawprogramtoNONEcommands:

    ld hl,MergeDrawPROGRAMRAMTOP
clearloop:
    ld a,EMPTYMEMORYFORCMD
    ld (hl),a
    ld a,l
    cp &80;;;clears it up to C980
    jp z,finlooop
    inc hl
  jp clearloop
finlooop:
   ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interpretMergeDrawprogram:

  call pendown
   ld b,POSBCINIT
  ld c,POSBCINIT

   ld ixh,0
  ld hl,MergeDrawPCCOUNTERFOREXECUTING
  ld a,0
  ld (hl),0
  ld (hl),a
  ld hl,MergeDrawLOOPDETECTEDFLAG 
  ld a,0
  ld (hl),a
  ld hl,MergeDrawPROGRAMRAMTOP

 
MergeDrawcmdincludeloop:
  ld a,(hl)
MergeDrawcmdincludeloopENTRYpointforMergeDrawLOOP:
  cp EMPTYMEMORYFORCMD
  jp z,finishedincludeing;;;;since the size of RAM program block is always going to be bigger than actual Mergedraw program it must end with the dummy val
  
 
  ld a,(hl)
  and %00011111
  ld e,a;;;load the value


  xor a 
  or a

  ld a,(hl)
  and %11100000
  srl a
  srl a
  srl a
  srl a
  srl a
 sub 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;code added for repeat command;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      push hl
    push af
 cp REPEATCOMMAND 
  jp nz,ignoreloopstuff;;;ignore code if not a loop code
    ;;;if it is a loop detected then set the flag
  


  ld hl,MergeDrawLOOPDETECTEDFLAG
  ld a,(hl)
    sub 0
  cp 1
  jp z,doonceifloop
  ;;;if the flag isnt set store the loop value (so it can be decrmented as needs be later)
  push af
  push hl
  push de

    ld hl,MergeDrawLOOPVALUE 
  ld a,e
  dec a;;;;this is required to match the loop number shown to what is drawn -except 0 
  ld (hl),a

  ld hl,MergeDrawLOOPDETECTEDFLAG 
  ld a,1
  ld (hl),a

  ld hl,MergeDrawPCCOUNTERFOREXECUTING 
  ld a,(hl)
  ld hl,MergeDrawLOOPSTARTPOSITION 
  ld (hl),a;;;;copy the position as it is start of loop


  pop de
  pop hl
  pop af



doonceifloop:
  

ignoreloopstuff:
  pop af
  pop hl


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end code for repeat command;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
  push de
  push af
 cp PENDOWNCOMMAND
  jp nz,ingorepencommands
     ld a,e
    cp PENDOWNTRUE
    call z, pendown
    ld a,e
      cp PENDOWNFALSE
    call z, penup
ingorepencommands:
  pop af
  pop de

  push de
  push af
   cp CIRCLECOMMAND
  jp nz,ingorecirclecommands
  push hl
  ld hl,CIRCLEDIAMETERCHOICE;;;;passed from e
  ld a,e
  ld (hl),a

  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld (hl),a;;;CORRECTCURSORIFSEMICIRCLEDRAWN is 7 6 5 4 

  pop hl
  call drawcircle
ingorecirclecommands:
  pop af
  pop de
 

  cp DRAWRIGHTCOMMAND
   call z,drawrr

  cp DRAWDOWNCOMMAND
  call z,drawdd

 cp DRAWLEFTCOMMAND
 call z,drawll
 
 cp DRAWUPCOMMAND
   call z, drawuu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  push af
  push hl
 cp ENDREPEATCOMMAND
 jp nz,ignoreendrepeatloopstuff

  push af
  push hl
  push de
    ld hl,MergeDrawLOOPVALUE 
    ld a,(hl);;;
    cp 0
   jp z,finishedoingrepeatMergeDrawloop 
      ld hl,MergeDrawLOOPVALUE 
      ld a,(hl)
      dec a
      ld (hl),a;;;decreases no of times
        ld hl,MergeDrawLOOPSTARTPOSITION
        ld a,(hl)
         ld hl,MergeDrawPCCOUNTERFOREXECUTING
           ld (hl),a;;;move loop counter back to start of loop in mergedraw pragram
           
finishedoingrepeatMergeDrawloop:
         ld hl,MergeDrawLOOPDETECTEDFLAG 
         ld a,0;;;reset flag for detection of next loop ;;
         ld (hl),a
   pop de
  pop hl
  pop af
ignoreendrepeatloopstuff:
 pop hl
  pop af

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  

  push bc;;;need to make counter like this instead of just using hl becuase hl is corrupted by calls abopve

  ld hl,MergeDrawPCCOUNTERFOREXECUTING;
  ld a,(hl)
  inc a
  ld (hl),a;;;stored inc pc MergeDraw
  ld bc,0
  ld c,a
  
  ld hl,MergeDrawPROGRAMRAMTOP
  add hl,bc
  pop bc

  jp MergeDrawcmdincludeloop
finishedincludeing:
    
   ret

drawtoprightarc:
  
circlesubelementdrawingloop:
 push hl
 push de

 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords
 ld bc,0
 ld c,a

 call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e;;;min is 2 for drawing for e here
     pop bc
 call drawrr
 pop de
 pop hl
 push hl
 push de
 ;;;;;;;;
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords here
 ld bc,0
 ld c,a

 call loadbaseadressforCIRCLEtypechoceupORdownshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e;;;min is 2 for drawing
     pop bc
 call drawdd
 pop de
 pop hl


 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
 inc a
 ld (hl),a

 push hl
 push bc
  ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords
 ld bc,0
 ld c,a

 call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
   pop bc
 pop bc
 pop hl
 sub 0
 cp 255;;;if a is 255 it is ended
  jp z,endrawingcirclearc
 jp circlesubelementdrawingloop
;;;;;;;;;;;;;;;;;;;;;;;;
endrawingcirclearc:


  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawtopleftarc:
circlesubelementdrawingloop2:
 push hl
 push de

 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc
 ld bc,0
 ld c,a
 
  call   loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e;;;min is 2 for drawing
     pop bc
 call drawll
 pop de
 pop hl
 
 push hl
 push de
 ;;;;;;;;
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords
 ld bc,0
 ld c,a
 
 call loadbaseadressforCIRCLEtypechoceupORdownshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e
     pop bc
 call drawdd
 pop de
 pop hl
 
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
 inc a
 ld (hl),a

 push hl
 push bc
  ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords
 ld bc,0
 ld c,a
  call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
   pop bc
 pop bc
 pop hl
 sub 0
 cp 255;;;if a is 255 it is ended
  jp z,endrawingcirclearc2
 jp circlesubelementdrawingloop2
;;;;;;;;;;;;;;;;;;;;;;;;
endrawingcirclearc2:

  ret
;;;;;;;;;;;;;;;;;;;;;;;;;
drawbottomleftarc:
circlesubelementdrawingloop33:
 push hl
 push de
 ;;;;;;;
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;
 ld bc,0
 ld c,a
 call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e;;;min is 2 for drawing
     pop bc
 call drawll
 pop de
 pop hl

 push hl
 push de
 ;;;;;;;;
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc;;;preserves MergeDraw coords
 ld bc,0
 ld c,a
 
  call loadbaseadressforCIRCLEtypechoceupORdownshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e;;;min is 2 for drawing
     pop bc
 call drawuu
 pop de
 pop hl
 ;;;;;;;;;;;;;;; 
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
 inc a
 ld (hl),a

 push hl
 push bc
  ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc
 ld bc,0
 ld c,a
 
    call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 pop bc
 pop bc
 pop hl
 sub 0
 cp 255
  jp z,endrawingcirclearc33
 jp circlesubelementdrawingloop33

endrawingcirclearc33:
  ret


drawbottomrightarc:
circlesubelementdrawingloop44:
 push hl
 push de
 
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc
 ld bc,0
 ld c,a
 
  call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e
     pop bc
 call drawrr
 pop de
 pop hl
 
 push hl
 push de

 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc
 ld bc,0
 ld c,a
 
  call loadbaseadressforCIRCLEtypechoceupORdownshift
 add hl,bc
 ld a,(hl)
 ld e,a
 inc e
     pop bc
 call drawuu
 pop de
 pop hl
 
 ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
 inc a
 ld (hl),a

 push hl
 push bc
  ld hl,CIRCLEPTRCOUNTER
 ld a,(hl)
    push bc
 ld bc,0
 ld c,a

  call loadbaseaddressforCIRCLEtypechoiceleftORrightshift
 add hl,bc
 ld a,(hl)
 pop bc
 pop bc
 pop hl
 sub 0
 cp 255
  jp z,endrawingcirclearc44
 jp circlesubelementdrawingloop44
endrawingcirclearc44:
  ret
 



loadbaseadressforCIRCLEtypechoceupORdownshift:
  push af
  ld hl,CIRCLEDIAMETERCHOICE
  ld a,(hl)
  cp 0
  jp z,loadsmallestcircle
  cp 1
  jp z,loadsmallcircle
  cp 2
  jp z,loadmediumcircle
  cp 3
  jp z,loadlargestcircle

  cp 4
  jp z,loadsmallestcircle
  cp 5
  jp z,loadsmallcircle
  cp 6
  jp z,loadmediumcircle
  cp 7
  jp z,loadlargestcircle

loadsmallestcircle:
 ld hl,circle4downshift
 jp end21
loadsmallcircle:
 ld hl,circle8downshift
 jp end21
loadmediumcircle:
 ld hl,circle16downshift
 jp end21
loadlargestcircle:
 ld hl,circle24downshift



 
end21:
   pop af
 ret

 

loadbaseaddressforCIRCLEtypechoiceleftORrightshift:
  push af
  ld hl,CIRCLEDIAMETERCHOICE
  ld a,(hl)
  cp 0
  jp z,loadsmallestcirclefor0123ORsemicirclefor4567
  cp 1
  jp z,loadsmallcirclefor0123ORsemicirclefor4567
  cp 2
  jp z,loadmediumcirclefor0123ORsemicirclefor4567
  cp 3
  jp z,loadlargestcirclefor0123ORsemicirclefor4567
  cp 4
  jp z,loadsmallestcirclefor0123ORsemicirclefor4567
  cp 5
  jp z,loadsmallcirclefor0123ORsemicirclefor4567
  cp 6
  jp z,loadmediumcirclefor0123ORsemicirclefor4567
  cp 7
  jp z,loadlargestcirclefor0123ORsemicirclefor4567
loadsmallestcirclefor0123ORsemicirclefor4567:
 ld hl,circle4rightshift
 jp end21
loadsmallcirclefor0123ORsemicirclefor4567:
 ld hl,circle8rightshift
 jp end21
loadmediumcirclefor0123ORsemicirclefor4567:
 ld hl,circle16rightshift
 jp end21
loadlargestcirclefor0123ORsemicirclefor4567:
 ld hl,circle24rightshift
 jp end2122

end2122:
   pop af
 ret


pendowncirclereducestoaddindiameter:
 push de
 push hl
 ld hl,CIRCLEDIAMETERCHOICE
 ld a,(HL)
 cp 0
 jp z,add8toY
 cp 1
 jp z,add15toY
 cp 2
 jp z,add31toY
 cp 3
 jp z,add47toY
add8toY:
  ld a,c
  add a,6
  ld c,a
  jp doneaddinginvisiblediameter
add15toY:
  ld a,c
  add a,16
  ld c,a
  jp doneaddinginvisiblediameter
add31toY:
  ld a,c
  add a,32
  ld c,a
  jp doneaddinginvisiblediameter
add47toY:
  ld a,c
  add a,48
  ld c,a
  jp doneaddinginvisiblediameter
doneaddinginvisiblediameter:

 pop hl
 pop de
 ret

moveHHbottomofinvisiblecircleduetopenup: 
  push bc
  push de
  push hl
  push af
  ReadHHCURSORPOSXVAR 0;
  add a,48
  ld e,a
  StoreHHCURSORPOSXVAR e;
  call moveHHcursorfordrawingleft
  call moveHHcursorfordrawingright
  pop af
  pop hl
  pop de
  pop bc
 
  ret
 
  
 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;draw circle
drawcircle:
 push hl
 ld hl,PENDOWNFLAG
 ld a,(HL)
 pop hl
  push af
  cp 0
  call z,pendowncirclereducestoaddindiameter;;;DEALS WITH FULL CIRCLE CHOISES
  pop af
   cp 0
   jp z,pendowncirclereducestoaddindiametev2;;;semi ellipse does nothing as start=finish point
  call pendown
 ld hl,CIRCLEDIAMETERCHOICE
 ld a,(hl)
 cp 7
 jp z,penmovedfordrawingnextarcs
 cp 5
 jp z,penmovedfordrawingnextarcs
 cp 6
 call z,pendown
 cp 4
 call z,pendown


  push hl
  ld hl,CIRCLEPTRCOUNTER
  ld a,0
  ld (hl),a
  pop hl
 push af
 push hl
 push de
 push bc
 call drawtoprightarc
 pop bc
 pop de
 pop hl
 pop af
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  push hl
  ld hl,CIRCLEPTRCOUNTER
  ld a,0
  ld (hl),a
  pop hl
 push af
 push hl
 push de
 push bc
 call drawtopleftarc
 pop bc
 pop de
 pop hl
 pop af
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ld hl,CIRCLEDIAMETERCHOICE
 ld a,(hl)
 cp 0
 jp z,smallestcircle
 cp 1
 jp z,smallcircle
 cp 2
 jp z,mediumcircle
 cp 3
 jp z,largestcircle
 cp 4
 jp z,smallestcircle
 cp 5
 jp z,smallcircle
 cp 6
 jp z,mediumcircle
 cp 7
 jp z,largestcircle
 
smallestcircle:
 ld a,6
 add a,c
 ld c,a
 jp penmovedfordrawingnextarcs
smallcircle:
 ld a,15
 add a,c
 ld c,a
  jp penmovedfordrawingnextarcs
mediumcircle:
 ld a,31
 add a,c
 ld c,a
  jp penmovedfordrawingnextarcs
largestcircle:
 ld a,47
 add a,c
 ld c,a



penmovedfordrawingnextarcs:
  call pendown
 ld hl,CIRCLEDIAMETERCHOICE
 ld a,(hl)
 cp 7
 call z,pendown
 cp 5
 call z,pendown
 cp 6
 call z,penup
 cp 4
 call z,penup



  push hl
  ld hl,CIRCLEPTRCOUNTER
  ld a,0
  ld (hl),a
  pop hl
 push af
 push hl
 push de
 push bc
 call drawbottomrightarc
 pop bc
 pop de
 pop hl
 pop af



  push hl
  ld hl,CIRCLEPTRCOUNTER
  ld a,0
  ld (hl),a
  pop hl
 push af
 push hl
 push de
  push bc
 call drawbottomleftarc


  pop bc
 pop de
 pop hl

 pop af

 ld hl,CIRCLEDIAMETERCHOICE
 ld a,(hl)
 cp 4
 jp z,smallestcirclecorect
 cp 6
 jp z,mediumcirclecorrect
 jp donesemicirclecorrection
smallestcirclecorect:

 ld a,c
 sub 6
 ld c,a
 jp donesemicirclecorrection
mediumcirclecorrect:
 ld a,c
 sub 31
 ld c,a
  jp donesemicirclecorrection
donesemicirclecorrection:
 call pendown


 push hl
 ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
 ld a,(hl)
 pop hl
 cp 7
 call z,semicircle7correction;;put the hedgehog  cursor in same place to where it started drawing the semi circle
 cp 5
 call z,semicircle5correction
 cp 6
 call z,semicircle6correction
 cp 4
 call z,semicircle4correction
 cp 3
 call z,fullcircle3correction
 cp 1
 call z,fullcircle1correction
 cp 2
 call z,fullcircle2correction
 cp 0
 call z,fullcircle0correction
pendowncirclereducestoaddindiametev2:
 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
correctaftercircle:
   call penup
   call pendown
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fullcircle3correction:
semicircle7correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,24
 ld e,a
 StoreHHCURSORPOSYVAR e

 ReadHHCURSORPOSXVAR 0
 add a,24
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret



 
 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveHHtosecondtolastpixelplottedbyHH:
pastrightcheck:;;;makes it follow last pixel drawn
  push bc
  push af
  push hl
  push de

  ld d,0
  xor a
  or a
  ld a,b
  sub 50
  ld d,a
  xor a
  or a
  ld a,c
  sub 50
  add a,d
  cp 0
  jp z,dontgobacktoSTART

  ld a,b
  add a,24
  ld e,a
  StoreHHCURSORPOSXVAR e;
  

  ld a,c
  add a,24
  ld e,a
  StoreHHCURSORPOSYVAR e;
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
 jp end23423
dontgobacktoSTART:

end23423: 


   pop de
   pop hl
   pop af
   pop bc
 
  ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fullcircle1correction:
semicircle5correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,8
 ld e,a
 StoreHHCURSORPOSYVAR e
 ReadHHCURSORPOSXVAR 0
 add a,8
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret


fullcircle2correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,16
 ld e,a
 StoreHHCURSORPOSYVAR e
 ReadHHCURSORPOSXVAR 0
 add a,16
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret

semicircle6correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,16
 ld e,a
 StoreHHCURSORPOSYVAR e
 ReadHHCURSORPOSXVAR 0
 sub a,16
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret

fullcircle0correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,4
 ld e,a
 StoreHHCURSORPOSYVAR e
 ReadHHCURSORPOSXVAR 0
 add a,4
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret



semicircle4correction:
 push af
 push hl
 push de
 push bc
 ReadPLAYERPOSYVAR 0
 add a,4
 ld e,a
 StoreHHCURSORPOSYVAR e
 ReadHHCURSORPOSXVAR 0
 sub a,4
 ld e,a
 StoreHHCURSORPOSXVAR e
  call moveHHcursorfordrawingleft
 call moveHHcursorfordrawingright
  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
 ld (hl),a
  pop bc
  pop de
  pop hl
 pop af
   ret


  

vpoke:
   ld h,0
   ld l,c
  
   add hl,hl; mult 2
   add hl,hl;
   add hl,hl;
   add hl,hl;
   add hl,hl;
   ld c,b;;
   ld b,0
   add hl,bc
   add hl,hl;; 
   ld bc,&3801
   add hl,bc
   ld a,l
   out (&BF),a
   ld a,h
   
   out (&BF),a


   ld hl,VPOKETHIS
  ld a,(hl)
    
     out (&BE),a
    ld a,0
     out (&BE),a
   ret


vpokeover255:
   ld h,0
   ld l,c
   add hl,hl; mult 2
   add hl,hl;
   add hl,hl;
   add hl,hl;
   add hl,hl;
   ld c,b;
   ld b,0
   add hl,bc
   add hl,hl
   ld bc,&3801
   add hl,bc
   ld a,l
   out (&BF),a
   ld a,h
   
   out (&BF),a



	;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ld hl,VPOKETHIS
  ld a,(hl)
   
     out (&BE),a
    ld a,1
     out (&BE),a
   ret
 

vpokeover255ver2:

   ld h,0
   ld l,c
   add hl,hl; mult 2
   add hl,hl;
   add hl,hl;
   add hl,hl;
   add hl,hl;
   ld c,b;;
   ld b,0
   add hl,bc
   add hl,hl;;
   ld bc,&3801
   add hl,bc
   dec hl
   ld a,l
   out (&BF),a
   ld a,h
 
   out (&BF),a


   ld hl,VPOKETHIS
  ld a,(hl)
     out (&BE),a
    ld a,1
     out (&BE),a
   ret

vpokechar:
   ld h,0
   ld l,c
   add hl,hl; 
   add hl,hl;
   add hl,hl;
   add hl,hl;
   add hl,hl;
   ld c,b;;
   ld b,0
   add hl,bc
   add hl,hl;;
   ld bc,&3800-&01;;;3800 is start of the VRAM table
   add hl,bc
   ld a,l
   out (&BF),a
   ld a,h 
   out (&BF),a
   ld hl,VPOKETHIS
  ld a,(hl)
 cp '.'
 jp z,loadthefullstop
 cp ' '
 jp z,loadthespace

  cp 'a'
  jp z,loadnowchar1of2
  cp 'b'
  jp z,loadnowchar2of2

  cp 't'
  jp z,loadcirclechar1of4
  cp 'q'
  jp z,loadcirclechar2of4
  cp 'v'
  jp z,loadcirclechar3of4
  cp 'w'
  jp z,loadcirclechar4of4
 cp 'x'
   jp z,loadSE;;;se in SEMICIRCLE
 cp 'z'
   jp z,loadMI
 cp 'u'
  jp z,loadUPequals
 cp 'd'
  jp z,loadDOWNequals

  cp 's'
  jp z,loadSCOREas3charschar1
  cp 'c'
  jp z,loadSCOREas3charschar2
  cp 'o'
  jp z,loadSCOREas3charschar3
  cp 'l'
  jp z,loadAYinPLAYas2chars
  cp 'p'
  jp z,loadAPLinPLAYas2chars


 

  ld d,a
  sub 63;;;
  jp c,writenum
writeletter:
  ld a,d
  sub 29;;;;65 is 29 her for A
    ;;;ld a,44;;;little endian write tile number first
     out (&BE),a
    ld a,1
     out (&BE),a
   jp end45645
writenum:
  ld a,d
  sub 42
     out (&BE),a
    ld a,0
     out (&BE),a
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadthefullstop:
   ld a,333-256;;;tile 333 is fill stop

     out (&BE),a
    ld a,1
     out (&BE),a
      jp end45645
loadthespace:
   ld a,334-256;
     out (&BE),a
    ld a,1;;
     out (&BE),a;;;
      jp end45645
loadSE:
   ld a,337-256;;;
     out (&BE),a
    ld a,1;;
     out (&BE),a;;
      jp end45645
loadMI:
   ld a,338-256;;
     out (&BE),a
    ld a,1;;
     out (&BE),a;
      jp end45645
loadcirclechar1of4:
     ld a,1;;
     out (&BE),a
    ld a,0;;;
     out (&BE),a;;
      jp end45645 
loadcirclechar2of4:
     ld a,2;;
     out (&BE),a
    ld a,0;;
     out (&BE),a;
      jp end45645 
loadcirclechar3of4:
     ld a,3;
     out (&BE),a
    ld a,0;;
     out (&BE),a;;
      jp end45645 
loadcirclechar4of4:
     ld a,4;;
     out (&BE),a
    ld a,0;
     out (&BE),a;;
      jp end45645 
loadnowchar1of2:
       ld a,5;;
     out (&BE),a
    ld a,0;;
     out (&BE),a

        jp end45645 
loadnowchar2of2:
       ld a,6;
     out (&BE),a
    ld a,0;
     out (&BE),a
          jp end45645 
loadUPequals:
   ld a,339-256;;
     out (&BE),a
    ld a,1;
     out (&BE),a;;
      jp end45645

loadDOWNequals:
   ld a,340-256;;
     out (&BE),a
    ld a,1;;
     out (&BE),a;
      jp end45645
loadSCOREas3charschar1:
   ld a,341-256;
     out (&BE),a
    ld a,1;;
     out (&BE),a;;
    jp end45645
loadSCOREas3charschar2:
   ld a,342-256;;
     out (&BE),a
    ld a,1;;;
     out (&BE),a;;
    jp end45645
loadSCOREas3charschar3:
   ld a,343-256;;
     out (&BE),a
    ld a,1;;
     out (&BE),a;;
      jp end45645
loadAYinPLAYas2chars:
    ld a,440-256;
     out (&BE),a
    ld a,1;;
     out (&BE),a;;
       jp end45645
loadAPLinPLAYas2chars:
       ld a,427-256;;
     out (&BE),a
    ld a,1;;;
     out (&BE),a;;
       jp end45645
end45645:
   ret

 


 


computermodulo10ofA:
modloop:
   sub 10
   jp c,correctifnegative
  jp modloop
correctifnegative:
  add 10
  ret


Aroundedtonearest10:
  push de
  ld d,a
modloopb:
   sub 10
   jp c,correctifnegative2
  jp modloopb
correctifnegative2:
  add 10
  ld e,a
  ld a,d
  sub e
  pop de
  
  ret


divideAby10:
  cp 0
  jp z,d0
  cp 10
  jp z,d10
  cp 20
  jp z,d20
  cp 30
  jp z,d30
  cp 40
  jp z,d40
  cp 50
  jp z,d50
  cp 60
  jp z,d60
  cp 70
  jp z,d70
  cp 80
  jp z,d80

  cp 90
  jp z,d90
  cp 100
  jp z,d100
  cp 110
  jp z,d110
  cp 120
  jp z,d120
  cp 130
  jp z,d130
  cp 140
  jp z,d140
  cp 150
  jp z,d150
  cp 160
  jp z,d160
  cp 170
  jp z,d170
  cp 180
  jp z,d180
  cp 190
  jp z,d190
  cp 200
  jp z,d200
  cp 210
  jp z,d210
  cp 220
  jp z,d220
  cp 230
  jp z,d230
  cp 240
  jp z,d240
  cp 250
  jp z,d250
d0:
  ld a,0
  jp enddiv
d10:
  ld a,1
  jp enddiv
d20:
  ld a,2
  jp enddiv
d30:
  ld a,3
  jp enddiv
d40:
  ld a,4
  jp enddiv
d50:
  ld a,5
  jp enddiv
d60:
  ld a,6
  jp enddiv

d70:
  ld a,7
  jp enddiv
d80:
  ld a,8
  jp enddiv
d90:
  ld a,9
  jp enddiv
d100:
  ld a,10
  jp enddiv
d110:
  ld a,11
  jp enddiv
d120:
  ld a,12
  jp enddiv

d130:
  ld a,13
  jp enddiv
d140:
  ld a,14
  jp enddiv
d150:
  ld a,15
  jp enddiv
d160:
  ld a,16
  jp enddiv
d170:
  ld a,17
  jp enddiv


d180:
  ld a,18
  jp enddiv
d190:
  ld a,19
  jp enddiv
d200:
  ld a,20
  jp enddiv
d210:
  ld a,21
  jp enddiv
d220:
  ld a,22
  jp enddiv

d230:
  ld a,23
  jp enddiv
d240:
  ld a,24
  jp enddiv
d250:
  ld a,25
  jp enddiv
enddiv:
  ret


  
loadnumbertodiplayintoa:
 push hl
 ld hl,NUMTODISPLAY
 ld a,(hl)
 pop hl
 ret

setcursordisplay3digitnumberinAposinBC:
  push hl
 push bc;;;
  ld hl,PRINTNUMBERXPOS
  ld a,b
  inc a
  ld (hl),a
  ld hl,PRINTNUMBERYPOS
  ld a,c
  ld (hl),a
  pop bc
  pop hl
  ret


display3digitnumberinAposinBC:
  push bc
  push hl
  ld hl,NUMTODISPLAY
  ld (hl),a
  pop hl

 

 call loadnumbertodiplayintoa
 call computermodulo10ofA
 push hl
 push af
 ld hl,DIGIT3
 ld (hl),a
 pop af
 pop hl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 call loadnumbertodiplayintoa
 call Aroundedtonearest10
 call divideAby10;;;2nd digit processing 
 call computermodulo10ofA;;
 push hl
 push af
 ld hl,DIGIT2
 ld (hl),a
 pop af
 pop hl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 call loadnumbertodiplayintoa
 call Aroundedtonearest10
 call divideAby10;
 call Aroundedtonearest10
 call divideAby10;
 push hl
 push af
 ld hl,DIGIT1
 ld (hl),a
 pop af
 pop hl



 ld hl,DIGIT2
 ld a,(hl)
 call writeadigit
 
 ld hl,DIGIT3
 ld a,(hl)
 call writeadigit
 pop bc
 ret

display3digitnumberinAposinBCsetcurosor:
   push hl
   push af
  push bc
  call setcursordisplay3digitnumberinAposinBC
  pop bc
  pop af
  call display3digitnumberinAposinBC
  pop hl
 ret

writeHLstringwithvpokexyposBC:
   push hl
   push bc
   push de
   push af


       ld de,VPOKEMESSAGEADDRESSLOWBYTE
       ld a,l
       ld (de),a
       ld de,VPOKEMESSAGEADDRESSHIGHBYTE
       ld a,h
       ld (de),a
   ld de,VPOKESTRINGXPOS
   ld a,b
   ld (de),a
 
    ld de,VPOKESTRINGYPOS
     ld a,c
    ld (de),a

   ld de,VPOKESTRINGPOSINSTRING
     ld a,0
    ld (de),a
gotonextcharinstring:
    

     LD de,VPOKEMESSAGEADDRESSLOWBYTE
     ld a,(de)
     ld l,a
     LD de,VPOKEMESSAGEADDRESSHIGHBYTE
     ld a,(de)
     ld h,a

     ld de,VPOKESTRINGPOSINSTRING
     ld a,(de);;
     ld e,a;;;
     ld d,0
     add hl,de
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ld a,(hl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;comput coorsds for across;;;;;;;;;;;;;;;;;;;;;;;
    push af
     ld de,VPOKESTRINGXPOS
     ld a,(de)
     inc a
     ld (de),a
     ld b,a 
   
   

    ld de,VPOKESTRINGYPOS
     ld a,(de)
      ld c,a
     pop af

   cp 255
     jp z,finishedstringwriting
     cp '%'
     call z,gotonewline
     cp '%'
    jp z,skipprintingnewlineasgarbage
   

 
  
     ld de,VPOKETHIS
    ld (de),a
   push hl
  call vpokechar
   pop hl
skipprintingnewlineasgarbage:
   
       ld hl,VPOKESTRINGPOSINSTRING
     ld a,(hl)
     inc a
     ld (hl),a

     ld de,VPOKESTRINGXPOS
   ld a,(de)
    cp LENGTHOFTEXTATTOPANDBOTTOMADJACENTARTFULLIMAGE;;doest overlap MergeDraw instructions
    call z,gotonewline

   jp gotonextcharinstring
finishedstringwriting: 
   pop af
   pop de
   pop bc
   pop hl 
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SHIFTMergeDrawPROGRAMRIGHT  EQU 2
renderrepeatcmd:
  push bc

       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
;;;;

 

   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawrepeatlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT;;;across value fixed
   ld hl,MergeDrawPCCOUNTERFORGUI;;
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start rendering commads ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


reduceCmodulo24:

  push de
  push hl
  ld d,a
  ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
  ld a,(hl)
 

  cp 0
  jp z,sub0
  cp 1
  jp z,sub1
  cp 2
  jp z,sub2
  cp 3
  jp z,sub3
sub0:

  ld a,d
  sub 0

  jp donereduction24
sub1:

  ld a,d
  sub 23

  jp donereduction24
sub2:

  ld a,d
  sub 46

  jp donereduction24
sub3:

  ld a,d
  sub 69

  jp donereduction24
donereduction24:
  pop hl
  

  pop de
  ret
  
SHIFTNUMVALINSTRUCTIONLEFT EQU 1
renderupcmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
 
   call reduceCmodulo24
   ld c,a
      ld hl,Drawuplabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUI;; the row value
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderdowncmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawdownlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderleftcmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawleftlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderrightcmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawrightlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret


rendercirclecmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24


   ld c,a
      ld hl,Circlelabel
 
   call changetosemicircleinstrifneedsbe
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8-SHIFTNUMVALINSTRUCTIONLEFT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a


  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

changetosemicircleinstrifneedsbe:
   push af
    ld a,e
   sub 4
  jp c,dontupdatMergeDrawprogramtoshowsemicircle
  ld hl,Circlelabelsemi
dontupdatMergeDrawprogramtoshowsemicircle:
  pop af
  ret

renderpendowncmd:
    push bc
       ld b,18+SHIFTMergeDrawPROGRAMRIGHT
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawpendownlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,18+SHIFTMergeDrawPROGRAMRIGHT+8
   ld hl,MergeDrawPCCOUNTERFORGUI
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
;;;;;
      dec b
       dec b
       dec b
       dec b
   dec b
   

  ld a,e


  cp 0
 jp z,weritedown
 
  cp 1
 jp z,writeup

weritedown:
       ld hl,DrawpendownDOWNlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

 jp done2423
writeup:
     ld hl,DrawpendownUPlabel
    push de
  call   writeHLstringwithvpokexyposBC
     pop de
done2423:
   pop bc

  ret


renderemptycmd:
    push bc
       ld b,23-5+SHIFTMergeDrawPROGRAMRIGHT;;
   ld hl,MergeDrawPCCOUNTERFORGUI;
   ld a,(hl)
   inc a



     call reduceCmodulo24
   ld c,a
      ld hl,Emptylabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

   pop bc
  ret

renderendrepeatcmd:
    push bc
       ld b,23-5+SHIFTMergeDrawPROGRAMRIGHT;;
   ld hl,MergeDrawPCCOUNTERFORGUI;;
   ld a,(hl)
   inc a
   call reduceCmodulo24
   ld c,a
      ld hl,Drawrepeatendlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de


   pop bc
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;for rendering current instruction;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


renderrepeatnextcmdtoenter:
  push bc

       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;
   ld a,(hl)
   inc a
 
   ld c,a
      ld hl,Drawrepeatlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;
   ld a,(hl)
   inc a

   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderupnextcmdtoenter:
   push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
   

      ld hl,Drawuplabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderdownnextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Drawdownlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderleftnextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Drawleftlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderrightnextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Drawrightlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a

  ld a,e
 
 
  call display3digitnumberinAposinBCsetcurosor
   pop bc

  ret

  
rendercirclenextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Circlelabel
   call changetosemicircleinstrifneedsbe
    push de
   call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a

  ld a,e
  call display3digitnumberinAposinBCsetcurosor
   pop bc
  ret

renderpendownnextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Drawpendownlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

  
   ld b,CMDTOENTERXPOS+8;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant;;
   ld a,(hl)
   inc a
   ld c,a
;;;;;;;;move down and up 0 space after pen as 1 word
      dec b
       dec b
       dec b
       dec b
   dec b
   

  ld a,e
  
  cp 0;;
 jp z,writedown2
 
  cp 1;;
 jp z,writeup2

writedown2:
       ld hl,DrawpendownDOWNlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de

 jp donedoingthewrite
writeup2:
     ld hl,DrawpendownUPlabel
    push de
  call   writeHLstringwithvpokexyposBC
     pop de
donedoingthewrite:
   pop bc

  ret


renderemptynextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Emptylabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de


   pop bc
  ret

renderendrepeatnextcmdtoenter:
    push bc
       ld b,CMDTOENTERXPOS;;;acrosss value fixed
   ld hl,MergeDrawPCCOUNTERFORGUIconstant
   ld a,(hl)
   inc a
   ld c,a
      ld hl,Drawrepeatendlabel
    push de
  call  writeHLstringwithvpokexyposBC
     pop de


   pop bc
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

renderinstructionsonce2:
 ;;;this reders the individuly displayed  instrcshon shown in upper left half of screnn (not in program on right)
    
     push hl
        push bc
          push de
            push af
  
     ld b,1
     ld c,1
     ld hl,blankoutanswe15char
     call  writeHLstringwithvpokexyposBC
          pop af
         pop de
      pop bc
   pop hl

startGUIrender2:
GUIrediringloopstart2:
 
 
 
;;;;;;;;;;;;;;;;;;;;
  ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED
  ld a,(hl)

  CP EMPTYMEMORYFORCMD
  jp z,emptyslotmem2
  and %00011111
  ld e,a;;;load the value
  
  xor a 
  or a;
  ld a,(hl)
  and %11100000
  srl a
  srl a
  srl a
  srl a
  srl a

 sub 0
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;code added for repeat command;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 



 cp REPEATCOMMAND 
 jp z,DOrenderrepeatnextcmdtoenter
  CP DRAWUPCOMMAND
 jp z,DOrenderupnextcmdtoenter
  CP DRAWRIGHTCOMMAND
 jp z,DOrenderrightnextcmdtoenter
  CP DRAWLEFTCOMMAND
 jp z,DOrenderleftnextcmdtoenter
  CP DRAWDOWNCOMMAND
 jp z,DOrenderdownnextcmdtoenter
  CP CIRCLECOMMAND
 jp z,DOrendercirclenextcmdtoenter
  CP PENDOWNCOMMAND
  jp z,DOrenderpendownnextcmdtoenter
 CP ENDREPEATCOMMAND
   jp z,DOrenderendrepeatnextcmdtoenter
emptyslotmem2:
    jp DOrenderemptynextcmdtoenter
     jp end735283
DOrenderrepeatnextcmdtoenter:
   call renderrepeatnextcmdtoenter
   jp end735283
DOrenderupnextcmdtoenter:
   call renderupnextcmdtoenter
   jp end735283
DOrenderrightnextcmdtoenter:
   call renderrightnextcmdtoenter
   jp end735283
DOrenderleftnextcmdtoenter:
  call renderleftnextcmdtoenter
   jp end735283
DOrenderdownnextcmdtoenter:
 call renderdownnextcmdtoenter
   jp end735283
DOrendercirclenextcmdtoenter:
  call rendercirclenextcmdtoenter
   jp end735283
DOrenderpendownnextcmdtoenter:
  call renderpendownnextcmdtoenter
   jp end735283
DOrenderendrepeatnextcmdtoenter:
  call renderendrepeatnextcmdtoenter
   jp end735283
DOrenderemptynextcmdtoenter:
  call renderemptynextcmdtoenter
   jp end735283
end735283:

finishedrenderingpage2:

  ret

 

 

delay:
  di
  TimeDelay 64
  ei
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;render command to enter
renderinstructionsonce:
;;;; 0  23;;;23 instruction on 1 page
;;;; 24 47;;;vals for 2nd page
;;;; 48 63

     ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,(hl)
   cp 0
     call z,showviewpingpage1banner
   cp 1
     call z,showviewpingpage2banner
   cp 2
     call z,showviewpingpage3banner

   ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,(hl)
 


 
   cp 0
   jp z,ldstartofMergeDrawGUIpage0
   cp 1
   jp z,ldstartofMergeDrawGUIpage1
   cp 2
   jp z,ldstartofMergeDrawGUIpage2
   cp 3
   jp z,ldstartofMergeDrawGUIpage3
ldstartofMergeDrawGUIpage0:
   ld hl,MergeDrawPCCOUNTERFORGUI 
   ld a,0
 ld (hl),a
   ld hl,ENDVALUEOFMergeDrawPCCOUNTERFORGUI
   ld a,23
  ld (hl),a
  jp doneloadingendpoints
ldstartofMergeDrawGUIpage1:
   ld hl,MergeDrawPCCOUNTERFORGUI 
   ld a,23
 ld (hl),a
   ld hl,ENDVALUEOFMergeDrawPCCOUNTERFORGUI
   ld a,46
  ld (hl),a
  jp doneloadingendpoints
ldstartofMergeDrawGUIpage2:
   ld hl,MergeDrawPCCOUNTERFORGUI 
   ld a,46
 ld (hl),a
   ld hl,ENDVALUEOFMergeDrawPCCOUNTERFORGUI
   ld a,73
  ld (hl),a
ldstartofMergeDrawGUIpage3:

 
 
  jp doneloadingendpoints

 

doneloadingendpoints:


startGUIrender:
GUIrenderloop:
 
 ld hl,MergeDrawPCCOUNTERFORGUI 
 ld a,(hl)
   
    push af
    push hl
      ld hl,ENDVALUEOFMergeDrawPCCOUNTERFORGUI
      ld a,(hl)
      ld ixl,a
   pop hl
   pop af
     cp ixl

  jp z,finishedrenderingpage 
   or a
  xor a

   ld hl,MergeDrawPCCOUNTERFORGUI;
 ld a,(hl)
 ld e,a;;for de=pc here used in hl_de below and so it strts at 0
  ld hl,MergeDrawPROGRAMRAMTOP
  ld d,0
  add hl,de
 

  ld a,(hl)

  CP EMPTYMEMORYFORCMD
  jp z,emptyslotmem
  and %00011111
  ld e,a;;;load the value
  
  xor a 
  or a
  ld a,(hl)
  and %11100000
  srl a
  srl a
  srl a
  srl a
  srl a

 sub 0
 
 
 cp REPEATCOMMAND 
 jp z,DOrenderrepeatcmd
  CP DRAWUPCOMMAND
 jp z,DOrenderupcmd
  CP DRAWRIGHTCOMMAND
 jp z,DOrenderrightcmd
  CP DRAWLEFTCOMMAND
 jp z,DOrenderleftcmd
  CP DRAWDOWNCOMMAND
 jp z,DOrenderdowncmd
  CP CIRCLECOMMAND
 jp z,DOrendercirclecmd
  CP PENDOWNCOMMAND
  jp z,DOrenderpendowncmd
 CP ENDREPEATCOMMAND
   jp z,DOrenderendrepeatcmd
emptyslotmem:
    jp DOrenderemptycmd
     jp end735
DOrenderrepeatcmd:
   call renderrepeatcmd
   jp end735
DOrenderupcmd:
   call renderupcmd
   jp end735
DOrenderrightcmd:
   call renderrightcmd
   jp end735
DOrenderleftcmd:
  call renderleftcmd
   jp end735
DOrenderdowncmd:
 call renderdowncmd
   jp end735
DOrendercirclecmd:
  call rendercirclecmd
   jp end735
DOrenderpendowncmd:
  call renderpendowncmd
   jp end735
DOrenderendrepeatcmd:
  call renderendrepeatcmd
   jp end735
DOrenderemptycmd:
  call renderemptycmd
   jp end735
end735:


 push hl
 ld hl,MergeDrawPCCOUNTERFORGUI
 ld a,(hl)
 inc a
 ld (hl),a
 
 pop hl


  jp GUIrenderloop


finishedrenderingpage:
  
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setinstuctionchoice:
      ld hl,INSTRUCTIONVALUEFOROUNDING
      ld a,(hl)
      inc a
      ld (hl),a
      call doAdivisionof2
      call doAdivisionof2
      call doAdivisionof2
      call doAdivisionof2;;;256/32=8 instrcutions
      ld hl,INSTRUCTIONCHOICE

    call truncatevaluesifneedsbe

      ld (hl),a
  call delay

   call displayandconstructinstruction

     call renderinstructionsonce2
 

  ret

setpenupORpendownrandomly:
       push de
      push bc
        push hl 
        push af
       call RANDOMnum
        and 1
        ld hl,INSTRUCTIONVALUE
       
	ld (hl),a 
        pop af
        pop hl
      pop bc
	pop de
	ret


circlecommandrestrictTOlessthan4:

       push de
      push bc
        push hl 
        push af
        ld hl,INSTRUCTIONVALUE
        ld a,(hl)
        and 7
        ld hl,INSTRUCTIONVALUE
	ld (hl),a 
     sub 4
     call nc,setcircleorsemicrlelabel
     call c,blankaboveifneedsbe
        pop af
        pop hl
      pop bc
	pop de
  

	ret

truncatevaluesifneedsbe:

    push hl
    push af
          ld hl,INSTRUCTIONCHOICE
        ld a,(hl)
        sub 0
      CP PENDOWNCOMMAND
      jp z,truncatreforpendown
       CP CIRCLECOMMAND
       jp z,truncateforcircle
       CP DRAWUPCOMMAND
       jp z,truncateUDLR
       CP DRAWDOWNCOMMAND
       jp z,truncateUDLR
       CP DRAWLEFTCOMMAND
       jp z,truncateUDLR
       CP DRAWRIGHTCOMMAND
       jp z,truncateUDLR
      CP REPEATCOMMAND
       jp z,truncaterepeat
      CP ENDREPEATCOMMAND
       jp z,donothingtruncaterepeat

truncatreforpendown:

  push af
      call setpenupORpendownrandomly
  pop af
      jp done762312
truncateforcircle:
    push af
      call circlecommandrestrictTOlessthan4
   pop af
         jp done762312
truncateUDLR:
       call z,truncateUDLRfloorto2

         jp done762312
truncaterepeat:
         call z,truncaterepeatfloor0
            jp done762312
donothingtruncaterepeat:
             jp done762312
done762312:
     pop af
     pop hl
enddjjj:

  RET

truncaterepeatfloor0:
 push af
  push hl
  ld hl,INSTRUCTIONVALUE
  ld a,(HL)
  cp 0
  jp nz,nonzerorepeats
     ld hl,INSTRUCTIONVALUE
     ld a,1
    ld (hl),a
nonzerorepeats:
   pop af
  pop hl
  ret


truncateUDLRfloorto2:
  push af
  push hl
  ld hl,INSTRUCTIONVALUE
  ld a,(HL)
  sub 3
  jp nc,over2
     ld hl,INSTRUCTIONVALUE
     ld a,2
    ld (hl),a
over2:
   pop af
  pop hl
  ret

        



setinstructionchoiceVALUEup:
      ld hl,INSTRUCTIONVALUEFOROUNDING2
      ld a,(hl)
      inc a
      ld (hl),a
      ;;; dame
      call doAdivisionof2
      call doAdivisionof2
      ld hl,INSTRUCTIONVALUE
   
  
 
      ld (hl),a
  call delay
  call delay
  call truncatevaluesifneedsbe
  call displayandconstructinstruction
     call renderinstructionsonce2
  ret


         

setinstuctionchoiceVALUEdown:
     xor a
     or a
      ld hl,INSTRUCTIONVALUEFOROUNDING2
      ld a,(hl)
      dec a
      or a
      ld (hl),a
      call doAdivisionof2
      call doAdivisionof2
      ld hl,INSTRUCTIONVALUE
      ld (hl),a
  call delay
  call delay
  call truncatevaluesifneedsbe
    call displayandconstructinstruction
  call  renderinstructionsonce2
  ret

displayandconstructinstruction:
    ;;;go to position in memory MergeDraw program 
  ld hl,INSTRUCTIONVALUE
  ld a,(hl)
  ld e,a
  

  xor a 
  or a
    ld hl,INSTRUCTIONCHOICE
  ld a,(hl)
  add a,a
  add a,a
  add a,a
  add a,a
  add a,a

   add a,e;;;final construction is this addtion


   ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED
   ld (hl),a 

 
  


finishedrenderingpagePASTMAX:

   ret
 

errorchecksntax:
  ld hl,INSTRUCTIONPOINTER;;;
  ld a,(hl)
  ld c,a

  ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED
  ld a,(HL)
  and %11100000
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ld b,a

  ld hl,INSTRUCTIONMergeDrawPCCOUNTERFORERRORCHECK
  ld a,0
  ld (hl),a
   
;;;loop through all 69 instructions 
errorcheckloopolddontusr:
    ld hl,INSTRUCTIONMergeDrawPCCOUNTERFORERRORCHECK
  ld a,(hl)
  ld e,a
  ld d,0
   ld hl, MergeDrawPROGRAMRAMTOP
   add hl,de
  ld a,(hl)
  call doAdivisionof32
  cp C
  
  ret

doAdivisionof32:
    call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  call doAdivisionof2
  ret

swapfirsttwobytesif1insretionprogram:
 ld de,&C9B0
 ld a,(DE)
 cp EMPTYMEMORYFORCMD
 jp nz,nonnedtoswap
 ld de,&C9B1
 ld a,(de)
 ld de,&C9B0
 ld (de),a
 ld de,&C9B1
 ld a,EMPTYMEMORYFORCMD
 ld (de),a
nonnedtoswap:
 ret

makecopyofentireMergeDrawprogram:


;;;this makes a direct copy of MergeDraw progem in c900 to c900+end size
;;to c9b0+program size. the destination copy is initlised as a block
;;of 08s then the program is copied. A MergeDraw copied program needs the
;;first two bytes need to be swapped swap is done by swapfirsttwobytesif1insretionprogram
 push hl
 push de
 push bc

 ld b,&7F
 ld hl,&C900
 ld de,&C9B0
copyMergeDrawallloop08hinitlise:
 ld a,(hl)
 ld (de),a
 inc hl
 inc de
 ld a,(hl)
  djnz copyMergeDrawallloop08hinitlise
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ld b,&7F
 ld hl,&C900
 ld de,&C9B0
copyMergeDrawallloop:
 ld a,(hl)
 ld (de),a
 inc hl
 inc de
 ld a,(hl)
 cp EMPTYMEMORYFORCMD;;;this is the 08h of the original program not DEstination
 jp z,endofMergeDrawprogrmmaybenotnotmaxsizeloop
  djnz copyMergeDrawallloop
endofMergeDrawprogrmmaybenotnotmaxsizeloop:
   ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED;;;add in candidate instruction
  ld a,(hl)
  ld (de),a
 call swapfirsttwobytesif1insretionprogram
 
 pop bc
 pop de
 pop hl
  ret

addrepeattofilteredblockmem:
 ld a,REPEATCOMMAND
 ld (de),a
 inc de
 ret

addendrepeattofilteredblockmem:
 ld a,ENDREPEATCOMMAND
 ld (de),a
 inc de
 ret

decodeinstruction:
 ld a,(hl)
  and %11100000
  srl a
  srl a
  srl a
  srl a
  srl a
 ret
 
 

initialisefiltermemoryblock:
   ld b,&7F
 ;;;;;copy of mergedraw porgram start
 ld de,&CA40;;;desitination filtered out start adress
inilitstherepteatrtypesfiletmemeblock:
initialisetheMEMblockforfilteringrepeats:
  ld a,EMPTYMEMORYFORCMD
  ld (DE),a
  inc de
 djnz initialisetheMEMblockforfilteringrepeats
  ret


filteroutREPEATsandENDREPEATS:
 
 ld b,&7F
 ld hl,&C9B0;;;copy of m.d. porgram start
 ld de,&CA40;;;destination filtered out star t
copyMergeDrawallloopfilterrepeattypes:
 call decodeinstruction
 cp REPEATCOMMAND
  call z,addrepeattofilteredblockmem
   call decodeinstruction
  cp ENDREPEATCOMMAND
 call z,addendrepeattofilteredblockmem
  inc hl;;;go to next instruction of candiadre MergeDraw program
  djnz copyMergeDrawallloopfilterrepeattypes
 ret
  
setMergeDrawrepplooperrortofalse:
setMergeDrawrepplooperrortofalseassumedchangedoterwise:
  push hl
  ld hl,ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR
  ld a,0
  ld (HL),a
  pop hl

  ret

setMergeDrawrepplooperrortotrue:
  push hl
  ld hl,ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR
  ld a,1
  ld (HL),a
  pop hl
  ret


syntaxerrorcheckrepeatandendrepeatloopstructure:
VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG EQU &C9A4;;;is 1 initially for  empty program
VALIDREPEATEXACTLYONESTARTREPEATUSED EQU &C9A5;;;
VALIDflagREPEATandENDREPEATexactlyMATCHED EQU &C9A6;;;
INVALIDTWOendrepeatsADJACENT EQU &C9A7;;;0 to enter or ok;; 1 is error detects when there is two 05 05 conseuctively in filtered block
INVALIDprogramSTARTSwithENDREPEATafterfilter EQU &C9A8
ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR EQU &C9A9


  ;;;continually resets flag here
   ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
   ld a,1
   ld (HL),a;;;assume it to be false that it is not valid that rep
   ld de,&CA40;
  call validifNOtendrepeatORstartrepeatsinfilteredBLOCK
   ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,0
   ld (HL),a
  call validifEXACTLYoneSTARTrepeatISUSED
   ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,1
   ld (hl),a
  call validEXACTLYmatchedENDREPEATSandREPEATS
    ld hl,INVALIDTWOendrepeatsADJACENT
   ld a,0;;assumed to be false
   ld (hl),a
  call checkINVALIDTWOendrepeatsADJACENT
   ld hl,INVALIDprogramSTARTSwithENDREPEATafterfilter
   ld a,0
   ld (hl),a
  call checkINVALIDprogramSTARTSwithENDREPEATafterfilter
   ld hl,LASTCOMMANDISREPEATFLAG
   ld a,0
  ld (hl),a
  call checklastcommandisREPEAT
 ret

 
checklastcommandisREPEAT:
 
  ld  hl,&C9F4;;;last byte in simulated input program
  ld a,(hl)
  call decodeinstruction
  CP REPEATCOMMAND
  jp nz,lastcommandisNOTrpeat
   ld hl,LASTCOMMANDISREPEATFLAG
   ld a,1
   ld (hl),a
lastcommandisNOTrpeat:
   ret




l;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validifNOtendrepeatORstartrepeatsinfilteredBLOCK:
 ld b,&7C;;124=7c still bigger than 63 bytes so longer than any m.d. prog
 ld hl,&C9B0;;;copy of m.d. porgram start
 ld de,&CA40;;;destination filtered out start
looptotesfornoloopscommandsiMergeDrawprogram:
  ld a,(de)
  cp EMPTYMEMORYFORCMD;;;the whole block will be 08s as there are no repeats or end repats (a 5 or 6) in block
  jp z,noneedtosetflag
   call setvalidorepeatnonrepeatflag ;; if not equal then this is false
noneedtosetflag:
  inc de
  djnz looptotesfornoloopscommandsiMergeDrawprogram
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validifEXACTLYoneSTARTrepeatISUSED:
  ld b,&7C;;124=7c still bigger than 63 bytes of m.d. program
  ld c,0
 ld de,&CA40;;;destination filtered out start
looptoCOOUNTforasstrartREPEATSogaprogram:
  ld a,(de)
  cp REPEATCOMMAND;;;the whole block will be 08s as there are no repeats or end repats (a 5 or 6) in block
  jp nz,noneedtoaddcountinC
   inc c;;inc  count no of repeats
noneedtoaddcountinC:
  inc de
  djnz looptoCOOUNTforasstrartREPEATSogaprogram
   ld a,c
   cp 1;;;one repeated conted
   call z,setvalidONEstartrepeatUSEDtflag
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validEXACTLYmatchedENDREPEATSandREPEATS:
  ld b,&7C
 ld de,&CA40
  dec de
looptCOUNTmatchingpairREPEATSandENDREPEATSMergeDrawprogram:
  inc de
  ld c,0
  ld a,(de)
  cp REPEATCOMMAND
  jp nz,notfindingpairSTARTINGwithrepeat
  inc c
notfindingpairSTARTINGwithrepeat:
  inc de
  ld a,(de)
  cp EMPTYMEMORYFORCMD;;if the second byte in the pair is 08 then it at end of filtered block means first byte is 08 too
  jp z,finisheddetection
  cp ENDREPEATCOMMAND;;;the whole block will be 08s as there are no repeats or end repeats (a 5 or 6) in block

  jp nz,notfindpairENDINGwithENDREPEAT
  inc c
notfindpairENDINGwithENDREPEAT:
   ld a,c
    cp 2 
   call nz,setVALIDNONREPEATandREPEATexactlyMATCHED
   
  djnz looptCOUNTmatchingpairREPEATSandENDREPEATSMergeDrawprogram

 
finisheddetection:
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkINVALIDTWOendrepeatsADJACENT:
  ld b,&7C; 
 ld de,&CA40 
  dec de
looptfindtwoadjacentENDREPEATSwithrepeatMergeDrawprogram:
  dec de;;;this is done as a sliding window like 2 bytes not two at a time like repeat aNDand END REPEeat HENCE THE DEC DE here
  inc de
  ld c,0
  ld a,(de)
  cp &05
  jp nz,notfindpaitSTARTINGwithENDrepeat
  inc c
notfindpaitSTARTINGwithENDrepeat:
  inc de
  ld a,(de)
  cp EMPTYMEMORYFORCMD;;
  jp z,finisheddetection2
  cp &05
  jp nz,notfindpairENDINGwithENDREPEATcase2
  inc c
notfindpairENDINGwithENDREPEATcase2:
   ld a,c
    cp 2;;;not 2 then a pair that does match found
   call z,setINVALIDflaypairofENDREPEATS
   
  djnz looptfindtwoadjacentENDREPEATSwithrepeatMergeDrawprogram

 
finisheddetection2:
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
checkINVALIDprogramSTARTSwithENDREPEATafterfilter:
  ld de,&CA40;
  ld a,(de)
  cp &05
  jp nz,nonnedtosetflag
    ld de,INVALIDprogramSTARTSwithENDREPEATafterfilter
    ld a,1
    ld (de),a
nonnedtosetflag:
  ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setINVALIDflaypairofENDREPEATS:

   ld hl,INVALIDTWOendrepeatsADJACENT
   ld a,1;;assumed to be false
   ld (hl),a
  ret

setVALIDNONREPEATandREPEATexactlyMATCHED:
  ld a,(de)
 ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,0
   ld (hl),a
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setvalidorepeatnonrepeatflag:
  push de
  push hl
 ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
   ld a,0
   ld (HL),a
  pop hl
  pop de
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setvalidONEstartrepeatUSEDtflag:
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,1
   ld (HL),a
  ret

processpossibleerrorsforMergeDrawrepeatloops:
  or a
  xor a
  ;;c works as  OR using addtion here
  ld c,0
  ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG;;;;an empty program basically
  ld a,(HL)
  ld c,a;;;
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED ;;;;an empty program basically MergeDraw prog that starts with 1 repeat
  ld a,(HL)
  add a,c
  ld c,a
  ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED  ;;;matching pairs of staRTS AND ENDS OF M.D. REPAT LOOPS
  ld a,(HL)
  add a,c
  ld c,a
  cp 0
  call nz,setMergeDrawrepplooperrortotrue;;;;so far if any of the three above conditions are true then ok to enter next instruction 
  ld hl,INVALIDTWOendrepeatsADJACENT
  ld a,(HL)
  cp 1
  call z,setMergeDrawrepplooperrortofalse
  ld hl,INVALIDprogramSTARTSwithENDREPEATafterfilter
  ld a,(HL)
  cp 1
  call z,setMergeDrawrepplooperrortofalse
  ld hl,LASTCOMMANDISREPEATFLAG
  ld a,(HL)
  cp 1
  call z,setMergeDrawrepplooperrortofalse;;set enter m.d. to flags if least entry is repeat
  ret
 
processmessageserrorsforMergeDrawrepeatloops:
  or a
  xor a
  

 

  ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
  ld a,(HL)
  cp 0
  call z,MergeDrawrepeatnestingerror

  ld hl,INVALIDTWOendrepeatsADJACENT
  ld a,(HL)
  cp 1
  CALL z,MergeDrawtoomanyendrepeatserror
 
  ld hl,INVALIDprogramSTARTSwithENDREPEATafterfilter
  ld a,(HL)
  cp 1
  call z,MergeDrawstartwithendrepearerror
   ld hl,LASTCOMMANDISREPEATFLAG
   ld a,(HL)
   cp 1
  call z,lastcommandCANNOTbeREPEATrerror
  
  ret
 
lastcommandCANNOTbeREPEATrerror:
 push de
   push bc
   push hl
   push af
  ld hl,genericmessage7
  call genericmessaheinHL
   pop af
   pop hl
   pop bc
  pop de
  ret



MergeDrawfinalanswerentered:

  
 

  ret 




 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
holdtoentermessage:
   di  
 push de
   push bc
   push hl
   push af

  
  ld hl,genericmessage6
  call genericmessaheinHL

  jp done5838

done5838:



   pop af
   pop hl
   pop bc
  pop de
  ret

MergeDrawcircleafterpendownerror:
 push de
   push bc
   push hl
   push af
  ld hl,genericmessage5
     push hl
    ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED
    ld a,(hl)
    pop hl
    and %00011111
    cp 0
    jp z,dontchangetosemicircleerrormessage
    cp 1
    jp z,dontchangetosemicircleerrormessage
    cp 2
    jp z,dontchangetosemicircleerrormessage
    cp 3
    jp z,dontchangetosemicircleerrormessage
      ld hl,genericmessage5b
dontchangetosemicircleerrormessage:

  call genericmessaheinHL

  ld b,10
delaytoincludecirclerrormessgae:
         push bc
    call biggerdelay;;;creates abot  a 1 second delay
   call biggerdelay
   call biggerdelay
   call biggerdelay;
   call biggerdelay;
     pop bc
  djnz delaytoincludecirclerrormessgae
  push af
  push ix
  push bc
  push hl
  push de
includeerrormessage2232:
  di
    call ReadPlayerControlKeys
     bit 4,a; exit
       jp z,exitincludeerrormessage4232

  ei
 jp includeerrormessage2232
exitincludeerrormessage4232:

     ld b,0
  ld c,1
   ld hl,blankchar
     call  writeHLstringwithvpokexyposBC
 

  
       ld b,1
  ld c,1
   ld hl,blankoutanswe15char
     call  writeHLstringwithvpokexyposBC
  pop de
  pop hl
  pop bc
  pop ix
  pop af

 ;;;;;;;;;;;;;;;;end MergeDraw loop error cb;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ld a,107;;;for activating circle after an  error message
    ld ixl,a
   pop af
   pop hl
   pop bc
  pop de
  ret


MergeDrawstartwithendrepearerror:
 push de
   push bc
   push hl
   push af
  ld hl,genericmessage3
  call genericmessaheinHL
   pop af
   pop hl
   pop bc
  pop de
  ret



MergeDrawtoomanyendrepeatserror:
  push de
   push bc
   push hl
   push af
  ld hl,genericmessage4
  call genericmessaheinHL
   pop af
   pop hl
   pop bc
  pop de
  ret

MergeDrawrepeatnestingerror:
  push de
   push bc
   push hl
   push af
  ld hl,genericmessage2
  call genericmessaheinHL
 


   pop af
   pop hl
   pop bc
  pop de
  ret



enterinstruction:;;;puts the constructed byte ointo MergeDraw program memory
 push bc
  push hl
  push de
  push af



  

 call biggerdelay
  call selectpagefromPCsize

 ;;;;;;;;;;;;;;;;;;start MergeDraw loop error checking;;;;;;;;;;;;;;;;;;;;;;;;;;;
   push hl
 push de
 push bc
  call setMergeDrawrepplooperrortofalseassumedchangedoterwise;;set error flags
  call makecopyofentireMergeDrawprogram;;;copy program to simulate error if was entererted with possiblwe wrong instruction
  call initialisefiltermemoryblock;;;;;;initialise the non used commans in flitered block of memeory
  call filteroutREPEATsandENDREPEATS;;;filter the copied program to so the filtering just leaves repeats and end repeats in a canonacial form
  call syntaxerrorcheckrepeatandendrepeatloopstructure;;;check what are valid patterns of conanafcial form
  call processpossibleerrorsforMergeDrawrepeatloops;;;combine all the valid patterns to deduce all possible rror flag then combine these flags to get a final boolean if there isa an y error
  call processmessageserrorsforMergeDrawrepeatloops;;;write the correspoding error correspoding to above error flags
 pop bc
 pop de
 pop hl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  call removegarbagefromscreen

includeerrormessage8376:;;;let player include the error message
  di

  push hl
  ld hl,ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR
  ld a,(HL)
  pop hl
    cp 1
  jp z,delayforincludeingerror
  jp nodelayforincludeinerror
delayforincludeingerror:
      call ReadPlayerControlKeys
     bit 5,a; exit
       jp z,exitincludeerrormessage2
   jp includeerrormessage8376

nodelayforincludeinerror:
        call ReadPlayerControlKeys
     bit 4,a; exits 
       jp z,exitincludeerrormessage2

  ei
 jp includeerrormessage8376
exitincludeerrormessage2:
 
     ld b,0
  ld c,1
   ld hl,blankchar
     call  writeHLstringwithvpokexyposBC
 
  
       ld b,1
  ld c,1
   ld hl,blankoutanswe15char
     call  writeHLstringwithvpokexyposBC

 
;;;;;;;;;;;;;;;;;end MergeDraw loop error ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ld hl,ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR 
 ld a,(HL)
 cp 0;;;0 means error
 jp z,someMergeDrawlooperror
    

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;stop instruction entry if circle after pendown;;;;;;;;;;;;;;;;;;;;;;;;;;
    or a
    xor a
   ld de,PENDOWNFLAG
     ld a,(de)
     ld d,a 
    
  ld hl,INSTRUCTIONCURRENTLYCONSTRUCTED
    ld a,(hl)
    call decodeinstruction
     add a,d
     CP CIRCLECOMMAND 
     call z,MergeDrawcircleafterpendownerror
     ld a,(ixl);;used as a nonce if circle after penup is detected
     cp 107
     jp z,someMergeDrawlooperror
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ld hl,INSTRUCTIONPOINTER
  ld a,(hl)
  ld e,a
  ld d,0
   ld hl, MergeDrawPROGRAMRAMTOP
   add hl,de
  ld de,INSTRUCTIONCURRENTLYCONSTRUCTED
  ld a,(de)
  ld (hl),a
  

;;;;increment to next instrction need to be checked against maximum
  ld hl,INSTRUCTIONPOINTER
  ld a,(hl)
  inc a
  ld (hl),a

  call renderinstructionsonce
  call interpretMergeDrawprogram

someMergeDrawlooperror:
  ld HL,ENTERINTRUCTIONFLAGNOMergeDrawrepeatLOOPERROR 
  ld a,1
  ld (hl),a
  ld (ixl),a;;

 call biggerdelay
  call biggerdelay

  pop af
  pop de
  pop hl
 pop bc
  push bc
  push hl
  push de
 
  call blankrightmostedgesub 
  pop de
  pop hl
  pop bc



  ret

biggerdelay:
   
    call delay
  call delay
  call delay
  call delay

  ret




setSWpageinDtoload:
 
   push de
   ld a,d 
    and 1
    cp 0;;;a is even
   jp z,evenpagenumbermapstooddHWpage
ODDpagenumbermapstooddHWpage:
    or a
   xor a;;clear flags
    ld a,d
    sub 1 
   call doAdivisionof2
   add 2
   


   jp finishedsettingHWpage
evenpagenumbermapstooddHWpage:
       or a
   xor a 
    ld a,d
   
   call doAdivisionof2
   add 1
finishedsettingHWpage:


  ld hl,rompagealt
  ld (hl),a;; loads the HL roma page into FFFF
   pop de

 
   ld a,d
    and 1
    cp 0 
   jp z,evenpagenumber
    ld hl,&8000
   jp loadedoffsetinpageafter64kb
evenpagenumber:
    ;;;of a is 
    ld hl,&8000+&2000;;add the offset &2000 for includeing info from page bpaged in
loadedoffsetinpageafter64kb:
  ret

drawartfullimagetoscreenandsetartfullimageHIGHandLOWbytes:
   push bc
    ld bc,8192 
    push hl
   call TilestoVideoRAMBW
   pop hl

  push de
       
  push hl 
 
  ld de,ARTFULLIMAGEBASEADDRESSHIGHBYTE 
  ld a,h
  ld (de),a
  ld de,ARTFULLIMAGEBASEADDRESSLOWBYTE 
  ld a,l
  ld (de),a
     
  pop hl    
  pop de
  pop bc
  ret
gotonewline:
  push hl
  push bc
  push de
   push af
     ld de,VPOKESTRINGXPOS
   ld a,0
   ld (de),a
    ld de,VPOKESTRINGYPOS
     ld a,(de)
      inc a
      ld (de),a
   pop af;;;;a is restored stop garbage printed
  pop de
  pop bc
  pop hl
 ret
displaycluetype:
  
   push de
   push hl
   push bc
   call setloadblankartfullimageFLAGtofalse

     ld a,(hl)
   ;;;capital letters below is for message with draw all 
  ;;lower case letter below is for message with image to draw over
   cp 'i';;;;this is idiom or proverb
    jp z,clueIdiomorproverb
   cp 'I'
    jp z,clueIdiomorproverbWITHDRAWALLMSG
   cp 'o';;;;this is object
    jp z,clueOsomeobject
   cp 'O'
    jp z,clueOsomeobjectWITHDRAWALLMSG
   cp 'p';;;;this is perosn
    jp z,cluePperson
   cp 'P'
    jp z,cluePpersonWITHDRAWALLMSG
   cp 'c';;;;this is creature
    jp z,clueCcreature
   cp 'C'
    jp z,clueCcreatureWITHDRAWALLMSG
   cp 'f';;;;this is PhRASE
    jp z,cluefood
   cp 'F';;;;this is pHrase
    jp z,cluefoodWITHDRAWALLMSG


  
  


clueIdiomorproverbWITHDRAWALLMSG:
         call needtodrawallartfullimage
         call setloadblankartfullimageFLAGTOtrue
       jp entrypointdrawallIDIOMorPROVERB
clueIdiomorproverb:
   call needtodrawallartfullimageblanked
entrypointdrawallIDIOMorPROVERB: 
      ld b,0
      ld c,21
      ld hl,cluetypeI
     call  writeHLstringwithvpokexyposBC
    jp donedisplayingcluefromcontrolcharacter
clueOsomeobjectWITHDRAWALLMSG:
        call needtodrawallartfullimage
      call setloadblankartfullimageFLAGTOtrue
      jp entrypointdrawallOBJECT
clueOsomeobject:
   call needtodrawallartfullimageblanked
entrypointdrawallOBJECT:
      ld b,0
      ld c,21
      ld hl,cluetypeO
     call  writeHLstringwithvpokexyposBC
    jp donedisplayingcluefromcontrolcharacter
cluePpersonWITHDRAWALLMSG: 
          call needtodrawallartfullimage
         call setloadblankartfullimageFLAGTOtrue
       jp entrypointdrawallPERSON
cluePperson:
  call needtodrawallartfullimageblanked
entrypointdrawallPERSON:
      ld b,0
      ld c,21
      ld hl,cluetypeP
     call  writeHLstringwithvpokexyposBC
    jp donedisplayingcluefromcontrolcharacter
clueCcreatureWITHDRAWALLMSG:
           call needtodrawallartfullimage
          call setloadblankartfullimageFLAGTOtrue
         jp entrypointcreaturedrawall
clueCcreature:
    call needtodrawallartfullimageblanked
entrypointcreaturedrawall:
      ld b,0
      ld c,21
      ld hl,cluetypeC
     call  writeHLstringwithvpokexyposBC
     jp donedisplayingcluefromcontrolcharacter
cluefoodWITHDRAWALLMSG:
      call needtodrawallartfullimage
       call setloadblankartfullimageFLAGTOtrue
       jp entrypointdrawallFOOD
cluefood:
     call needtodrawallartfullimageblanked
entrypointdrawallFOOD:
      ld b,0
      ld c,21
      ld hl,cluetypeF
     call  writeHLstringwithvpokexyposBC
    jp donedisplayingcluefromcontrolcharacter
donedisplayingcluefromcontrolcharacter:

    push hl
  ld hl,CHOOSEDOALLTHEDRAWINGONLY
  ld a,(hl)
  pop hl
  cp 1
  call z,overwritetouserdefinedifdrawingall
     pop bc
    pop hl
  pop de
  ret

overwritetouserdefinedifdrawingall:
   ld b,0
      ld c,21
      ld hl,cluetypeUSERDEFINED
     call  writeHLstringwithvpokexyposBC

    push hl
 ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
 ld a,(hl)
 pop hl
  cp MENUPROGLANGUAGE
 jp nz,blankoutonyourpapermessageforprogmode

     ld b,0
      ld c,21
      ld hl,blankoutwords
     call  writeHLstringwithvpokexyposBC
blankoutonyourpapermessageforprogmode:

   ret

changetoblanktextifneedbeinHL:
   push de
    ld de,CHOOSEDOALLTHEDRAWINGONLY
  ld a,(de)
  pop de
  cp 0
  jp z,dontloadblankanswerifnotUSERDEFINEDansweronpaper
 ld hl,blankedanswer
dontloadblankanswerifnotUSERDEFINEDansweronpaper:
  ret



   

setcircleorsemicrlelabel:
  ret





needtodrawallartfullimageblanked:
  push bc
  push de
  push hl
  ld b,1
  ld c,1
  ld hl,genericmessage1b
  call  writeHLstringwithvpokexyposBC


  ld hl,P1TURN
  ld a,(HL)
  cp 1
  jp z,accpetorchoosemesgep1

  ld hl,P2TURN
  ld a,(HL)
  cp 1
  jp z,accpetorchoosemesgep2
accpetorchoosemesgep1:
  ld hl,ingamemessage1P2
  call genericmessaheinHL
  jp done232383
accpetorchoosemesgep2:
  ld hl,ingamemessage1P1
  call genericmessaheinHL
  jp done232383


done232383:
  pop hl
  pop de
  pop bc
 ret

blankaboveifneedsbe:
   push de
  push hl
  push bc
  ld hl,Blanklabelforintterpretermessages
     ld b,1
      ld c,1
       call  writeHLstringwithvpokexyposBC
  pop bc
  pop hl
  pop de
  ret


needtodrawallartfullimage:

  
   push hl
   ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
  cp MENUPROGLANGUAGE
  call z,drawstartdrawingMSGsinsteadofdrawallMSG

   push hl
   ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
  cp MENUPROGLANGUAGE
  jp z,skipifinprogmode

  ld b,0
  ld c,1
  ld hl,genericmessage1;;
  call  writeHLstringwithvpokexyposBC

skipifinprogmode:
 ret

drawstartdrawingMSGsinsteadofdrawallMSG:
  
  ld b,0
  ld c,1
  ld hl,genericmessage52
  call  writeHLstringwithvpokexyposBC
   writetext &01,&03,blankchar;;
  ret





genericmessaheinHL: 
 






  ld b,0
  ld c,1
  push de

      push af
    push hl

    ld hl,P2TOP1MESSAGECORRECT

    ld a,(HL) 
   pop hl
    cp 199
   jp nz,noneedtocorrectmesssagefromP2toP1
    ld hl,ingamemessage1P1
noneedtocorrectmesssagefromP2toP1:
  pop af
 

  call  writeHLstringwithvpokexyposBC
  
  writetext &01,03,blankchar;;deletes an unwanted character
  writetext 19,02,blankchar;;;;deletes an unwanted character


  pop de

 ret



removegarbagefromscreen:

  PUSH DE
  PUSH BC
  PUSH HL
  PUSH AF
  PUSH IX
  PUSH IY

   ld hl,GAMEEND
 ld a,(hl)
 cp 1
 jp z,nothingtoremove

    ld hl,MOVEGARBAGECOUNTER
    ld a,(hl)
    inc a
    ld (hl),a
    and 255
    cp 1

   call z,garbagemovedbyredraw
nothingtoremove:
  POP IY
  POP ix
  POP AF
  POP HL
  POP BC
  POP DE

  ret


garbagemovedbyredraw:
  call redrawinstructionafterplayersmessage
   call drawframe
 call drawarrowinstructions
 CALL blankleftedgePARTIAL
  ret

view1stpagesetflag:
   ld e,0
   ret
view3rdpagesetflag:
   ld e,2
   ret


showviewpingpage1banner:
  push af
  push de
  push bc
   ld bc,&0C17

     ld de,441
    ld hl,&0701;;
     call TilesToVRAM
  call drawbuttonforbothgameMODESrestart
  
  
  pop bc
 pop de
 pop af
  ret

showonlyhumangamnemessage:
 push hl
  push af
  push de
  push bc
  
   ld b,11
    ld c,17
  
     ld de,404
    ld hl,&0801;;
     call TilesToVRAM
  pop bc
 pop de
 pop af
 pop hl
  ret



showviewpingpage1bannerwothoutotherbuttons:
  push af
  push de
  push bc
  
   ld bc,&0C17
    
   ld de,441
    ld hl,&0701;; 
     call TilesToVRAM
 
  
  pop bc
 pop de
 pop af
  ret


drawbuttonlabels:
 push hl
 ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
 ld a,(hl)
 pop hl
 
  cp MENUCHOICEGAMESTARTANDDRAWOVEREXISTING 
  jp z,drawbuttonforbothgameMODESrestart
  cp MENUCHOICEDRAWYOUDRAWEVERYTHING  
  jp z,drawbuttonforbothgameMODESrestart
  cp MENUPROGLANGUAGE   
  jp z,drawbuttonforprogrammingmode


drawbuttonforbothgameMODESrestart:
     
      ld bc,&0A00
    ld de,354;
    ld hl,&1601
     call TilesToVRAM


       ld bc,&0015
       inc c 
    ld de,405;
    ld hl,&0B02;; 
     call TilesToVRAM


    push hl
 ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
 ld a,(hl)
 pop hl
  cp MENUPROGLANGUAGE
   jp nz,dontredrawexitlongpressforprogonlymode
  
       ld bc,&0015
       inc c 
    ld de,428
    ld hl,&0A01
    inc h
     call TilesToVRAM

  ;;;toggle grid button drawn 
  call showgridonofftogglebanner
dontredrawexitlongpressforprogonlymode:
 jp done234227 

drawbuttonforprogrammingmode:
 

       ld bc,&0A00
    ld de,354;;
    ld hl,&1601;; 
     call TilesToVRAM


       ld bc,&0015
       inc c 
    ld de,405;
    ld hl,&0B02;
     call TilesToVRAM


       ld bc,&0015
       inc c 
    ld de,428
    ld hl,&0B01
     call TilesToVRAM

  
done234227:  
  ret




showgridonofftogglebanner:
  push af
  push de
  push bc
   ld bc,&0000
    ld de,376;
    ld hl,&0B01;;
     call TilesToVRAM
  pop bc
 pop de
 pop af
  ret

showviewpingpage2banner:
  push af
  push de
  push bc
   ld bc,&0C17
    ld de,384+7;;
    ld hl,&0701;; 
     call TilesToVRAM
  pop bc
 pop de
 pop af
  ret

showviewpingpage3banner:
  push af
  push de
  push bc
   ld bc,&0C17
    ld de,384+14;;
    ld hl,&0701;; 
     call TilesToVRAM
  pop bc
 pop de
 pop af
  ret

setloadblankartfullimageFLAGTOtrue:
   push hl 
   push af
   ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,1;;
  ld (HL),a
  pop af
  pop hl
 ret

setloadblankartfullimageFLAGtofalse:
   push hl 
   push af
   ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,0;;;
  ld (HL),a
  pop af
  pop hl
 ret

add32tobaseartfullimage3address:;;;for finding artfullimage adress to load and its text
   push de 
   ld de,32
   add hl,de
   pop de
  ret


settextfromDforimahenumberinB:
   dec b;;;make it match the page number in SW numbering 
   dec b
   dec b
  push bc
           push bc
             call blankoutanswerwith15spaces
             call pagein32Kto48Ktextforimages
       ld hl,BASEADartfullimagemsg3;;;
         pop bc
      
   ld a,b
   cp 0
   jp z,ignoreloop
add32tobasetextadressloop:
   push bc
  call add32tobaseartfullimage3address:
   pop bc
  djnz add32tobasetextadressloop
ignoreloop:

    
   push hl
   LD HL,REVEALANSWERFORPLAYERTOMEMORISE 
   LD A,(HL)
     ld iyl,a
   pop hl

         push hl
      ld b,0
      ld c,21
     call displaycluetype
   pop hl
      ld b,0
      ld c,22
     inc hl
   call showanswerifnotinplayerdrawsallgamemode
     call nz, showblankedanswer
  pop bc
  ret

showanswerifnotinplayerdrawsallgamemode:
  push de
  ld de, CHOOSEDOALLTHEDRAWINGONLY
   ld a,(de)
  pop de
  cp 1
  jp z,ignore342328
   ld a,iyl
       cp 1
  call z,writeHLstringwithvpokexyposBC
ignore342328:
  ret
  
   


showblankedanswer:
  ld hl,blankedanswer
  call writeHLstringwithvpokexyposBC
   writetext &01,22,blankchar;
  ret

 
calldrawartfullimagewithttext:

  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(hl)
  ld b,a

  call settextfromDforimahenumberinB
  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(hl)
  ld d,a
  
  call setSWpageinDtoload;
  call drawartfullimagetoscreenandsetartfullimageHIGHandLOWbytes;;;
  call showviewpingpage1bannerwothoutotherbuttons
  ret
blankoutonecolumnincanvas:
  push bc
  push de
  push hl



blankVRAMtilesusedincanvas:
  ld hl,511;;

       ld a,l
   out (&BF),a
    ld a,H;;;
   out (&BF),a 
blankabyteinVRAM:
   

   push hl

    ld a,0
   out (&BE),a
  
    ld a,0
   out (&BE),a
    
    ld a,0
   out (&BE),a
    
    ld a,255
   out (&BE),a
   

    pop hl
       ld a,h
       cp 10;;
      jp z,exitVRAMloop
              inc hl
   jp blankabyteinVRAM
exitVRAMloop:
  ret


setartfullimageinAorBLANKartfullimagetoloadwithmatchingtext:
  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld (hl),a 
  ret
  
 


drawansetanyartfullimagewinA:
  push de
  push hl
  push bc
 
  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY2
 ld (HL),a

  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld (hl),a 
 

  ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
  ld a,(hl)
  call calldrawartfullimagewithttext

  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,(HL)
  cp 0
  jp z,dontblankartfullimage
  call blankVRAMtilesusedincanvas
dontblankartfullimage:
  pop bc
  pop hl
  pop de
  ret



resetandloadnewartfullimageforonepoint:
 

   ld hl,NOTPASSEDTHROUGHMAINLOOPONCE
   ld a,(hl)
   cp 1
   jp z,ignorethereset


   ld hl,LONGPRESSCOUNTERSTARTOVER
   ld a,241;;value controls key press delay
   ld (hl),a


  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,0;;;assume it is not blank artfullimage to load
  ld (HL),a



  ld hl,MergeDrawPCCOUNTERFOREXECUTING
  ld a,0
  ld (hl),a

  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
  ld (hl),a


    ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,0
   ld (hl),a


   ld hl,PENDOWNFLAG 
 ld a,1
 ld (hl),a

   ld hl,PENDOWNFLAG 
   ld a,1
   ld (hl),a

  ld hl,MergeDrawPCCOUNTER;;;
  ld a,0
  ld (hl),a;;;set MergeDraw pc to zero



  ld hl,XPOSLOOPTILES2SCR
  ld a,CANVASXPOS
  ld (hl),a
  ld hl,YPOSLOOPTILES2SCR
  ld a,CANVASYPOS
  ld (hl),a



  call drawcanvastoscreen
   push hl
   ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY2
  ld a,(HL)
   ld iyl,a
  pop hl
  push iy;;;need to use IY onto stack to preserve sccurrent doodl number drawn affect by sandwiched calls belwo
    call clearscreenbuffer
  call clearMergeDrawprogramtoNONEcommands
  pop iy
  ld a,(iyl)
   push hl
   ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY2
  ld (HL),a
   ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
    ld (HL),a
  pop hl
  


 ld hl,CURSORPOSITIONINPAGE
 ld a,8
 ld (hl),a;;initlise 

 ld hl,MergeDrawPCCOUNTERFORGUI
 ld a,0
 ld (hl),a;;initlise 

 ld hl,PAGENUMBERONSCREEN;;;
 ld a,0
 ld (hl),a;;initlise to zero

  ld a,%101;;;;
   ld (hl),a
  ld hl,INSTRUCTIONCHOICE
  ld a,%00000111;;;
   ld (hl),a
  ld hl,INSTRUCTIONVALUE
   ld a,250
   ld (hl),a
  ld hl,INSTRUCTIONVALUEFOROUNDING
   ld a,0
   ld (hl),a
 ld hl,INSTRUCTIONPOINTER
 

    push hl
  push af
 ld hl,MergeDrawPCCOUNTERFORGUIconstant
 ld a,1;;;
 ld (hl),a
  pop af
  pop hl

     call initialisehedgehogcursorposition

  ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
    ld a,1;;;
    ld (HL),a
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,0;;;
  ld (HL),0

   ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,0
   ld (hl),a


  ld hl,LASTCOMMANDISREPEATFLAG;;;
   ld a,0
   ld (hl),a


 ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXTCOPY2
 ld a,(HL)

 ld hl,ARTFULLIMAGENUMBERTOSELECTDRAWWITHTEXT
 ld (HL),a;





 call drawansetanyartfullimagewinA
 

  call biggerdelay;;;stop it resetting too fast
  call biggerdelay
  call biggerdelay
  call biggerdelay
  call biggerdelay
  call biggerdelay
  call biggerdelay
 
  ld hl,&c900
  ld a,&21
  ld (hl),a
  call renderinstructionsonce;
  call interpretMergeDrawprogram
  ld hl,&c900;;;;;
  ld a,EMPTYMEMORYFORCMD
  ld (hl),a
  call renderinstructionsonce;
  call interpretMergeDrawprogram
 
  push de
  push bc
  push af
  push hl
  ld hl,GAMESTARTOVEFLAGINGAMEMODE
  ld a,(hl)
  cp 1 
  call z,cleared
  pop hl
  pop af
  pop bc
  pop de
ignorethereset:


 ret

cleared:
  ld  hl,GAMESTARTOVEFLAGINGAMEMODE
  ld a,0
  ld (hl),a
  ld hl,genericmessage30
  call  genericmessaheinHL
  ret


chooserandomartfullimage:

   push de
   push bc
   push hl
   push af
  
  call  Drawthetwochardbottomleft
  

selectbetween3to14:;;;between 3 and 14 as 3 corresponds to first page (page 3) in value used to page 
;;;art work to draw over ,pages 0,1,2 are hold main program code
 
  push hl
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
  ld a,(hl)
  cp 1
  jp z,loadblankartfullimageimageeverytime
  jp chooserandomlyaartfullimage
loadblankartfullimageimageeverytime;
  ld a,13
  jp done8261237
chooserandomlyaartfullimage:
    call RANDOMnum;;; call rng to slect the random value here

  and UPPERLIMITNOARTWORKS
  add a,3
done8261237:
  pop hl



  
  cp 15
  jp z,selectbetween3to14
  cp 16
  jp z,selectbetween3to14
  cp 17
  jp z,selectbetween3to14
  cp 18
  jp z,selectbetween3to14


  push af
  call drawansetanyartfullimagewinA
  pop af
  push af
  call drawansetanyartfullimagewinA
   pop af
   push af
  call drawansetanyartfullimagewinA
   pop af


  
nonneedtocorrectmessagefromP1toP21:


   pop af
   pop hl
   pop bc
   pop de
 ret

showchosenartfullimage:
     push de
   push bc
   push hl
   push af
  push af
  call drawansetanyartfullimagewinA
  pop af
  push af
  call drawansetanyartfullimagewinA
  pop af
  push af
 call drawansetanyartfullimagewinA
  pop af

    
   pop af
   pop hl
   pop bc
   pop de
   RET

incmenucounter:
  ld hl,MENUCOUNTERCHOICE
  ld a,(hl)
  inc a
  ld (hl),a
   and %00111100;;;;
   call doAdivisionof2
   call doAdivisionof2
   call doAdivisionof2
   cp 6;;;number of items in menu
   call z,resetmenubacktofirstoption
  ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
  ld (hl),a
  call movemenupointer

  ret


resetmenubacktofirstoption:
  push hl
  ld a,0
   ld hl,MENUCOUNTERCHOICE
   ld (hl),a
    ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
    ld (hl),a
   pop hl


  ret

movemenupointertoproglang:
 ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
 LD A,3
 call movemenupointer
 ret


movemenupointer:
     

    ld b,1
    add a,a
    add a,a
    add a,a
    add a,144



   
    ld c,a
     ld de,&0000  
     ld e,MENUARROWPOINTSPRITE
     ld h,0  ;tile details 
     ld a,4  ;
     call SetupSprite

     RET

hidemenupointer:
    
    ld b,1
    add a,a
    add a,a
    add a,a
    add a,144
   add a,48; ;;;add 48 to move off screen menupointer when in game mode


   
    ld c,a
     ld de,&0000 
     ld e,MENUARROWPOINTSPRITE
     ld h,0  ;tile details 
     ld a,4  
     call SetupSprite


     RET


progmodeflags:
    ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,1
  ld (hl),a
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
   ld a,1
   ld (hl),a
  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
    ld a,1
  ld (hl),a
  ld a,13
  call drawansetanyartfullimagewinA
  ret

resettonormalfromflagsetFORprogmode:
    ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,0
  ld (hl),a
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
   ld a,0
   ld (hl),a
  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
    ld a,0
  ret


callsubroutineformenuchoice:

  push hl
  ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
  ld a,(hl)
 pop hl
  ;;;

  cp MENUCHOICEGAMESTARTANDDRAWOVEREXISTING 
  jp z,setflagsfordrawoverimages

  cp MENUCHOICEDRAWYOUDRAWEVERYTHING
  jp z,setflagforDRAWeverthing

  cp MENUPROGLANGUAGE 
 jp z,setflagsforprogrammininMergeDrawmode

  cp MENUINKCOLOUR
  jp z,setinkcolour
 
  CP MENUINSTRUCTIONHWOTOPLAY
  JP Z,showinstructions

  CP MENUCREDITS
  JP Z,showcredits

showcredits:
    call moveallspritesoffscreen;;;made invisible when show in instruction instead
  call hidemenupointer
      ld a,3
   call writepageinAoftext;;;shows page of credits or instruction text page number is in A 
   

letplayerincludepageuntilthepressedkey:
    di
   in a,(&DC)
   bit 4,a;;;exit
       jp z,exitletplayerincludepageuntilthepressedkey
     call biggerdelay
    ei
 jp letplayerincludepageuntilthepressedkey

exitletplayerincludepageuntilthepressedkey:
  writetext 0,0,blankline;;;;compliments clearmostbutnotallofthescreen

  call redrawmenu
   jp done32423;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;exit back to meanu after title screen redrawn



showinstructions:
    call hidemenupointer
    ld a,0
   call writepageinAoftext;;
   
 ;;; 
letplayerincludepageuntilpressedkey:
  di 
   in a,(&DC)
   bit 4,a;;;
       jp z,exitletplayerincludepageuntilpressedkey
     call biggerdelay
   ei
 jp letplayerincludepageuntilpressedkey
exitletplayerincludepageuntilpressedkey:

    ld a,1;;;
   call writepageinAoftext;;;

letplayerincludepageuntilpressedkey2:
   di
   in a,(&DC)
   bit 4,a;;;
       jp z,exitletplayerincludepageuntilpressedkey2
     call biggerdelay
    ei
 jp letplayerincludepageuntilpressedkey2
 
exitletplayerincludepageuntilpressedkey2:


 ld a,2;;;
   call writepageinAoftext;;;
letplayerincludepageuntilpressedkey3:
    di
   in a,(&DC)
   bit 4,a;;;
       jp z,exitletplayerincludepageuntilpressedkey3
     call biggerdelay

   ei
 jp letplayerincludepageuntilpressedkey3
exitletplayerincludepageuntilpressedkey3:


 ld a,4;;;
   call writepageinAoftext;;;
letplayerincludepageuntilpressedkey4:
    di
   in a,(&DC)
   bit 4,a;;;
       jp z,exitletplayerincludepageuntilpressedkey4
     call biggerdelay

   ei
 jp letplayerincludepageuntilpressedkey4
exitletplayerincludepageuntilpressedkey4:

 
  writetext 0,0,blankline;;;compliments clearmostbutnotallofthescreen

;;;;;redraws menu after text instrctuion chosen from menu are shown
    call redrawmenu
 
  
    
;;;;;;;;;;;;;;;;;END redraw menu agaain grphics  after deleted from showing instructions;;;;;;;;;;;;;;;;;;;;;;;;;
 
   
  jp done32423;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;exit back to mmenu and title screen


setinkcolour:
  

  ld hl,DELAYCOUNTERFORINKCHOCEMENU 
  ld a,(hl)
  inc a
  and 15
  ld (hl),a
  cp 1
  jp nz,done32423;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ld hl,CHOOSEINKFLAG
  ld a,(hl)
  xor 1;;;flip between solid and and multicolour
  ld (hl),a
  cp 1
  jp z,updateinkmenuchoceonscreen
  ld (hl),a
  cp 0
  jp z,updateinkmenuchoiceonscreen2
updateinkmenuchoiceonscreen2:
   writetext &01,22,menuchoice7
   jp done32423
updateinkmenuchoceonscreen:
   writetext &01,22,menuchoice5
  jp done32423
  

setflagsforprogrammininMergeDrawmode:
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,1
  ld (hl),a
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
   ld a,1
   ld (hl),a
  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
    ld a,1
  ld (hl),a
    ld a,13
  call drawansetanyartfullimagewinA
ignoreflagssetprogmode:
 jp done32423

setflagsfordrawoverimages:
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,0
  ld (hl),a
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
   ld a,0
   ld (hl),a
        ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
         ld a,0
           ld (hl),a
ignoreflaggamestartwithimages:
   jp done32423

setflagforDRAWeverthing:
 
  ld hl,CHOOSEPROGRAMMINGLANGFLAG
  ld a,0
  ld (hl),a
   ld hl,CHOOSEDOALLTHEDRAWINGONLY
   ld a,1
   ld (hl),a
ignoreflaggamestartwithNOimages:
   jp done32423

done32423:

 
  ret

updateinkchoceonmenu:
  push af
  push hl
  push bc
  push de
  ld hl,CHOOSEINKFLAG
  ld a,(hl)
  cp 1
  jp z,updateinkmenuchoiceonscreenmulticolour
  ld (hl),a
  cp 0
  jp z,updateinkmenuchoiceonscreensolidonly
updateinkmenuchoiceonscreensolidonly:
   writetext &01,22,menuchoice7
   jp done3242381
updateinkmenuchoiceonscreenmulticolour:
   writetext &01,22,menuchoice5
  jp done3242381
 
done3242381:
  call correctmenuINKdisplayedifneedsbe
  pop de
  pop bc
  pop hl
  pop de
  ret

correctmenuINKdisplayedifneedsbe:
  push hl
  push af
  push de
  push bc
 ld hl,ONETIMEFLAGTOINVERTCOLOURMENUCHOICE
 ld a,(HL)
 cp 1
 jp z,showitsissolidcolour;;correction is done once at every hard reset or power up of console
 jp npneedtocorrectmenu
showitsissolidcolour:
   writetext &01,22,menuchoice5
  ld hl,ONETIMEFLAGTOINVERTCOLOURMENUCHOICE;;;stays like  this for rest of game until power on or off again reset
  ld a,0
  ld (hl),a
npneedtocorrectmenu:
  pop bc
  pop de
  pop af
  pop hl
  ret
 

  
  


redrawmenu:
   push bc
     call clearmostbutnotallofthescreen
   call movemenupointer

   writetext &01,18,menuchoice1
   writetext &01,19,menuchoice2
   writetext &01,20,menuchoice3
   writetext &01,21,menuchoice4
   call updateinkchoceonmenu
   writetext &01,23,menuchoice6
   call drawframonTITLESC
   DefineTheTiles Teapottitle,Teapottitleend-Teapottitle,355;;;reload graphics tiles required for title screen
  
  call resertitlescreenparams
  call drawARTfulword
   
     call loademptycup
   pop bc
  ret

redrawmenutextpart:
    push bc
      writetext &01,18,menuchoice1
   writetext &01,19,menuchoice2
   writetext &01,20,menuchoice3
   writetext &01,21,menuchoice4
   call updateinkchoceonmenu
   writetext &01,23,menuchoice6
   pop bc
  ret


drawfirstletterL:
         LD B,12;;;
     LD C,0
     ld h,2
     LD L,15
     ld d,0
     ld e,228;;
     call TilesToVRAM
    ret

  


 

blankchar: db ' ',255;;;
blankchar2: db ' ',255;;;

p1counter: db '\',255;;;
p2counter: db ']',255;;;
blankplayercounterchar: db '[',255;;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writepageinAoftext:
   push af
   call clearmostbutnotallofthescreen
   pop af

   cp 0
   jp z,loadTHEpagenumber
   cp 1
   jp z,loadTHEpagewithnumber2
   cp 2
   jp z,loadTHEpagewithnumber3
   cp 3
   jp z,loadTHEpagewithnumber4;;;credits page all other pages are instructions of description of game
   cp 4
   jp z,loadTHEpagewithnumber5
loadTHEpagenumber:
   ld hl ,PAGE1TEXTINSTR1
  jp doneloadedpage
loadTHEpagewithnumber2:
   LD HL, PAGE2TEXTINSTR1
  jp doneloadedpage
loadTHEpagewithnumber3:
   LD HL, PAGE3TEXTINSTR1
  jp doneloadedpage
loadTHEpagewithnumber4:
   LD HL, PAGE4TEXTINSTR1
  jp doneloadedpage
loadTHEpagewithnumber5:
   LD HL, PAGE3bTEXTINSTR1

  
  jp doneloadedpage


doneloadedpage:
   
   ld de,33;;;need to get past end of line char encoded as 255
  ld b,18;;;NO OF LINES ON the PAGE  of text
downloop:
     push bc
     ld a,18
     sub b
     ld iyl,a
     push hl
     push de
    textloadHL &00,iyl 
    pop de
    pop hl
    pop bc
    add hl,de
  djnz downloop
 
   push bc
    push af
   ld b,30
   ld c,23-6
  ld hl,VPOKETHIS
  ld a,439-256
  ld (hl),a
  call vpokeover255
   pop af  
  pop bc

   ret

redrawentercmdbanner:
    push af
  push de
  push bc
  push hl
   call RANDOMnum
   sub 15
   jp c,dontupdatebanner
   ld bc,&0000
   ld b,31-4
    ld de,371;
    ld hl,&0501;; 
     call TilesToVRAM
dontupdatebanner:
     pop hl
  pop bc
 pop de
 pop af
 ret

redrawARTFULtitle:
  push bc
     LD B,0
     LD C,0
     ld h,12
     LD L,15
     ld d,0
     ld e,48
     call TilesToVRAM

     LD B,12
     LD C,0
     ld h,2
     LD L,15
     ld d,0
     ld e,228;;
     call TilesToVRAM
 pop bc
  ret

Titlescreen:
     push bc

  call moveallspritesoffscreen
  call resertitlescreenparams
  call drawARTfulword

  call biggerdelay
  DefineTheTiles CRCchar,CRCcharend-CRCchar,290;as CRC as ? quation mark character
  call biggerdelay
  DefineTheTiles Ahumangame,Ahumangameend-Ahumangame,404
  call biggerdelay
  call biggerdelay
  call biggerdelay
 

  push hl

  call blankHHsprites






  pop hl



 
  call initialisehedgehogcursorposition
   call blankHHsprites;;;blank out in game hedge hog cursor on title screen using tile 15 wich is blank
   call clearmostbutnotallofthescreen
   writetext &00,&00,blankline;;;;delete counters at top most line

 
   call movemenupointer
   writetext &01,18,menuchoice1
   writetext &01,19,menuchoice2
   writetext &01,20,menuchoice3
   writetext &01,21,menuchoice4
   call updateinkchoceonmenu
   writetext &01,23,menuchoice6
     writetext 10,16,authorinfo
  call showonlyhumangamnemessage

   call pagein32Kto48Ktextforimages
  DefineTheTiles Artfutitle,Artfutitleend-Artfutitle,16+32
   DefineTheTiles Letterl,Letterlend-Letterl,16+32+180
  DefineTheTiles Teainair, Teainairend-Teainair,3;
 DefineTheTiles CRCchar,CRCcharend-CRCchar,290;copyrght symbols ?
      push ix
    pop ix


     LD B,0
     LD C,0
     ld h,12
     LD L,15
     ld d,0
     ld e,48
     call TilesToVRAM

     LD B,12
     LD C,0
     ld h,2
     LD L,15
     ld d,0
     ld e,228
     call TilesToVRAM



  ld hl,TOGGLEHHmetaspriteONOROFF
  ld a,1
  ld (hl),a


   ld hl,HHTITLEACROSSPOS
   ld a,128
   ld (hl),a

   DefineTheTiles HHframe1,HHframe1end-HHframe1,16

   call showHHmetaspriteifchosen



  


  call drawframonTITLESC

   


     ld b,192
     ld c,62
     ld de,&0000  
     ld e,3  ;; 
     ld h,0  
     ld a,63  
     call SetupSprite

   


playeranswerconfirmloop21:;;;title screen loop main
  LD ixh,238;;
    ;;;flowing tea sprite here
        ld b,192
     ld c,62
     ld de,&0000  
     ld e,3  ;; 
     ld h,0  ;
     ld a,63  ;
     call SetupSprite
    call blankmiddletwolinesontitlescreensub

   call delay


   call loadteapotiles
      DefineTheTiles menuTSarrow,menuTSarrowend-menuTSarrow,5
       push ix
    pop ix
     call drawframonTITLESC
     call redrawmenutextpart
 push hl
 push af
   ld hl,JUSTEXITEDPROGLANGMODE
   ld a,(hl)
   cp 1
  call z,movemenupointertoproglang
  
  ld hl,JUSTEXITEDPROGLANGMODE
  ld a,0
  ld (hl),a


 pop af
 pop hl

PLAYERanswerconfirmloop212:
  di 
  ld a,ixh
  cp 238
  call z,loadteapotiles;;;and cup empty too
  push hl 
  push bc
  push de
  push af
  call titleHHwalkacross
  ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  call z,checkfordrawletterLononTITLEscreenpicframe

  call moveallspriteoffscreennotusedintitlescreen
  



  
  pop af
  pop de
  pop bc
  pop hl


  call ReadPlayerControlKeys
  bit 4,a
  call z,incmenucounter

  

   in a,(&DC)
   bit 5,a
       jp z,exitPLAYERanswerconfirmloop212
     call biggerdelay
  ei
 jp PLAYERanswerconfirmloop212
  


exitPLAYERanswerconfirmloop212:
  

    call callsubroutineformenuchoice;;;processes choice on menu
    call restoremenupointerifneedsbe


 

  ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
  ld a,(HL)
  cp MENUINKCOLOUR 
  jp z,PLAYERanswerconfirmloop212;;doe not jump to drawing all graphics on screen
  cp MENUINSTRUCTIONHWOTOPLAY
  jp z,playeranswerconfirmloop21;;;jump redraws all graphics on titlesc screen;;just needs to update text for ink
  cp MENUCREDITS
  jp z,playeranswerconfirmloop21

     call moveallspritesoffscreen
    CALL loadalltilesrequiredbeforeevergame
  DefineTheTiles Circlein4chars,Circlein4charsend-Circlein4chars,1;;;put in 4 char circle text here
   
    ;;;NOW in two chars write over the menu purple arrow which gets redefined when menu goes back to start
   DefineTheTiles Nowin2chars,Nowin2charsend-Nowin2chars,5
    

   call hidemenupointer
  call loadHHsprites;;;;if gets at this point the menu choce proceeds to gamne so load the HH cursor sprites that was previously blanked out
 call clearmostbutnotallofthescreen;;;;;;;;;;;;;;;;;;;;;;de
 call delay;;;stop menu input button being perssed too fast
 call delay
 call delay
 call delay
  ;;;;;play start of game alert
 push bc
 push af
 push hl
 push de
 ld e,3
 STORESONGPOSASCHOICEVAR e;
 pop de
 pop hl
 pop af
 pop bc
 ;;;end start of game alert

  writetext &00,&00,blankline;;;;delete counters at top most line

     ld hl,genericmessage15
   call genericmessaheinHL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;need to reset scores 
   ld hl,GAMEEND
    ld a,0
    ld (hl),a
  
  ld hl,P1SCORE;;; 
 ld a,0
 ld (hl),a
 ld hl,P2SCORE;;; 
 ld a,0
 ld (hl),a
 call blankgeneralmssgesarea
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;do reset block
;;;;;;;;;;START BLOCK OF CODE THAT START BEFORE INSTRuCTION LOOP;;;;;;
;;;hence the block of code below will reset for a new game
 ld hl,P1TURN
 ld a,1
 ld (hl),a
 ld hl,P2TURN;;;not used
 ld a,0
 ld (hl),a

 LD HL,NOOFPOINTPLAYEDSOFARINONEGAME 
 LD A,0
 LD (HL),a
 
 ld hl,REVEALANSWERFORPLAYERTOMEMORISE
 ld a,0
 ld (hl),a

  ld hl,ISBLANKARTFULLIMAGETOLOADFLAG
  ld a,0;;;assume it is not blank artfullimage to load
  ld (HL),a

  ld hl,LONGPRESSCOUNTERSTARTOVER
  ld a,0
  ld (HL),a


  ld hl,MergeDrawPCCOUNTERFOREXECUTING
  ld a,0
  ld (hl),a

  ld hl,CORRECTCURSORIFSEMICIRCLEDRAWN
  ld a,0
  ld (hl),a


    ld hl,CURRENTMergeDrawPAGESHOWINGINGGUI
   ld a,0
   ld (hl),a


   ld hl,PENDOWNFLAG 
 ld a,1
 ld (hl),a

  
  call clearscreenbuffer
  call clearMergeDrawprogramtoNONEcommands

  ld hl,PENDOWNFLAG 
   ld a,1
   ld (hl),a

  ld hl,MergeDrawPCCOUNTER;;;needs to text if too larger
  ld a,0
  ld (hl),a;;;set MergeDraw pc to zero

   ld hl,XPOSLOOPTILES2SCR
  ld a,CANVASXPOS
  ld (hl),a
  ld hl,YPOSLOOPTILES2SCR
  ld a,CANVASYPOS
  ld (hl),a


  call drawcanvastoscreen

  
 ld b,50
 ld c,50


 
 
  
 push hl
 ld hl,CURSORPOSITIONINPAGE
 ld a,8
 ld (hl),a;;init

 ld hl,MergeDrawPCCOUNTERFORGUI
 ld a,0
 ld (hl),a;;init

 ld hl,PAGENUMBERONSCREEN;;;this is changed sets MergeDrawPCCOUNTERFORGUI to 0 2
 ld a,0
 ld (hl),a;;init to zero
 pop hl


  ld a,%101;;;;draw right;;;in GUI NOT SHIFTED As it starts with a non shoifted value counter
 ld (hl),a
 ld hl,INSTRUCTIONCHOICE
 ld a,%00010001;;;17
 ld (hl),a
  ld hl,INSTRUCTIONVALUE
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONVALUEFOROUNDING
 ld a,0
 ld (hl),a
 ld hl,INSTRUCTIONPOINTER

   push hl
  push af
 ld hl,MergeDrawPCCOUNTERFORGUIconstant
 ld a,1;;;
 ld (hl),a
  pop af
  pop hl


   ld hl,P1TURN
   ld a,(hl) 
   cp 1
    call z,P1ingamestart;;; implies pre initlisation by choosing image
   ld hl,P1TURN
   ld a,(hl)
   cp 0
    call z,P2ingamestart
  call initialisehedgehogcursorposition;;moving in in plotxy
   

  ld hl,VALIDREPEATORENDREPEATNOLOOPSINMergeDrawPROG
    ld a,1;;;
    ld (HL),a
  ld hl,VALIDREPEATEXACTLYONESTARTREPEATUSED
   ld a,0;;;
  ld (HL),0

   ld hl,VALIDflagREPEATandENDREPEATexactlyMATCHED
   ld a,0
   ld (hl),a


  ld hl,LASTCOMMANDISREPEATFLAG;;;for last commeand 
   ld a,0
   ld (hl),a


  call   show4blankcounters
;;;;;;;;;;end  BLOCK OF CODE THAT START BEFORE INSTRUCTION LOOP;;;;;;
    pop bc
  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;end of title screen code
titleHHwalkacross:

   
    ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  cp 1
  jp z, ignoreformovingacross

  ld hl,HHTITLEACROSSSPEED
  ld a,(hl)
  inc a

  ld (hl),a
  and 7
  cp 7
  jp z,loadframetwotilesHHtitle
  cp 0
  jp z,loadframeonetilesHHtitle

  jp donotloadanynewframenow
loadframeonetilesHHtitle:
 
   DefineTheTiles HHframe1,HHframe1end-HHframe1,16
     call showHHmetaspriteifchosen
   jp doneloadintheframeHHtitle
loadframetwotilesHHtitle:

   DefineTheTiles HHframe2,HHframe2end-HHframe2,16
   call showHHmetaspriteifchosen
   jp doneloadintheframeHHtitle

ignoreformovingacross:
doneloadintheframeHHtitle:
donotloadanynewframenow:

    ld hl,HHTITLEACROSSSPEED
    ld a,(hl)
     and 0
     cp 0
    call z,movetitleHHacross

  ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



movetitleHHacross:
  push af
  push hl
  ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  cp 1
  jp z, ignoremoveacross

    ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  cp 5
    call z,redrawmenu

    ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  cp 6
    call z,redrawARTFULtitle

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  inc a
  ld (hl),a 
  cp 224
  call z,setmovinHHupanddownontitoleflagtoTRUE

 cp 28  ;;;28 is about the edge of the frame
  call z,setmovinHHupanddownontitoleflagtoTRUE
  call showHHmetaspriteifchosen
ignoremoveacross:
  pop hl
  pop af
;;;;;;;;;;;;;ths part moves up or dowan if walk aCROSS FLag is not set
 push af
  push hl
  ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,(hl)
  cp 0
  jp z,ignoreformovingacross3754
  ld hl,HHTITLEVERTICALPOS;;
  ld a,(hl)
  dec a
  ld (hl),a 
  push af
  call showHHmetaspriteifchosen
  pop af
  call checktochangebacktoacrossflag
ignoreformovingacross3754:
  pop hl
  pop af
  ret


checktochangebacktoacrossflag:
  cp 255;;
  call z,setmoveHHcursorupanddownontitleflagtoFALSE
  ret

setmovinHHupanddownontitoleflagtoTRUE:
   push af
  push hl
  push de
  push bc
   DefineTheTiles HHframe3,HHframe3end-HHframe3,16


  
  ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,1
  ld (HL),a
  pop bc
  pop de
  pop hl
  pop af
  ret

setmoveHHcursorupanddownontitleflagtoFALSE:
   push af
  push hl
  ld hl,HHTITLEVERTICALMOVEMENTFLAG
  ld a,0
  ld (HL),a
  pop hl
  pop af
  ret
  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadteapotiles:
    push bc
    push hl
  ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
  ld a,(hl)
 pop hl
  cp MENUINKCOLOUR
  jp z,ignoreloadingtilesonstartscreen;;;avoids flicker on title screen


  call blankyellocanvasontitlescreenpic;;;done once here
  DefineTheTiles Teapottitle,Teapottitleend-Teapottitle,355;;;reload graphics tiles required for title screen
   ;;;;;;;;;;;;;;;;;;;;;;;draw teapot
    LD B,24;;
     LD C,1
     ld h,7
     LD L,7
     ld d,1
     ld e,355-256;;
     call TilesToVRAM
   call loademptycup
 

    ld ixh,2;;used as a nonce here
    ;;;using to blank 18 tilkes since a 2 by 8 block is usd for blanking the other 2 block contaiun a singke poxielk not uesd
    DefineTheTiles Blank18tiles,Blank18tilesend-Blank18tiles,270;;;this are used in blank tiles for blanking ART in ARTFULL and letter L in FULL
ignoreloadingtilesonstartscreen:  
   
  pop bc
  ret

loadteapotilesWITHOUTCUP:
      push bc
    push hl
  ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
  ld a,(hl)
 pop hl
  cp MENUINKCOLOUR
  jp z,ignoreloadingtilesonstartscreenw;;;avoids flicker on title screen


  DefineTheTiles Teapottitle,Teapottitleend-Teapottitle,355;;;
    LD B,24
     LD C,1
     ld h,7
     LD L,7
     ld d,1
     ld e,355-256;;
     call TilesToVRAM

    ld ixh,2
    DefineTheTiles Blank18tiles,Blank18tilesend-Blank18tiles,270
ignoreloadingtilesonstartscreenw:  
   
  pop bc
  ret
   

resertitlescreenparams:
   push bc
   
     ld hl,HHTITLEACROSSPOS
   ld a,128
   ld (hl),a
          ld hl,HHDRAWINGBOTHPARTOFLFLAG
     ld a,1;;;
   ld (hl),a

       ld hl,HHDRAWINGFULLCUPFLAG
     ld a,1;;
   ld (hl),a
   

     ld hl,HHTITLEVERTICALMOVEMENTFLAG
     ld a,0
   ld (hl),a

  ld hl,HHTITLEVERTICALPOS
     ld a,255;;;cant be 0/255 here or misses drawing the L on first iteration at start
   ld (hl),a
   call clearspritesoffscreen
  pop bc
  ret


checkfordrawletterLononTITLEscreenpicframe:
  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 224;;;if in line with space for L
  call z,drawletterBOTTOMHALFonthetitlescreen
 ;; cp 100-32;if in line with cup 
  cp 28
  call z,drawfulloremptycupbasedontheflag
      call checkbetweensecondLandcupatleast
  ret

drawfulloremptycupbasedontheflag:
  ld hl,HHDRAWINGFULLCUPFLAG 
  ld a,(hl)
  cp 0
  call nz,drawfullcup;;;;
    ld hl,HHDRAWINGFULLCUPFLAG 
  ld a,(hl)
  cp 0
  call z,loademptycup
  ret

drawfullcup:
    ld hl,HHTITLEVERTICALPOS
   ld a,(hl)
   sub 239
  jp nc,donotdrawfullcup
  call   loadfullcup;;draws full cup

donotdrawfullcup:
 ret

 
setCUPdrawflagtoTRUEasnonzero:
    or a
  xor a
  ld hl,HHDRAWINGFULLCUPFLAG 
  ld a,(hl)
  inc a
  ld (hl),a
  ret

setCUPdrawflagtoFALSEaszero:
    or a
  xor a
  ld hl,HHDRAWINGFULLCUPFLAG 
  ld a,0
  ld (hl),a
  ret



loademptycup:

      DefineTheTiles Emptycup,Emptycupend-Emptycup,258;;;reload graphics tiles required for title screen
     ld hl,HHTITLEVERTICALPOS
   ld a,(hl)
   cp 255
   jp z,drawcupspecialcaseatstart

     ld hl,HHTITLEVERTICALPOS
   ld a,(hl)
   sub 239
  jp nc,donotdrawemptycup

drawcupspecialcaseatstart:
    LD B,20
     LD C,8
     ld h,4
     LD L,3
     ld d,1
     ld e,258-256
     call TilesToVRAM


donotdrawemptycup:
   ret


loadfullcup:

    ld hl,HHTITLEACROSSPOS
  ld a,(hl);;;
  cp 28
  jp nz,ignoreifnotinlinewithcup

   DefineTheTiles Fullcup,Fullcupend-Fullcup,258;;;reload graphics tiles required for title screen
        ld hl,HHTITLEVERTICALPOS;;;fills the cup on moving verticall up condtion
   ld a,(hl)
   sub  239
   jp nc,ignore3432
    LD B,20
     LD C,8
     ld h,4
     LD L,3
     ld d,1
     ld e,258-256;;;
     call TilesToVRAM

       push af
       push hl
  
     pop hl
    pop af
ignoreifnotinlinewithcup:
ignore3432:
  ret

checkbetweensecondLandcupatleast:
  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 229
  call z,setCUPdrawflagtoTRUEasnonzero

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  add a,241
  cp 251;comparision for a BIT BEFORE CUP ITS BLANKED
  call z,loadteapotiles;;;also loads empty ucup
   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 154;;
  call z,loadteapotilesWITHOUTCUP
   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 131;;;near left edge where HH walks for about 1 sec or less
  call z,redrawmenutextpart

    ld hl,HHTITLEACROSSPOS
  ld a,(hl)
    cp 133
  call z,redefineletterL

    ld hl,HHTITLEACROSSPOS
  ld a,(hl)
    cp 135
  call z,redefineARTword


  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 251
  call z,eraseletterLontitlescreen


  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 230
  call z,deleteARTwordintitle


   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 137
  call z,redefinechar

   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 139
  call z,quarterblankyellocanvasontitlescreenpictopleft

   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 141
  call z,quarterblankyellocanvasontitlescreenpicbottomright

  
  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 151
  call z,drawARTfulword;;

   ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 151-16
  call z,drawARTfulword;

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 251
  call z,drawARTfulword

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 155;;;near left edge hHH walk for about 1 sec or less
  call z,drawframonTITLESC



  ;;;the follwing coddtional jumps redraw part of the tile screen elemts very quickly 
  ;;;for special EDGE cases where menu elements need to be redrawn if needs be
  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 158;;;near left edge hHH walk for about 1 sec or less
  call z,redrawmenutextpart

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 129;;;
  call z,blankmiddletwolinesontitlescreensub

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 169;;
  call z,blankmiddletwolinesontitlescreensub

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 161
    call z,moveallspriteoffscreennotusedintitlescreen
  

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 165
  call z,blanktileblock

  ld hl,HHTITLEACROSSPOS
  ld a,(hl)
  cp 169
  call z,redefineaHOGmessage

  ret


redefineaHOGmessage:
    DefineTheTiles Ahumangame,Ahumangameend-Ahumangame,404
 ret

redefinechar:
   DefineTheTiles thefont,thefontend-thefont,288
   DefineTheTiles CRCchar,CRCcharend-CRCchar,290;as CRC as ?
   ret 


blanktileblock:
  DefineTheTiles Blank18tiles,Blank18tilesend-Blank18tiles,270
  ret


redefineletterL:
  DefineTheTiles Letterl,Letterlend-Letterl,16+32+180
  ret

redefineARTword:
   DefineTheTiles Artfutitle,Artfutitleend-Artfutitle,16+32
  ret


blankmiddletwolinesontitlescreensub:
  push bc
 ld b,29

looptodraw3lineheightblockiINmiddleofscreenforblanking:
  push bc
blankmiddletwolinesontitlescreen: 
     LD C,15
     ld h,3
     LD L,3
     ld d,1
     ld e,270-256 
      push ix
     call TilesToVRAM
     pop ix
 
 pop  bc
  djnz looptodraw3lineheightblockiINmiddleofscreenforblanking
       ld b,0
      LD C,15
     ld h,3
     LD L,3
     ld d,1
     ld e,270-256  
      push ix
     call TilesToVRAM
      POP IX

    call blankleftmostedgemostoflowerhalf
      ;rewdraw authorinfo as it was blanked out above
         writetext 10,16,authorinfo
   call showonlyhumangamnemessage
  pop bc
  ret

blankleftmostedgemostoflowerhalf:
         ld b,0
      LD C,15
     ld h,1
     LD L,9
     ld d,1
     ld e,270-256  
      push ix
     call TilesToVRAM

        pop ix
   ret


blankyellocanvasontitlescreenpic:;;for blanking the 14 by 14 block on title screen teapot image
  ld b,14
acrosslooptitlescreenpic:
      dec b
     ld iyl,b
     
  push iy
  push bc
  push de
  push hl
 ld b,13
blankTITLESCREENtpictureblankyellowtile:
 ld iyh,b 
  push bc
   ld b,IYL;;across value
   ld c,iyh
   push af
   ld a,b
   add a,16
   ld b,a
   pop af
   ld hl,VPOKETHIS
  ld a,403-256
  ld (hl),a
  call vpokeover255
  pop bc
 djnz blankTITLESCREENtpictureblankyellowtile
  pop hl
  pop de
  pop bc
   POP Iy
   ld a,b
   cp 0
   jp z,acrosslooptoexit
  jp acrosslooptitlescreenpic
acrosslooptoexit:
 
  ret


quarterblankyellocanvasontitlescreenpictopleft:
  ld b,7
acrosslooptitlescreenpic28329:
      dec b
     ld iyl,b
     
  push iy
  push bc
  push de
  push hl
 ld b,7;;;23 instrction per page
blankTITLESCREENtpictureblankyellowtileTLquarter:
 ld iyh,b;;;cant us b as it is used for across however we can use b for both bfor across and down used inner and outer and stack and iyh 
  push bc
   ld b,IYL;;across value
   ld c,iyh
   push af
   ld a,b
   add a,16
   ld b,a
   pop af
   ld hl,VPOKETHIS
  ld a,403-256
  ld (hl),a
  call vpokeover255
  pop bc
 djnz blankTITLESCREENtpictureblankyellowtileTLquarter
  pop hl
  pop de
  pop bc
   POP Iy
   ld a,b
   cp 0
   jp z,acrossloopexit7823
  jp acrosslooptitlescreenpic28329
acrossloopexit7823:
 
  ret

quarterblankyellocanvasontitlescreenpicbottomright:
  ld b,7
acrosslooptitlescreenpic84756:
      dec b
     ld iyl,b
     
  push iy
  push bc
  push de
  push hl
 ld b,6;;;23 instrction per page
blankTITLESCREENtpictureblankyellowtileBRquarter:
 ld iyh,b;;;cant use b as it is used for across however we can use b for both for across and down used inner and outer and stack and iyh 
  push bc
   ld b,IYL;;across value
   ld c,iyh
   push af
   ld a,b
   add a,23
   ld b,a

   ld a,c
   add a,7
   ld c,a
   pop af
   
   ld hl,VPOKETHIS
  ld a,403-256
  ld (hl),a
  
  call vpokeover255
  pop bc
 djnz blankTITLESCREENtpictureblankyellowtileBRquarter
  pop hl
  pop de
  pop bc
   POP Iy
   ld a,b
   cp 0
   jp z,acrossloopexit95723
  jp acrosslooptitlescreenpic84756
acrossloopexit95723:
 
  ret



drawARTfulword:
      LD B,0
     LD C,0
     ld h,12
     LD L,15
     ld d,0
     ld e,16+32;;
     call TilesToVRAM
    call drawfirstletterL
  ret


eraseletterLontitlescreen:
      LD B,14;;
     LD C,8
     ld h,2
     LD L,7
     ld d,1
     ld e,270-255;;
     call TilesToVRAM
      LD B,14;;
     LD C,0
     ld h,2
     LD L,7
     ld d,1
     ld e,270-255;;
     call TilesToVRAM
      LD B,14;;;
     LD C,3
     ld h,2
     LD L,7
     ld d,1
     ld e,270-255;;
     call TilesToVRAM
  ret
   



deleteARTwordintitle:
 ld b,6
djanzdeletteARTloopleTitlescreenersatitle:
  ld ixl,b
   push bc

     push ix
     LD B,ixl
     LD C,0
     ld h,2
     LD L,7
     ld d,1
     ld e,270-255;;; 
 	    dec b
     call TilesToVRAM
     pop ix
    push ix
      LD B,ixl
     LD C,7
     ld h,2
     LD L,7
     ld d,1
     ld e,270-255;; 
        dec b
     call TilesToVRAM
    pop ix
      LD B,ixl
     LD C,10
     ld h,2
     LD L,8
     ld d,1
     ld e,270-255;; 
         dec b
    call TilesToVRAM
  pop bc
  djnz djanzdeletteARTloopleTitlescreenersatitle
  ret




drawletterBOTTOMHALFonthetitlescreen:

   ld hl,HHTITLEVERTICALPOS
   ld a,(hl)
   sub 240
   jp nc,donotdrawLbottomhalfuntilmovedpenenough
     LD B,14
     LD C,8
     ld h,2
     LD L,7
     ld d,0
     ld e,244
     call TilesToVRAM
donotdrawLbottomhalfuntilmovedpenenough:
   ld hl,HHTITLEVERTICALPOS
   ld a,(hl)
   sub 240-64
   jp nc,drawcompleteletterL
     LD B,14
     LD C,0
     ld h,2
     LD L,15
     ld d,0
     ld e,228
     call TilesToVRAM
drawcompleteletterL:

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadalltilesrequiredbeforeevergame:
     DefineTheTiles Charsayin1char,Charsayin1charend-Charsayin1char,440;
    DefineTheTiles CharsPLin1char,CharsPLin1charend-CharsPLin1char,427;


   DefineTheTiles HHcursortiles,HHcursortilesend-HHcursortiles,9

 
  
    DefineTheTiles Twocharsnums,Twocharsnumsend-Twocharsnums,7


   DefineTheTiles menuTSarrow,menuTSarrowend-menuTSarrow,5
  
  DefineTheTiles Gridcrosspoint,Gridcrosspointend-Gridcrosspoint,14;;;
  
 
 
   DefineTheTiles thefont,thefontend-thefont,288

    DefineTheTiles Viewingpageimage2,Viewingpageimage2end-Viewingpageimage2,391
    DefineTheTiles Viewingpageimage3,Viewingpageimage3end-Viewingpageimage3,398
    DefineTheTiles Twocharsemiword,Twocharsemiwordend-Twocharsemiword,337;;;

   DefineTheTiles TwocharUPEQUDOWNEQU,TwocharUPEQUDOWNEQUend-TwocharUPEQUDOWNEQU,339;
     DefineTheTiles Threecharscoreword,Threecharscorewordend-Threecharscoreword,341;
   DefineTheTiles frame,frameend-frame,344;
 
   DefineTheTiles arrowspagedivider,arrowspagedividerend-arrowspagedivider,350;long red arrow divides screen  and Mergedrawprogram

 
  
 DefineTheTiles Keysbanner1,Keysbanner1end-Keysbanner1,354
   
 DefineTheTiles Keysbanner2,Keysbanner2end-Keysbanner2,405
  

  DefineTheTiles Keysbanner3,Keysbanner3end-Keysbanner3,428
   

    DefineTheTiles rightarrow,rightarrowend-rightarrow,439

   DefineTheTiles Keygridtoggle,Keygridtoggleend-Keygridtoggle,376


  DefineTheTiles Viewingpageimage1,Viewingpageimage1end-Viewingpageimage1,441
      ret
 
restoremenupointerifneedsbe:
   push af
   push hl
   push de
   push bc
      push hl
   ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
  cp MENUCREDITS
  call z,movemenupointertocredits

   push hl
   ld hl,MENUCOUNTERCHOICEASROUNDEDINTEGER
   ld a,(hl)
   pop hl
   cp MENUINSTRUCTIONHWOTOPLAY
   call z,movemenupointertoinstructions

   pop bc
   pop de
   pop hl
   pop af
  ret

movemenupointertoinstructions:
 ld a,2
  call movemenupointer
  ret
  
movemenupointertocredits:
   ld a,5
  call movemenupointer
  ret

moveallspriteoffscreennotusedintitlescreen:
 ld b,38; this subroutine moves all the other sprites off screen not used in title screen
clearingloop86497:
  push bc
   ld a,b
      push bc
   ld b,255
   ld c,200
  call moveHHcursor16by16sprite
       pop bc
  pop bc
 ld a,b
  cp 63
  jp z,exithisclearingloop72553

   inc b
 jp clearingloop86497
exithisclearingloop72553:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ld b,0; 
clearingloop15312:
  push bc
   ld a,b;
       push bc
   ld b,255
   ld c,200
  call moveHHcursor16by16sprite
        pop bc
   pop bc
 ld a,b;
  cp 2
  jp z,exithisclearingloop08725
   inc b
 jp clearingloop15312
 

exithisclearingloop08725:
     
        ld b,192
     ld c,62; 
     ld de,&0000  ; 
     ld e,3  ;; 
     ld h,0  
     ld a,63  
     call SetupSprite
     ret





 org &7FF0;;;;near to 8000 which is 32 to 48K
 align 14;;;put it at atrt of 48K boundary
;;;;it is in the 32-48k ardes
 ;;;% is new line

;;;;  divide  by 2 (number in from of artfullimagemsg) to get hatrdware poage adress
artworkanswers:
  ;;;the first letter is  not part of the answer to guess -it gives the type of clue shown 
  ;;; for the 1st letter i=idiom or proverb , o = object,  p=person,   ,  f=food related
  ;;; add the answers for the new artfullimage, as 31 character answer starting with code letter above and ending in 255
  ;;; th proram does not use the label to address a specific answer instead it
  ;;uses the value of BASEADartfullimagemsg3 and adds a mutiple of 32 to it
BASEADartfullimagemsg3:db 'pABRAHAM LINCOLN%              ',255;;;for image 3a 
artfullimagemsg4:      db 'iSUNSCREEN%                    ',255;;;for image 3b
artfullimagemsg5:      db 'iBOX CLEVER%                   ',255;;;for image 4a
artfullimagemsg6:      db 'oBIRD CAGE%                    ',255;;;for image 4b 
artfullimagemsg7:      db 'oBIRDBOX%                      ',255;;;for image 5a
artfullimagemsg8:      db 'iKICK THE BUCKET%              ',255;;;for image 5b
artfullimagemsg9:      db 'iOVER THE MOON%                ',255;;;for image 6a
artfullimagemsg10:     db 'fLEMON CAKE%                   ',255;;;for image 6b
artfullimagemsg11:     db 'pPABLO PICASSO%                ',255;;;for image 7a
artfullimagemsg12:     db 'cBIGFOOT%                      ',255;;;for image 7b
artfullimagemsg13:     db 'CSTICK INSECT%                 ',255;;;for image 8a
artfullimagemsg14:     db 'iLET THE CAT OUT OF THE BAG%   ',255;;;for image 8b
artfullimagemsg15:     db 'iNOT USED IN GAME%             ',255;;;not used;;used for expanding for adding  in more pics

;;space for 100 more 
;;if extending the names moves the title to somewhere else as above
;;;works by addin to base address
;;;move everything below this page to a new page  if need the space     


Artfutitle:;;just contains ARTFU no letter L
      incbin "E:\Artfullgraphics\ARTFUL96BY120.GRA"; 
Artfutitleend:

Letterl:
      incbin "E:\Artfullgraphics\ARTFULLETTERL.GRA"; 
Letterlend:

HHframe1:;;frame one of HH animeted on title screen
      incbin "E:\Artfullgraphics\HHFRAME1TITLE.GRA"; 
HHframe1end:

HHframe2:
      incbin "E:\Artfullgraphics\HHFRAME2TITLE.GRA"; 
HHframe2end:


HHframe3:
      incbin "E:\Artfullgraphics\HHFRAME3TITLE.GRA"; 
HHframe3end:


Teapottitle:
      incbin "E:\Artfullgraphics\TEAPOT56BY56.GRA"; 
Teapottitleend:

Teainair:;
      incbin "E:\Artfullgraphics\MAKEINTOFLOWINGTEA.GRA"; 
Teainairend:

Emptycup:;;
      incbin "E:\Artfullgraphics\EMPTYCUP32BY24.GRA"; 
Emptycupend:

Fullcup:;;
      incbin "E:\Artfullgraphics\FULLCUP32BY24.GRA"; 
Fullcupend:


Blank18tiles:;
    incbin "E:\Artfullgraphics\BLANK18TILESACROSS.GRA"; 
Blank18tilesend:

 
  

   
 
 	org &7FF0;;;in the middle not end;;;;;;;;;;;;;;;;;;
	db "TMR SEGA"	;
	db 0,0			;
	db &69,&69		;
					;
	db 0,0,0 		;
		db &4C	

;;name coding is 3-3A  4-3B  5-4A  6-4B    7-5A  8-5B  in names below so 3A,3B fit exactly in one page in slot 2,4A,4B fit exactly in one page in slot 2,,,and so on
  org &BFF0
   
 align 14
 ;;;this is the 48 to 64k border BF00 = C000 -48K
artfullimage3A:
      incbin "E:\Artfullgraphics\MOUNTRUSHMORE.GRA"; 
artfullimage3Aend:
artfullimage3B:;;;
      incbin "E:\Artfullgraphics\SUNSCREEN.GRA"; 
artfullimage3Bend:
artfullimage4A:;;;
      incbin "E:\Artfullgraphics\ALBERTE.GRA"; 
artfullimage4Aend:
artfullimage4B 
      incbin "E:\Artfullgraphics\BIRDCAGE.GRA"; 
artfullimage4Bend:
artfullimage5A:;;;
      incbin "E:\Artfullgraphics\BIRDBOX.GRA"; 
artfullimage5Aend:
artfullimage5B:;
      incbin "E:\Artfullgraphics\KICKTHEBUCKET.GRA"; 
artfullimage5Bend:
artfullimage6A:;;
      incbin "E:\Artfullgraphics\OVERTHEMOON.GRA"; 
artfullimage6Aend:
artfullimage6B;;;
      incbin "E:\Artfullgraphics\LEMONCAKE.GRA"; 
artfullimage6Bend:
artfullimage7A:;;;
      incbin "E:\Artfullgraphics\PICASSO.GRA"; 
artfullimage7Aend:
artfullimage7B:;;
      incbin "E:\Artfullgraphics\BIGFOOT.GRA"; 
artfullimage7Bend:
artfullimage8A:;;;
      incbin "E:\Artfullgraphics\NOIMAGE.GRA"
artfullimage8Aend:
artfullimage8B:;;
      incbin "E:\Artfullgraphics\CATOUTOFBAG.GRA"; 
artfullimage8Bend:



