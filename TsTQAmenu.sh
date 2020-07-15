#!/bin/ksh

################################################################################
##
##  Nombre del Programa : TsTQAmenu.sh
##                Autor : FJVG
##       Codigo Inicial : 29/06/2020
##          Descripcion : Menu de Herramientas de TST QA 
##  ======================== Registro de Modificaciones ========================
##
##  Fecha      Autor Version Descripcion de la Modificacion
##  ---------- ----- ------- ---------------------------------------------------
##  29/06/2020 FJVG  1.00    Codigo Inicial

################################################################################

################################################################################
## DECLARACION DE DATOS, PARAMETROS DE EJECUCION Y VARIABLES DEL PROGRAMA
################################################################################


## Datos del Programa
################################################################################

dpNom="TsTQAmenu"             # Nombre del Programa
dpDesc=""                     # Descripcion del Programa
dpVer=1.00                    # Ultima Version del Programa
dpFec="20200629"              # Fecha de Ultima Actualizacion [Formato:AAAAMMDD]

## Variables del Programa
################################################################################

vpValRet=""                   # Valor de Retorno (funciones)
vpFH=`date '+%Y%m%d%H%M%S'`   # Fecha y Hora [Formato:AAAAMMDDHHMMSS]
vpFileLOG=""                  # Nombre del Archivo LOG del Programa


## Parametros
################################################################################


## Variables de Trabajo
################################################################################

vFecSes=""                    # Fecha de Sesion
vFecProc=""                   # Fecha de Proceso

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

# f_getCTAMC () | codigo de tipo de archivo
################################################################################
f_getCTAMC ()
{

pTipo="$1"

if [ "${pTipo}" = "INCOMING" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,1,3)}'`
elif [ "${pTipo}" = "INCRET" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,4,3)}'`
elif [ "${pTipo}" = "INCMATCH" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,7,3)}'`
elif [ "${pTipo}" = "INCMAESTRONGTA" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,10,3)}'`
elif [ "${pTipo}" = "REPCREDMC" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,13,3)}'`
elif [ "${pTipo}" = "REPDEBMAESTRO" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,16,3)}'`
elif [ "${pTipo}" = "REPDEBMAESTROSW" ]; then
     vpValRet=`echo $COD_TIPOARCHMC_NGTA | awk '{print substr($0,19,5)}'`
fi

}


# f_menuCAB () | Encabezado Menu Principal
################################################################################
f_menuCAB ()
{

   clear
   echo "*******************************************************************************"
   echo "*                       SISTEMA DE GESTION DE COMERCIOS                 ${COD_AMBIENTE}  *"
   echo "*                  MENU PRINCIPAL DE HERRAMIENTAS QA DE TST                   *"
   echo "*******************************************************************************"

}


# f_menuDAT () | menu de informacion
################################################################################
f_menuDAT ()
{

   f_fechora ${vFecSes}
   vFecSesF=${vpValRet}
   f_fechora ${vFecProc}
   vFecProcF=${vpValRet}
   echo " Fecha de Sesion: ${vFecSesF}                     Fecha de Proceso: ${vFecProcF}"

}


# f_menuOPC () | menu de opciones
################################################################################
f_menuOPC ()
{

   echo "-------------------------------------------------------------------------------"
   echo
   echo "   PROCESOS                                 CONFIGURACION"
   echo "  -------------------------------------    ----------------------------------"
   echo "   [ 1] Construir Incoming de MC             [00]  Fecha de Sesion"
   echo "                                             [01]  Fecha de Proceso"
   echo "  "
   echo "-------------------------------------------------------------------------------"
   echo " Ver $dpVer | Telefonica Servicios Transaccionales                     [Q] Salir"
   echo "-------------------------------------------------------------------------------"

}
# f_admCTL () | administra el Archivo de Control (lee/escribe)
# Parametros
#   pOpcion   : R=lee/W=escribe
################################################################################
f_admCTL ()
{

  # Estructura del Archivo de Control
  # [01-02] Codigo de Entidad Adquirente
  # [04-11] Fecha de Proceso
  # [16-16] Estado del Proceso (P=Pendiente/X=En Ejecucion/E=Fin ERROR/F=Fin OK)
  # [18-19] Codigo del Sub-Proceso
  # [21-33] Fecha y Hora de Actualizacion de los Estados [AAAAMMDDHHMMSS]

  pOpcion="$1"

  if [ "$pOpcion" = "R" ]; then
     if ! [ -f "$vFileCTL" ]; then
        # Crea el Archivo CTL
        vEstProc="P"
        vSubProc="00"
        echo "${pEntAdq}|${pFecProc}|${vEstProc}|${vSubProc}|`date '+%Y%m%d%H%M%S'`" > $vFileCTL
     else
        vEstProc=`awk '{print substr($0,16,1)}' $vFileCTL`
     fi
  else
     echo "${pEntAdq}|${pFecProc}|${vEstProc}|${vSubProc}|`date '+%Y%m%d%H%M%S'`" > $vFileCTL
  fi

}


