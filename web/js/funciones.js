var OPCIONES_DATATABLES = {
    "language": {
        "lengthMenu": "Mostrar _MENU_ registros por página",
        "zeroRecords": "Nada encontrado",
        "info": "Mostrando página _PAGE_ de _PAGES_",
        "infoEmpty": "No records available",
        "infoFiltered": "(filtered from _MAX_ total records)",
        "paginate": {
            "previous": "Anterior",
            "next": "Siguiente"
        },
        "search": "Buscar"
    },
    "paging": true,
    "ordering": true,
    "drawCallback": function () {
        $('.dataTables_paginate > .pagination').addClass('pagination-sm');
    }
};

String.prototype.replaceAll = function (search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

function getDateHoy(sep) {
    var today = new Date();
    var mes = ((today.getMonth() + 1) < 10 ? '0' + (today.getMonth() + 1) : today.getMonth() + 1);
    var dia = (today.getDate() < 10 ? '0' + today.getDate() : today.getDate());
    var date = today.getFullYear() + sep + mes + sep + dia;
    return date;
}

function formatMilesInput(input) {
    var num = input.value.replace(/\./g, "");
    if (!isNaN(num)) {
        num = num.toString().split("").reverse().join("").replace(/(?=\d*\.?)(\d{3})/g, '$1.');
        num = num.split("").reverse().join("").replace(/^[\.]/, "");
        input.value = num;
    } else {
        input.value = input.value.replace(/[^\d\.]*/g, "");
    }
}

function formatMiles(valor){
    valor = valor.toString();
    var num = valor.replace(/\./g, "");
    if(!isNaN(num)){
        num = num.toString().split("").reverse().join("").replace(/(?=\d*\.?)(\d{3})/g, '$1.');
        num = num.split("").reverse().join("").replace(/^[\.]/, "");
        return num;
    }else{
        console.log("No se puede formatear.");
        valor = valor.replace(/[^\d\.]*/g, "");
        return valor;
    }
}
