start_offset        .equ    $8000
system_start        .equ    $8900
system_dimension    .equ    $5200

start:                      .org start_offset 
                            jmp load_system
load_system:                lxi h,0 
                            lxi b,system_dimension 
                            lxi d,system_start 
load_system_transfer:       mov a,b     
                            ora c 
                            jz 0
                            ldax d 
                            mov m,a 
                            dcx b 
                            inx h 
                            inx d 
                            jmp load_system_transfer