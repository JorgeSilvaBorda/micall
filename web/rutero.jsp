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

                            var rutcliente = linea[0];
                            var dvcliente = linea[1];
                            var nombres = linea[2];
                            var apellidos = linea[3];
                            var genero = linea[4];
                            var fechaNacInt = linea[5].toString();
                            var fechanac = fechaNacInt;
                            var direccion = linea[6];
                            var comuna = linea[7];
                            var region = linea[8];
                            var codigopostal = linea[9];
                            var email = linea[10];
                            var montoaprobado = linea[11];
                            var fono1 = parseInt(linea[12]);
                            var fono2 = parseInt(linea[13]);
                            var fono3 = parseInt(linea[14]);

                            var filaRutero = {
                                rutcliente: parseInt(rutcliente),
                                dvcliente: dvcliente,
                                nombres: nombres,
                                apellidos: apellidos,
                                genero: genero,
                                fechanac: fechanac,
                                direccion: direccion.replaceAll("'", "''"),
                                comuna: comuna,
                                region: region,
                                codigopostal: parseInt(codigopostal),
                                email: email,
                                montoaprobado: montoaprobado,
                                fono1: fono1,
                                fono2: fono2,
                                fono3: fono3
                            };
                            rutero.filas.push(filaRutero);
                            rutero.registros ++;
                        }
                    }
                    RUTERO = rutero;
                    armarTablaRutero(rutero);
                };
                reader.readAsText(file, 'UTF-8');
            };

            function armarTablaRutero(rutero) {
                var tab = "<table id='tab-rutero' class='table table-sm small table-striped table-condensed table-hover'><thead>";
                tab += "<tr>";
                tab += "<th>RUTCLIENTE</th>";
                tab += "<th>DVCLIENTE</th>";
                tab += "<th>NOMBRES</th>";
                tab += "<th>APELLIDOS</th>";
                tab += "<th>GENERO</th>";
                tab += "<th>FECHANAC</th>";
                tab += "<th>DIRECCION</th>";
                tab += "<th>COMUNA</th>";
                tab += "<th>REGION</th>";
                tab += "<th>COD. POSTAL</th>";
                tab += "<th>EMAIL</th>";
                tab += "<th>MONTOAPROBADO</th>";
                tab += "<th>FONO1</th>";
                tab += "<th>FONO2</th>";
                tab += "<th>FONO3</th>";
                tab += "</tr>";
                tab += "</thead>";
                tab += "<tbody>";
                $(rutero.filas).each(function (i) {
                    tab += "<tr>";
                    tab += "<td>" + $(this)[0].rutcliente + "</td>";
                    tab += "<td>" + $(this)[0].dvcliente + "</td>";
                    tab += "<td>" + $(this)[0].nombres + "</td>";
                    tab += "<td>" + $(this)[0].apellidos + "</td>";
                    tab += "<td>" + $(this)[0].genero + "</td>";
                    tab += "<td>" + fechaIntToString($(this)[0].fechanac) + "</td>";
                    tab += "<td>" + $(this)[0].direccion + "</td>";
                    tab += "<td>" + $(this)[0].comuna + "</td>";
                    tab += "<td>" + $(this)[0].region + "</td>";
                    tab += "<td>" + $(this)[0].codigopostal + "</td>";
                    tab += "<td>" + $(this)[0].email + "</td>";
                    tab += "<td>$ " + formatMiles($(this)[0].montoaprobado) + "</td>";
                    tab += "<td>" + $(this)[0].fono1 + "</td>";
                    tab += "<td>" + $(this)[0].fono2 + "</td>";
                    tab += "<td>" + $(this)[0].fono3 + "</td>";
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
                    insertar(detalle, function(obj){
                        
                    });
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
                            <button id="btnInsert" onclick="insert();" type="button" class="btn btn-primary btn-sm">Ingresar</button>
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
