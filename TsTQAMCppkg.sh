#!/bin/ksh

################################################################################
##
##  Nombre del Programa : TstQAMCppkq.sh
##                Autor : FJVG
##       Codigo Inicial : 24/07/2020
##          Descripcion : Procesos Construción de Entrantes
##
##  ======================== Registro de Modificaciones ========================
##
##  Fecha      Autor Version Descripcion de la Modificacion
##  ---------- ----- ------- ---------------------------------------------------
##  24/07/2020 FJVG   1.00    Codigo Inicial
##
################################################################################

################################################################################
## DECLARACION DE DATOS, PARAMETROS DE EJECUCION Y VARIABLES DEL PROGRAMA
################################################################################

## Datos del Programa
################################################################################

dpNom="TsTQAMCppkq"            # Nombre del Programa
dpDesc=""                      # Descripcion del Programa
dpVer=1.00                     # Ultima Version del Programa
dpFec="20200724"               # Fecha de Ultima Actualizacion [Formato:AAAAMMDD]

## Variables del Programa
################################################################################

vpValRet=""                    # Valor de Retorno (funciones)
vpFH=`date '+%Y%m%d%H%M%S'`    # Fecha y Hora [Formato:AAAAMMDDHHMMSS]
vpFileLOG=""                   # Nombre del Archivo LOG del Programa

## Parametros de Ejecucion
################################################################################

pMarca="$1"                    # Marca [MC/NG]
pFecProc="$2"                  # Fecha de Proceso [Formato:AAAAMMDD]
pFecSes="$3"                   # Fecha de Sessión [Formato:AAAAMMDD]
ActBug="$4"                    # Actuvar Bug en los reportes [Maestro 470 S=Si N=No]


## Variables de Trabajo
################################################################################

vNomFile_IdAdq=""              # Nombre del Archivo de Datos - Adquiriente
vNomFile_FeJul=""              # Nombre del Archivo de Datos - Fecha Juliana
vNomFile_Prefi=""              # Nombre del Archivo de Datos - Prefijo
vNomFile_SecA=""               # Secuencia del años en curso ultimo digito Ex: 2020 Seria 0 Ex2: 2021 Seria 1 IPR 1302

vEntidad=""                    # Nombre de la Entidad
vEntidadIdB=""                 # Identificador Banco #IPR1302 NAIGUATA
vCodAmbi=""                    # Codigo de Ambiente
vNomFile=""                    # Nombre del Archivo de Datos
vFileDIR=""                    # Nombre del Archivo con Lista "vFileDAT" Existentes
vFileDAT=""                    # Archivo de Datos a Cargar
vFileTMP=""                    # Archivo Temporal para agregar saltos de linea
vFileCTL=""                    # Archivo de Control de la Carga
vFileCAR=""                    # Archivo LOG de la Carga
vFileBAD=""                    # Archivo de Errores de la Carga
vFileDSC=""                    # Archivo de Registros Descartados


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


# f_msgtit | muestra mensaje de titulo
# Parametros
#   pTipo : tipo de mensaje de titulo [I=Inicio/F=Fin OK/E=Fin Error]
################################################################################
f_msgtit ()
{
pTipo="$1"
if [ "${dpDesc}" = "" ]; then
   vMsg="${dpNom}"
else
   vMsg="${dpNom} - ${dpDesc}"
fi
if [ "${pTipo}" = "I" ]; then
   vMsg="INICIO | ${vMsg}"
elif [ "${pTipo}" = "F" ]; then
     vMsg="FIN OK | ${vMsg}"
else
   vMsg="FIN ERROR | ${vMsg}"
fi
vMsg="\n\
********************************************************** [`date '+%d.%m.%Y'` `date '+%H:%M:%S'`]
 ${vMsg}\n\
********************************************************************************
\n\
"
f_msg "${vMsg}" S
if [ "${pTipo}" = "E" ]; then
   exit 1;
elif [ "${pTipo}" = "F" ]; then
   exit 0;
fi
}


