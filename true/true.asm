;
; Small, self-contained 32/64-bit ELF executable for NASM
; compile with nasm -f bin -DTRUE_ARCH=x86|amd64 -o true.bin
;
; Adapted from: http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html
;
; http://blog.markloiseau.com/2012/05/tiny-64-bit-elf-executables/

%ifndef TRUE_ARCH
    %fatal "Undefined value for TRUE_ARCH; alternatives: x86, amd64"
%endif
%ifidni TRUE_ARCH, x86
    %define TRUE_SIZE       32
    %define TRUE_EI_CLASS   1       ; e_ident       EI_CLASS    32-bit
    %define TRUE_E_MACHINE  0x03    ; e_machine                 x86
    %define DA              dd      ; 32-bit data
    %macro  TRUE_START 0
        ; sys_exit(return_code)
        ; In Linux >= 2.2, all registers are zero on program startup
        ; xor   eax, eax
        ; xor   edi, edi
        mov al, 0x01
        int 0x80
    %endmacro
%elifidni TRUE_ARCH, amd64
    %define TRUE_SIZE       64
    %define TRUE_EI_CLASS   2       ; e_ident       EI_CLASS    64-bit
    %define TRUE_E_MACHINE  0x3e    ; e_machine                 x86-64
    %define DA              dq      ; 64-bit data
    %macro  TRUE_START 0
        ; sys_exit(return_code)
        ; In Linux >= 2.2, all registers are zero on program startup
        ; xor   eax, eax
        ; xor   edi, edi
        mov al, 0x3c
        syscall
    %endmacro
%else
    %fatal "Unknown value for TRUE_ARCH; alternatives: x86, amd64"
%endif


BITS TRUE_SIZE
    org 0x00010000      ; Program load offset

; 32/64-bit ELF header
ehdr:
    db 0x7F, "ELF"      ; e_ident       EI_MAG          magic number
    db TRUE_EI_CLASS    ; e_ident       EI_CLASS
    db 1                ; e_ident       EI_DATA         little-endian
    db 1                ; e_ident       EI_VERSION      current ELF
    db 0                ; e_ident       EI_OSABI        System V
    db 0                ; e_ident       EI_ABIVERSION   unused in Linux 2.6+
    times 7 db 0        ; e_ident       EI_PAD          zero padding

    dw 2                ; e_type        ET_EXEC/Executable file
    dw TRUE_E_MACHINE   ; e_machine
    dd 1                ; e_version     current version
    DA _start           ; e_entry       program entry address
    DA phdr - $$        ; e_phoff       program header table offset
    DA 0                ; e_shoff       section header table offset (no section headers)
    dd 0                ; e_flags       flags (no flags)
    dw ehdrsize         ; e_ehsize      ELF header size (0x34)
    dw phdrsize         ; e_phentsize   program header table entry size
    dw 1                ; e_phnum       program header table entry count
    dw 0                ; e_shentsize   section header table entry size
    dw 0                ; e_shnum       section header table entry count
    dw 0                ; e_shstrndx    section header table name entry index

ehdrsize equ $ - ehdr


; 32/64-bit ELF program header
phdr:
    dd 1                ; p_type        PT_LOAD = loadable segment
%define P_FLAGS 5       ; p_flags       1/PF_X/execute | 4/PF_R/read
%if TRUE_EI_CLASS == 2
    dd P_FLAGS          ; p_flags       (position for 64-bit ELF format)
%endif
    DA 0                ; p_offset      offset of segment in file image
    DA $$               ; p_vaddr       virtual  address of the segment
    DA $$               ; p_paddr       physical address of the segment
    DA filesize         ; p_filesz      byte size of segment in file image
    DA filesize         ; p_memsz       byte size of segment in memory
%if TRUE_EI_CLASS == 1
    dd P_FLAGS          ; p_flags       (position for 32-bit ELF format)
%endif
    DA 0x001000         ; p_align       2^11=200000=11 bit boundaries

; program header size
phdrsize equ $ - phdr


; Minimal program returning 0
_start:
    TRUE_START

; File size calculation
filesize equ $ - $$
