Cls
Use ParqueNu New
Index On Reserva to pp
Set Index to pp

_Alpt(72)
Use Reserva New
DbGoTop()
While !Eof()
   xReserva:=Reserva
   If ParqueNu->(DbSeek(xReserva))
      xCobrador:=Cobrador
      Replace ParqueNu->Cobrador With xCobrador
   Else
      ?'No Existe Reserva',xReserva
   EndIf
   DbSkip()
EndDo
Eject
_Clpt()
Return
