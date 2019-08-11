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
	    case "tabla-detalle-ventas-vendedor":
		out.print(tablaDetalleVendedor(entrada));
		break;
	    case "tabla-resumen-ventas-empresa":
		out.print(tablaResumenVentasEmpresa(entrada));
		break;
	    case "tabla-detalle-ventas-empresa":
		out.print(tablaDetalleVentasEmpresa(entrada));
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
    
    private JSONObject tablaDetalleVendedor(JSONObject entrada){
	JSONObject salida = new JSONObject();
	JSONArray ventas = new JSONArray();
	String rutVendedorFull = entrada.getString("rutfullvendedor");
	int rutVendedor = Integer.parseInt(rutVendedorFull.substring(0, rutVendedorFull.length() - 1));
	
	String query = "CALL SP_GET_VENTAS_DETALLE_VENDEDOR(" + rutVendedor + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
	Conexion c = new Conexion();
	c.abrir();
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
		venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
		venta.put("rutfullcliente", rs.getString("RUTCLIENTE") + "-" + rs.getString("DVCLIENTE"));
		venta.put("rutcliente", rs.getString("RUTCLIENTE"));
		venta.put("codproducto", rs.getString("CODPRODUCTO"));
		venta.put("descproducto", rs.getString("DESCPRODUCTO"));
		venta.put("codcampana", rs.getString("CODCAMPANA"));
		venta.put("nomcampana", rs.getString("NOMCAMPANA"));
		venta.put("monto", rs.getInt("MONTO"));
		venta.put("meta", rs.getInt("META"));
		venta.put("cuotas", rs.getInt("CUOTAS"));
		venta.put("empresa", rs.getString("NOMBRE"));
                venta.put("subproductos", rs.getInt("SUBPRODUCTOS"));
		ventas.put(venta);
	    }
	    salida.put("ventas", ventas);
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    salida.put("estado", "error");
	    salida.put("error", ex);
	    System.out.println("No se pudo obtener el detalle de las ventas por vendedor por fecha");
	    System.out.println(ex);
	}
	c.cerrar();
	return salida;
    }
    
    private JSONObject tablaResumenVentasEmpresa(JSONObject entrada){
	JSONObject salida = new JSONObject();
	JSONArray registros = new JSONArray();
	int rutusuario = Integer.parseInt(entrada.getString("rutusuario"));
	String query = "CALL SP_RESUMEN_VENTAS_EMPRESA(" + rutusuario + ")";
	Conexion c = new Conexion();
	c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject registro = new JSONObject();
		registro.put("codproducto", rs.getString("CODPRODUCTO"));
		registro.put("descproducto", rs.getString("DESCPRODUCTO"));
		registro.put("codcampana", rs.getString("CODCAMPANA"));
		registro.put("nomcampana", rs.getString("NOMCAMPANA"));
		registro.put("meta", format.format(rs.getDouble("META")));
		registro.put("montoacum", rs.getInt("MONTOACUM"));
		registro.put("porcacum", rs.getInt("PORCACUM"));
		registro.put("cantidad", rs.getInt("CANTIDAD"));
		registro.put("acumdia", rs.getInt("ACUMDIA"));
                registro.put("fechaini", rs.getDate("FECHAINI"));
                registro.put("fechafin", rs.getDate("FECHAFIN"));
		registros.put(registro);
	    }
	    salida.put("registros", registros);
	    salida.put("estado", "ok");
	}catch (JSONException | SQLException ex) {
	    System.out.println("No se pudo obtener el resumen del mes para la empresa.");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("error", ex);
	}
	c.cerrar();
	return salida;
    }
    
    private JSONObject tablaDetalleVentasEmpresa(JSONObject entrada){
	JSONObject salida = new JSONObject();
	JSONArray ventas = new JSONArray();
	int rutusuario = Integer.parseInt(entrada.getString("rutusuario"));
	String query = "CALL SP_DETALLE_VENTAS_EMPRESA(" + rutusuario + ", '" + entrada.getString("desde") + "', '" + entrada.getString("hasta") + "')";
	Conexion c = new Conexion();
	c.abrir();
        DecimalFormat format = new DecimalFormat("###,###,###,###,###");
	ResultSet rs = c.ejecutarQuery(query);
	try{
	    while(rs.next()){
		JSONObject venta = new JSONObject();
                venta.put("idsimulacion", rs.getInt("IDSIMULACION"));
		venta.put("fechasimulacion", rs.getDate("FECHASIMULACION"));
		venta.put("codcampana", rs.getString("CODCAMPANA"));
		venta.put("nomcampana", rs.getString("NOMCAMPANA"));
		venta.put("codproducto", rs.getString("CODPRODUCTO"));
		venta.put("descproducto", rs.getString("DESCPRODUCTO"));
		venta.put("meta", format.format(rs.getDouble("META")));
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
	}catch (JSONException | SQLException ex) {
	    System.out.println("No se pudo obtener el detalle de las ventas para una empresa.");
	    System.out.println(ex);
	    salida.put("estado", "error");
	    salida.put("estado", ex);
	}
	
	return salida;
    }
}
