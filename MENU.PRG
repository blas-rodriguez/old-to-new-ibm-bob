///#Include "FTMENUTO.CH"
Public FonCol:='GR+/GR+,W,,,I/I'
Public CurCol:='W/B+,N/W,,,W/B+'
Public EmuCol:='R/W,W/B+,,,W/B+'
Public PelCol:='W+/R,R/W,,,W/R'
Public MonCol:='GR+/B,Gr+/B+,,,GR+/B'
Public DanCol:='GR+*/B,Gr+*/B+,,,GR+*/B'
Public Alegre:='W+/G+,N/W,,,W+/G+'
Public EmpNom:='EMPRESA DEMO S.R.L.'
Public EmpDir:='DOMICILIO FICTICIO'
Public Puesto:=GetEnv('Puesto')
*Public xUser:=Contrasenia()
AbreSet()
Fondo()
OpenDbf()
MenuPrincipal()
SetColor( '' )
UltTecla(0)
DbCloseAll()
SalNic(EmpNom,EmpDir)
Return

Function Contrasenia
    Local Scr:=SaveScreen(0,0,24,79)
    Local xUsuario:=Spac(10)
    Local xClave:=Spac(10)
    Local xColor:=SetColor()
    SetColor(PelCol)
    Cls
    Use Contras Shared New
    If !File('Contras.Ntx')
       Index On Usuario to Contras
    EndIf
    Set Index to Contras
    BoxFede(10,20,14,50,'W+/R+')
    xPasa:=.f.
    For t=1 to 3
        @11,23 Say 'Usuario :' Get xUsuario Pict '@!'
        @12,23 say 'Clave   : '
        ReadOn()
        pw = 0
        mak=""
        While pw < 10
           pw = pw + 1
           mak = mak + upper(chr(inkey(0)))
           If LastKey() = 27 .Or. LastKey() = 13
              If LastKey()=13
                 Mak:=Substr(Mak,1,Len(Mak)-1)
              EndIf
              Exit
           EndIf
           Say(12,32+pw,'','N/R')
        End
        xClave:=PadR(Mak,10)
        If DbSeek(xUsuario)
           If Clave=xClave
              xPasa:=.t.
              Exit
           EndIf
        EndIf
    Next t
    If !xPasa
       xUsuario:='9999999999'
    EndIf
    RestScreen(0,0,24,79,Scr)
    SetColor(xColor)
Return xUsuario


Static Function Fondo
Local xColor:=SetColor()
SetColor(FonCol)
Say(0,0,PadC(EmpNom,80),'Gr+/B+')
@1,0,23,79 Box 'ฑฑฑฑฑฑฑฑฑ'
SetColor(xColor)
SetColor(MonCol)
SetColor('G+')
Say(24,56,' Sistema legado demo ','Gr+/B+')
SetColor(xColor)
Return Nil

*Function Udf(x,y,Falso)
*Local xColor:=SetColor()
*SetColor(EmuCol)
*If Falso=Nil
*   @x,y Say ' ฏ'
*EndIf
*SetColor(xColor)
*Return ""

Function MenuPrincipal

 Scr1:=SaveScreen(3,5,6,26)
 Scr2:=SaveScreen(3,30,6,51)
 Scr3:=SaveScreen(3,55,6,76)
 xCursor:=SetCursor()
 SetColor(CurCol)
 BoxFede(3,5,5,25)
 BoxFede(3,30,5,50)
 BoxFede(3,55,5,75)
 SetCursor(0)
While .t.
   Set Key 5 to Nada()
   Set Key 24 to Nada()
*  SetColor(CurCol)
*  clear
   @4, 8 Prompt '   Ingresos    ' //HotKey 4 HotKeyColor R+/B BarHotKeyColor R+/W
   @4,33 Prompt '  Operaciones  ' //HotKey 3 HotKeyColor R+/B BarHotKeyColor R+/W
   @4,58 Prompt '   Consultas   ' //HotKey 4 HotKeyColor R+/B BarHotKeyColor R+/W
   Menu to Op
   Set Key 5 to
   Set Key 24 to
   Scr:=SaveScreen(0,0,24,79)
   Do Case
      Case Op=0
           If _Quest(10,'!!!  A T E N C I O N  !!!',;
               'Est  por Salir y Regresar al Sistema Operativo',;
               'จ Confirma ?')
              Exit
           EndIf
      Case Op=1
           BoxSofi(3,5,5,25,Scr1,'   Ingresos    ')
           Inkey(.1)
           MenuIngresos()
           RestScreen(0,0,24,79,Scr)
           Inkey(.1)
      Case Op=2
           BoxSofi(3,30,5,50,Scr2,'  Operaciones  ')
           Inkey(.1)
           MenuOperaciones()
           RestScreen(0,0,24,79,Scr)
           Inkey(.1)
      Case Op=3
           BoxSofi(3,55,5,75,Scr3,'   Consultas   ')
           Inkey(.1)
           MenuConsultas()
           RestScreen(0,0,24,79,Scr)
           Inkey(.1)
   EndCase
   RestScreen(0,0,24,79,Scr)
EndDo
SetCursor(xCursor)
DbCommitAll()
Return Nil

Function BoxSofi(f1,c1,f2,c2,xScr,xLeyenda,xColor)
Local ColAnt:=SetColor()
Local xCursor:=SetCursor()
If xColor!=Nil
   SetColor(xColor)
EndIf
SetCursor(0)
Tone(1500,1)
RestScreen(f1,c1,f2+1,c2+1,xScr)
@f1+1,c1+1 clea to f2+1,c2+1
@f1+1,c1+2 to f2+1,c2 Doub
@f1+2,c1+4 Say xLeyenda
SetColor(ColAnt)
SetCursor(xCursor)
Return Nil

Function MenuIngresos
Local Op:=1
Local Scr
Private xAgencia:=0
Public Vec:={}
BoxFede(7,5,13,47)
Say(7,8,' Menฃ de Ingresos ',MonCol)
While .t.
   SetColor(CurCol)
   @ 8,8 Prompt ' ณ Cobro de Expensas                 ' //HotKey 13 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @ 9,8 Prompt ' ณ Cobro de Cuotas                   ' //HotKey 13 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @10,8 Prompt ' ณ Cobro de Mutuales                 ' //HotKey 13 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @11,8 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @12,8 Prompt ' ณ <Esc> Regresa Menฃ Anterior       ' //HotKey 10 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   Menu to Op
   Scr:=SaveScreen(0,0,24,79)
   Do Case
      Case Op=5 .Or. Op=0
           Exit
      Case Op=1
           CobroExpensas()
      Case Op=2
           CobroCuotas()
      Case Op=4
   EndCase
   RestScreen(0,0,24,79,Scr)
EndDo
Return Nil

Function MenuOperaciones
Local Op:=1
Local Scr
Private xAgencia:=0
Public Vec:={}
BoxFede(7,20,21,62)
Say(7,23,' Menฃ de Operaciones ',MonCol)
While .t.
   SetColor(CurCol)
   @ 8,23 Prompt ' ณ Adjudicaciขn de Parcelas          ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @ 9,23 Prompt ' ณ Modificaciขn de Parcelas          ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @10,23 Prompt ' ณ Modificaciขn de Reservas          ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @11,23 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @12,23 Prompt ' ณ Alta de Inhumaciones              ' //HotKey 12 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @13,23 Prompt ' ณ MoDificaciขn en Inhumaciones      ' //HotKey 6 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @14,23 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @15,23 Prompt ' ณ Liquidaciขn de Expensas           ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @16,23 Prompt ' ณ Liquidaciขn de Expensas x Reserva ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @17,23 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ' //HotKey 20 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @18,23 Prompt ' ณ Emisiขn de Listados               ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @19,23 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @20,23 Prompt ' ณ <Esc> Regresa Menฃ Anterior       ' //HotKey 10 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   Menu to Op
   Scr:=SaveScreen(0,0,24,79)
   Do Case
      Case Op=13 .Or. Op=0
           Exit
      Case Op=1
           ParqueNu->(AltaReservas())
      Case Op=2
           ParqueNu->(VerActiva())
           ParqueNu->(Hojear())
           ParqueNu->(DbCommit())
           ParqueNu->(DbUnLock())
      Case Op=3
           Reserva->(VerActiva())
           Reserva->(Hojear())
           Reserva->(DbCommit())
           Reserva->(DbUnLock())
      Case Op=5
           ParqueNu->(AltaInhu())
      Case Op=8
           If Pass1('DEMO00')
              //ResuCta->(__DbZap())
              Reserva->(Nucleo())
           EndIf
      Case Op=9
           Reserva->(N_ucleo())
      Case Op=11
           MenuListados()
   EndCase
   RestScreen(0,0,24,79,Scr)
EndDo
Return Nil

Function AltaInhu
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษออออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออป ',;
            ' บ  Cขdigo :                          ณ    Sector :             บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด      Fila :             บ ',;
            ' บ Apellido y Nombre                  ณ   Parcela :             บ ',;
            ' บ                                    ณ   Reserva :             บ ',;
            ' บ Domicilio                          ณ      Tipo :             บ ',;
            ' บ                                    ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ Barrio                           Telefono        Documento   บ ',;
            ' บ                                                              บ ',;
            ' บ Nivel                            SubNivel                    บ ',;
            ' บ                                                              บ ',;
            ' ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ '}
Local xSector:=Spac(3)
Local xFila:=xParcela:=0
Local xNivel:=xSubNivel:=0
Local xOrd:=DbSetOrder()
Private xCodigo:=Spac(7)
SetColor('W+/B+')
BoxFede(2,2,13,67)
WinShowR(Arr,2,2,'B')
Say(2,5,' Alta de Inhumaciones ',MonCol)
DbSetOrder(2)
While .t.
   SetColor('W+/B+')
   @3,55 Get xSector Pict '!!!'
   @4,55 Get xFila Pict '99'
   @5,55 Get xParcela Pict '99'
   ReadOn()
   If LastKey()=27
      Exit
   EndIf
   xCodigo:=xSector+StrZero(xFila,2)+StrZero(xParcela,2)
   If DbSeek(xCodigo)
      Say(3,15,PadR(AllTrim(Codigo),11),'GR+/B+')
      Say(6,5,PadR(AllTrim(Nombre),34),'RB+/B+')
      Say(6,55,Str(Reserva,6),'BG+/B+')
      Say(7,54,If(Tipo_P_S='S','Socio',If(Tipo_P_S='V','120c x $20','Particular')),'BG+/B+')
      Say(8,5,PadR(AllTrim(Domicilio),34),'BG+/B+')
      Say(10,5,PadR(AllTrim(Barrio),34),'BG+/B+')
      Say(10,39,PadR(AllTrim(Telefono),10),'BG+/B+')
      Say(10,52,PadC(Str(Documento,8),12),'BG+/B+')
      @12,5 Get xNivel Pict '9' Range 1,3
      @12,39 Get xSubNivel Pict '9' Range 1,6
      ReadOn()
      If LastKey()=27
         Loop
      EndIf
      SubNivel->(DbSetOrder(2))
      If SubNivel->(DbSeek(xCodigo+Str(xNivel,1)+Str(xSubNivel,1)))
         MueveLet('Inhumaciขn Existente. Verifique')
      Else
        SubNivel->(CargaSub(xCodigo,xNivel,xSubNivel))
      EndIf
   Else
      MueveLet('Cขdigo Inexistente. Verifique.')
   EndIf
EndDo
DbSetOrder(xOrd)
Return Nil

Function CargaSub(xCodigo,xNivel,xSubNivel)
Local Scr:=SaveScreen(0,0,24,79)
Local xColor:=SetColor()
Local xFallece:=Date()
Local xNombre:=Spac(25),xDocum:=Spac(8),xSexo:=' ',xActa:=0,xTipo:=' ',xImpuesto:=0
Local xFecInhu:=CtoD('  /  /  '),xBoleto:=Spac(8),xTipSer:=' ',xCocheria:=0,xFeretro:=0
For t=1 to xSubNivel
    If !DbSeek(xCodigo+Str(xNivel,1)+Str(t,1))
       If t!=xSubNivel
          MueveLet('Debe Cargar primero el SubNivel '+Str(t,1))
          Return Nil
       EndIf
    EndIf
Next t
SetColor(Alegre)
BoxFede(8,20,21,65)
   @ 9,23 Say 'Fallecimiento ' Get xFallece Pict '@D'
   @10,23 Say '       Nombre ' Get xNombre Pict '@!'
   @11,23 Say '    Documento ' Get xDocum Pict '99999999'
   @12,23 Say '         Sexo ' Get xSexo Pict '!' Valid xSexo="M" .Or. xSexo="F"
   @13,23 Say '         Acta ' Get xActa Pict '9999999999'
   @14,23 Say '         Tipo ' Get xTipo Pict '!'
   @15,23 Say '     Impuesto ' Get xImpuesto Pict '999999999'
   @16,23 Say '   Inhumaciขn ' Get xFecInhu Pict '@D'
   @17,23 Say '       Boleto ' Get xBoleto Pict '@!'
   @18,23 Say 'Tipo Servicio ' Get xTipSer Pict '!'
   @19,23 Say '     Cocheria ' Get xCocheria Pict '9999'
   @20,23 Say '      Feretro ' Get xFeretro Pict '9999'
   ReadOn()
   If LastKey()!=27
      VerActiva()
      DbAppend()
      Replace Codigo With xCodigo,;
              Nivel With xNivel,;
              SubNivel With xSubNivel,;
              Fecha With xFallece,;
              Nombre With xNombre,;
              Documento With xDocum,;
              Sexo With xSexo,;
              Acta With xActa,;
              Tipo With xTipo,;
              Impuesto With xImpuesto,;
              FechaI With xFecInhu,;
              Boleto With xBoleto,;
              TipoI With xTipSer,;
              Cocheria With xCocheria,;
              Feretro With xFeretro
      DbCommit()
      DbUnLock()
   EndIf
SetColor(xColor)
Restscreen(0,0,24,79,Scr)
Return Nil


Function MenuListados
Local Op:=1
Local Scr
Private xAgencia:=0
Public Vec:={}
BoxFede(9,25,17,71)
Say(9,28,' Menฃ de Listados ',MonCol)
While .t.
   SetColor(CurCol)
   @10,28 Prompt ' ณ Listado de Liquidaciขn Por Cobrador ' //HotKey 16 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @11,28 Prompt ' ณ Listado de Liquidaciขn Por Mutual   ' //HotKey 16 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @12,28 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @13,28 Prompt ' ณ Listado de Cobranzas por Cobrador   ' //HotKey 16 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @14,28 Prompt ' ณ Listado de Cobranzas General        ' //HotKey 16 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @15,28 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @16,28 Prompt ' ณ <Esc> Regresa Menฃ Anterior         ' //HotKey 10 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   Menu to Op
   Scr:=SaveScreen(0,0,24,79)
   Do Case
      Case Op=7 .Or. Op=0
           Exit
      Case Op=1
           Cobrador->(ListaCob())
      Case Op=2
           Mutual->(ListaMut())
      Case Op=4
           Cobrador->(LCobCob())
      Case Op=5
           Cobrador->(LCobGen())
   EndCase
   RestScreen(0,0,24,79,Scr)
EndDo
Return Nil

Function LCobGen
Local Scr:=SaveScreen(0,0,24,79)
Local xDesde:=xHasta:=Date()
Private xCob:=0
Private Vec:={}
BoxFede(12,35,15,73)
Say(12,38,' Listado Cobranzas General ',MonCol)
While .t.
   @13,38 Say 'Desde :' Get xDesde Pict '@D'
   @14,38 Say 'Hasta :' Get xHasta Pict '@D' Valid xHasta>=xDesde
   ReadOn()
   If LastKey()=27
      Exit
   EndIf
   Vec:={}
   xAcum:=0
   xtCuota:=xtExpensa:=xtTotal:=0
   AADD(Vec,PadR(''+EmpNom+'',81))
   AADD(Vec,PadR('4'+EmpDir+'5',81))
   AADD(Vec,Spac(77))
   AADD(Vec,PadR('Listado de Cobranzas General',81))
   AADD(Vec,Spac(77))
   AADD(Vec,PadR('EFecha DesdeF '+DtoC(xDesde)+'    '+'EFecha Hasta F'+DtoC(xHasta),85))
   AADD(Vec,Replicate('ฤ',77))
   AADD(Vec,PadR('E  Fecha          Cuota      Expensa      Total     AcumuladoF',81))
   While .t.
      xCuota:=Recibo->(TakeRec(xCob,xDesde,.f.))
      xExpensa:=ExpCta->(TakeRec(xCob,xDesde,.f.))
      xTotal:=xCuota+xExpensa
      xAcum+=xTotal
      xtCuota+=xCuota
      xtExpensa+=xExpensa
      xtTotal+=xTotal
      AADD(Vec,PadR(DtoC(xDesde)+'    '+Transform(xCuota,'999999.99')+'   '+;
      Transform(xExpensa,'999999.99')+'   '+Transform(xTotal,'999999.99')+'   E4'+;
      Transform(xAcum,'999999.99')+'5F',85))
      xDesde++
      If xDesde>xHasta
         Exit
      EndIf
   EndDo
   AADD(Vec,PadR('ET O T A L E S '+Transform(xtCuota,'999999.99')+'   '+;
   Transform(xtExpensa,'999999.99')+'   '+Transform(xtTotal,'999999.99')+'F',81))
   MChoice(Vec,12,'A',.t.)
EndDo
RestScreen(0,0,24,79,Scr)
Return

Function LCobCob
Local Scr:=SaveScreen(0,0,24,79)
Local xDesde:=xHasta:=Date()
Private xCob:=0
Private Vec:={}
BoxFede(12,35,17,73)
Say(12,38,' Listado Cobranzas Por Cobrador ',MonCol)
While .t.
   xDesde:=xHasta:=Date()
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
   @13,38 Say 'Ingrese Cobrador: ' Get xCob Pict '999999'
   ReadOn()
   SetKey( -9,{|| Nil })
   If LastKey()=27
      Exit
   EndIf
   If !DbSeek(xCob)
      MueveLet('Error, Cobrador Inexistente....')
      Loop
   EndIf
   Say(14,38,Nombre,'G/B')
   @15,38 Say 'Desde :' Get xDesde Pict '@D'
   @16,38 Say 'Hasta :' Get xHasta Pict '@D' Valid xHasta>=xDesde
   ReadOn()
   Vec:={}
   xAcum:=0
   xtCuota:=xtExpensa:=xtTotal:=0
   AADD(Vec,PadR(''+EmpNom+'',81))
   AADD(Vec,PadR('4'+EmpDir+'5',81))
   AADD(Vec,Spac(77))
   AADD(Vec,PadR('Listado de Cobranzas por Cobrador',81))
   AADD(Vec,Spac(77))
   AADD(Vec,PadR('EFecha DesdeF '+DtoC(xDesde)+'    '+'EFecha Hasta F'+DtoC(xHasta),85))
   AADD(Vec,PadR('Cobrador :E'+Nombre+'F',81))
   AADD(Vec,Replicate('ฤ',77))
   AADD(Vec,PadR('E  Fecha          Cuota      Expensa      Total     AcumuladoF',81))
   While .t.
      xCuota:=Recibo->(TakeRec(xCob,xDesde,.t.))
      xExpensa:=ExpCta->(TakeRec(xCob,xDesde,.t.))
      xTotal:=xCuota+xExpensa
      xAcum+=xTotal
      xtCuota+=xCuota
      xtExpensa+=xExpensa
      xtTotal+=xTotal

      AADD(Vec,PadR(DtoC(xDesde)+'    '+Transform(xCuota,'999999.99')+'   '+;
      Transform(xExpensa,'999999.99')+'   '+Transform(xTotal,'999999.99')+'   E4'+;
      Transform(xAcum,'999999.99')+'5F',85))
      xDesde++
      If xDesde>xHasta
         Exit
      EndIf
   EndDo
   AADD(Vec,PadR('ET O T A L E S '+Transform(xtCuota,'999999.99')+'   '+;
   Transform(xtExpensa,'999999.99')+'   '+Transform(xtTotal,'999999.99')+'F',81))
   MChoice(Vec,12,'A',.t.)