# f_parametros | muestra los parametros de ejecucion
################################################################################
f_parametros ()
{
f_fechora ${dpFec}
echo "
--------------------------------------------------------------------------------
${dpNom} - Parametros de Ejecucion

pEntAdq  (obligatorio): Entidad Adquirente
                        [BM=Banco Mercantil/BP=Banco Provincial]
pFecProc (opcional)   : Fecha de Proceso [Formato: AAAAMMDD, default=SYSDATE]
--------------------------------------------------------------------------------
Programa: ${dpNom} | Version: ${dpVer} | Modificacion: ${vpValRet}
" | more
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

# f_menuOPC_B () | menu de opciones
################################################################################
f_menuOPC ()
{

   echo
   echo " Seleccione el Adquirente:"
   echo "------------------------------------------------"
   echo "   [0105] Banco Mercantil"
   echo "   [0108] Banco Provincial"
   echo "   [Q] Cancelar"
   echo

}

################################################################################
## INICIO | PROCEDIMIENTO PRINCIPAL
################################################################################

dpDesc="Procesos Construción de Entrantes"



## Crea Archivo LOG del Programa
################################################################################

vpFileLOG="${DIRLOG}/${vFileID}.LOG"

echo > ${vpFileLOG}


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

## Procesos ORACLE
################################################################################

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

   if [ "$vOpcion" = "0105" ]; then

      vFlgOpcErr="N"
      vOpcion=""

      # Verifica el Estado del Proceso en el Archivo de Control
      ## Procesos ORACLE
      ################################################################################
      if [ "$pMarca" = "MC" ]; then  # BUILD Incoming Master Card - MERCANTIL
         vFlgOpcErr="N"
         vOpcion=""
         # Verifica el Estado del Proceso en el Archivo de Control
         ## Procesos ORACLE
         ################################################################################
         f_fhmsg "Procesando Construccion de Incoming..."
         f_fhmsg "Master Card Mercantil..."
         vRet=`ORAExec.sh "exec :rC:=PBUILDINCMC_B.F_MAIN ('${pFecSes}','${pFecProc}','BM','MC','$ActBug');" $DB`
         f_vrfvalret "$?" "Error al ejecutar PBUILDINCMC.F_MAIN. Avisar a Soporte."
         vEst=`echo $vRet | awk '{print substr($0,1,1)}'`
         if [ "$vEst" = "0" ]; then
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,2,23)}'`
            f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            f_fhmsg "Busca en File_Out"
            sleep 10  
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,25,23)}'`
            if [ "${vFileOUTMC}" != "" ]; then
               f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            fi
         elif [ "$vEst" = "W" ]; then
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_fhmsg "$vRet"
         else
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_finerr "$vRet"
         fi
      fi # Incoming MC - MERCANTIL

   
      if [ "$pMarca" = "NG" ]; then  # BUILD Incoming Naiguata - MERCANTIL
         vFlgOpcErr="N"
         vOpcion=""
         # Verifica el Estado del Proceso en el Archivo de Control
         ## Procesos ORACLE
         ################################################################################
         f_fhmsg "Procesando Construccion de Incoming..."
         f_fhmsg "Naiguata Mercantil..."
         vRet=`ORAExec.sh "exec :rC:=PBUILDINCMC.F_MAIN ('${pFecSes}','${pFecProc}','BM','NGTA','$ActBug');" $DB`
         f_vrfvalret "$?" "Error al ejecutar PBUILDINCMC.F_MAIN. Avisar a Soporte."
         vEst=`echo $vRet | awk '{print substr($0,1,1)}'`
         if [ "$vEst" = "0" ]; then
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,2,23)}'`
            f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            f_fhmsg "Busca en File_Out"
            sleep 10  
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,25,23)}'`
            if [ "${vFileOUTMC}" != "" ]; then
               f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            fi
         elif [ "$vEst" = "W" ]; then
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_fhmsg "$vRet"
         else
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_finerr "$vRet"
         fi
      fi # Incoming MC - MERCANTIL

   fi # Opcion 1 - INCOMING DEBITO MAESTRO MERCANTIL


   if [ "$vOpcion" = "0108" ]; then

      vFlgOpcErr="N"
      vOpcion=""

      # Verifica el Estado del Proceso en el Archivo de Control
      ## Procesos ORACLE
      ################################################################################
      if [ "$pMarca" = "MC" ]; then  # BUILD Incoming Master Card - PROVINCIAL
         vFlgOpcErr="N"
         vOpcion=""
         # Verifica el Estado del Proceso en el Archivo de Control
         ## Procesos ORACLE
         ################################################################################
         f_fhmsg "Procesando Construccion de Incoming..."
         f_fhmsg "Master Card PROVINCIAL..."
         vRet=`ORAExec.sh "exec :rC:=PBUILDINCMC_B.F_MAIN ('${pFecSes}','${pFecProc}','BP','MC','$ActBug');" $DB`
         f_vrfvalret "$?" "Error al ejecutar PBUILDINCMC.F_MAIN. Avisar a Soporte."
         vEst=`echo $vRet | awk '{print substr($0,1,1)}'`
         if [ "$vEst" = "0" ]; then
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,2,23)}'`
            f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            f_fhmsg "Busca en File_Out"
            sleep 10  
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,25,23)}'`
            if [ "${vFileOUTMC}" != "" ]; then
               f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            fi
         elif [ "$vEst" = "W" ]; then
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_fhmsg "$vRet"
         else
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_finerr "$vRet"
         fi
      fi # Incoming MC - PROVINCIAL

   
      if [ "$pMarca" = "NG" ]; then  # BUILD Incoming Naiguata - PROVINCIAL
         vFlgOpcErr="N"
         vOpcion=""
         # Verifica el Estado del Proceso en el Archivo de Control
         ## Procesos ORACLE
         ################################################################################
         f_fhmsg "Procesando Construccion de Incoming..."
         f_fhmsg "Naiguata PROVINCIAL..."
         vRet=`ORAExec.sh "exec :rC:=PBUILDINCMC.F_MAIN ('${pFecSes}','${pFecProc}','BP','NGTA','$ActBug');" $DB`
         f_vrfvalret "$?" "Error al ejecutar PBUILDINCMC.F_MAIN. Avisar a Soporte."
         vEst=`echo $vRet | awk '{print substr($0,1,1)}'`
         if [ "$vEst" = "0" ]; then
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,2,23)}'`
            f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            f_fhmsg "Busca en File_Out"
            sleep 10  
            vFileOUTMC=`echo "$vRet" | awk '{print substr($0,25,23)}'`
            if [ "${vFileOUTMC}" != "" ]; then
               f_fhmsg "Archivo Generado: ${vFileOUTMC}"
            fi
         elif [ "$vEst" = "W" ]; then
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_fhmsg "$vRet"
         else
            vRet=`echo "$vRet" | awk '{print substr($0,2)}'`
            f_finerr "$vRet"
         fi
      fi # Incoming MC - MERCANTIL

   fi # Opcion 1 - INCOMING DEBITO MAESTRO MERCANTIL


   if [ "$vFlgOpcErr" = "S" ]; then
      vOpcion=""
      echo
      f_msg "${dpNom} - Opcion Incorrecta."
      echo
      echo "... presione [ENTER] para continuar."
      read vContinua
   fi

done

# Eliminando Temporales
################################################################################

f_fhmsg "Eliminando archivos temporales"
rm -f ${vFileTMP}

f_msgtit F
exit 0;

################################################################################
## FIN | PROCEDIMIENTO PRINCIPAL
################################################################################
