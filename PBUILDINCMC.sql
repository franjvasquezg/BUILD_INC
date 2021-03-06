CREATE OR REPLACE PACKAGE SGCVNZ.PBUILDINCMC IS
/***************************************************************************************************
************   Proyecto : Procesadora Venezuela   **************************************************
************   Proposito: Build Incoming Maestro (Mc y Ngta)  Mercantil y Provicial ****************
 Historial
 =========
 Persona                  Fecha           Comentarios
 --------------------   --------------     ------------
 Francisco Vásquez.     01/Julio/2020     Inicio de Constructor de Entrantes Maestro (MC y NGTA)
 Francisco Vásquez.     06/Julio/2020     Correccion en variables de fecha (MC y NGTA)
 Francisco Vásquez.     08/Julio/2020     Ajustes en p_GenRegBodyIncBp para los registros del 470
 Francisco Vásquez.     20/Julio/2020     Nueva lineas SHDR, STRL, 
 Francisco Vásquez.     27/Julio/2020     Funcionalidad para crear archivos 470 con registos NREC  
******************************************************************************************************/


 TYPE Mapa_Bits is Table Of Char(1);
 TYPE ArrayLuhn is Table Of number(1);


 TYPE s is record(
      s1  char(1)  :='',
      s2  char(1)  :='',
      s3  char(1)  :='',
      s4  char(1)  :='',
      s5  char(1)  :='',
      s6  char(1)  :='',
      s7  char(1)  :='',
      s8  char(1)  :='',
      s9  char(1)  :='',
      s10 char(1)  :='',
      s11 char(1)  :='',
      s12 char(1)  :=''
      );

 type vb_CardAceptorBusiness is record(vbCab_61 boolean := false,
                                       vbCab_62 boolean := false,
                                       vbCab_63 boolean := false,
                                       vbCab_67 boolean := false,
                                       vbCab_73 boolean := false,
                                       vbCab_75 boolean := false);



 TYPE Msg_1240C IS RECORD  -- Compras
     (MesTypeInd         varchar2 (4)    :='',     -- Message Type Indicator
      SwSerialNum        varchar2 (9)    :='',     -- Switch Serial Number
      ProAcqIssuer       varchar2 (1)    :='',     -- Processor—Acquirer or Issuer  -A Adquiriente -I Emisor
      ProcessorID        varchar2 (4)    :='',     -- Processor ID
      TransactionDate    varchar2 (6)    :='',     -- Transaction Date
      TransactionTime    varchar2 (6)    :='',     -- Transaction Time
      PANLength          varchar2 (2)    :='',     -- PAN Length
      PAN                varchar2(19)    :='',     -- Primary Account Number
      ProcessingCode     varchar2 (6)    :='',     -- Processing Code
      TraceNumber        varchar2 (6)    :='',     -- Trace Number
      MerchantType       varchar2 (4)    :='',     -- Merchant Type (MCC)
      POSEntry           varchar2 (3)    :='',     -- POS Entry
      ReferenceNumber    varchar2(12)    :='',     -- Reference Number
      AcqInstitutionID   varchar2(10)    :='',     -- Acquirer Institution ID
      TerminalID         varchar2(10)    :='',     -- Terminal ID
      ResponseCode       varchar2 (2)    :='',     -- Response Code
      Brand              varchar2 (3)    :='',     -- Brand
      AdviceReasonCode   varchar2 (7)    :='',     -- Advice Reason Code
      IntAgreCode        varchar2 (4)    :='',     -- Intracurrency Agreement
      AuthorizationID    varchar2 (6)    :='',     -- Authorization ID
      CurCodeTrans       varchar2 (3)    :='',     -- Currency Code—Transaction
      ImpliedDecTrans    varchar2 (1)    :='',     -- Implied Decimal — Transaction
      ComAmtTransLocal   varchar2(12)    :='',     -- Completed Amt Trans— Local
      ComAmoTransLocalI  varchar2 (1)    :='',     -- Completed Amount Transaction—Local DR/CR Indicator
      
      CasBacAmtLocal     varchar2(12)    :='',     -- 
      CasBacAmoLocalI    varchar2 (1)    :='',     -- 
      AccessFeeLocal     varchar2 (8)    :='',     -- 
      AccFeeLocalInd     varchar2 (1)    :='',     -- 
      CurCodeSett        varchar2 (3)    :='',     -- 
      ImpDecSett         varchar2 (1)    :='',     -- 
      ConvRatSett        varchar2 (8)    :='',     -- 
      CompAmtSett        varchar2(12)    :='',     -- 
      CompAmoSettInd     varchar2 (1)    :='',     --  
      InterchangeFee     varchar2(10)    :='',     -- 
      InterchangeFeeI    varchar2 (1)    :='',     -- 
      ServLevelInd       varchar2 (3)    :='',     -- 
      ResponseCode2      varchar2 (2)    :='',     -- 
      Filler             varchar2 (2)    :='',     -- 
      RepAmoLocal        varchar2(12)    :='',     -- 
      RepAmoLocalInd     varchar2 (1)    :='',     -- 
      RepAmtSett         varchar2(12)    :='',     -- 
      RepAmoSettInd      varchar2 (1)    :='',     -- 
      OriSettDate        varchar2 (6)    :='',     -- 
      PosIDInd           varchar2 (1)    :='',     -- 
      ATMSurFProID       varchar2 (1)    :='',     -- 
      CroBorInd          varchar2 (1)    :='',     -- 
      CroBorCurInd       varchar2 (1)    :='',     -- 
      ISAFeeInd          varchar2 (1)    :='',     -- 
      TracNumATrans      varchar2 (6)    :='',     -- 
      Filler2            varchar2 (1)    :='');    --


TYPE r_Mtotot_1240 IS RECORD  --Record para calculo de Sumas de 1240's
     (MontoTotal     pls_integer:=0,
      TotalMensaje   pls_integer:=0
   );


 TYPE Msg_1644 IS RECORD -- mensajes administrativos
     (MessTypeInd        varchar2(4)    :='',   -- indicador de tipo de mensaje/Message Type Indicator
      SettDate           varchar2(6)    :='',    -- Fecha de Liquidación/Settlement Date MMDDYY
      ProcessorID        varchar2(10)   :='',   -- Identificación de Procesador asignada por Mastercard /Processor ID
      RecordSize         varchar2(3)    :='',   -- /Record Size
      FileType           varchar2(1)    :='',   -- M Archivo de Pruebas, P Archivo de Producción
      VersionArch        varchar2(10)   :='',   -- Número de la versión actual del Archivo de Datos de Grupo de Transacciones.
      Filler216          varchar2(216)  :='',   -- Espacios
      TotRecordCount     varchar2(11)   :='',   -- Número total de todos los registros incluyendo el registro encabezador de archivo, los apéndices, registros de control financiero y el final de archivo.
      Filler225          varchar2(225)  :='',   -- Espacios
      Filler247          varchar2(247)  :='',   -- Espacios
      --SHDR Y STRL
      SettSeNumber       varchar2(3)    :='',   -- Identificador del tiempo de liquidación asignado por Mastercard
      ICuAgrNumber       varchar2(4)    :='',   -- Número del Convenio de Moneda Común, Reservado para uso futuro
      SetCurrCode        varchar2(3)    :='',   -- Código de Moneda de Liquidación
      ImDecSettlement    varchar2(1)    :='',   -- Decimal Implícito-Liquidación
      ProAcqIssuer       varchar2(1)    :='',   -- Procesador–Adquiriente o Emisor ,Tipo de procesador listado en los siguientes registros. Los valores válidos
      Filler1SHDR        varchar2(10)   :='',   -- Relleno Reservdao para el futuro
      Filler2SHDR        varchar2(224)  :='',   -- Espacios
      TotDebitAmountSet  varchar2(14)   :='',   -- Monto Total de Débito—Liquidación    
      NumDebitItems      varchar2(8)    :='',   -- Número de Partidas de Débito
      TotCredAmoSet      varchar2(14)   :='',   -- Monto Total de Crédito—Liquidación Se calcula durante el procesamiento de grupo de transacciones. Suma de todos los registros de crédito de FREC.
      NumCredItems       varchar2(8)    :='',   -- Número de Partidas de Crédito
      TotRevDebAmount    varchar2(14)   :='',   -- Monto Total de Reversiones de Débito
      NumDebiRever       varchar2(8)    :='',   -- Número de Reversiones de Débito 
      TotRevCreAmount    varchar2(14)   :='',   -- Total Reversal Credit Amount Calculated in batch processing. The sum of all credit EREC records. Credit records contain a C in the settlement indicator field.
      NumCredReversals   varchar2(8)    :='',   -- Number of Credit Reversals
      
      NumNonfinancial    varchar2(8)    :='',   -- Número de registros No Financieros NREC 
      TotIntFeesDebits   varchar2(12)   :='',   -- Se calcula durante el procesamiento de grupo de transacciones. Suma de todos los intercambios de débito desde los registros de FREC, NREC y EREC. Los registros de débito 
      TotIntFeesCredits  varchar2(12)   :='',   -- Cargo por Intercambio Total––Créditos
      Filler1strl        varchar2(17)   :='',   -- Espacios
      TotNetSettlement   varchar2(14)   :='',   -- Liquidación Neta Total, Posición de Liquidación del Procesador
      TotNetSetDRCRInd   varchar2(1)    :='',   -- Indicador de Liquidación Neta Total DR/CR
      TotDAwMisFeeItems  varchar2(14)   :='',   -- Total Debit Amount with Miscellaneous Fee Items
      NumDIwMisFees      varchar2(8)    :='',   -- Number of Debit Items with Miscellaneous Fees
      TotCrAwMisFees     varchar2(14)   :='',   -- Total Credit Amount with Miscellaneous Fees
      NumCrIwMisFeesI    varchar2(8)    :='',   --Number of Credit Items with Miscellaneous Fee Items
      ExtPTIFeesDebits   varchar2(14)   :='',   --Extended Precision Total Interchange Fees–Debits
      ExtPTIFeesCredits  varchar2(14)   :=''    --Extended Precision Total Interchange Fees–Credits
  );

TYPE Msg_1740 IS RECORD  -- Cobros pagos
     (mti                varchar2 (4)    :='',     -- indicador de tipo de mensaje
      bitpri             varchar2(16)    :='',     -- Primer Mapa De Bits
      bitsec             varchar2(16)    :='',     -- Segundo Mapa De Bits
      de02               varchar2(23)    :='',     -- PAN o Numero de Tarj
      de03               varchar2(6)     :='',     -- Codigo de procesamiento
      de04               varchar2(12)    :='',
      de24               varchar2(3)     :='',     -- Codigo de funcion
      de25               varchar2(4)     :='',     -- Codigo de Razon
      de30               varchar2(24)    :='',     -- Monto original
        de30s1           varchar2(12)    :='',     -- Monto original de la transaccion
      de31               varchar2(23)    :='',     -- Datos referentes al adquiriente
        de31_pre         varchar2(22)    :='',
      de33               varchar2(11)    :='',
      de48               varchar2(114)   :='',     -- longitud de dato, dato adicional
        de48_londat      varchar(3)      :='',     -- Longitud del p48
        de48_pds0025     varchar2(14)    :='',
        pds0137_lon      varchar(3)      :='',
        de48_pds0137     varchar2(27)    :='',
        pds0137_cad      varchar2(17)    :='',
        digCheck         pls_integer     :=0,
        de48_pds0148     varchar2(11)    :='',
        de48_pds0149     varchar2(6)     :='',
        de48_pds0165     varchar2(38)    :='',
        de48_pds0230     varchar2(8)     :='',
        de48_pds0264     varchar2(4)     :='',
      de49               varchar2(3)     :='',
      de71               varchar2(8)     :='',     -- numero de mensaje en el lote
      de73               varchar2(6)     :='',     -- longitud de dato DE94
      de93               varchar2(24)    :='',
      de94               varchar2(11)    :='',     -- valor del campo: presen_p33_actc
      de95               varchar2(10)    :='',
      isnum_nacional     pls_integer     :=0,
      cod_ird            varchar2(2)     :='',     -- codigo de IRD
      cod_mcc            varchar2(4)     :='',     -- codigo MCC
      cod_tcc            char(1)         :='',     -- codigo TCC
      isBetweenFiveday   boolean         :=false,  -- la transaccion realizada, es enviada dentro de los 5 dias calendario
      isBetweenThirtyday boolean         :=false,  -- la transaccion realizada, es enviada dentro de los 30 dias calendario
      cod_producto_gcms  varchar2(3)     :='',
      cod_licen_producto varchar2(3)     :='',
      ImpTran            varchar2(12)    :='',
      MonTran            varchar2(3)     :='');

<<<<<<< HEAD
FUNCTION f_main(psfecha VARCHAR2, ppfecha VARCHAR2, pcod_entadq VARCHAR2, Marca VARCHAR2) RETURN VARCHAR2;
--FUNCTION f_main(psfecha VARCHAR2) RETURN VARCHAR2;

PROCEDURE p_mainGen_entrante(pFecha CHAR,pFechaP CHAR,pfechaR CHAR,vtipoimc CHAR, pBankChar CHAR, pIdProc NUMBER, pDirOut CHAR,  pmarca NUMBER, pfile OUT VARCHAR);

--Cabecera y Fin de Archivo provincial
PROCEDURE p_GenRegHFp(vcodfuncion CHAR,vfecha VARCHAR2, vCReg VARCHAR2);

