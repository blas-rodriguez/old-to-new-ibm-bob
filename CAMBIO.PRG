Cls
Use Reserva New
Index On Reserva to gRes
Set Index to gRes

Use ParqueNu New
DbGoTop()
While !Eof()
  xReserva:=Reserva
  xSector:=Sector
  xFila:=Fila
  xParcela:=Parcela
  xProvincia:=Provincia
  xLocalidad:=Localidad
  xCPostal:=CPostal
  xTDoc:=TDoc
  xDocumento:=Documento
  If Reserva!=0
      If Reserva->(DbSeek(xReserva))
            Replace Reserva->Sector With xSector,;
                    Reserva->Fila With xFila,;
                    Reserva->Parcela With xParcela,;
                    Reserva->Provincia With xProvincia,;
                    Reserva->Localidad With xLocalidad,;
                    Reserva->CPostal With xCPostal,;
                    Reserva->TDoc With xTDoc,;
                    Reserva->Documento With xDocumento
       Else
         ?xReserva
       EndIf
 EndIf
 DbSkip()
EndDo
Return

