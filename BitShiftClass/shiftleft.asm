; David Fritts corrected by Robert Rayment

[BITS 32]
push ebx

mov eax, dword [esp+0Ch] ; value
mov ecx, dword [esp+10h] ; shift

mov edx, dword [esp+14h] ; hresult

shl eax, cl

mov dword [edx], eax
xor eax, eax

pop ebx

ret 16  ; 10 orig?