--Cabecera y Fin de Archivo mercantil
PROCEDURE p_GenRegHFm(vcodfuncion CHAR,vfecha VARCHAR2, vCReg VARCHAR2);

--Cabecera y Fin de Archivo mercantil
PROCEDURE p_GenRegfin(vcodfuncion CHAR);
=======
FUNCTION f_main(psfecha VARCHAR2, ppfecha VARCHAR2, pcod_entadq VARCHAR2, Marca VARCHAR2, bug CHAR) RETURN VARCHAR2;
--FUNCTION f_main(psfecha VARCHAR2) RETURN VARCHAR2;

PROCEDURE p_mainGen_entrante(pFecha CHAR,pFechaP CHAR,pfechaR CHAR,vtipoimc CHAR, pBankChar CHAR, pIdProc NUMBER, pDirOut CHAR,  pmarca NUMBER, bug CHAR, pfile OUT VARCHAR);

--Cabecera y Fin de Archivo provincial
PROCEDURE p_GenRegHFp(vcodfuncion CHAR,vfecha VARCHAR2, vCReg VARCHAR2);

--Cabecera y Fin de Archivo  (SHDR Y STRL) provincial
PROCEDURE p_genRegSHp(vcodfuncion CHAR,vfecha VARCHAR2,pmarca NUMBER);

--Cabecera y Fin de Archivo  (SHDR Y STRL) mercantil
PROCEDURE p_genRegSHm(vcodfuncion CHAR,vfecha VARCHAR2,pmarca NUMBER);
>>>>>>> Desarrollo

--Cabecera y Fin de Archivo mercantil
PROCEDURE p_GenRegHFm(vcodfuncion CHAR,vfecha VARCHAR2, vCReg VARCHAR2);

--Cabecera y Fin de Archivo mercantil
PROCEDURE p_GenRegfin(vcodfuncion CHAR);

--Cuerpo Banco Provincial y Banco Mercantil
PROCEDURE p_GenRegBodyIncBp(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER);

PROCEDURE p_GenRegBodyIncBm(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER);

--Cuerpo Banco Provincial y Banco Mercantil con fallas 
PROCEDURE p_GenRegBodyIncBp_bug(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER);

PROCEDURE p_GenRegBodyIncBm_bug(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER);


procedure p_FindPostalCode(pComercio varchar2, codePostal out varchar2, codEstado out varchar2);

function f_IniMapaBits return mapa_bits;

function f_IniArrayLuhn return ArrayLuhn;

function f_Bin_Hex(bin varchar2) return char;

function f_Gen_MapaHex2(matrizBin in out Mapa_Bits) return varchar;

function f_ini_msg1240C return Msg_1240C;


function f_ini_msg1740 return Msg_1740;

function f_iniCardAceptorBusiness return vb_CardAceptorBusiness;

function f_FindCodigoRazon(pCodRazon number, pNumTarjeta varchar2 )return varchar2;

function f_AtLeastOne(pfecha varchar2, pbanco varchar2, marca number)return pls_integer;

function f_GenCheckDigit(pCadena varchar2) return pls_integer;

function f_getIdBankDestino(bin_tarjeta varchar2,pBanco char)return varchar2;

procedure p_findTransOriginal(pbanco varchar2, p31 varchar2,pNumTarjeta varchar2,
                               pImpTran out number, pMonTran out varchar2);

procedure p_findTransactionIdDisputas(p31 varchar2, pNumTarjeta varchar2, pTransationID out varchar2,
                                       pSourceAmount out varchar2,Pcurrencode out varchar2, Pinc_doc_ind  OUT VARCHAR2 );


function f_IsDate(pstring varchar2)return boolean;

function f_isBetweenFiveDay(pfecha date) return boolean;

function f_isBetweenThirtyDay(pfecha date) return boolean;

function f_getCursorCab(pmcc varchar2)return sys_refcursor;

procedure p_Insert_CtlProcMc(pIDProc number, pIdAdq varchar2, pEstado char,pNumSec number,pfecha date);

--function f_getSecuencia(pbanco char, pNomProc char,pRepro char:='N',pfecha date) return pls_integer;
function f_getSecuencia(pfecha date) return pls_integer;

FUNCTION f_QUITA_20(pDato CHAR) RETURN CHAR;

function f_FindTarjetaNacional(pIdProc pls_integer, bin_tarjeta varchar2,pBanco char )return pls_integer;

FUNCTION FN_TIPO_TERM_TRANS (p_idter_41 IN VARCHAR2) RETURN VARCHAR2;

end;
/
CREATE OR REPLACE PACKAGE BODY SGCVNZ.PBUILDINCMC IS

      vIDFile         utl_file.file_type;
      vFile           varchar2(50);
      vmtotot_1240    r_mtotot_1240;
      vPaso           varchar2(10);
      vIdProc         pls_integer;
      vErrMsg         varchar2(200);
      vRetC           varchar2(100);
      vErrCod         varchar2(2);
      vOraCode        pls_integer;
      vOraErr         varchar2(200);
      eFinError       exception;
      eFinWarning     exception;
      vCad1240        clob;
      vCad1644        clob;
      vNumSecReg      pls_integer := 0;
      vb_isDate       boolean     := true;
      vTipocambio     number(8,3) := 0;
      vMoney          char(3)     := '';
      vSecControl     pls_integer := 0;
      vBank4          varchar2(4) := '';
      vMontoTotal     number(16)  := 0;
      vtotalMensaje   pls_integer := 0;
      vCantRegMer     pls_integer := 0;
      vCantRegPro     pls_integer := 0;
      vEntorno        char(4)     := '';
      vTipFileMC      char(1)     := '';
      VTIPO_TERM      CHAR(3);
      vCReg           pls_integer := 0;
      tiempo          CHAR(8) := '';
      
      



<<<<<<< HEAD
FUNCTION f_main(psfecha VARCHAR2, ppfecha VARCHAR2, pcod_entadq VARCHAR2, Marca VARCHAR2) RETURN VARCHAR2 IS
=======
FUNCTION f_main(psfecha VARCHAR2, ppfecha VARCHAR2, pcod_entadq VARCHAR2, Marca VARCHAR2, bug CHAR) RETURN VARCHAR2 IS
>>>>>>> Desarrollo


 vDirOUT          VARCHAR2(100)   :='DIR-OUT';
 vfechac6         VARCHAR2(6)     :='';
 dfecha           DATE;
 vArchivo         VARCHAR2(100)    :='';
 vRetorno         VARCHAR2(100)   :='';
 vMarca           NUMBER(6);
 --pfechad          DATE;
 vfechacA         VARCHAR2(2)     :='';
 vfechacM         VARCHAR2(2)     :='';
 vfechacD         VARCHAR2(2)     :='';
 vfechacR         VARCHAR2(6)     :='';
 vtipoimc         CHAR(3);
 
 


BEGIN

  --vFechac6    := SUBSTR(psFecha,3,6);
  vFechacA    := SUBSTR(psFecha,3,2);
  vFechacM    := SUBSTR(psFecha,5,2);
  vFechacD    := SUBSTR(psFecha,7,2);
  vFechacR    := vFechacM||vFechacD||vFechacA;
  --dFecha      := TO_DATE(psFecha,'YYYYMMDD');

  
  --get money code
  vMoney      := pqcomercios.gcw_f_getmonedavig(sysdate);

  --get IDPROC
  vPaso      := 'Paso 01';
  vIDProc    := pqmonproc.InsMonProc ('PBUILDINC');

  --get Dirout
  vDirOUT    := STD.F_GETVALPAR('DIR-OUT');

  --get ENTORNO
  vEntorno:= STD.F_GETVALPAR('ENTORNO');
  IF vEntorno='PROD' THEN vTiPOimc:='464'; END IF;
  IF vEntorno='CCAL' THEN vtipoimc:='470'; END IF;
  IF vEntorno='DESA' THEN vtipoimc:='470'; END IF;

   IF Marca = 'MC' then
      vMarca := 8010;
   ELSIF Marca = 'NGTA' then
      vMarca := 9010;
   END IF;

   
  -- Proceso para Banco Mercantil y Provincial
<<<<<<< HEAD
  p_mainGen_entrante(psfecha,ppfecha,vFechacR,vtipoimc,pcod_entadq,vIDProc,vDirOUT,vMarca,vArchivo);
=======
  p_mainGen_entrante(psfecha,ppfecha,vFechacR,vtipoimc,pcod_entadq,vIDProc,vDirOUT,vMarca,bug,vArchivo);
>>>>>>> Desarrollo
  IF LENGTH(TRIM(vArchivo)) > 0 THEN
     vRetorno := vArchivo;
  END IF;

  -- Verificacion de Warning
  IF (vCantRegMer < 1 AND vCantRegPro < 1) THEN
     verrmsg :='No hay registros para procesar OUTGOING';
     verrcod := '21';
     RAISE eFinWarning;
  END IF;

  RETURN '0'||vRetorno||'~';

 EXCEPTION
    WHEN efinerror THEN
         utl_file.fclose(vIDFile);
         pqmonproc.inslog(vidproc, 'E', verrmsg);
         p_Insert_CtlProcMc(vIDProc,vBank4,'E',vSecControl,dFecha);
         vretc :=pqmonproc.updmonproc (vidproc, 'E');
         RETURN 'EERROR: '||verrmsg||'~';

    WHEN eFinWarning THEN
         utl_file.fclose(vIDFile);
         pqmonproc.inslog(vidproc, 'E', verrmsg);
         p_Insert_CtlProcMc(vIDProc,vBank4,'E',vSecControl,dFecha);
         vretc :=pqmonproc.updmonproc (vidproc, 'E');
         RETURN 'WALERTA: '||verrmsg||'~';

    WHEN others THEN
         voracode := abs(sqlcode);
         voraerr  := substr(sqlerrm,1,200);
         utl_file.fclose(vIDFile);
         pqmonproc.inslog(vidproc, 'E', voraerr);
         p_Insert_CtlProcMc(vIDProc,vBank4,'E',vSecControl,dfecha);
         vretc    := pqmonproc.updmonproc (vidproc, 'E', '99');
         RETURN 'EERROR de Base de Datos (ORA-'||LPAD(vOraCode,5,'0')||')~';

END;


FUNCTION FN_TIPO_TERM_TRANS (p_idter_41 IN VARCHAR2) RETURN VARCHAR2 IS

 v_count NUMBER;
 vtipo_trans CHAR(3);

BEGIN

    SELECT count(1) into v_count FROM SGCVNZ.TERMINALES_GENERALES
    WHERE tipo_term='MP'
    AND (nro_serie= p_idter_41 OR INVENTORYID= p_idter_41);

        IF  v_count = 0 THEN
            vtipo_trans:='NA ';
        ELSE
            vtipo_trans:='CT9';
        END IF;

    RETURN vtipo_trans;
   EXCEPTION
    WHEN OTHERS THEN
    RETURN ('Error en la ejecucion de la funcion PQOUTGOINGMC.TIPO_TERM_TRANS: '||SQLERRM);
END;

<<<<<<< HEAD
PROCEDURE p_mainGen_entrante(pFecha CHAR,pFechaP CHAR,pfechaR CHAR,vtipoimc CHAR, pBankChar CHAR, pIdProc NUMBER, pDirOut CHAR,  pmarca NUMBER, pfile OUT VARCHAR) IS
=======
PROCEDURE p_mainGen_entrante(pFecha CHAR,pFechaP CHAR,pfechaR CHAR,vtipoimc CHAR, pBankChar CHAR, pIdProc NUMBER, pDirOut CHAR,  pmarca NUMBER, bug CHAR, pfile OUT VARCHAR) IS
>>>>>>> Desarrollo

 vbank6   CHAR(6):= '';
 pfechad  date;
 vfA      VARCHAR2(4)     :='';
 vfM      VARCHAR2(2)     :='';
 vfD      VARCHAR2(2)     :='';
 vfH      VARCHAR2(2)     :='';
 vfmm     VARCHAR2(2)     :='';
 vfS      VARCHAR2(2)     :='';
 --vmar     VARCHAR2(6)     :='';
 
 BEGIN

   IF pBankChar = 'BM' THEN
       vBank4      := '0105';
       vCantRegMer := f_AtLeastOne(pFecha,pBankChar,pmarca);
   END IF;

   IF pBankChar = 'BP' THEN
      vBank4      := '0108';
      vCantRegpro := f_AtLeastOne(pFecha,pBankChar,pmarca);
   END IF;

   --get_secuence
   --vSecControl  := f_getSecuencia(vBank4,'POUTMC',pRepro,pfechad);
   --vSecControl  := f_getSecuencia(pfecha);

   --inserta inicio de proceso
   --p_Insert_CtlProcMc(pIdProc, vBank4,'I',vSecControl,pfecha);

   --validando directorio
   IF pDirOut IS NULL THEN
      verrmsg := 'Directorio de salida (dir_out) no definido en std_parametro';
      verrcod := '2';
      RAISE efinerror;
   END IF;

   --Validando si parametro de fecha es ok
   vb_isdate  := f_IsDate(pfecha);
   IF vb_isDate = FALSE THEN
      verrmsg := 'El parametro no es de tipo fecha [YYYYMMDD]';
      verrcod := '6';
      RAISE efinerror;
   END IF;
   
   --Hora del proceso
   select to_char(sysdate, 'HH:MI:SS') into tiempo from dual;

   --********************************************************************************************
   --*********************************GEN FILE BANCO MERCANTIL***********************************
   --********************************************************************************************

    IF vCantRegMer > 0 AND pBankChar = 'BM' AND  pmarca = '8010' THEN
         --generando File
         vfA    := SUBSTR(pFechaP,1,4);
         vfM    := SUBSTR(pFechaP,5,2);
         vfD    := SUBSTR(pFechaP,7,2);
         vfH    := SUBSTR(tiempo,1,2);
         vfmm   := SUBSTR(tiempo,4,2);
         vfS    := SUBSTR(tiempo,7,2);
         
         vFile   := '';
         --vFile   := 'TT'||vtipoimc||vfA||'-'||vfM||'-'||vfD||'-'||vfS;
