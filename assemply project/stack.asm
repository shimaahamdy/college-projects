; Heap                        (Heap.asm)

INCLUDE Irvine32.inc

Node STRUCT     
;intalize node content (value,next pointer to next node)
content dd ?  ;value
next dd NULL  ;pointer
Node ends

.data
NODE_SIZE = 8   ;size of node
List_SIZE DD 0  ;linkedlist size
first dword NULL ;refer to first node
last dword NULL  ;refer to last node
hHeap   DWORD ?				; handle to the process heap
new_node_ptr  DWORD ?		; pointer to block of memory allocate 
str1 BYTE "Heap size is: ",0  
failmsg byte "Fail to allocate new node"
arrow byte "->"

.code
main PROC
	call create_heap
	mov eax, 17			;node data
	call push_item
	mov eax, 15			;node data
	call push_item
	mov eax, 14			;node data
	call push_item
	 call display_array

	call pop_item
	call pop_item

	call display_array
	call pop_item
	call pop_item


	
	
	; free the array
	
	
quit::
	exit
main ENDP
show_size proc
    mov edx,offset str1
    call writestring
	mov eax,list_SIZE
	call WriteDec
	call crlf

	ret
show_size endp
pop_item proc uses esi edi edx ecx
	mov ecx, List_SIZE
	jcxz go
	mov esi, first
	mov eax, (Node ptr [esi]).content
	mov edi, (Node ptr [esi]).next
	cmp edi, NULL
	jne cont
	mov last, NULL
	cont:
	INVOKE HeapFree, hHeap, 0, first
	mov first, edi
	dec Dword ptr List_SIZE			;increase the list size
	go:
	ret
pop_item endp

push_item proc uses esi edx
	call create_node				;create new node new Node(eax, edi)
	cmp List_SIZE, 0				;if (listSize == 0)
	jne cont						
	mov esi, new_node_ptr			;last = newNode
	mov last, esi					;
	cont:
	mov esi, new_node_ptr			;newNode.next = first
	mov edx, first					;
	mov (Node ptr [esi]).next, edx	;
	mov first, esi					;first = newNode
	inc Dword ptr List_SIZE			;increase the list size
	ret
push_item endp

create_node proc uses edx esi
	call allocate_new_node
	jnc	 allocation_success		; failed (CF = 1)?
	call WriteWindowsMsg
	call Crlf
	jmp	 fail
allocation_success:				; ok to fill the node
	call fill_node
	jmp sucessreturn
fail:
	mov edx, offset failmsg
	call writestring
sucessreturn:
	ret
create_node endp

create_heap proc
	INVOKE GetProcessHeap		; get handle to prog's heap
	.IF eax == NULL			; failed?
	call	WriteWindowsMsg
	jmp	quit
	.ELSE
	mov	hHeap,eax		; success
	.ENDIF
create_heap endp
;--------------------------------------------------------
allocate_new_node PROC USES eax
;
; Dynamically allocates space for the array.
; Receives: nothing
; Returns: CF = 0 if allocation succeeds.
;--------------------------------------------------------
	INVOKE HeapAlloc, hHeap, HEAP_ZERO_MEMORY, NODE_SIZE
	
	.IF eax == NULL
	   stc				; return with CF = 1
	.ELSE
	   mov  new_node_ptr,eax		; save the pointer
	   clc				; return with CF = 0
	.ENDIF

	ret
allocate_new_node ENDP

;--------------------------------------------------------
fill_node PROC USES ecx edx esi edi
	mov edi, NULL		;next node
; Fills all array positions with a single character.
; Receives: nothing
; Returns: nothing
;--------------------------------------------------------
	mov	ecx,NODE_SIZE			; loop counter
	mov	esi,new_node_ptr			; point to the array

	mov (Node ptr [esi]).content, eax
	mov (Node ptr [esi]).next, edi
	ret
fill_node ENDP

;--------------------------------------------------------
display_array PROC USES eax ebx ecx esi edx
;
; Displays the array
; Receives: nothing
; Returns: nothing
;--------------------------------------------------------
	mov	ecx, List_SIZE	; loop counter
	mov	esi, first		; point to the first
	
	mov edx, offset arrow
	jcxz go
L1:	mov	eax,[esi]		; get a node
	mov	ebx,TYPE Dword
	call WriteDec		; display it
	mov esi, (Node ptr [esi]).next
	call writestring
	loop L1
	call crlf
	go:

	ret
display_array ENDP

END main
