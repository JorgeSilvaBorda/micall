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
            case "carga-tab-resumen-simulaciones-vendedor":
                out.print(cargaTablaResumenSimulacionesVendedor(entrada.getString("rutfullvendedor")));
                break;
            case "carga-tab-resumen-ventas-vendedor":
                out.print(cargaTablaResumenVentasVendedor(entrada.getString("rutfullvendedor")));
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
            case "bbdd":
                out.print(bbdd(entrada.getInt("idcampana")));
                break;
            case "resultante":
                out.print(resultante(entrada.getInt("idcampana")));
                break;
            case "grabaciones":
                out.print(grabaciones(entrada.getInt("idcampana")));
                break;
            case "ejecutivos":
                out.print(ejecutivos(entrada.getInt("idcampana")));
                break;
            default:
                break;
        }
    }

    private JSONObject cargaTablaResumenSimulacionesVendedor(String rutfullvendedor) {
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

    private JSONObject cargaTablaResumenVentasVendedor(String rutfullvendedor) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        int rutvendedor = Integer.parseInt(rutfullvendedor.substring(0, rutfullvendedor.length() - 1));
        String query = "CALL SP_RESUMEN_MES_VENTAS_VENDEDOR(" + rutvendedor + ")";
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

    private JSONObject tablaResumenVentasEmpresa(int idempresa) {
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
        } catch (JSONException | SQLException e) {
            System.out.println("Problemas en ReportesControler.tablaResumenVentasEmpresa()");
            System.out.println(e);
            salida.put("estado", "error");
            salida.put("error", e);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject bbdd(int idcampana) {
        JSONObject salida = new JSONObject();
        JSONArray registros = new JSONArray();
        String query = "CALL SP_GET_REPORTE_BBDD_DIA(" + idcampana + ", NOW())";
        Conexion c = new Conexion();
        c.abrir();
        JSONArray cabeceras = new JSONArray();

        ResultSet rs = c.ejecutarQuery(query);
        String fechaini = "";
        String fechafin = "";
        try {
            fechaini = rs.getMetaData().getColumnName(3);
            int len = rs.getMetaData().getColumnCount();
            fechafin = rs.getMetaData().getColumnName(len);
        } catch (Exception ex) {
            System.out.println("No se puede obtener fechaini fechafin");
            System.out.println(ex);
        }

        try {
            for (int i = 1; i < rs.getMetaData().getColumnCount() + 1; i++) {
                cabeceras.put(i, rs.getMetaData().getColumnName(i));
            }
        } catch (Exception ex) {
            System.out.println("No se pueden mapear las cabeceras");
            System.out.println(ex);
        }

        try {
            while (rs.next()) {
                JSONObject registro = new JSONObject();
                for (int i = 1; i < rs.getMetaData().getColumnCount() + 1; i++) {
                    registro.put(rs.getMetaData().getColumnName(i), rs.getObject(rs.getMetaData().getColumnName(i)));
                }
                registros.put(registro);
            }
            salida.put("estado", "ok");
            salida.put("registros", registros);
            salida.put("fechaini", fechaini);
            salida.put("fechafin", fechafin);
            salida.put("cabeceras", cabeceras);

        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject resultante(int idcampana) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_REPORTE_RESULTANTE_2(" + idcampana + ")";
        System.out.println(query);
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        String cuerpo = "";
        int cont = 0;
        try {
            while (rs.next()) {
                cont++;
            }
        } catch (Exception ex) {
            System.out.println("No se puede obtener la cuenta de filas");
            System.out.println(ex);
        }

        try {
            rs.beforeFirst();
            while (rs.next()) {
                if (rs.getInt("uniqueid") > 0) {
                    cuerpo += "<tr>";
                    cuerpo += "<td>" + rs.getInt("uniqueid") + "</td>";
                    cuerpo += "<td>" + modelo.Util.formatRut(rs.getString("vendor_lead_code")) + "</td>";
                    cuerpo += "<td>" + rs.getInt("phone_number") + "</td>";
                    cuerpo += "<td>" + rs.getString("status_name") + "</td>";
                    //cuerpo += "<td>" + rs.getString("SEQUENCE") + (!rs.getString("comments").equals("") ? ">" + rs.getString("comments") : "") + "</td>";
                    cuerpo += "<td>" + rs.getString("comments") + "</td>";
                    cuerpo += "<td>" + rs.getDate("FECHA") + "</td>";
                    cuerpo += "<td>" + rs.getString("user") + "</td>";
                    cuerpo += "<td>" + rs.getInt("length_in_sec") + "</td>";
                    cuerpo += "<td>" + rs.getString("HORAINI") + "</td>";
                    cuerpo += "<td>" + rs.getString("HORAFIN") + "</td>";
                    cuerpo += "</tr>";
                }

            }
            salida.put("estado", "ok");
            salida.put("filas", cont);
            salida.put("cuerpo", cuerpo);
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject grabaciones(int idcampana) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_RECORDINGS_IDCAMPANA_2(" + idcampana + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        String cuerpo = "";
        int registros = 0;
        try {
            while (rs.next()) {
                cuerpo += "<tr>";
                cuerpo += "<td>" + rs.getInt("uniqueid") + "</td>";
                cuerpo += "<td>" + rs.getString("vendor_lead_code") + "</td>";
                cuerpo += "<td>" + rs.getString("first_name") + "</td>";
                cuerpo += "<td>" + rs.getString("last_name") + "</td>";
                cuerpo += "<td>" + rs.getInt("phone_number") + "</td>";
                cuerpo += "<td>" + rs.getString("ESTADOLLAMADO") + "</td>";
                cuerpo += "<td>" + rs.getDate("FECHAHORAINI") + "</td>";
                cuerpo += "<td>" + rs.getString("USER") + "</td>";
                String enlace = "<a href='" + rs.getString("location") + "' download>Descargar</a>";
                cuerpo += "<td>" + enlace + "</td>";
                cuerpo += "</tr>";
                registros ++;
            }
            salida.put("estado", "ok");
            salida.put("registros", registros);
            salida.put("cuerpo", cuerpo);
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }

    private JSONObject ejecutivos(int idcampana) {
        JSONObject salida = new JSONObject();
        String query = "CALL SP_GET_REPORTE_EJECUTIVOS(" + idcampana + ")";
        Conexion c = new Conexion();
        c.abrir();
        ResultSet rs = c.ejecutarQuery(query);
        String cuerpo = "";
        DecimalFormat format = new DecimalFormat("###,###,###.##");
        int registros = 0;
        try {
            while (rs.next()) {
                cuerpo += "<tr>";

                cuerpo += "<td>" + rs.getString("NOMBRESEJECUTIVO") + "</td>";
                // cuerpo += "<td>" + modelo.Util.formatRut(rs.getString("RUTEJECUTIVO")) + "</td>";
                cuerpo += "<td>" + rs.getString("RUTEJECUTIVO") + "</td>";
                cuerpo += "<td>" + rs.getInt("VENTAS") + "</td>";
                cuerpo += "<td>" + rs.getInt("LLAMADAS") + "</td>";
                cuerpo += "<td>" + rs.getString("PRIMCONEXION") + "</td>";
                cuerpo += "<td>" + rs.getInt("LOGINTIME") + "</td>";
                cuerpo += "<td>" + rs.getInt("TMOESPERA") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PORCTMOESPERA")) + "%</td>";
                cuerpo += "<td>" + rs.getInt("TMOLLAMADA") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PORCTMOLLAMADA")) + "%</td>";
                cuerpo += "<td>" + rs.getInt("TMOREGISTROLLAMADA") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PORCTMOREGISTROLLAMADA")) + "%</td>";
                cuerpo += "<td>" + rs.getInt("TMOPAUSE") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PORCTMOPAUSE")) + "%</td>";
                cuerpo += "<td>" + rs.getInt("TMOMUERTO") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PORCTMOMUERTO")) + "%</td>";
                cuerpo += "<td>" + rs.getInt("TMOHABLCLIENTE") + "</td>";
                cuerpo += "<td>" + format.format(rs.getDouble("PRODUCTIVIDAD")) + "%</td>";

                cuerpo += "</tr>";
                
                registros ++;
            }
            salida.put("estado", "ok");
            salida.put("registros", registros);
            salida.put("cuerpo", cuerpo);
        } catch (JSONException | SQLException ex) {
            salida.put("estado", "error");
            System.out.println(ex);
        }
        c.cerrar();
        return salida;
    }
}