<<<<<<< HEAD
         --vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfS||'.001';
=======
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
>>>>>>> Desarrollo
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;
         
         --Cantidad de Registros Por en la Fecha de Sesion
        SELECT count(p00idmsg) into vCReg
        FROM mcp_bm 
           WHERE  cod_entadq = pBankChar
           AND p28sesion = pFecha         --TO_CHAR(pFecha-1,'YYYYMMDD') fecha de session 08/07/2020
           AND p48tiptra LIKE '10%'
           and P58IDAUT ='358011';        --35 MC 8011 MAESTRO MERCANTIL AND p71nummen LIKE pmarca||'%';
         

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de contrucción de entrante BM');
<<<<<<< HEAD
         p_genRegHFm('FHDR',pfechaR,vCReg);  --pFecha6
         p_GenRegBodyIncBm(pFecha,pfechaR,vbank4,'358011'); --pmarca
         --p_GenReg1740(pFecha6,vbank4,pcodhcierre);      --p_GenReg1740(pFecha6,vbank6);
         p_genRegHFm('FTRL',pfechaR,vCReg); --pFecha6
=======
         p_genRegHFm('FHDR',pfechaR,vCReg);                
         p_genRegSHm('SHDR',pFecha,'358011');
         IF bug = 'S' THEN  
            p_GenRegBodyIncBm_bug(pFecha,pfechaR,vbank4,'358011'); --las transacciones 1444 la construira como NREC
         ELSIF bug = 'N' THEN
            p_GenRegBodyIncBm(pFecha,pfechaR,vbank4,'358011');
         END IF;
         p_genRegSHm('STRL',pFecha,'358011');
         p_genRegSHm('STRN',pFecha,'358011');
         p_genRegHFm('FTRL',pfechaR,vCReg); 
>>>>>>> Desarrollo
         p_genRegfin('FTRL'); 
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         --p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pFecha);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
         
    ELSIF vCantRegMer > 0 AND pBankChar = 'BM' AND  pmarca = '9010' THEN
            --generando File
         vfA    := SUBSTR(pFechaP,1,4);
         vfM    := SUBSTR(pFechaP,5,2);
         vfD    := SUBSTR(pFechaP,7,2);
         vfH    := SUBSTR(tiempo,1,2);
         vfmm   := SUBSTR(tiempo,4,2);
         vfS    := SUBSTR(tiempo,7,2);
         
         vFile   := '';
         --vFile   := 'TT'||vtipoimc||vfA||'-'||vfM||'-'||vfD||'-'||vfS;
<<<<<<< HEAD
         --vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfS||'.001';
=======
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
>>>>>>> Desarrollo
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;

        --Cantidad de Registros Por en la Fecha de Sesion
        SELECT count(p00idmsg) into vCReg
        FROM mcp_bm 
           WHERE  cod_entadq = pBankChar
           AND p28sesion = pFecha  --TO_CHAR(pFecha-1,'YYYYMMDD')
           AND p48tiptra LIKE '10%'
           and P58IDAUT ='359011';              --35 MC 8011 MAESTRO MERCANTIL AND p71nummen LIKE pmarca||'%';
           
         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de contrucción de entrante BM');
         p_genRegHFm('FHDR',pfechaR,vCReg);  --pFecha6
<<<<<<< HEAD
         p_GenRegBodyIncBm(pFecha,pfechaR,vbank4,'359011');  --pmarca
         --p_GenReg1740(pFecha6,vbank4,pcodhcierre);         --p_GenReg1740(pFecha6,vbank6);
=======
         p_genRegSHm('SHDR',pFecha,'359011');
         IF bug = 'S' THEN
            p_GenRegBodyIncBm_bug(pFecha,pfechaR,vbank4,'359011');  --las transacciones 1444 la construira como NREC
         ELSIF bug = 'N' THEN
            p_GenRegBodyIncBm(pFecha,pfechaR,vbank4,'359011');  --pmarca
         END IF;
         p_genRegSHm('STRL',pFecha,'359011');
         p_genRegSHm('STRN',pFecha,'358011');
>>>>>>> Desarrollo
         p_genRegHFm('FTRL',pfechaR,vCReg); --pFecha6
         p_genRegfin('FTRL'); 
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         --p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pFecha);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
    END IF;
    
    --********************************************************************************************
    --*********************************GEN FILE BANCO PROVINCIAL**********************************
    --********************************************************************************************

   IF vCantRegPro > 0 AND pBankChar = 'BP' AND  pmarca = '8010' THEN
         --generando File
         vfA    := SUBSTR(pFechaP,1,4);
         vfM    := SUBSTR(pFechaP,5,2);
         vfD    := SUBSTR(pFechaP,7,2);
         vfH    := SUBSTR(tiempo,1,2);
         vfmm   := SUBSTR(tiempo,4,2);
         vfS    := SUBSTR(tiempo,7,2);
         
         vFile   := '';
         --vFile   := 'TT'||vtipoimc||vfA||'-'||vfM||'-'||vfD||'-'||vfS;
<<<<<<< HEAD
         --vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfS||'.001';
=======
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
>>>>>>> Desarrollo
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;
         
        --Cantidad de Registros Por en la Fecha de Sesion
        SELECT count(p00idmsg) into vCReg
        FROM mcp_bp 
           WHERE  cod_entadq = pBankChar
           AND p28sesion = pFecha               --TO_CHAR(pFecha-1,'YYYYMMDD')--FEcha de session
           AND p48tiptra LIKE '10%'
           and P58IDAUT ='358012';              --35 MC 8011 MAESTRO MERCANTIL AND p71nummen LIKE pmarca||'%';

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de contrucción de entrante BP');
         p_genRegHFp('FHDR',pfechaR,vCReg);
<<<<<<< HEAD
         p_GenRegBodyIncBp(pFecha,pfechaR,vbank4,'358012');  --pmarca 
         --p_GenRegAnulacion(pFecha6,vbank4,pcodhcierre);
         --p_GenReg1740(pFecha6,vbank4,pcodhcierre);
=======
         p_genRegSHp('SHDR',pFecha,'358012');
         IF bug = 'S' THEN
            p_GenRegBodyIncBp_bug(pFecha,pfechaR,vbank4,'358012');  --pmarca
         ELSIF bug = 'N' THEN
            p_GenRegBodyIncBp(pFecha,pfechaR,vbank4,'358012');  --pmarca
         END IF; 
         p_genRegSHp('STRL',pFecha,'358012');
         p_genRegSHp('STRN',pFecha,'358012');
>>>>>>> Desarrollo
         p_genRegHFp('FTRL',pfechaR,vCReg);
         p_genRegfin('FTRL'); 
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         --p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pFecha); --pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
         
    ELSIF vCantRegPro > 0 AND pBankChar = 'BP' AND  pmarca = '9010' THEN
         --generando File
         vfA    := SUBSTR(pFechaP,1,4);
         vfM    := SUBSTR(pFechaP,5,2);
         vfD    := SUBSTR(pFechaP,7,2);
         vfH    := SUBSTR(tiempo,1,2);
         vfmm   := SUBSTR(tiempo,4,2);
         vfS    := SUBSTR(tiempo,7,2);
         
         vFile   := '';
         --vFile   := 'TT'||vtipoimc||vfA||'-'||vfM||'-'||vfD||'-'||vfS;
<<<<<<< HEAD
         --vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfS||'.001';
=======
         vFile   := 'TT'||vtipoimc||'T0.'||vfA||'-'||vfM||'-'||vfD||'-'||vfH||'-'||vfmm||'-'||vfS||'.001';
>>>>>>> Desarrollo
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;
         
        --Cantidad de Registros Por en la Fecha de Sesion
        SELECT count(p00idmsg) into vCReg
        FROM mcp_bp 
           WHERE  cod_entadq = pBankChar
           AND p28sesion = pFecha  --TO_CHAR(pFecha-1,'YYYYMMDD')
           AND p48tiptra LIKE '10%'
           and P58IDAUT ='359012';              --35 MC 8011 MAESTRO MERCANTIL AND p71nummen LIKE pmarca||'%';

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de contrucción de entrante BP');

         p_genRegHFp('FHDR',pfechaR,vCReg);
<<<<<<< HEAD
         p_GenRegBodyIncBp(pFecha,pfechaR,vbank4,'359012');  --pmarca
         --p_GenReg1740(pFecha6,vbank4,pcodhcierre);
=======
         p_genRegSHp('SHDR',pFecha,'359012');
         IF bug = 'S' THEN
            p_GenRegBodyIncBp_bug(pFecha,pfechaR,vbank4,'359012');  --pmarca
         ELSIF bug = 'N' THEN
            p_GenRegBodyIncBp(pFecha,pfechaR,vbank4,'359012');
         END IF;
         p_genRegSHp('STRL',pFecha,'359012');
         p_genRegSHp('STRN',pFecha,'358012');
>>>>>>> Desarrollo
         p_genRegHFp('FTRL',pfechaR,vCReg);
         p_genRegfin('FTRL'); 
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         --p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pFecha); --pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
    END IF;


END;


PROCEDURE p_GenRegBodyIncBp(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER) IS
 strhexa1240C       VARCHAR2(32)   := '';
 vcodpostal         VARCHAR2(10)   := '';
 vcodestado         VARCHAR2(3)    := '';
 long_p48           NUMBER         := 0;
 vbanco             VARCHAR2(2)    := '';
 vt1240C            msg_1240C;
 mb                 Mapa_Bits;
 vs                 s;
 vlong              VARCHAR2(128);
 vdato              VARCHAR2(1024);
 ncero              NUMBER := 0;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;
 --vmarca             number(6) ;



 CURSOR cr_reginc IS
   SELECT 
   cod_entadq, csb_entadq, cod_hrcierre, p00idmsg, 
   p02numtar, p03codpro, p04imptra, p05impcon, p06imptit, p09concon,
   p10concli, p11idetra, p12timloc, p14feccad, p16feccon, p17feccap,
   p18lacti, p22punser, p24codfun, p25codraz, p26lacti, p28sesion,
   p29inlote, p30impori, p31refadq, p32idadq, p33idpre, p37datref,
   p38numaut, p39codacr, p41cseri, p42ideest, p46tcuot01,
   p46tcuot02, p46tcuot03, p46tcuot04, p48tiptra, p48cuenta,
   p48tipmov, p48filler, p49montra, p50moncon, p51montit,
   p56do_idmsg, p56do_idetra, p56do_timloc, p56do_idadq, p58idaut,
   p62melect, p71nummen, pxxfiller, tipo_insert, es_dataok,
   tipo_auxfunc
   FROM mcp_bp 
   WHERE  cod_entadq = 'BP' --pbanco
   AND p28sesion = pfecha   --TO_CHAR(dFecha-1,'YYYYMMDD')
   AND p48tiptra LIKE '10%'
   AND P58IDAUT = pmarca;    -- AND p71nummen LIKE pmarca||'%';
