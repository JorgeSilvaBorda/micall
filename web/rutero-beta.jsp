<%@include file="headjava.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <script type="text/javascript">
            var RUTERO = null;
            document.getElementById('archivo').onchange = function () {
                var file = this.files[0];
                var reader = new FileReader();
                reader.onload = function () { //Acá convertir a tabla
                    var lineas = this.result.split("\n");
                    var rutero = {
                        idcampana: $('#select-campana').val(),
                        registros: 0,
                        filas: []
                    };
                    for (var i = 1; i < lineas.length; i++) { //Comienza en 1. La primera línea es cabecera
                        if (lineas[i].length > 10) {
                            var linea = lineas[i].split(";");
                            var folio = linea[0];
                            var rutcliente = linea[1];
                            var dvcliente = linea[2];
                            var nombres = linea[3];
                            var genero = linea[4];
                            var rangoetario = linea[5];
                            var dispavanve = linea[6];
                            var ultaefecha = linea[7];
                            var ultaemonto = linea[8];
                            var ultaecuotas = linea[9];
                            var areafono1 = linea[10];
                            var areafono2 = linea[11];
                            var areafono3 = linea[12];
                            var areafono4 = linea[13];
                            var grupo = linea[14];
                            var callcenter = linea[15];
                            var fecenvio = linea[16];
                            var filler1 = linea[17];
                            var filler2 = linea[18];
                            var filler3 = linea[19];
                            var filler4 = linea[20];
                            var filler5 = linea[21];
                            var filler6 = linea[22];
                            var color = linea[23];
                            var fechavencnexus = linea[24];
                            var afinidad = linea[25];

                            var filaRutero = {
                                folio: folio,
                                rutcliente: rutcliente,
                                dvcliente: dvcliente,
                                nombres: nombres,
                                genero: genero,
                                rangoetario: rangoetario,
                                dispavance: dispavanve,
                                ultaefecha: ultaefecha,
                                ultaemonto: ultaemonto,
                                ultaecuotas: ultaecuotas,
                                areafono1: (areafono1 === '' ? 0 : areafono1),
                                areafono2: (areafono2 === '' ? 0 : areafono2),
                                areafono3: (areafono3 === '' ? 0 : areafono3),
                                areafono4: (areafono4 === '' ? 0 : areafono4),
                                grupo: grupo,
                                callcenter: callcenter,
                                fecenvio: fecenvio,
                                filler1: filler1,
                                filler2: filler2,
                                filler3: filler3,
                                filler4: filler4,
                                filler5: filler5,
                                filler6: filler6,
                                color: color,
                                fechavencnexus: fechavencnexus,
                                afinidad: afinidad,
                                fechanac: '',
                                direccion: '',
                                comuna: '',
                                region: '',
                                codigopostal: 0,
                                email: ''
                            };
                            rutero.filas.push(filaRutero);
                            rutero.registros ++;
                        }
                    }
                    RUTERO = rutero;
                    armarTablaRutero(rutero);
                };
                reader.readAsText(file, 'utf8');
            };

            function armarTablaRutero(rutero) {
                var tab = "<table id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'><thead>";
                tab += "<tr>";
                tab += "<th>FOLIO</th>";
                tab += "<th>RUTCLIENTE</th>";
                tab += "<th>DVCLIENTE</th>";
                tab += "<th>NOMBRE</th>";
                tab += "<th>GENERO</th>";
                tab += "<th>RANGOETARIO</th>";
                tab += "<th>DISPAVANCE</th>";
                tab += "<th>ULT AE FECHA</th>";
                tab += "<th>ULT AE MONTO</th>";
                tab += "<th>ULT AE CUOTAS</th>";
                tab += "<th>AREAFONO1</th>";
                tab += "<th>AREAFONO2</th>";
                tab += "<th>AREAFONO3</th>";
                tab += "<th>AREAFONO4</th>";
                tab += "<th>GRUPO</th>";
                tab += "<th>CALLCENTER</th>";
                tab += "<th>FECENVIO</th>";
                tab += "<th>COLOR</th>";
                tab += "<th>FECHA VENC NEXUS</th>";
                tab += "<th>AFINIDAD</th>";
                tab += "</tr>";
                tab += "</thead>";
                tab += "<tbody>";
                $(rutero.filas).each(function (i) {
                    tab += "<tr>";
                    tab += "<td>" + $(this)[0].folio + "</td>";
                    tab += "<td>" + $(this)[0].rutcliente + "</td>";
                    tab += "<td>" + $(this)[0].dvcliente + "</td>";
                    tab += "<td>" + $(this)[0].nombres + "</td>";
                    tab += "<td>" + $(this)[0].genero + "</td>";
                    tab += "<td>" + $(this)[0].rangoetario + "</td>";
                    tab += "<td>" + $(this)[0].dispavance + "</td>";
                    tab += "<td>" + $(this)[0].ultaefecha + "</td>";
                    tab += "<td>" + $(this)[0].ultaemonto + "</td>";
                    tab += "<td>" + $(this)[0].ultaecuotas + "</td>";
                    tab += "<td>" + $(this)[0].areafono1 + "</td>";
                    tab += "<td>" + $(this)[0].areafono2 + "</td>";
                    tab += "<td>" + $(this)[0].areafono3 + "</td>";
                    tab += "<td>" + $(this)[0].areafono4 + "</td>";
                    tab += "<td>" + $(this)[0].grupo + "</td>";
                    tab += "<td>" + $(this)[0].callcenter + "</td>";
                    tab += "<td>" + $(this)[0].fecenvio + "</td>";
                    tab += "<td>" + $(this)[0].color + "</td>";
                    tab += "<td>" + $(this)[0].fechavencnexus + "</td>";
                    tab += "<td>" + $(this)[0].afinidad + "</td>";
                    tab += "</tr>";
                });
                tab += "</tbody></table>";
                
                var tabDetalle = "<table style='border: none; border-collapse: collapse;'><tbody><tr>";
                tabDetalle += "<td>Registros procesados</td>";
                tabDetalle += "<td>" + rutero.registros + "</td>";
                tabDetalle += "</tr></tbody></table>";
                $('#tabla-rutero').html(tabDetalle + "<br />"+ tab);
            }

            $(document).ready(function () {
                cargaSelectCampana();
            });
            function insert() {
                if(validarInsert()){
                    var detalle = {
                        url: 'RuteroController',
                        datos: {
                            tipo: 'ins-rutero',
                            rutero: RUTERO
                        }
                    };
                    insertar(detalle);
                }
            }
            
            function validarInsert(){
                if($('#select-campana').val() === '0' || $('#select-campana').val() === 0){
                    alert('Debe seleccionar una campaña para cargar el rutero.');
                    return false;
                }
                
                var cantidad = 0;
                $('#tab-rutero tbody tr').each(function(){
                    cantidad ++;
                });
                if(cantidad === 0){
                    alert('No existen registros para insertar');
                    return false;
                }
                return true;
            }
            
            function cargaSelectCampana() {
                var idempresa = '<% out.print(session.getAttribute("idempresa"));%>';
                var detalle = {
                    url: 'CampanaController',
                    objetivo: 'select-campana',
                    datos: {
                        tipo: 'select-campanas',
                        idempresa: idempresa
                    }
                };
                cargarSelectParams(detalle);
            }
            
            function limpiar(){
                $('#tabla-rutero').html('');
                $('#select-campana').val('0');
                $('#archivo').val('');
                RUTERO = null;
            }
        </script>
        <div class="container-fluid">
            <br />
            <br />
            <br />
            <div class="row">
                <div class="col-sm-12">
                    <h2>Rutero</h2>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-4">
                    <form>
                        <div class="form-group small">
                            <label for="select-campana">Campaña</label>
                            <select  id="select-campana" class="form-control form-control-sm" >
                            </select>
                        </div>
                        <div class="form-group-small">
                            <label for="archivo">Archivo rutero</label>
                            <input type="file" class="form-control form-control-sm" id="archivo" />
                        </div>
                        <br />
                        <div id='creacion' class="form-group small">
                            <button id="btnInsert" onclick="insert();" type="button" class="btn btn-primary btn-sm">Analizar</button>
                            <button onclick='limpiar();' type="button" class="btn btn-default btn-sm float-right">Limpiar</button>
                        </div>
                    </form>
                </div>
                <div class="col-sm-8">

                    <table id="tabla-productos" class="table table-sm small table-borderless table-hover table-striped">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Descripción</th>
                                <th>Empresa</th>
                                <th>Rut</th>                         
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody id="cuerpo-tab-producto">

                        </tbody>
                    </table>

                </div>
            </div>
            <div class="row">
                <div id="tabla-rutero" class="col-sm-12">

                </div>
            </div>
        </div>
    </body>
</html>
