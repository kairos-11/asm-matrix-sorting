section .data
    size    equ 4
    number  equ 2 * size - 1
    
    ; Matrix 4x4 (8-bit numbers)
    matrix  db 1, 10, 8, 9
            db 3, 5, 11, 12
            db 6, 16, 4, 14
            db 2, 7, 13, 15

    sort_order: db 2

    %ifndef SORT_ORDER
        %define SORT_ORDER 1
    %endif

section .bss
    buffer  resb size



section .text
    global _start

; %1 = jle/jge
; %2 = первый регистр
; %3 = второй регистр
%macro CMP_SWAP 3
    cmp %2, %3
    %1 %%skip_swap
    xchg %2, %3
%%skip_swap:
%endmacro

; %1 = jle/jge  
; %2 = элемент для вставки
; %3 = индекс
; %4 = базовый адрес массива
; %5 = метка завершения
%macro INSERT_ELEM 5
%%insert_loop:
    cmp %3, -1
    jle %5
    mov dl, [%4 + %3]
    cmp dl, %2
    %1 %5
    mov [%4 + (%3+1)], dl
    dec %3
    jmp %%insert_loop
%endmacro

_start:
    mov rsi, matrix             ; rsi = pointer to matrix
    xor rdi, rdi                ; rdi = i (diagonal index)

.diagonal_work:
    mov rax, rdi
    mov rbx, size
    dec rbx
    cmp rax, rbx
    jle .first_str
    sub rax, rbx
    mov rbx, rax
    jmp .find_j

.first_str:
    xor rbx, rbx
    
.find_j:
    mov rax, rdi
    sub rax, rbx                ; rax = rdi - rbx (column index)
    mov rcx, rax                ; rcx = column index
    
    mov r8, rdi
    mov r9, rbx
    mov r10, rcx
    xor rdx, rdx                ; rdx = buffer offset
    
.copy_diagonal:
    cmp rbx, size
    jge .end_copy
    cmp rcx, 0
    jl .end_copy
    
    mov rax, rbx
    imul rax, size
    jc err
    add rax, rcx
    jo err
    mov al, [rsi + rax]
    mov [buffer + rdx], al
    inc rdx

    inc rbx
    dec rcx
    jmp .copy_diagonal
    
.end_copy:
    mov r12, rdx
    cmp r12, 1
    jle sort_done
    lea r13, [buffer]
    mov r12, rdx
    jmp .sort_start

.sort_start:

    cmp r12, 1
    jle sort_done

    %if SORT_ORDER == 2
        jmp DISORT_INIT
    %else
        jmp AISORT_INIT
    %endif

AISORT_INIT:
    mov al, [r13]            ; array[0]
    mov bl, [r13 + 1]        ; array[1]
    CMP_SWAP jle, al, bl
    mov [r13], al
    mov [r13 + 1], bl

    mov r14, 2                ; R14 = i
AIS_outer_loop:
    cmp r14, r12
    jge AIS_sort_done

    mov r15, r14
    inc r15                   ; r15 = i + 1
    cmp r15, r12
    jge AIS_single_element

    mov al, [r13 + r14]    ; first = array[i]
    mov bl, [r13 + r15]    ; second = array[i+1]
    CMP_SWAP jle, al, bl

    mov rcx, r14
    dec rcx                   ; j = i - 1
    INSERT_ELEM jle, al, rcx, r13, AIS_insert_first_done

AIS_insert_first_done:
    mov [r13 + (rcx+1)], al

    mov rcx, r14
    INSERT_ELEM jle, bl, rcx, r13, AIS_insert_second_done

AIS_insert_second_done:
    mov [r13 + (rcx+1)], bl

    add r14, 2
    jmp AIS_outer_loop

AIS_single_element:
    mov al, [r13 + r14]
    mov rcx, r14
    dec rcx
    INSERT_ELEM jle, al, rcx, r13, AIS_insert_single_done
AIS_insert_single_done:
    mov [r13 + (rcx+1)], al
    jmp AIS_sort_done

AIS_sort_done:
    jmp sort_done

DISORT_INIT:
    mov al, [r13]            ; array[0]
    mov bl, [r13 + 1]        ; array[1]
    CMP_SWAP jge, al, bl
    mov [r13], al
    mov [r13 + 1], bl

    mov r14, 2                ; R14 = i
DIS_outer_loop:
    cmp r14, r12
    jge DIS_sort_done

    mov r15, r14
    inc r15
    cmp r15, r12
    jge DIS_single_element

    mov al, [r13 + r14]
    mov bl, [r13 + r15]
    CMP_SWAP jge, al, bl

    mov rcx, r14
    dec rcx
    INSERT_ELEM jge, al, rcx, r13, DIS_insert_first_done
DIS_insert_first_done:
    mov [r13 + (rcx+1)], al

    mov rcx, r14
    INSERT_ELEM jge, bl, rcx, r13, DIS_insert_second_done
DIS_insert_second_done:
    mov [r13 + (rcx+1)], bl

    add r14, 2
    jmp DIS_outer_loop

DIS_single_element:
    mov bl, [r13 + r14]
    mov rcx, r14
    dec rcx
    INSERT_ELEM jge, bl, rcx, r13, DIS_insert_single_done
DIS_insert_single_done:
    mov [r13 + (rcx+1)], bl
    jmp DIS_sort_done

DIS_sort_done:
    jmp sort_done

sort_done:
    mov rdi, r8
    mov rbx, r9
    mov rcx, r10
    xor rdx, rdx

update:
    cmp rdx, r12
    jge end_update
    cmp rbx, size
    jge end_update
    cmp rcx, 0
    jl end_update
    
    mov al, [buffer + rdx]
    
    mov r14, rbx
    imul r14, size
    jc err
    add r14, rcx
    jo err
    
    mov [rsi + r14], al
    
    inc rdx
    inc rbx
    dec rcx
    jmp update

end_update:
    inc rdi
    cmp rdi, number
    jl _start.diagonal_work
    jmp end

end:
    mov rax, 60
    xor rdi, rdi
    syscall

err:
    mov rax, 60
    mov rdi, 1
    syscall
