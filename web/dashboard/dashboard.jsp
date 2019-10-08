<!-- %@include file="../headjava.jsp" % -->
<script type="text/javascript" src="dashboard/dashboard.js?=<% out.print(modelo.Util.generaRandom(10000, 99999));%>" ></script>
<script src='./vue.min.js'></script>
<script src='./d3.v3.min.js'></script>
<script type="text/javascript">

    $(document).ready(function () {
        traerMil(function (obj) {
            console.log(obj);
        });
    });

</script>
<br />
<div class="row">
    <div class="col-sm-4">
        <h3>Estado del servicio</h3>
    </div>
</div>
<div class="row">
    <div class="container">
        <div class='col-sm-12 col-md-4'>
            <div class="panel panel-card">
                <div class="panel-title">
                    <h5 class='no-margin m-b'>CPU Monitor</h5>
                </div>
                <div class="panel-body">
                    <div id="docker-cpu-rect-d3" style="height:280px;"></div>
                </div>
            </div>
        </div>
    </div>
</div>
