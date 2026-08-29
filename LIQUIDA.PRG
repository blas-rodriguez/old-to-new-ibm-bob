Private Mes_Liq:=03
Private Ano_Liq:=2000
Private FechaVence:=CToD('03/10/1999')
Cls
AbreSet()
AbreDbf()
Reserva->(Nucleo())
Return

Function Nucleo
    DbGoTop()
    While !Eof()
        If CodBaja=0
           xReserva:=Reserva
           xUlt_Mes:=1
           xUlt_Ano:=1991
           xExpensa:=Expensa
           AuxLiq->(__DbZap())
           CtaExp->(Liquidacion(xReserva,xUlt_Mes,xUlt_Ano,xExpensa))
        EndIf
        DbSkip()
    EndDo
Return Nil

Function Liquidacion(xReserva,xMes,xAno,xExpensa)
    Local xTotal:=xCantidad:=0
    Local xSalida:=.f.
    ?xReserva
    DbSetOrder(2)
    ****browse()
    DbSeek(StrZero(xReserva,6)+StrZero(Ano_Liq,4)+StrZero(Mes_Liq,2),.t.)

    If xReserva!=Reserva
       VerActiva()
          DbAppend()
          Replace Reserva With xReserva,;
                  Vence   With FechaVence,;
                  Valor   With xExpensa,;
                  Mes     With Mes_Liq,;
                  Ano     With Ano_Liq,;
                  Pagada  With 'N'
          DbCommit()
       DbUnLock()
    Else
       ??Reserva,Mes,Ano
       Inkey(0)
    EndIf
    While .t.
       If DbSeek(StrZero(xReserva,6)+StrZero(xAno,4)+StrZero(xMes,2))
           If Pagada='N'
              xTotal+=Valor
              xCuota:=Valor
              AuxLiq->(CargaDeta(xReserva,xAno,xMes,xCuota))
              xCantidad++
           EndIf
       EndIf
       xMes++
       If xMes=13
          xMes:=1
          xAno++
       EndIf
       If xSalida
          Exit
       Else
          If xMes=Mes_Liq .And. xAno=Ano_Liq
             xSalida:=.t.
          EndIf
       EndIf
    EndDo
    ??xCantidad
    ResuCta->(CargaLiq(xReserva,xCantidad,xTotal))
Return Nil

Function CargaDeta(xReserva,xAno,xMes,xCuota)
    DbAppend()
    Replace Reserva With xReserva,;
            Ano     With xAno,;
            Mes     With xMes,;
            Cuota   With xCuota
Return Nil

Function CargaLiq(xReserva,xCantidad,xTotal)
    Local xMinimo:=0
    VerActiva()
       xMinimo:=(xTotal*.30)
       If xMinimo>xTotal
          xMinimo:=xTotal
       EndIf
       DbAppend()
       Replace Reserva With xReserva,;
               Total   With xTotal,;
               Minimo  With xMinimo,;
               Vence   With FechaVence
       xAdeuda:=AuxLiq->(TraeMesAde(xReserva))
       Replace Adeuda With xAdeuda
       DbCommit()
    DbUnLock()
Return Nil

Function TraeMesAde(xReserva)
    Local xDevuelve:=''
    DbGoTop()
    While !Eof()
       xDevuelve+=Str(Ano,4)+'/'+StrZero(Mes,2)+' '
       DbSkip()
    EndDo
Return xDevuelve

Function AbreDbf
    Use CtaExp Shared New
    If !File('CtaExp.Ntx')
       Index On Reserva to CtaExp
    EndIf
    If !File('CtaExp2.Ntx')
       Index On StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2) to CtaExp2
    EndIf
    Set Index to CtaExp,CtaExp2

    Use ResuCta Shared New
    If !File('ResuCta.Ntx')
       Index On Reserva to ResuCta
    EndIf

    Use Reserva Shared New
    If !File('Reser1.Ntx')
       Index On Reserva to Reser1
    EndIf
    If !File('Reser2.Ntx')
       Index On Nombre to Reser2
    EndIf
    Set Index to Reser1,Reser2

    Use AuxLiq01 Alias AuxLiq New

Return Nil
