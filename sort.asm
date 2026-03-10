section .data
    ; Массив для сортировки (8-байтные целые числа - dq)
    array:      dq 5, 2, 9, 1, 5, 6, 8, 3, 7, 4
    size:       dq 10                 ; Количество элементов
    sort_order: dq 2                  ; 1 = Ascending, 2 = Descending

section .text
global _start

_start:
    push rbp
    mov rbp, rsp

    mov r12, [size]           ; R12 = size
    lea r13, [array]          ; R13 = base address of array
    mov r11, [sort_order]     ; R11 = sort_order (1=asc, 2=desc)


    cmp r12, 1
    jle sort_done


    cmp r11, 2
    je DISORT_INIT


AISORT_INIT:
    mov rax, [r13]            ; array[0]
    mov rbx, [r13 + 8]        ; array[1]
    cmp rax, rbx
    jle AIS_first_pair_sorted
    xchg rax, rbx
    mov [r13], rax
    mov [r13 + 8], rbx
AIS_first_pair_sorted:

    mov r14, 2                ; R14 = i
AIS_outer_loop:
    cmp r14, r12
    jge AIS_sort_done

    mov r15, r14
    inc r15                   ; r15 = i + 1
    cmp r15, r12
    jge AIS_single_element

    ; --- Загружаем пару ---
    mov rax, [r13 + r14*8]    ; first = array[i]
    mov rbx, [r13 + r15*8]    ; second = array[i+1]


    cmp rax, rbx
    jle AIS_pair_ordered
    xchg rax, rbx
AIS_pair_ordered:

    mov rcx, r14
    dec rcx                   ; j = i - 1

AIS_insert_smaller:
    cmp rcx, -1
    jle AIS_insert_smaller_done

    mov rdx, [r13 + rcx*8]
    cmp rdx, rax
    jle AIS_insert_smaller_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp AIS_insert_smaller

AIS_insert_smaller_done:
    mov [r13 + (rcx+1)*8], rax

    mov rcx, r14

AIS_insert_larger:
    cmp rcx, -1
    jle AIS_insert_larger_done

    mov rdx, [r13 + rcx*8]
    cmp rdx, rbx
    jle AIS_insert_larger_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp AIS_insert_larger

AIS_insert_larger_done:
    mov [r13 + (rcx+1)*8], rbx

    add r14, 2
    jmp AIS_outer_loop

AIS_single_element:
    mov rax, [r13 + r14*8]
    mov rcx, r14
    dec rcx

AIS_insert_single:
    cmp rcx, -1
    jle AIS_insert_single_done 

    mov rdx, [r13 + rcx*8]
    cmp rdx, rax
    jle AIS_insert_single_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp AIS_insert_single

AIS_insert_single_done:
    mov [r13 + (rcx+1)*8], rax
    jmp AIS_sort_done

AIS_sort_done:
    jmp sort_done


DISORT_INIT:
    mov rax, [r13]            ; array[0]
    mov rbx, [r13 + 8]        ; array[1]
    cmp rax, rbx
    jge DIS_first_pair_sorted
    xchg rax, rbx
    mov [r13], rax
    mov [r13 + 8], rbx
DIS_first_pair_sorted:

    mov r14, 2                ; R14 = i

DIS_outer_loop:
    cmp r14, r12
    jge DIS_sort_done

    mov r15, r14
    inc r15
    cmp r15, r12
    jge DIS_single_element

    mov rax, [r13 + r14*8]
    mov rbx, [r13 + r15*8]

    cmp rax, rbx
    jge DIS_pair_ordered
    xchg rax, rbx
DIS_pair_ordered:

    mov rcx, r14
    dec rcx

DIS_insert_first:
    cmp rcx, -1
    jle DIS_insert_first_done

    mov rdx, [r13 + rcx*8]
    cmp rdx, rax
    jge DIS_insert_first_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp DIS_insert_first

DIS_insert_first_done:
    mov [r13 + (rcx+1)*8], rax

    mov rcx, r14

DIS_insert_second:
    cmp rcx, -1
    jle DIS_insert_second_done

    mov rdx, [r13 + rcx*8]
    cmp rdx, rbx
    jge DIS_insert_second_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp DIS_insert_second

DIS_insert_second_done:
    mov [r13 + (rcx+1)*8], rbx

    add r14, 2
    jmp DIS_outer_loop

DIS_single_element:
    mov rax, [r13 + r14*8]
    mov rcx, r14
    dec rcx

DIS_insert_single:
    cmp rcx, -1
    jle DIS_insert_single_done

    mov rdx, [r13 + rcx*8]
    cmp rdx, rax
    jge DIS_insert_single_done

    mov [r13 + (rcx+1)*8], rdx
    dec rcx
    jmp DIS_insert_single

DIS_insert_single_done:
    mov [r13 + (rcx+1)*8], rax

DIS_sort_done:
    jmp sort_done


sort_done:

    mov rax, 60
    xor rdi, rdi
    syscall

