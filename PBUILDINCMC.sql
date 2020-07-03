CREATE OR REPLACE PACKAGE SGCVNZ.PBUILDINCMC IS
/***************************************************************************************************
************   Proyecto : Procesadora Venezuela   **************************************************
************   Proposito: Build Incoming Maestro (Mc y Ngta)  Mercantil y Provicial ****************
 Historial
 =========
 Persona                  Fecha           Comentarios
 --------------------   --------------     ------------
 Francisco Vásquez.     01/Julio/2020     Inicio de Constructor de Entrantes Maestro (MC y NGTA)

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
     (idemen_p00_actc    varchar2 (4)    :='',     -- indicador de tipo de mensaje
      bitpri_actc        varchar2(16)    :='',     -- Primer Mapa De Bits
      bitsec_actc        varchar2(16)    :='',     -- Segundo Mapa De Bits
      lontar_l02_actc    varchar2(19)    :='',     -- PAN o Numero de Tarjeta Longitud
      numtar_p02_actc    varchar2(19)    :='',     -- PAN o Numero de Tarj
      bin_tarjeta        varchar2(6)     :='',
      codpro_p03_actc    varchar2(6)     :='',     -- Codigo de procesamiento
      imptra_p04_actc    varchar2(12)    :='',     -- Monto de transaccion
      timloc_p12_actc    varchar2(12)    :='',     -- fecha y hora de la transaccion
      feccad_p14_actc    varchar2(4)     :='',     -- Fecha de Expiracion
      punser_p22_actc    varchar2(12)    :='',     -- Codigo del Punto de servicio
      codfun_p24_actc    varchar2(3)     :='',     -- Codigo de funcion
      numsec_p23_actc    varchar2(3)     :='',     -- Numero de secuencia de tarjeta
      codraz_p25_actc    varchar2(4)     :='',     -- Codigo de Razon
      codact_p26_actc    varchar2(4)     :='', --pls_integer     :=0,      -- Codigo de Negocio del establecimiento
      de_30              varchar2(24)    :='',     -- Monto original
        de_30s1          varchar2(12)    :='',     -- Monto original de la transaccion
        de_30s2          varchar2(12)    :='',     -- Monto original de la conciliacion
      refadq_p31_actc    varchar2(25)    :='',     -- Datos referentes al adquiriente
      londat_de32        varchar2(2)     :='',
      de_32              varchar2(6)     :='',
      londat_de33        varchar2(2)     :='',
      de_33              varchar2(6)     :='',
      datref_p37_actc    varchar2(12)    :='',     -- Numero de referencia de la peticion
      numaut_p38_actc    varchar2(6)     :='',     -- Codigo de autorizacion
      codser_p40_actc    varchar2(3)     :='',
      ideter_p41_actc    varchar2(8)     :='',     -- Identificacion del terminal
      ideest_p42_actc    varchar2(15)    :='',     -- codigo de comercio
      nomest_p43_actc    varchar2(83)    :='',     -- nombre del comercio
      dircomercio_p43    varchar2(83)    :='',     -- direccion del comercio
      locest_p43_actc    varchar2(83)    :='',     -- Localidad del comercio
        longdat_p43      char(2)         :='',
      cod_postal         varchar(10)     :='',     -- codigo postal
      cod_estado         varchar(3)      :='',     -- codigo de estado
      paiest_p43_actc    varchar2(3)     :='',     -- pais del comercio
      londat_P48         varchar(3)      :='',     -- Longitud del p48
      De48               varchar2(121)   :='',     -- longitud de dato, dato adicional
         pds0002_de48    varchar2(10)     :='',
         pds0003_de48    varchar2(10)     :='',
         pds0148_de48    varchar2(21)    :='',
         pds0149_de48    varchar2(13)    :='',
         pds0158_de48    varchar2(19)    :='',
         pds0165_de48    varchar2(38)    :='',
         pds0262_Ide48   varchar2(1)     :='',
         pds0262_de48    varchar2(8)     :='',
      montra_p49_actc    varchar2(3)     :='',     -- Codigo de la moneda de la transaccion
      moncon_p50_actc    varchar2(3)     :='',     -- codigo moneda de conciliacion
      londat_p55         varchar2(3)     :='',     -- Longitud del p55
      De55               varchar2(256)   :='',     -- Composicion del De55
         t9f26_de55      varchar2(80)     :='',
         t9f27_de55      varchar2(80)     :='',
         t9f10_de55      varchar2(80)    :='',
         t9f37_de55      varchar2(80)     :='',
         t9f36_de55      varchar2(80)     :='',
         t95_de55        varchar2(80)     :='',
         t9a_de55        varchar2(80)     :='',
         t9c_de55        varchar2(80)     :='',
         t9f02_de55      varchar2(80)     :='',
         t5f2a_de55      varchar2(80)     :='',
         t82_de55        varchar2(80)     :='',
         t9f1a_de55      varchar2(80)     :='',
         t9f03_de55      varchar2(80)     :='',
      de_63              varchar2(19)    :='',     -- transaction life cicle
      nummen_p71_actc    varchar2(8)     :='',     -- numero de mensaje en el lote
      londat_de72        varchar(3)      :='',
      de_72              varchar(50)     :='',
      londat_de94        varchar(2)      :='',     -- longitud de dato DE94
      de_94              varchar2(11)    :='',     -- valor del campo: presen_p33_actc
      de_95              varchar2(12)    :='',     -- Datos referios al emisor de la tarjeta
      cod_ird            varchar2(2)     :='',     -- codigo de IRD
      cod_mcc            varchar2(4)     :='',     -- codigo MCC
      cod_tcc            char(1)         :='',     -- codigo TCC
      isnum_nacional     pls_integer     :=0,      -- Es tarjeta Nacional?
      isBetweenFiveday   boolean         :=false, -- la transaccion realizada, es enviada dentro de los 5 dias calendario?
      isBetweenThirtyday boolean         :=false,  -- la transaccion realizada, es enviada dentro de los 30 dias calendario
      cod_producto_gcms  varchar2(3)     :='',
      cod_licen_producto varchar2(3)     :='',
      cod_pais           varchar2(3)     :='',
      cod_region         varchar2(1)     :='',
      cod_programa       varchar2(3)     :='',
      ImpTran            varchar2(12)    :='',
      MonTran            varchar2(3)     :='',
      TransationID       varchar2(10)    :='',
      SourceAmount       varchar2(12)    :='',
      currenCode         varchar2(3)     :='',
      FecPresentacion    varchar2(6)     :='');

 TYPE Msg_1240A IS RECORD  -- Anulaciones
     (MTI                     varchar2 (4)    :='',     -- indicador de tipo de mensaje
      bitpri_actc             varchar2(16)    :='',     -- Primer Mapa De Bits
      bitsec_actc             varchar2(16)    :='',     -- Segundo Mapa De Bits
      lontar_l02_actc         varchar2(19)    :='',     -- PAN o Numero de Tarjeta Longitud
      numtar_p02_actc         varchar2(19)    :='',     -- PAN o Numero de Tarj
      bin_tarjeta             varchar2(6)     :='',
      codpro_p03_actc         varchar2(6)     :='',     -- Codigo de procesamiento
      imptra_p04_actc         varchar2(12)    :='',     -- Monto de transaccion
      timloc_p12_actc         varchar2(12)    :='',     -- fecha y hora de la transaccion
      feccad_p14_actc         varchar2(4)     :='',     -- Fecha de Expiracion
      punser_p22_actc         varchar2(12)    :='',     -- Codigo del Punto de servicio
      numsec_p23_actc         varchar2(3)     :='',
      codfun_p24_actc         varchar2(3)     :='',     -- Codigo de funcion
      codraz_p25_actc         varchar2(4)     :='',     -- Codigo de Razon
      codact_p26_actc         varchar2(4)     :='',  --pls_integer     :=0,      -- Codigo de Negocio del establecimiento
      de_30                   varchar2(24)    :='',     -- Monto original de transacion
      refadq_p31_actc         varchar2(25)    :='',     -- Datos referentes al adquiriente
      londat_de32             varchar2(2)     :='',
      de_32                   varchar2(6)     :='',
      londat_de33             varchar2(2)     :='',
      de_33                   varchar2(6)     :='',
      datref_p37_actc         varchar2(12)    :='',     -- Numero de referencia de la peticion
      numaut_p38_actc         varchar2(6)     :='',     -- Codigo de autorizacion
      codser_p40_actc         varchar2(3)     :='',
      ideter_p41_actc         varchar2(8)     :='',     -- Identificacion del terminal
      ideest_p42_actc         varchar2(15)    :='',     -- codigo de comercio
      nomest_p43_actc         varchar2(83)    :='',     -- nombre del comercio
      dircomercio_p43         varchar2(83)    :='',     -- direccion del comercio
      locest_p43_actc         varchar2(83)    :='',     -- Localidad del comercio
      longdat_p43           char(2)         :='',
      cod_postal              varchar(10)     :='',     -- codigo postal
      cod_estado              varchar(3)      :='',     -- codigo de estado
      paiest_p43_actc         varchar2(3)     :='',     -- pais del comercio
      londat_P48              varchar(3)      :='',     -- Longitud del p48
      De48                    varchar2(135)   :='',     -- longitud de dato, dato adicional
     pds0002_de48         varchar2(10)     :='',
     pds0003_de48         varchar2(10)     :='',
     pds0025_de48         varchar2(14)    :='',     -- Indicador de anulacion de mensaje
     pds0148_de48         varchar2(21)    :='',
     pds0149_de48         varchar2(13)    :='',
     pds0158_de48         varchar2(19)    :='',
     pds0165_de48         varchar2(38)    :='',
     pds0262_de48         varchar2(8)     :='',
     montra_p49_actc         varchar2(3)     :='',     -- Codigo de la moneda de la transaccion
     moncon_p50_actc         varchar2(3)     :='',     -- codigo moneda de conciliacion
     londat_p55              varchar2(3)     :='',     -- Longitud del p55
     De55                    varchar2(256)   :='',     -- Composicion del De55
     t9f26_de55           varchar2(80)     :='',
     t9f27_de55           varchar2(80)     :='',
     t9f10_de55           varchar2(80)    :='',
     t9f37_de55           varchar2(80)     :='',
     t9f36_de55           varchar2(80)     :='',
     t95_de55             varchar2(80)     :='',
     t9a_de55             varchar2(80)     :='',
     t9c_de55             varchar2(80)     :='',
     t9f02_de55           varchar2(80)     :='',
     t5f2a_de55           varchar2(80)     :='',
     t82_de55             varchar2(80)     :='',
     t9f1a_de55           varchar2(80)     :='',
     t9f03_de55           varchar2(80)     :='',
     de_63                   varchar2(19)    :='',     -- transaction life cicle
      nummen_p71_actc         varchar2(8)     :='',     -- numero de mensaje en el lote
      londat_de94             varchar(2)      :='',     -- longitud de dato DE94
      de_94                   varchar2(11)    :='',     -- valor del campo: presen_p33_actc
      de_95                   varchar2(10)    :='',     -- Datos referios al emisor de la tarjeta
      cod_ird                 varchar2(2)     :='',     -- codigo de IRD
      cod_mcc                 varchar2(4)     :='',     -- codigo MCC
      cod_tcc                 char(1)         :='',     -- codigo TCC
      isnum_nacional          pls_integer     :=0,      -- Es tarjeta Nacional?
      isBetweenFiveday        boolean         :=false,  -- la transaccion realizada, es enviada dentro de los 5 dias calendario?
      isBetweenThirtyday      boolean         :=false,  -- la transaccion realizada, es enviada dentro de los 30 dias calendario
      cod_producto_gcms       varchar2(3)     :='',
      cod_licen_producto      varchar2(3)     :='',
      cod_pais                varchar2(3)     :='',
      cod_region              varchar2(1)     :='',
      cod_programa            varchar2(3)     :='',
      tipo_cambio             number(8,3)     :='',
      FecPresentacion         varchar2(6)     :='',   --tipo de cambio del dia para mastercard
     --- Inicio Mod. 28/01/2020 - Error 0122
      TransationID       varchar2(10)       :='',
      SourceAmount       varchar2(12)    :='',
      currenCode         varchar2(3)        :='',
      pds0262_Ide48   varchar2(1)         :='');
      --- Fin Mod. 28/01/2020 - Error 0122

TYPE r_Mtotot_1240 IS RECORD  --Record para calculo de Sumas de 1240's
     (MontoTotal     pls_integer:=0,
      TotalMensaje   pls_integer:=0
   );

 TYPE Msg1644Adendum IS RECORD -- mensajes administrativos
     (mti                varchar2(4)    :='',   -- indicador de tipo de mensaje
      de1_bitpri         varchar2(16)   :='',   -- Primer Mapa De Bits
      de1_bitSec         varchar2(16)   :='',   -- Segundo Mapa De Bits
      de24               varchar2(3)    :='',   -- Codigo de funcion
      de33_londat        varchar2(2)    :='',   -- longitud de de33
      de33_codPresen     varchar2(6)    :='',   -- Codigo de Razon
      de48_londat        varchar2(3)    :='',   -- longitud de de_48
      de_48              varchar2(72)   :='',   -- datos adicionales
        pds501_48        varchar2(23)   :='',   -- descripcion de la transaccion
        s1501_48         varchar2(2)    :='',   -- codigo de uso
        s2501_48         varchar2(3)    :='',   -- nro reg. de la industria
        s3501_48         varchar2(3)    :='',   -- indicador de ocrrencia
        s4501_48         varchar2(8)    :='',   -- nro asociado a la 1ra presentacion
        pds506_48        varchar2(28)   :='',   -- Aceptador de la tarjeta cobra los impuestos
        s1506_48         varchar2(20)   :='',   -- Id del aceptador de la tarjeta
        s2506_48         varchar2(1)    :='',   -- Codigo proveido por ID aceptador de la tarjeta
        pds507_48        varchar2(21)   :='',   -- Monto total del impuesto
        s1507_48         varchar2(12)   :='',   -- Monto total del impuesto
        s2507_48         varchar2(1)    :='',   -- Exponente total del impuesto
        s3507_48         varchar2(1)    :='',   -- Signo del impuesto total
      de_71              varchar2(8)    :='',   -- nro del mensaje
      de94_londat        varchar2(2)    :='',   -- longitud de_94
      de_94              varchar2(11)   :='');  -- ID institucion origen de la transaccion


 TYPE Msg_1644 IS RECORD -- mensajes administrativos
     (idemen_p00_actc    varchar2(4)    :='',   --indicador de tipo de mensaje
      bitpri_actc        varchar2(16)   :='',   -- Primer Mapa De Bits
      bitsec_actc        varchar2(16)   :='',   -- Segundo Mapa De Bits
      codfun_p24_actc    varchar2(3)    :='',   -- Codigo de funcion
      codraz_p25_actc    varchar2(4)    :='',   -- Codigo de Razon
      codact_p26_actc    varchar2(4)    :='',   -- Codigo de Negocio del establecimiento
      impori_p30_actc    varchar2(24)   :='',   -- Monto original de transacion
      refadq_p31_actc    varchar2(23)   :='',   -- Datos referentes al adquiriente
      londat_p48_actc    varchar2(3)    :='',   -- longitud de dato, dato adicional
      de_p48             varchar2(71)   :='',
        pds0105_p48      varchar2(32)   :='',
        pds0122_p48      varchar2(8)    :='',
        pds0301_p48      varchar2(23)   :='',
        pds0306_p48      varchar2(15)   :='',
      nummen_p71_actc    varchar2(8)    :='',   -- numero de mensaje en el lote
      delement94_actc    varchar2(11)   :='',   -- valor del campo: presen_p33_actc
      numemi_p95_actc    varchar2(10)   :=''    -- Datos referios al emisor de la tarjeta
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

FUNCTION f_main(psfecha VARCHAR2, pcodhcierre CHAR:='1', pRepro CHAR:='N') RETURN VARCHAR2;

PROCEDURE p_mainGen_entrante(pFecha CHAR  ,pcod_entadq CHAR ,pIdProc NUMBER ,pDirOut CHAR ,pmarca NUMBER ,pfile OUT VARCHAR);

PROCEDURE p_GenReg1644(vcodfuncion NUMBER,vfecha VARCHAR2, vbanco VARCHAR2);
PROCEDURE p_GenRegCompra(pfecha VARCHAR2, pbanco VARCHAR2, pcodhcierre CHAR);
PROCEDURE p_GenReversionCompra(pfecha  VARCHAR2,pbanco VARCHAR2, pcodhcierre CHAR);

PROCEDURE p_GenRegAnulacion(pfecha  VARCHAR2,pbanco VARCHAR2, pcodhcierre CHAR);

PROCEDURE p_GenReg1740(pfecha  VARCHAR2,pbanco VARCHAR2, pcodhcierre CHAR);

PROCEDURE p_GenReg1644Adendum(vbanco VARCHAR2);

procedure p_FindPostalCode(pComercio varchar2, codePostal out varchar2, codEstado out varchar2);

function f_IniMapaBits return mapa_bits;

function f_IniArrayLuhn return ArrayLuhn;

function f_Bin_Hex(bin varchar2) return char;

function f_Gen_MapaHex2(matrizBin in out Mapa_Bits) return varchar;

function f_ini_msg1240C return Msg_1240C;

function f_ini_msg1240A return Msg_1240A;

function f_ini_msg1740 return Msg_1740;
--procedure p_Obtiene_IRD (Cod_Producto_GCMS varchar2,cod_region varchar2,punser_p22_actc_c varchar2,punser_p22_actc_vt1240 varchar2,vcodser varchar2,
--                        isBetweenFiveday boolean,isBetweenThirtyDay boolean,isFecha varchar2,pcod_programa varchar2,pds0158_de48 out varchar2, mb40 out varchar2  ) ;
function f_ini_Msg1644Adendum return Msg1644Adendum;

function f_iniCardAceptorBusiness return vb_CardAceptorBusiness;

function f_FindCodigoRazon(pCodRazon number, pNumTarjeta varchar2 )return varchar2;

function f_AtLeastOne(pfecha varchar2,pbanco varchar2,marca number)return pls_integer;

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

procedure p_GenReg1644_noMov(vcodfuncion number,vfecha varchar2,vbanco varchar2);

procedure p_Insert_CtlProcMc(pIDProc number, pIdAdq varchar2, pEstado char,pNumSec number,pfecha date);

--function f_getSecuencia(pbanco char, pNomProc char,pRepro char:='N',pfecha date) return pls_integer;
function f_getSecuencia(pfecha date) return pls_integer;

FUNCTION f_QUITA_20(pDato CHAR) RETURN CHAR;

  function f_FindTarjetaNacional(pIdProc pls_integer, bin_tarjeta varchar2,pBanco char )return pls_integer;

  procedure p_getDataInternacional(pIdProc pls_integer, bin_tarjeta varchar2,pBanco char,pgcms out varchar2,plic_prod out varchar2,pcod_pais out varchar2, pcod_reg out varchar2,pcod_programa out varchar2);


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



--FUNCTION f_main(psfecha DATE, pcodhcierre CHAR:='1', pRepro CHAR:='N') RETURN VARCHAR2 IS
FUNCTION f_main(psfecha DATE, pcod_entadq VARCHAR2, Marca VARCHAR2) RETURN VARCHAR2 IS

 vDirOUT          VARCHAR2(100)   :='DIR-OUT';
 vfechac6         VARCHAR2(6)     :='';
 dfecha           DATE;
 vArchivo         VARCHAR2(50)    :='';
 vRetorno         VARCHAR2(100)   :='';
 vMarca           NUMBER(4);

BEGIN

  --vFechac6    := SUBSTR(psFecha,3,6);
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
  IF vEntorno='CCAL' THEN vTiPOimc:='470'; END IF;
  --IF vEntorno='DESA' THEN vTipFileMC:='T'; END IF;

  /*IF pcodhcierre = '1' then
      dFecha := dFecha;
   ELSIF pcodhcierre = '2' then
      dFecha := dFecha + 1;
   END IF;*/

   IF Marca = 'MC' then
      vMarca := 8010;
   ELSIF Marca = 'NGTA' then
      vMarca := 9010;
   END IF;

  -- Exrae datos de la tabla MCP_[BP/BM]
   /*OPEN CurTMP FOR

   SELECT /*+ INDEX(mcp idxp_mcp_bm_adqp28hc) 
   'C000',id_mov, cod_entadq, csb_entadq, cod_hrcierre, p00idmsg, 
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
   WHERE  cod_entadq = pcod_entadq
   AND p28sesion = TO_CHAR(dFecha-1,'YYYYMMDD')
   AND p48tiptra LIKE '10%'
   AND p71nummen LIKE 'vmarca%'; */

   
  -- Proceso para Banco Mercantil
  p_mainGen_entrante(psFecha,pcod_entadq,vIDProc,vDirOUT,vMarca,vArchivo);
  IF LENGTH(TRIM(vArchivo)) > 0 THEN
     vRetorno := vArchivo;
  END IF;

  -- Reiniciando Variables
  --vNumSecReg    :=0; 
  --vMontoTotal   :=0;
  --vtotalMensaje :=0;

  -- Proceso para Banco Provincial
  --p_mainGen_byBank(psFecha,vFechac6,'BP',vIDProc,vDirOUT,pRepro,pcodhcierre,dfecha,vArchivo);
  --IF LENGTH(TRIM(vArchivo)) > 0 THEN
  --   vRetorno := vRetorno||vArchivo;
  --END IF;

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

