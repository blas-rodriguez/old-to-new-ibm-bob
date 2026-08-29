Use CtaExp New
Zap
*********Use ParqueNu New
*********Index On Codigo to Ppp
*********Set Index to Ppp

Use PExpensa New
*********DbGoTop()
*********While !Eof()
*********   xCodigo=Codigo
*********   If ParqueNu->(DbSeek(xCodigo))
*********      xReserva:=ParqueNu->Reserva
*********      Replace Reserva With xReserva
*********   EndIf
*********   DbSkip()
*********EndDo
DbGoTop()
While !Eof()
    xReserva:=Reserva
    xMes:=Ult_Mes
    xAno:=Ult_Ano
    xValor:=Saldo
    CtaExp->(Carga(xReserva,xMes,xAno,xValor))
    DbSkip()
EndDo
Return

Function Carga(xReserva,xMes,xAno,xValor)
    DbAppend()
    Replace Reserva With xReserva,;
            Mes With xMes,;
            Ano With xAno,;
            Valor With xValor,;
            Pagada With 'N'
Return Nil
