VERSION 5.00
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00FFFFFF&
   Caption         =   "Bit shifting VB v CLASS"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   ForeColor       =   &H00000000&
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   2  'CenterScreen
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

' Best to compile to show maximum speed diffeence

Private BitS As CBitwise

Private tmHowLong As New CTimingPC

Private Sub Form_Load()

 Dim i As Long
 Dim a As Long
 Dim b As Long

   Print
   Me.Show

   Set tmHowLong = New CTimingPC
   Set BitS = New CBitwise ' Initializes the Class

   Print "ShiftLeft 4 by 4 bits  =   "; BitS.ShiftLeft(4, 4)
   Print "ShiftRight 64 by 2 bits =  "; BitS.ShiftRight(64, 2)
   Print "RotateLeft -2 by 4 bits =  "; BitS.RotateLeft(-2, 4)
   Print
   Print

   '''''''''''''''''''''''''''''''''''''

   a = 7

   tmHowLong.Reset

   For i = 1 To 1000000
      b = a * 2 ^ 2
   Next i

   Print Format(tmHowLong.Elapsed, "0000") & " msec"
   Print "for VB 1 million times: num = 7 Shift left 2 = "; b
   Print

   a = 7

   tmHowLong.Reset

   For i = 1 To 1000000
      b = BitS.ShiftLeft(a, 2)
   Next i

   Print Format(tmHowLong.Elapsed, "0000") & " msec"
   Print "for CLASS 1 million times: num = 7 Shift left 2 = "; b

   '''''''''''''''''''''''''''''''''''''

   Set BitS = Nothing   ' Terminate class
   Set tmHowLong = Nothing

End Sub

':) Ulli's VB Code Formatter V2.16.6 (2003-Jun-03 17:29) 7 + 52 = 59 Lines