<<<<<<< HEAD
=======

 BEGIN

   --inicia Generacion de Compra
   vPaso   := 'Paso 03';

   FOR c IN cr_reginc LOOP

          long_p48:=0;
          vt1240C     := f_ini_msg1240C;
          if c.P00IDMSG = '1244' then
            vt1240C.MesTypeInd      :='FREC';                -- FREC=00 
          elsif c.P00IDMSG = '1444' then
            vt1240C.MesTypeInd      :='EREC';                -- EREC
          end if; 
          vt1240C.SwSerialNum       := '000000000';          --Switch Serial Number
          vt1240C.ProAcqIssuer      := 'A';
          vt1240C.ProcessorID       := '0000';
          vt1240C.TransactionDate   := vfecha;
          vt1240C.TransactionTime   := SUBSTR(c.p12timloc,9,6);
          vt1240C.PANLength         := length(c.p02numtar);
          vt1240C.PAN               := rpad(c.p02numtar,19,' '); --lpad(c.p02numtar,19,' ');
          vt1240C.ProcessingCode    := '000000';
          vt1240C.TraceNumber       :=  lpad(c.p11idetra,6,'0');
          vt1240C.MerchantType      :=  '0000';
          vt1240C.POSEntry          :=  '000';
          vt1240C.ReferenceNumber   := '000000000000';
          vt1240C.AcqInstitutionID  := '1993731318';        -- Banco Provincial  '1993731318'  
          vt1240C.TerminalID        := '0000000000';
          if c.P00IDMSG = 1244 then
            vt1240C.ResponseCode    := '00';                -- FREC=00 
          elsif c.P00IDMSG = 1444 then
             vt1240C.ResponseCode   := '05';                -- NREC=05
          end if; 
          vt1240C.Brand             := 'MS2';                -- MS1 ¿INTERNACIONA?
          vt1240C.AdviceReasonCode  := '       ';            --From online 0220/0420 messages. Contains blanks when the transaction completes as requested.
          vt1240C.IntAgreCode       := 'C'||c.p49montra;     -- Si está presente, representa la moneda en la cual se liquidará la transacción.
          vt1240C.AuthorizationID   := '      ';              --Identificación de la Autorización , En blanco si no está disponible
          vt1240C.CurCodeTrans      := c.p49montra;          -- Código de Moneda–– Transacción
          vt1240C.ImpliedDecTrans   := '2';                   -- Decimal Implícito–– Transacción
          vt1240C.ComAmtTransLocal  := lpad(c.p04imptra,12,'0');          -- Transacción de Monto Completada—Local
          vt1240C.ComAmoTransLocalI := UPPER(c.p48tipmov);   --Transacción de Monto Final––Indicador Local DR/CR
          vt1240C.CasBacAmtLocal    := '000000000000';        -- 
          vt1240C.CasBacAmoLocalI   := UPPER(c.p48tipmov);    -- 
          vt1240C.AccessFeeLocal    := '00000000';             -- 
          vt1240C.AccFeeLocalInd    := UPPER(c.p48tipmov);     -- 
          vt1240C.CurCodeSett       := c.p49montra;            -- 
          vt1240C.ImpDecSett        := '2';                     --  Implied decimal of DE 50, Currency Code—Settlement
          vt1240C.ConvRatSett       := '11000000';              -- Conversion Rate— Settlement
          vt1240C.CompAmtSett       := lpad(c.P04IMPTRA,12,'0');                -- Completed amount (DE 5)represented in settlement currency (DE 50).
          vt1240C.CompAmoSettInd    := UPPER(SUBSTR(c.P46TCUOT01,3,1));           -- Indicates whether the value is a credit or debit to the receiver. Valid  
          vt1240C.InterchangeFee    := LPAD(NVL(lpad(SUBSTR(C.P46TCUOT01,4,8),10,'0'),0),10,'0');     -- Batch generated—same currency as DE 50
          vt1240C.InterchangeFeeI   := UPPER(c.p48tipmov);     -- 
          vt1240C.ServLevelInd      :='000';     -- 
          vt1240C.ResponseCode2     :='  ';     -- 
          vt1240C.Filler            :='  ';                    --Spaces 
          vt1240C.RepAmoLocal       :='       4NNX ';     -- Monto de Reemplazo—Local
          vt1240C.RepAmoLocalInd    :=' ';     -- 
          vt1240C.RepAmtSett        := lpad(c.P04IMPTRA,12,'0');     -- 
          vt1240C.RepAmoSettInd     := UPPER(c.p48tipmov);     -- 
          vt1240C.OriSettDate       := vfecha;     -- Fecha de Liquidación ORIGINAL
          vt1240C.PosIDInd          :=' ';     -- Indicador de Identificación Positiva
          vt1240C.ATMSurFProID      :=' ';     -- 
          vt1240C.CroBorInd         :=' ';     -- 
          vt1240C.CroBorCurInd      :=' ';     -- 
          vt1240C.ISAFeeInd         :=' ';     -- 
          vt1240C.TracNumATrans     :='000000';     -- 
          vt1240C.Filler2           :=' ';    --

          --vMontoTotal   :=vMontoTotal + to_number(nvl(vt1240C.imptra_p04_actc,0));
          --vtotalMensaje :=vtotalMensaje + 1;


          vCad1240:= vt1240C.MesTypeInd || vt1240C.SwSerialNum      || vt1240C.ProAcqIssuer      ||
                     vt1240C.ProcessorID || vt1240C.TransactionDate  || vt1240C.TransactionTime  ||
                     vt1240C.PANLength || vt1240C.PAN  || vt1240C.ProcessingCode  || vt1240C.TraceNumber ||
                     vt1240C.MerchantType || vt1240C.POSEntry  || vt1240C.ReferenceNumber  || vt1240C.AcqInstitutionID  ||
                     vt1240C.TerminalID  || vt1240C.ResponseCode || vt1240C.Brand  || vt1240C.AdviceReasonCode ||
                     vt1240C.IntAgreCode     || vt1240C.AuthorizationID || vt1240C.CurCodeTrans      ||
                     vt1240C.ImpliedDecTrans || vt1240C.ComAmtTransLocal || vt1240C.ComAmoTransLocalI  ||
                     vt1240C.CasBacAmtLocal || vt1240C.CasBacAmoLocalI || vt1240C.AccessFeeLocal ||
                     vt1240C.AccFeeLocalInd || vt1240C.CurCodeSett || vt1240C.ImpDecSett      ||
                     vt1240C.ConvRatSett || vt1240C.CompAmtSett  || vt1240C.CompAmoSettInd  ||
                     vt1240C.InterchangeFee || vt1240C.InterchangeFeeI || vt1240C.ServLevelInd ||
                     vt1240C.ResponseCode2 || vt1240C.Filler || vt1240C.RepAmoLocal  ||
                     vt1240C.RepAmoLocalInd  || vt1240C.RepAmtSett  || vt1240C.RepAmoSettInd   ||
                     vt1240C.OriSettDate || vt1240C.PosIDInd  || vt1240C.ATMSurFProID  ||
                     vt1240C.CroBorInd || vt1240C.CroBorCurInd  || vt1240C.ISAFeeInd  ||
                     vt1240C.TracNumATrans || vt1240C.Filler2 ;

          utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
          utl_file.new_line(vidfile);
          utl_file.fflush(vidfile);

          -- Inicio: Calculos para Registro de Conciliacion (1240)
          vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
    END LOOP;
END;

PROCEDURE p_GenRegBodyIncBp_bug(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER) IS
 strhexa1240C       VARCHAR2(32)   := '';
 vcodpostal         VARCHAR2(10)   := '';
 vcodestado         VARCHAR2(3)    := '';
 long_p48           NUMBER         := 0;
 vbanco             VARCHAR2(2)    := '';
 vt1240C            msg_1240C;
 mb                 Mapa_Bits;
 vs                 s;
 vlong              VARCHAR2(128);
 vdato              VARCHAR2(1024);
 ncero              NUMBER := 0;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;
 --vmarca             number(6) ;



 CURSOR cr_reginc IS
   SELECT 
   cod_entadq, csb_entadq, cod_hrcierre, p00idmsg, 
   p02numtar, p03codpro, p04imptra, p05impcon, p06imptit, p09concon,
   p10concli, p11idetra, p12timloc, p14feccad, p16feccon, p17feccap,
   p18lacti, p22punser, p24codfun, p25codraz, p26lacti, p28sesion,
   p29inlote, p30impori, p31refadq, p32idadq, p33idpre, p37datref,
   p38numaut, p39codacr, p41cseri, p42ideest, p46tcuot01,
   p46tcuot02, p46tcuot03, p46tcuot04, p48tiptra, p48cuenta,
   p48tipmov, p48filler, p49montra, p50moncon, p51montit,
   p56do_idmsg, p56do_idetra, p56do_timloc, p56do_idadq, p58idaut,
   p62melect, p71nummen, pxxfiller, tipo_insert, es_dataok,
   tipo_auxfunc
   FROM mcp_bp 
   WHERE  cod_entadq = 'BP' --pbanco
   AND p28sesion = pfecha   --TO_CHAR(dFecha-1,'YYYYMMDD')
   AND p48tiptra LIKE '10%'
   AND P58IDAUT = pmarca;    -- AND p71nummen LIKE pmarca||'%';
>>>>>>> Desarrollo

 BEGIN

   --inicia Generacion de Compra
   vPaso   := 'Paso 03';

   FOR c IN cr_reginc LOOP

          long_p48:=0;
          vt1240C     := f_ini_msg1240C;
          if c.P00IDMSG = '1244' then
            vt1240C.MesTypeInd      :='FREC';                -- FREC=00 
          elsif c.P00IDMSG = '1444' then
            vt1240C.MesTypeInd      :='NREC';                -- NREC=05
          end if; 
          vt1240C.SwSerialNum       := '000000000';          --Switch Serial Number
          vt1240C.ProAcqIssuer      := 'A';
          vt1240C.ProcessorID       := '0000';
          vt1240C.TransactionDate   := vfecha;
          vt1240C.TransactionTime   := SUBSTR(c.p12timloc,9,6);
          vt1240C.PANLength         := length(c.p02numtar);
          vt1240C.PAN               := rpad(c.p02numtar,19,' '); --lpad(c.p02numtar,19,' ');
          vt1240C.ProcessingCode    := '000000';
          vt1240C.TraceNumber       :=  lpad(c.p11idetra,6,'0');
          vt1240C.MerchantType      :=  '0000';
          vt1240C.POSEntry          :=  '000';
          vt1240C.ReferenceNumber   := '000000000000';
          vt1240C.AcqInstitutionID  := '1993731318';        -- Banco Provincial  '1993731318'  
          vt1240C.TerminalID        := '0000000000';
          if c.P00IDMSG = 1244 then
            vt1240C.ResponseCode    := '00';                -- FREC=00 
          elsif c.P00IDMSG = 1444 then
             vt1240C.ResponseCode   := '05';                -- NREC=05
          end if; 
          vt1240C.Brand             := 'MS2';                -- MS1 ¿INTERNACIONA?
          vt1240C.AdviceReasonCode  := '       ';            --From online 0220/0420 messages. Contains blanks when the transaction completes as requested.
          vt1240C.IntAgreCode       := 'C'||c.p49montra;     -- Si está presente, representa la moneda en la cual se liquidará la transacción.
          vt1240C.AuthorizationID   := '      ';              --Identificación de la Autorización , En blanco si no está disponible
          vt1240C.CurCodeTrans      := c.p49montra;          -- Código de Moneda–– Transacción
          vt1240C.ImpliedDecTrans   := '2';                   -- Decimal Implícito–– Transacción
          vt1240C.ComAmtTransLocal  := lpad(c.p04imptra,12,'0');          -- Transacción de Monto Completada—Local
          vt1240C.ComAmoTransLocalI := UPPER(c.p48tipmov);   --Transacción de Monto Final––Indicador Local DR/CR
          vt1240C.CasBacAmtLocal    := '000000000000';        -- 
          vt1240C.CasBacAmoLocalI   := UPPER(c.p48tipmov);    -- 
          vt1240C.AccessFeeLocal    := '00000000';             -- 
          vt1240C.AccFeeLocalInd    := UPPER(c.p48tipmov);     -- 
          vt1240C.CurCodeSett       := c.p49montra;            -- 
          vt1240C.ImpDecSett        := '2';                     --  Implied decimal of DE 50, Currency Code—Settlement
          vt1240C.ConvRatSett       := '11000000';              -- Conversion Rate— Settlement
          vt1240C.CompAmtSett       := lpad(c.P04IMPTRA,12,'0');                -- Completed amount (DE 5)represented in settlement currency (DE 50).
          vt1240C.CompAmoSettInd    := UPPER(SUBSTR(c.P46TCUOT01,3,1));           -- Indicates whether the value is a credit or debit to the receiver. Valid  
          vt1240C.InterchangeFee    := LPAD(NVL(lpad(SUBSTR(C.P46TCUOT01,4,8),10,'0'),0),10,'0');     -- Batch generated—same currency as DE 50
          vt1240C.InterchangeFeeI   := UPPER(c.p48tipmov);     -- 
          vt1240C.ServLevelInd      :='000';     -- 
          vt1240C.ResponseCode2     :='  ';     -- 
          vt1240C.Filler            :='  ';                    --Spaces 
          vt1240C.RepAmoLocal       :='       4NNX ';     -- Monto de Reemplazo—Local
          vt1240C.RepAmoLocalInd    :=' ';     -- 
          vt1240C.RepAmtSett        := lpad(c.P04IMPTRA,12,'0');     -- 
          vt1240C.RepAmoSettInd     := UPPER(c.p48tipmov);     -- 
          vt1240C.OriSettDate       := vfecha;     -- Fecha de Liquidación ORIGINAL
          vt1240C.PosIDInd          :=' ';     -- Indicador de Identificación Positiva
          vt1240C.ATMSurFProID      :=' ';     -- 
          vt1240C.CroBorInd         :=' ';     -- 
          vt1240C.CroBorCurInd      :=' ';     -- 
          vt1240C.ISAFeeInd         :=' ';     -- 
          vt1240C.TracNumATrans     :='000000';     -- 
          vt1240C.Filler2           :=' ';    --

          --vMontoTotal   :=vMontoTotal + to_number(nvl(vt1240C.imptra_p04_actc,0));
          --vtotalMensaje :=vtotalMensaje + 1;


          vCad1240:= vt1240C.MesTypeInd || vt1240C.SwSerialNum      || vt1240C.ProAcqIssuer      ||
                     vt1240C.ProcessorID || vt1240C.TransactionDate  || vt1240C.TransactionTime  ||
                     vt1240C.PANLength || vt1240C.PAN  || vt1240C.ProcessingCode  || vt1240C.TraceNumber ||
                     vt1240C.MerchantType || vt1240C.POSEntry  || vt1240C.ReferenceNumber  || vt1240C.AcqInstitutionID  ||
                     vt1240C.TerminalID  || vt1240C.ResponseCode || vt1240C.Brand  || vt1240C.AdviceReasonCode ||
                     vt1240C.IntAgreCode     || vt1240C.AuthorizationID || vt1240C.CurCodeTrans      ||
                     vt1240C.ImpliedDecTrans || vt1240C.ComAmtTransLocal || vt1240C.ComAmoTransLocalI  ||
                     vt1240C.CasBacAmtLocal || vt1240C.CasBacAmoLocalI || vt1240C.AccessFeeLocal ||
                     vt1240C.AccFeeLocalInd || vt1240C.CurCodeSett || vt1240C.ImpDecSett      ||
                     vt1240C.ConvRatSett || vt1240C.CompAmtSett  || vt1240C.CompAmoSettInd  ||
                     vt1240C.InterchangeFee || vt1240C.InterchangeFeeI || vt1240C.ServLevelInd ||
                     vt1240C.ResponseCode2 || vt1240C.Filler || vt1240C.RepAmoLocal  ||
                     vt1240C.RepAmoLocalInd  || vt1240C.RepAmtSett  || vt1240C.RepAmoSettInd   ||
                     vt1240C.OriSettDate || vt1240C.PosIDInd  || vt1240C.ATMSurFProID  ||
                     vt1240C.CroBorInd || vt1240C.CroBorCurInd  || vt1240C.ISAFeeInd  ||
                     vt1240C.TracNumATrans || vt1240C.Filler2 ;

          utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
          utl_file.new_line(vidfile);
          utl_file.fflush(vidfile);

          -- Inicio: Calculos para Registro de Conciliacion (1240)
          vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
    END LOOP;
