AbreSet()
Set century on
Use Parquenu New
***Index On Reserva to pppp
Set index to pppp

Use Reserva New
DbGoTop()
While !Eof()
   xReserva:=Reserva
   If Parquenu->(DbSeek(xReserva))
      Replace Ult_mes With Parquenu->Ult_mes
      If Parquenu->Ult_Ano<1000
         Replace Ult_Ano With Parquenu->Ult_Ano+1900
      Else
         Replace Ult_Ano With Parquenu->Ult_Ano
      EndIf
   Else
      Replace Ult_Ano With 1990
      Replace Ult_mes With 1
   EndIf
   DbSkip()
EndDo
Browse()
Return
