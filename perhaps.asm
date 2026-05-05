;SUCCESS BOY
global main
section .text
%define u(x) __?utf16?__(x)
main:
	push rbp
	mov rbp, rsp
	sub rsp, 40

	mov rcx, handle
	mov rdx, 0x80000000
	mov r8, objatr
	mov r9, iostate
	mov DWORD[rsp + 8], 40
	mov DWORD[rsp + 4], 0
	mov rax, 0x0033
	syscall
	add rsp, 40
	pop rbp
	cmp rax, NT_SUCCESS
	jl .err
	cmp [rel handle], 0
	je .ok
	jmp .err
.err:
	mov rax, 1
	ret
.ok:
	mov rax, 0
	ret
section .data
NT_SUCCESS equ 0
handle: dq 0 

%if 0
  [out] PHANDLE            FileHandle,       8
  [in]  ACCESS_MASK        DesiredAccess,    4
  [in]  POBJECT_ATTRIBUTES ObjectAttributes, 8
  [out] PIO_STATUS_BLOCK   IoStatusBlock,  16 bytes
  [in]  ULONG              ShareAccess,
  [in]  ULONG              OpenOptions UNICODE 16 bytes
%endif
mask: dd 1
;0x80000000
;0x7ffff800
objatr:
	.length:  ;4
	.root: dq 0 ;12
	.objlen: dw 38	;14
	.objmaxlen: equ 40 ;16
	.name: dw u("\\??\\C:\\asm\\fuck.asm");28
	.resv: dd 0
	.attr: dd 0 ;32
	.sd: dq 0	;40
	.sqos: dq 0	;48
%if 0
  ULONG           Length;
  HANDLE          RootDirectory;
  PUNICODE_STRING ObjectName;
  ULONG           Attributes;
  PVOID           SecurityDescriptor;
  PVOID           SecurityQualityOfService;

  union {
    NTSTATUS Status;
    PVOID    Pointer;
  };
  ULONG_PTR Information;
rcx/xmm0, rdx/xmm1, r8/xmm2, r9/xmm3
%endif
iostate:
	.state: dd 0
	.info: dq 0
	.resv: dd 0
share: dd 0
option: dd 0x40