END;

PROCEDURE p_GenRegBodyIncBm(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER) IS
 strhexa1240C       VARCHAR2(32)   := '';
 vcodpostal         VARCHAR2(10)   := '';
 vcodestado         VARCHAR2(3)    := '';
 long_p48           NUMBER         := 0;
 vbanco             VARCHAR2(2)    := '';
 vt1240C            msg_1240C;
 mb                 Mapa_Bits;
 vs                 s;
 vlong              VARCHAR2(128);
 vdato              VARCHAR2(1024);
 ncero              NUMBER := 0;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;



 CURSOR cr_reginc IS
   SELECT 
   cod_entadq, csb_entadq, cod_hrcierre, p00idmsg, 
   p02numtar, p03codpro, p04imptra, p05impcon, p06imptit, p09concon,
   p10concli, p11idetra, p12timloc, p14feccad, p16feccon, p17feccap,
   p18lacti, p22punser, p24codfun, p25codraz, p26lacti, p28sesion,
   p29inlote, p30impori, p31refadq, p32idadq, p33idpre, p37datref,
   p38numaut, p39codacr, p41cseri, p42ideest, p46tcuot01,
   p46tcuot02, p46tcuot03, p46tcuot04, p48tiptra, p48cuenta,
   p48tipmov, p48filler, p49montra, p50moncon, p51montit,
   p56do_idmsg, p56do_idetra, p56do_timloc, p56do_idadq, p58idaut,
   p62melect, p71nummen, pxxfiller, tipo_insert, es_dataok,
   tipo_auxfunc
   FROM mcp_bm 
   WHERE  cod_entadq = 'BM'
   AND p28sesion = pfecha   --TO_CHAR(dFecha-1,'YYYYMMDD')
   AND p48tiptra LIKE '10%'
   AND P58IDAUT = pmarca;  -- AND p71nummen LIKE pmarca||'%';
<<<<<<< HEAD
=======

 BEGIN

   --inicia Generacion de Compra
   vPaso   := 'Paso 03';

   FOR c IN cr_reginc LOOP

          long_p48:=0;
          vt1240C     := f_ini_msg1240C;
          if c.P00IDMSG = '1244' then
            vt1240C.MesTypeInd      :='FREC';                        -- FREC=00 
          elsif c.P00IDMSG = '1444' then
            vt1240C.MesTypeInd      :='EREC';                        -- EREC=05
          end if; 
          vt1240C.SwSerialNum       := '000000000';                  --Switch Serial Number
          vt1240C.ProAcqIssuer      := 'A';
          vt1240C.ProcessorID       := '0000';
          vt1240C.TransactionDate   := vfecha;
          vt1240C.TransactionTime   := SUBSTR(c.p12timloc,9,6);
          vt1240C.PANLength         := length(c.p02numtar);
          vt1240C.PAN               := rpad(c.p02numtar,19,' '); 
          vt1240C.ProcessingCode    := '000000';
          vt1240C.TraceNumber       :=  lpad(c.p11idetra,6,'0');   
          vt1240C.MerchantType      :=  '0000';
          vt1240C.POSEntry          :=  '000';
          vt1240C.ReferenceNumber   := '000000000000';
          vt1240C.AcqInstitutionID  := '1986227512';                 -- Banco Mercantil  '1986227512'  
          vt1240C.TerminalID        := '0000000000';
          if c.P00IDMSG = 1244 then
            vt1240C.ResponseCode    := '00';                         -- FREC=00 
          elsif c.P00IDMSG = 1444 then
             vt1240C.ResponseCode   := '05';                         -- NREC=05
          end if; 
          vt1240C.Brand             := 'MS2';                        -- MS1 ¿INTERNACIONA?
          vt1240C.AdviceReasonCode  := '       ';                    --From online 0220/0420 messages. Contains blanks when the transaction completes as requested.
          vt1240C.IntAgreCode       := 'C'||c.p49montra;             -- Si está presente, representa la moneda en la cual se liquidará la transacción.
          vt1240C.AuthorizationID   := '      ';                     --Identificación de la Autorización , En blanco si no está disponible
          vt1240C.CurCodeTrans      := c.p49montra;                  -- Código de Moneda–– Transacción
          vt1240C.ImpliedDecTrans   := '2';                          -- Decimal Implícito–– Transacción
          vt1240C.ComAmtTransLocal  := lpad(c.p04imptra,12,'0');     -- Transacción de Monto Completada—Local
          vt1240C.ComAmoTransLocalI := UPPER(c.p48tipmov);           --Transacción de Monto Final––Indicador Local DR/CR
          vt1240C.CasBacAmtLocal    := '000000000000';               -- 
          vt1240C.CasBacAmoLocalI   := UPPER(c.p48tipmov);           -- 
          vt1240C.AccessFeeLocal    := '00000000';                   -- 
          vt1240C.AccFeeLocalInd    := UPPER(c.p48tipmov);           -- 
          vt1240C.CurCodeSett       := c.p49montra;                  -- 
          vt1240C.ImpDecSett        := '2';                          --  Implied decimal of DE 50, Currency Code—Settlement
          vt1240C.ConvRatSett       := '11000000';                   -- Conversion Rate— Settlement
          vt1240C.CompAmtSett       := lpad(c.P04IMPTRA,12,'0');                -- Completed amount (DE 5)represented in settlement currency (DE 50).
          vt1240C.CompAmoSettInd    := UPPER(SUBSTR(c.p46tcuot01,3,1));         -- Indicates whether the value is a credit or debit to the receiver. Valid  
          vt1240C.InterchangeFee    := lpad(SUBSTR(c.p46tcuot01,4,8),10,'0');   -- Batch generated—same currency as DE 50
          vt1240C.InterchangeFeeI   := UPPER(c.p48tipmov);                      -- 
          vt1240C.ServLevelInd      :='000';                                    -- 
          vt1240C.ResponseCode2     :='  ';                                     -- 
          vt1240C.Filler            :='  ';                                     --Spaces 
          vt1240C.RepAmoLocal       :='       4NNX ';                           -- Monto de Reemplazo—Local
          vt1240C.RepAmoLocalInd    :=' ';     -- 
          vt1240C.RepAmtSett        := lpad(c.P04IMPTRA,12,'0');                -- 
          vt1240C.RepAmoSettInd     := UPPER(c.p48tipmov);                      -- 
          vt1240C.OriSettDate       := vfecha;                                  -- Fecha de Liquidación ORIGINAL
          vt1240C.PosIDInd          :=' ';                                      -- Indicador de Identificación Positiva
          vt1240C.ATMSurFProID      :=' ';                                      -- 
          vt1240C.CroBorInd         :=' ';                                      -- 
          vt1240C.CroBorCurInd      :=' ';                                      -- 
          vt1240C.ISAFeeInd         :=' ';                                      -- 
          vt1240C.TracNumATrans     :='000000';                                 -- 
          vt1240C.Filler2           :=' ';                                      --

        vCad1240:= vt1240C.MesTypeInd || vt1240C.SwSerialNum      || vt1240C.ProAcqIssuer      ||
                 vt1240C.ProcessorID || vt1240C.TransactionDate  || vt1240C.TransactionTime  ||
                 vt1240C.PANLength || vt1240C.PAN  || vt1240C.ProcessingCode  || vt1240C.TraceNumber ||
                 vt1240C.MerchantType || vt1240C.POSEntry  || vt1240C.ReferenceNumber  || vt1240C.AcqInstitutionID  ||
                 vt1240C.TerminalID  || vt1240C.ResponseCode || vt1240C.Brand  || vt1240C.AdviceReasonCode ||
                 vt1240C.IntAgreCode     || vt1240C.AuthorizationID || vt1240C.CurCodeTrans      ||
                 vt1240C.ImpliedDecTrans || vt1240C.ComAmtTransLocal || vt1240C.ComAmoTransLocalI  ||
                 vt1240C.CasBacAmtLocal || vt1240C.CasBacAmoLocalI || vt1240C.AccessFeeLocal ||
                 vt1240C.AccFeeLocalInd || vt1240C.CurCodeSett || vt1240C.ImpDecSett      ||
                 vt1240C.ConvRatSett || vt1240C.CompAmtSett  || vt1240C.CompAmoSettInd  ||
                 vt1240C.InterchangeFee || vt1240C.InterchangeFeeI || vt1240C.ServLevelInd ||
                 vt1240C.ResponseCode2 || vt1240C.Filler || vt1240C.RepAmoLocal  ||
                 vt1240C.RepAmoLocalInd  || vt1240C.RepAmtSett  || vt1240C.RepAmoSettInd   ||
                 vt1240C.OriSettDate || vt1240C.PosIDInd  || vt1240C.ATMSurFProID  ||
                 vt1240C.CroBorInd || vt1240C.CroBorCurInd  || vt1240C.ISAFeeInd  ||
                 vt1240C.TracNumATrans || vt1240C.Filler2 ;

          utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
          utl_file.new_line(vidfile);
          utl_file.fflush(vidfile);

          -- Inicio: Calculos para Registro de Conciliacion (1240)
          vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
    END LOOP;
END;

PROCEDURE p_GenRegBodyIncBm_bug(pfecha VARCHAR2, vfecha varchar2, pbanco VARCHAR2, pmarca NUMBER) IS
 strhexa1240C       VARCHAR2(32)   := '';
 vcodpostal         VARCHAR2(10)   := '';
 vcodestado         VARCHAR2(3)    := '';
 long_p48           NUMBER         := 0;
 vbanco             VARCHAR2(2)    := '';
 vt1240C            msg_1240C;
 mb                 Mapa_Bits;
 vs                 s;
 vlong              VARCHAR2(128);
 vdato              VARCHAR2(1024);
 ncero              NUMBER := 0;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;



 CURSOR cr_reginc IS
   SELECT 
   cod_entadq, csb_entadq, cod_hrcierre, p00idmsg, 
   p02numtar, p03codpro, p04imptra, p05impcon, p06imptit, p09concon,
   p10concli, p11idetra, p12timloc, p14feccad, p16feccon, p17feccap,
   p18lacti, p22punser, p24codfun, p25codraz, p26lacti, p28sesion,
   p29inlote, p30impori, p31refadq, p32idadq, p33idpre, p37datref,
   p38numaut, p39codacr, p41cseri, p42ideest, p46tcuot01,
   p46tcuot02, p46tcuot03, p46tcuot04, p48tiptra, p48cuenta,
   p48tipmov, p48filler, p49montra, p50moncon, p51montit,
   p56do_idmsg, p56do_idetra, p56do_timloc, p56do_idadq, p58idaut,
   p62melect, p71nummen, pxxfiller, tipo_insert, es_dataok,
   tipo_auxfunc
   FROM mcp_bm 
   WHERE  cod_entadq = 'BM'
   AND p28sesion = pfecha   --TO_CHAR(dFecha-1,'YYYYMMDD')
   AND p48tiptra LIKE '10%'
   AND P58IDAUT = pmarca;  -- AND p71nummen LIKE pmarca||'%';
