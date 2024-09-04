; Copyright (c) 2024 ozforester.
; Use of this source code is governed by a MIT license
;
; = another oled lab =
; 1. avr tiny13 uC (medium speed)
; 2. ssd1306 display (128x64)

#include <avr/io.h>
#undef  __SFR_OFFSET
#define __SFR_OFFSET 0
#define twi_port PORTB
#define twi_pin  PINB
#define twi_ddr  DDRB
#define scl PB3 /* oled twi clock */
#define sda PB4 /* oled twi data */

temp    = 16	; common reg
data    = 17	; twi reg
char    = 18	; ascii
memc    = 19	; mem counter
bytec   = 21	; bit counter
delay	= 23   	;

.section .text
.global main
main:				;
        ldi temp, RAMEND        ;
        out SPL, temp           ;
	rcall delay_10ms
        rcall ssd1306_init      ;
        rcall ssd1306_clear     ;
        loop:			;
 	rjmp loop		;
ret				;

; ------------ ssd1306 -------------

ssd1306_clear:			;
        ldi YL, lo8(1024)	; 32x128
        ldi YH, hi8(1024)	; max pixels
        rcall i2c_start         ;
        ldi data, (0x3c<<1)       ;
        rcall i2c_write         ;
        ldi data, 0x40          ; data continuous
        rcall i2c_write         ;
	clr1:			;
        ldi data, 0x55          ; <--- filler byte
        rcall i2c_write         ;
	subi YL, 1		;
	brne clr1
	tst YH
	breq ssd_m
	subi YH, 1
	ser YL
	rjmp clr1	; YH = 0
	ssd_m:
        rcall i2c_stop          ;
ret				;

ssd1306_init:		    	;
       ldi ZL, lo8(init_seq)  ;
        ldi ZH, hi8(init_seq)  ;
        lpm memc, Z             ; read block size
        adiw Z, 1               ;
        rcall i2c_start         ;
	ldi data, (0x3c<<1)
        rcall i2c_write         ;
        ldi data, 0x00          ; continuous command
        rcall i2c_write         ;
        ssd1:                   ;
        lpm data, Z             ; read byte
        rcall i2c_write         ;
        dec memc                ;
        breq ssd2               ;
        adiw Z, 1               ;
        rjmp ssd1               ; next
        ssd2:                   ;
        rcall i2c_stop          ;
ret				;

; ------- i2c ---------

.macro pulldown wire		;
	nop
        sbi twi_ddr, \wire	;
        cbi twi_port, \wire	;
	nop			;
.endm				;

.macro release wire		;
	nop
        cbi twi_ddr, \wire	;
        cbi twi_port, \wire	;
	nop
.endm				;

.macro latch
	nop			;
        release scl		;
        waitrelease scl		;
        nop			;
        pulldown scl		;
	nop			;
.endm				;

.macro waitrelease wire		;
	wf\@:			;
        sbis twi_pin, \wire	;
        rjmp wf\@		;
.endm				;

i2c_start:			; general start condition
        waitrelease sda         ;
        waitrelease scl		;
        pulldown sda		;
        pulldown scl		;
ret				;

i2c_stop:			; general stop condition
        pulldown sda            ;
        release scl		;
        waitrelease scl		;
        release sda		;
ret				;

i2c_write:			; send data byte from data reg
        ldi bytec, 8		;
	twn:			;
	sbrs data, 7		; msb
        rjmp msb_low		; not set
        release sda		; 1
        rjmp tws		;
	msb_low:		;
	pulldown sda		; 0
	tws:			;
	latch			;
        lsl data		; next shift
        dec bytec		;
        brne twn		; next bit
	latch			; ignore ack slot
ret				;

; -------- delays ----------

delay_10ms:			;not tuned yet
	ldi delay, 255		;
        d10m:			;
	push delay		;
	rcall delay_50us	; 50us
	pop delay			;
	dec delay			;
        brne d10m		;
ret				;

delay_50us:             ; not tuned
        ldi delay, 255	;
        d50u:		;
	dec delay		; 1
        brne d50u	; 1
ret
			;
; ---- forget about vect

init_seq:               ; oled init
.byte 16                ; even sequency size
.byte 0xda, 0b00010010  ; cfg 128x64
.byte 0x81, 0x01        ; leds current down
.byte 0x8d, 0x14        ; charge pump enable
.byte 0xaf              ; display on
.byte 0x20, 0x01	; mode
.byte 0x21, 0, 127	; rows
.byte 0x22, 0, 7	; columns

.end
