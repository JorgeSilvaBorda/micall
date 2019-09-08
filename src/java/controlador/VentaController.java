package controlador;

import clases.json.JSONObject;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Conexion;

public class VentaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        switch (entrada.getString("tipo")) {
            case "ins-venta":
                out.print(insVenta(
                        entrada.getInt("idsimulacion"),
                        entrada.getInt("rutcliente"),
                        Integer.parseInt(request.getSession().getAttribute("rutusuario").toString())
                        ));
                break;
            case "del-venta":
                out.print(delVenta(
                        entrada.getInt("idventa"),
                        entrada.getInt("rutcliente"),
                        Integer.parseInt(request.getSession().getAttribute("rutusuario").toString())
                        ));
                break;
        }
    }
    
    private JSONObject insVenta(int idsimulacion, int rutcliente, int rutvendedor){
        String query = "CALL SP_INS_VENTA(" + idsimulacion + ", " + rutcliente + ", " + rutvendedor + ")";
        System.out.println(query);
        Conexion c = new Conexion();
        c.abrir();
        c.ejecutar(query);
        c.cerrar();
        //salida.put("estado", "ok");
        JSONObject salida = new SimulacionController().getSimulacionesRutVendedorRutCliente(rutvendedor, rutcliente);
        return salida;
    }
    
    private JSONObject delVenta(int idventa, int rutcliente, int rutvendedor){
        String query = "CALL SP_DEL_VENTA(" + idventa + ")";
        Conexion c = new Conexion();
        c.abrir();
        c.ejecutar(query);
        c.cerrar();
        JSONObject salida = new SimulacionController().getSimulacionesRutVendedorRutCliente(rutvendedor, rutcliente);
        return salida;
    }

}
