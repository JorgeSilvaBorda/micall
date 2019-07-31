package controlador;

import clases.json.JSONArray;
import clases.json.JSONObject;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.Iterator;

public class CampanaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	JSONObject entrada = new JSONObject(request.getParameter("datos"));
	PrintWriter out = response.getWriter();
	response.setContentType("text/html; charset=UTF-8");
	switch (entrada.getString("tipo")) {
	    case "get-campanas":
		out.print(getCampanas());
		break;
	    case "ins-campanasubproducto":
		out.print(insCampanaSubProducto(entrada.getJSONObject("campana")));
		break;
	    case "del-campana":
		out.print(delCampana(entrada.getInt("idcampana")));
		break;
	    default:
		break;
	}
    }

    private JSONObject getCampanas() {
	JSONObject salida = new JSONObject();
	return salida;
    }
    private JSONObject insCampanaSubProducto(JSONObject campana) {
	JSONObject salida = new JSONObject();
	JSONArray subproductos = campana.getJSONArray("subproductos");
	System.out.println("Campaña");
	System.out.println(campana);
	Iterator i = subproductos.iterator();
	while(i.hasNext()){
	    JSONObject subproducto = (JSONObject) i.next();
	    System.out.println("Subproducto: ");
	    System.out.println(subproducto);
	}
	return salida;
    }
    private JSONObject delCampana(int idcampana) {
	JSONObject salida = new JSONObject();
	return salida;
    }
}
