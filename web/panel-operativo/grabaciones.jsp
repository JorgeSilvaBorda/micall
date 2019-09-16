<%@include file="../headjava.jsp" %>
<script type="text/javascript" src="panel-operativo/grabaciones.js?=<% out.print(modelo.Util.generaRandom(10000, 99999)); %>" ></script>
<br />
<div class="row">
    <div class="col-sm-4">
        <h3>Grabaciones</h3>
    </div>
</div>

<div class="row">
    <div class="form-group-small">
        <label for="select-campana" >Campaña</label>
        <select onchange="traeDatosCampana();" id="select-campana" class="form-control-sm">

        </select>
    </div>
</div>
<br />
<div class="row">
    <div class="col-sm-9">
        <form>
            <div class="row">
                <div class="col-sm-2">
                    <div class="form-group small">
                        <label for="desde">Fecha Inicio</label> 
                    </div>
                </div>
                <div class="col-sm-2">
                    <div class="form-group small">
                        <label for="hasta">Fecha Fin</label> 
                    </div>
                </div>
                <div class="col-sm-2">
                    <div class="form-group small">
                        <label for="btnBuscar"></label> 
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-2">
                    <div class="form-group small">
                        <input disabled="disabled" type="date" id="desde" class="form-control form-control-sm"/> 
                    </div>
                </div>
                <div class="col-sm-2">
                    <input disabled="disabled" type="date" id="hasta" class="form-control form-control-sm"/> 
                </div>
                <div class="col-sm-2">
                    <div class="form-group small">
                        <button onclick="buscarGrabaciones();" id="btnBuscar" type="button" class="btn btn-success btn-sm">Buscar</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<div class="row">
    <div class="col-sm-12">
        <table class="table" style="font-size: 12px;">
            <thead>
                <tr>
                    <th>ID Llamada</th>
                    <th>Rut</th>
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>Teléfono</th>
                    <th>Resolución</th>
                    <th>Fecha</th>
                    <th>Agente</th>
                    <th>Grabación</th>
                </tr>
            </thead>
            <tbody id="cuerpo-grabaciones">
                
            </tbody>
        </table>
    </div>
</div>