EndDo
RestScreen(0,0,24,79,Scr)
Return

Function TakeRec(xCob,xFecha,xPara)
Local xOrd:=DbSetOrder()
Local xCuota:=0
If xPara
   DbSetOrder(3)
   If DbSeek(StrZero(xCob,6)+DtoC(xFecha))
      While Cobrador=xCob .And. Fecha=xFecha .And. !Eof()
         xCuota+=Importe
         DbSkip()
      EndDo
   EndIf
Else
   DbSetOrder(4)
   If DbSeek(DtoC(xFecha))
      While Fecha=xFecha .And. !Eof()
         xCuota+=Importe
         DbSkip()
      EndDo
   EndIf
EndIf
DbSetOrder(xOrd)
Return xCuota

Function ListaCob
Local Scr:=SaveScreen(0,0,24,79)
Private xCob:=0
BoxFede(12,35,15,73)
Say(12,38,' Listado Por Cobrador ',MonCol)
While .t.
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
   @13,38 Say 'Ingrese Cobrador: ' Get xCob Pict '999999'
   ReadOn()
   SetKey( -9,{|| Nil })
   If LastKey()=27
      Exit
   EndIf
   If !DbSeek(xCob)
      MueveLet('Error, Cobrador Inexistente....')
      Loop
   EndIf
   Reserva->(PutExpensa(xCob))
EndDo
RestScreen(0,0,24,79,Scr)
Return


Function ListaMut
Local Scr:=SaveScreen(0,0,24,79)
Private xMut:=0
BoxFede(12,35,15,73)
Say(12,38,' Listado Por Mutual ',MonCol)
While .t.
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
   @13,38 Say 'Ingrese Mutual: ' Get xMut Pict '999999'
   ReadOn()
   SetKey( -9,{|| Nil })
   If LastKey()=27
      Exit
   EndIf
   If !DbSeek(xMut)
      MueveLet('Error, Mutual Inexistente....')
      Loop
   EndIf
   If Diskette
      Reserva->(DisExpensa(xMut))
   Else
      Reserva->(PonExpensa(xMut))
   EndIf
EndDo
RestScreen(0,0,24,79,Scr)
Return

Function DisExpensa(xMut)
Local xOrd:=DbSetOrder()
Local Vec:={}
Local BeforAr:=Select()
Private xGrupo:=StrZero(Mutual->Grupo,3)
Use Imp&xGrupo Alias AxMutu New
Zap
DbSelectAr(BeforAr)
DbSetOrder(4)
DbSeek(xMut)
While Mutual=xMut .And. !Eof()
  If Empty(Baja)
     xReserva:=Reserva
     ParqueNu->(DbSeek(xReserva))
     If ResuCta->(DbSeek(xReserva))
        xNombre:=Nombre
        xLugT:=LugT
        xDocumento:=ParqueNu->Documento
        xImporte:=Expensa
        xCredito:=Credito
        xPagCta:=CtaCte->(TraeDM(xReserva,xCredito))
        AxMutu->(DbAppend())
        Replace AxMutu->NumSuc With 0,;
                AxMutu->Grupo With Mutual->Grupo,;
                AxMutu->Cuenta With Val(xLugT),;
                AxMutu->Moneda With 1,;
                AxMutu->Nombre With xNombre,;
                AxMutu->NroDoc With xDocumento,;
                AxMutu->Importe With xImporte+xPagCta
     EndIf
  EndIf
  DbSkip()
EndDo
DbSetOrder(xOrd)
AxMutu->(ImpriDis(xMut))
AxMutu->(ImpriDis(xMut))
AxMutu->(ImpriDis(xMut))
Return Nil

Function ImpriDis(xMut)
_Alpt(72)
DbGoTop()
Cabecera()
f=9
totreg=0
totimpo=0
While !Eof()
  @f,1 say NumSuc
  @f,7 say Grupo
  @f,10 say Cuenta
  @f,23 say Moneda
  @f,26 say 'E' + Nombre + 'F'
  @f,53 say NroDoc
  @f,59 say Importe
  totreg++
  totimpo+=Importe
  f++
  If f >= 66
          Eject
          Cabecera()
          f=9
  EndIf
  Skip
  If Eof()
          Exit
  EndIf
EndDo
@f,21 say repl('-',58)
f++
@f,21 say 'TOTAL REGISTROS: ' + Ltrim(Str(totreg))
@f,49 say 'TOTAL IMPORTE: '
@f,60 say 'E' + Str(totimpo) + 'F'
Eject
_Clpt()
Return

Function Cabecera
@1,1 say 'EEMPRESA DEMO S.R.L.F'
@4,1 say Mutual->Descripcio
@5,1 say '4'+CMes(Month(date()))+' de '+Str(Year(date()),4)+'5'
@7,1 say 'E4Sucur Gp  C u e n t a Mn       Apellido y Nombre       Document  ImporteF5'
@8,1 say '----- -- ------------ -- ----------------------------- -------- --------'
Return Nil

Function PonExpensa(xMut)
Local xOrd:=DbSetOrder()
Local Vec:={}
ImpMut->(__DbZap())
DbSetOrder(4)
DbSeek(xMut)
While Mutual=xMut .And. !Eof()
  If Empty(Baja)
     xReserva:=Reserva
     If ResuCta->(DbSeek(xReserva))
        xNombre:=Nombre
        xLugT:=LugT
        xLegajo:=Legajo
        xCredito:=Credito
        xImporte:=Expensa
        xPagCta:=CtaCte->(TraeDM(xReserva,xCredito))
        ImpMut->(DbAppend())
        Replace ImpMut->Reserva With xReserva,;
                ImpMut->Nombre With xNombre,;
                ImpMut->LugT With xLugT,;
                ImpMut->Legajo With xLegajo,;
                ImpMut->Expensa With xImporte,;
                ImpMut->Cuota With xPagCta,;
                ImpMut->Total With xImporte+xPagCta
     EndIf
  EndIf
  DbSkip()
EndDo
DbSetOrder(xOrd)
ImpMut->(ImpriM(xMut))
ImpMut->(ImpriM(xMut))
ImpMut->(ImpriM(xMut))
Return Nil

Function PutExpensa(xCob)
Local xOrd:=DbSetOrder()
Local Vec:={}
ImpCob->(__DbZap())
DbSetOrder(3)
DbSeek(xCob)
While Cobrador=xCob .And. !Eof()
  If Empty(Baja)
     xReserva:=Reserva
     If ParqueNu->(DbSeek(xReserva))
        If ParqueNu->SCargo=' '
           If ResuCta->(DbSeek(xReserva))
              xNombre:=Nombre
              xDomicilio:=Domicilio
              xBarrio:=Barrio
              xAlta:=Alta
              xCredito:=Ctacte->(TraeCredito(xReserva))
              VerActiva()
                Replace Credito With xCredito
              DbUnLock()
              xImporte:=ResuCta->Total
              xPagCta:=Recibo->(TraeDR(xReserva))
              xDebCta:=xCredito-xPagCta
              ImpCob->(DbAppend())
              Replace ImpCob->Reserva With xReserva,;
                      ImpCob->Nombre With xNombre,;
                      ImpCob->Domicilio With xDomicilio,;
                      ImpCob->Barrio With xBarrio,;
                      ImpCob->Alta With xAlta,;
                      ImpCob->Credito With xCredito,;
                      ImpCob->Importe With xImporte,;
                      ImpCob->PagCta With xPagCta,;
                      ImpCob->DebCta With xDebCta,;
                      ImpCob->Total With xImporte+xDebCta
           EndIf
        EndIf
     EndIf
  EndIf
  DbSkip()
EndDo
DbSetOrder(xOrd)
ImpCob->(Imprix(xCob))
Return Nil

Function TraeCredito(xReserva)
Local xOrd:=DbSetOrder()
Local xValor:=0
DbSetOrder(xOrd)
If DbSeek(xReserva)
   While Reserva=xReserva
      xValor+=Importe
      DbSkip()
   EndDo
EndIf
DbSetOrder(xOrd)
Return xValor

Function Imprix(xCob)
_Alpt(72)
?'E'+EmpNom+'F'
?EmpDir
?
?'Cobrador: E'+Transform(xCob,'9999')+' '+Cobrador->Nombre+'F'
?'Periodo : '+CMes(Month(Date()))+' de '+Transform(Year(Date()),'9999')
?
?"M"
?'EReserva Apellido y Nombre              Domicilio                 Barrio            Alta         Cedito   Expensa Pag/Cuota Deb/Cuota  TOTAL DeudaF'
DbGoTop()
While !Eof()
    ?Transform(Reserva,'9999999'),Nombre,Domicilio,Barrio,Alta,Credito,Transform(Importe,'999999.99'),;
    Transform(PagCta,'999999.99'),Transform(DebCta,'999999.99'),;
    Transform(Total,'999999.99')
    If PRow()>66
       Eject
       ?"P"
       ?'E'+EmpNom+'F'
       ?EmpDir
       ?
       ?'Cobrador: E'+Transform(xCob,'9999')+' '+Cobrador->Nombre+'F'
       ?'Periodo : '+CMes(Month(Date()))+' de '+Transform(Year(Date()),'9999')
       ?
       ?"M"
       ?'EReserva Apellido y Nombre              Domicilio                 Barrio            Alta         Cedito   Expensa Pag/Cuota Deb/Cuota  TOTAL DeudaF'
    EndIf
    DbSkip()
EndDo
?"P"
Eject
_CLpt()
Return Nil

Function ImpriM(xMut)
Local xSuma:=0
_Alpt(72)
?'E'+EmpNom+'F'
?EmpDir
?
?'Mutual: E'+Transform(xMut,'9999')+' '+Mutual->Descripcio+'F'
?'Periodo : '+CMes(Month(Date()))+' de '+Transform(Year(Date()),'9999')
?
?'EReserva Apellido y Nombre            Lug/Trab Legajo    Expensa    Cuota   TOTALF'
DbGoTop()
While !Eof()
    ?Transform(Reserva,'9999999'),Nombre,LugT,xLegajo,Transform(Expensa,'999.99'),;
    Transform(Cuota,'999.99'),Transform(Total,'9999.99')
    xSuma+=Total
    If PRow()>66
       Eject
       ?'E'+EmpNom+'F'
       ?EmpDir
       ?
       ?'Cobrador: E'+Transform(xMut,'9999')+' '+Mutual->Descripcio+'F'
       ?'Periodo : '+CMes(Month(Date()))+' de '+Transform(Year(Date()),'9999')
       ?
       ?'EReserva Apellido y Nombre            Lug/Trab Legajo    Expensa    Cuota   TOTALF'
    EndIf
    DbSkip()
EndDo
?'E'
?PadL('SUB-TOTAL',73)+Transform(xSuma,'9999.99')
?PadL(' COMISION',73)+Transform(xSuma*Mutual->Comisi/100,'9999.99')
?
?PadL('T O T A L',73)+Transform(xSuma-(xSuma*Mutual->Comisi/100),'9999.99')+'F'
Eject
_CLpt()
Return Nil

Function TraeDM(xReserva,xCredito)
Local xSuma:=xDevuelve:=0
If DbSeek(xReserva)
   While Reserva=xReserva .And. !Eof()
      xDevuelve:=Importe
      xSuma+=Saldo
      DbSkip()
   EndDo
EndIf
If xSuma=0
   xDevuelve=0
EndIf
Return xDevuelve

Function TraeDR(xReserva)
Local xSuma:=0
Local xOrd:=DbSetOrder()
DbSetOrder(2)
If DbSeek(xReserva)
   While Reserva=xReserva .And. !Eof()
      xSuma+=(Bonificaci+Importe)
      DbSkip()
   EndDo
EndIf
DbSetOrder(xOrd)
Return xSuma

Function N_ucleo
    Private xReserva:=0
    Private Mes_Liq:=Month(Date())
    Private Ano_Liq:=Year(Date())
    Private FechaVence:=CtoD('20/'+StrZero(Month(Date()),2)+'/'+Str(Year(Date()),4))
    BoxFede(14,30,19,77)
    Say(14,33,' Liquidaciขn de Expensas x Reserva ',MonCol)
    While .t.
       SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
       @15,33 Say 'Ingrese Reserva : ' Get xReserva Pict '999999' Color MonCol
       ReadOn()
       SetKey( -9,{|| Nil })
       If LastKey()=27
          Exit
       EndIf
       If !DbSeek(xReserva)
          MueveLet('Cขigo Inexistente')
          Loop
       EndIf
       Say(16,33,Nombre,MonCol)
       @17,33 Say 'Ingrese Mes Liq.: ' Get Mes_Liq Pict '99'
       @18,33 Say 'Ingrese Aคo Liq.: ' Get Ano_Liq Pict '9999'
       ReadOn()
       If LastKey()=27
          Loop
       EndIf
       If Con_Tes(' Confirma ',' No Confirma ')
          If CodBaja=0
             xReserva:=Reserva
             xUlt_Mes:=1
             xUlt_Ano:=1991
             xExpensa:=Expensa
             AuxLiq->(__DbZap())
             CtaExp->(Liquidacion(xReserva,xUlt_Mes,xUlt_Ano,xExpensa,FechaVence))
          EndIf
       EndIf
    EndDo
Return Nil


Function Nucleo
    Private Mes_Liq:=Month(Date())
    Private Ano_Liq:=Year(Date())
    Private FechaVence:=CtoD('20/'+StrZero(Month(Date()),2)+'/'+Str(Year(Date()),4))
    DbGoTop()
    While !Eof()
        If CodBaja=0
           xReserva:=Reserva
           xUlt_Mes:=1
           xUlt_Ano:=1991
           xExpensa:=Expensa
           AuxLiq->(__DbZap())
           Say(24,0,Transform(xReserva,'999999'),'W+')
           CtaExp->(Liquidacion(xReserva,xUlt_Mes,xUlt_Ano,xExpensa,FechaVence))
        EndIf
        DbSkip()
    EndDo
Return Nil

Function Liquidacion(xReserva,xMes,xAno,xExpensa,FechaVence)
    Local xTotal:=xCantidad:=0
    Local xSalida:=.f.
    DbSetOrder(2)
    DbSeek(StrZero(xReserva,6)+StrZero(Ano_Liq,4)+StrZero(Mes_Liq,2),.t.)
    If Reserva!=xReserva .Or. Ano!=Ano_Liq .Or. Mes!=Mes_Liq
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
    ResuCta->(CargaLiq(xReserva,xCantidad,xTotal,FechaVence))
Return Nil

Function CargaDeta(xReserva,xAno,xMes,xCuota)
   DbAppend()
   Replace Reserva With xReserva,;
           Ano     With xAno,;
           Mes     With xMes,;
           Cuota   With xCuota
Return Nil

Function CargaLiq(xReserva,xCantidad,xTotal,FechaVence)
    Local xMinimo:=0
    If !DbSeek(xReserva)
       VerActiva()
          xMinimo:=(xTotal*.30)
          xCan:=Int(xMinimo/(Reserva->Expensa))
          xMinimo:=Reserva->Expensa*(xCan+1)
          DbAppend()
          Replace Reserva With xReserva,;
                  Total   With xTotal,;
                  Minimo  With xMinimo,;
                  Vence   With FechaVence
          xAdeuda:=AuxLiq->(TraeMesAde(xReserva))
          Replace Adeuda With xAdeuda
          DbCommit()
       DbUnLock()
    EndIf
Return Nil

Function TraeMesAde(xReserva)
    Local xDevuelve:=''
    DbGoTop()
    While !Eof()
       xDevuelve+=Str(Ano,4)+'/'+StrZero(Mes,2)+' '
       DbSkip()
    EndDo
Return xDevuelve

Function MenuConsultas
Local Op:=1
Local Scr
Private xAgencia:=0
Public Vec:={}
BoxFede(7,33,16,75)
Say(7,36,' Menฃ de Consultas ',MonCol)
While .t.
   SetColor(CurCol)
   @ 8,36 Prompt ' ณ Inhumaciones                      ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @ 9,36 Prompt ' ณ Titulares de Parcelas             ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @10,36 Prompt ' ณ Reservas y Cuotas                 ' //HotKey 15 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @11,36 Prompt ' ณ Parcelas y Expensas               ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @12,36 Prompt ' ณ Niveles                           ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @13,36 Prompt ' ณ Superficie                        ' //HotKey 4 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   @14,36 Prompt 'ฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ'
   @15,36 Prompt ' ณ <Esc> Regresa Menฃ Anterior       ' //HotKey 10 HotKeyColor Gr+/B BarHotKeyColor Gr+/W
   Menu to Op
   Scr:=SaveScreen(0,0,24,79)
   Do Case
      Case Op=8 .Or. Op=0
           Exit
      Case Op=1
           SubNivel->(Inhumacion())
      Case Op=2                                 
           ParqueNu->(Parcelas())
      Case Op=3
           Reserva->(Reservas())
      Case Op=4
           ParqueNu->(CuotaExpensa())
      Case Op=5
           ParqueNu->(Niveles())
      Case Op=6
           ParqueNu->(Superficie())
   EndCase
   RestScreen(0,0,24,79,Scr)
EndDo
Return Nil

Function Superficie
Local xtFila:=xtParcela:=0
Local xSector:=Spac(3)
Local xFila:=fi:=li:=0
Local xColor:=SetColor()
Local Scr:=SaveScreen(0,0,24,79)
Local Scr1
Local xCodigo:=Spac(7)
Local xCantidad:=xCantExuma:=xReservadas:=xOcupadas:=xCantidad:=xOcupadas:=xReservadas:=;
      xNivel1:=xNivel2:=xNivel3:=xSubNiv1:=xSubNiv2:=xSubNiv3:=xCocheN:=xCocheO:=0
