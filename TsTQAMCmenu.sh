#!/bin/ksh 

################################################################################
##
##  Nombre del Programa : TsTQAMCmenu.sh
##                Autor : FJVG
##       Codigo Inicial : 29/06/2020
##          Descripcion : Menu de Construccion de Incoming de MasterCard 
##
##  ======================== Registro de Modificaciones ========================
##
##  Fecha      Autor Version Descripcion de la Modificacion
##  ---------- ----- ------- ---------------------------------------------------
##  29/06/2020 FJVG   1.00    Codigo Inicial
##  24/07/2020 FJVG   2.00    Generación deportes con fallas 
##
################################################################################

################################################################################
## DECLARACION DE DATOS, PARAMETROS DE EJECUCION Y VARIABLES DEL PROGRAMA
################################################################################


## Datos del Programa
################################################################################

dpNom="TsTQAMCmenu"           # Nombre del Programa
dpDesc=""                     # Descripcion del Programa
dpVer=2.00                    # Ultima Version del Programa
dpFec="20200724"              # Fecha de Ultima Actualizacion [Formato:AAAAMMDD]

## Variables del Programa
################################################################################

vpValRet=""                   # Valor de Retorno (funciones)
vpFH=`date '+%Y%m%d%H%M%S'`   # Fecha y Hora [Formato:AAAAMMDDHHMMSS]
vpFileLOG=""                  # Nombre del Archivo LOG del Programa


## Parametros
################################################################################

pMarca="$1"                    # Marca [MC/NG]
pFecProc="$2"                  # Fecha de Proceso [Formato:AAAAMMDD]
pFecSes="$3"                   # Fecha de Sessión [Formato:AAAAMMDD]
Report="$4"                    # Código de los Repostes [058|167|168|120|121|655|470|150|467]


## Variables de Trabajo
################################################################################

vFileCTL=""                   # Archivo de Control del Proceso
vNumSec=""                    # Numero de Secuencia
vOpcRepro=""                  # Opcion de Reproceso
vCTAMC=""                     # Codigo de Tipo de Archivo de MasterCard


################################################################################
## DECLARACION DE FUNCIONES
################################################################################


# f_msg | muestra mensaje en pantalla
# Parametros
#   pMsg    : mensaje a mostrar
#   pRegLOG : registra mensaje en el LOG del Proceso [S=Si(default)/N=No]
################################################################################
f_msg ()
{
pMsg="$1"
pRegLOG="$2"
if [ "${pMsg}" = "" ]; then
   echo
   if [ "${vpFileLOG}" != "" ]; then
      echo >> ${vpFileLOG}
   fi
else
   echo "${pMsg}"
   if [ "${vpFileLOG}" != "" ]; then
      if [ "${pRegLOG}" = "S" ] || [ "${pRegLOG}" = "" ]; then
         echo "${pMsg}" >> ${vpFileLOG}
      fi
   fi
fi
}


# f_vrfvalret | verifica valor de retorno, fin error si el valor es 1
# Parametros
#   pValRet : valor de retorno
#   pMsgErr : mensaje de error
################################################################################
f_vrfvalret ()
{
pValRet="$1"
pMsgErr="$2"
if [ "${pValRet}" != "0" ]; then
   f_finerr "${pMsgErr}"
fi
}

# f_finerr | error en el programa, elimina archivos de trabajo
# Parametros
#   pMsg : mensaje a mostrar
################################################################################
f_finerr ()
{
# <Inicio RollBack>
# <Fin RollBack>
pMsg="$1"
if [ "${pMsg}" != "" ]; then
   f_fhmsg "${pMsg}"
fi
f_msgtit E
}

# f_fhmsg | muestra mensaje con la fecha y hora del sistema
# Parametros
#   pMsg    : mensaje a mostrar
#   pFlgFH  : muestra fecha y hora [S=Si(default)/N=No]
#   pRegLOG : registra mensaje en el LOG del Proceso [S=Si(default)/N=No]
################################################################################
f_fhmsg ()
{
pMsg="$1"
pFlgFH="$2"
pRegLOG="$3"
if [ "$pMsg" = "" ]; then
   f_msg
else
   if [ "$pFlgFH" = "S" ] || [ "$pFlgFH" = "" ]; then
      pMsg="`date '+%H:%M:%S'` > ${pMsg}"
   else
      pMsg="         > ${pMsg}"
   fi
   f_msg "${pMsg}" ${pRegLOG}
fi
}

