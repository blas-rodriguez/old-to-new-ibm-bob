
Function Inhumacion
Public xDesde:=xHasta:=Date()
BoxFede(15,10,17,53)
@16,13 Say 'Desde :' Get xDesde Pict '@D'
@16,33 Say 'Hasta :' Get xHasta Pict '@D' Valid xHasta>=xDesde
Read
DbSetFilter({|| FechaI >= xDesde .And. FechaI <= xHasta})
DbGoTop()
xCantidad:=0
xCanSocio:=0
xCanOtras:=0
xCanParti:=0
xNivel1:=0
xNivel2:=0
xNivel3:=0
xSubNivel1:=0
xSubNivel2:=0
xSubNivel3:=0
xCanEspec:=0
xCoche1:=0
xCoche2:=0
xCoche3:=0
xCoche4:=0
xTipo1S:=0
xTipo1T:=0
xTipo2S:=0
xTipo2T:=0
xTipo3T:=0
xTipo3S:=0
xTipo4T:=0
xTipo4S:=0
tNivel1:=.f.
tNivel2:=.f.
tNivel3:=.f.
While !Eof()
  xCodigo:=Codigo
  xCantidad++
  Parque->(DbSetOrder(2))
  If Parque->(DbSeek(xCodigo))
     If Upper(Parque->Tipo_P_S)='S'
        xCanSocio++
     ElseIf Upper(Parque->Tipo_P_S)='P'
        xCanParti++
     ElseIf Upper(Parque->Tipo_P_S)='V'
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
       If Upper(Parque->Tipo_P_S)='S'
          xTipo1S++
       Else
          xTipo1T++
       EndIf
  ElseIf Cocheria=2
       xCoche2++
       If Upper(Parque->Tipo_P_S)='S'
          xTipo2S++
       Else
          xTipo2T++
       EndIf
  ElseIf Cocheria=3
     xCoche3++
     If Upper(Parque->Tipo_P_S)='S'
        xTipo3S++
     Else
        xTipo3T++
     EndIf
  Else
    xCoche4++
     If Upper(Parque->Tipo_P_S)='S'
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
Parque->(DbSetOrder(1))
Return Nil

Function Listado
Public Vec:={}
*AADD(Vec,PadR(''+Empresa->Nombre+'',81))
*AADD(Vec,PadR('4'+Empresa->Servicio+'5',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('Listado General',81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('Fecha Desde'+DtoC(xDesde)+'    '+'Fecha Hasta'+DtoC(xHasta),81))
AADD(Vec,Spac(77))
AADD(Vec,PadR('Total         : '+Str(xCantidad,3),77))
AADD(Vec,PadR('Socios        : '+Str(xCanSocio,3),77))
AADD(Vec,PadR('Particulares  : '+Str(xCanParti,3),77))
AADD(Vec,PadR('Plan 120 x 20 : '+Str(xCanEspec,3),77))
AADD(Vec,PadR('Otros         : '+Str(xCanOtras,3),77))
AADD(Vec,PadR('Cocheria Demo 1     : '+Str(xCoche1,3)+'  Traslados : '+Str(xTipo1T,3)+'  Servicios : '+Str(xTipo1S,3),77))
AADD(Vec,PadR('Cocheria Demo 2  : '+Str(xCoche2,3)+'  Traslados : '+Str(xTipo2T,3)+'  Servicios : '+Str(xTipo2S,3),77))
AADD(Vec,PadR('Cocheria Demo 3 : '+Str(xCoche3,3)+'  Traslados : '+Str(xTipo3T,3)+'  Servicios : '+Str(xTipo3S,3),77))
AADD(Vec,PadR('Cocheria Otros    : '+Str(xCoche4,3)+'  Traslados : '+Str(xTipo4T,3)+'  Servicios : '+Str(xTipo4S,3),77))
AADD(Vec,PadR('Nivel 1       : '+Str(xNivel1,3)+'  SubNivel 1 : '+Str(xSubNivel1,3),77))
AADD(Vec,PadR('Nivel 2       : '+Str(xNivel2,3)+'  SubNivel 2 : '+Str(xSubNivel2,3),77))
AADD(Vec,PadR('Nivel 3       : '+Str(xNivel3,3)+'  SubNivel 3 : '+Str(xSubNivel3,3),77))
MChoice(Vec,12,'D',.t.)
Return Nil









