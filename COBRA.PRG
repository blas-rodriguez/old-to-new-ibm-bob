Private FechaVence:=CToD('12/10/1999')
Cls
AbreSet()
AbreDbf()
Reserva->(Cobranza())
Return

Function Cobranza
    Local xPaga:=0
    Private xReserva:=0
    BoxFede(5,10,15,60)
    While .t.
       @7,13 Say 'Ingrese Reserva: ' Get xReserva Pict '999999'
       ReadOn()
       If LastKey()=27
          Exit
       EndIf
       If !DbSeek(xReserva)
          MueveLet('Reserva Inexistente')
          Loop
       EndIf
       xCobrador:=Cobrador
       If ResuCta->(DbSeek(xReserva))
          xMinimo:=ResuCta->Minimo
          xTotal:=ResuCta->Total
          @9,13 Say 'Paga :' Get xPaga Pict '999999.99'
          ReadOn()
          If xPaga<xMinimo
             MueveLet('No puede pagar menos del m¡nimo.')
             Loop
          EndIf
          CtaExp->(Descarga(xReserva,xPaga))
          ResuCta->(VerActiva())
             Replace ResuCta->Pagado With xPaga
             ResuCta->(DbCommit())
          ResuCta->(DbUnLock())
       EndIf
    EndDo
Return Nil

Function Descarga(xReserva,xPaga)
    Local tMes:=tAno:=0,xDias:=0,SiPaga:=' ',xMes:=xAno:=0
    DbSetOrder(2)
    DbSeek(StrZero(xReserva,6)+StrZero(1990,4)+StrZero(1,2),.t.)
    While Reserva=xReserva
       tMes:=Mes
       tAno:=Ano
       If Pagada='N'
          If Valor<xPaga
             xPaga-=Valor
             VerActiva()
                Replace Pagada With 'S',;
                        Valor With 0
                      ///// Cargar Comprobante Nro y toda la boludez
                DbCommit()
             DbUnLock()
          ElseIf xPaga=Valor
             VerActiva()
                Replace Pagada With 'S',;
                        Valor With 0
                      ///// Cargar Comprobante Nro y toda la boludez
                DbCommit()
             DbUnLock()
             xMes:=Mes
             xAno:=Ano
             Reserva->(VerActiva())
                Replace Reserva->Ult_Mes With xMes,;
                        Reserva->Ult_Ano With xAno
                Reserva->(DbCommit())
             Reserva->(DbUnLock())
             xPaga-=Valor
             Exit
          ElseIf xPaga>0 .And. Valor>xPaga
             xPaga-=Valor
             VerActiva()
                Replace Valor With Abs(xPaga)
                DbCommit()
             DbUnLock()
             DbSkip(-1)
             xMes:=Mes
             xAno:=Ano
             Reserva->(VerActiva())
                Replace Reserva->Ult_Mes With xMes,;
                        Reserva->Ult_Ano With xAno
                Reserva->(DbCommit())
             Reserva->(DbUnLock())
             Exit
          EndIf
       EndIf
       DbSkip()
    Enddo
    If xPaga>0
       xDias:=0
       SiPaga:='N'
       While .t.
           xDias+=30
           tMes++
           If tMes=13
              tMes:=1
              tAno++
           EndIf
           VerActiva()
              xCuota:=xPaga-(Reserva->Expensa)
              If xCuota>=0
                 xCuota:=0
                 SiPaga:='S'
              Else
                 xCuota:=Abs(xCuota)
                 SiPaga:='N'
              EndIf
              DbAppend()
              Replace Reserva With xReserva,;
                      Vence   With FechaVence+xDias,;
                      Valor   With xCuota,;
                      Mes     With tMes,;
                      Ano     With tAno,;
                      Pagada  With SiPaga

                      ///// Cargar Comprobante Nro y toda la boludez
              DbCommit()
           DbUnLock()
           xPaga-=(Reserva->Expensa)
           If xPaga<=0
              Exit
           EndIf
       EndDo
    EndIf
Return Nil

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
    Set Index to ResuCta

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

