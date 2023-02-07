start_address       .equ $8000
stack_address       .equ $7fff
rst55_address       .equ $002c

timer_counter0      .equ %00000100
timer_counter1      .equ %00000101
timer_control       .equ %00000111
usart_data          .equ %00000000
usart_control       .equ %00000001
serial_clock_divide .equ 8
timer_counter0_byte .equ %00010110      ;select counter 0 - lsb only - mode 3 - binary count
usart_set_byte      .equ %01001101      ; 1 bit stop - no party - 8 bit lenght - divide by x1

begin:  .org start_address
        jmp start

start:  di
        lxi sp, stack_address
        call device_setup 
        lxi h,test_string
        call string_out 
loop:   call char_in
        call char_out
        jmp loop

device_setup:   push psw 
                push h
                mvi a,timer_counter0_byte
                out timer_control 
                mvi a,serial_clock_divide
                out timer_counter0
				mvi a,0		
				out usart_control		
				out usart_control
				out usart_control
				mvi a,$40
				out usart_control
				mvi a,usart_set_byte
				out usart_control
				mvi a,$37
				out usart_control
				in usart_data
                mvi a,%00011101
                sim
                mvi a,$C3
                sta rst55_address 
                lxi h,char_in_int
                shld rst55_address+1
                pop h
                pop psw 
                ret 

string_out:		push psw		
				push b
string_out_1:	mov a,m			
				cpi 00
				jz string_out_2
				mov c,m
				call char_out
				inx h
				jmp string_out_1
string_out_2:	pop b
				pop psw
				ret

char_out: 	    push psw 
char_out_ver:   in usart_control
                ani %00000001 
                jz char_out_ver 
                pop psw
                out usart_data
    			ret

char_in:		in usart_control
                ani %00000010
                jz char_in
char_in_int:    in usart_data
    			ret

test_string     .text "if you read this message then the PX1 miniboard works :)"
                .b $0a,$0d,0