Local xVar:=' '
Local Vec:={}
AADD(Vec,'ษออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป')
AADD(Vec,'บFilaบ   P     A     R     C     E     L     A     S                         บ')
AADD(Vec,'วฤฤฤฤืฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤถ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'ศออออสออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออผ')

SetColor( '' )
WinShowR(Vec,0,1,'D')
Say(1,2,'Fila','GR+/N')
Say(1,10,'P     A     R     C     E     L     A     S','GR+/N')
SetColor(xColor)
While .t.
  xSector:=Spac(3)
  BoxFede(0,57,2,76)
  @1,60 Say 'Sector Nง:' Get xSector Pict '!!!' Valid !Empty(xSector)
  ReadOn()
  If LastKey()=27
     Exit
  EndIf
  DbSetOrder(5)
  If DbSeek(xSector,.t.)
     SetColor( '' )
     Lev_Pan()
     WinShowR(Vec,0,1,'D')
     Say(1,2,'Fila','GR+/N')
     Say(1,10,'P     A     R     C     E     L     A     S','GR+/N')
     Say(24,0,PadC(' Sector : '+xSector+ '         < F5 >  Estadกsticas',80),'Gr+/B')
     xFila=Fila
     fi:=3
     xCantidad:=0
     xCantExuma:=0
     xOcupadas:=0
     xReservadas:=0
     xNivel1:=0
     xNivel2:=0
     xNivel3:=0
     xSubNiv1:=0
     xSubNiv2:=0
     xSubNiv3:=0
     xCocheN:=0
     xCocheO:=0
     While Sector=xSector
        li:=7
        Say(fi,3,StrZero(Fila,2),'B+')
        While Fila=xFila .And. Sector=xSector .And. !Eof()
           xCantidad++
           xCodigo=Codigo
           If Tipo_p_s='P'
              xReservadas++
              SetColor('GR+/GR+')
           ElseIf Tipo_p_s='M'
              SetColor('G+/G')
           Else
              SetColor( '' )
           EndIf
           If SubNivel->(DbSeek(xCodigo))
              xOcupadas++
              If SubNivel->Fechaexuma<>CtoD('  /  /    ')
                 xCantExuma++
                 xOcupadas--
              EndIf
              If Tipo_p_s='P'
                 xReservadas--
              EndIf
              If Date()-15 <= SubNivel->FechaI
                 SetColor('N*/R')
              Else
                 SetColor('G+/R+')
              EndIf
              tNivel1:=.f.
              tNivel2:=.f.
              tNivel3:=.f.
              While .t.
                 If SubNivel->Cocheria=1
                    xCocheN++
                 Else
                    xCocheO++
                 EndIf
                 If SubNivel->Nivel=1
                    If !tNivel1
                       xNivel1++
                       tNivel1:=.t.
                    EndIf
                    xSubNiv1++
                 ElseIf SubNivel->Nivel=2
                    If !tNivel2
                       xNivel2++
                       tNivel2:=.t.
                    EndIf
                    xSubNiv2++
                 ElseIf SubNivel->Nivel=3
                    If !tNivel3
                       xNivel3++
                       tNivel3:=.t.
                    EndIf
                    xSubNiv3++
                 EndIf
                 SubNivel->(DbSkip())
                 If SubNivel->Codigo!=xCodigo .Or. SubNivel->(Eof())
                    Exit
                 EndIf
              EndDo
           EndIf
           @fi,li Say Str(Parcela,2)
           SetColor( '' )
           li+=3
           DbSkip()
           If li>76
              li:=7
              fi++
           EndIf
        EndDo
        xFila:=Fila
        fi++
     EndDo
     SetColor(xColor)
     DbSetOrder(1)
     Scr1:=SaveScreen(15,0,24,79)
     While .t.
       RestScreen(15,0,24,79,Scr1)
       SetKey( -4,{|cProg,cLine,cVar| Porcentajes(cProg,cLine,cVar,xCantidad,xCantExuma,xReservadas,xOcupadas,xNivel1,xNivel2,xNivel3,xCocheN,xCocheO,xSubNiv1,xSubNiv2,xSubNiv3)})
       @24,0 Say 'F:' get xtFila Pict '99'
       @24,10 Say 'P:' get xtParcela Pict '99' Valid xtParcela>0
       ReadOn()
       SetKey( -4,{|| Nil })
       If LastKey()=27
          Exit
       EndIf

       Private Vec1:={}
       Private Vec2:={}
       Private Vec3:={}
       Private Matriz1,Matriz2,Matriz3
       Matriz1:=Array(7,14)
       Matriz2:=Array(7,14)
       Matriz3:=Array(7,14)
       xCodigo:=xSector+StrZero(xtFila,2)+StrZero(xtParcela,2)
       SubNivel->(BuscaNivel(xCodigo))

       UltTecla(0)
       SetKey( -1,{|| FunFede1()})
       SetKey( -2,{|| FunFede2()})
       SetKey( -3,{|| FunFede3()})
       @24,15 Get xVar Pict '!'
       ReadOn()
       SetKey( -3,{|| Nil })
       SetKey( -2,{|| Nil })
       SetKey( -1,{|| Nil })
     EndDo
     RestScreen(15,0,24,79,Scr1)
   Else
     MueveLet(' SECTOR No Encontrado ')
   EndIf
EndDo
RestScreen(0,0,24,79,Scr)
Return Nil

Function Porcentajes(cProg,cLine,cVar,xCantidad,xCantExuma,xReservadas,xOcupadas,xNivel1,xNivel2,xNivel3,xCocheN,xCocheO,xSubNiv1,SubNiv2,xSubNiv3)
Local Scr:=SaveScreen(10,0,22,79)
Local xPO:=xOcupadas/xCantidad*100
Local xPR:=xReservadas/xCantidad*100
Local xLibres:=xCantidad-(xOcupadas+xReservadas)
Local xPL:=xLibres/xCantidad*100
SetKey( -4,{|| Nil })
Oscurece(10,20,23,60)
Say(11,23,'Porcentajes de Ocupaciขn del Sector','G+/N+')
Say(13,32,'Ocupadas ','R+/N+')
Say(13,42,Transform(xPO,'999.99%'),'R+/N+')
Say(13,50,Transform(xOcupadas,'9999'),'R+/N+')
Say(14,30,'Reservadas ','GR+/N+')
Say(14,42,Transform(xPR,'999.99%'),'GR+/N+')
Say(14,50,Transform(xReservadas,'9999'),'GR+/N+')
Say(15,34,'Libres ','G+/N+')
Say(15,42,Transform(xPL,'999.99%'),'G+/N+')
Say(15,50,Transform(xLibres,'9999'),'G+/N+')
Say(17,23,' Nivel 1  ','B+/N+')
Say(17,35,' Nivel 2  ','B+/N+')
Say(17,47,' Nivel 3  ','B+/N+')
Say(18,20,'Canti.','R+/N+')
Say(18,26,Transform(xNivel1,'9999'),'BG+/N+')
Say(18,38,Transform(xNivel2,'9999'),'BG+/N+')
Say(18,50,Transform(xNivel3,'9999'),'BG+/N+')
Say(19,20,'Inhum.','R+/N+')
Say(19,26,Transform(xSubNiv1,'9999'),'GR+/N+')
Say(19,38,Transform(xSubNiv2,'9999'),'GR+/N+')
Say(19,50,Transform(xSubNiv3,'9999'),'GR+/N+')
Say(21,23,'Cocheria Demo 1 '+Transform(xCocheN,'9999'),'RB+/N+')
Say(21,47,'Otras '+Transform(xCocheO,'9999'),'W+/N+')
Say(22,23,'Cantidad de Exhumaciones '+Transform(xCantExuma,'999'),'W+/N+')
Inkey(0)
SetKey( -4,{|cProg,cLine,cVar| Porcentajes(cProg,cLine,cVar,xCantidad,xCantExuma,xReservadas,xOcupadas,xNivel1,xNivel2,xNivel3,xCocheN,xCocheO,xSubNiv1,xSubNiv2,xSubNiv3)})
RestScreen(10,0,22,79,Scr)
Return Nil

Function Niveles
*-Objetivo : Consuta de Niveles
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษออออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออป ',;
            ' บ  Cขdigo :                          ณ    Sector :             บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด      Fila :             บ ',;
            ' บ Apellido y Nombre                  ณ   Parcela :             บ ',;
            ' บ                                    ณ   Reserva :             บ ',;
            ' บ Domicilio                          ณ      Tipo :             บ ',;
            ' บ                                    ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ Barrio                           Telefono        Documento   บ ',;
            ' บ                                                              บ ',;
            ' ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ '}
Private xCodigo:=Spac(7)
Private Vec1:={}
Private Vec2:={}
Private Vec3:={}
Private Matriz1,Matriz2,Matriz3
SetColor('W+/B+')
BoxFede(2,2,11,67)
WinShowR(Arr,2,2,'B')
Say(11,42,' Consulta de Niveles ',MonCol)
While .t.
   SetColor('W+/B+')
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'!!!!!!!',1,1)})
   SetKey( -1,{|| FunFede1()})
   SetKey( -2,{|| FunFede2()})
   SetKey( -3,{|| FunFede3()})
   @3,15 Get xCodigo Pict '!!!!!!!' Color MonCol
   ReadOn()
   SetKey( -3,{|| Nil })
   SetKey( -2,{|| Nil })
   SetKey( -1,{|| Nil })
   SetKey( -9,{|| Nil })
   If LastKey() = 27
      Exit
   EndIf
   If LastKey()=18
      DbSkip(-1)
      If Bof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   If LastKey()=3
      DbSkip(1)
      If Eof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   Vec1:={}
   Vec2:={}
   Vec3:={}
   Matriz1:=Array(7,14)
   Matriz2:=Array(7,14)
   Matriz3:=Array(7,14)
   DbSetOrder(2)
   If DbSeek(xCodigo)
      WinShowR(Arr,2,2,'B')
      Say(11,42,' Consulta de Niveles ',MonCol)
      Say(3,15,PadR(AllTrim(Codigo),11),'GR+/B+')
      Say(3,55,PadC(AllTrim(Sector),4),'BG+/B+')
      Say(4,55,Str(Fila,2),'BG+/B+')
      Say(5,55,Str(Parcela,2),'BG+/B+')
      Say(6,5,PadR(AllTrim(Nombre),34),'RB+/B+')
      Say(6,55,Str(Reserva,6),'BG+/B+')
      Say(7,54,If(Tipo_P_S='S','Socio',If(Tipo_P_S='V','120c x $20','Particular')),'BG+/B+')
      Say(8,5,PadR(AllTrim(Domicilio),34),'BG+/B+')
      Say(10,5,PadR(AllTrim(Barrio),34),'BG+/B+')
      Say(10,39,PadR(AllTrim(Telefono),10),'BG+/B+')
      Say(10,52,PadC(Str(Documento,8),12),'BG+/B+')
      SubNivel->(BuscaNivel(xCodigo))
   Else
      MueveLet('ERROR !!!. El Cขdigo Ingresado es ERRONEO.')
   EndIf
   DbSetOrder(1)
EndDo
_SBoxDS(2,1,11,68,Scr1)
Return Nil

Function FunFede1
Local Scr:=SaveScreen(15,0,24,79),Scr1
Local f1,c1,f2,c2
Local xCodAtaud:=xCodCoche:=0
Private xElementoIn:=1
SetKey( -1,{|| Nil })
BoxFede(15,0,23,79,Nil,.f.)
Say(15,3,'Sn',MonCol)
Say(15,8,'Nombre',MonCol)
Say(15,30,'Fallecimiento',MonCol)
Say(15,44,'Documento',MonCol)
Say(15,54,'Sexo',MonCol)
Say(15,59,'Tipo',MonCol)
Say(15,67,'Inhumaciขn',MonCol)
Say(23,4,' Nivel 1 ',MonCol)
While .t.
  xNumero:=Achoice(16,2,23,77,Vec1,,"FunUsuario",xElementoIn)
  xElementoIn:=xNumero
  If LastKey()=13
     Scr1:=SaveScreen(0,0,24,79)
     f1:=9
     c1:=30
     f2:=23
     c2:=73
     While .t.
         Oscureze(f1,c1+4,f2,c2)
         Say(   f1,c1+5,'Datos Completos del Nivel 1','RB+/N+')
         Say( f1+1,c1+10,'SubNivel','G+/N+')
         Say( f1+2,c1+5,'Fallecimiento','G+/N+')
         Say( f1+3,c1+12,'Nombre','G+/N+')
         Say( f1+4,c1+9,'Documento','G+/N+')
         Say( f1+5,c1+14,'Sexo','G+/N+')
         Say( f1+6,c1+14,'Acta','G+/N+')
         Say( f1+7,c1+14,'Tipo','G+/N+')
         Say( f1+8,c1+10,'Impuesto','G+/N+')
         Say( f1+9,c1+8,'Inhumaciขn','G+/N+')
         Say(f1+10,c1+12,'Boleto','G+/N+')
         Say(f1+11,c1+5,'Tipo Servicio','G+/N+')
         Say(f1+12,c1+10,'Cocheria','G+/N+')
         Say(f1+13,c1+6,'Denominaciขn','G+/N+')
         Say(f1+14,c1+8,'Exhumaciขn','G+/N+')
         Say( f1+1,c1+19,AllTrim(Transform(Matriz1[xNumero,1],'@!')),'W+/N+')
         Say( f1+2,c1+19,AllTrim(Transform(Matriz1[xNumero,2],'@!')),'W+/N+')
         Say( f1+3,c1+19,AllTrim(Transform(Matriz1[xNumero,3],'@!')),'W+/N+')
         Say( f1+4,c1+19,AllTrim(Transform(Matriz1[xNumero,4],'@!')),'W+/N+')
         Say( f1+5,c1+19,If(Upper(Matriz1[xNumero,5])='M','Masculino','Femenino'),'W+/N+')
         Say( f1+6,c1+19,AllTrim(Transform(Matriz1[xNumero,6],'@!')),'W+/N+')
         Say( f1+7,c1+19,If(Matriz1[xNumero,7]='P','Particular',If(Matriz1[xNumero,7]='S','Socio','  ')),'W+/N+')
         Say( f1+8,c1+19,AllTrim(Transform(Matriz1[xNumero,8],'@!')),'W+/N+')
         Say( f1+9,c1+19,AllTrim(Transform(Matriz1[xNumero,9],'@!')),'W+/N+')
         Say(f1+10,c1+19,AllTrim(Transform(Matriz1[xNumero,10],'@!')),'W+/N+')
         Say(f1+11,c1+19,If(Matriz1[xNumero,11]='T','Traslado',If(Matriz1[xNumero,11]='S','Sepelio','  ')),'W+/N+')
         xCodCoche:=Matriz1[xNumero,12]
         If Cocheria->(DbSeek(xCodCoche))
             Say(f1+12,c1+19,Transform(Cocheria->Nombre,'@!'),'W+/N+')
         EndIf
         xCodAtaud:=Matriz1[xNumero,13]
         If Ataud->(DbSeek(xCodAtaud))
            Say(f1+13,c1+19,Transform(Ataud->Descripcio,'@!'),'W+/N+')
         EndIf
         Say( f1+14,c1+19,AllTrim(Transform(Matriz1[xNumero,14],'@!')),'W+/N+')
         Inkey(0)
         xTecla:=LastKey()
         If xTecla=5
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If --f1<0
                 f1=0
            EndIf
            If --f2<13
                 f2=13
            EndIf
            RestScreen(0,0,24,79,Scr1)
            *RestScreen(f1,c1,f2,c2,Scr2)
         ElseIf xTecla=24
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If ++f1>11
                 f1=11
            EndIf
            If ++f2>24
                 f2=24
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=19
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If --c1<0
                 c1=0
            EndIf
            If --c2<47
                 c2=47
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=4
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If ++c1>32
                 c1=32
            EndIf
            If ++c2>79
                 c2=79
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=27
            Exit
         EndIf
     EndDo
     RestScreen(0,0,24,79,Scr1)
  Else
     Exit
  EndIf
EndDo
RestScreen(15,0,24,79,Scr)
SetKey( -1,{|| FunFede1()})
Return ""

Function FunFede2
Local Scr:=SaveScreen(15,0,24,79),Scr1
Local w1,q1,w2,q2
Local xCodAtaud:=xCodCoche:=0
Private xElementoIn:=1
SetKey( -2,{|| Nil })
BoxFede(15,0,23,79,Nil,.f.)
Say(15,3,'Sn',MonCol)
Say(15,8,'Nombre',MonCol)
Say(15,30,'Fallecimiento',MonCol)
Say(15,44,'Documento',MonCol)
Say(15,54,'Sexo',MonCol)
Say(15,59,'Tipo',MonCol)
Say(15,67,'Inhumaciขn',MonCol)
Say(23,4,' Nivel 2 ',MonCol)
While .t.
  xNumero:=Achoice(16,2,23,77,Vec2,,"FunUsuario",xElementoIn)
  xElementoIn:=xNumero
  If LastKey()=13
     Scr1:=SaveScreen(0,0,24,79)
     w1:=9
     q1:=30
     w2:=23
     q2:=73
     While .t.
         oscureze(w1,q1+4,w2,q2)
         Say(   w1,q1+5,'Datos Completos del Nivel 2','RB+/N+')
         Say( w1+1,q1+10,'SubNivel','G+/N+')
         Say( w1+2,q1+5,'Fallecimiento','G+/N+')
         Say( w1+3,q1+12,'Nombre','G+/N+')
         Say( w1+4,q1+9,'Documento','G+/N+')
         Say( w1+5,q1+14,'Sexo','G+/N+')
         Say( w1+6,q1+14,'Acta','G+/N+')
         Say( w1+7,q1+14,'Tipo','G+/N+')
         Say( w1+8,q1+10,'Impuesto','G+/N+')
         Say( w1+9,q1+8,'Inhumaciขn','G+/N+')
         Say(w1+10,q1+12,'Boleto','G+/N+')
         Say(w1+11,q1+5,'Tipo Servicio','G+/N+')
         Say(w1+12,q1+10,'Cocheria','G+/N+')
         Say(w1+13,q1+6,'Denominaciขn','G+/N+')
         Say(w1+14,q1+8,'Exhumaciขn','G+/N+')
         Say( w1+1,q1+19,AllTrim(Transform(Matriz2[xNumero,1],'@!')),'W+/N+')
         Say( w1+2,q1+19,AllTrim(Transform(Matriz2[xNumero,2],'@!')),'W+/N+')
         Say( w1+3,q1+19,AllTrim(Transform(Matriz2[xNumero,3],'@!')),'W+/N+')
         Say( w1+4,q1+19,AllTrim(Transform(Matriz2[xNumero,4],'@!')),'W+/N+')
         Say( w1+5,q1+19,If(Upper(Matriz2[xNumero,5])='M','Masculino','Femenino'),'W+/N+')
         Say( w1+6,q1+19,AllTrim(Transform(Matriz2[xNumero,6],'@!')),'W+/N+')
         Say( w1+7,q1+19,If(Matriz2[xNumero,7]='P','Particular',If(Matriz2[xNumero,7]='S','Socio','  ')),'W+/N+')
         Say( w1+8,q1+19,AllTrim(Transform(Matriz2[xNumero,8],'@!')),'W+/N+')
         Say( w1+9,q1+19,AllTrim(Transform(Matriz2[xNumero,9],'@!')),'W+/N+')
         Say(w1+10,q1+19,AllTrim(Transform(Matriz2[xNumero,10],'@!')),'W+/N+')
         Say(w1+11,q1+19,If(Matriz2[xNumero,11]='T','Traslado',If(Matriz2[xNumero,11]='S','Sepelio','  ')),'W+/N+')
         xCodCoche:=Matriz2[xNumero,12]
         If Cocheria->(DbSeek(xCodCoche))
             Say(w1+12,q1+19,Transform(Cocheria->Nombre,'@!'),'W+/N+')
         EndIf
         xCodAtaud:=Matriz2[xNumero,13]
         If Ataud->(DbSeek(xCodAtaud))
            Say(w1+13,q1+19,Transform(Ataud->Descripcio,'@!'),'W+/N+')
         EndIf
         Say( w1+14,q1+19,AllTrim(Transform(Matriz2[xNumero,14],'@!')),'W+/N+')
         Inkey(0)
         xTecla:=LastKey()
         If xTecla=5
            Scr2:=SaveScreen(w1,q1,w2,q2)
            If --w1<0
                 w1=0
            EndIf
            If --w2<13
                 w2=13
            EndIf
            RestScreen(0,0,24,79,Scr1)
            *RestScreen(f1,c1,f2,c2,Scr2)
         ElseIf xTecla=24
            Scr2:=SaveScreen(w1,q1,w2,q2)
            If ++w1>11
                 w1=11
            EndIf
            If ++w2>24
                 w2=24
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=19
            Scr2:=SaveScreen(w1,q1,w2,q2)

            If --q1<0
                 q1=0
            EndIf
            If --q2<47
                 q2=47
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=4
            Scr2:=SaveScreen(w1,q1,w2,q2)

            If ++q1>32
                 q1=32
            EndIf
            If ++q2>79
                 q2=79
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=27
            Exit
         EndIf
     EndDo
     RestScreen(0,0,24,79,Scr1)
  Else
     Exit
  EndIf
