package controlador;

import clases.json.JSONObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Iterator;
import modelo.Conexion;

public class RuteroController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        switch (entrada.getString("tipo")) {
            case "ins-rutero":
                out.print(insRutero(entrada.getJSONObject("rutero"), entrada.getInt("idusuario")));
                break;
            case "traer-ruteros-empresa":
                out.print(traerRuterosEmpresa(entrada.getInt("rutempresa")));
                break;
            case "del-rutero":
                out.print(delRutero(entrada.getJSONObject("rutero"), entrada.getInt("idusuario")));
                break;
            default:
                break;
        }
    }

    private JSONObject insRutero(JSONObject rutero, int idusuario) {
        JSONObject ruteroid = getIdNewRutero();
        JSONObject salida = new JSONObject();
        if(ruteroid.getInt("idrutero") == 0){
            salida.put("estado", "error");
            salida.put("mensaje", "No se puede obtener el ID de Rutero");
            return salida;
        }
        
        int idcampana = rutero.getInt("idcampana");
        Iterator i = rutero.getJSONArray("filas").iterator();
        while (i.hasNext()) {
            JSONObject fila = (JSONObject) i.next();
            String query = "CALL SP_INS_FILA_RUTERO("
                    + idcampana + ","
                    + fila.getInt("rutcliente") + ","
                    + "'" + fila.getString("dvcliente") + "',"
                    + "'" + fila.getString("nombres") + "',"
                    + "'" + fila.getString("apellidos") + "',"
                    + "'" + fila.getString("genero") + "',"
                    + "'" + fila.getString("fechanac") + "',"
                    + "'" + fila.getString("direccion") + "',"
                    + "'" + fila.getString("comuna") + "',"
                    + "'" + fila.getString("region") + "',"
                    + fila.getInt("codigopostal") + ","
                    + "'" + fila.getString("email") + "',"
                    + fila.getInt("montoaprobado") + ","
                    + fila.getInt("fono1") + ","
                    + fila.getInt("fono2") + ","
                    + fila.getInt("fono3") + ","
                    + "'" + rutero.getString("nomarchivo") + "',"
                    + "'INS',"
                    + idusuario + ","
                    + ruteroid.getInt("idrutero") + ")";
            Conexion c = new Conexion();
            c.abrir();
            c.ejecutar(query);
            c.cerrar();
        }

        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject traerRuterosEmpresa(int rutempresa) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_RUTEROS_EMPRESA(" + rutempresa + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        String tab = "<table id='tabla-ruteros-empresa' class='table table-sm small table-borderless table-hover table-striped'><thead>";
        tab += "<tr>";
        tab += "<th>Fecha Carga</th>";
        tab += "<th>Campaña</th>";
        tab += "<th>Registros</th>";
        tab += "<th>Archivo</th>";
        tab += "<th>Tipo Operación</th>";
        tab += "</tr></thead><tbody>";
        try {
            while (rs.next()) {
                tab += "<tr>";
                tab += "<td>" + rs.getDate("FECHACARGA") + "</td>";
                tab += "<td>[" + rs.getString("CODCAMPANA") + "] " + rs.getString("NOMCAMPANA") + "</td>";
                tab += "<td>" + rs.getInt("CANT") + "</td>";
                tab += "<td>" + rs.getString("NOMARCHIVO") + "</td>";
                tab += "<td>" + rs.getString("DESCOPERACION") + "</td>";
                tab += "</tr>";
            }
            salida.put("tabla", tab);
            salida.put("estado", "ok");
        } catch (SQLException ex) {
            System.out.println("Problemas en modelo.RuteroController.traerRuterosEmpresa()");
            System.out.println(ex);
            salida = new JSONObject();
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject delRutero(JSONObject rutero, int idusuario) {
        JSONObject ruteroid = getIdNewRutero();
        JSONObject salida = new JSONObject();
        if(ruteroid.getInt("idrutero") == 0){
            salida.put("estado", "error");
            salida.put("mensaje", "No se puede obtener el ID de Rutero");
            return salida;
        }
        int idcampana = rutero.getInt("idcampana");
        Iterator i = rutero.getJSONArray("filas").iterator();
        while (i.hasNext()) {
            JSONObject fila = (JSONObject) i.next();
            String query = "CALL SP_DEL_FILA_RUTERO("
                    + idcampana + ","
                    + fila.getInt("rutcliente") + ","
                    + "'" + rutero.getString("nomarchivo") + "',"
                    + "'DEL',"
                    + idusuario + ","
                    + ruteroid.getInt("idrutero") + ")";
            Conexion c = new Conexion();
            c.abrir();
            c.ejecutar(query);
            c.cerrar();
        }
        salida.put("estado", "ok");
        return salida;
    }
    
    private JSONObject getIdNewRutero(){
        String query = "CALL SP_GET_ID_RUTERO()";
        Conexion c = new Conexion();
        c.abrir();
        JSONObject salida = new JSONObject();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while(rs.next()){
                salida.put("idrutero", rs.getInt("IDRUTERO"));
                salida.put("fechacreacion", rs.getDate("FECHACREACION"));
            }
            return salida;
        } catch (SQLException ex) {
            System.out.println("No se pudo obtener el IDRUTERO");
            System.out.println(ex);
            salida.put("fechacreacion", "1900-01-01");
            salida.put("idrutero", 0);
        }
        c.cerrar();
        return salida;
    }

}