>>>>>>> Desarrollo

 BEGIN

   --inicia Generacion de Compra
   vPaso   := 'Paso 03';

   FOR c IN cr_reginc LOOP

          long_p48:=0;
          vt1240C     := f_ini_msg1240C;
          if c.P00IDMSG = '1244' then
            vt1240C.MesTypeInd      :='FREC';                        -- FREC=00 
          elsif c.P00IDMSG = '1444' then
            vt1240C.MesTypeInd      :='NREC';                        -- NREC=05
          end if; 
          vt1240C.SwSerialNum       := '000000000';                  --Switch Serial Number
          vt1240C.ProAcqIssuer      := 'A';
          vt1240C.ProcessorID       := '0000';
          vt1240C.TransactionDate   := vfecha;
          vt1240C.TransactionTime   := SUBSTR(c.p12timloc,9,6);
          vt1240C.PANLength         := length(c.p02numtar);
          vt1240C.PAN               := rpad(c.p02numtar,19,' '); 
          vt1240C.ProcessingCode    := '000000';
          vt1240C.TraceNumber       :=  lpad(c.p11idetra,6,'0');   
          vt1240C.MerchantType      :=  '0000';
          vt1240C.POSEntry          :=  '000';
          vt1240C.ReferenceNumber   := '000000000000';
          vt1240C.AcqInstitutionID  := '1986227512';                 -- Banco Mercantil  '1986227512'  
          vt1240C.TerminalID        := '0000000000';
          if c.P00IDMSG = 1244 then
            vt1240C.ResponseCode    := '00';                         -- FREC=00 
          elsif c.P00IDMSG = 1444 then
             vt1240C.ResponseCode   := '05';                         -- NREC=05
          end if; 
          vt1240C.Brand             := 'MS2';                        -- MS1 ¿INTERNACIONA?
          vt1240C.AdviceReasonCode  := '       ';                    --From online 0220/0420 messages. Contains blanks when the transaction completes as requested.
          vt1240C.IntAgreCode       := 'C'||c.p49montra;             -- Si está presente, representa la moneda en la cual se liquidará la transacción.
          vt1240C.AuthorizationID   := '      ';                     --Identificación de la Autorización , En blanco si no está disponible
          vt1240C.CurCodeTrans      := c.p49montra;                  -- Código de Moneda–– Transacción
          vt1240C.ImpliedDecTrans   := '2';                          -- Decimal Implícito–– Transacción
          vt1240C.ComAmtTransLocal  := lpad(c.p04imptra,12,'0');     -- Transacción de Monto Completada—Local
          vt1240C.ComAmoTransLocalI := UPPER(c.p48tipmov);           --Transacción de Monto Final––Indicador Local DR/CR
          vt1240C.CasBacAmtLocal    := '000000000000';               -- 
          vt1240C.CasBacAmoLocalI   := UPPER(c.p48tipmov);           -- 
          vt1240C.AccessFeeLocal    := '00000000';                   -- 
          vt1240C.AccFeeLocalInd    := UPPER(c.p48tipmov);           -- 
          vt1240C.CurCodeSett       := c.p49montra;                  -- 
          vt1240C.ImpDecSett        := '2';                          --  Implied decimal of DE 50, Currency Code—Settlement
          vt1240C.ConvRatSett       := '11000000';                   -- Conversion Rate— Settlement
          vt1240C.CompAmtSett       := lpad(c.P04IMPTRA,12,'0');                -- Completed amount (DE 5)represented in settlement currency (DE 50).
          vt1240C.CompAmoSettInd    := UPPER(SUBSTR(c.p46tcuot01,3,1));         -- Indicates whether the value is a credit or debit to the receiver. Valid  
          vt1240C.InterchangeFee    := lpad(SUBSTR(c.p46tcuot01,4,8),10,'0');   -- Batch generated—same currency as DE 50
          vt1240C.InterchangeFeeI   := UPPER(c.p48tipmov);                      -- 
          vt1240C.ServLevelInd      :='000';                                    -- 
          vt1240C.ResponseCode2     :='  ';                                     -- 
          vt1240C.Filler            :='  ';                                     --Spaces 
          vt1240C.RepAmoLocal       :='       4NNX ';                           -- Monto de Reemplazo—Local
          vt1240C.RepAmoLocalInd    :=' ';     -- 
          vt1240C.RepAmtSett        := lpad(c.P04IMPTRA,12,'0');                -- 
          vt1240C.RepAmoSettInd     := UPPER(c.p48tipmov);                      -- 
          vt1240C.OriSettDate       := vfecha;                                  -- Fecha de Liquidación ORIGINAL
          vt1240C.PosIDInd          :=' ';                                      -- Indicador de Identificación Positiva
          vt1240C.ATMSurFProID      :=' ';                                      -- 
          vt1240C.CroBorInd         :=' ';                                      -- 
          vt1240C.CroBorCurInd      :=' ';                                      -- 
          vt1240C.ISAFeeInd         :=' ';                                      -- 
          vt1240C.TracNumATrans     :='000000';                                 -- 
          vt1240C.Filler2           :=' ';                                      --

        vCad1240:= vt1240C.MesTypeInd || vt1240C.SwSerialNum      || vt1240C.ProAcqIssuer      ||
                 vt1240C.ProcessorID || vt1240C.TransactionDate  || vt1240C.TransactionTime  ||
                 vt1240C.PANLength || vt1240C.PAN  || vt1240C.ProcessingCode  || vt1240C.TraceNumber ||
                 vt1240C.MerchantType || vt1240C.POSEntry  || vt1240C.ReferenceNumber  || vt1240C.AcqInstitutionID  ||
                 vt1240C.TerminalID  || vt1240C.ResponseCode || vt1240C.Brand  || vt1240C.AdviceReasonCode ||
                 vt1240C.IntAgreCode     || vt1240C.AuthorizationID || vt1240C.CurCodeTrans      ||
                 vt1240C.ImpliedDecTrans || vt1240C.ComAmtTransLocal || vt1240C.ComAmoTransLocalI  ||
                 vt1240C.CasBacAmtLocal || vt1240C.CasBacAmoLocalI || vt1240C.AccessFeeLocal ||
                 vt1240C.AccFeeLocalInd || vt1240C.CurCodeSett || vt1240C.ImpDecSett      ||
                 vt1240C.ConvRatSett || vt1240C.CompAmtSett  || vt1240C.CompAmoSettInd  ||
                 vt1240C.InterchangeFee || vt1240C.InterchangeFeeI || vt1240C.ServLevelInd ||
                 vt1240C.ResponseCode2 || vt1240C.Filler || vt1240C.RepAmoLocal  ||
                 vt1240C.RepAmoLocalInd  || vt1240C.RepAmtSett  || vt1240C.RepAmoSettInd   ||
                 vt1240C.OriSettDate || vt1240C.PosIDInd  || vt1240C.ATMSurFProID  ||
                 vt1240C.CroBorInd || vt1240C.CroBorCurInd  || vt1240C.ISAFeeInd  ||
                 vt1240C.TracNumATrans || vt1240C.Filler2 ;

          utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
          utl_file.new_line(vidfile);
          utl_file.fflush(vidfile);

          -- Inicio: Calculos para Registro de Conciliacion (1240)
          vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
    END LOOP;
END;

<<<<<<< HEAD
=======
procedure p_genRegSHp(vcodfuncion CHAR,vfecha varchar2, pmarca NUMBER)as
    m1644          Msg_1644;
    MonedaLiq      NUMBER(3)       := '';
    totSumfrec     varchar2(14)    := '';
    totConfrec     varchar2(8)     := '';
    totSumerec     varchar2(14)    := '';
    totConerec     varchar2(8)     := '';

Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';
      
      select P49MONTRA into MonedaLiq  
      from mcp_bp 
      where P28SESION= vfecha
      and rownum=1;
      
      --select sum(P04IMPTRA), count(P04IMPTRA) into totSumfrec, totConfrec 
      select lpad(nvl(sum(P04IMPTRA),0),14,'0'), lpad(nvl(count(P04IMPTRA),0),8,'0') into totSumfrec, totConfrec  
      from mcp_bp 
      where P28SESION= vfecha
      and P58IDAUT= pmarca
      and P00IDMSG='1244';
      
      --select sum(P04IMPTRA), count(P04IMPTRA) into totSumerec, totConerec
      select lpad(nvl(sum(P04IMPTRA),0),14,'0'), lpad(nvl(count(P04IMPTRA),0),8,'0') into totSumerec, totConerec  
      from mcp_bp 
      where P28SESION= vfecha
      and P58IDAUT= pmarca 
      and P00IDMSG='1444';
      
      
      --cabecera de registro
      if vcodfuncion = 'SHDR' then
           m1644.MessTypeInd       := 'SHDR';
           m1644.SettSeNumber      := '000';
           m1644.ICuAgrNumber      := '    ';
           m1644.SetCurrCode       := MonedaLiq;
           m1644.ImDecSettlement   := '2'; 
           m1644.ProAcqIssuer      := 'A'; -- A Adquiriente
           m1644.Filler1SHDR       := '          ';
           m1644.Filler2SHDR       := '                                                                                                                                                                                                                                '; --224 ESPACIOS

      end if;

      --trailer de registro
       if  vcodfuncion = 'STRL' then
          m1644.MessTypeInd       := 'STRL';
          m1644.SettSeNumber      := '000';
          m1644.ICuAgrNumber      := '    ';
          m1644.SetCurrCode       := MonedaLiq;
          m1644.ImDecSettlement   := '2';
          m1644.ProAcqIssuer      := 'A'; 
          m1644.Filler1SHDR       := '          '; 
          m1644.TotDebitAmountSet := '00000000000000';
          m1644.NumDebitItems     := '00000000';
          m1644.TotCredAmoSet     := lpad(totSumfrec,14,'0');  --FREC SUM
          m1644.NumCredItems      := lpad(totConfrec,8,'0');   --FREC COUNT  
          m1644.TotRevDebAmount   := lpad(totSumerec,14,'0');  --EREC SUM 
          m1644.NumDebiRever      := lpad(totConerec,8,'0');   --EREC COUNT 
          m1644.TotRevCreAmount   := '00000000000000';       
          m1644.NumCredReversals  := '00000000';     
          m1644.NumNonfinancial   := '00000000';               --NREC COUNT 
          m1644.TotIntFeesDebits  := '000000000000';
          m1644.TotIntFeesCredits := '000000000000';
          m1644.Filler1strl       := '                 ';       --17 ESPACIOS
          m1644.TotNetSettlement  := lpad(totSumfrec,14,'0');
          m1644.TotNetSetDRCRInd  := 'C';
          m1644.TotDAwMisFeeItems := '00000000000000';
          m1644.NumDIwMisFees     := '00000000';
          m1644.TotCrAwMisFees    := '00000000000000';
          m1644.NumCrIwMisFeesI   := '00000000';
          m1644.ExtPTIFeesDebits  := '00000000000000';
          m1644.ExtPTIFeesCredits := '00000000000000';
          
       end if;

      --trailer de registro
       if  vcodfuncion = 'STRN' then
          m1644.MessTypeInd       := 'STRL';
          m1644.SettSeNumber      := '000';
          m1644.ICuAgrNumber      := '    ';
          m1644.SetCurrCode       := MonedaLiq;
          m1644.ImDecSettlement   := '2';
          m1644.ProAcqIssuer      := 'N'; 
          m1644.Filler1SHDR       := '          '; 
          m1644.TotDebitAmountSet := '00000000000000';
          m1644.NumDebitItems     := '00000000';
          m1644.TotCredAmoSet     := '00000000000000';  --FREC SUM
          m1644.NumCredItems      := '00000000';        --FREC COUNT  
          m1644.TotRevDebAmount   := '00000000000000';  --EREC SUM 
          m1644.NumDebiRever      := '00000000';        --EREC COUNT 
          m1644.TotRevCreAmount   := '00000000000000';       
          m1644.NumCredReversals  := '00000000';     
          m1644.NumNonfinancial   := '00000000';               --NREC COUNT 
          m1644.TotIntFeesDebits  := '000000000000';
          m1644.TotIntFeesCredits := '000000000000';
          m1644.Filler1strl       := '                 ';       --17 ESPACIOS
          m1644.TotNetSettlement  := lpad(totSumfrec,14,'0');
          m1644.TotNetSetDRCRInd  := 'C';
          m1644.TotDAwMisFeeItems := '00000000000000';
          m1644.NumDIwMisFees     := '00000000';
          m1644.TotCrAwMisFees    := '00000000000000';
          m1644.NumCrIwMisFeesI   := '00000000';
          m1644.ExtPTIFeesDebits  := '00000000000000';
          m1644.ExtPTIFeesCredits := '00000000000000';
          
       end if;

     vCad1240:= m1644.MessTypeInd ||  m1644.SettSeNumber||  m1644.ICuAgrNumber|| m1644.SetCurrCode|| m1644.ImDecSettlement||
                m1644.ProAcqIssuer ||  m1644.Filler1SHDR||  m1644.Filler2SHDR|| m1644.TotDebitAmountSet||
                m1644.NumDebitItems||  m1644.TotCredAmoSet|| m1644.NumCredItems|| m1644.TotRevDebAmount|| m1644.NumDebiRever|| m1644.TotRevCreAmount|| m1644.NumCredReversals||
                m1644.NumNonfinancial|| m1644.TotIntFeesDebits|| m1644.TotIntFeesCredits|| m1644.Filler1strl||
                m1644.TotNetSettlement|| m1644.TotNetSetDRCRInd|| m1644.TotDAwMisFeeItems ||
                m1644.NumDIwMisFees|| m1644.TotCrAwMisFees|| m1644.NumCrIwMisFeesI|| m1644.ExtPTIFeesDebits||
                m1644.ExtPTIFeesCredits;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;

procedure p_genRegSHm(vcodfuncion CHAR,vfecha varchar2, pmarca NUMBER)as
    m1644          Msg_1644;
    MonedaLiq      NUMBER(3)       := '';
    totSumfrec     varchar2(14)    := '';
    totConfrec     varchar2(8)     := '';
    totSumerec     varchar2(14)    := '';
    totConerec     varchar2(8)     := '';