EndDo
RestScreen(15,0,24,79,Scr)
SetKey( -2,{|| FunFede2()})
Return ""

Function FunFede3
Local Scr:=SaveScreen(15,0,24,79),Scr1
Local f1,c1,f2,c2
Local xCodAtaud:=xCodCoche:=0
Private xElementoIn:=1
SetKey( -3,{|| Nil })
BoxFede(15,0,23,79,Nil,.f.)
Say(15,3,'Sn',MonCol)
Say(15,8,'Nombre',MonCol)
Say(15,30,'Fallecimiento',MonCol)
Say(15,44,'Documento',MonCol)
Say(15,54,'Sexo',MonCol)
Say(15,59,'Tipo',MonCol)
Say(15,67,'Inhumaciขn',MonCol)
Say(23,4,' Nivel 3 ',MonCol)
While .t.
  xNumero:=Achoice(16,2,23,77,Vec3,,"FunUsuario",xElementoIn)
  xElementoIn:=xNumero
  If LastKey()=13
     Scr1:=SaveScreen(0,0,24,79)
     f1:=9
     c1:=30
     f2:=23
     c2:=73
     While .t.
         oscureze(f1,c1+4,f2,c2)
         Say( f1,c1+5,'Datos Completos del Nivel 3','RB+/N+')
         Say( f1+1,c1+10,'SubNivel','G+/N+')
         Say( f1+2,c1+5,'Fallecimiento','G+/N+')
         Say( f1+3,c1+12,'Nombre','G+/N+')
         Say( f1+4,c1+9,'Documento','G+/N+')
         Say( f1+5,c1+14,'Sexo','G+/N+')
         Say( f1+6,c1+14,'Acta','G+/N+')
         Say( f1+7,c1+14,'Tipo','G+/N+')
         Say( f1+8,c1+10,'Impuesto','G+/N+')
         Say( f1+9,c1+8,'Inhumaciขn','G+/N+')
         Say(f1+10,c1+12,'Boleto','G+/N+')
         Say(f1+11,c1+5,'Tipo Servicio','G+/N+')
         Say(f1+12,c1+10,'Cocheria','G+/N+')
         Say(f1+13,c1+6,'Denominaciขn','G+/N+')
         Say(f1+14,c1+8,'Exhumaciขn','G+/N+')
         Say( f1+1,c1+19,AllTrim(Transform(Matriz3[xNumero,1],'@!')),'W+/N+')
         Say( f1+2,c1+19,AllTrim(Transform(Matriz3[xNumero,2],'@!')),'W+/N+')
         Say( f1+3,c1+19,AllTrim(Transform(Matriz3[xNumero,3],'@!')),'W+/N+')
         Say( f1+4,c1+19,AllTrim(Transform(Matriz3[xNumero,4],'@!')),'W+/N+')
         Say( f1+5,c1+19,If(Matriz3[xNumero,5]='M','Masculino','Femenino'),'W+/N+')
         Say( f1+6,c1+19,AllTrim(Transform(Matriz3[xNumero,6],'@!')),'W+/N+')
         Say( f1+7,c1+19,If(Matriz3[xNumero,7]='P','Particular',If(Matriz3[xNumero,7]='S','Socio','  ')),'W+/N+')
         Say( f1+8,c1+19,AllTrim(Transform(Matriz3[xNumero,8],'@!')),'W+/N+')
         Say( f1+9,c1+19,AllTrim(Transform(Matriz3[xNumero,9],'@!')),'W+/N+')
         Say(f1+10,c1+19,AllTrim(Transform(Matriz3[xNumero,10],'@!')),'W+/N+')
         Say(f1+11,c1+19,If(Matriz3[xNumero,11]='T','Traslado',If(Matriz3[xNumero,11]='S','Sepelio','  ')),'W+/N+')

         xCodCoche:=Matriz3[xNumero,12]
         If Cocheria->(DbSeek(xCodCoche))
             Say(f1+12,c1+19,Transform(Cocheria->Nombre,'@!'),'W+/N+')
         EndIf

         xCodAtaud:=Matriz3[xNumero,13]
         If Ataud->(DbSeek(xCodAtaud))
            Say(f1+13,c1+19,Transform(Ataud->Descripcio,'@!'),'W+/N+')
         EndIf
         Say( f1+14,c1+19,AllTrim(Transform(Matriz3[xNumero,14],'@!')),'W+/N+')
         Inkey(0)
         xTecla:=LastKey()
         If xTecla=5
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If --f1<0
                 f1=0
            EndIf
            If --f2<13
                 f2=13
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=24
            Scr2:=SaveScreen(f1,c1,f2,c2)
            If ++f1>11
                 f1=11
            EndIf
            If ++f2>24
                 f2=24
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=19
            Scr2:=SaveScreen(f1,c1,f2,c2)

            If --c1<0
                 c1=0
            EndIf
            If --c2<47
                 c2=47
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=4
            Scr2:=SaveScreen(f1,c1,f2,c2)

            If ++c1>32
                 c1=32
            EndIf
            If ++c2>79
                 c2=79
            EndIf
            RestScreen(0,0,24,79,Scr1)
         ElseIf xTecla=27
            Exit
         EndIf
     EndDo
     RestScreen(0,0,24,79,Scr1)
  Else
     Exit
  EndIf
EndDo
RestScreen(15,0,24,79,Scr)
SetKey( -3,{|| FunFede3()})
Return ""

Function FunUsuario( nModo , b , c )
Local tecla:=LastKey()
Local ValRet:=2
**xElementoIn:=c
Do Case
   Case nModo==3
        Do Case
           Case tecla==13
                ValRet:=1
           Case tecla=8
                ValRet:=1
           Case tecla==27
                ValRet:=0
           Case tecla==19
                ValRet:=2
           Case tecla==4
                ValRet:=2
           Case tecla==5
                ValRet:=2
           Case tecla==24
                ValRet:=2
           Case tecla>32 .And. tecla<=255
                ValRet:=3
           Case tecla= -1
                ValRet:=1
        EndCase
EndCase
Return ValRet

Function BuscaNivel(xCodigo)
Local Arr:={' ษออออออออ Nivel 1 อออออออหออออออออ Nivel 2 อออออออออหอออออออ Nivel 3 ออออออออป ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' บ                        บ                          บ                        บ ',;
            ' ศออออออออออออออออออออออออสออออออออออออออออออออออออออสออออออออออออออออออออออออผ '}
Local Li1:=16
Local Li2:=16
Local Li3:=16
BoxFede(15,0,23,78)
WinShowR(Arr,15,0,'D')
Say(23,4,' < F2 > ',MonCol)
Say(23,29,' < F3 > ',MonCol)
Say(23,56,' < F4 > ',MonCol)
If DbSeek(xCodigo)
   While .t.
      If Nivel=1
         @li1,3 Say Subnivel Pict '9'
         @li1++,5 Say Nombre Pict '@S20!'
         AADD(Vec1,' '+Str(SubNivel,1)+'  '+PadR(Nombre,25)+' '+DtoC(Fecha)+'  '+Documento+;
                       '   '+Sexo+'    '+Tipo+'      '+DtoC(Fechai))
         xSubNivel:=SubNivel
         Matriz1[xSubNivel,1]:=SubNivel
         Matriz1[xSubNivel,2]:=Fecha
         Matriz1[xSubNivel,3]:=Nombre
         Matriz1[xSubNivel,4]:=Documento
         Matriz1[xSubNivel,5]:=Sexo
         Matriz1[xSubNivel,6]:=Acta
         Matriz1[xSubNivel,7]:=Tipo
         Matriz1[xSubNivel,8]:=Impuesto
         Matriz1[xSubNivel,9]:=FechaI
         Matriz1[xSubNivel,10]:=Boleto
         Matriz1[xSubNivel,11]:=TipoI
         Matriz1[xSubNivel,12]:=Cocheria
         Matriz1[xSubNivel,13]:=Feretro
         Matriz1[xSubNivel,14]:=FechaExuma
      ElseIf Nivel=2
         @li2,28 Say Subnivel Pict '9'
         @li2++,30 Say Nombre Pict '@S20!'
         AADD(Vec2,' '+Str(SubNivel,1)+'  '+PadR(Nombre,25)+' '+DtoC(Fecha)+'  '+Documento+;
                       '   '+Sexo+'    '+Tipo+'      '+DtoC(Fechai))
         xSubNivel:=SubNivel
         Matriz2[xSubNivel,1]:=SubNivel
         Matriz2[xSubNivel,2]:=Fecha
         Matriz2[xSubNivel,3]:=Nombre
         Matriz2[xSubNivel,4]:=Documento
         Matriz2[xSubNivel,5]:=Sexo
         Matriz2[xSubNivel,6]:=Acta
         Matriz2[xSubNivel,7]:=Tipo
         Matriz2[xSubNivel,8]:=Impuesto
         Matriz2[xSubNivel,9]:=FechaI
         Matriz2[xSubNivel,10]:=Boleto
         Matriz2[xSubNivel,11]:=TipoI
         Matriz2[xSubNivel,12]:=Cocheria
         Matriz2[xSubNivel,13]:=Feretro
         Matriz2[xSubNivel,14]:=FechaExuma
      ElseIf Nivel=3
         @li3,55 Say Subnivel Pict '9'
         @li3++,57 Say Nombre Pict '@S20!'
         AADD(Vec3,' '+Str(SubNivel,1)+'  '+PadR(Nombre,25)+' '+DtoC(Fecha)+'  '+Documento+;
                       '   '+Sexo+'    '+Tipo+'      '+DtoC(Fechai))
         xSubNivel:=SubNivel
         Matriz3[xSubNivel,1]:=SubNivel
         Matriz3[xSubNivel,2]:=Fecha
         Matriz3[xSubNivel,3]:=Nombre
         Matriz3[xSubNivel,4]:=Documento
         Matriz3[xSubNivel,5]:=Sexo
         Matriz3[xSubNivel,6]:=Acta
         Matriz3[xSubNivel,7]:=Tipo
         Matriz3[xSubNivel,8]:=Impuesto
         Matriz3[xSubNivel,9]:=FechaI
         Matriz3[xSubNivel,10]:=Boleto
         Matriz3[xSubNivel,11]:=TipoI
         Matriz3[xSubNivel,12]:=Cocheria
         Matriz3[xSubNivel,13]:=Feretro
         Matriz3[xSubNivel,14]:=FechaExuma
      EndIf
      DbSkip()
      If Eof() .Or. Codigo != xCodigo
         Exit
      EndIf
   End
EndIf
Return Nil

Function Parcelas
*-Objetivo : Consuta de Titulares y Suplentes de Parcelas
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป ',;
            ' บ Cขdigo  :            Sector :      Fila    :         Parcela :            บ ',;
            ' บ Reserva :            Tipo   :      Ultimo Pago  :                         บ ',;
            ' ฬอออออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออออออออออออน ',;
            ' บ    Nombre :                         ณ    Nombre :                         บ ',;
            ' บ Domicilio :                         ณ Domicilio :                         บ ',;
            ' บ    Barrio :                         ณ    Barrio :                         บ ',;
            ' บ Localidad :                         ณ Localidad :                         บ ',;
            ' บ Provincia :                         ณ Provincia :                         บ ',;
            ' บ  C/Postal :                         ณ  C/Postal :                         บ ',;
            ' บ Documento :                         ณ Documento :                         บ ',;
            ' บ  Telefono :                         ณ  Telefono :                         บ ',;
            ' ฬอออออออออออออออออออออออออออออออออออออุอออออออออออออออออออออออออออออออออออออน ',;
            ' บ    Nombre :                         ณ    Nombre :                         บ ',;
            ' บ Domicilio :                         ณ Domicilio :                         บ ',;
            ' บ    Barrio :                         ณ    Barrio :                         บ ',;
            ' บ Localidad :                         ณ Localidad :                         บ ',;
            ' บ Provincia :                         ณ Provincia :                         บ ',;
            ' บ  C/Postal :                         ณ  C/Postal :                         บ ',;
            ' บ Documento :                         ณ Documento :                         บ ',;
            ' บ  Telefono :                         ณ  Telefono :                         บ ',;
            ' ศอออออออออออออออออออออออออออออออออออออฯอออออออออออออออออออออออออออออออออออออผ '}
Private xCodigo:=Space(7)
SetColor('W+/B+')
BoxFede(2,0,23,78)
WinShowR(Arr,2,0,'I')
Say(23,52,' Consulta de Parcelas ',MonCol)
While .t.
   SetColor('W+/B+')
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,2,'!!!!!!!',2,1)})
   @3,13 Get xCodigo Pict '!!!!!!!' Color MonCol
   ReadOn()
   SetKey( -9,{|| Nil })
   If LastKey() = 27
      Exit
   EndIf
   If LastKey()=18
      DbSkip(-1)
      If Bof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   If LastKey()=3
      DbSkip(1)
      If Eof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   DbSetOrder(2)
   If DbSeek(xCodigo)
       WinShowR(Arr,2,0,'I')
       Say(2,42,' Consulta de Parcelas ',MonCol)
       Say(3,13,PadC(AllTrim(Codigo),7),'GR+/B+')
       Say(3,33,PadC(AllTrim(Sector),3),'BG+/B+')
       Say(3,48,Str(Fila,2),'BG+/B+')
       Say(3,66,Str(Parcela,2),'BG+/B+')
       Say(4,13,Str(Reserva,6),'BG+/B+')
       Say(4,33,AllTrim(Tipo_p_s),'BG+/B+')
*       Say(4,53,Str(Ult_mes,2)+'/'+Str(Ult_ano,2),'BG+/B+')
*           ===================
       Say(6,15,PadR(AllTrim(Nombre),23),'G+/B+')
*       Say(6,53,PadR(AllTrim(Titular),23),'G+/B+')
       Say(7,15,PadR(AllTrim(Domicilio),23),'G+/B+')
*       Say(7,53,PadR(AllTrim(Domicilioa),23),'G+/B+')
       Say(8,15,PadR(AllTrim(Barrio),23),'G+/B+')
*       Say(8,53,PadR(AllTrim(Barrioa),23),'G+/B+')
       Say(9,15,PadR(AllTrim(Localidad),23),'G+/B+')
*       Say(9,53,PadR(AllTrim(Localidada),23),'G+/B+')
       Say(10,15,Str(Provincia,3),'G+/B+')
*       Say(10,53,Str(Provinciaa,3),'G+/B+')
       Say(11,15,Str(Cpostal,4),'G+/B+')
*       Say(11,53,Str(Cpostala,4),'G+/B+')
       Say(12,15,Str(Documento,8),'G+/B+')
*       Say(12,53,Str(Documentoa,8),'G+/B+')
       Say(13,15,PadR(AllTrim(Telefono),23),'G+/B+')
*       Say(13,53,PadR(AllTrim(Telefonoa),23),'G+/B+')
*          =======================
*       Say(15,15,PadR(AllTrim(Titularb),23),'G+/B+')
*       Say(15,53,PadR(AllTrim(Titularc),23),'G+/B+')
*       Say(16,15,PadR(AllTrim(Domiciliob),23),'G+/B+')
*       Say(16,53,PadR(AllTrim(Domicilioc),23),'G+/B+')
*       Say(17,15,PadR(AllTrim(Barriob),23),'G+/B+')
*       Say(17,53,PadR(AllTrim(Barrioc),23),'G+/B+')
*       Say(18,15,PadR(AllTrim(Localidadb),23),'G+/B+')
*       Say(18,53,PadR(AllTrim(Localidadc),23),'G+/B+')
*       Say(19,15,Str(Provinciab,3),'G+/B+')
*       Say(19,53,Str(Provinciac,3),'G+/B+')
*       Say(20,15,Str(Cpostalb,4),'G+/B+')
*       Say(20,53,Str(Cpostalc,4),'G+/B+')
*       Say(21,15,Str(Documentob,8),'G+/B+')
*       Say(21,53,Str(Documentoc,8),'G+/B+')
*       Say(22,15,PadR(AllTrim(Telefonob),23),'G+/B+')
*       Say(22,53,PadR(AllTrim(Telefonoc),23),'G+/B+')
   Else
      MueveLet('ERROR !!!. El Cขdigo Ingresado es ERRONEO.')
   EndIf
   DbSetOrder(1)
EndDo
_SBoxDS(2,0,23,78,Scr1)
Return Nil

Function Reservas
*-Objetivo : Consuta de Reservas y Estado de Cuenta
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษอออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออป ',;
            ' บ Reserva :                         ณ      Mutual :             บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด    Cobrador :             บ ',;
            ' บ        Apellido y Nombre          ณ    Promotor :             บ ',;
            ' บ                                   ณ        Alta :             บ ',;
            ' บ            Domicilio              ณ Alta Mutual :             บ ',;
            ' บ                                   ณ        Tipo :             บ ',;
            ' บ             Barrio                ณ                           บ ',;
            ' บ                                   ณ  ฺฤฤฤฤ Crdito ฤฤฤฤฤฟ     บ ',;
            ' บ            Telefono               ณ  ณ                  ณ     บ ',;
            ' บ                                   ณ  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู     บ ',;
            ' วฤฤฤฤ Baja ฤฤฤฤยฤฤ Cขdigo de Baja ฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ              ณ                                                บ ',;
            ' ศออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออผ '}
Private xReserva := 0
Private Vec:={}
Private Vuc:={}
SetColor('W+/B+')
BoxFede(2,2,15,68)
WinShowR(Arr,2,2,'B')
Say(15,42,' Consulta de Reservas ',MonCol)
Scr1:=SaveScreen(0,0,24,79)
While .t.
   SetColor('W+/B+')
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
   SetKey( -1,{|| FunDaniel()})
   SetKey( -2,{|| FunPato()})
   SetKey( -4,{|| FunDeuda()})
   @3,15 Get xReserva Pict '999999' Color MonCol
   ReadOn()
   SetKey( -4,{|| Nil })
   SetKey( -2,{|| Nil })
   SetKey( -1,{|| Nil })
   SetKey( -9,{|| Nil })
   If LastKey() = 27
      Exit
   EndIf
   If LastKey()=18
      DbSkip(-1)
      If Bof()
         Tone(300,3)
         Loop
      EndIf
      xReserva:=Reserva
   EndIf
   If LastKey()=3
      DbSkip(1)
      If Eof()
         Tone(300,3)
         Loop
      EndIf
      xReserva:=Reserva
   EndIf
   Auxiliar->(__DbZap())
   Vec:={}
   If DbSeek(xReserva)
      RestScreen(0,0,24,79,Scr1)
      WinShowR(Arr,2,2,'B')
      Say(15,42,' Consulta de Reservas ',MonCol)
      Say(12,47,' < F5 > ',MonCol)
      Say(3,15,Str(Reserva,6),'GR+/B+')
      Say(3,55,Str(Mutual,6),'BG+/B+')
      Say(4,55,Str(Cobrador,6),'BG+/B+')
      Say(5,55,Str(Promotor,6),'BG+/B+')
      Say(6,4,PadC(AllTrim(Nombre),34),'RB+/B+')
      Say(6,55,Alta,'BG+/B+')
      Say(7,55,AltaMut,'BG+/B+')
      Say(8,4,PadC(AllTrim(Domicilio),34),'BG+/B+')
      Say(8,55,If(Tipo='P','Particular',If(Tipo='S','Socio','Especial')),'BG+/B+')
      Say(10,4,PadC(AllTrim(Barrio),34),'BG+/B+')
      Say(11,47,Str(Credito,10,2),'G+/B+')
      Say(12,4,PadC(AllTrim(Telefono),34),'BG+/B+')
      If !Empty(Baja)
         Say(14,6,Baja,'R+/B+')
      EndIf
      xBaja:=CodBaja
      If Baja->(DbSeek(xBaja))
         Say(14,20,AllTrim(Baja->Descripcio),'R+/B+')
      EndIf
      ParqueNu->(BuscaParque(xReserva))
      Recibo->(BuscaDatos(xReserva))
      CtaCte->(BuscaRecibo(xReserva))
   Else
      MueveLet('ERROR !!!. El Cขdigo Ingresado es ERRONEO.')
   EndIf
