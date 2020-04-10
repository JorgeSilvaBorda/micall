package controlador;

import clases.json.JSONArray;
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
import java.text.DecimalFormat;
import java.util.Iterator;
import modelo.Conexion;

public class SimulacionController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        System.out.println("Entrada");
        System.out.println(entrada);
        switch (entrada.getString("tipo")) {
            case "ins-simulacion":
                out.print(insSimulacion(entrada.getJSONObject("simulacion")));
                break;
            case "get-simulaciones-rutvendedor-rutcliente":
                out.print(getSimulacionesRutVendedorRutCliente(entrada.getInt("rutvendedor"), entrada.getInt("rutcliente")));
                break;
            case "get-subproductos-simulacion":
                out.print(getSubproductosSimulacion(entrada.getInt("idsimulacion")));
                break;
            case "get-id-grupo":
                out.print(newGrupoSimulacion());
                break;
        }
    }

    private JSONObject newGrupoSimulacion() {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_INS_GRUPO_SIMULACION()";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        int LIID = 0;
        try {
            while (rs.next()) {
                LIID = rs.getInt("LIID");
            }
            salida.put("liid", LIID);
            System.out.println("New Grupo: ");
            System.out.println(salida);
        } catch (Exception ex) {
            System.out.println("Problemas");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("liid", -1);
        }
        c.cerrar();
        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject insSimulacion(JSONObject simulacion) {
        System.out.println(simulacion);
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
                + simulacion.getInt("comision") + ","
                //+ simulacion.getInt("impuesto") + ")";
                + simulacion.getInt("impuesto") + ","
                + simulacion.getBigInteger("idgrupo") + ")";
        Conexion c = new Conexion();
        c.abrir();
        int liid = 0;
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                liid = rs.getInt("LIID");
            }

            if (liid == 0) {
                salida.put("estado", "error");
                salida.put("mensaje", "No se pudo insertar la simulación.");
                c.cerrar();
                return salida;
            }

        } catch (JSONException | SQLException ex) {
            System.out.println("Problemas en modelo.SimulacionController.insSimulacion()");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();

        Iterator i = simulacion.getJSONArray("subproductos").iterator();
        while (i.hasNext()) {
            JSONObject subproducto = (JSONObject) i.next();
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

    public JSONObject getSimulacionesRutVendedorRutCliente(int rutvendedor, int rutcliente) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_SIMULACIONES_RUTVENDEDOR_RUTCLIENTE(" + rutvendedor + ", " + rutcliente + ")";
        System.out.println(query);
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        int filas = 0;
        String cuerpo = "";
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        DecimalFormat decimales = new DecimalFormat("###,###.##");
        try {
            while (rs.next()) {
                String filaSubs = "<td>" + rs.getInt("SUBPRODUCTOS") + "</td>";
                if (rs.getInt("SUBPRODUCTOS") > 0) {
                    filaSubs = "<td>" + rs.getInt("SUBPRODUCTOS") + " <a href='#' onclick='verSubproductosVendidos(" + rs.getInt("IDSIMULACION") + ");'>Detalle</a></td>";
                }
                String botones = "";
                if (rs.getInt("IDVENTA") != -1) {
                    cuerpo += "<tr class='table-success'>";
                    botones = "<td style='font-size: 10px;'><div id='botones' class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"First group\">\n"
                            + "    <button style='font-size: 10px;' type=\"button\" class=\"btn btn-success\">Vender</button>\n"
                            + "    <button onclick='marcarme(\"" + rs.getInt("IDVENTA") + "\", \"quitar\"); 'style='font-size: 10px;' type=\"button\" class=\"btn btn-secondary\">Quitar</button>\n"
                            + "  </div></td>";
                } else {
                    cuerpo += "<tr>";
                    botones = "<td style='font-size: 10px;'><div id='botones' class=\"btn-group btn-group-sm\" role=\"group\" aria-label=\"First group\">\n"
                            + "    <button onclick='marcarme(\"" + rs.getInt("IDSIMULACION") + "\", \"vender\");' style='font-size: 10px;' type=\"button\" class=\"btn btn-secondary\">Vender</button>\n"
                            + "    <button style='font-size: 10px;' type=\"button\" class=\"btn btn-danger\">Quitar</button>\n"
                            + "  </div></td>";
                }
                cuerpo += "<td>[" + rs.getString("CODPRODUCTO") + "] " + rs.getString("DESCPRODUCTO") + "</td>";
                cuerpo += "<td>$ " + format.format(rs.getInt("MONTO")) + "</td>";
                cuerpo += "<td>" + rs.getInt("CUOTAS") + "</td>";
                cuerpo += "<td>$ " + format.format(rs.getInt("VALORCUOTA")) + "</td>";
                cuerpo += "<td>$ " + format.format(rs.getInt("IMPUESTO")) + "</td>";
                cuerpo += "<td>$ " + format.format(rs.getInt("COSTOTOTAL")) + "</td>";
                cuerpo += "<td>" + decimales.format(rs.getDouble("TASAINTERES")) + " %</td>";
                cuerpo += "<td>" + decimales.format(rs.getDouble("CAE")) + " %</td>";
                cuerpo += filaSubs;
                cuerpo += botones;
                cuerpo += "</tr>";
                filas++;
            }
            if (filas > 0) {
                salida.put("cuerpotabla", cuerpo);
            }
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("Problemas en SimulacionController.getSimulacionesRutVendedor()");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();

        return salida;
    }

    private JSONObject getSubproductosSimulacion(int idsimulacion) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_SUBPRODUCTOS_SIMULACION(" + idsimulacion + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        JSONArray subproductos = new JSONArray();
        DecimalFormat format = new DecimalFormat("###,###,###");
        try {
            while (rs.next()) {
                JSONObject sub = new JSONObject();
                sub.put("idsimulacion", rs.getInt("IDSIMULACION"));
                sub.put("idsubproducto", rs.getInt("IDSUBPRODUCTO"));
                sub.put("idempresa", rs.getInt("IDEMPRESA"));
                sub.put("codsubproducto", rs.getString("CODSUBPRODUCTO"));
                sub.put("descsubproducto", rs.getString("DESCSUBPRODUCTO"));
                sub.put("prima", Double.toString(rs.getDouble("PRIMA")));
                sub.put("montometa", rs.getInt("MONTOMETA"));
                sub.put("montoseguro", format.format(rs.getInt("MONTOSEGURO")));
                sub.put("cantidadmeta", rs.getInt("CANTIDADMETA"));
                subproductos.put(sub);
            }
            salida.put("subproductos", subproductos);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("Problemas en modelo.SimlacionController.getSubproductosSimulacion()");
            System.out.println(ex);
            salida = new JSONObject();
            salida.put("estado", "error");
            salida.put("mensaje", ex);
        }
        c.cerrar();
        return salida;
    }
}