Begin
      --inicia proceso de outgoing Banco Mercantil
      vPaso   := 'Paso 06';
      
      select P49MONTRA into MonedaLiq  
      from mcp_bm 
      where P28SESION= vfecha
      and rownum=1;
      
      --select sum(P04IMPTRA), count(P04IMPTRA) into totSumfrec, totConfrec
      select lpad(nvl(sum(P04IMPTRA),0),14,'0'), lpad(nvl(count(P04IMPTRA),0),8,'0') into totSumfrec, totConfrec 
      from mcp_bm 
      where P28SESION= vfecha
      and P58IDAUT= pmarca
      and P00IDMSG='1244';
      
      select lpad(nvl(sum(P04IMPTRA),0),14,'0'), lpad(nvl(count(P04IMPTRA),0),8,'0') into totSumerec, totConerec 
      from mcp_bm 
      where P28SESION= vfecha
      and P58IDAUT= pmarca 
      and P00IDMSG='1444';
      
      
      --cabecera de registro
      if vcodfuncion = 'SHDR' then
           m1644.MessTypeInd       := 'SHDR';
           m1644.SettSeNumber      := '000';
           m1644.ICuAgrNumber      := '    ';
           m1644.SetCurrCode       := MonedaLiq;
           m1644.ImDecSettlement   := '2'; 
           m1644.ProAcqIssuer      := 'A'; -- A Adquiriente
           m1644.Filler1SHDR       := '          ';
           m1644.Filler2SHDR       := '                                                                                                                                                                                                                                '; --224 ESPACIOS

      end if;

       --trailer de registro
       if  vcodfuncion = 'STRL' then
          m1644.MessTypeInd       := 'STRL';
          m1644.SettSeNumber      := '000';
          m1644.ICuAgrNumber      := '    ';
          m1644.SetCurrCode       := MonedaLiq;
          m1644.ImDecSettlement   := '2';
          m1644.ProAcqIssuer      := 'A'; 
          m1644.Filler1SHDR       := '          '; 
          m1644.TotDebitAmountSet := '00000000000000';
          m1644.NumDebitItems     := '00000000';
          m1644.TotCredAmoSet     := lpad(totSumfrec,14,'0');  --FREC SUM
          m1644.NumCredItems      := lpad(totConfrec,8,'0');   --FREC COUNT  
          m1644.TotRevDebAmount   := lpad(totSumerec,14,'0');  --EREC SUM 
          m1644.NumDebiRever      := lpad(totConerec,8,'0');   --EREC COUNT 
          m1644.TotRevCreAmount   := '00000000000000';       
          m1644.NumCredReversals  := '00000000';     
          m1644.NumNonfinancial   := '00000000';               --NREC COUNT 
          m1644.TotIntFeesDebits  := '000000000000';
          m1644.TotIntFeesCredits := '000000000000';
          m1644.Filler1strl       := '                 ';       --17 ESPACIOS
          m1644.TotNetSettlement  := lpad(totSumfrec,14,'0');
          m1644.TotNetSetDRCRInd  := 'C';
          m1644.TotDAwMisFeeItems := '00000000000000';
          m1644.NumDIwMisFees     := '00000000';
          m1644.TotCrAwMisFees    := '00000000000000';
          m1644.NumCrIwMisFeesI   := '00000000';
          m1644.ExtPTIFeesDebits  := '00000000000000';
          m1644.ExtPTIFeesCredits := '00000000000000';
          
       end if;
       
       if  vcodfuncion = 'STRN' then
          m1644.MessTypeInd       := 'STRL';
          m1644.SettSeNumber      := '000';
          m1644.ICuAgrNumber      := '    ';
          m1644.SetCurrCode       := MonedaLiq;
          m1644.ImDecSettlement   := '2';
          m1644.ProAcqIssuer      := 'N'; 
          m1644.Filler1SHDR       := '          '; 
          m1644.TotDebitAmountSet := '00000000000000';
          m1644.NumDebitItems     := '00000000';
          m1644.TotCredAmoSet     := '00000000000000';  --FREC SUM
          m1644.NumCredItems      := '00000000';        --FREC COUNT  
          m1644.TotRevDebAmount   := '00000000000000';  --EREC SUM 
          m1644.NumDebiRever      := '00000000';        --EREC COUNT 
          m1644.TotRevCreAmount   := '00000000000000';       
          m1644.NumCredReversals  := '00000000';     
          m1644.NumNonfinancial   := '00000000';               --NREC COUNT 
          m1644.TotIntFeesDebits  := '000000000000';
          m1644.TotIntFeesCredits := '000000000000';
          m1644.Filler1strl       := '                 ';       --17 ESPACIOS
          m1644.TotNetSettlement  := lpad(totSumfrec,14,'0');
          m1644.TotNetSetDRCRInd  := 'C';
          m1644.TotDAwMisFeeItems := '00000000000000';
          m1644.NumDIwMisFees     := '00000000';
          m1644.TotCrAwMisFees    := '00000000000000';
          m1644.NumCrIwMisFeesI   := '00000000';
          m1644.ExtPTIFeesDebits  := '00000000000000';
          m1644.ExtPTIFeesCredits := '00000000000000';
          
       end if;


     vCad1240:= m1644.MessTypeInd ||  m1644.SettSeNumber||  m1644.ICuAgrNumber|| m1644.SetCurrCode|| m1644.ImDecSettlement||
                m1644.ProAcqIssuer ||  m1644.Filler1SHDR||  m1644.Filler2SHDR|| m1644.TotDebitAmountSet||
                m1644.NumDebitItems||  m1644.TotCredAmoSet|| m1644.NumCredItems|| m1644.TotRevDebAmount|| m1644.NumDebiRever|| m1644.TotRevCreAmount|| m1644.NumCredReversals||
                m1644.NumNonfinancial|| m1644.TotIntFeesDebits|| m1644.TotIntFeesCredits|| m1644.Filler1strl||
                m1644.TotNetSettlement|| m1644.TotNetSetDRCRInd|| m1644.TotDAwMisFeeItems ||
                m1644.NumDIwMisFees|| m1644.TotCrAwMisFees|| m1644.NumCrIwMisFeesI|| m1644.ExtPTIFeesDebits||
                m1644.ExtPTIFeesCredits;
                
     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;


>>>>>>> Desarrollo
procedure p_GenRegHFp(vcodfuncion CHAR,vfecha varchar2,vCReg varchar2)as
    m1644          Msg_1644;
    TotRCount        varchar2(11)     := '';

Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';
      
      TotRCount := LPAD(vCReg,11,'0');


      --cabecera de registro
      if vcodfuncion = 'FHDR' then
           m1644.MessTypeInd       := 'FHDR';
           m1644.SettDate          := vfecha;
           m1644.ProcessorID       := '9000000313';  -- identificador del banco
           m1644.RecordSize        := '250';
           m1644.FileType          := 'M';
           m1644.VersionArch       := 'VERSION 16';
           m1644.Filler216         := '                                                                                                                                                                                                                        '; --216 ESPACIOS
           

      end if;

      --trailer de registro
       if  vcodfuncion = 'FTRL' then
          m1644.MessTypeInd       := 'FTRL';
          m1644.ProcessorID       := '9000000313';  -- identificador del banco
          m1644.TotRecordCount    := TotRCount;
          m1644.Filler225         := '                                                                                                                                                                                                                                 '; --225 ESPACIOS
       end if;


     vCad1240:= m1644.MessTypeInd ||   m1644.SettDate||               m1644.ProcessorID||
                m1644.RecordSize ||   m1644.FileType||  m1644.VersionArch||
                m1644.Filler216||   m1644.TotRecordCount|| m1644.Filler225;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;

procedure p_GenRegHFm(vcodfuncion CHAR,vfecha varchar2,vCReg varchar2)as
    m1644          Msg_1644;
    TotRCount        varchar2(11)     := '';
<<<<<<< HEAD

Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';
      
      TotRCount := LPAD(vCReg,11,'0');


      --cabecera de registro
      if vcodfuncion = 'FHDR' then
           m1644.MessTypeInd       := 'FHDR';
           m1644.SettDate          := vfecha;
           m1644.ProcessorID       := '9000000275';   -- identificador del banco
           m1644.RecordSize        := '250';
           m1644.FileType          := 'M';
           m1644.VersionArch       := 'VERSION 16';
           m1644.Filler            := '                                                                                                                                                                                                                        '; --216 ESPACIOS
           

      end if;

      --trailer de registro
       if  vcodfuncion = 'FTRL' then
          m1644.MessTypeInd       := 'FTRL';
          m1644.ProcessorID       := '9000000275';   -- identificador del banco
          m1644.TotRecordCount    := TotRCount;
          m1644.Filler2            := '                                                                                                                                                                                                                                 '; --225 ESPACIOS
       end if;


     vCad1240:= m1644.MessTypeInd ||   m1644.SettDate||               m1644.ProcessorID||
                m1644.RecordSize ||   m1644.FileType||  m1644.VersionArch||
                m1644.Filler||   m1644.TotRecordCount|| m1644.Filler2;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;

procedure p_GenRegfin(vcodfuncion CHAR)as
    m1644          Msg_1644;

=======

>>>>>>> Desarrollo
Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';
      
<<<<<<< HEAD
      --trailer de registro
       if  vcodfuncion = 'FTRL' then
          m1644.MessTypeInd       := 'SUB';
          m1644.Filler2            := '                                                                                                                                                                                                                                                       '; --247 ESPACIOS
       end if;


     vCad1240:= m1644.MessTypeInd ||   m1644.SettDate|| m1644.ProcessorID||
                m1644.RecordSize ||   m1644.FileType||  m1644.VersionArch||
                m1644.Filler||   m1644.TotRecordCount|| m1644.Filler2;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;
=======
      TotRCount := LPAD(vCReg,11,'0');
>>>>>>> Desarrollo


      --cabecera de registro
      if vcodfuncion = 'FHDR' then
           m1644.MessTypeInd       := 'FHDR';
           m1644.SettDate          := vfecha;
           m1644.ProcessorID       := '9000000275';   -- identificador del banco
           m1644.RecordSize        := '250';
           m1644.FileType          := 'M';
           m1644.VersionArch       := 'VERSION 16';
           m1644.Filler216         := '                                                                                                                                                                                                                        '; --216 ESPACIOS
           

      end if;

      --trailer de registro
       if  vcodfuncion = 'FTRL' then
          m1644.MessTypeInd       := 'FTRL';
          m1644.ProcessorID       := '9000000275';   -- identificador del banco
          m1644.TotRecordCount    := TotRCount;
          m1644.Filler225            := '                                                                                                                                                                                                                                 '; --225 ESPACIOS
       end if;


     vCad1240:= m1644.MessTypeInd ||   m1644.SettDate||               m1644.ProcessorID||
                m1644.RecordSize ||   m1644.FileType||  m1644.VersionArch||
                m1644.Filler216||   m1644.TotRecordCount|| m1644.Filler225;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;

procedure p_GenRegfin(vcodfuncion CHAR)as
    m1644          Msg_1644;

Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';
      
      --trailer de registro
       if  vcodfuncion = 'FTRL' then
          m1644.MessTypeInd       := 'SUB';
          m1644.Filler247       := '                                                                                                                                                                                                                                                       '; --247 ESPACIOS
       end if;


     vCad1240:= m1644.MessTypeInd ||  m1644.Filler247;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;

procedure p_FindPostalCode(pComercio varchar2, codePostal out varchar2, codEstado out varchar2)as
   begin


   select codigo_postal,cod_estado
     into codePostal,codEstado
     from comercios_pmp
    where cod_comercio = pComercio;

  exception
    when no_data_found  then
      verrmsg := 'No existe Codigo Postal y de Estado para el Comercio '||pComercio;
      verrcod := '9';
      raise efinerror;

   when too_many_rows then
      verrmsg := 'Hay mas de un Codigo Postal y de Estado para el Comercio '||pComercio;
      verrcod := '10';
      raise efinerror;
end;





function f_IniMapaBits return mapa_bits is
    num1 number:=0;
    vmapabits  mapa_bits;
begin
    vmapabits:=mapa_bits();
    for num1 in 1 ..128 loop
        vmapabits.extend;
        vmapabits(num1):='0';
    end loop;
    return vmapabits;
end;







function f_IniArrayLuhn return ArrayLuhn is
    i number:=0;
    vArrayLuhn  ArrayLuhn;
begin
    vArrayLuhn:=ArrayLuhn();
    for i in 1 ..17 loop
        vArrayLuhn.extend;
        vArrayLuhn(i):='';
    end loop;
    return vArrayLuhn;
end;


function f_Bin_Hex(bin varchar2) return char
-- InPut : cadena binaria de 4 caracteres
-- OutPut: cadena hexadecimal
is
  i        number;
  n        number;
  valor    number:=0;
  vTotal   number:=0;

  type t_binaria is varray(4) of number;
  type t_hexadecimal is varray(16) of char;
  v_binario t_binaria := t_binaria(8,4,2,1);
  v_hex t_hexadecimal := t_hexadecimal('A','B','C','D','E','F');

begin

    for i in 1 .. 4 loop
        valor:=0;
        n:= to_number(substr(bin,i,1));
        if n=1 then
           valor := v_binario(i);
        end if;
        vTotal:= vTotal + valor;
    end loop;

    if vTotal> 9 then
        for i in 10..15 loop
            if i=vTotal then
               return to_char(v_hex(i-9));
            end if;
        end loop;
    else
        return to_char(vTotal);
    end if;