# f_msgtit | muestra mensaje de titulo
# Parametros
#   pTipo : tipo de mensaje de titulo [I=Inicio/F=Fin OK/E=Fin Error]
################################################################################
f_msgtit ()
{
pTipo="$1"
#Tswchd="$2"
if [ "${dpDesc}" = "" ]; then
   vMsg="${dpNom}"
else
   vMsg="${dpNom} - ${dpDesc}"
fi
if [ "${pTipo}" = "I" ]; then
   vMsg="INICIO | ${vMsg} - Transferencia Archivo T464"  #Reporte SWCHD${Tswchd}"
elif [ "${pTipo}" = "F" ]; then
     vMsg="FIN OK | ${vMsg}"
elif [ "${pTipo}" = "OKF" ]; then
     vMsg="FIN OK | ${vMsg}"
else
   vMsg="FIN ERROR | ${vMsg}"
fi
vMsg="\n\
********************************************************** [`date '+%d.%m.%Y'` `date '+%H:%M:%S'`]
 ${vMsg}\n\
********************************************************************************"
#\n\
#"
f_msg "${vMsg}" S
if [ "${pTipo}" = "E" ]; then
   exit 1;
elif [ "${pTipo}" = "F" ]; then
   exit 0;
fi
}

# f_msgtit | muestra mensaje de titulo Naiguata
# Parametros
#   pTipo : tipo de mensaje de titulo [I=Inicio/F=Fin OK/E=Fin Error]
################################################################################
f_msgtit2 ()
{
pTipo="$1"
Tswchd="$2"
if [ "${dpDesc}" = "" ]; then
   vMsg="${dpNom}"
else
   vMsg="${dpNom} - ${dpDesc}"
fi
if [ "${pTipo}" = "I" ]; then
   vMsg="INICIO | ${vMsg} - Reporte SWCHD${Tswchd}"
elif [ "${pTipo}" = "F" ]; then
     vMsg="FIN OK | ${vMsg}"
else
   vMsg="FIN ERROR | ${vMsg}"
fi
vMsg="\n\
********************************************************** [`date '+%d.%m.%Y'` `date '+%H:%M:%S'`]
 ${vMsg}\n\
********************************************************************************"
#\n\
#"
f_msg "${vMsg}" S
if [ "${pTipo}" = "E" ]; then
   exit 1;
elif [ "${pTipo}" = "F" ]; then
   exit 0;
fi
}

# f_fechora | cambia el formato de la fecha y hora
#             YYYYMMDD > DD/MM/YYYY
#             HHMMSS > HH:MM:SS
#             YYYYMMDDHHMMSS > DD/MM/YYYY HH:MM:SS
# Parametros
#   pFH : fecha/hora
################################################################################
f_fechora ()
{
pFH="$1"
vLong=`echo ${pFH} | awk '{print length($0)}'`
case ${vLong} in
     8)  # Fecha
         vDia=`echo $pFH | awk '{print substr($0,7,2)}'`
         vMes=`echo $pFH | awk '{print substr($0,5,2)}'`
         vAno=`echo $pFH | awk '{print substr($0,1,4)}'`
         vpValRet="${vDia}/${vMes}/${vAno}";;
     6)  # Hora
         vHra=`echo $pFH | awk '{print substr($0,1,2)}'`
         vMin=`echo $pFH | awk '{print substr($0,3,2)}'`
         vSeg=`echo $pFH | awk '{print substr($0,5,2)}'`
         vpValRet="${vHra}:${vMin}:${vSeg}";;
     14) # Fecha y Hora
         vDia=`echo $pFH | awk '{print substr($0,7,2)}'`
         vMes=`echo $pFH | awk '{print substr($0,5,2)}'`
         vAno=`echo $pFH | awk '{print substr($0,1,4)}'`
         vHra=`echo $pFH | awk '{print substr($0,9,2)}'`
         vMin=`echo $pFH | awk '{print substr($0,11,2)}'`
         vSeg=`echo $pFH | awk '{print substr($0,13,2)}'`
         vpValRet="${vDia}/${vMes}/${vAno} ${vHra}:${vMin}:${vSeg}";;
esac
}

f_menuCAB ()
{

   clear
   echo "*******************************************************************************"
   echo "*                       SISTEMA DE GESTION DE COMERCIOS                 ${COD_AMBIENTE}  *"
   if [ "$pMarca" = "MC" ]; then
      echo "*                     Incoming  de  Maestro  Master  Card                     *"
   elif [ "$pMarca" = "NG" ]; then
      echo "*                     Incoming  de  Maestro  Naiguata                         *"
   fi
   echo "*******************************************************************************"

}


