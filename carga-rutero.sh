## Data de prueba--------------------------------
## idrutero = 58
## idcampana = 42
## idusuario = 5
## tipooperacion = INS
## nomarchivo = /home/interfaces/rutero/10500.csv

IDRUTERO=$1;
IDCAMPANA=$2;
IDUSUARIO=$3;
TIPOOPERACION=$4;
NOMARCHIVO=$5;


mysql --user=root --password=micall5454 --host=192.168.10.30 --verbose -e "SET @pFECHACARGA=NOW(); SET @pIDRUTERO="$IDRUTERO"; SET @pIDUSUARIO="$IDUSUARIO"; SET @pIDCAMPANA="$IDCAMPANA"; SET @pTIPOOPERACION='"$TIPOOPERACION"'; SET @pNOMARCHIVO='"$NOMARCHIVO"'; load data local infile '"$NOMARCHIVO"' into table RUTEROPASO FIELDS TERMINATED BY ';' ignore 1 lines (RUT, DV, NOMBRES, APELLIDOS, GENERO, FECHANAC, DIRECCION, COMUNA, REGION, CODIGOPOSTAL, EMAIL, MONTOAPROBADO, FONO1, FONO2, FONO3) SET FECHACARGA=@pFECHACARGA, IDCAMPANA=@pIDCAMPANA, IDUSUARIO=@pIDUSUARIO, IDRUTERO=@pIDRUTERO, TIPOOPERACION=@pTIPOOPERACION, NOMARCHIVO=@pNOMARCHIVO; CALL SP_TRAPASAR_RUTERO("$IDRUTERO");" micall