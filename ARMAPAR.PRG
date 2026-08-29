Cls
AbreSet()
Use ParqueNu Exclusive New
xSector:='   '
xFila:=0
xParcela:=0
xdSector:=xhSector:=0
While .t.
    @10,10 Say ' Ingrese Sector :' Get xSector Pict '99!'
    @11,10 Say ' Ingrese Fila   :' Get xFila Pict '99'
    @12,10 Say ' Ingrese Parcela Desde :' Get xdSector Pict '99'
    @13,10 Say ' Ingrese Parcela Hasta :' Get xhSector Pict '99'
    ReadOn()
    If LastKey()=27
       Exit
    EndIf
    For t=xdSector to xhSector
       xCodigo:=xSector+StrZero(xFila,2)+StrZero(t,2)
       ?xCodigo
       DbAppend()
       Replace Codigo With xCodigo,;
               Sector With xSector,;
               Fila   With xFila,;
               Parcela With t
     Next t
     Inkey(0)
     Cls
EndDo
Return

