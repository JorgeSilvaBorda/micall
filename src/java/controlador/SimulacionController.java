package controlador;

import clases.json.JSONException;
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

public class SimulacionController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        switch (entrada.getString("tipo")) {
            case "ins-simulacion":
                out.print(insSimulacion(entrada.getJSONObject("simulacion")));
                break;
            case "get-simulaciones-rutvendedor":
                out.print(getSimulacionesRutVendedor(entrada.getInt("rutvendedor")));
                break;
        }
    }

    private JSONObject insSimulacion(JSONObject simulacion) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_INS_SIMULACION("
                + simulacion.getInt("idcampana") + ","
                + simulacion.getInt("rutvendedor") + ","
                + "'" + simulacion.getString("dvvendedor") + "',"
                + simulacion.getInt("rutcliente") + ","
                + "'" + simulacion.getString("dvcliente") + "',"
                + simulacion.getInt("monto") + ","
                + simulacion.getInt("cuotas") + ","
                + simulacion.getInt("valorcuota") + ","
                + simulacion.getBigDecimal("tasainteres") + ","
                + simulacion.getBigDecimal("tasaanual") + ","
                + simulacion.getBigDecimal("cae") + ","
                + "'" + simulacion.getString("vencimiento") + "',"
                + simulacion.getInt("costototal") + ","
                + simulacion.getInt("comision") + ")";
        Conexion c = new Conexion();
        c.abrir();
        int liid = 0;
        ResultSet rs = c.ejecutarQuery(query);
        try{
            while(rs.next()){
                liid = rs.getInt("LIID");
            }
            
            if(liid == 0){
                salida.put("estado", "error");
                salida.put("mensaje", "No se pudo insertar la simulación.");
                c.cerrar();
                return salida;
            }
            
        }catch (JSONException | SQLException ex) {
            System.out.println("Problemas en modelo.SimulacionController.insSimulacion()");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();
        
        Iterator i = simulacion.getJSONArray("subproductos").iterator();
        while(i.hasNext()){
            JSONObject subproducto = (JSONObject)i.next();
            query = "CALL SP_INS_SIMULACION_SUBPRODUCTO("
                    + liid + ","
                    + subproducto.getInt("idsubproducto") + ")";
            Conexion conn = new Conexion();
            conn.abrir();
            conn.ejecutar(query);
            conn.cerrar();
        }
        
        salida.put("estado", "ok");
        salida.put("idsimulacion", liid);
        return salida;
    }
    
    private JSONObject getSimulacionesRutVendedor(int rutvendedor){
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_SIMULACIONES_RUTVENDEDOR(" + rutvendedor + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        int filas = 0;
        String cuerpo = "";
        try{
            while(rs.next()){
                cuerpo += "<tr>";
                cuerpo += "<td>" + rs.getDate("FECHASIMULACION") + "</td>";
                cuerpo += "<td>" + rs.getString("RUTCLIENTE") + "-" + rs.getString("DVCLIENTE") + "</td>";
                cuerpo += "<td>" + rs.getString("NOMBRESCLIENTE") + " " + rs.getString("APELLIDOSCLIENTE") + "</td>";
                cuerpo += "<td>" + rs.getString("CODPRODUCTO") + "</td>";
                cuerpo += "<td>" + rs.getString("DESCPRODUCTO") + "</td>";
                cuerpo += "<td>" + rs.getInt("MONTO") + "</td>";
                cuerpo += "<td>" + rs.getInt("CUOTAS") + "</td>";
                cuerpo += "<td>" + rs.getInt("SUBPRODUCTOS") + "</td>";
                cuerpo += "</tr>";
                filas ++;
            }
            if(filas > 0){
                salida.put("cuerpotabla", cuerpo);
            }
            salida.put("estado", "ok");
        }catch (JSONException | SQLException ex) {
            System.out.println("Problemas en SimulacionController.getSimulacionesRutVendedor()");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();

        return salida;
    }
}