################################################################################



################################################################################
## INICIO | PROCEDIMIENTO PRINCIPAL
################################################################################

echo

## Fecha de Sesion
################################################################################

vFecSes=`getdate -1`
vFecProc=`getdate`
vOpcRepro="N"

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

   #vFlgOpcErr="S"

   if [ "$vOpcion" = "" ]; then
      # Vuelve a mostrar el menu
      vFlgOpcErr="N"
   fi


   # INCOMING DE MASTER CARD 

   if [ "$vOpcion" = "1" ]; then   # construccion Incoming de Maestro MasterCard

         
      clear   #limpia la pantalla para visualizar mejor el menu ip1302 fjvg
      f_menuCAB
      vFlgOpcErr="N"
      vOpcion=""
      ############################################################
         f_getCTAMC INCOMING
         vpValRet_3=${vpValRet}
         f_getCTAMC INCRET
         vpValRet_4=${vpValRet}
         f_getCTAMC INCMATCH
         vpValRet_5=${vpValRet}
         f_getCTAMC INCMAESTRONGTA
         vpValRet_6=${vpValRet}
         f_getCTAMC REPCREDMC
         vpValRet_8=${vpValRet}
         f_getCTAMC REPDEBMAESTRO
         vpValRet_9=${vpValRet}
         f_getCTAMC REPDEBMAESTROSW
         vpValRet_10=${vpValRet}

         echo "-------------------------------------------------------------------------------"
         echo "  SELECCIONAR ENTRANTES                           "
         echo " ----------------------------------------------    "

         echo " [ 1] CREAR INC MC Debito Maestro (TT${vpValRet_6})       "
         echo
         echo
         echo "-------------------------------------------------------------------------------"
         echo " Ver $dpVer | Telefonica Servicios Transaccionales                  [Q] Salir"
         echo "-------------------------------------------------------------------------------"
         echo
         echo "   Seleccione Opcion => \c"
         read vOpcADQ

         if [ "$vOpcADQ" = "q" ] || [ "$vOpcADQ" = "Q" ]; then
            vOpcion=""
            vFlgOpcErr="N"
         fi

         if [ "$vOpcADQ" = "" ]; then
            vOpcion="00"
            vFlgOpcErr="N"
         fi

         if [ "$vOpcADQ" = "1" ]; then  # Incoming MARCA MASTER CARD
            vFlgOpcErr="N"
            vOpcion=""
            trap "trap '' 2" 2
            TsTQAMCmenu.sh MC ${vFecProc} ${vFecSes}
            trap ""
         fi # Incoming MARCA MASTER CARD

         if [ "$vOpcADQ" = "2" ]; then  # Incoming MARCA NAIGUATA
            vFlgOpcErr="N"
            vOpcion=""
            trap "trap '' 2" 2
            TsTQAMCmenu.sh NG ${vFecProc} ${vFecSes}
            trap ""
         fi # Incoming MARCA NAIGUATA


         if [ "$vFlgOpcErr" = "S" ]; then
            vOpcion="00"
            echo
            f_msg "${dpNom} - Opcion Incorrecta."
            echo
            echo "... presione [ENTER] para continuar."
            read vContinua
         fi

         vFlgOpcErr="N"

      ############################################################

   fi # Incoming de Maestro MasterCard

   # INCOMING DE VISA

   if [ "$vOpcion" = "2" ]; then

         clear   #limpia la pantalla para visualizarmejor el menu ip1302 fjvg
         f_menuCAB
         vFlgOpcErr="N"
         vOpcion=""
         
         echo "    [xx]  Incoming de Visa NAIGUATA <<<EN CONTRUCCION>>>"
         trap ""   
   fi # Opcion 2 - Incoming Naiguata VISA
   
   if [ "$vFlgOpcErr" = "S" ]; then
      vOpcion="00"
      echo
      f_msg "${dpNom} - Opcion Incorrecta."
      echo
      echo "... presione [ENTER] para continuar."
      read vContinua
   fi

   vFlgOpcErr="N"
  
  
   # FECHA DE SESION

   if [ "$vOpcion" = "00" ]; then

      vFlgOpcErr="N"
      vOpcion=""

      echo
      echo " Fecha de Sesion (Formato: AAAAMMDD,[Enter]=SYSDATE-1) => \c"
      read vModFecSes

      if [ "$vModFecSes" = "" ]; then
         vFecSes=`getdate -1`
      else
         ValFecha.sh $vModFecSes
         vRet=$?
         if [ "$vRet" = "0" ]; then
            # Confirmacion si la fecha de sesion es igual o mayor a la actual
            vFecSys="`getdate`"
            vFlgModFec="S"
            if [ "$vModFecSes" -ge "$vFecSys" ]; then
               vFlgModFec="N"
               echo
               echo "--------------------------------------------------------------------------------"
               echo " CONFIRMACION DE CAMBIO DE FECHA DE SESION"
               echo "--------------------------------------------------------------------------------"
               echo
               echo " La Fecha de Sesion ingresada es igual o mayor a la fecha actual."
               echo
               echo " Desea Continuar? (S=Si/N=No/[Enter]=No) => \c"
               read vConf
               if [ "$vConf" = "S" ] || [ "$vConf" = "s" ]; then
                  vFlgModFec="S"
               fi
            fi
            if [ "$vFlgModFec" = "S" ]; then
               vFecSes=$vModFecSes
            fi
         else
            echo
            f_fhmsg "La Fecha de Sesion Ingresada es Incorrecta."
            echo
            echo "... presione [ENTER] para continuar."
            read vContinua
         fi
      fi

   fi  # Opcion 00 - Fecha de Sesion


   # FECHA DE PROCESO

   if [ "$vOpcion" = "01" ]; then

      vFlgOpcErr="N"
      vOpcion=""

      echo
      echo " Fecha de Proceso (Formato: AAAAMMDD,[Enter]=SYSDATE) => \c"
      read vModFecProc

      if [ "$vModFecProc" = "" ]; then
         vFecProc=`getdate`
      else
         ValFecha.sh $vModFecProc
         vRet=$?
         if [ "$vRet" = "0" ]; then
            # Confirmacion si la fecha de Proceso es igual o mayor a la actual
            vFecSys="`getdate`"
            vFlgModFec="S"
            if [ "$vModFecProc" -gt "$vFecSys" ]; then
               vFlgModFec="N"
               echo
               echo "--------------------------------------------------------------------------------"
               echo " CONFIRMACION DE CAMBIO DE FECHA DE PROCESO"
               echo "--------------------------------------------------------------------------------"
               echo
               echo " La Fecha de Proceso ingresada es mayor a la fecha actual."
               echo
               echo " Desea Continuar? (S=Si/N=No/[Enter]=No) => \c"
               read vConf
               if [ "$vConf" = "S" ] || [ "$vConf" = "s" ]; then
                  vFlgModFec="S"
               fi
            fi
            if [ "$vFlgModFec" = "S" ]; then
               vFecProc=$vModFecProc
            fi
         else
            echo
            f_fhmsg "La Fecha de Proceso Ingresada es Incorrecta."
            echo
            echo "... presione [ENTER] para continuar."
            read vContinua
         fi
      fi

   fi  # Opcion 01 - Fecha de Proceso


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
