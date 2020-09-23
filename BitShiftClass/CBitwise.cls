VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CBitwise"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

' From David Fritts (CodeId=45885)
' ASM corrected by Robert Rayment
' Class recast by Ulli

Private Declare Function GlobalAlloc Lib "kernel32" (ByVal wFlags As Long, ByVal dwBytes As Long) As Long
Private Declare Function GlobalLock Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Private Declare Function GlobalUnlock Lib "kernel32" (ByVal hMem As Long) As Long
Private Declare Function GlobalFree Lib "kernel32" (ByVal hMem As Long) As Long

Private Type tPD
    hMem                As Long
    PtrToOldCode        As Long
End Type
Private ProcDetails()   As tPD

Private VTIndex         As Long
Private Code            As Byte
Private CodeSize        As Long
Private PtrToNewCode    As Long
Private PtrToMyself     As Long
Private i               As Long

Private Sub Class_Initialize()

    VTIndex = -1 'initialize index into Virtual Table
    ShiftLeft 0, 0 'this sets up m/c code and modifies the VT
    ShiftRight 0, 0 'this sets up m/c code and modifies the VT
    RotateLeft 0, 0 'this sets up m/c code and modifies the VT

End Sub

Public Function ShiftLeft(ByVal Value As Long, ByVal Shift As Long) As Long

  'this is in fact only called once during class initialize
  'subsequent calls are diverted (via the VT) to the m/c code

    DivertTo "53 8B44240C 8B4C2410 8B542414 D3E0 8902 31C0 5B C21000"

End Function

Public Function ShiftRight(ByVal Value As Long, ByVal Shift As Long) As Long

  'this is in fact only called once during class initialize
  'subsequent calls are diverted (via the VT) to the m/c code

    DivertTo "53 8B44240C 8B4C2410 8B542414 D3E8 8902 31C0 5B C21000"

End Function

Public Function RotateLeft(ByVal Value As Long, ByVal Shift As Long) As Long

  'this is in fact only called once during class initialize
  'subsequent calls are diverted (via the VT) to the m/c code

    DivertTo "53 8B44240C 8B4C2410 8B542414 D3C0 8902 31C0 5B C21000"

End Function

Private Sub DivertTo(ByVal HexCode As String)

    VTIndex = VTIndex + 1 'inc index into VT
    ReDim Preserve ProcDetails(0 To VTIndex) 'adjust array size
    
    HexCode = Replace$(HexCode, " ", "") 'remove spaces from hex code
    CodeSize = Len(HexCode) / 2 'length of the resulting binary code (2 hex chars per byte of code)

    With ProcDetails(VTIndex)
        .hMem = GlobalAlloc(0, CodeSize) 'get memory for m/c code and save handle
        PtrToNewCode = GlobalLock(.hMem) 'get far pointer to allocated memory

        For i = 0 To CodeSize - 1
            Code = Val("&H" & Mid$(HexCode, i + i + 1, 2)) 'convert hex to binary m/c code
            CopyMemory ByVal PtrToNewCode + i, Code, 1 'store it in allocated memory
        Next i

        .PtrToOldCode = VirtualTableEntry 'save old VT entry; VTIndex determines which entry
        VirtualTableEntry = PtrToNewCode 'overwrite VT entry; VTIndex determines which entry
        GlobalUnlock .hMem 'unlock memory
    End With 'PROCDETAILS(VTINDEX)

End Sub

Private Property Let VirtualTableEntry(ByVal FarPointer As Long)

    CopyMemory PtrToMyself, ByVal ObjPtr(Me), 4 'get pointer to object (Me)
    CopyMemory ByVal PtrToMyself + &H1C + VTIndex * 4, FarPointer, 4 'put VT entry

End Property

Private Property Get VirtualTableEntry() As Long

    CopyMemory PtrToMyself, ByVal ObjPtr(Me), 4 'get pointer to object (Me)
    CopyMemory VirtualTableEntry, ByVal PtrToMyself + &H1C + VTIndex * 4, 4 'get VT entry

End Property

Private Sub Class_Terminate()

    For VTIndex = VTIndex To 0 Step -1 'VTIndex still points to the last VT entry overwritten
        With ProcDetails(VTIndex)
            VirtualTableEntry = .PtrToOldCode 'restore VT entry; VTIndex determines which entry
            GlobalFree .hMem 'release memory used for m/c code
        End With 'PROCDETAILS(VTINDEX)
    Next VTIndex

End Sub

':) Ulli's VB Code Formatter V2.16.11 (2003-Jun-03 10:21) 20 + 87 = 107 Lines