PROCEDURE p_mainGen_entrante(pFecha CHAR,  pBankChar CHAR, pIdProc   NUMBER, pDirOut   CHAR,  pmarca NUMBER, pfile OUT VARCHAR) IS

 vbank6 CHAR(6):= '';

 BEGIN

   IF pBankChar = 'BM' THEN
       --vBank4      := '0105';
       --vbank6      := '540105';
       vCantRegMer := f_AtLeastOne(pFecha,pBankChar,pmarca);
   END IF;

   IF pBankChar = 'BP' THEN
      --vBank4      := '0108';
      --vbank6      := '540108';
      vCantRegpro := f_AtLeastOne(pFecha,pBankChar,pmarca);
   END IF;

   --get_secuence
--   vSecControl  := f_getSecuencia(vBank4,'POUTMC',pRepro,pfechad);
   vSecControl  := f_getSecuencia(pfecha);

   --inserta inicio de proceso
   p_Insert_CtlProcMc(pIdProc, vBank4,'I',vSecControl,pfecha);

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

   --*********************************GEN FILE BANCO MERCANTIL**********************************

   IF vCantRegMer > 0 AND pBankChar = 'BM' AND  pmarca = '8010' THEN
         --generando File
         vFile   := '';
   --      vFile   := 'TT'||470||TO_CHAR(pfechad,'YYYYMMDD')||lpad(to_char(vSecControl),2,0)||'.DAT';
         vFile   := 'TT'||470||TO_CHAR(pfechad,'YYYYMMDD')||lpad(to_char(vSecControl),2,0)||'.DAT';
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de Outgoing MasterCard BM');
         p_genReg1644(697,TO_CHAR(pfechad,'YYMMDD'),pBankChar);  --pFecha6
         /*p_GenRegCompra(pFecha6,vbank4,pcodhcierre);    --p_GenRegCompra(pFecha6,vbank6)
         p_GenRegAnulacion(pFecha6,vbank4,pcodhcierre); --p_GenRegAnulacion(pFecha6,vbank6)
         p_GenReg1740(pFecha6,vbank4,pcodhcierre);      --p_GenReg1740(pFecha6,vbank6);
         p_genReg1644(695,TO_CHAR(pfechad,'YYMMDD'),pBankChar); --pFecha6*/
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
   ELSE IF vCantRegMer > 0 AND pBankChar = 'BM' AND  pmarca = '9010' THEN
            --generando File
         vFile   := '';
   --      vFile   := 'OUTMC'||vBank4||pfecha||lpad(to_char(vSecControl),2,0)||'.DAT';
         vFile   := 'TT'||vTiPOimc||TO_CHAR(pfechad,'YYYYMMDD')||lpad(to_char(vSecControl),2,0)||'.DAT';
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;


         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de Outgoing MasterCard BM');
         p_genReg1644(697,TO_CHAR(pfechad,'YYMMDD'),pBankChar);  --pFecha6
         /*p_GenRegCompra(pFecha6,vbank4,pcodhcierre);    --p_GenRegCompra(pFecha6,vbank6)
         p_GenRegAnulacion(pFecha6,vbank4,pcodhcierre); --p_GenRegAnulacion(pFecha6,vbank6)
         p_GenReg1740(pFecha6,vbank4,pcodhcierre);      --p_GenReg1740(pFecha6,vbank6);
         p_genReg1644(695,TO_CHAR(pfechad,'YYMMDD'),pBankChar); --pFecha6*/
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
   END IF;

    --*********************************GEN FILE BANCO PROVINCIAL**********************************

   IF vCantRegPro > 0 AND pBankChar = 'BP' AND  pmarca = '8010' THEN
         --generando File
         vFile   := '';
   --      vFile   := 'OUTMC'||vBank4||pfecha||lpad(to_char(vSecControl),2,0)||'.DAT';
         vFile   := 'TT'||vTiPOimc||TO_CHAR(pfechad,'YYYYMMDD')||lpad(to_char(vSecControl),2,0)||'.DAT';
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de Outgoing MasterCard BP');

         p_genReg1644(697,TO_CHAR(pfechad,'YYMMDD'),pBankChar);
         /*p_GenRegCompra(pFecha6,vbank4,pcodhcierre);
         p_GenRegAnulacion(pFecha6,vbank4,pcodhcierre);
         p_GenReg1740(pFecha6,vbank4,pcodhcierre);
         p_genReg1644(695,TO_CHAR(pfechad,'YYMMDD'),pBankChar);*/
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pfechad); --pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
   ELSE IF vCantRegPro > 0 AND pBankChar = 'BP' AND  pmarca = '9010' THEN
               --generando File
         vFile   := '';
   --      vFile   := 'OUTMC'||vBank4||pfecha||lpad(to_char(vSecControl),2,0)||'.DAT';
         vFile   := 'TT'||vTiPOimc||TO_CHAR(pfechad,'YYYYMMDD')||lpad(to_char(vSecControl),2,0)||'.DAT';
         pfile   := vfile;

         --validacion si archivo esta abierto
         vIDFile := utl_file.fopen(pDirOut,vFile,'w',32767);
         IF NOT utl_file.is_open(vIDFile) THEN
            verrmsg := 'Al abrir <'||pDirOut||'/'||vFile||'>';
            verrcod := '99';
            RAISE efinerror;
         END IF;

         --inicia proceso de outgoing
         vPaso   := 'Paso 02';
         pqmonproc.inslog(pIdProc, 'M', 'inicia Proceso de Outgoing MasterCard BP');

         p_genReg1644(697,TO_CHAR(pfechad,'YYMMDD'),pBankChar);
         /*p_GenRegCompra(pFecha6,vbank4,pcodhcierre);
         p_GenRegAnulacion(pFecha6,vbank4,pcodhcierre);
         p_GenReg1740(pFecha6,vbank4,pcodhcierre);
         p_genReg1644(695,TO_CHAR(pfechad,'YYMMDD'),pBankChar);*/
         utl_file.fCLOSE(vIDFile);

         pqmonproc.inslog(vidproc, 'M', 'fin ok | archivo: '||pDirOut||'/'||vFile);
         p_Insert_CtlProcMc(pIdProc, vBank4,'F',vSecControl,pfechad); --pfechad);
         vretc :=pqmonproc.updmonproc (pIdProc, 'F');
   END IF;

