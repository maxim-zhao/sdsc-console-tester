.memorymap
slotsize $4000
slot 0 $0000
slot 1 $4000
slot 2 $8000
defaultslot 2
.endme

.rombankmap
bankstotal 1
banksize $4000
banks 1
.endro

.sdsctag 0.1, "SDSC Console Tester", "", "Maxim"

.define SDSC_OUTPORT_DEBUGCONSOLE_COMMAND $FC
.define SDSC_OUTPORT_DEBUGCONSOLE_DATA    $FD

.define SDSC_DEBUGCONSOLE_COMMAND_SUSPENDEMULATION $01
.define SDSC_DEBUGCONSOLE_COMMAND_CLEARSCREEN      $02
.define SDSC_DEBUGCONSOLE_COMMAND_SETATTRIBUTE     $03
.define SDSC_DEBUGCONSOLE_COMMAND_MOVECURSOR       $04

.org 0
  jp Start
  
.org $39
  reti
  
.org $66
  retn
  
.macro Print args string
  jr +
-:
.db string
.if NARGS >= 2
.db \2
.endif
.if NARGS >= 3
.db \3
.endif
.db 10
.db 0
+:ld hl, -
  call OutputString
.endm

.macro SendControl args value
  ld a, value
  out (SDSC_OUTPORT_DEBUGCONSOLE_COMMAND), a
.endm

.macro SendByte args value
  ld a, value
  out (SDSC_OUTPORT_DEBUGCONSOLE_DATA), a
.endm

.macro SendWord args value
  ld a, >value
  out (SDSC_OUTPORT_DEBUGCONSOLE_DATA), a
  ld a, <value
  out (SDSC_OUTPORT_DEBUGCONSOLE_DATA), a
.endm
  
Start:
  ; Disable joystick ports.  This enables ports in region $C0 through $FF
  ; allowing Debug Console ports at $FC and $FD to be visible.
  ld a, ($c000)
  or %00000100
  out ($3e), a

  Print "SDSC Console Tester"
  /*
  Print "Part 1: commands"
  Print "Control command 1: suspend emulation"
  SendControl 1
  Print "Control command 2: clear console"
  SendControl 2
  Print "Control command 3: set attribute to light red on dark green"
  SendControl 3
  SendControl $2c
  Print "Control command 3: set attribute to white on black"
  SendControl 3
  SendControl $0f
  Print "Control command 4: move cursor to row 8, column 2"
  SendControl 4
  SendControl 8
  SendControl 2
  Print "Control command 4: move cursor to 9,1 using wrapping"
  SendControl 4
  SendControl 9 + 25*3
  SendControl 1 + 80*2
  Print "Control command 5: not a valid command"
  SendControl 5
  Print ""
*/
  Print "Part 2: messages"
  Print "We've already been printing bare strings. Now for some formatting..."
  ld b, -3
  Print "Register B as signed decimal, using index (expect -3): %dpr", $0
  ld c, 127
  Print "Register C as unsigned decimal, using index (expect 127): %upr", $1
  Print "Register BC as signed decimal, using char name (expect -641): %dprB"
  Print "Register BC as unsigned decimal, using index (expect 64895): %upr", $c
  ld d, $5a
  Print "Register D as lowercase hex, using char name (expect 5a): %xprd"
  ld e, $a5
  Print "Register E as uppercase hex, using index (expect A5): %Xpr", $3
  Print "Register DE as binary, using index (expect 101101010100101): %bpr", $d
  Print "Register DE as signed decimal, using char name, width 8 (expect    23205): %8dprD"
  Print "Register DE as unsigned decimal, using index, width 4 (expect 3205): %4upr", $d
  exx
  ld de,$f00d
  ld bc,$12ab
  exx
  Print "Register DE' as hex, using index, width 8 (expect 0000f00d): %8xpr", $13
  Print "Register BC' as binary, using index, width 16 (expect 0001001010101011): %16bpr", $12
  Print "Invalid register index: %dpr", $20
  /*
  Print "Register dump by letter:"
  Print "A %2xpra"
  Print "F %2xprf"
  Print "B %2xprb"
  Print "C %2xprc"
  Print "D %2xprd"
  Print "E %2xpre"
  Print "H %2xprh"
  Print "L %2xprl"
  Print "AF %4xprA"
  Print "BC %4xprB"
  Print "DE %4xprD"
  Print "HL %4xprH"
  Print "IX %4xprx"
  Print "IY %4xpry"
  Print "SP %4xprs"
  Print "R %2xprr"
  Print "i %2xpri"
  Print "Register dump by index:"
  Print "B %2xpr", $0
  Print "C %2xpr", $1
  Print "D %2xpr", $2
  Print "E %2xpr", $3
  Print "H %2xpr", $4
  Print "L %2xpr", $5
  Print "F %2xpr", $6
  Print "A %2xpr", $7
  Print "PC %4xpr", $8
  Print "SP %4xpr", $9
  Print "IX %4xpr", $a
  Print "IY %4xpr", $b
  Print "BC %4xpr", $c
  Print "DE %4xpr", $d
  Print "HL %4xpr", $e
  Print "AF %4xpr", $f
  Print "R %2xpr", $10
  Print "I %2xpr", $11
  Print "AF' %4xpr", $12
  Print "BC' %4xpr", $13
  Print "DE' %4xpr", $14
  Print "HL' %4xpr", $15
  */
  Print ""
  Print "String printing"
  Print "The string says: %smb", <NullTerminatedString, >NullTerminatedString
  Print "Truncated width: %8smb", <NullTerminatedString, >NullTerminatedString
  Print "Padded width: %16smb", <NullTerminatedString, >NullTerminatedString
  ; We copy it to VRAM