EndDo
_SBoxDS(2,1,15,68,Scr1)
Return Nil

Function FunDaniel
Local Scr:=SaveScreen(07,0,24,79)
Local Arr:={' ษอออออัออออออออออัออออออออออัออออออออัออออออออออัอออออออออออัอออออออออออออป ',;
            ' บCuotaณ  Vence   ณ   Pagข   ณSucursalณ  Recibo  ณ   Saldo   ณ   Importe   บ ',;
            ' ฬอออออุออออออออออุออออออออออุออออออออุออออออออออุอออออออออออุอออออออออออออน ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' ศอออออฯออออออออออฯออออออออออฯออออออออฯออออออออ Monto  Adeudado อออออออออออผ '}
SetKey( -1,{|| Nil})
SetKey( -2,{|| Nil})
SetKey( -9,{|| Nil})
BoxFede(07,2,23,78)
WinShowR(Arr,07,2,'B')
Say(23,6,' Vista de Cuotas ',MonCol)
Achoice(10,4,22,76,Vec,.t.,.t.,.t.,.t.)
RestScreen(07,0,24,79,Scr)
SetKey( -1,{|| FunDaniel()})
SetKey( -2,{|| FunPato()})
SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
Return ""

Function FunPato
Local Scr:=SaveScreen(07,0,24,79)
Local Arr:={' ษอออออัออออออออออัออออออออออัออออออออัออออออออออัอออออออออออัอออออออออออออป ',;
            ' บCuotaณ  Vence   ณ   Pagข   ณSucursalณ  Recibo  ณBonificaci.ณ   Importe   บ ',;
            ' ฬอออออุออออออออออุออออออออออุออออออออุออออออออออุอออออออออออุอออออออออออออน ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' ศอออออฯออออออออออฯออออออออออฯออออออออฯออออออออ Monto  Adeudado อออออออออออผ '}
SetKey( -1,{|| Nil})
SetKey( -2,{|| Nil})
SetKey( -9,{|| Nil})
BoxFede(07,2,23,78)
WinShowR(Arr,07,2,'B')
Say(23,6,' Vista de Pagos ',MonCol)
Achoice(10,4,22,76,Vuc,.t.,.t.,.t.,.t.)
RestScreen(07,0,24,79,Scr)
SetKey( -1,{|| FunDaniel()})
SetKey( -2,{|| FunPato()})
SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
Return ""


Function FunDeuda
Local Scr:=SaveScreen(0,0,24,79)
Local BeforArea:=Select()
Local t:=0
Sele Auxiliar
SetKey( -4,{|| Nil})
DbGoTop()
oscurece(12+t,43,12+t,60)
Say(12+t,45,' Plan de Pago','BG+/N+')
While !Eof()
   t++
   oscurece(12+t,43,12+t,60)
   Say(12+t,45,'๛','R+/N+')
   Say(12+t,47,AllTrim(Str(Cantidad,6))+' x '+AllTrim(Str(Importe,10,2)),'B+/N+')
   DbSkip()
EndDo
Inkey(0)
RestScreen(0,0,24,79,Scr)
SetKey( -4,{|| FunDeuda()})
DbSelectArea(BeforArea)
Return ""

Function BuscaDatos(xReserva)
Local xOrd:=DbSetOrder()
Local cOrd:=CtaCte->(DbSetOrder())
Local xFecha:=CtoD('  /  /    '),xSucursal:=xRecibo:=xBonificaci:=xImporte:=0
Local xSuma:=0
Local xCuota:=1
Local xValorRec:=0
Vuc:={}
Say(23,26,' < F3 > Recibos ',MonCol)
CtaCte->(DbSetOrder(2))
DbSetOrder(2)
DbSeek(xReserva)
While Reserva=xReserva .And. !Eof()
   If CtaCte->(DbSeek(StrZero(xReserva,6)+StrZero(xCuota,4)))
       xValorRec+=(Importe+Bonificaci)
       xValorCta:=CtaCte->Importe
       If xValorRec >= xValorCta
          VerActiva()
          Replace Cuota With xCuota
          DbUnLock()
          CtaCte->(VerActiva())
          Replace CtaCte->Saldo With 0
          CtaCte->(DbUnLock())
          xCuota++
          xValorRec:=0
       Else
          VerActiva()
          Replace Cuota With xCuota
          DbUnLock()
          CtaCte->(VerActiva())
          Replace CtaCte->Saldo With (CtaCte->Importe)-xValorRec
          CtaCte->(DbUnLock())
       EndIf
   Else
      MueveLet('Problemas con la cuota '+Str(xCuota,4))
   EndIf
   DbSkip()
EndDo
DbSeek(StrZero(xReserva,6)+StrZero(0,4),.t.)
While Reserva=xReserva .And. !Eof()
   xFecha:=CtoD('  /  /    ')
   xSucursal:=xRecibo:=0
   xFecha:=Fecha
   xSucursal:=Sucursal
   xRecibo:=Recibo
   xBonificaci+=Bonificaci
   xImporte+=Importe
   AADD(Vuc,Str(Cuota,4)+' ณ'+Space(10)+'ณ'+If(Empty(xFecha),Spac(10),Transform(xFecha,'@D'));
          +'ณ  '+If(xSucursal=0,Spac(4),Transform(xSucursal,'9999'))+'  ณ '+;
          If(xRecibo=0,Spac(8),Transform(xRecibo,'99999999'))+' ณ'+;
          If(xBonificaci=0,Spac(10),Transform(xBonificaci,'9999999.99'))+' ณ '+Transform(Importe,'9999999.99'))
   DbSkip()
EndDo
DbSetOrder(xOrd)
CtaCte->(DbSetOrder(cOrd))
Return Nil

Function BuscaRecibo(xReserva)
Local Arr:={' ษอออออัออออออออออัออออออออออัออออออออัออออออออออัอออออออออออัอออออออออออออป ',;
            ' บCuotaณ  Vence   ณ   Pagข   ณSucursalณ  Recibo  ณ   Saldo   ณ   Importe   บ ',;
            ' ฬอออออุออออออออออุออออออออออุออออออออุออออออออออุอออออออออออุอออออออออออออน ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' บ     ณ          ณ          ณ        ณ          ณ           ณ             บ ',;
            ' ศอออออฯออออออออออฯออออออออออฯออออออออฯออออออออ Monto  Adeudado อออออออออออผ '}
Local Li:=20
Local xCuota:=0
Local xFecha:=CtoD('  /  /    '),xSucursal:=xRecibo:=xBonificaci:=0
Local xSuma:=0
Local cOrd:=DbSetOrder()
Local xOrd:=Recibo->(DbSetOrder())
Recibo->(DbSetOrder(1))
DbSetOrder(1)
BoxFede(17,2,23,78)
WinShowR(Arr,17,2,'B')
Say(23,6,' < F2 > Cuotas ',MonCol)
Vec:={}
If DbSeek(xReserva)
   While .t.
      Say(Li,4,Str(Cuota,4),'BG+/B+')
      Say(Li,9,'ณ','W+/B+')
      xCuota:=Cuota
      Say(Li,10,Transform(Vencimient,'@D'),'BG+/B+')
      Say(Li,20,'ณ','W+/B+')
      Say(Li,31,'ณ','W+/B+')
      Say(Li,40,'ณ','W+/B+')
      Say(Li,51,'ณ','W+/B+')
      xFecha:=CtoD('  /  /    ')
      xSucursal:=xRecibo:=xBonificaci:=0
      //If Vencimient <= Date()
         xSuma+=Saldo
      //EndIf
      If Recibo->(DbSeek(StrZero(xReserva,6)+StrZero(xCuota,4)))
          Say(Li,21,Transform(Recibo->Fecha,'@D'),'BG+/B+')
          Say(Li,34,Transform(Recibo->Sucursal,'9999'),'BG+/B+')
          Say(Li,42,Transform(Recibo->Recibo,'99999999'),'BG+/B+')
               xFecha:=Recibo->Fecha
            xSucursal:=Recibo->Sucursal
              xRecibo:=Recibo->Recibo
      EndIf
      xBonificaci:=Saldo
      Say(Li,52,Transform(Saldo,'9999999.99'),'BG+/B+')
      Say(Li,63,'ณ','W+/B+')
      xImporte:=Importe
      If Auxiliar->(DbSeek(xImporte))
         Replace Auxiliar->Cantidad With Auxiliar->Cantidad+1
      Else
         Auxiliar->(DbAppend())
         Replace Auxiliar->Importe  With xImporte
         Replace Auxiliar->Cantidad With 1
      EndIf
      Say(Li,65,Transform(Importe,'9999999.99'),'BG+/B+')
      Say(23,65,Transform(xSuma,'9999999.99'),'R+/B+')
      AADD(Vec,Str(Cuota,4)+' ณ'+Transform(Vencimient,'@D')+'ณ'+If(Empty(xFecha),Spac(10),Transform(xFecha,'@D'));
               +'ณ  '+If(xSucursal=0,Spac(4),Transform(xSucursal,'9999'))+'  ณ '+;
               If(xRecibo=0,Spac(8),Transform(xRecibo,'99999999'))+' ณ'+;
               Transform(xBonificaci,'9999999.99')+' ณ '+Transform(Importe,'9999999.99'))
      DbSkip()
      If Eof() .Or. Reserva != xReserva
        Exit
      EndIf
      If ++Li > 22
         Li:=22
         Scroll(20,4,22,76,1)
      EndIf
   End
EndIf
Recibo->(DbSetOrder(xOrd))
DbSetOrder(cOrd)
Return Nil

Function BuscaParque(xReserva)
If DbSeek(xReserva)
   BoxFede(7,65,14,78)
   Say(7,68,'PARCELAS','R+/B+')
   t:=1
   While .t.
      Say(7+(t++),68,AllTrim(Codigo),'Gr+/B+')
      DbSkip()
      If Eof() .Or. Reserva!=xReserva
         Exit
      EndIf
   EndDo
EndIf
Return Nil

Function CuotaExpensa
*-Objetivo : Consuta de Cuotas y Expensas
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออป ',;
            ' บ Cขdigo :                         ณ      Sector :             บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด        Fila :             บ ',;
            ' บ        Apellido y Nombre         ณ     Parcela :             บ ',;
            ' บ                                  ณ     Reserva :             บ ',;
            ' บ            Domicilio             รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ                                  ณ                           บ ',;
            ' บ             Barrio               ณ                           บ ',;
            ' บ                                  ณ                           บ ',;
            ' บ            Telefono              ณ                           บ ',;
            ' บ                                  ณ                           บ ',;
            ' วฤ Documento ฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ             ณ                                                บ ',;
            ' ศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออผ '}
Private xCodigo:=Spac(7),xReserva:=0
Private Vec:={}
SetColor('W+/B+')
BoxFede(2,2,15,67)
WinShowR(Arr,2,2,'B')
Say(15,37,' Consulta Cuotas-Expensas ',MonCol)
While .t.
   SetColor('W+/B+')
   SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'!!!!!!!',2,1)})
   SetKey( -1,{|| FunGustavo()})
   @3,15 Get xCodigo Pict '!!!!!!!' Color MonCol
   ReadOn()
   SetKey( -9,{|| Nil })
   SetKey( -1,{|| Nil })
   If LastKey() = 27
      Exit
   EndIf
   If LastKey()=18
      DbSkip(-1)
      If Bof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   If LastKey()=3
      DbSkip(1)
      If Eof()
         Tone(300,3)
         Loop
      EndIf
      xCodigo:=Codigo
   EndIf
   Vec:={}
   DbSetOrder(2)
   If DbSeek(xCodigo)
      xReserva:=Reserva
      Reserva->(DbSeek(xReserva))
      WinShowR(Arr,2,2,'B')
      Say(15,39,' Consulta Cuotas-Expensas ',MonCol)
      Say(3,15,PadR(AllTrim(Codigo),11),'GR+/B+')
      Say(3,55,PadC(AllTrim(Sector),4),'BG+/B+')
      Say(4,55,Str(Fila,2),'BG+/B+')
      Say(5,55,Str(Parcela,2),'BG+/B+')
      Say(6,4,PadC(Reserva->(AllTrim(Reserva->Nombre)),34),'RB+/B+')
      Say(6,55,Str(Reserva,6),'BG+/B+')
      Say(8,4,PadC(AllTrim(Reserva->Domicilio),34),'BG+/B+')
      Say(10,4,PadC(AllTrim(Reserva->Barrio),34),'BG+/B+')
      Say(12,4,PadC(AllTrim(Reserva->Telefono),34),'BG+/B+')
      Say(14,4,PadC(Str(Documento,8),12),'BG+/B+')
      xReserva:=Reserva
      CtaExp->(DbSetOrder(1))
      CtaExp->(BuscaExpensa(xReserva))
   Else
      MueveLet('ERROR !!!. El Cขdigo Ingresado es ERRONEO.')
   EndIf
EndDo
_SBoxDS(2,1,15,68,Scr1)
Return Nil

Function BuscaExpensa(xReserva)
Local Arr:={' ษอออออออัออออออออออัออออออออออัอออออออออออออัอออออออออออัอออออออออออออป ',;
            ' บ Cuota ณ   Vence  ณ  Pagada  ณ  Recibo     ณBonificaci.ณ   Importe   บ ',;
            ' ฬอออออออุออออออออออุออออออออออุอออออออออออออุอออออออออออุอออออออออออออน ',;
            ' บ       ณ          ณ          ณ             ณ           ณ             บ ',;
            ' บ       ณ          ณ          ณ             ณ           ณ             บ ',;
            ' บ       ณ          ณ          ณ             ณ           ณ             บ ',;
            ' ศอออออออฯออออออออออฯออออออออออฯอออออออออออ Monto Adeudado ออออออออออออผ '}
Local Li:=20
Local xMes:=0
Local xAnio:=0
Local xFecha:=CtoD('  /  /    '),xSucursal:=xRecibo:=xBonificaci:=0
Local xSuma:=0
BoxFede(17,0,23,67)
WinShowR(Arr,17,0,'B')
Say(23,6,' < F2 > ',MonCol)
If DbSeek(xReserva)
   While Reserva=xReserva .And. !Eof()
      xMes:=ParqueNu->Ult_Mes
      xAnio:=ParqueNu->Ult_Ano
      /////Say(Li,4,Str(xMes,2)+'/'+Str(xAnio,2),'BG+/B+')
      Say(Li,4,'ณ','W+/B+')
      Say(Li,9,'ณ','W+/B+')
      Say(Li,20,'ณ','W+/B+')
      Say(Li,31,'ณ','W+/B+')
      Say(Li,45,'ณ','W+/B+')
      Say(Li,57,'ณ','W+/B+')
      /////   xSuma+=Saldo
      xFecha:=CtoD('  /  /    ')
      xSucursal:=xRecibo:=xBonificaci:=0
      Say(Li,2,Transform(Mes,'99'),'BG+/B+')
      Say(Li,5,Transform(Ano,'9999'),'BG+/B+')
      Say(Li,10,Transform(Vence,'@D'),'BG+/B+')
      Say(Li,21,Transform(FechaPago,'@D'),'G+/B+')
      Say(Li,32,Transform(Recibo,'@!'),'BG+/B+')
      Say(Li,46,Transform(Bonifica,'9999999.99'),'BG+/B+')
      Say(Li,58,Transform(Valor,'9999999.99'),'BG+/B+')
      If Pagada='N'
         xSuma+=Valor
      EndIf
      Say(23,58,Transform(xSuma,'9999999.99'),'R+/B+')
      AADD(Vec,StrZero(Mes,2)+'ณ'+Str(Ano,4)+'ณ'+Transform(Vence,'@D')+'ณ'+;
               Transform(FechaPago,'@D')+'ณ'+Recibo+'ณ '+;
               Transform(Bonifica,'9999999.99')+'ณ'+;
               Transform(Valor,'9999999.99'))
      If ++Li > 22
         Li:=22
         Scroll(20,2,22,68,1)
      EndIf
      DbSkip()
   EndDo
EndIf
Return Nil


Function FunGustavo
Local Scr:=SaveScreen(17,0,24,79)
SetKey( -1,{|| Nil })
Achoice(20,2,22,70,Vec,.t.,.t.,.t.,.t.)
RestScreen(17,0,24,79,Scr)
SetKey( -1,{|| FunGustavo()})
Return ""

Function Inhumacion
Private xDesde:=xHasta:=Date()
Private xCantidad:=0
Private xCantExuma:=0
Private xCanSocio:=0
Private xCanOtras:=0
Private xCanParti:=0
Private xNivel1:=0
Private xNivel2:=0
Private xNivel3:=0
Private xSubNivel1:=0
Private xSubNivel2:=0
Private xSubNivel3:=0
Private xCanEspec:=0
Private xCoche1:=0
Private xCoche2:=0
Private xCoche3:=0
Private xCoche4:=0
Private xTipo1S:=0
Private xTipo1T:=0
Private xTipo2S:=0
Private xTipo2T:=0
Private xTipo3T:=0
Private xTipo3S:=0
Private xTipo4T:=0
Private xTipo4S:=0
Private tNivel1:=.f.
Private tNivel2:=.f.
Private tNivel3:=.f.
BoxFede(10,12,12,55)
Say(12,25,' Inhumaciones entre Fechas ',MonCol)
@11,15 Say 'Desde :' Get xDesde Pict '@D'
@11,35 Say 'Hasta :' Get xHasta Pict '@D' Valid xHasta>=xDesde
ReadOn()
If LastKey()=27
   Return Nil
