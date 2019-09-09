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
import modelo.Conexion;

public class ReportesController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");

        JSONObject entrada = new JSONObject((String) request.getParameter("datos"));
        switch (entrada.getString("tipo")) {
            case "carga-tab-resumen-vendedor":
                out.print(cargaTablaResumenVendedor(entrada.getString("rutfullvendedor")));
                break;
            case "tabla-detalle-simulaciones-vendedor":
                out.print(tablaDetalleSimulacionesVendedor(entrada));
                break;
                case "tabla-detalle-ventas-vendedor":
                out.print(tablaDetalleVentasVendedor(entrada));
                break;
            case "tabla-resumen-simulaciones-empresa":
                out.print(tablaResumenSimulacionesEmpresa(entrada));
                break;
            case "tabla-resumen-simulaciones-empresa-dia":
                out.print(tablaResumenSimulacionesEmpresaDia(entrada));
                break;
            case "tabla-detalle-simulaciones-empresa":
                out.print(tablaDetalleSimulacionesEmpresa(entrada));
                break;
                case "tabla-detalle-ventas-empresa":
                out.print(tablaDetalleVentasEmpresa(entrada));
                break;
            case "tabla-resumen-ventas-empresa-dia":
                out.print(tablaResumenVentasEmpresaDia(entrada.getInt("idempresa")));
                break;
            case "tabla-resumen-venta-empresa":
                out.print(tablaResumenVentasEmpresa(entrada.getInt("idempresa")));
                break;
            default:
                break;
        }
    }

    private JSONObject cargaTablaResumenVendedor(String rutfullvendedor) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        int rutvendedor = Integer.parseInt(rutfullvendedor.substring(0, rutfullvendedor.length() - 1));
        String query = "CALL SP_RESUMEN_MES_VENDEDOR(" + rutvendedor + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                registro.put("codcampana", rs.getString("CODCAMPANA"));
                registro.put("nomcampana", rs.getString("NOMCAMPANA"));
                registro.put("codproducto", rs.getString("CODPRODUCTO"));
                registro.put("descproducto", rs.getString("DESCPRODUCTO"));
                registro.put("nomempresa", rs.getString("NOMEMPRESA"));
                registro.put("montoacum", rs.getInt("ACUMMES"));
                //registro.put("porcacum", Util.redondear(rs.getFloat("PORCACUM"), 2));
                registro.put("cantidad", rs.getInt("CANTIDAD"));
                registros.put(registro);
            }
            salida.put("registros", registros);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            salida.put("mensaje", ex);
            System.out.println("No se pudo obtener el resumen de ventas del mes por vendedor");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject tablaDetalleSimulacionesVendedor(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray ventas = new JSONArray();
        String rutVendedorFull = entrada.getString("rutfullvendedor");
        int rutVendedor = Integer.parseInt(rutVendedorFull.substring(0, rutVendedorFull.length() - 1));
        String query = "CALL SP_GET_SIMULACIONES_DETALLE_VENDEDOR(" + rutVendedor + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
                venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
                venta.put("rutfullcliente", rs.getString("RUTCLIENTE") + "-" + rs.getString("DVCLIENTE"));
                venta.put("rutcliente", rs.getString("RUTCLIENTE"));
                venta.put("codproducto", rs.getString("CODPRODUCTO"));
                venta.put("descproducto", rs.getString("DESCPRODUCTO"));
                venta.put("codcampana", rs.getString("CODCAMPANA"));
                venta.put("nomcampana", rs.getString("NOMCAMPANA"));
                venta.put("monto", format.format(rs.getDouble("MONTO")));
                venta.put("meta", format.format(rs.getDouble("META")));
                venta.put("cuotas", rs.getInt("CUOTAS"));
                venta.put("empresa", rs.getString("NOMBRE"));
                venta.put("subproductos", rs.getInt("SUBPRODUCTOS"));
                ventas.put(venta);
            }
            salida.put("ventas", ventas);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            salida.put("error", ex);
            System.out.println("No se pudo obtener el detalle de las ventas por vendedor por fecha");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }
    
    private JSONObject tablaDetalleVentasVendedor(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray ventas = new JSONArray();
        String rutVendedorFull = entrada.getString("rutfullvendedor");
        int rutVendedor = Integer.parseInt(rutVendedorFull.substring(0, rutVendedorFull.length() - 1));
        String query = "CALL SP_GET_VENTAS_DETALLE_VENDEDOR(" + rutVendedor + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
                venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
                venta.put("rutfullcliente", rs.getString("RUTCLIENTE") + "-" + rs.getString("DVCLIENTE"));
                venta.put("rutcliente", rs.getString("RUTCLIENTE"));
                venta.put("codproducto", rs.getString("CODPRODUCTO"));
                venta.put("descproducto", rs.getString("DESCPRODUCTO"));
                venta.put("codcampana", rs.getString("CODCAMPANA"));
                venta.put("nomcampana", rs.getString("NOMCAMPANA"));
                venta.put("monto", format.format(rs.getDouble("MONTO")));
                venta.put("meta", format.format(rs.getDouble("META")));
                venta.put("cuotas", rs.getInt("CUOTAS"));
                venta.put("empresa", rs.getString("NOMBRE"));
                venta.put("subproductos", rs.getInt("SUBPRODUCTOS"));
                ventas.put(venta);
            }
            salida.put("ventas", ventas);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            salida.put("error", ex);
            System.out.println("No se pudo obtener el detalle de las ventas por vendedor por fecha");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject tablaResumenSimulacionesEmpresa(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        int rutusuario = Integer.parseInt(entrada.getString("rutusuario"));
        String query = "CALL SP_RESUMEN_SIMULACIONES_EMPRESA(" + rutusuario + ", NULL)";
        Conexion c = new Conexion();
        c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        DecimalFormat decimales = new DecimalFormat("###,###.##");
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                registro.put("fechaini", rs.getDate("FECHAINI"));
                registro.put("fechafin", rs.getDate("FECHAFIN"));
                registro.put("codcampana", rs.getString("CODCAMPANA"));
                registro.put("nomcampana", rs.getString("NOMCAMPANA"));
                registro.put("codproducto", rs.getString("CODPRODUCTO"));
                registro.put("descproducto", rs.getString("DESCPRODUCTO"));
                //registro.put("metaproducto", format.format(rs.getDouble("META")));
                registro.put("metaproducto", rs.getDouble("META"));
                //registro.put("acumproducto", format.format(rs.getDouble("ACUM")));
                registro.put("acumproducto", rs.getDouble("ACUM"));

                registro.put("porcacumprod", decimales.format(rs.getDouble("PORCACUM")));
                registro.put("simulaciones", rs.getInt("SIMULACIONES"));
                registro.put("codsubproducto", rs.getString("CODSUBPRODUCTO"));
                registro.put("descsubproducto", rs.getString("DESCSUBPRODUCTO"));
                //registro.put("metasubproducto", format.format(rs.getDouble("MONTOMETA")));
                registro.put("metasubproducto", rs.getDouble("MONTOMETA"));
                //registro.put("acumsubproducto", format.format(rs.getDouble("ACUMMES")));
                registro.put("acumsubproducto", rs.getDouble("ACUMMES"));
                registro.put("porcacumsubprod", decimales.format(rs.getDouble("PORCACUMMES")));
                registro.put("cantidadmeta", rs.getInt("CANTIDADMETA"));
                registro.put("cantidadmes", rs.getInt("CANTMES"));
                registro.put("prima", decimales.format(rs.getDouble("PRIMA")));
                registros.put(registro);
            }
            salida.put("registros", registros);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se pudo obtener el resumen del mes para la empresa.");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("error", ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject tablaResumenSimulacionesEmpresaDia(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        int rutusuario = Integer.parseInt(entrada.getString("rutusuario"));
        String query = "CALL SP_RESUMEN_SIMULACIONES_EMPRESA(" + rutusuario + ", '" + entrada.getString("fechahoy") + "')";
        Conexion c = new Conexion();
        c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        DecimalFormat decimales = new DecimalFormat("###,###.##");
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                registro.put("fechaini", rs.getDate("FECHAINI"));
                registro.put("fechafin", rs.getDate("FECHAFIN"));
                registro.put("codcampana", rs.getString("CODCAMPANA"));
                registro.put("nomcampana", rs.getString("NOMCAMPANA"));
                registro.put("codproducto", rs.getString("CODPRODUCTO"));
                registro.put("descproducto", rs.getString("DESCPRODUCTO"));
                registro.put("metaproducto", rs.getDouble("META"));
                registro.put("acumproducto", rs.getDouble("ACUM")); //Al día de hoy
                registro.put("porcacumprod", decimales.format(rs.getDouble("PORCACUM")));
                registro.put("simulaciones", rs.getInt("SIMULACIONES"));
                registro.put("codsubproducto", rs.getString("CODSUBPRODUCTO"));
                registro.put("descsubproducto", rs.getString("DESCSUBPRODUCTO"));
                registro.put("metasubproducto", rs.getDouble("MONTOMETA"));
                registro.put("acumsubproducto", rs.getDouble("ACUMDIASUBPROD")); //Acumulado al día
                registro.put("porcacumsubprod", decimales.format(rs.getDouble("PORCACUMMES")));
                registro.put("cantidadmeta", rs.getInt("CANTIDADMETA"));
                registro.put("cantidadmes", rs.getInt("CANTMES")); //Campo corresponde en esta ejecución al día, no al mes
                registro.put("prima", decimales.format(rs.getDouble("PRIMA")));
                registros.put(registro);
            }
            salida.put("registros", registros);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se pudo obtener el resumen del mes para la empresa al día de hoy.");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("error", ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject tablaResumenVentasEmpresaDia(int idempresa) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        String query = "CALL SP_RESUMEN_VENTAS_EMPRESA_DIA(" + idempresa + ")";
        Conexion c = new Conexion();
        c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        DecimalFormat decimales = new DecimalFormat("###,###.##");
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                registro.put("fechaini", rs.getDate("FECHAINI"));
                registro.put("fechafin", rs.getDate("FECHAFIN"));
                registro.put("codcampana", rs.getString("CODCAMPANA"));
                registro.put("nomcampana", rs.getString("NOMCAMPANA"));
                registro.put("codproducto", rs.getString("CODPRODUCTO"));
                registro.put("descproducto", rs.getString("DESCPRODUCTO"));
                registro.put("metaproducto", rs.getDouble("META"));
                registro.put("acumproducto", rs.getDouble("ACUMPRODDIA")); //Al día de hoy
                registro.put("porcacumprod", decimales.format(rs.getDouble("PORCACUMDIA")));
                registro.put("simulaciones", rs.getInt("SIMULACIONESDIA"));
                registro.put("codsubproducto", rs.getString("CODSUBPRODUCTO"));
                registro.put("descsubproducto", rs.getString("DESCSUBPRODUCTO"));
                registro.put("metasubproducto", rs.getDouble("MONTOMETA"));
                registro.put("acumsubproducto", rs.getDouble("ACUMDIA")); //Acumulado al día
                registro.put("porcacumsubprod", decimales.format(rs.getDouble("PORCACUMDIA")));
                registro.put("cantidadmeta", rs.getInt("CANTIDADMETA"));
                registro.put("cantidadmes", rs.getInt("CANTDIA")); //Campo corresponde en esta ejecución al día, no al mes
                registro.put("prima", decimales.format(rs.getDouble("PRIMA")));
                registros.put(registro);
            }
            salida.put("registros", registros);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se pudo obtener el resumen del mes para la empresa al día de hoy.");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("error", ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject tablaDetalleSimulacionesEmpresa(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray ventas = new JSONArray();
        String query = "CALL SP_DETALLE_SIMULACIONES_EMPRESA(" + entrada.getInt("idempresa") + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
        Conexion c = new Conexion();
        c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
                venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
                venta.put("codcampana", rs.getString("CODCAMPANA"));
                venta.put("nomcampana", rs.getString("NOMCAMPANA"));
                venta.put("codproducto", rs.getString("CODPRODUCTO"));
                venta.put("descproducto", rs.getString("DESCPRODUCTO"));
                venta.put("meta", rs.getDouble("META"));
                venta.put("monto", rs.getInt("MONTO"));
                venta.put("rutfullcliente", rs.getString("RUTFULLCLIENTE"));
                venta.put("rutfullvendedor", rs.getString("RUTFULLVENDEDOR"));
                venta.put("cuotas", rs.getInt("CUOTAS"));
                venta.put("valorcuota", rs.getInt("VALORCUOTA"));
                venta.put("subproductos", rs.getInt("SUBPRODUCTOS"));
                ventas.put(venta);
            }
            salida.put("ventas", ventas);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se pudo obtener el detalle de las ventas para una empresa.");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("estado", ex);
        }

        return salida;
    }
    
    private JSONObject tablaDetalleVentasEmpresa(JSONObject entrada) {
        JSONObject salida = new JSONObject();
        JSONArray ventas = new JSONArray();
        String query = "CALL SP_DETALLE_VENTAS_EMPRESA(" + entrada.getInt("idempresa") + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
        Conexion c = new Conexion();
        c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
                JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
                venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
                venta.put("codcampana", rs.getString("CODCAMPANA"));
                venta.put("nomcampana", rs.getString("NOMCAMPANA"));
                venta.put("codproducto", rs.getString("CODPRODUCTO"));
                venta.put("descproducto", rs.getString("DESCPRODUCTO"));
                venta.put("meta", rs.getDouble("META"));
                venta.put("monto", rs.getInt("MONTO"));
                venta.put("rutfullcliente", rs.getString("RUTFULLCLIENTE"));
                venta.put("rutfullvendedor", rs.getString("RUTFULLVENDEDOR"));
                venta.put("cuotas", rs.getInt("CUOTAS"));
                venta.put("valorcuota", rs.getInt("VALORCUOTA"));
                venta.put("subproductos", rs.getInt("SUBPRODUCTOS"));
                ventas.put(venta);
            }
            salida.put("ventas", ventas);
            salida.put("estado", "ok");
        } catch (JSONException | SQLException ex) {
            System.out.println("No se pudo obtener el detalle de las ventas para una empresa.");
            System.out.println(ex);
            salida.put("estado", "error");
            salida.put("estado", ex);
        }

        return salida;
    }
    
    private JSONObject tablaResumenVentasEmpresa(int idempresa){
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        String query = "CALL SP_RESUMEN_VENTAS_EMPRESA_MES(" + idempresa + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
        DecimalFormat decimales = new DecimalFormat("###,###.##");
        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                registro.put("fechaini", rs.getDate("FECHAINI"));
                registro.put("fechafin", rs.getDate("FECHAFIN"));
                registro.put("codcampana", rs.getString("CODCAMPANA"));
                registro.put("nomcampana", rs.getString("NOMCAMPANA"));
                registro.put("codproducto", rs.getString("CODPRODUCTO"));
                registro.put("descproducto", rs.getString("DESCPRODUCTO"));
                registro.put("metaproducto", rs.getDouble("META"));
                registro.put("acumproducto", rs.getDouble("ACUMPROD"));
                registro.put("porcacumprod", decimales.format(rs.getDouble("PORCACUM")));
                registro.put("simulaciones", rs.getInt("SIMULACIONES"));
                registro.put("codsubproducto", rs.getString("CODSUBPRODUCTO"));
                registro.put("descsubproducto", rs.getString("DESCSUBPRODUCTO"));
                registro.put("metasubproducto", rs.getDouble("MONTOMETA"));
                registro.put("acumsubproducto", rs.getDouble("ACUMMES"));
                registro.put("porcacumsubprod", decimales.format(rs.getDouble("PORCACUMMES")));
                registro.put("cantidadmeta", rs.getInt("CANTIDADMETA"));
                registro.put("cantidadmes", rs.getInt("CANTMES"));
                registro.put("prima", decimales.format(rs.getDouble("PRIMA")));
                registros.put(registro);
            }
            salida.put("registros", registros);
            salida.put("estado", "ok");
        }catch(JSONException | SQLException e){
            System.out.println("Problemas en ReportesControler.tablaResumenVentasEmpresa()");
            System.out.println(e);
            salida.put("estado", "error");
            salida.put("error", e);
        }
        c.cerrar();
        return salida;
    }
}