# f_menuDAT () | menu de informacion
################################################################################
f_menuDAT ()
{

   if [ "$vOpcRepro" = "S" ]; then
      vRepro="SI"
   else
      vRepro="NO"
   fi

   f_fechora ${vFecSes}
   vFecSesF=${vpValRet}
   f_fechora ${vFecProc}
   vFecProcF=${vpValRet}
   echo " Fecha de Sesion: ${vFecSesF}                     Fecha de Proceso: ${vFecProcF}"
}



# f_menuOPC () | menu de opciones
################################################################################
f_menuOPC ()
         echo "-------------------------------------------------------------------------------"
         echo "  ENTRANTE SELECCIONADO                                     TIPO REPORTE"
         echo " ----------------------------------------------      --------------------------"
         echo "                                                         OK [00]   FALLAS [01] " 
         if [ "${Report}" = "470" ]; then  
            echo " [ X] CREAR INC MC Debito Maestro (TT${Report})                                "
         elif [ "${Report}" = "461" ]; then
            echo "prueba reporte 461" 
         else
            echo "prueba reporte ultima opción" 
         fi
         echo
         echo
         echo "-------------------------------------------------------------------------------"
         echo " Ver $dpVer | Telefonica Servicios Transaccionales                  [Q] Salir"
         echo "-------------------------------------------------------------------------------"
         echo
         echo "   Seleccione Opcion => \c"

}

################################################################################
## INICIO | PROCEDIMIENTO PRINCIPAL
################################################################################

echo


## Fecha de Proceso
################################################################################

if [ "${pFecProc}" = "" ]; then
   vFecProc=`getdate`
else
   ValFecha.sh ${pFecProc}
   vRet="$?"
   if [ "$vRet" != "0" ]; then
      f_msg "Fecha de Proceso Incorrecta (FecProc=${pFecProc})"
      f_msg
      exit 1;
   fi
   vFecProc=${pFecProc}
fi

## Fecha de Sesion
################################################################################

if [ "${pFecSes}" = "" ]; then
   vFecSes=`getdate -1`
else
   ValFecha.sh ${pFecSes}
   vRet="$?"
   if [ "$vRet" != "0" ]; then
      f_msg "Fecha de Sesion Incorrecta (FecProc=${pFecSes})"
      f_msg
      exit 1;
   fi
   vFecSes=${pFecSes}
fi


## Opcion de Reproceso
################################################################################

vOpcRepro="N"


## Archivo de Control
################################################################################

while ( test -z "$vOpcion" || true ) do

   f_menuCAB
   f_menuDAT
   f_menuOPC

   if [ "${vOpcion}" = "" ]; then
      echo
      echo "   Seleccione Opcion => \c"
      read vOpcion
      if [ "$vOpcion" = "q" ] || [ "$vOpcion" = "Q" ]; then
         echo
         exit 0
      fi
   fi

   vFlgOpcErr="S"

   if [ "$vOpcion" = "" ]; then
      # Vuelve a mostrar el menu
      vFlgOpcErr="N"
   fi


   # CONSTRUCCION DE ENTRANTES MAESTRO
   ###########################################################################################
   #  INICIO 
   ###########################################################################################

  if [ "$vOpcADQ" = "00" ]; then  # Incoming MARCA MASTER CARD
            vFlgOpcErr="N"
            vOpcion=""
            trap "trap '' 2" 2
            TsTQAMCppkg.sh MC ${vFecProc} ${vFecSes} N   # N= sin fallas registros FREC Y EREC
            trap ""
   fi # Incoming MARCA MASTER CARD

   if [ "$vOpcADQ" = "01" ]; then  # Incoming MARCA NAIGUATA
            vFlgOpcErr="N"
            vOpcion=""
            trap "trap '' 2" 2
            TsTQAMCppkg.sh NG ${vFecProc} ${vFecSes} S   # S= Con fallas registros FREC Y NREC
            trap ""
   fi # Incoming MARCA NAIGUATA


   if [ "$vFlgOpcErr" = "S" ]; then
      vOpcion=""
      echo
      f_msg "${dpNom} - Opcion Incorrecta."
      echo
      echo "... presione [ENTER] para continuar."
      read vContinua
   fi

done

################################################################################
## FIN | PROCEDIMIENTO PRINCIPAL
################################################################################