END;


PROCEDURE p_GenRegCompra(pfecha VARCHAR2, pbanco VARCHAR2,pcodhcierre CHAR) IS
 strhexa1240C       VARCHAR2(32)   := '';
 vcodpostal         VARCHAR2(10)   := '';
 vcodestado         VARCHAR2(3)    := '';
 long_p48           NUMBER         := 0;
 vbanco             VARCHAR2(2)    := '';
 vt1240C            msg_1240C;
 vMsg1644Adendum    Msg1644Adendum;
 mb                 Mapa_Bits;
 vs                 s;
 vlong              VARCHAR2(128);
 vdato              VARCHAR2(1024);
 ncero              NUMBER := 0;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;

 videmen_p00_actc   clr_dcemvfull.idemen_p00_actc%TYPE;
 videtra_p11_actc   clr_dcemvfull.idetra_p11_actc%TYPE;
 vtimloc_p12_actc   clr_dcemvfull.timloc_p12_actc%TYPE;
 videadq_p32_actc   clr_dcemvfull.ideadq_p32_actc%TYPE;
 vemvtvr_p55_actc   clr_dcemvfull.emvtvr_p55_actc%TYPE;
 vperint_p55_actc   clr_dcemvfull.perint_p55_actc%TYPE;
 vnumale_p55_actc   clr_dcemvfull.numale_p55_actc%TYPE;
 vcapter_p55_actc   clr_dcemvfull.capter_p55_actc%TYPE;
 vscremi_p55_actc   clr_dcemvfull.scremi_p55_actc%TYPE;
 vnumsec_p23_actc   clr_dcemvfull.numsec_p23_actc%TYPE;
 vdaplem_p55_actc   clr_dcemvfull.daplem_p55_actc%TYPE;
 vttcrip_p55_actc   clr_dcemvfull.ttcrip_p55_actc%TYPE;
 vemvatc_p55_actc   clr_dcemvfull.emvatc_p55_actc%TYPE;
 vcrippe_p55_actc   clr_dcemvfull.crippe_p55_actc%TYPE;
 vpaicri_p55_actc   clr_dcemvfull.paicri_p55_actc%TYPE;
 vfeccri_p55_actc   clr_dcemvfull.feccri_p55_actc%TYPE;
 vimpcri_p55_actc   clr_dcemvfull.impcri_p55_actc%TYPE;
 vinfcri_p55_actc   clr_dcemvfull.infcri_p55_actc%TYPE;
 vmoncri_p55_actc   clr_dcemvfull.moncri_p55_actc%TYPE;
 vimccri_p55_actc   clr_dcemvfull.imccri_p55_actc%TYPE;

 CURSOR cr_compra IS
   SELECT idemen_p00_actc,   lontar_l02_actc,   numtar_p02_actc,
           codpro_p03_actc,  imptra_p04_actc,   idetra_p11_actc,
           timloc_p12_actc,  DECODE(feccad_p14_actc,'0000','',feccad_p14_actc) feccad_p14_actc,
           punser_p22_actc,  codfun_p24_actc,   codraz_p25_actc,
           codact_p26_actc,   lpad(nvl(impori_p30_actc,0),12,0) impori_p30_actc,
           lonref_l31_actc,  refadq_p31_actc,   ideadq_l32_actc,
           ideadq_p32_actc,  idepre_l33_actc,   idepre_p33_actc, pista2_p35_actc,
           datref_p37_actc,  numaut_p38_actc,   ideter_p41_actc,
           ideest_p42_actc,  nomest_p43_actc,    locest_p43_actc,
           decode(paiest_p43_actc,'VE','VEN','VEN')paiest_p43_actc,
           londat_p48_actc,  montra_p49_actc,   moncon_p50_actc,SUBSTR(FILLER_P62_ACTC,1,15) CYCLID_P63_ACTC,
           nummen_p71_actc,  numemi_l95_actc,   numemi_p95_actc,
           sesion_p28_actc,  filler_p48_actc,   oritim_p56_actc, codser_p40_actc          
          ,SGCVNZ.FN_GETPARTICION(TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD'),'YYYY'))||SUBSTR(sesion_p28_actc,3,2)||TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD'),'DAY','NLS_DATE_LANGUAGE=''numeric date language''') as idparticion
          ,TO_NUMBER(TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD'),'MM')) id_mes
           -- Se obtiene la siguiente partición para solventar la incidencia de Data Integrity - Edit 1 - JLE - 30/10/2018
           ,SGCVNZ.FN_GETPARTICION(TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD'),'YYYY'))||(TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD') + 1,'MM') )||TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD') + 1,'DAY','NLS_DATE_LANGUAGE=''numeric date language''')  as idparticion_sig
           ,TO_NUMBER(TO_CHAR(TO_DATE(sesion_p28_actc,'YYMMDD') + 1,'MM') ) id_mes_sig 
     FROM  clr_ex8010
    WHERE sesion_p28_actc = pfecha
      AND SUBSTR(ideadq_p32_actc,3,4) = pbanco
      AND idemen_p00_actc = '1240'
      AND substr(tiptra_p48_actc,1,2) = '06'
--      AND refadq_p31_actc <> '75180024209544284574399'
      AND cod_hrcierre = pcodhcierre;

 BEGIN

   --inicia Generacion de Compra
   vPaso   := 'Paso 03';
   IF pbanco = '0105' THEN vbanco :='BM'; END IF;
   IF pbanco = '0108' THEN vbanco :='BP'; END IF;

   FOR c IN cr_compra LOOP

      long_p48:=0;
      vt1240C     := f_ini_msg1240C;

      mb:= f_inimapabits;

      mb(1):='1';   vt1240C.idemen_p00_actc :=to_char(c.idemen_p00_actc);

      mb(2) :='1';  vt1240C.lontar_l02_actc := to_char(c.lontar_l02_actc);
                    vt1240C.numtar_p02_actc := c.numtar_p02_actc;

      mb(3) :='1';  vt1240C.codpro_p03_actc := lpad(c.codpro_p03_actc,6,0);

      mb(4) :='1';  vt1240C.isnum_nacional := f_FindTarjetaNacional(vIdProc, vt1240C.numtar_p02_actc,vbanco);
      IF c.codfun_p24_actc = '200' THEN
         IF vt1240C.isnum_nacional > 0 THEN
            vt1240C.imptra_p04_actc := to_char(lpad(c.imptra_p04_actc,12,0));
         ELSE
            vt1240C.imptra_p04_actc := lpad(to_char(round(((c.imptra_p04_actc/100) / vTipocambio),2)*100),12,0);
         END IF;
      END IF;

      IF c.codfun_p24_actc  != '200' THEN
         p_findTransactionIdDisputas(c.refadq_p31_actc, c.numtar_p02_actc,vt1240C.TransationID,vt1240C.SourceAmount,vt1240C.currenCode,vt1240C.pds0262_Ide48);
         vt1240C.imptra_p04_actc  := vt1240C.SourceAmount;
      END IF;

      vMontoTotal   :=vMontoTotal + to_number(nvl(vt1240C.imptra_p04_actc,0));
      vtotalMensaje :=vtotalMensaje + 1;

      mb(12):='1';  vt1240C.timloc_p12_actc := c.timloc_p12_actc;

      IF c.feccad_p14_actc IS NOT NULL THEN
         mb(14):='1';
         vt1240C.feccad_p14_actc  := c.feccad_p14_actc;
      END IF;

      mb(22):='1';
/*   IF c.punser_p22_actc IS NULL THEN
         vt1240C.punser_p22_actc := '000000000000';
    ELSE
         vs.s1  := substr(c.punser_p22_actc,1,1);
         IF vs.s1 <>'5' THEN  vs.s1:= substr(c.punser_p22_actc,1,1);
    ELSE
         IF substr(c.punser_p22_actc,4,1) ='M' THEN  vs.s1:= 'D' ; Else vs.s1 := 'C';
         END IF; END IF; */

     /* NUEVO CAMBIO */
     IF c.punser_p22_actc IS NULL THEN
        vt1240C.punser_p22_actc := '000000000000';
     ELSE
         IF substr(c.punser_p22_actc,4,1) = 'M' THEN  vs.s1 := 'D' ;
         ELSE
            IF  substr(c.punser_p22_actc,7,1) ='5' THEN vs.s1 := 'D';
            ELSE
                 IF  substr(c.punser_p22_actc,7,1) IN ('2','6','S') THEN vs.s1 := 'C';
                 ELSE
                    vs.s1 := 'D';
                 END IF;
            END IF;
         END IF;

         vs.s2  := substr(c.punser_p22_actc,2,1);
         vs.s3  := substr(c.punser_p22_actc,3,1);
         vs.s4  := substr(c.punser_p22_actc,4,1);
         IF  vs.s4 ='M' THEN -- realizado por Carlos Brito para: valida campo 22 subcampo 4, M es igual a mPOs y se modifica para que mande el valor 1 fecha 05/05/2017
              vs.s4:='1' ;
         END IF;
         vs.s6  := substr(c.punser_p22_actc,6,1);
         vs.s10 := substr(c.punser_p22_actc,10,1);
         vs.s11 := substr(c.punser_p22_actc,11,1);
         vs.s12 := substr(c.punser_p22_actc,12,1);

         vs.s5 := substr(c.punser_p22_actc,5,1);
         IF vs.s5 = '2' THEN vs.s5 := '3'; END IF;
         IF vs.s5 = '3' THEN vs.s5 := '4'; END IF;
         IF vs.s5 = '7' OR   vs.s5  = '8' THEN vs.s5 := '5'; END IF;

         vs.s7 := substr(c.punser_p22_actc,7,1);
         IF vs.s7 = '5' THEN vs.s7 := 'C'; END IF;
         IF vs.s7 = '6' THEN vs.s7 := '1'; END IF; --JLE - 19/09/2018 - Data Integrety - Tx Entrada Manual del PAN
         --IF vs.s7 = 'S' OR   vs.s7  = 'T'  THEN  vs.s7 := 'B'; END IF; --Se cambio la F por B , solicitado por AVV para las pruebas con chip en caso de fallback
         IF vs.s7 = 'S' OR   vs.s7  = 'T' OR vs.s7 = '2' THEN  vs.s7 := 'B'; END IF; --JLE - 19/09/2018 - Data Integrety - Tx Banda Magnética
         
         IF vs.s5 = '7' THEN vs.s7 := 'T'; END IF;
         IF vs.s5 = '8' THEN vs.s7 := 'S'; END IF;

         vs.s8 := substr(c.punser_p22_actc,8,1);
         IF vs.s8 = '8' THEN    vs.s8 := '6';     END IF;

         vs.s9  := substr(c.punser_p22_actc,9,1);
         IF vs.s8 = '0' AND vs.s9  = '0' THEN vs.s9 := '0'; END IF;
         IF vs.s8 = '1' AND vs.s9  = '1' THEN vs.s9 := '1'; END IF;
         IF vs.s8 = '1' AND vs.s9  = '3' THEN vs.s9 := '3'; END IF;
         IF vs.s8 = '5' AND vs.s9  = '4' THEN vs.s9 := '4'; END IF;

          --se concatena todas las cadenas
         vt1240C.punser_p22_actc := vs.s1||vs.s2||vs.s3||vs.s4||vs.s5||vs.s6||vs.s7||vs.s8||vs.s9||vs.s10||vs.s11||vs.s12;
      END IF;

      mb(24):='1';  vt1240C.codfun_p24_actc := c.codfun_p24_actc;
      IF c.codfun_p24_actc  = '200'  THEN
         IF c.codraz_p25_actc = '1377' AND c.impori_p30_actc = 0 THEN
            mb(25):='1';    vt1240C.codraz_p25_actc := '1401';
         ELSE
            mb(25):='1';    vt1240C.codraz_p25_actc := '1402';
         END IF;
      ELSE
         IF c.codfun_p24_actc != '200' THEN
            mb(25):='1';    vt1240C.codraz_p25_actc := f_FindCodigoRazon(c.codraz_p25_actc,c.numtar_p02_actc);
         END IF;
      END IF;

      mb(26):='1';    vt1240C.codact_p26_actc := lpad(c.codact_p26_actc,4,0);

      -- Solo para transacciones cuyo mcc = 7995(11/09/2009)
      IF vt1240C.codact_p26_actc IN ('4829','7995') THEN
         vt1240C.codpro_p03_actc := '180000';
      END IF;

      IF c.codfun_p24_actc != '200' THEN
         mb(30):='1';   vt1240C.de_30s1  := vt1240C.SourceAmount;
                        vt1240C.de_30s2  := '000000000000';
                        vt1240C.de_30    := vt1240C.de_30s1 || vt1240C.de_30s2;
      END IF;

      mb(31):='1';  vt1240C.refadq_p31_actc := to_char(lpad(c.lonref_l31_actc,2,0))||lpad(c.refadq_p31_actc,23,0);

      mb(32):='1';
      IF vbanco  = 'BM' THEN
         vt1240C.de_32       := '010375';
         vt1240C.londat_de32 := '06';
      ELSE
         vt1240C.de_32       := '010403';
         vt1240C.londat_de32 := '06';
      END IF;

      mb(33):='1';
      IF vbanco  = 'BM' THEN
         vt1240C.de_33        := '010375';
         vt1240C.londat_de33  := '06';
      ELSE
         vt1240C.de_33        := '010403';
         vt1240C.londat_de33  := '06';
      END IF;

      IF c.datref_p37_actc IS NOT NULL OR c.datref_p37_actc <> '0%' THEN
         mb(37):='1';   vt1240C.datref_p37_actc := rpad(c.datref_p37_actc,12,0);
      END IF;

    --mb(38):='1';  vt1240C.numaut_p38_actc  :=  rpad(c.numaut_p38_actc,6,0);
      mb(38):='1';  vt1240C.numaut_p38_actc  :=  RPAD(NVL(c.numaut_p38_actc,'0'),6,'0'); -- JMG 19/02/2011

      mb(41):='1';  vt1240C.ideter_p41_actc  :=  rpad(c.ideter_p41_actc,8,0);

      mb(42):='1';  vt1240C.ideest_p42_actc  :=  rpad(c.ideest_p42_actc,15,' ');

      mb(43):='1';  vt1240C.nomest_p43_actc  :=  rpad(substr(c.nomest_p43_actc,1,22),22,' ')||'\';
      vt1240C.dircomercio_p43  :=  '\';
      vt1240C.locest_p43_actc  :=  rpad(c.locest_p43_actc,13,' ')||'\';

      p_findPostalCode(c.ideest_p42_actc,vcodpostal,vcodestado);
      vcodpostal := pqutlcom.p_PostalCodexState(vcodestado); -- IPR 1080 CODIGO POSTAL POR ESTADO
      vt1240C.cod_postal       := rpad(vcodpostal,10,' ');
      vt1240C.cod_estado       := rpad(vcodestado,3,' ');
      vt1240C.paiest_p43_actc  := rpad(c.paiest_p43_actc,3,' ');
      vt1240C.longdat_p43      := lpad(length(vt1240C.nomest_p43_actc||
                                              vt1240C.dircomercio_p43||
                                              vt1240C.locest_p43_actc||
                                              vt1240C.cod_postal||
                                              vt1240C.cod_estado||
                                              vt1240C.paiest_p43_actc),2,0);

    VTIPO_TERM:=FN_TIPO_TERM_TRANS(vt1240C.ideter_p41_actc);

      mb(48):='1';
      IF vt1240C.isnum_nacional > 0 THEN
         vt1240C.pds0148_de48   := '0023003'||VTIPO_TERM||'0148004'||c.montra_p49_actc||'2';
      ELSE
         vt1240C.pds0148_de48   := '0023003'||VTIPO_TERM||'01480048402';
      END IF;

      IF c.codfun_p24_actc != '200'  THEN
         vt1240C.pds0149_de48   := '0149006'||vt1240C.currenCode||'000';
         vt1240C.pds0262_de48   := '0262001'||vt1240C.pds0262_Ide48;
      END IF;

      --PQOUTGOINGMC.p_findird(vIdProc, vt1240C.codact_p26_actc, vt1240C.cod_mcc, vt1240C.cod_ird, vt1240C.cod_tcc );

      IF vt1240C.isnum_nacional > 0 THEN   --Tarjetas Nacionales
         IF to_number(vt1240C.codact_p26_actc) = to_number(vt1240C.cod_mcc) THEN
            vt1240C.pds0158_de48 := '0158012MCC       '||lpad(to_char(vt1240C.cod_ird),2,'0');
         END IF;
      ELSE
         PQOUTGOINGMC.p_getDataInternacional(vIdProc, c.numtar_p02_actc,vbanco, vt1240C.Cod_Producto_GCMS, vt1240C.cod_licen_producto, vt1240C.cod_pais, vt1240C.cod_region, vt1240C.cod_programa);

         vt1240C.isBetweenFiveday := PQOUTGOINGMC.f_isBetweenFiveday(to_date(substr(c.timloc_p12_actc,1,6),'yymmdd'));

         vt1240C.isBetweenThirtyday := PQOUTGOINGMC.f_isBetweenThirtyday(to_date(substr(c.timloc_p12_actc,1,6),'yymmdd'));

         vcodser := LPAD(NVL(c.codser_p40_actc,'0'),3,'0');

         --para validar la fecha de la primera presentacion LMJ
         IF c.codfun_p24_actc = '205' THEN
            vt1240C.FecPresentacion := substr(c.oritim_p56_actc,1,6);
         else
            vt1240C.FecPresentacion := substr(c.timloc_p12_actc,1,6);
         END IF;

         if vt1240C.Cod_Producto_GCMS in ('DAG','DAP','DAS','DOS','SAG','SAP','SAS','SOS','WBE','MBP','MBT','MTP','MDJ','MRH','MDP','MET') then  --SE AGREGO LA 'MRH' PARA EL MDG GLOBAL 396 IPR 1112 FV-BSP 04/09/2013
            vt1240C.pds0002_de48 := '0002003' || vt1240C.Cod_Producto_GCMS ;
            vt1240C.pds0003_de48 := '0003003' || vt1240C.cod_licen_producto;
         else
            vt1240C.pds0002_de48 := '';
            vt1240C.pds0003_de48 := '';
         end if;

         --PQOUTGOINGMC.p_Obtiene_IRD(vt1240C.Cod_Producto_GCMS,vt1240C.cod_region,c.punser_p22_actc,vt1240C.punser_p22_actc,vcodser,vt1240C.isBetweenFiveday,vt1240C.isBetweenThirtyday,vt1240C.FecPresentacion,vt1240C.cod_programa,pds0158_de48,mb40);

         vt1240C.pds0158_de48 := pds0158_de48;

         IF mb40 = '1' THEN
            mb(40):= mb40;
            vt1240C.codser_p40_actc := vcodser;
         END IF;

      END IF;

      vt1240C.pds0165_de48 := '0165001M';
      vt1240C.De48         := vt1240C.pds0002_de48||  vt1240C.pds0003_de48||
                              vt1240C.pds0148_de48||  vt1240C.pds0149_de48||
                              vt1240C.pds0158_de48||  vt1240C.pds0165_de48||
                              vt1240C.pds0262_de48;

      vt1240C.londat_P48 := Lpad(length(vt1240C.De48),3,'0');

      IF SUBSTR(c.punser_p22_actc,7,1) = '5' THEN
         BEGIN
            BEGIN
                select /*+ NO_PARALLEL  INDEX (A,PK_CLR_DCEMVFULL)*/
                        emvtvr_p55_actc, perint_p55_actc, numale_p55_actc, capter_p55_actc,
                        scremi_p55_actc, numsec_p23_actc, daplem_p55_actc, ttcrip_p55_actc,
                        infcri_p55_actc, emvatc_p55_actc, crippe_p55_actc, paicri_p55_actc,
                        feccri_p55_actc, impcri_p55_actc, moncri_p55_actc, imccri_p55_actc
                into vemvtvr_p55_actc, vperint_p55_actc, vnumale_p55_actc, vcapter_p55_actc,
                        vscremi_p55_actc, vnumsec_p23_actc, vdaplem_p55_actc, vttcrip_p55_actc,
                        vinfcri_p55_actc, vemvatc_p55_actc, vcrippe_p55_actc, vpaicri_p55_actc,
                        vfeccri_p55_actc, vimpcri_p55_actc, vmoncri_p55_actc, vimccri_p55_actc
                from CLR_DCEMVFULL A
                --se agrega DECODE ya que el p00 que llega a la tabla DCEMVFULL se toma del MX
                where idemen_p00_actc = DECODE(c.idemen_p00_actc,1240,1244,1440,1444)
                    and idetra_p11_actc = c.idetra_p11_actc
                    and timloc_p12_actc = c.timloc_p12_actc
                    and ideadq_p32_actc = c.ideadq_p32_actc
                    and idparticion     = c.idparticion /* Implementacion del particionamiento TST 19/04/2014 */ 
                    and id_mes          = c.id_mes    /* Implementacion del particionamiento TST 19/04/2014 */;
        
            EXCEPTION
                WHEN NO_DATA_FOUND THEN 
                -- Al producirse la excepción se realiza la búsqueda de los datos EMV con la partición siguiente(idparticion_sig) 
                -- JLE - 30/10/2018 - Data Integrity - Edit 1
                    select /*+ NO_PARALLEL  INDEX (A,PK_CLR_DCEMVFULL)*/    
                            emvtvr_p55_actc, perint_p55_actc, numale_p55_actc, capter_p55_actc,
                            scremi_p55_actc, numsec_p23_actc, daplem_p55_actc, ttcrip_p55_actc,
                            infcri_p55_actc, emvatc_p55_actc, crippe_p55_actc, paicri_p55_actc,
                            feccri_p55_actc, impcri_p55_actc, moncri_p55_actc, imccri_p55_actc
                    into vemvtvr_p55_actc, vperint_p55_actc, vnumale_p55_actc, vcapter_p55_actc,
                            vscremi_p55_actc, vnumsec_p23_actc, vdaplem_p55_actc, vttcrip_p55_actc,
                            vinfcri_p55_actc, vemvatc_p55_actc, vcrippe_p55_actc, vpaicri_p55_actc,
                            vfeccri_p55_actc, vimpcri_p55_actc, vmoncri_p55_actc, vimccri_p55_actc
                    from CLR_DCEMVFULL A
                    where idemen_p00_actc = DECODE(c.idemen_p00_actc,1240,1244,1440,1444)
                        and idetra_p11_actc = c.idetra_p11_actc
                        and timloc_p12_actc = c.timloc_p12_actc
                        and ideadq_p32_actc = c.ideadq_p32_actc
                        and idparticion     = c.idparticion_sig 
                        and id_mes          = c.id_mes_sig;
            END;
        
--         mb(23):='1';
--         vt1240C.numsec_p23_actc := LPAD(NVL(TRIM(vnumsec_p23_actc),'0'),3,'0');

--         if vnumsec_p23_actc is not null then
            mb(23):='1';
            vt1240C.numsec_p23_actc := LPAD(NVL(vnumsec_p23_actc,'0'),3,'0');
--         end if;

         mb(55):='1';

--         if vcrippe_p55_actc is null then
--            vt1240C.t9f26_de55 := '';
--         else
            vdato := LPAD(NVL(vcrippe_p55_actc,'0'),16,'0'); --std.PF_BCD2HEX(vcrippe_p55_actc); --std.pf_hex2bin(std.PF_BCD2HEX(vcrippe_p55_actc));
            vlong := std.pf_dec2hex(length(vdato)/2); --std.pf_hex2bin(std.pf_dec2hex(length(vdato) / 8));
            vt1240C.t9f26_de55 := '9F26'||lpad(vlong,2,'0')||vdato;
            vlong := '';
            vdato := '';
--         end if;

            vdato := LPAD(NVL(vimccri_p55_actc,'0'),12,'0'); --std.pf_bcd2hex(vimccri_p55_actc); --std.pf_hex2bin(std.pf_bcd2hex(vimccri_p55_actc));
            vlong := std.pf_dec2hex(length(vdato)/2); --std.pf_hex2bin(std.pf_dec2hex(length(vdato) / 8));
            vt1240C.t9f03_de55 := '9F03'||lpad(vlong,2,'0')||vdato; --std.pf_hex2bin('9F03')||vlong||vdato;
            vlong := '';
            vdato := '';
--         end if;

         vt1240C.De55      := vt1240C.t9f26_de55||vt1240C.t9f27_de55||vt1240C.t9f10_de55||vt1240C.t9f37_de55||
                              vt1240C.t9f36_de55||vt1240C.t95_de55  ||vt1240C.t9a_de55  ||vt1240C.t9c_de55  ||
                              vt1240C.t9f02_de55||vt1240C.t5f2a_de55||vt1240C.t82_de55  ||vt1240C.t9f1a_de55||
                              vt1240C.t9f03_de55;

         -- JMG: valida si P55 es nulo
         IF vt1240C.De55 IS NULL THEN
            mb(55):='0';
            pqmonproc.inslog(vidproc, 'W', 'No Existe P55 para P31='||vt1240C.refadq_p31_actc);
         ELSE
            vt1240C.londat_p55 := lpad(length(vt1240C.De55)/2,3,'0');
         END IF;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 mb(55):='0';
                 pqmonproc.inslog(vidproc, 'W', 'Esta transaccion no tiene datos complemetarios='||vt1240C.refadq_p31_actc);
         END;

      end if;

      mb(49):='1';
      if  c.codfun_p24_actc  = '200'  then
         if vt1240C.isnum_nacional > 0 then
            vt1240C.montra_p49_actc := c.montra_p49_actc;
         else
            vt1240C.montra_p49_actc := '840';
         end if;
      end if;

      if  c.codfun_p24_actc  != '200'  then
          vt1240C.montra_p49_actc := vt1240C.currenCode;
      end if;

      if c.codfun_p24_actc = '200' and NVL(c.CYCLID_P63_ACTC,' ') <> ' '  then
        mb(63):='1';   vt1240C.de_63 := '016 ' || rpad(c.CYCLID_P63_ACTC,15,' '); --IPR 1062
      end if;

      mb(71):='1';
      vNumSecReg              := vNumSecReg + 1;
      vt1240C.nummen_p71_actc := lpad(vNumSecReg,8,0);
      if c.codfun_p24_actc != '200' then
         if vt1240C.codraz_p25_actc in ('2001','2002','2003','2004','2005','2008','2011',
                                        '2700','2701','2702','2703','2704','2705','2706',
                                        '2707','2708','2709','2710','2713','2870','2871') and length(trim(c.NUMEMI_P95_ACTC)) > 0  then
            mb(72):='1';
            vt1240C.londat_de72     := to_char(lpad(length(trim(substr(c.numemi_p95_actc,7,50))),3,0));
            vt1240C.de_72           := trim(substr(c.numemi_p95_actc,7,50));
         end if;
      end if;

      mb(94):='1';
      vt1240C.londat_de94     := vt1240C.londat_de33;
      vt1240C.de_94           := vt1240C.de_33;
      if c.codfun_p24_actc != '200'  then
          mb(95):='1';   vt1240C.de_95 := '10'||vt1240C.TransationID;
      end if;

      -- Concatenar los campos del registro en linea
      strHexa1240C:= rtrim(ltrim(f_gen_MapaHex2(mb)));
      vt1240C.bitpri_actc := substr(strHexa1240C,1,16);
      vt1240C.bitsec_actc := substr(strHexa1240C,17,16);

      vCad1240:= vt1240C.idemen_p00_actc || vt1240C.bitpri_actc      || vt1240C.bitsec_actc      ||
                 vt1240C.lontar_l02_actc || vt1240C.numtar_p02_actc  || vt1240C.codpro_p03_actc  ||
                 vt1240C.imptra_p04_actc || vt1240C.timloc_p12_actc  || vt1240C.feccad_p14_actc  ||
                 vt1240C.punser_p22_actc || vt1240C.numsec_p23_actc  || vt1240C.codfun_p24_actc  || vt1240C.codraz_p25_actc  ||
                 vt1240C.codact_p26_actc || vt1240C.de_30            || vt1240C.refadq_p31_actc  ||
                 vt1240C.londat_de32     || vt1240C.de_32            || vt1240C.londat_de33      ||
                 vt1240C.de_33           || vt1240C.datref_p37_actc  || vt1240C.numaut_p38_actc  || vt1240C.codser_p40_actc ||
                 vt1240C.ideter_p41_actc || vt1240C.ideest_p42_actc  || vt1240C.longdat_p43      ||
                 vt1240C.nomest_p43_actc || vt1240C.dircomercio_p43  || vt1240C.locest_p43_actc  ||
                 vt1240C.cod_postal      || vt1240C.cod_estado       || vt1240C.paiest_p43_actc  ||
                 vt1240C.londat_P48      || vt1240C.De48             || vt1240C.montra_p49_actc  ||
                 vt1240C.moncon_p50_actc || vt1240C.londat_p55       || vt1240C.De55             ||
                 vt1240C.de_63           || vt1240C.nummen_p71_actc  || vt1240C.londat_de72      ||
                 vt1240C.de_72           || vt1240C.londat_de94      || vt1240C.de_94            ||
                 vt1240C.de_95;

      utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
      utl_file.new_line(vidfile);
      utl_file.fflush(vidfile);

      -- Inicio: Calculos para Registro de Conciliacion (1240)
      vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
 END LOOP;
END;

PROCEDURE p_GenRegAnulacion(pfecha  varchar2, pbanco varchar2, pcodhcierre CHAR) IS
 strhexa1240A       varchar2(32)     := '';
 vcodpostal         varchar2(10)     := '';
 vcodestado         varchar2(3)      := '';
 long_p48           number           := 0;
 vbanco             varchar2(2)      := '';
 vt1240A            msg_1240A;
 vMsg1644Adendum    Msg1644Adendum;
 mb                 Mapa_Bits;
 vs                 s;
 pds0158_de48       VARCHAR2(20)    :='';
 mb40               VARCHAR2(1)     :='';
 vcodser            VARCHAR2(3)     :=NULL;
/* vlong              varchar2(128);
 vdato              varchar2(1024);
 ncero              number := 0;

 videmen_p00_actc   clr_dcemvfull.idemen_p00_actc%TYPE;
 videtra_p11_actc   clr_dcemvfull.idetra_p11_actc%TYPE;
 vtimloc_p12_actc   clr_dcemvfull.timloc_p12_actc%TYPE;
 videadq_p32_actc   clr_dcemvfull.ideadq_p32_actc%TYPE;
 vemvtvr_p55_actc   clr_dcemvfull.emvtvr_p55_actc%TYPE;
 vperint_p55_actc   clr_dcemvfull.perint_p55_actc%TYPE;
 vnumale_p55_actc   clr_dcemvfull.numale_p55_actc%TYPE;
 vcapter_p55_actc   clr_dcemvfull.capter_p55_actc%TYPE;
 vscremi_p55_actc   clr_dcemvfull.scremi_p55_actc%TYPE;
 vnumsec_p23_actc   clr_dcemvfull.numsec_p23_actc%TYPE;
 vdaplem_p55_actc   clr_dcemvfull.daplem_p55_actc%TYPE;
 vttcrip_p55_actc   clr_dcemvfull.ttcrip_p55_actc%TYPE;
 vemvatc_p55_actc   clr_dcemvfull.emvatc_p55_actc%TYPE;
 vcrippe_p55_actc   clr_dcemvfull.crippe_p55_actc%TYPE;
 vpaicri_p55_actc   clr_dcemvfull.paicri_p55_actc%TYPE;
 vfeccri_p55_actc   clr_dcemvfull.feccri_p55_actc%TYPE;
 vimpcri_p55_actc   clr_dcemvfull.impcri_p55_actc%TYPE;
 vinfcri_p55_actc   clr_dcemvfull.infcri_p55_actc%TYPE;
 vmoncri_p55_actc   clr_dcemvfull.moncri_p55_actc%TYPE;
 vimccri_p55_actc   clr_dcemvfull.imccri_p55_actc%TYPE;
 */


 CURSOR cr_anulacion IS
 SELECT idemen_p00_actc,   lontar_l02_actc,   numtar_p02_actc,
         codpro_p03_actc,   imptra_p04_actc,   idetra_p11_actc, timloc_p12_actc,
         DECODE(feccad_p14_actc,'0000','',feccad_p14_actc) feccad_p14_actc,
         punser_p22_actc,   codfun_p24_actc,   codraz_p25_actc,
         codact_p26_actc,   lpad(nvl(impori_p30_actc,0),12,0) impori_p30_actc, lonref_l31_actc,
         refadq_p31_actc,   ideadq_l32_actc,   ideadq_p32_actc,
         idepre_l33_actc,   idepre_p33_actc,   pista2_p35_actc, datref_p37_actc,
         numaut_p38_actc,   ideter_p41_actc,   ideest_p42_actc,
         nomest_p43_actc,   locest_p43_actc,   decode(paiest_p43_actc,'VE','VEN','VEN')paiest_p43_actc,
         londat_p48_actc,   montra_p49_actc,   moncon_p50_actc,SUBSTR(FILLER_P62_ACTC,1,15) CYCLID_P63_ACTC,
         nummen_p71_actc,   numemi_p95_actc,   sesion_p28_actc,
         oriide_p56_actc,   SUBSTR(oritim_p56_actc,1,6) oritim_p56_actc, codser_p40_actc
    FROM clr_ex8010
   WHERE sesion_p28_actc  = pfecha
     and SUBSTR(ideadq_p32_actc,3,4)  = pbanco
     and COD_HRCIERRE = pcodhcierre
     and idemen_p00_actc  = '1440'
     and substr(tiptra_p48_actc,1,2)  = '06'
     and oriide_p56_actc  = '1240';

 BEGIN

   --inicia generacion de Anulacion
   vPaso   := 'Paso 04';

      FOR c IN cr_anulacion LOOP
      long_p48:=0;

      vt1240A     := f_ini_msg1240A;

      mb:= f_inimapabits;

      mb(1):='1';   vt1240A.mti      := '1240';

      mb(2) :='1';  vt1240A.lontar_l02_actc := to_char(c.lontar_l02_actc);
                    vt1240A.numtar_p02_actc := c.numtar_p02_actc;

      mb(3) :='1';  vt1240A.codpro_p03_actc := '000000'; --'200000';

      --mb(4) :='1';  vt1240A.imptra_p04_actc := to_char(lpad(c.imptra_p04_actc,12,0));
      
      ---  Inicio Mod. 28/01/2020 - Error 0122
      mb(4) :='1';  vt1240A.isnum_nacional := f_FindTarjetaNacional(vIdProc, vt1240A.numtar_p02_actc,vbanco);
      
      IF c.codfun_p24_actc = '200' THEN
         IF vt1240A.isnum_nacional > 0 THEN
            vt1240A.imptra_p04_actc := TO_CHAR(LPAD(c.imptra_p04_actc,12,0));
         ELSE
            vt1240A.imptra_p04_actc := LPAD(TO_CHAR(ROUND(((c.imptra_p04_actc/100) / vTipocambio),2)*100),12,0);
         END IF;
      END IF;

      IF c.codfun_p24_actc  != '200' THEN
         p_findTransactionIdDisputas(c.refadq_p31_actc, c.numtar_p02_actc,vt1240A.TransationID,vt1240A.SourceAmount,vt1240A.currenCode,vt1240A.pds0262_Ide48);
         vt1240A.imptra_p04_actc  := vt1240A.SourceAmount;
      END IF;
     --- Fin de  Mod. 28/01/2020 - Error 0122
      
                    vMontoTotal             := vMontoTotal + TO_NUMBER(NVL(vt1240A.imptra_p04_actc,0));
                    vtotalMensaje           := vtotalMensaje + 1;

      mb(12):='1';  vt1240A.timloc_p12_actc := c.timloc_p12_actc;
      IF c.feccad_p14_actc IS NOT NULL THEN
         mb(14):='1';    vt1240A.feccad_p14_actc  := c.feccad_p14_actc;
      END IF;

      mb(22):='1';
/*       if c.punser_p22_actc is null then
          vt1240A.punser_p22_actc := '000000000000';
      ELSE
          vs.s1  := substr(c.punser_p22_actc,1,1);
          IF vs.s1 <>'5' THEN  vs.s1:= substr(c.punser_p22_actc,1,1);
      ELSE
          IF substr(c.punser_p22_actc,4,1) ='M' THEN  vs.s1:= 'D' ; Else vs.s1 := 'C';
          END IF;END IF; */

     /* NUEVO CAMBIO */
     IF c.punser_p22_actc IS NULL THEN
        vt1240A.punser_p22_actc := '000000000000';
     ELSE
         IF SUBSTR(c.punser_p22_actc,4,1) = 'M' THEN  vs.s1 := 'D' ;
         ELSE
            IF  SUBSTR(c.punser_p22_actc,7,1) ='5' THEN vs.s1 := 'D';
            ELSE
                 IF  SUBSTR(c.punser_p22_actc,7,1) IN ('2','6','S') THEN vs.s1 := 'C';
                 ELSE
                    vs.s1 := 'D';
                 END IF;
            END IF;
         END IF;
          vs.s2  := SUBSTR(c.punser_p22_actc,2,1);
          vs.s3  := SUBSTR(c.punser_p22_actc,3,1);
          vs.s4  := SUBSTR(c.punser_p22_actc,4,1);
          IF  vs.s4 ='M' THEN -- realizado por Carlos Brito para: valida campo 22 subcampo 4, M es igual a mPOs y se modifica para que mande el valor 1 fecha 05/05/2017
                  vs.s4:='1' ;
             END IF;
          vs.s6  := substr(c.punser_p22_actc,6,1);
          vs.s10 := substr(c.punser_p22_actc,10,1);
          vs.s11 := substr(c.punser_p22_actc,11,1);
          vs.s12 := substr(c.punser_p22_actc,12,1);

          vs.s5 := substr(c.punser_p22_actc,5,1);
          if vs.s5 = '2' then    vs.s5 := '3';     end if;
          if vs.s5 = '3' then    vs.s5 := '4';     end if;
          if vs.s5 = '7' or      vs.s5 = '8'       then     vs.s5 := '5'; end if;

          vs.s7 := substr(c.punser_p22_actc,7,1);
          if vs.s7 = '5' then    vs.s7 := 'C';     end if;
          if vs.s7 = '6' then    vs.s7 := '1'; end if; --JLE - 19/09/2018 - Data Integrety - Tx Entrada Manual del PAN
          --if vs.s7 = 'S' or      vs.s7  = 'T'      then     vs.s7 := 'B'; end if; --Se cambio la F por B , solicitado por AVV para las pruebas con chip en caso de fallback
          if vs.s7 = 'S' or      vs.s7  = 'T'  or  vs.s7  = '2'   then     vs.s7 := 'B'; end if; --JLE - 19/09/2018 - Data Integrety - Tx Banda Magnética
          
          if vs.s5 = '7' then    vs.s7 := 'T';     end if;
          if vs.s5 = '8' then    vs.s7 := 'S';     end if;

          vs.s8 := substr(c.punser_p22_actc,8,1);
          if vs.s8 = '8' then    vs.s8 := '6';     end if;

          vs.s9  := substr(c.punser_p22_actc,9,1);
          if vs.s8 = '0' and     vs.s9  = '0'      then     vs.s9 := '0'; end if;
          if vs.s8 = '1' and     vs.s9  = '1'      then     vs.s9 := '1'; end if;
          if vs.s8 = '1' and     vs.s9  = '3'      then     vs.s9 := '3'; end if;
          if vs.s8 = '5' and     vs.s9  = '4'      then     vs.s9 := '4'; end if;

          --se concatena todas las cadenas
          vt1240A.punser_p22_actc := vs.s1||vs.s2||vs.s3||vs.s4||vs.s5||vs.s6||vs.s7||vs.s8||vs.s9||vs.s10||vs.s11||vs.s12;
       end if;

      mb(24):='1';
      vt1240A.codfun_p24_actc := '200';
          if c.codraz_p25_actc = '1377' and c.impori_p30_actc = 0 then
             mb(25):='1';
             vt1240A.codraz_p25_actc := '1401';
          else
             mb(25):='1';
             vt1240A.codraz_p25_actc := '1402';
          end if;

      mb(26):='1';
      vt1240A.codact_p26_actc := lpad(c.codact_p26_actc,4,0);
      -- Solo para transacciones cuyo mcc = 7995(11/09/2009)
      if vt1240A.codact_p26_actc in ('4829','7995') then
         vt1240A.codpro_p03_actc := '180000';
      end if;

      mb(31):='1';
      vt1240A.refadq_p31_actc := to_char(lpad(c.lonref_l31_actc,2,0))||lpad(c.refadq_p31_actc,23,0);

      mb(32):='1';
      if pbanco = '0105' then vbanco :='BM'; end if;
      if pbanco = '0108' then vbanco :='BP'; end if;

      if vbanco  = 'BM' then
         vt1240A.de_32       := '010375';
         vt1240A.londat_de32 := '06';
      else
         vt1240A.de_32       := '010403';
         vt1240A.londat_de32 := '06';
      end if;

      mb(33):='1';
      if vbanco  = 'BM' then
         vt1240A.de_33        := '010375';
         vt1240A.londat_de33  := '06';
      else
         vt1240A.de_33        := '010403';
         vt1240A.londat_de33  := '06';
      end if;

      if c.datref_p37_actc is not null or c.datref_p37_actc <> '0%' then
           mb(37):='1';     vt1240A.datref_p37_actc := rpad(c.datref_p37_actc,12,0);
      end if;

      mb(38):='1';
    --vt1240A.numaut_p38_actc  :=  rpad(c.numaut_p38_actc,6,0);
      vt1240A.numaut_p38_actc  :=  RPAD(NVL(c.numaut_p38_actc,'0'),6,'0'); -- JMG 19/02/2011

      mb(41):='1';
      vt1240A.ideter_p41_actc  :=  rpad(c.ideter_p41_actc,8,0);

      mb(42):='1';
      vt1240A.ideest_p42_actc  :=  rpad(c.ideest_p42_actc,15,' ');

      mb(43):='1';
      vt1240A.nomest_p43_actc  :=  rpad(substr(c.nomest_p43_actc,1,22),22,' ')||'\';
      vt1240A.dircomercio_p43  :=  '\';
      vt1240A.locest_p43_actc  :=  rpad(c.locest_p43_actc,13,' ')||'\';

      p_findPostalCode(c.ideest_p42_actc,vcodpostal,vcodestado);
      vcodpostal := pqutlcom.p_PostalCodexState(vcodestado); -- IPR 1080 CODIGO POSTAL POR ESTADO
      vt1240A.cod_postal       := rpad(vcodpostal,10,' ');
      vt1240A.cod_estado       := rpad(vcodestado,3,' ');
      vt1240A.paiest_p43_actc  := rpad(c.paiest_p43_actc,3,' ');
      vt1240A.longdat_p43      := lpad(length(vt1240A.nomest_p43_actc||
                                              vt1240A.dircomercio_p43||
                                              vt1240A.locest_p43_actc||
                                              vt1240A.cod_postal||
                                              vt1240A.cod_estado||
                                              vt1240A.paiest_p43_actc),2,0);


      mb(48):='1';
      vt1240A.pds0025_de48        := '0025007R'||substr(c.timloc_p12_actc,1,6);
      vt1240A.pds0148_de48        := '0148004'||c.montra_p49_actc||'2';

      if c.codfun_p24_actc = '200' and c.impori_p30_actc > 0 then
         vt1240A.pds0149_de48   := '0149006'||c.montra_p49_actc||'000';
      end if;

      vt1240A.isnum_nacional  := f_FindTarjetaNacional(vIdProc, vt1240A.numtar_p02_actc,vBanco);

       VTIPO_TERM:=FN_TIPO_TERM_TRANS(vt1240A.ideter_p41_actc);

      /*if vt1240A.isnum_nacional > 0 then
         vt1240A.pds0148_de48   := '0023003'||VTIPO_TERM||'0148004'||c.montra_p49_actc||'2';
      else
         vt1240A.pds0148_de48   := '0023003'||VTIPO_TERM||'01480048402';
      end if;
      */
      --p_findird(vIdProc, vt1240A.codact_p26_actc, vt1240A.cod_mcc, vt1240A.cod_ird, vt1240A.cod_tcc );

      if vt1240A.isnum_nacional > 0 then   --Tarjetas Nacionales

         if to_number(vt1240A.codact_p26_actc) = to_number(vt1240A.cod_mcc)  then
            vt1240A.pds0158_de48 := '0158012MCC       '||lpad(to_char(vt1240A.cod_ird),2,'0');
         end if;

      else

         p_getDataInternacional(vIdProc, c.numtar_p02_actc,vbanco, vt1240A.Cod_Producto_GCMS, vt1240A.cod_licen_producto, vt1240A.cod_pais, vt1240A.cod_region,vt1240A.cod_programa);
         vt1240A.isBetweenFiveday := f_isBetweenFiveday(to_date(substr(c.timloc_p12_actc,1,6),'yymmdd'));
         vt1240A.isBetweenThirtyday := f_isBetweenThirtyday(to_date(substr(c.timloc_p12_actc,1,6),'yymmdd'));

         vcodser := LPAD(NVL(c.codser_p40_actc,'0'),3,'0');

         vt1240A.FecPresentacion := c.oritim_p56_actc;

         if vt1240A.Cod_Producto_GCMS in ('DAG','DAP','DAS','DOS','SAG','SAP','SAS','SOS','WBE','MBP','MBT','MTP','MDJ','MRH','MDP','MET') then --SE AGREGO LA 'MRH' PARA EL MDG GLOBAL 396 IPR 1112 FV-BSP 04/09/2013
            vt1240A.pds0002_de48 := '0002003' || vt1240A.Cod_Producto_GCMS ;
            vt1240A.pds0003_de48 := '0003003' || vt1240A.cod_licen_producto;
         else
            vt1240A.pds0002_de48 := '';
            vt1240A.pds0003_de48 := '';
         end if;

         --p_Obtiene_IRD(vt1240A.Cod_Producto_GCMS,vt1240A.cod_region,c.punser_p22_actc,vt1240A.punser_p22_actc,vcodser,vt1240A.isBetweenFiveday,vt1240A.isBetweenThirtyday,vt1240A.FecPresentacion,vt1240A.cod_programa,pds0158_de48,mb40);

         vt1240A.pds0158_de48 := pds0158_de48;

         IF mb40 = '1' THEN
            mb(40):= mb40;
            vt1240A.codser_p40_actc := vcodser;
         END IF;

      END IF;

      vt1240A.pds0165_de48 := '0165001M';

      vt1240A.De48         := vt1240A.pds0002_de48  ||vt1240A.pds0003_de48
                            ||vt1240A.pds0025_de48  ||vt1240A.pds0148_de48
                            ||vt1240A.pds0149_de48  ||vt1240A.pds0158_de48
                            ||vt1240A.pds0165_de48  ||vt1240A.pds0262_de48;

      vt1240A.londat_P48 := Lpad(length(vt1240A.De48),3,'0');



      mb(49):='1';
      IF c.imptra_p04_actc IS NOT NULL THEN
          vt1240A.montra_p49_actc := c.montra_p49_actc;
      ELSE
          vt1240A.montra_p49_actc := '000';
      END IF;

      IF  NVL(c.CYCLID_P63_ACTC,' ') <> ' ' THEN
        mb(63):='1'; vt1240A.de_63 := '016 ' || RPAD(c.CYCLID_P63_ACTC,15,' '); --IPR 1062
      END IF;

      mb(71):='1';
      vNumSecReg              := vNumSecReg + 1;
      vt1240A.nummen_p71_actc := lpad(vNumSecReg,8,0);

      mb(94):='1';
      vt1240A.londat_de94     := vt1240A.londat_de33;
      vt1240A.de_94           := vt1240A.de_33;

      -- Concatenar los campos del registro en linea
      strHexa1240A:= rtrim(ltrim(f_gen_MapaHex2(mb)));
      vt1240A.bitpri_actc := substr(strHexa1240A,1,16);
      vt1240A.bitsec_actc := substr(strHexa1240A,17,16);

      vCad1240:= vt1240A.mti             || vt1240A.bitpri_actc      || vt1240A.bitsec_actc      ||
                 vt1240A.lontar_l02_actc || vt1240A.numtar_p02_actc  || vt1240A.codpro_p03_actc  ||
                 vt1240A.imptra_p04_actc || vt1240A.timloc_p12_actc  || vt1240A.feccad_p14_actc  ||
                 vt1240A.punser_p22_actc || vt1240A.numsec_p23_actc  || vt1240A.codfun_p24_actc  || vt1240A.codraz_p25_actc  ||
                 vt1240A.codact_p26_actc || vt1240A.de_30            || vt1240A.refadq_p31_actc  ||
                 vt1240A.londat_de32     || vt1240A.de_32            || vt1240A.londat_de33      ||
                 vt1240A.de_33           || vt1240A.datref_p37_actc  || vt1240A.numaut_p38_actc  ||  vt1240A.codser_p40_actc ||
                 vt1240A.ideter_p41_actc || vt1240A.ideest_p42_actc  || vt1240A.longdat_p43      ||
                 vt1240A.nomest_p43_actc || vt1240A.dircomercio_p43  || vt1240A.locest_p43_actc  ||
                 vt1240A.cod_postal      || vt1240A.cod_estado       || vt1240A.paiest_p43_actc  ||
                 vt1240A.londat_P48      || vt1240A.De48             || vt1240A.montra_p49_actc  ||
                 vt1240A.moncon_p50_actc || vt1240A.londat_p55       || vt1240A.De55             ||
                 vt1240A.de_63           || vt1240A.nummen_p71_actc  || vt1240A.londat_de94      ||
                 vt1240A.de_94           || vt1240A.de_95;

      --formato fijo a 1024 posiciones
      --vlinea   := rpad(vlinea,1024,' ');

      utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
      utl_file.new_line(vidfile);
      utl_file.fflush(vidfile);

      -- Inicio: Calculos para Registro de Conciliacion (1240)
      vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
   END LOOP;
END;



procedure p_GenReg1644(vcodfuncion number,vfecha varchar2,vbanco varchar2)as
    m1644          Msg_1644;
    vbit_pri       varchar2(16)     := '';
    vbit_sec       varchar2(16)     := '';
    bank           varchar2(11)     := '';
   -- vBancoVi       varchar2(6)      := '';
   -- vBancoMc       varchar2(6)      := '';


Begin
      --inicia proceso de outgoing Banco Provincial
      vPaso   := 'Paso 06';

      m1644.idemen_p00_actc   := '1644';
      vbit_pri                := '8000010000010000';
      vbit_sec                := '0200000000000000' ;


      if vbanco = 'BM'  then
             bank        := lpad('010375',11,0);
            -- vBancoVi    := '540105';
            -- vBancoMc    := '990105';
         else if vbanco = 'BP' then
             bank        := lpad('010403',11,0);
            -- vBancoVi    := '540108';
            -- vBancoMc    := '990108';
         end if;
      end if;


      vNumSecReg             := vNumSecReg + 1;
      m1644.nummen_p71_actc  := to_char(lpad((vNumSecReg),8,0));


      --cabecera de registro
      if vcodfuncion = 697 then
           m1644.pds0105_p48      := '0105025002'||vfecha||bank||lpad(to_char(vSecControl),5,0);
           m1644.pds0122_p48      := '0122001'||vTipFileMC;


           m1644.londat_p48_actc  := lpad(length(m1644.pds0105_p48||
                                                 m1644.pds0122_p48),3,0);

           m1644.de_p48           :=  m1644.pds0105_p48||   m1644.pds0122_p48||
                                      m1644.pds0301_p48||   m1644.pds0306_p48;
      end if;

      --trailer de registro
       if  vcodfuncion = 695 then
         m1644.pds0105_p48      := '0105025002'||vfecha||bank||lpad(to_char(vSecControl),5,0);
          --m1644.pds0122_p48     := '0122001T';
          m1644.pds0301_p48     := '0301016'||lpad(to_char(nvl(vMontoTotal,0)),16,0);
          m1644.pds0306_p48     := '0306008'||to_char(lpad(nvl(vtotalMensaje,0)+ 2,8,0));

          m1644.londat_p48_actc := lpad(length(m1644.pds0105_p48||
                                               m1644.pds0301_p48||
                                               m1644.pds0306_p48),3,0);

          m1644.de_p48          := m1644.pds0105_p48|| m1644.pds0301_p48||m1644.pds0306_p48;
       end if;

     m1644.codfun_p24_actc         :=   vcodfuncion;

     vCad1240:= m1644.idemen_p00_actc ||   vbit_pri||               vbit_sec||
                m1644.codfun_p24_actc ||   m1644.codraz_p25_actc||  m1644.codact_p26_actc||
                m1644.impori_p30_actc ||   m1644.refadq_p31_actc||  m1644.londat_p48_actc||
                m1644.de_p48||             m1644.nummen_p71_actc;

     --formato fijo a 1024 posiciones
     --vlinea   := rpad(vlinea,1024,' ');

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);

End;



PROCEDURE p_GenReg1740(pfecha  varchar2, pbanco varchar2, pcodhcierre CHAR) IS
 strhexa1240C       varchar2(32)     := '';
 vcodpostal         varchar2(10)     := '';
 vcodestado         varchar2(3)      := '';
 vcad1740           varchar2(999)    := '';
 long_p48           number           := 0;
 vbanco             varchar2(2)      := '';
 vfecJuliana        varchar2(4)      := '';
 vbinAdq            varchar2(6)      := '';
 vt1740             msg_1740;
 vMsg1644Adendum    Msg1644Adendum;
 mb                 Mapa_Bits;
 vs                 s;

cursor cr_1740 is
    select *
      from clr_copae8010
     where sesion_p28_accp  = pfecha
       and SUBSTR(ideadq_p32_accp,3,4)  = pbanco
       and COD_HRCIERRE = pcodhcierre
       and idemen_p00_accp  = '1740';

begin
   --inicia Generacion mensajes 1740
   vPaso   := 'Paso 07';

   if pbanco = '0105' then vbanco :='BM'; end if;
   if pbanco = '0108' then vbanco :='BP'; end if;

   for c in cr_1740  loop
      vcad1740  := '';
      long_p48  := 0;
      vt1740    := f_ini_msg1740;

      mb:= f_inimapabits;
      -- presencia del mapa de bits secundario
      mb(1) :='1';   vt1740.mti   := '1740';

      if c.numtar_p02_accp is not null then
         mb(2) :='1';   vt1740.de02  := lpad(to_char(c.lontar_l02_accp),2,0)||c.numtar_p02_accp;
      end if;
      if c.sigcu1_p46_accp = 'C' then
         mb(3) :='1';   vt1740.de03   := '290000';
      elsif c.sigcu1_p46_accp = 'D' then
         mb(3) :='1';   vt1740.de03   := '190000';
      end if;
      --mb(3) :='1';   vt1740.de03   := '190000';
      mb(4) :='1';   vt1740.de04   := lpad(to_char(c.impcu1_p46_accp),12,0);
                     vMontoTotal   := vMontoTotal + to_number(nvl(vt1740.de04,0));
                     vtotalMensaje := vtotalMensaje + 1;

      mb(24):='1';   vt1740.de24   := c.codfun_p24_accp;
      mb(25):='1';   vt1740.de25   := f_FindCodigoRazon(c.codraz_p25_accp,c.numtar_p02_accp);


      mb(33):='1';
          if vbanco  = 'BM' then  vt1740.de33  := '06010375'; end if;
          if vbanco  = 'BP' then  vt1740.de33  := '06010403'; end if;

      mb(48):='1';
                      --de48_pds0137
                      if vbanco = 'BM' then   vbinadq := '550291'; end if;
                      if vbanco = 'BP' then   vbinadq := '550291'; end if;

                      select to_char(sysdate,'y')||to_char(sysdate,'ddd')
                      into vfecJuliana
                      from dual;

                      vt1740.pds0137_cad   := '7'||vbinadq||vfecJuliana||c.idetra_p11_accp;
                      vt1740.digCheck      := f_GenCheckDigit(vt1740.pds0137_cad);
                      vt1740.pds0137_lon   := lpad(length(vt1740.pds0137_cad||to_char(vt1740.digCheck)),3,0);
                      vt1740.de48_pds0137  := '0137'||vt1740.pds0137_lon||vt1740.pds0137_cad||to_char(vt1740.digCheck);

                      --de48_pds0148
                      vt1740.isnum_nacional := f_FindTarjetaNacional(vIdProc, c.numtar_p02_accp,vbanco);
                      vt1740.de48_pds0148   := '0148004'||vMoney||'2';

                      vt1740.de48_pds0165   := '0165001M';

                      vt1740.De48           := vt1740.de48_pds0137||vt1740.de48_pds0148||
                                               vt1740.de48_pds0165;

                      vt1740.de48_londat := Lpad(length(vt1740.De48),3,'0');

      mb(49):='1';    vt1740.de49   := vMoney;
      mb(71):='1';    vNumSecReg    := vNumSecReg + 1;
                      vt1740.de71   := lpad(vNumSecReg,8,0);

      mb(73):='1';    vt1740.de73   := substr(c.timloc_p12_accp,1,6);
      mb(93):='1';    vt1740.de93   := '11'||lpad(f_getIdBankDestino(c.numtar_p02_accp,vbanco),11,0);
      mb(94):='1';    vt1740.de94   := vt1740.de33;


      strHexa1240C:= rtrim(ltrim(f_gen_MapaHex2(mb)));
      vt1740.bitpri := substr(strHexa1240C,1,16);
      vt1740.bitsec := substr(strHexa1240C,17,16);

      vcad1740  :=  vt1740.mti             || vt1740.bitpri         || vt1740.bitsec
                 || vt1740.de02            || vt1740.de03           || vt1740.de04
                 || vt1740.de24            || vt1740.de25           || vt1740.de33
                 || vt1740.de48_londat     || vt1740.De48           || vt1740.de49
                 || vt1740.de71            || vt1740.de73           || vt1740.de93
                 || vt1740.de94;

      utl_file.put_line(vidfile,vcad1740,true);

      vMtoTot_1240.TotalMensaje  := vMtoTot_1240.TotalMensaje + 1;
end loop;
end;



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

function f_ini_msg1240A return Msg_1240A is
    vtc_Msg_1240A  Msg_1240A;
  begin
    return vtc_Msg_1240A;
end ;

--procedimiento eliminado p_Obtiene_IRD

function f_ini_msg1740 return Msg_1740 is
    vtc_Msg_1740  Msg_1740;
  begin
    return vtc_Msg_1740;
end ;


function f_ini_Msg1644Adendum return Msg1644Adendum is
    tvMsg1644Adendum  Msg1644Adendum;
  begin
    return tvMsg1644Adendum;
end ;


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

      if marca = 8010 then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bm 
            WHERE  cod_entadq = pbanco
            AND p28sesion = TO_CHAR(pfecha-1,'YYYYMMDD')
            AND p48tiptra LIKE '10%'
            AND p71nummen LIKE 'marca%';
            and rownum < 2;
      else if marca = 9010 then
            SELECT count(p00idmsg) into vCountReg
            FROM mcp_bm 
            WHERE  cod_entadq = pbanco
            AND p28sesion = TO_CHAR(pfecha-1,'YYYYMMDD')
            AND p48tiptra LIKE '10%'
            AND p71nummen LIKE 'marca%';
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


procedure p_getDataInternacional(pIdProc pls_integer, bin_tarjeta varchar2,pBanco char,pgcms out varchar2,plic_prod out varchar2,pcod_pais out varchar2, pcod_reg out varchar2,pcod_programa out varchar2) is
    vcont          pls_integer :=0;

    cursor cur_dataInternacional(bin_tarjeta varchar2) is
    select val_rango_menor, val_rango_mayor, cod_producto_gcms, cod_licencia_producto, cod_alf_pais, cod_region,ind_prog_tarjeta
      from bines_mc
     where to_number(val_rango_menor) <= to_number(rpad(substr(bin_tarjeta,1,19),19,'0'))
       and to_number(val_rango_mayor) >= to_number(rpad(substr(bin_tarjeta,1,19),19,'9'))
       and ind_activo                  = 'A'
       and cod_alf_pais               != 'VEN'
       and cod_entadq                  = pBanco
       and ind_prog_tarjeta            IN ('MCC','DMC');

begin

    for c in cur_dataInternacional(bin_tarjeta) loop
        pgcms       := c.cod_producto_gcms;
        plic_prod   := c.cod_licencia_producto;
        pcod_pais   := c.cod_alf_pais;
        pcod_reg    := c.cod_region;
        pcod_programa := c.ind_prog_tarjeta;
        vcont       := vcont + 1;
    end loop;

    if vcont = 0 then
       verrmsg := 'No existe rango menor y mayor para la tarjeta Nro '||bin_tarjeta;
       verrcod := '17';
       pqmonproc.inslog(pIdProc, 'W', vErrMsg);
       raise efinerror;
    end if;

    if vcont > 1 then
       vErrMsg := 'WARNING: Existen '||TO_CHAR(vcont)||' rangos de valor para la tarjeta: '||bin_tarjeta||'.';
       vcont   := 1;
       pqmonproc.inslog(pIdProc, 'W', vErrMsg);
    end if;

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


procedure p_GenReg1644_noMov(vcodfuncion number,vfecha varchar2,vbanco varchar2)as
    m1644          Msg_1644;
    vbit_pri       varchar2(16)     := '';
    vbit_sec       varchar2(16)     := '';
    bank           varchar2(11)     := '';

Begin
      m1644.idemen_p00_actc   := '1644';
      vbit_pri                := '8000010000010000';
      vbit_sec                := '0200000000000000' ;


      if vbanco = 'BM'  then
             bank      := lpad('010375',11,0);
      else if vbanco = 'BP' then
             bank      := lpad('010403',11,0);
         end if;
      end if;


      vtotalMensaje    := 0;

      vNumSecReg             := vNumSecReg + 1;
      m1644.nummen_p71_actc  := to_char(lpad((vNumSecReg),8,0));


      --cabecera de registro
      if vcodfuncion = 697 then
           m1644.pds0105_p48      := '0105025002'||vfecha||bank||lpad(to_char(vSecControl),5,0);
           m1644.pds0122_p48      := '0122001T';

           m1644.londat_p48_actc  := lpad(length(m1644.pds0105_p48||
                                                 m1644.pds0122_p48||
                                                 m1644.pds0301_p48||
                                                 m1644.pds0306_p48),3,0);

           m1644.de_p48           :=  m1644.pds0105_p48||   m1644.pds0122_p48||
                                      m1644.pds0301_p48||   m1644.pds0306_p48;
      end if;

      --trailer de registro
       if  vcodfuncion = 695 then
          m1644.pds0105_p48      := '0105025002'||vfecha||bank||lpad(to_char(vSecControl),5,0);
          m1644.pds0122_p48     := '0122001T';
          m1644.pds0301_p48     := '0301016'||to_char(lpad(nvl(vMontoTotal,0),16,0));
          m1644.pds0306_p48     := '0306008'||to_char(lpad(nvl(vtotalMensaje,0)+ 2,8,0));

          m1644.londat_p48_actc := lpad(length(m1644.pds0105_p48||
                                               m1644.pds0122_p48),3,0);

          m1644.de_p48          := m1644.pds0105_p48||  m1644.pds0122_p48;
       end if;

     m1644.codfun_p24_actc         :=   vcodfuncion;

     vCad1240:= m1644.idemen_p00_actc ||   vbit_pri||               vbit_sec||
                m1644.codfun_p24_actc ||   m1644.codraz_p25_actc||  m1644.codact_p26_actc||
                m1644.impori_p30_actc ||   m1644.refadq_p31_actc||  m1644.londat_p48_actc||
                m1644.de_p48||             m1644.nummen_p71_actc;

     utl_file.put_raw(vidfile, utl_raw.cast_to_raw(vCad1240),true);
     utl_file.new_line(vidfile);
     utl_file.fflush(vidfile);
End;



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
         where  nom_proceso  in ('POUTMC','POUTREMC')
           and  fh_sesion    = pfecha
           and  estado       = 'F' ;
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