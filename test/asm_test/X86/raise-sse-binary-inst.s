// REQUIRES: x86_64-linux
// RUN: clang -O0 -o %t %s
// RUN: llvm-mctoll -d -I /usr/include/stdio.h %t
// RUN: clang -o %t-dis %t-dis.ll
// RUN: %t-dis 2>&1 | FileCheck %s
// CHECK: 1.0
// CHECK: 1.0
// CHECK: 1.0
// CHECK: 1.5
// CHECK: 1.5
// CHECK: 1.5
// CHECK-EMPTY

.text
.intel_syntax noprefix
.file "raise-sse-binary-inst.s"

.p2align    4, 0x90
.type    test_pand,@function
test_pand:
    pand xmm0, xmm1
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.p2align    4, 0x90
.type    test_andps,@function
test_andps:
    andps xmm0, xmm1
    cvtss2sd xmm0, xmm0
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.p2align    4, 0x90
.type    test_andpd,@function
test_andpd:
    andpd xmm0, xmm1
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.p2align    4, 0x90
.type    test_por,@function
test_por:
    por xmm0, xmm1
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.p2align    4, 0x90
.type    test_orps,@function
test_orps:
    orps xmm0, xmm1
    cvtss2sd xmm0, xmm0
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.p2align    4, 0x90
.type    test_orpd,@function
test_orpd:
    orpd xmm0, xmm1
    mov al, 1
    mov rdi, offset .L.str
    call printf
    ret

.globl    main                    # -- Begin function main
.p2align    4, 0x90
.type    main,@function
main:                                   # @main
    movsd xmm0, [.L.val]
    movsd xmm1, [.L.val.4]
    call test_pand

    movsd xmm0, [.L.val]
    movsd xmm1, [.L.val.4]
    call test_andpd

    movss xmm0, [.L.val.2]
    movss xmm1, [.L.val.5]
    call test_andps

    movsd xmm0, [.L.val]
    movsd xmm1, [.L.val.1]
    call test_por

    movsd xmm0, [.L.val]
    movsd xmm1, [.L.val.1]
    call test_orpd

    movss xmm0, [.L.val.2]
    movss xmm1, [.L.val.3]
    call test_orps

    xor rax, rax
    ret

.type   .L.str,@object                  # @.str
.section        .rodata.str1.1,"aMS",@progbits,1
.L.str:
    .asciz  "%.1f\n"
    .size   .L.str, 6

.section    .rodata.cst8,"aM",@progbits,8
.L.val:
    .quad 0x3ff0000000000000 # double 1.0
.L.val.1:
    .quad 0x0008000000000000 # used to flip single bit in .L.val
.L.val.4:
    .quad 0xffffffffffffffff
.L.val.2:
    .long 0x3f800000 # float 1.0
.L.val.3:
    .long 0x400000 # used to flip single bit in .L.val.2
.L.val.5:
    .long 0xffffffff # used to flip single bit in .L.val.2
