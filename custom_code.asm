;F783 - FEFF | 1398 bytes | bank 01

{
setup_pause_menu:
    ;backup hud
    !AX16
    ldx #$0200-2
-:
    lda.l _7F9000,X : sta.l $7FFE00,X
    lda.w #$01C5    : sta.l _7F9000,X
    dex #2 : bpl -

    jsr .draw_menu_text
    jsr .draw_menu_options
    lda.w ram.cursor_pos : and.w #$FF : xba : lsr #2 : tax
    lda.w #$21AB : sta.l _7F9000+$42,X
    !AX8
    inc.w layer3_needs_update
.ret:
    rts

;-----

.draw_menu_text:
    ldy.w #-1  ;string offset
    lda.w #$0000-$40 : sta.b $00 ;base drawing offset
..next_text:
    iny
    lda.b $00 : clc : adc #$0040 : sta.b $00 ;increment base drawing offset
    cmp.w #$40*4
    bcs ..done

    tax
    lda.w menu_name,Y : and.w #$FF
    cmp.w #$FF : beq ..done
    bra ..start_load

..load_next:
    lda.w menu_name,Y : and.w #$FF
    cmp.w #$FF : beq ..next_text

..start_load:
    ora.w #$2180 : sta.l _7F9000+$44,X
    inx #2
    iny
    bra ..load_next

..done:
    rts

;-----

.draw_menu_options:
    ;todo
    rts
}

{
run_custom_menu:
    lda.w p1_button_press+1
    beq .skip

    !AX16
    jsr .check_move_cursor
    !AX8
    jsr .check_toggle_option
    inc.w layer3_needs_update
.skip:
    rts

;-----

.check_move_cursor:
    lda.w ram.cursor_pos : and.w #$FF : xba : lsr #2 : tax
    lda #$01C5 : sta.l _7F9000+$42,X ;clear

    !A8
    lda.w p1_button_press+1
    bit #!up : beq +

    dec.w ram.cursor_pos
+:
    bit #!down : beq +

    inc.w ram.cursor_pos
+:
    lda.w ram.cursor_pos
    bpl +

    lda.b #2-1
+:
    cmp #2 : bcc +

    lda.b #0
+:
    sta.w ram.cursor_pos
    !A16
    and.w #$FF : xba : lsr #2 : tax
    lda #$21AB : sta.l _7F9000+$42,X ;add cursor to new pos
    rts

;-----

.check_toggle_option:
    ldx.w ram.cursor_pos
    lda.l extram.menu_idx,X : tay
    lda.w p1_button_press+1
    bit #!left : beq +

    dey
+:
    bit #!right : beq +

    iny
+:
    tya
    bpl +

    lda.w menu_count,X : dec
+:
    cmp.w menu_count,X : bcc +

    lda.b #0
+:
    sta.l extram.menu_idx,X
    rts
}

{
restore_pause_menu:
    lda.l extram.menu_idx+1 : asl : ora.l extram.menu_idx+0 : sta.w ram.flags
    !AX16
    jsr .set_pos
    jsr .set_rng

    ;restore hud
    ldx #$0200-2
-:
    lda.l $7FFE00,X : sta.l _7F9000,X
    dex #2 : bpl -
    !AX8
    inc.w layer3_needs_update
    rts

;-----

.set_pos:
    ;todo: set flags here
    lda.w #1
    bit.w ram.flags
    beq ..clear

    lda.w #$21A1 : sta.l $7FFE00+$92 ;'X'
    lda.w #$21A2 : sta.l $7FFE00+$D2 ;'Y'
    bra ..ret

..clear:
    lda.w #$01C5
    ;clear xpos from hud
    ldx.w #8 : phx
-:
    sta.l $7FFE00+$94-2,X
    dex #2 : bpl -

    ;clear ypos from hud
    plx ;8
-:
    sta.l $7FFE00+$D4-2,X
    dex #2 : bpl -
..ret:
    rts

;-----

.set_rng:
    ;todo: set flags here
    lda.w #3*2
    bit.w ram.flags
    bne ..set

    lda.w #$01C5
    ldx.w #6
-:
    sta.l $7FFE00+$A4,X
    dex #2 : bpl -
..set:
    rts
}

{
display_arthur_pos:
    !A16
    ldx.b #6
    lda.w !obj_arthur.pos_x
    bra +

-:
    lsr #4
+:
    pha
    and.w #$000F : ora.w #$2180 : sta.l _7F9000+$94,X
    pla
    dex #2
    bpl -

    ;copy paste for Y
    ldx.b #6
    lda.w !obj_arthur.pos_y
    bra +

-:
    lsr #4
+:
    pha
    and.w #$000F : ora.w #$2180 : sta.l _7F9000+$D4,X
    pla
    dex #2
    bpl -

    !A8
    inc.w layer3_needs_update
    rts
}

{
display_rng:
    bit.b #1*2
    !A16
    bne .state

    lda.w ram.rng_counter
    bra +

.state:
    lda.w rng_state
+:
    ldx.b #6
    ;lda.w rng_state
    bra +

-:
    lsr #4
+:
    pha
    and.w #$000F : ora.w #$2180 : sta.l _7F9000+$A4,X
    pla
    dex #2
    bpl -

    !A8
    inc.w layer3_needs_update
    rts
}
