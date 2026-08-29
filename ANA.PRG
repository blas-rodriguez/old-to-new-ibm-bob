Use BaseP Exclusive New
Zap

Use ParqueNu Shared New
If !File('Par.Ntx')
   Index on Codigo to Par
EndIf
Set Index to Par

Use SubNivel Shared New
Index On Codigo to subbb
Set Index to Subbb
DbGoTop()
While !Eof()
   xCod:=Codigo
   ?xCod
   If ParqueNu->(DbSeek(xCod))
      ??'Encuentra'
      If ParqueNu->Tipo_P_S='M'
         ??'Municipal'
         BaseP->(DbAppend())
         Replace BaseP->Codigo With xCod,;
                 BaseP->Fecha With SubNivel->FechaI,;
                 BaseP->Cocheria With SubNivel->Cocheria

      EndIf
   EndIf
   Inkey(0)
   DbSkip()
EndDo
Return Nil
