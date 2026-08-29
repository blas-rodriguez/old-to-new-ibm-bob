*/cls
Private xGrupo:=002
Private xMutual:='GRUPO DEMO - BANCO DEMO'
Private xMes:='ENERO DE 2000'

ValGr:='Imp'+StrZero(xGrupo,3)

Use &ValGr. Alias Mary Exclusive New
Mary->(__DbZap())

Use Titular.Sn Shared New
Set Index to Tit3

Use Respon.Sn Shared New
Set Index to Respo1

Use Auxi01.Sn Shared New
*Set index to Auxi
DbGoTop()
x:=0
While !Eof()
   Mary->(DbAppend())
   Titular->(DbSeek(Auxi01->Socio))
   Respon->(DbSeek(Auxi01->Socio))
   If Titular->Agencia=1
      Repla Mary->NumSuc with 0
   ElseIf Titular->Agencia=19    ///// AGENCIA DEMO 19
      Repla Mary->NumSuc with 3
   ElseIf Titular->Agencia=21   ///// AGENCIA DEMO 21
      Repla Mary->NumSuc with 2
   EndIf
   Repla Mary->Grupo with xGrupo,;
         Mary->Cuenta with Respon->Cuenta,;
         Mary->Moneda with 01,;
         Mary->Nombre with Auxi01->Responsabl,;
         Mary->NroDoc with Val(Auxi01->R_Document),;
         Mary->Importe with Auxi01->Cuota
   DbSkip()
EndDo
cls
DbCloseAll()
*/Return

Use &ValGr. Alias Mary Exclusive New
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
Clear All
Return

Function Cabecera
@1,1 say 'EEMPRESA DEMO S.R.L.F'
@2,1 say 'Prestaciones Asistenciales'
@4,1 say xMutual
@5,1 say '4'+xMes+'5'
@7,1 say 'E4Sucur Gp  C u e n t a Mn       Apellido y Nombre       Document  ImporteF5'
@8,1 say '----- -- ------------ -- ----------------------------- -------- --------'
Return Nil
