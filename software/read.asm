#include <xc.inc>

GLOBAL _bit_count

; This entire handler takes 16 cycles to execute.
PSECT intentry,class=CODE,reloc=2,delta=2
    BANKSEL PORTA
    movf PORTA, w         ; Sample PORTA. Bit 5 is the input.
    decfsz _bit_count, f  ; Decrement bit count. If zero, we're in echo mode.
    bra read_mode

    ; echo mode handling.
    bsf PORTA, 1          ; Generate rising edge (bit 1).
    lsrf WREG, w          ; Shift the input bit to the output position.
    nop
    movwf PORTA           ; We're setting all PORTA bits, but bit 4 is the only output.
    movlw 1               ; Increment bit count.
    addwf _bit_count
    clrf PORTA            ; Generate falling edge.

  cleanup:
    clrf TMR0             ; Clear the idle time counter.
    BANKSEL IOCAF         ; Clear the interrupt.
    clrf BANKMASK(IOCAF)
    retfie

    ; read mode handling.
  read_mode:
    movwi FSR0++          ; Save the bit into the color array.

    ; Save FSR0 to the shadow register.
    movf FSR0L, w
    BANKSEL FSR0L_SHAD
    movwf BANKMASK(FSR0L_SHAD)

    bra cleanup