.define VDP_ADDRESS $bf
.define VDP_DATA $be
.define VDP_REGISTER $bf
  ld a, 0
  out (VDP_ADDRESS), a
  ld a, $50
  out (VDP_ADDRESS), a
  ld hl, NullTerminatedStringForVRAM
  ld c, VDP_DATA
  ld b, 23
  otir
  Print "The string in VRAM (using wrapped address) says: %svb", 0, $d0
  Print "The fifth character is %amb", <(NullTerminatedString + 4), >(NullTerminatedString + 4)
  Print ""
  Print "Data sources"
  ; RAM
  ld hl, $55aa
  ld ($c001),hl
  ; VRAM
  ld a, 0
  out (VDP_ADDRESS), a
  ld a, $40
  out (VDP_ADDRESS), a
  ld a, $76
  out (VDP_DATA), a
  ld a, $fe
  out (VDP_DATA), a
  ; PRAM
  ld a, 0
  out (VDP_ADDRESS), a
  ld a, $c0
  out (VDP_ADDRESS), a
  ld a, $54
  out (VDP_DATA), a
  ld a, $dc
  out (VDP_DATA), a
  ; VDP register
  ld a, $32
  out (VDP_REGISTER), a
  ld a, $88
  out (VDP_REGISTER), a
  
  Print "ROM word (expect 6548): %xmw", <NullTerminatedString, >NullTerminatedString ; Note: little-endian interpretation so it's "eH"
  Print "RAM word (expect 55aa): %xmw", $01, $c0
  Print "VRAM word (expect fe76): %xvw", $00, $00
  Print "ROM byte (expect 48): %xmb", <NullTerminatedString, >NullTerminatedString
  Print "RAM byte (expect aa): %xmb", $01, $c0
  Print "PRAM byte (expect 54): %xvr", $10
  Print "VDP register (expect 32): %xvr", $08
  

-:jr -

NullTerminatedString:
.db "Hello world!",0

NullTerminatedStringForVRAM:
.db "Hello world from VRAM!",0

OutputString:
-:ld a, (hl)
  out (SDSC_OUTPORT_DEBUGCONSOLE_DATA), a
  inc hl
  cp 10
  jr nz,-
  ; We terminate only if it's a line break followed by a null
  ld a,(hl)
  or a
  ret z
  jr -