EndIf
DbSetFilter({|| FechaI >= xDesde .And. FechaI <= xHasta})
DbGoTop()
While !Eof()
  xCodigo:=Codigo
  xCantidad++
  ****If SubNivel->Fechaexuma<>CtoD('  /  /    ')
  ****   xCantExuma++
  ****EndIf
  ParqueNu->(DbSetOrder(2))
  If ParqueNu->(DbSeek(xCodigo))
     If Upper(ParqueNu->Tipo_P_S)='S'
        xCanSocio++
     ElseIf Upper(ParqueNu->Tipo_P_S)='P'
        xCanParti++
     ElseIf Upper(ParqueNu->Tipo_P_S)='V'
        xCanEspec++
     Else
        xCanOtras++
     EndIf
  EndIf
  If Nivel=1
     If !tNivel1
        xNivel1++
        tNivel1:=.t.
     EndIf
     xSubNivel1++
  ElseIf Nivel=2
     If !tNivel2
        xNivel2++
        tNivel2:=.t.
     EndIf
     xSubNivel2++
  Else
     If !tNivel3
        xNivel3++
        tNivel3:=.t.
     EndIf
     xSubNivel3++
  EndIf
  If Cocheria=1
       xCoche1++
       If Upper(TipoI)='S'
          xTipo1S++
       Else
          xTipo1T++
       EndIf
  ElseIf Cocheria=2
       xCoche2++
       If Upper(TipoI)='S'
          xTipo2S++
       Else
          xTipo2T++
       EndIf
  ElseIf Cocheria=3
     xCoche3++
     If Upper(TipoI)='S'
        xTipo3S++
     Else
        xTipo3T++
     EndIf
  Else
    xCoche4++
     If Upper(TipoI)='S'
        xTipo4S++
     Else
        xTipo4T++
     EndIf
  EndIf
  DbSkip()
  If xCodigo<>Codigo
     tNivel1:=.f.
     tNivel2:=.f.
     tNivel3:=.f.
  EndIf
EndDo
DbClearFil()
Listado()
ParqueNu->(DbSetOrder(1))
Return Nil

