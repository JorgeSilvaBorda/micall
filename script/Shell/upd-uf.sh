dia=$(date '+%d');
mes=$(date '+%m');
anio=$(date '+%Y');

## Fecha formato dd-MM-yyyy
fecha=$dia'-'$mes'-'$anio;

## url
URL='https://mindicador.cl/api/uf/'$fecha;

