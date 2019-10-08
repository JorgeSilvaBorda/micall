package controlador;

import clases.json.JSONArray;
import clases.json.JSONException;
import clases.json.JSONObject;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Conexion;

public class DashboardController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        switch (entrada.getString("tipo")) {
            case "repo-snapshot":
                out.print(repoSnapshot());
                break;
            case "repo":
                out.print(repo());
                break;
            default:
                break;
        }
    }

    private JSONObject repoSnapshot() {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_REPO_SERVER_SNAPSHOT()";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                salida.put("fechahora", rs.getString("FECHAHORA"));
                salida.put("ipservidor", rs.getString("IPSERVIDOR"));
                salida.put("sysload", rs.getString("SYSLOAD"));
                salida.put("freeram", rs.getString("FREERAM"));
                salida.put("usedram", rs.getString("USEDRAM"));
                salida.put("processes", rs.getString("PROCESSES"));
                salida.put("channelstotal", rs.getString("CHANNELSTOTAL"));
                salida.put("trunktotal", rs.getString("TRUNKTOTAL"));
                salida.put("clientstotal", rs.getString("CLIENTSTOTAL"));
                salida.put("clientszap", rs.getString("CLIENTSZAP"));
                salida.put("clientsiax", rs.getString("CLIENTSIAX"));
                salida.put("clientslocal", rs.getString("CLIENTSLOCAL"));
                salida.put("clientssip", rs.getString("CLIENTSSIP"));
                salida.put("liverecordings", rs.getString("LIVERECORDINGS"));
                salida.put("cpuuserpercent", rs.getString("CPUUSERPERCENT"));
                salida.put("cpuidlepercent", rs.getString("CPUIDLEPERCENT"));
                salida.put("diskreads", rs.getString("DISKREADS"));
                salida.put("diskwrites", rs.getString("DISKWRITES"));
            }
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se puede obtener el snapshot del estado del server");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("error", ex);
        }
        return salida;
    }
    
    private JSONObject repo() {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_REPO_SERVER()";
        JSONObject fila;
        JSONArray filas = new JSONArray();
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        
        try {
            while (rs.next()) {
                fila = new JSONObject();
                fila.put("fechahora", rs.getString("FECHAHORA"));
                fila.put("ipservidor", rs.getString("IPSERVIDOR"));
                fila.put("sysload", rs.getString("SYSLOAD"));
                fila.put("freeram", rs.getString("FREERAM"));
                fila.put("usedram", rs.getString("USEDRAM"));
                fila.put("processes", rs.getString("PROCESSES"));
                fila.put("channelstotal", rs.getString("CHANNELSTOTAL"));
                fila.put("trunktotal", rs.getString("TRUNKTOTAL"));
                fila.put("clientstotal", rs.getString("CLIENTSTOTAL"));
                fila.put("clientszap", rs.getString("CLIENTSZAP"));
                fila.put("clientsiax", rs.getString("CLIENTSIAX"));
                fila.put("clientslocal", rs.getString("CLIENTSLOCAL"));
                fila.put("clientssip", rs.getString("CLIENTSSIP"));
                fila.put("liverecordings", rs.getString("LIVERECORDINGS"));
                fila.put("cpuuserpercent", rs.getString("CPUUSERPERCENT"));
                fila.put("cpuidlepercent", rs.getString("CPUIDLEPERCENT"));
                fila.put("diskreads", rs.getString("DISKREADS"));
                fila.put("diskwrites", rs.getString("DISKWRITES"));
                filas.put(fila);
            }
            salida.put("estado", "ok");
            salida.put("registros", filas);
        } catch (JSONException | SQLException ex) {
            System.out.println("No se puede obtener el reporte del estado del server");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("error", ex);
        }
        return salida;
    }

}