Function Listado
Local Vec:={}
AADD(Vec,PadR(''+EmpNom+'',81))
AADD(Vec,PadR('4'+EmpDir+'5',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('Listado General de Inhumaciones',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('EFecha DesdeF '+DtoC(xDesde)+'    '+'EFecha Hasta F'+DtoC(xHasta),85))
AADD(Vec,Spac(77))
AADD(Vec,PadC('Total Inhumaciones',77))
AADD(Vec,PadC('E'+Str(xCantidad,4)+'F',81))
AADD(Vec,PadC('Total Exhumaciones',77))
AADD(Vec,PadC('E'+Str(xCantExuma,4)+'F',81))
AADD(Vec,PadR(' Socios Plan Demo A 4'+Str(xCanSocio,4)+'5',81))
AADD(Vec,PadR('       Particulares 4'+Str(xCanParti,4)+'5',81))
AADD(Vec,PadR('      Plan 120 x 20 4'+Str(xCanEspec,4)+'5',81))
AADD(Vec,PadR('              Otros 4'+Str(xCanOtras,4)+'5',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('    Cocheria Demo 1 E'+Str(xCoche1,4)+'F    Traslados E'+Str(xTipo1T,4)+'F    Servicios E'+Str(xTipo1S,4)+'F',89))
AADD(Vec,PadR(' Cocheria Demo 2 E'+Str(xCoche2,4)+'F    Traslados E'+Str(xTipo2T,4)+'F    Servicios E'+Str(xTipo2S,4)+'F',89))
AADD(Vec,PadR('Cocheria Demo 3 E'+Str(xCoche3,4)+'F    Traslados E'+Str(xTipo3T,4)+'F    Servicios E'+Str(xTipo3S,4)+'F',89))
AADD(Vec,PadR('   Cocheria Otros E'+Str(xCoche4,4)+'F    Traslados E'+Str(xTipo4T,4)+'F    Servicios E'+Str(xTipo4S,4)+'F',89))
AADD(Vec,Spac(77))
AADD(Vec,PadR('     Nivel 1 E '+Str(xNivel1,4)+'F      SubNivel 1  E'+Str(xSubNivel1,4)+'F',85))
AADD(Vec,PadR('     Nivel 2 E '+Str(xNivel2,4)+'F      SubNivel 2  E'+Str(xSubNivel2,4)+'F',85))
AADD(Vec,PadR('     Nivel 3 E '+Str(xNivel3,4)+'F      SubNivel 3  E'+Str(xSubNivel3,4)+'F',85))
MChoice(Vec,12,'A',.t.)
Return Nil

Function CobroCuotas
*-Objetivo : Cobro de Cuotas -
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษอออออออออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออออออออป ',;
            ' บ                                         ณ                                 บ ',;
            ' บ                                         ณ                                 บ ',;
            ' ฬอออออออออออออออออออออออออออออออออออออออออฯอออออออออออออออออออออออออออออออออน ',;
            ' บ   Recibo    Reserva Titular                      Bonificaciขn   Importe   บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ '}

Local xRetorna:=.t.
While .t.
    AuxiRes->(__DbZap())
    SetColor('W+/B+')
    BoxFede(2,2,21,68)
    WinShowR(Arr,2,2,'B')
    Scr1:=SaveScreen(0,0,24,79)
    Say(3,5,' Cobrador       ',MonCol)
    If !Cobrador->(CargaCobrador(3,22,0))
       Exit
    EndIf
    xFecha:=CtoD('  /  /    ')
    xComprobante:=Spac(13)
    @3,48 Say 'Fecha de Pago  : ' Get xFecha Pict '@D' Valid !Empty(xFecha)
    ReadOn()
    If LastKey() = 27
       Return Nil
    EndIf
    Reserva->(CargaDatos(xFecha))
    If _Quest(15,'!!!  A T E N C I O N  !!!',;
                 'ACTUALIZA LOS DATOS INGRESADOS',;
                   'จ Confirma ?')
        AuxiRes->(CargaCuoCta(xFecha))
    EndIf
EndDo
Return Nil

Function CobroExpensas
*-Objetivo : Cobro de Expensas -
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษอออออออออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออออออออป ',;
            ' บ                                         ณ                                 บ ',;
            ' บ                                         ณ                                 บ ',;
            ' ฬอออออออออออออออออออออออออออออออออออออออออฯอออออออออออออออออออออออออออออออออน ',;
            ' บ   Recibo    Reserva Titular                      Bonificaciขn   Importe   บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' บ                                                                           บ ',;
            ' ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ '}

Local xRetorna:=.t.
While .t.
    AuxiRes->(__DbZap())
    SetColor('W+/B+')
    BoxFede(2,2,21,68)
    WinShowR(Arr,2,2,'B')
    Scr1:=SaveScreen(0,0,24,79)
    Say(3,5,' Cobrador       ',MonCol)
    If !Cobrador->(CargaCobrador(3,22,0))
       Exit
    Else
        xFecha:=CtoD('  /  /    ')
        xComprobante:=Spac(13)
        @3,48 Say 'Fecha de Pago  : ' Get xFecha Pict '@D' Valid !Empty(xFecha)
        ReadOn()
        If LastKey() = 27
           Return Nil
        EndIf
        CtaExp->(CargaDatos(xFecha))
        If _Quest(15,'!!!  A T E N C I O N  !!!',;
                     'ACTUALIZA LOS DATOS INGRESADOS',;
                       'จ Confirma ?')
            AuxiRes->(CargaExpCta())
        EndIf
    EndIf
EndDo
Return Nil

Function CargaDatos(xFecha)
Local Vec:={}
Local xTot:=0
Local tCobrador:=Cobrador->Cobrador
Private xReserva:=0,xImpExpe:=0,xBonifica:=0,xTotBon:=0,xTotImp:=0
Private Linea:=7
While .t.
  xReserva:=0
  xBonifica:=0
  xImpExpe:=0
  xRecibo1:=0
  xRecibo2:=0
  @Linea,4 Get xRecibo1 Pict '9999'
  @Linea,9 Get xRecibo2 Pict '99999999'
  ReadOn()
  xRecibo:=StrZero(xRecibo1,4)+'-'+StrZero(xRecibo2,8)
  If LastKey()=27
     Op:=Contesta(' Listado de Control ','   Sale de Carga    ',19,21,'W+/G,N/W+')
     If Op=1
        AuxiRes->(ListaControl(xFecha,tCobrador,xTotImp,xTotBon))
        Loop
     ElseIf Op=2
        Exit
     ElseIf Op=0
        Loop
     EndIf
  EndIf
  SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999999',1,1)})
  @Linea,18 Get xReserva Pict '999999'
  ReadOn()
  SetKey( -9,{|| Nil })
  If LastKey() = 27
     Loop
  EndIf
  If !DbSeek(xReserva)
     MueveLet('Reserva No Encontrada. Verifique. ')
     Loop
  Endif
  Reserva->(DbSetOrder(1))
  If Reserva->(DbSeek(xReserva))
     * If Reserva->Cobrador!=1
     *   If Reserva->Cobrador!=tCobrador
     *      MueveLet('La Reserva No Pertenece a Este Cobrador')
     *      Loop
     *   EndIf
     * EndIf
  Else
     MueveLet('Existe un error en la Liquidaciขn. Verifique con Sistemas.')
     Loop
  EndIf
  If AuxiRes->(Busca_Rep(xReserva,xFecha,tCobrador))
     Loop
  EndIf
  xNombre:=Reserva->Nombre
  Say(Linea,4,xRecibo,MonCol)
  Say(Linea,18,xReserva,MonCol)
  Say(Linea,25,xNombre,MonCol)
  @Linea,55 Get xBonifica Pict '999999.99'
  @Linea,65 Get xImpExpe  Pict '999999.99'
  ReadOn()
  If LastKey()=27
     Say(Linea,4,Spac(60),MonCol)
     Loop
  EndIf
  Say(Linea,55,Transform(xBonifica,'999999.99'),MonCol)
  Say(Linea,65,Transform(xImpExpe,'999999.99'),MonCol)
  xTotBon+=xBonifica
  xTotImp+=xImpExpe
  If ++Linea>19
     Scroll(7,4,20,66,1)
     --Linea
     Say(Linea,4,Spac(60),MonCol)
  Endif
  AuxiRes->(PasaDato(xRecibo,xReserva,xNombre,xBonifica,xImpExpe,xFecha,tCobrador))
EndDo
Return Nil

Function Busca_Rep(xReserva,xFecha,tCobrador)
Local xCan,xDct
Local Scr:=SaveScreen(18,0,21,79)
DbSetOrder(1)
If !DbSeek(xReserva)
   Return .f.
ElseIf xFecha=FechaPago
   Tone(600,3)
   BoxFede(18,0,20,79,'W/R+')
   Say(18,5,' <Esc> Sale ','W+/R+')
   Say(18,25,' (Importe = 0) Borra Item ','W+/R+')
   Say(18,52,' Expensa ya Ingresada ','Gr+/R+')
   Say(20,2,' Reserva ','W+/R+')
   Say(20,10,' Nombre ','W+/R+')
   Say(20,44,' Bonificacion ','W+/R+')
   Say(20,59,' Importe ','W+/R+')
   Say(19,2,Transform(xReserva,'999999'),'GR+/R+')
   Say(19,10,Transform(Substr(Nombre,1,30),'@!'),'GR+/R+')
   xBonifica:=Bonifica
   xImporte:=Importe
   @19,48 Get xBonifica Pict '99999.99'
   ReadOn()
   If xBonifica=0
      @19,59 Get xImporte Pict '99999.99'
      ReadOn()
   EndIf
   If LastKey() != 27
      VerActiva()
      Replace Bonifica With xBonifica
      Replace Importe  With xImporte
      DbCommit()
      DbUnLock()
   EndIf
   RestScreen(18,0,21,79,Scr)
   Muestra(xFecha,tCobrador)
EndIf
Return .t.

Function Muestra(xFecha,tCobrador)
Linea:=7
DBSetOrder(0)
DBGoTop()
While !Eof()
  If Importe=0
     VerActiva()
     DbDelete()
     DbUnLock()
  Else
     If FechaPago=xFecha .And. Cobrador=tCobrador
        Say(Linea,4,Transform(Reserva,'999999'),MonCol)
        Say(Linea,12,Nombre,MonCol)
        Say(Linea,45,Transform(Bonifica,'999999.99'),MonCol)
        Say(Linea,55,Transform(Importe,'999999.99'),MonCol)
        If ++Linea>19
           Scroll(7,4,20,66,1)
           --Linea
           Say(Linea,4,Spac(60),MonCol)
        EndIf
     EndIf
  EndIf
  DBSkip()
End
DbSetOrder(1)
Return Nil

Static Function Contesta(Opcion1,Opcion2,fil1,fil2,xColor)
Local Colo:=SetColor()
Local op,co1,co2,kk:=0
Local Scr:=SaveScreen(0,0,24,79)
If PCount()=2
   fil1=21
   fil2=23
EndIf
If xColor=Nil
   xColor:='W+/B,N/W+'
EndIf
SetColor(xColor)
If Len(opcion1)>=Len(opcion2)
   kk=Len(Opcion1)
Else
   kk=Len(Opcion2)
EndIf
If Int(kk/2)=(kk/2)
   kk=(kk*2)+4
Else
   kk=(kk*2)+5
EndIf
co1=38-(kk/2)
co2=42+(kk/2)
BoxFede(fil1,co1,fil2,co2)
Say(fil1,33,' Elija Opciขn ',xColor)
op=2
@fil1+1,co1+3 Prompt Opcion1
@fil1+1,co2-(len(opcion2)+2) Prompt Opcion2
Menu to Op
SetColor(Colo)
RestScreen(0,0,24,79,Scr)
Return Op

Function PasaDato(xRecibo,xReserva,xNombre,xBonifica,xImpExpe,xFecha,tCobrador)
VerActiva()
If !DbSeek(xReserva)
   DbAppend()
EndIf
Replace Recibo      With xRecibo,;
        Reserva     With xReserva,;
        Nombre      With xNombre,;
        Bonifica    With xBonifica,;
        Importe     With xImpExpe,;
        Fechapago   With xFecha,;
        Cobrador    With tCobrador
DbCommit()
DbUnLock()
Return Nil

Function ListaControl(xFecha,tCobrador)
Local Vec:={}
Local xTotBon:=xTotImp:=0
AADD(Vec,PadR(''+EmpNom+'',81))
AADD(Vec,PadR('4'+EmpDir+'5',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('Listado Control De Expensas',81))
AADD(Vec,PadR('Cobrador: E'+Cobrador->Nombre+'F',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('E  Recibo   Reserva    Apellido y Nombre             Bonificaciขn   Importe F',81))
DbGoTop()
While !Eof()
  If Importe>0 .And. xFecha=FechaPago .And. Cobrador=tCobrador
     AADD(Vec,PadR(Recibo+' '+Str(Reserva,6)+'  '+Left(Nombre,30)+'  '+Str(Bonifica,9,2)+'   '+Str(Importe,9,2),77))
     xTotBon+=Bonifica
     xTotImp+=Importe
  EndIf
  DbSkip()
EndDo
AADD(Vec,Spac(77))
AADD(Vec,PadL('ETotal Bonificaciขn  Total Importe F',81))
AADD(Vec,PadL(Str(xTotBon,9,2)+'   '+Str(xTotImp,9,2)+'    ',77))
MChoice(Vec,8,'A',.t.)
Return Nil

Function CargaCuoCta(xFecha)
Local xReserva:=0,xMonto:=0
DbGoTop()
While !Eof()
   xReserva:=Reserva
   xMonto:=Importe+Bonifica
   CtaCte->(GrabaCuoCta(xReserva,xMonto,xFecha))
   DbSkip()
EndDo
Return Nil

Function GrabaCuoCta(xReserva,xImporte,xFecha)
Local tImporte:=AuxiRes->Importe
Local tBonifica:=AuxiRes->Bonifica
If DbSeek(xReserva)
   While Reserva=xReserva .And. !Eof()
      If Saldo>0
         xResta:=Saldo-xImporte
         If xResta>=0
            VerActiva()
               Replace Saldo With xResta
            DbUnLock()
            Recibo->(VerActiva())
               Recibo->(DbAppend())
               Replace Recibo->Reserva    With xReserva,;
                       Recibo->Cuota      With CtaCte->Cuota,;
                       Recibo->Fecha      With xFecha,;
                       Recibo->Sucursal   With Val(Left(AuxiRes->Recibo,4)),;
                       Recibo->Recibo     With Val(Right(AuxiRes->Recibo,8)),;
                       Recibo->Bonificaci With tBonifica,;
                       Recibo->Importe    With tImporte,;
                       Recibo->Cobrador   With AuxiRes->Cobrador
            Recibo->(DbUnLock())
            Exit
         Else
            xImporte:=Abs(xResta)
            If tBonifica>0
               If tBonifica>=Saldo
                  Recibo->(DbAppend())
                  Replace Recibo->Reserva    With xReserva,;
                          Recibo->Cuota      With CtaCte->Cuota,;
                          Recibo->Fecha      With xFecha,;
                          Recibo->Sucursal   With Val(Left(AuxiRes->Recibo,4)),;
                          Recibo->Recibo     With Val(Right(AuxiRes->Recibo,8)),;
                          Recibo->Bonificaci With Saldo,;
                          Recibo->Importe    With 0,;
                          Recibo->Cobrador   With AuxiRes->Cobrador
                  Recibo->(DbUnLock())
                  tBonifica-=Saldo
               Else
                  Recibo->(DbAppend())
                  Replace Recibo->Reserva    With xReserva,;
                          Recibo->Cuota      With CtaCte->Cuota,;
                          Recibo->Fecha      With xFecha,;
                          Recibo->Sucursal   With Val(Left(AuxiRes->Recibo,4)),;
                          Recibo->Recibo     With Val(Right(AuxiRes->Recibo,8)),;
                          Recibo->Bonificaci With tBonifica,;
                          Recibo->Importe    With Saldo-tBonifica,;
                          Recibo->Cobrador   With AuxiRes->Cobrador
                  Recibo->(DbUnLock())
                  tImporte-=(Saldo-tBonifica)
                  tBonifica:=0
               EndIf
            Else
               If (Saldo-tImporte)<=0
                  xrImporte:=Saldo
               Else
                  xrImporte:=Saldo-tImporte
               EndIf
               tImporte-=Saldo
               Recibo->(VerActiva())
                  Recibo->(DbAppend())
                  Replace Recibo->Reserva    With xReserva,;
                          Recibo->Cuota      With CtaCte->Cuota,;
                          Recibo->Fecha      With xFecha,;
                          Recibo->Sucursal   With Val(Left(AuxiRes->Recibo,4)),;
                          Recibo->Recibo     With Val(Right(AuxiRes->Recibo,8)),;
                          Recibo->Bonificaci With 0,;
                          Recibo->Importe    With xrImporte,;
                          Recibo->Cobrador   With AuxiRes->Cobrador
               Recibo->(DbUnLock())
            EndIf
            VerActiva()
               Replace Saldo With 0
            DbUnLock()
         EndIf
      EndIf
      DbSkip()
   EndDo
EndIf
Return Nil


*-Objetivo: Carga de datos en base ExpCta y Descarga de Deuda
Function CargaExpCta
Local xReserva:=0
DbGoTop()
While !Eof()
   xReserva:=Reserva
   ExpCta->(GrabaExpCta(xReserva))
   CtaExp->(Actualiza(xReserva))
   DbSkip()
EndDo
Return Nil

Function Actualiza(xReserva)
   Local xImporte:=AuxiRes->Importe+AuxiRes->Bonifica
   Local xExpensa:=ValorExp->ValorExpen
   DbSetOrder(2)
   DbSeek(StrZero(xReserva,6)+StrZero(1990,4)+StrZero(1,2),.t.)
   While Reserva=xReserva .And. !Eof()
      If Pagada='N'
         xImporte+=ACuenta
         If xImporte>0
            If Valor<=xImporte
               VerActiva()
                  Replace Pagada With 'S',;
                          FechaPago With AuxiRes->FechaPago,;
                          Recibo With AuxiRes->Recibo
               DbUnLock()
               xImporte-=Valor
            Else
               VerActiva()
                  Replace ACuenta With xImporte
               DbUnLock()
               xImporte-=Valor
            EndIf
         EndIf
      EndIf
      xMes_Liq:=Mes
      xAno_Liq:=Ano
      DbSkip()
   EndDo
   If xImporte>0
      While xImporte>0
         xMes_Liq++
         If xMes_Liq>12
            xMes_Liq:=1
            xAno_Liq++
         EndIf
         If xImporte>=xExpensa
            VerActiva()
               DbAppend()
               Replace Reserva With xReserva,;
                       Vence   With Date(),;
                       Valor   With xExpensa,;
                       Mes     With xMes_Liq,;
                       Ano     With xAno_Liq,;
                       Pagada  With 'S',;
                       FechaPago With AuxiRes->FechaPago,;
                       Recibo With AuxiRes->Recibo
               DbCommit()
            DbUnLock()
            xImporte-=xExpensa
         Else
            VerActiva()
               DbAppend()
               Replace Reserva With xReserva,;
                       Vence   With Date(),;
                       Valor   With xExpensa,;
                       Mes     With xMes_Liq,;
                       Ano     With xAno_Liq,;
                       Pagada  With 'N',;
                       ACuenta With xImporte
               DbCommit()
            DbUnLock()
            xImporte:=0
         EndIf
      EndDo
   EndIf
   DbCommit()
Return Nil

Function GrabaExpCta(xReserva)
   Local xResto:=xPaga:=xSuma:=0
   Local xMes:=xAnio:=0
   ValorExp->(DbGoBottom())
   xImporte:=ValorExp->ValorExpen
   DbSetOrder(2)
   DbSeek(StrZero(xReserva,6)+'999999',.t.)

   If Reserva=xReserva
      xMes :=Mes
      xAnio:=Anio
   EndIf

   xPaga:=AuxiRes->Bonifica+AuxiRes->Importe+aCuenta
   While .t.
      xSuma+=xImporte
      If xSuma>=xPaga
         If xSuma=xPaga
            xMes:=If(xMes=12,1,xMes+1)
            xAnio:=If(xMes=12,xAnio+1,xAnio)
            xResto=0
         Else
            xResto:=xPaga-(xSuma-xImporte)
         EndIf
         Exit
      EndIf
      xMes:=If(xMes=12,1,xMes+1)
      xAnio:=If(xMes=12,xAnio+1,xAnio)
   EndDo
   VerActiva()
   DbAppend()
   Replace Reserva     With AuxiRes->Reserva,;
           Bonifica    With AuxiRes->Bonifica,;
           Importe     With AuxiRes->Importe,;
           Acuenta     With xResto,;
           Fecha       With AuxiRes->FechaPago,;
           Comprobant  With AuxiRes->Recibo,;
           Cobrador    With AuxiRes->Cobrador,;
           Mes         With xMes,;
           Anio        With xAnio
   DbCommit()
   DbUnLock()
   DbSetOrder(1)
Return Nil

Function TraeNroRes
DbGoBottom()
Return Reserva+1


Function AltaReservas
*-Objetivo : Alta de Reservas - Una por Parcela -
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษอออออออออออออออออออออออออออออออออออัอออออออออออออออออออออออออออป ',;
            ' บ Reserva :                         ณ      Mutual :             บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด    Cobrador :             บ ',;
            ' บ        Apellido y Nombre          ณ    Promotor :             บ ',;
            ' บ                                   ณ        Alta :             บ ',;
            ' บ            Domicilio              ณ Alta Mutual :             บ ',;
            ' บ                                   ณ        Tipo :             บ ',;
            ' บ             Barrio                ณ                           บ ',;
            ' บ                                   ภฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤถ ',;
            ' บ Telefono  :                          ณ                     ณ  บ ',;
            ' บ Localidad :                          ภฤฤฤฤฤฤฤฤฤฤฤ Crdito ฤู  บ ',;
            ' บ Provincia :          C-Postal :         Tipo Documento :      บ ',;
            ' บ                                         Documento :           บ ',;
            ' วฤฤ Parcela ฤฤฤยฤฤ Sector ฤฤ Fila ฤฤ Parcela ฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤถ ',;
            ' บ              ณ                                   ณ Suplentes  บ ',;
            ' ศออออออออออออออฯอออออออออออออออออออออออออออออออออออฯออออออออออออผ '}

Local xCredito,xArea,xAlta
Local xNombre,xDomicilio,xBarrio,xTelefono,xAltaMut
Local xTipo,xReserva,xDocumento,xLocalidad,xSector
Local xFila,xParcela,xCPostal,xTDoc,xTipo_p_s
Local xRetorno:=.t.
Public xCodigo:=Space(7)
Public xProvincia:=0
Public xAsociacion:=0
Public xCobrador:=0
Public xPromotor:=0
SetColor('W+/B+')
BoxFede(2,2,17,68)
WinShowR(Arr,2,2,'B')
Say(17,42,' Alta de Reservas ',MonCol)
Scr1:=SaveScreen(0,0,24,79)
DbGoBottom()
xReserva:=TraeNroRes()
While .t.
   WinShowR(Arr,2,2,'B')
   Say(17,42,' Alta de Reservas ',MonCol)
   SetColor('W+/B+')
   Scr1:=SaveScreen(0,0,24,79)
   xCredito:=0
   xCPostal:=0
   xTDoc:=Spac(3)
   xDocumento:=0
   xNombre:=Spac(30)
   xTipo_p_s:=Spac(1)
   xAlta:=CtoD('  /  /    ')
   xAltaMut:=CtoD('  /  /    ')
   xDomicilio:=Spac(30)
   xBarrio:=Spac(30)
   xTelefono:=Spac(12)
   xLocalidad:=Spac(15)
   @3,15 Get xReserva Pict '999999' Color MonCol
   ReadOn()
   If LastKey() = 27
      Exit
   EndIf
   If DbSeek(xReserva)
      MueveLet('Reserva Ya Entregada. Verifique. ')
      Loop
   EndIf
   Say(17,42,' Alta de Reservas ',MonCol)
   Say(3,15,Str(xReserva,6),'GR+/B+')
   @ 6, 4 Get xNombre    Pict '@S30!' Color MonCol
   @ 8, 4 Get xDomicilio Pict '@S25!' Color MonCol
   @10, 4 Get xBarrio    Pict '@S15!' Color MonCol
   @11,16 Get xTelefono  Pict '!!!!-!!!!!!!' Color MonCol
   @12,16 Get xLocalidad Pict '@S15!' Color MonCol
   ReadOn()
   If LastKey()=27
      Loop
   EndIf
   If !Provinci->(CargaProvi(13,16))
      Loop
   EndIf
   @13,36 Get xCPostal   Pict '99999' Color MonCol
   ReadOn()
   If LastKey() = 27
      Loop
   EndIf
   Scr1:=SaveScreen(0,0,24,79)
   BoxFede(11,59,17,65,'Gr+/B')
   Op:=1
   @12,61 Prompt 'DNI'
   @13,61 Prompt 'LE '
   @14,61 Prompt 'LC '
   @15,61 Prompt 'CI '
   @16,61 Prompt 'CE '
   Menu to Op
   RestScreen(0,0,24,79,Scr1)
   Do Case
      Case Op=0
      Case Op=1
         Say(13,63,'DNI',MonCol)
         xTDoc='DNI'
      Case Op=2
         Say(13,63,'LE ',MonCol)
         xTDoc='LE'
      Case Op=3
         Say(13,63,'LC ',MonCol)
         xTDoc='LC'
      Case Op=4
         Say(13,63,'CI ',MonCol)
         xTDoc='CI'
      Case Op=5
         Say(13,63,'CE ',MonCol)
         xTDoc='CE'
   EndCase
   @14,58 Get xDocumento Pict '99999999' Color MonCol
   If !Mutual->(CargaMutual())
      Loop
   EndIf
   If !Cobrador->(CargaCobrador(4,55,1))
      Loop
   EndIf
   If !Promotor->(CargaPromotor())
      Loop
   EndIf
   @6,55 Get xAlta  Pict '@D'  Color MonCol Valid !Empty(xAlta)
   ReadOn()
   If LastKey() = 27
      Loop
   EndIf
   If xAsociacion!=0
      @7,55 Get xAltaMut  Pict '@D'  Color MonCol  /////////////Valid !Empty(xAltaMut)
   EndIf
   ReadOn()
   If LastKey() = 27
      Loop
   EndIf
   Scr1:=SaveScreen(0,0,24,79)
   BoxFede(7,53,11,69,'Gr+/B')
   @ 8,55 Prompt ' Plan Demo A '
   @ 9,55 Prompt ' Particular  '
   @10,55 Prompt ' Socio Demo B  '
   Menu to Op
   RestScreen(0,0,24,79,Scr1)
   Do Case
      Case Op=0
      Case Op=1
         Say(8,55,'Plan Demo A',MonCol)
         xTipo_P_S='S'
      Case Op=2
         Say(8,55,'Particular ',MonCol)
         xTipo_P_S='P'
      Case Op=3
         Say(8,55,'Socio Demo B ',MonCol)
         xTipo_P_S='V'
   EndCase

   xCodParcela:=CargaParcela()
   xSector:=SubStr(xCodParcela,-7,3)
   xFila:=Val(SubStr(xCodParcela,-4,2))
   xParcela:=Val(SubStr(xCodParcela,-2,2))

   Scr1:=SaveScreen(0,0,24,79)
   BoxFede(11,46,16,58,'Gr+/B')
   @12,48 Prompt ' Contado '
   @13,48 Prompt ' Tarjeta '
   @14,48 Prompt ' CtaCte. '
   @15,48 Prompt '  Socio  '
   Menu to Op
   RestScreen(0,0,24,79,Scr1)
   Do Case
      Case Op=0
           Loop
      OtherWise
           Facturar(Op)
   EndCase
   Scr1:=SaveScreen(0,0,24,79)
   BoxFede(15,54,17,68,'Gr+/W')
   @16,57 Prompt 'Suplentes'
   Menu to Op
   RestScreen(0,0,24,79,Scr1)
   Do Case
      Case Op=0
      Case Op=1
         AxSupl->(CargaSuple(xReserva))
   EndCase
   If _Quest(17,'!!!  A T E N C I O N  !!!',;
               'Debe Confirmar los Datos Ingresados',;
               'จ Confirma ?')
       Titular->(GrabaTitular(xCodigo,xReserva,xNombre,xDomicilio,xBarrio,xTelefono,xProvincia,xLocalidad,xCPostal,xTDoc,xDocumento))
       Reserva->(GrabaReserva(xReserva,xAsociacion,xCobrador,xNombre,xDomicilio,xBarrio,xTelefono,xAlta,xPromotor,xCredito))
       ParqueNu->(GrabaParque(xCodigo,xReserva,xSector,xFila,xParcela,xProvincia,xLocalidad,xCPostal,xTDoc,xDocumento))
       AxSupl->(PasaCarga())
       CtaCte->(CargaPlan(xReserva))
       xReserva++
       Loop
   Else
       AxSupl->(__DbZap())
   EndIf
EndDo
_SBoxDS(2,1,15,68,Scr1)
Return Nil

Function CargaPlan(xReserva)
BeforAr:=Select()
Use AxPl&Puesto. New
xCuotas:=Cuotas
xPrecio:=Precio
xVigencia:=Desde
xTotal:=Precio*Cuotas
DbCloseArea()
DbSelectAr(BeforAr)
VerActiva()
    For t=1 to xCuotas
        DbAppend()
        Replace Reserva With xReserva,;
                Cuota With t,;
                Vencimient With xVigencia,;
                Importe With xPrecio,;
                Saldo With xPrecio,;
                Marca With 'I'
       xVigencia:=AuMes(xVigencia)
    Next t
DbCommit()
DbUnLock()
Return Nil

Function AuMes(xFecha)
Local xDia:=Day(xFecha)
Local xAno:=Year(xFecha)
Local xMes:=Month(xFecha)
xMes++
If xMes=13
   xMes=1
   xAno++
EndIf
Return CtoD(StrZero(xDia,2)+'/'+StrZero(xMes,2)+'/'+StrZero(xAno,4))

Function Facturar(Op)
Local xLi:=12
Local xCuotas:=0
Local xPrecio:=0
Local xDesde:=Date()
Local scr:=SaveScreen(10,0,18,79)
BeforAr:=Select()
Use AxPl&Puesto. New
Zap
DbCloseArea()
DbSelectAr(BeforAr)
If Op=1
   BoxFede(10,40,17,75)
   Say(10,45,' Contado ',MonCol)
   Say(11,43,'Cuotas','Bg+/B+')
   Say(11,53,'Monto','Bg+/B+')
   Say(11,60,'Vigencia','Bg+/B+')
   While .t.
      xCuotas:=xPrecio:=0
      @xLi,43 Get xCuotas Pict '999' Valid xCuotas >0 .And. xCuotas <= 24
      @xLi,50 Get xPrecio Pict '99999.99'
      @xLi,60 Get xDesde Pict '@D'
      ReadOn()
      If LastKey()=27
         Exit
      EndIf
      BeforAr:=Select()
      Use AxPl&Puesto. New
      DbAppend()
      Replace Cuotas With xCuotas,;
              Precio With xPrecio,;
              Desde  With xDesde
      DbCloseArea()
      DbSelectAr(BeforAr)
      xDesde:=SumaMes(xDesde,xCuotas)
*     If ++xLi>16
*        xLi:=16
*        Scroll(11,43,16,72,1)
*     EndIf
      Exit
   EndDo
EndIf

If Op=3
   BoxFede(10,40,17,75)
   Say(10,43,' Cuenta Corriente ',MonCol)
   Say(11,43,'Cuotas','Bg+/B+')
   Say(11,53,'Monto','Bg+/B+')
   Say(11,60,'Vigencia','Bg+/B+')
   While .t.
      xCuotas:=xPrecio:=0
      @xLi,43 Get xCuotas Pict '999'
      @xLi,50 Get xPrecio Pict '99999.99'
      @xLi,60 Get xDesde Pict '@D'
      ReadOn()
      If LastKey()=27
         Exit
      EndIf
      BeforAr:=Select()
      Use AxPl&Puesto. New
      DbAppend()
      Replace Cuotas With xCuotas,;
              Precio With xPrecio,;
              Desde  With xDesde
      DbCloseArea()
      DbSelectAr(BeforAr)
      xDesde:=SumaMes(xDesde,xCuotas)
      If ++xLi>16
         xLi:=16
         Scroll(11,43,16,72,1)
      EndIf
   EndDo
EndIf
RestScreen(10,0,18,79,Scr)
Return Nil

Function SumaMes(xDesde,xCan)
Local xAno:=0
For t=1 to xCan
  If Month(xDesde)=1 .Or. Month(xDesde)=3 .Or. Month(xDesde)=5 ;
                     .Or. Month(xDesde)=7 .Or. Month(xDesde)=8 ;
                     .Or. Month(xDesde)=10 .Or. Month(xDesde)=12
     xDias:=31
  ElseIf Month(xDesde)=2
     xAno:=Year(xDesde)
     If Bisiesto->(DbSeek(xAno))
        xDias:=29
     Else
        xDias:=28
     EndIf
  Else
     xDias:=30
  EndIf
  xDesde:=xDesde+xDias
Next t
Return xDesde

Function PasaCarga
Local xApellido,xDomicilio,xBarrio,xLocalidad,xProvincia,xCPostal,xTipoDoc,xDocumento,;
      xTelefono,xReserva,xSuplente
DbGoTop()
While !Eof()
   xApellido := Titular
   xDomicilio:= Domicilio
   xBarrio   := Barrio
   xLocalidad:= Localidad
   xProvincia:= Provincia
   xCPostal  := CPostal
   xTipoDoc  := TDoc
   xDocumento:= Documento
   xTelefono := Telefono
   xReserva  := Reserva
   xSuplente := Suplente
   Suplente->(DatoSuple(xApellido,xDomicilio,xBarrio,xLocalidad,xProvincia,xCPostal,xTipoDoc,xDocumento,xTelefono,xReserva,xSuplente))
   DbSkip()
EndDo
AxSupl->(__DbZap())
Return Nil

Function GrabaTitular(xCodigo,xReserva,xNombre,xDomicilio,xBarrio,xTelefono,xProvincia,xLocalidad,xCPostal,xTDoc,xDocumento)
VerActiva()
DbAppend()
Replace  Codigo With xCodigo,;
        Reserva With xReserva,;
         Nombre With xNombre,;
      Domicilio with xDomicilio,;
         Barrio With xBarrio,;
       Telefono With xTelefono,;
      Provincia With xProvincia,;
      Localidad With xLocalidad,;
        Cpostal With xCPostal,;
           TDoc With xTDoc,;
      Documento With xDocumento
DbCommit()
DbUnLock()
Return Nil


*--Objetivo: Graba en la base transitoria
Function GrabaReserva(xReserva,xAsociacion,xCobrador,xNombre,xDomicilio,xBarrio,xTelefono,xAlta,xPromotor,xCredito)
Local xExpensa:=ValorExp->ValorExpen
VerActiva()
DbAppend()
Replace Reserva With xReserva,;
         Mutual With xAsociacion,;
       Cobrador With xCobrador,;
         Nombre With xNombre,;
      Domicilio with xDomicilio,;
         Barrio With xBarrio,;
       Telefono With xTelefono,;
           Alta With xAlta,;
       Promotor With xPromotor,;
        Credito With xCredito,;
        Ult_Mes With Month(Date()),;
        Ult_Ano With Year(Date()),;
        Expensa With xExpensa
DbCommit()
DbUnLock()
Return Nil

Function GrabaParque(xCodigo,xReserva,xSector,xFila,xParcela,xProvincia,xLocalidad,xCPostal,xTDoc,xDocumento)
Local xOrd:=DbSetOrder()
DbsetOrder(2)
VerActiva()
If DbSeek(xCodigo)
   Replace Reserva    With xReserva,;
           Sector     With xSector,;
           Fila       With xFila,;
           Parcela    With xParcela,;
           Tipo_P_S   With 'P',;
            Provincia With xProvincia,;
            Localidad With xLocalidad,;
              Cpostal With xCPostal,;
                 TDoc With xTDoc,;
            Documento With xDocumento,;
              Ult_Mes With Month(Date()),;
              Ult_Ano With Year(Date())
Else
   DbAppend()
   Replace Codigo     With xCodigo,;
           Reserva    With xReserva,;
           Sector     With xSector,;
           Fila       With xFila,;
           Parcela    With xParcela,;
           Tipo_P_S   With 'P',;
            Provincia With xProvincia,;
            Localidad With xLocalidad,;
              Cpostal With xCPostal,;
                 TDoc With xTDoc,;
            Documento With xDocumento,;
              Ult_Mes With Month(Date()),;
              Ult_Ano With Year(Date())
EndIf
DbCommit()
DbUnLock()
DbSetOrder(xOrd)
Return Nil

Function CargaParcela
Local xCodigo
While .t.
  xCodigo:=StorParcela()
  DbSetOrder(2)
  If DbSeek(xCodigo)
     If CanTit>3
        MueveLet('No Puede haber m s de 3 Titulares por Parcela')
        Loop
     EndIf
     If Tipo_p_s='P'
        MueveLet('Esta Parcela Est  Reservada')
        Loop
     Else
        If SubNivel->(DbSeek(xCodigo))
           MueveLet('Esta Parcela Est  Adjudicada')
           //Loop
        EndIf
     EndIf
  EndIf
  DbSetOrder(1)
  Say(16,7,xCodigo,DanCol)
  Say(16,24,SubStr(xCodigo,-7,3),DanCol)
  Say(16,33,SubStr(xCodigo,-4,2),DanCol)
  Say(16,42,SubStr(xCodigo,-2,2),DanCol)
  If _Quest(17,'!!!  A T E N C I O N  !!!',;
               'Debe Confirmar la Parcela Ingresada',;
               'จ Confirma ?')
      Say(16,7,xCodigo,MonCol)
      Say(16,24,SubStr(xCodigo,-7,3),MonCol)
      Say(16,33,SubStr(xCodigo,-4,2),MonCol)
      Say(16,42,SubStr(xCodigo,-2,2),MonCol)
      Exit
  EndIf
EndDo
Return xCodigo

Function StorParcela
Local xtFila:=xtParcela:=0
Local xSector:=Spac(3)
Local xFila:=fi:=li:=0
Local xColor:=SetColor()
Local Scr:=SaveScreen(0,0,24,79)
Local Scr1
Local xVar:=' '
Local Vec:={}
AADD(Vec,'ษออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป')
AADD(Vec,'บFilaบ   P     A     R     C     E     L     A     S                         บ')
AADD(Vec,'วฤฤฤฤืฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤยฤฤถ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'บ    บ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  ณ  บ')
AADD(Vec,'ศออออสออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออฯออผ')

SetColor( '' )
WinShowR(Vec,0,1,'D')
Say(1,2,'Fila','GR+/N')
Say(1,10,'P     A     R     C     E     L     A     S','GR+/N')
SetColor(xColor)
xCodigo:=Space(7)
While .t.
  xSector:=Spac(3)
  BoxFede(0,57,2,76)
  @1,60 Say 'Sector Nง:' Get xSector Pict '!!!' Valid !Empty(xSector)
  ReadOn()
  If LastKey()=27
     Exit
  EndIf
  DbSetOrder(5)
  If DbSeek(xSector,.t.)
     SetColor( '' )
     Lev_Pan()
     WinShowR(Vec,0,1,'D')
     Say(1,2,'Fila','GR+/N')
     Say(1,10,'P     A     R     C     E     L     A     S','GR+/N')
     Say(24,0,PadC(' Sector : '+xSector,80),'Gr+/B')
     xFila=Fila
     fi:=3
     While Sector=xSector
        li:=7
        Say(fi,3,StrZero(Fila,2),'B+')
        While Fila=xFila .And. Sector=xSector .And. !Eof()
           xCodigo=Codigo
           If Tipo_p_s='P'
              SetColor('GR+/GR+')
           ElseIf Tipo_p_s='M'
              SetColor('G+/G+')
           Else
              SetColor( '' )
           EndIf
           If SubNivel->(DbSeek(xCodigo))
              If Date()-15 <= SubNivel->FechaI
                 SetColor('N*/R')
              Else
                 SetColor('G+/R+')
              EndIf
           EndIf
           @fi,li Say Str(Parcela,2)
           SetColor( '' )
           li+=3
           DbSkip()
           If li>76
              li:=7
              fi++
           EndIf
        EndDo
        xFila:=Fila
        fi++
     EndDo
     SetColor(xColor)
     Scr1:=SaveScreen(15,0,24,79)
     @24,0  Say 'F:' get xtFila Pict '99'
     @24,10 Say 'P:' get xtParcela Pict '99' Valid xtParcela>0
     ReadOn()
     xCodigo:=xSector+StrZero(xtFila,2)+StrZero(xtParcela,2)
     Exit
     RestScreen(15,0,24,79,Scr1)
  Else
     MueveLet(' SECTOR No Encontrado ')
  EndIf
EndDo
DbSetOrder(1)
RestScreen(0,0,24,79,Scr)
Return xCodigo

Function CargaProvi(xh,xv)
Local xRetorna:=.t.
While .t.
 xProvincia:=0
 SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999',1,1)})
 @xh,xv Get xProvincia Pict '999' Color MonCol
 ReadOn()
 SetKey( -9,{|| Nil })
 If LastKey() = 27
     xProvincia:=0
     xRetorna:=.f.
    Exit
 EndIf
 If !DbSeek(xProvincia)
     MueveLet('Cขdigo De Provincia No Encontrado. Verifique. ')
 Else
     Say(xh,xv,xProvincia,MonCol)
     xRetorna:=.t.
     Exit
 Endif
EndDo
Return xRetorna

Function CargaMutual
Local xRetorna:=.t.
While .t.
 xAsociacion:=0
 SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999',1,1)})
 @3,55 Get xAsociacion Pict '999' Color MonCol
 ReadOn()
 SetKey( -9,{|| Nil })
 If LastKey() = 27
     xAsociacion:=0
     xRetorna:=.t.
     Exit
 EndIf
 If !DbSeek(xAsociacion)
     MueveLet('Cขdigo De Mutual No Encontrado. Verifique. ')
 Else
     Say(3,55,xAsociacion,MonCol)
     xRetorna:=.t.
     Exit
 Endif
EndDo
Return xRetorna

Function CargaCobrador(x,y,n)
Local xRetorna:=.t.
xCobrador:=0
While .t.
 xCobrador:=0
 SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999',1,1)})
 @x,y Get xCobrador Pict '999' Color MonCol
 ReadOn()
 SetKey( -9,{|| Nil })
 If LastKey() = 27
    xCobrador:=0
    xRetorna:=.f.
    Exit
 EndIf
 If !DbSeek(xCobrador)
     MueveLet('Cขdigo De Cobrador No Encontrado. Verifique. ')
 Else
     If n=1
         Say(x,y,xCobrador,MonCol)
         xRetorna:=.t.
         Exit
     Else
         Say(x,y,xCobrador,MonCol)
         Say(4,5,Nombre,MonCol)
         xRetorna:=.t.
         Exit
     EndIf
 Endif
EndDo
Return xRetorna

Function CargaPromotor()
Local xRetorna:=.t.
xPromotor:=0
While .t.
 xPromotor:=0
 SetKey( -9,{|cProg,cLine,cVar| AyuOnLine(cProg,cLine,cVar,Nil,1,'999',1,1)})
 @5,55 Get xPromotor Pict '999' Color MonCol
 ReadOn()
 SetKey( -9,{|| Nil })
 If LastKey() = 27
    xPromotor:=0
    xRetorna:=.f.
    Exit
 EndIf
 If !DbSeek(xPromotor)
     MueveLet('Cขdigo De Promotor No Encontrado. Verifique. ')
 Else
     Say(5,55,xPromotor,MonCol)
     xRetorna:=.t.
     Exit
 Endif
EndDo
Return xRetorna

Function CargaSuple(xReserva)
*-Objetivo : Alta de Suplentes - Varios por Parcela -
Local Scr1:=SaveScreen(0,0,24,79)
Local Arr:={' ษออออออออออออออออออออออัออออออออออออออป ',;
            ' บ Suplente Nง :        ณ              บ ',;
            ' วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู              บ ',;
            ' บ Apellido  :                         บ ',;
            ' บ Domicilio :                         บ ',;
            ' บ Barrio    :                         บ ',;
            ' บ Localidad :                         บ ',;
            ' บ Provincia :                         บ ',;
            ' บ C-Postal  :                         บ ',;
            ' บ Telefono  :                         บ ',;
            ' บ Tipo Doc. :                         บ ',;
            ' บ Documento :                         บ ',;
            ' ศอออออออออออออออออออออออออออออออออออออผ '}

Local xApellido,xDomicilio,xBarrio,xLocalidad,xCPostal
Local xTelefono,xTipoDoc,xDocumento
Local xRetorna:=.t.
SetColor('W+/B+')
Scr1:=SaveScreen(0,0,24,79)
BoxFede(8,37,20,77)
WinShowR(Arr,8,37,'I')
xSuplente:=1
While .t.
   WinShowR(Arr,8,38,'B')
   SetColor('W+/B+')
   xCPostal:=0
   xDocumento:=0
   xTipoDoc:=Spac(3)
   xApellido:=Spac(25)
   xDomicilio:=Spac(25)
   xBarrio:=Spac(25)
   xTelefono:=Spac(12)
   xLocalidad:=Spac(15)
   Say(9,56,Str(xSuplente,2),MonCol)
   @11,52 Get xApellido  Pict '@S22!' Color MonCol
   ReadOn()
   If LastKey() = 27
      Exit
   EndIf
   @12,52 Get xDomicilio Pict '@S22!' Color MonCol
   @13,52 Get xBarrio    Pict '@S15!' Color MonCol
   @14,52 Get xLocalidad Pict '@S15!' Color MonCol
   ReadOn()
   If LastKey() = 27
      Loop
   EndIf
   If !Provinci->(CargaProvi(15,52))
      Loop
   EndIf
   @16,52 Get xCPostal   Pict '99999' Color MonCol
   @17,52 Get xTelefono  Pict '!!!!-!!!!!!!' Color MonCol
   ReadOn()
   If LastKey()=27
      Loop
   EndIf
   Scr2:=SaveScreen(0,0,24,79)
   BoxFede(11,59,17,65,'Gr+/B')
   @12,61 Prompt 'DNI'
   @13,61 Prompt 'LE '
   @14,61 Prompt 'LC '
   @15,61 Prompt 'CI '
   @16,61 Prompt 'CE '
   Menu to Op
   RestScreen(0,0,24,79,Scr2)
   Do Case
      Case Op=0
      Case Op=1
         Say(18,52,'DNI',MonCol)
         xTipoDoc='DNI'
      Case Op=2
         Say(18,52,'LE ',MonCol)
         xTipoDoc='LE'
      Case Op=3
         Say(18,52,'LC ',MonCol)
         xTipoDoc='LC'
      Case Op=4
         Say(18,52,'CI ',MonCol)
         xTipoDoc='CI'
      Case Op=5
         Say(18,52,'CE ',MonCol)
         xTipoDoc='CE'
   EndCase
   @19,52 Get xDocumento Pict '99999999' Color MonCol
   ReadOn()
   If LastKey() = 27
      Loop
   EndIf
   If _Quest(15,'!!!  A T E N C I O N  !!!',;
                'Debe Grabar Los Datos Ingresados',;
                'จ Confirma ?')
     AxSupl->(DatoSuple(xApellido,xDomicilio,xBarrio,xLocalidad,xProvincia,xCPostal,xTipoDoc,xDocumento,xTelefono,xReserva,xSuplente))
     xSuplente++
   EndIf
EndDo
_SBoxDS(8,37,18,68,Scr1)
Return Nil

Function DatoSuple(xApellido,xDomicilio,xBarrio,xLocalidad,xProvincia,xCPostal,xTipoDoc,xDocumento,xTelefono,xReserva,xSuplente)
VerActiva()
DbAppend()
Replace Reserva   With xReserva
Replace Suplente  With xSuplente
Replace Titular   With xApellido
Replace Domicilio With xDomicilio
Replace Barrio    With xBarrio
Replace Localidad With xLocalidad
Replace Provincia With xProvincia
Replace CPostal   With xCPostal
Replace TDoc      With xTipoDoc
Replace Documento With xDocumento
Replace Telefono  With xTelefono
DbCommit()
DbUnLock()
Return Nil

Function OpenDbf
Local Scr:=SaveScreen(0,0,24,79),Colo:=SetColor()
Local xNum:=26,xConta:=0
TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
If Puesto='26'
   Use ImpCob Exclusive New
   Index On Barrio+Domicilio to ImpCob
   Set Index to ImpCob

   Use ImpMut Exclusive New
   Index On Nombre to ImpMut
   Set Index to ImpMut
EndIf

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use CtaExp Shared New
If !File('CtaExp.Ntx')
   Index On Reserva to CtaExp
EndIf
If !File('CtaExp2.Ntx')
   Index On StrZero(Reserva,6)+StrZero(Ano,4)+StrZero(Mes,2) to CtaExp2
EndIf
Set Index to CtaExp,CtaExp2

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Reserva Shared New
If !File('Reser1.Ntx')
   Index On Reserva to Reser1
EndIf
If !File('Reser2.Ntx')
   Index On Nombre to Reser2
EndIf
If !File('Reser3.Ntx')
   Index On Cobrador to Reser3
EndIf
If !File('Reser4.Ntx')
   Index On Mutual to Reser4
EndIf
Set Index to Reser1,Reser2,Reser3,Reser4

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use ResuCta Shared New
If !File('ResuCta.Ntx')
   Index On Reserva to ResuCta
EndIf
Set Index to ResuCta

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use AuxLiq&Puesto. Alias AuxLiq New

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Recibo Shared New
If !File('Recib1.Ntx')
   Index On StrZero(Reserva,6)+StrZero(Cuota,4) to Recib1
EndIf
If !File('Recib2.Ntx')
   Index On Reserva to Recib2
EndIf
If !File('Recib3.Ntx')
   Index On StrZero(Cobrador,6)+DtoC(Fecha) to Recib3
EndIf
If !File('Recib4.Ntx')
   Index On DtoC(Fecha) to Recib4
EndIf
Set Index to Recib1,Recib2,Recib3,Recib4

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use CtaCte Shared New
If !File('CtaCt1.Ntx')
   Index On Reserva to CtaCt1
EndIf
If !File('CtaCt2.Ntx')
   Index On StrZero(Reserva,6)+StrZero(Cuota,4) to CtaCt2
EndIf
Set Index to CtaCt1,CtaCt2

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Baja Shared New
If !File('Baja1.Ntx')
   Index On Codigo to Baja1
EndIf
Set Index to Baja1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use ParqueNu Shared New
If !File('Parque1.Ntx')
   Index On Reserva to Parque1
EndIf
If !File('Parque2.Ntx')
   Index On Codigo to Parque2
EndIf
If !File('Parque3.Ntx')
   Index On Nombre to Parque3
EndIf
If !File('Parque4.Ntx')
   Index On Documento to Parque4
EndIf
If !File('Parque5.Ntx')
   Index On Sector+Str(Fila,2)+Str(Parcela,2) to Parque5
EndIf
If !File('Parque6.Ntx')
   Index On Cobrador to Parque6
EndIf
Set Index to Parque1,Parque2,Parque3,Parque4,Parque5,Parque6

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Recexpe Shared New
If !File('Recex1.Ntx')
   Index On Codigo+StrZero(Mes,2)+Str(Anio,2) to Recex1
EndIf
Set Index to Recex1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Pexpensa Shared New
If !File('Pexpe1.Ntx')
   Index On Codigo to Pexpe1
EndIf
Set Index to Pexpe1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use SubNivel Shared New
If !File('SubNiv1.Ntx')
   Index On Codigo to SubNiv1
EndIf
If !File('SubNiv2.Ntx')
   Index On Codigo+Str(Nivel,1)+Str(SubNivel,1) to SubNiv2
EndIf
Set Index to SubNiv1,SubNiv2

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Ataud Shared New
If !File('Ataud1.Ntx')
   Index On Codigo to Ataud1
EndIf
Set Index to Ataud1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Auxi&Puesto. Alias Auxiliar Exclusive New
Index On Importe to Auxi&Puesto.
Set Index to Auxi&Puesto.

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Cocheria Shared New
If !File('Coche1.Ntx')
   Index On Codigo to Coche1
EndIf
Set Index to Coche1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Suplente Shared New
If !File('Suple1.Ntx')
   Index On Reserva to Suple1
EndIf
Set Index to Suple1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use AxSup&Puesto. Alias AxSupl Exclusive New
Index On Reserva to AxSup&Puesto.
Set Index to AxSup&Puesto.

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Mutual Shared New
If !File('Mutual.Ntx')
   Index On Asociacion to Mutual
EndIf
Set Index to Mutual

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Cobrador Shared New
If !File('Cobra1.Ntx')
   Index On Cobrador to Cobra1
EndIf
If !File('Cobra2.Ntx')
   Index On Nombre to Cobra2
EndIf
Set Index to Cobra1,Cobra2

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Promotor Shared New
If !File('Promot1.Ntx')
   Index On Promotor to Promot1
EndIf
If !File('Promot2.Ntx')
   Index On Nombre to Promot2
EndIf
Set Index to Promot1,Promot2

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Provinci Shared New
If !File('Prov1.Ntx')
   Index On Codigo to Prov1
EndIf
Set Index to Prov1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Aux&Puesto. Alias AuxiRes Exclusive New
If !File('AuxiRes.Ntx')
   Index On Reserva to AuxiRes
EndIf
Set Index to AuxiRes

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use ExpCta Shared New
If !File('ExpCta1.Ntx')
   Index On Fecha to ExpCta1
EndIf
If !File('ExpCta2.Ntx')
   Index On StrZero(Reserva,6)+StrZero(Anio,4)+StrZero(Mes,2) to ExpCta2 Descending
EndIf
If !File('ExpCta3.Ntx')
   Index On StrZero(Cobrador,6)+DtoC(Fecha) to ExpCta3
EndIf
If !File('ExpCta4.Ntx')
   Index On DtoC(Fecha) to ExpCta4
EndIf
Set Index to ExpCta1,ExpCta2,ExpCta3,ExpCta4

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use AuxParq Shared New
If !File('AuxParq1.Ntx')
   Index On Reserva to AuxParq1
EndIf
Set Index to AuxParq1

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use ValorExp Shared New

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Bisiesto Shared New
If !File('Bisiesto.Ntx')
   Index On Ano to Bisiesto
EndIf
Set Index to Bisiesto

TimeBar(9,13,xNum,++xConta,'Abriendo Bases e Indices')
Use Titular Shared New
If !File('Titular.Ntx')
   Index On Codigo to Titular
EndIf
Set Index to Titular

RestScreen(0,0,24,79,Scr)
Return Nil

Function EnCurso(xLugar,xNombre,xVez,Scr,xFinal)
Local xVa:=(Recno()/LastRec())*100
Local cCompleta:=AllTrim(StrZero((Recno()/LastRec())*100,3))
Local xFila:=18-(xVa/10)
Local xColumna:=xLugar*9
Private tFila1:=tFila2:=0
Say((xFila-1),xColumna,'ีััธ','GR+/B')
    Say(xFila,xColumna,'ณณณณ','GR+/B')
Say(18,xColumna,cCompleta+'%','B+/W+')
If Recno()<2
   tFila1:=Int(xColumna-1-(Len(xNombre)/2))
   tFila2:=Int(xColumna+4+(Len(xNombre)/2))
   BoxFede(19,tFila1,21,tFila2,'W+/R+')
   Say(20,tFila1+3,xNombre,'W+/R+')
EndIf
If Recno()/LastRec()=1
   RestScreen(19,0,22,79,Scr)
   tFila1:=Int(xColumna-1-(Len(xNombre)/2))
   tFila2:=Int(xColumna+4+(Len(xNombre)/2))
   BoxFede(xFinal,tFila1,xFinal+2,tFila2,'W+/R+')
   Say(xFinal+1,tFila1+3,xNombre,'W+/R+')
   Tone(500,1)
EndIf
Return .t.

Static Function ReadOn
SetCursor(1)
Read
SetCursor(0)
Return Nil

Static Function VerMensaje(xMensaje)
Local xColo:=SetColor()
SetColor( 'W+/R+')
MueveLet(xMensaje,.t.)
SetColor(xColo)
Return Nil

