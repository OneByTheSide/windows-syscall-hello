
;WARNING: HARDCODED SSN NUMBER
;WARNING: MANUAL STRUCT ADDRESS ALIGNMENT TO 8
global main
%define NT_SUCCESS 0
extern printf
extern NtOpenFile
extern NtQueryInformationFile
section .text
main:
;.\fifinal.asm:41: error: label `_main.NtwriteFile_error' changed during code generation (offset 0xad -> 0xab) [-w+error=label-redef-late]
;.\fifinal.asm:46: error: label `_main.NtOpenFile_error' changed during code generation (offset 0xb3 -> 0xb1) [-w+error=label-redef-late]
;https://hammertux.github.io/win-syscall-re
;https://www.ired.team/miscellaneous-reversing-forensics/windows-kernel-internals/windows-x64-calling-convention-stack-frame
%define capac 80
%if 0
SHAREACCESS: 3
MASK:C0100000
OPEN OPTIONS: 80
8 32 8*2
funcall 5th arg rsp+0x20
syscall 5th arg rsp+0x28
syscall stack arg starts at offset 40
%endif
	push rbp
	mov rbp, rsp
	sub rsp, capac	;8 32 works 40 + 36
	mov rcx, handle
	mov rdx, 0xC0100000; access mask: GENERIC_READ | GENERIC_WRITE | SYNCHRONIZE
	mov r8, objatr
	mov r9, iostate
	mov DWORD[rsp + 0x28], 3;share access FILE_SHARE_READ | FILE_SHARE_WRITE
	mov DWORD[rsp + 0x30], 0x50;open options
;	call NtOpenFile
	mov r10, rcx
	mov rax, 0x0033
	syscall
	cmp rax, NT_SUCCESS
	jne .NtOpenFile_error
%if 0
	mov rcx, QWORD[rel handle]
	mov rdx, iostate
	mov r8, mode
	mov r9, 4
	mov DWORD[rsp + 0x20], 16
	call NtQueryInformationFile
	cmp rax, 0
	jne .NtOpenFile_error
	mov rcx, what
	xor rdx, rdx
	mov edx, DWORD[rel mode]
	call printf
%endif

	mov r10, QWORD[rel handle]
	mov rdx, 0
	mov r8, 0
	mov r9, 0
	lea r11, [rel iostate]
	mov QWORD[rsp + 0x28], r11;36-8   40
	lea r11, [rel hello]
	mov QWORD[rsp + 0x30], r11;28-8   48
	mov DWORD[rsp + 0x38], 13;20-4    56
	mov QWORD[rsp + 0x40], 0 ;16-8    64
	mov QWORD[rsp + 0x48], 0 ;        72
	mov rax, 0x8
	syscall
	cmp rax, NT_SUCCESS
	jne .NtWriteFile_error

	mov r10, QWORD[rel handle] ;important
	mov rax, 0x000f
	syscall

	add rsp, capac
	pop rbp
	ret
.NtWriteFile_error:
	add rsp, capac
	pop rbp
	ret

.NtOpenFile_error:
	add rsp, capac ;forgot to change here
	pop rbp
	ret

%if 0
  [in]           HANDLE           FileHandle,
  [in, optional] HANDLE           Event,
  [in, optional] PIO_APC_ROUTINE  ApcRoutine,
  [in, optional] PVOID            ApcContext,
  [out]          PIO_STATUS_BLOCK IoStatusBlock,
  [in]           PVOID            Buffer,
  [in]           ULONG            Length,
  [in, optional] PLARGE_INTEGER   ByteOffset,
  [in, optional] PULONG           Key
8 8 4 8 8
%endif
;stack preparation
;put args in reg
;put args in stack
;open conout$
;write to conout$
;close conout$
;mov rax, NS
;syscall
;clean stack
;error handling
;struct padding
;alignment to 8
section .data
name: dw __?utf16?__('\GLOBAL??\CONOUT$');34
times 6 db 0;pad to 40
bte:
	.high dd 0
	.low dd 0
	.qad dq 0
unistr:
	.objlen: dw 34	;2
	.objmaxlen: dw 36 ;4
	.pad: dd 0		;8
	.name: dq name;16
;56
objatr:
	.length: dd 48 ;4
	.pad1: dd 0;8
	.root: dq 0 ;16
	.ptrstr: dq unistr;24
	.attr: dd 0 ;28
	.pad2: dd 0 ;32
	.sd: dq 0	;40
	.sqos: dq 0	;48
;104
info: dd 0		;;108
iostate:		;;124
	.status: dq 0
	.info: dq info
;mode: dd 0

handle: dq 0
hello:db "Hello World!",10
;what: db "MODE:0x%x",10
;hellolen equ $ - hello