end ;


function f_Gen_MapaHex2(matrizBin in out Mapa_Bits) return varchar
-- InPut  : Matriz binaria de 128 bits
-- OutPut : Cadena Hexadecimal de 32 bits
is
i number:=0;
Cad_Bin4 varchar2(4):='';
v_Hex char(1):='';
Cad_Hex varchar2(32):='';
begin
    Cad_Bin4:='';
    Cad_Hex:='';
    for i in 1..128 loop
        Cad_Bin4:=Cad_Bin4 || matrizBin(i);
        if length(Cad_Bin4) = 4 then
            v_Hex:= f_bin_hex(Cad_Bin4);
            Cad_Hex := Cad_Hex || v_Hex;
            Cad_Bin4:='';
        end if;
    end loop;
    return Cad_Hex;
end;


function f_ini_msg1240C return Msg_1240C is
    vtc_Msg_1240C  Msg_1240C;
  begin
    return vtc_Msg_1240C;
end ;

/*function f_ini_msg1240A return Msg_1240A is
    vtc_Msg_1240A  Msg_1240A;
  begin
    return vtc_Msg_1240A;
end ;*/

--procedimiento eliminado p_Obtiene_IRD

function f_ini_msg1740 return Msg_1740 is
    vtc_Msg_1740  Msg_1740;
  begin
    return vtc_Msg_1740;
end ;


/*function f_ini_Msg1644Adendum return Msg1644Adendum is
    tvMsg1644Adendum  Msg1644Adendum;
  begin
    return tvMsg1644Adendum;
end ;*/


function f_iniCardAceptorBusiness return vb_CardAceptorBusiness is
    t_vb_CardAceptorBusiness  vb_CardAceptorBusiness;
  begin
    return t_vb_CardAceptorBusiness;
end ;




function f_FindTarjetaNacional(pIdProc pls_integer, bin_tarjeta varchar2,pBanco char )return pls_integer is
    vcont     pls_integer := 0;

    cursor cur_dataNacional(bin_tarjeta varchar2) is
    select val_rango_menor, val_rango_mayor
      from bines_mc
     where to_number(val_rango_menor) <= to_number(rpad(substr(bin_tarjeta,1,19),19,'0'))
       and to_number(val_rango_mayor) >= to_number(rpad(substr(bin_tarjeta,1,19),19,'9'))
       and ind_activo                  = 'A'
       and cod_alf_pais                = 'VEN'
       and cod_entadq                  = pBanco
       and ind_prog_tarjeta            = 'MCC';

begin

    for c in cur_dataNacional(bin_tarjeta) loop
        vcont := vcont + 1;
    end loop;

    if vcont > 1 then
       vErrMsg := 'WARNING: Existen '||TO_CHAR(vcont)||' rangos de valor para la tarjeta: '||bin_tarjeta||'.';
       vcont   := 1;
       pqmonproc.inslog(pIdProc, 'W', vErrMsg);
    end if;

    return vcont;

end;


function f_FindCodigoRazon(pCodRazon number, pNumTarjeta varchar2 )return varchar2 is
     vCodRazon  varchar2(4);
begin

    select lpad(c9codmc,4,0)
      into vCodRazon
      from codigos_de_razon_del_mensaje
     where p25codraz = pCodRazon;

   return vCodRazon;

exception
   when no_data_found  then
      verrmsg := 'No Existe codigo de Razon para tarjeta Nro '||pNumTarjeta;
      verrcod := '11';
      raise efinerror;


   when too_many_rows then
      verrmsg := 'Hay mas de 01 codigo de razon para tarjeta Nro '||pNumTarjeta;
      verrcod := '12';
      raise efinerror;

end;


function f_AtLeastOne(pfecha varchar2,pbanco varchar2,marca number)return pls_integer is
   vCountReg         pls_integer:=0;

  begin

      if marca = '8010' and pbanco = 'BM'  then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bm 
            WHERE  cod_entadq = pbanco
            AND p28sesion = pfecha              --AND p28sesion = TO_CHAR(pfecha-1,'YYYYMMDD')--FECHA DE SESSION
            AND p48tiptra LIKE '10%'            --AND p28sesion = TO_CHAR(TO_DATE(pfecha,'YYYYMMDD')-1,'YYYYMMDD')--Conversion a Char de fecha - 1. CON FECHA  PROCESO
            and P58IDAUT ='358011'              --35 MC 8011 MAESTRO MERCANTIL  --AND p71nummen LIKE marca||'%'  
            and rownum < 2;
      elsif marca = '8010' and pbanco = 'BP' then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bp 
            WHERE  cod_entadq = pbanco
            AND p28sesion = pfecha              
            AND p48tiptra LIKE '10%'
            and P58IDAUT ='358012'               --35 MC 8012 MAESTRO provincial 
            and rownum < 2;
      elsif marca = '9010' and pbanco = 'BM' then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bm 
            WHERE  cod_entadq = pbanco
            AND p28sesion = pfecha          
            AND p48tiptra LIKE '10%'
            and P58IDAUT ='359011'        
            and rownum < 2;
      elsif marca = '9010' and pbanco = 'BP' then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bp 
            WHERE  cod_entadq = pbanco
            AND p28sesion = pfecha        
            AND p48tiptra LIKE '10%'
            and P58IDAUT ='359012'       
            and rownum < 2;
      
      end if;

   return vCountReg;

end;


function f_GenCheckDigit(pCadena varchar2) return pls_integer is
     suma     pls_integer := 0;
     x        pls_integer := 0;
     y        pls_integer := 0;
     numero   ArrayLuhn;

begin
     numero     := f_IniArrayLuhn;
     for i in 1..17 loop
         numero(i) := to_number(substr(pCadena,i,1));
     end loop;


     for x in 1..17 loop
         if mod(x,2) > 0 then   --impar
             y := numero(x)*2;
             if y >= 10 then
                y := y - 9;     --como sumar sus dos digitos
             end if;
         else
             y := numero(x);
         end if;
         suma := suma + y;
     end loop;

     suma := 10-(mod(suma,10));

     if suma = 10 then
        suma :=0;
     end if;

     return suma;
end;

function f_getIdBankDestino(bin_tarjeta varchar2,pBanco char)return varchar2 is
    vcont           pls_integer := 0;
    vlon_bin        pls_integer := 0;
    vcod_miembro    bines_mc.cod_miembro%type;

    cursor cur_dataBank(bin_tarjeta varchar2) is
    select val_rango_menor, val_rango_mayor, cod_miembro
      from bines_mc
     where to_number(val_rango_menor) <= to_number(rpad(substr(bin_tarjeta,1,19),19,'0'))
       and to_number(val_rango_mayor) >= to_number(rpad(substr(bin_tarjeta,1,19),19,'9'))
       and  ind_activo                 =   'A'
       and  cod_entadq                 = pBanco
       and  ind_prog_tarjeta           = 'MCC';

    begin

    vlon_bin:= length(bin_tarjeta);

    for c in cur_dataBank(bin_tarjeta) loop
          if  bin_tarjeta between c.val_rango_menor  and c.val_rango_mayor  then
              vcod_miembro := lpad(to_char(c.cod_miembro),11,0);
              vcont        := vcont + 1;
           end if;
    end loop;

    if vcont = 0 then
       verrmsg := 'No existe el ID_INSTITUCION_DESTINO para la tarjeta '||bin_tarjeta;
       verrcod := '13';
       raise efinerror;
    end if;

    if vcont > 1 then
       vErrMsg := 'WARNING: Existen '||TO_CHAR(vcont)||' ID_INSTITUCION_DESTINO para la tarjeta: '||bin_tarjeta||'.';
       pqmonproc.inslog(vIdProc, 'W', vErrMsg);
    end if;

    return vcod_miembro;

end;

procedure p_findTransOriginal(pbanco varchar2, p31 varchar2,pNumTarjeta varchar2,
                               pImpTran out number, pMonTran out varchar2) is

begin
    --inicia busqueda de transaccion original
    pImpTran  := 0;
    pMonTran  := 0;

    if pbanco = 'BM' then
        select p04imptra, p49montra
          into pImpTran, pMonTran
          from mcp_bm
         where p31refadq  = p31
           and p00idmsg   = '1244';
    end if;

    if  pbanco = 'BP' then
         select p04imptra, p49montra
           into pImpTran, pMonTran
           from mcp_bp
          where p31refadq  = p31
            and p00idmsg   = '1244';
    end if;

exception
   when no_data_found  then
      verrmsg := 'No Existe transaccion original para tarjeta Nro '||pNumTarjeta;
      verrcod := '14';
      raise efinerror;


   when too_many_rows then
      verrmsg := 'Hay mas de 01 transaccion original para tarjeta Nro '||pNumTarjeta;
      verrcod := '15';
      raise efinerror;
end;


procedure p_findTransactionIdDisputas(p31 varchar2, pNumTarjeta varchar2, pTransationID out varchar2,
                                       pSourceAmount out varchar2,PcurrenCode out varchar2, Pinc_doc_ind out varchar2)is


 begin

       with tabla_01 as (
                 select substr(transaction_id,1,10)transaction_id,
                        lpad(incoming_source_amount,12,0)incoming_source_amount,
                        lpad(incoming_source_curren_code,3,0)incoming_source_curren_code,
                        nvl(trim(incoming_documentation_ind),'0') incoming_documentation_ind
                   from disputas_master
                  where incoming_refadq = p31
                    and disputa_stat    = 'T'
                    and (disputa_type   = '15' or disputa_type    = '16')
                  order by disputa_id desc)
        select transaction_id, incoming_source_amount, incoming_source_curren_code, incoming_documentation_ind
          into pTransationID,pSourceAmount,Pcurrencode, Pinc_doc_ind
          from tabla_01
         where rownum < 2;

exception
   when no_data_found then
      verrmsg := 'No hay registro REFADQ31 para tarjeta Nro '||pNumTarjeta;
      verrcod := '16';
      raise efinerror;
end;

function f_IsDate(pstring varchar2)return boolean is
 ld_date   date;

begin
     ld_date := to_date(pstring,'yyyymmdd');
     return true;
exception
     when others then
        return false;
end;


function f_isBetweenFiveDay(pfecha date) return boolean is
   vi_fecha   pls_integer;

begin
      select count(*)
        into vi_fecha
        from dual
       where trunc(sysdate) between pfecha and pfecha + 5;

      if vi_fecha > 0 then
          return true;
      else
          return false;
      end if;

exception
     when others then
        return false;
end;


function f_isBetweenThirtyDay(pfecha date) return boolean is
   vi_fecha   pls_integer;

begin
      select count(*)
        into vi_fecha
        from dual
       where pfecha between pfecha and pfecha + 30;

      if vi_fecha > 0 then
          return true;
      else
          return false;
      end if;

exception
     when others then
        return false;
end;


function f_getCursorCab(pmcc varchar2)return sys_refcursor is
    vcur_cab      sys_refcursor;
begin
    open vcur_cab for  select cod_cab
                         from mcc_cab_mc c
                        where c.cod_mcc = pmcc;
    return vcur_cab;
end;


procedure p_Insert_CtlProcMc(pIDProc number, pIdAdq varchar2,pEstado char,pNumSec number, pfecha date) is

    Begin

    insert  into ctl_procmc(id_funcion, nom_proceso, id_entadq, estado ,sec_outgoing,FH_SESION)
--                     values(pidproc,    'POUTMC',    pidadq,    pestado,pNumSec ,trunc(sysdate) );
                     values(pidproc,'POUTMC',pidadq,pestado,pNumSec,pfecha);


    Commit;

End;


--function f_getSecuencia(pbanco char, pNomProc char,pRepro char:='N',pfecha date) return pls_integer  is
function f_getSecuencia(pfecha date) return pls_integer  is
/** modificado el 15/05 por FFI */
    vsecuence   pls_integer := 1;

    begin

--    if pRepro = 'N' then
          select  nvl(max(sec_outgoing),0) + 1
          into  vsecuence
          from  ctl_procmc
         where  nom_proceso  = 'PBUILDINC'
           and  fh_sesion    = pfecha;
           --and  estado       = 'F' ;
/*   elsif pRepro = 'S' then
          select nvl(max(sec_outgoing),0) -- decode(nvl(max(sec_outgoing),0),0,1,nvl(max(sec_outgoing),0))
            into  vsecuence
            from  ctl_procmc
           where  id_entadq   = pBanco
             and  nom_proceso = pNomProc
             and  fh_sesion   = pfecha;
   end if;*/

   return   vsecuence;

end;

FUNCTION f_QUITA_20(pDato CHAR) RETURN CHAR IS
    lvLen PLS_INTEGER;
    vDato VARCHAR2(256);
BEGIN
    vDato := pDato;
    lvLen := Length( vDato )/2;
    FOR i IN 1..lvLen LOOP
        IF SUBSTR( vDato , (lvLen * 2 - (2*i) + 1 ) , 2 ) = '20' THEN
            vDato := substr( vDato , 1 , lvLen * 2 - 2*i + 1 - 1 )||'  '||substr( vDato , (lvLen * 2 - 2*i + 1 + 2 ) );
        ELSE
            RETURN  vDato;
        END IF;
    END LOOP;
    RETURN vDato;
END;



end;
/