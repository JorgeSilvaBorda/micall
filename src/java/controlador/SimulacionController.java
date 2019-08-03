package controlador;

import clases.json.JSONObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.ResultSet;
import modelo.Conexion;

public class SimulacionController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	switch(entrada.getString("tipo")){
	    case "get-campana-empresa-rutcliente":
		//out.print(getCampanaEmpresaRutcliente(entrada.getInt("rutcliente"), entrada.getInt("idempresa")));
		break;
	}
    }
}
