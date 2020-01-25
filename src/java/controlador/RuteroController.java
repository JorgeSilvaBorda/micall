package controlador;

import clases.json.JSONObject;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Iterator;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import modelo.Conexion;
import org.apache.tomcat.util.http.fileupload.disk.DiskFileItemFactory;
import org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload;

@WebServlet("/upload")
@MultipartConfig
public class RuteroController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        JSONObject entrada = new JSONObject(request.getParameter("datos"));
        PrintWriter out = response.getWriter();
        response.setContentType("text/html; charset=UTF-8");
        //System.out.println(entrada);
        switch (entrada.getString("tipo")) {
            case "ins-rutero":
                out.print(insRutero(entrada.getString("contenido"), entrada.getInt("idusuario"), entrada.getInt("idcampana"), entrada.getString("nomarchivo")));
                break;
            case "traer-ruteros-empresa":
                out.print(traerRuterosEmpresa(entrada.getInt("rutempresa")));
                break;
            case "del-rutero":
                out.print(delRutero(entrada.getString("contenido"), entrada.getInt("idusuario"), entrada.getInt("idcampana"), entrada.getString("nomarchivo")));
                break;
            case "valida-ins-rutero":
                out.print(procesaContenidoRutero(entrada));
                break;
            case "valida-del-rutero":
                out.print(procesaContenidoRuteroEliminacion(entrada));
                break;
            default:
                break;
        }

    }

    private JSONObject insRutero(String contenido, int idusuario, int idcampana, String nomarchivo) {
        String[] filas = contenido.split("\r\n");
        JSONObject ruteroid = getIdNewRutero();
        JSONObject salida = new JSONObject();
        if (ruteroid.getInt("idrutero") == 0) {
            salida.put("estado", "error");
            salida.put("mensaje", "No se puede obtener el ID de Rutero");
            return salida;
        }

        int cont = 0;
        for (int i = 1; i < filas.length; i++) {
            String[] fila = filas[i].split(";");
            if (procesarFila(filas[i])) {
                String query = "CALL SP_INS_FILA_RUTERO("
                        + idcampana + ","
                        + fila[0] + ","
                        + "'" + fila[1] + "',"
                        + "'" + fila[2] + "',"
                        + "'" + fila[3] + "',"
                        + "'" + fila[4] + "',"
                        + "'" + fila[5] + "',"
                        + "'" + fila[6] + "',"
                        + "'" + fila[7] + "',"
                        + "'" + fila[8] + "',"
                        + fila[9] + ","
                        + "'" + fila[10] + "',"
                        + fila[11] + ","
                        + fila[12] + ","
                        + fila[13] + ","
                        + fila[14] + ","
                        + "'" + nomarchivo + "',"
                        + "'INS',"
                        + idusuario + ","
                        + ruteroid.getInt("idrutero") + ")";
                Conexion c = new Conexion();
                c.abrir();
                c.ejecutar(query);
                c.cerrar();
                cont ++;
                System.out.println("Ingresados: " + cont);
            }

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

    private JSONObject delRutero(String contenido, int idusuario, int idcampana, String nomarchivo) {
        JSONObject ruteroid = getIdNewRutero();
        JSONObject salida = new JSONObject();
        if (ruteroid.getInt("idrutero") == 0) {
            salida.put("estado", "error");
            salida.put("mensaje", "No se puede obtener el ID de Rutero");
            return salida;
        }
        /*
        Iterator i = rutero.getJSONArray("filas").iterator();
        while (i.hasNext()) {
            JSONObject fila = (JSONObject) i.next();
            String query = "CALL SP_DEL_FILA_RUTERO("
                    + idcampana + ","
                    + fila.getInt("rutcliente") + ","
                    + "'" + nomarchivo + "',"
                    + "'DEL',"
                    + idusuario + ","
                    + ruteroid.getInt("idrutero") + ")";
            Conexion c = new Conexion();
            c.abrir();
            c.ejecutar(query);
            c.cerrar();
        }
        */
        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject getIdNewRutero() {
        String query = "CALL SP_GET_ID_RUTERO()";
        Conexion c = new Conexion();
        c.abrir();
        JSONObject salida = new JSONObject();
        ResultSet rs = c.ejecutarQuery(query);
        try {
            while (rs.next()) {
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

    private JSONObject procesaContenidoRutero(JSONObject entrada) {
        //Generar archivo con el contenido--------------------------------------
        String RUTA_DEFAULT = "RUTERO.csv"; // [EN DURO] !!!! Corregir. Parametrizar en .properties 
        File newRutero = new File(RUTA_DEFAULT);
        //String nomarchivo = entrada.getString("nomarchivo");
        String[] filas = entrada.getString("contenido").split("\r\n");
        int filasProcesadas = 0;
        int filasBuenas = 0;
        int filasMalas = 0;
        //for (String fila : filas) {
        for (int i = 1; i < filas.length; i++) {
            String fila = filas[i];

            //System.out.println(fila);
            if (procesarFila(fila)) {
                filasBuenas++;
            } else {
                System.out.println("Fila: " + (filasProcesadas + 2));
                filasMalas++;
            }
            filasProcesadas++;
        }

        //System.out.println(filas);
        JSONObject salida = new JSONObject();
        salida.put("filasBuenas", filasBuenas);
        salida.put("filasMalas", filasMalas);
        salida.put("filasProcesadas", filasProcesadas);
        salida.put("estado", "ok");
        return salida;
    }

    private JSONObject procesaContenidoRuteroEliminacion(JSONObject entrada) {
        //Generar archivo con el contenido--------------------------------------
        String RUTA_DEFAULT = "RUTERO.csv"; // [EN DURO] !!!! Corregir. Parametrizar en .properties 
        File newRutero = new File(RUTA_DEFAULT);
        //String nomarchivo = entrada.getString("nomarchivo");
        String[] filas = entrada.getString("contenido").split("\r\n");
        int filasProcesadas = 0;
        int filasBuenas = 0;
        int filasMalas = 0;
        //for (String fila : filas) {
        for (int i = 1; i < filas.length; i++) {
            String fila = filas[i];

            //System.out.println(fila);
            if (procesarFilaEliminacion(fila)) {
                filasBuenas++;
            } else {
                System.out.println("Fila: " + (filasProcesadas + 2));
                filasMalas++;
            }
            filasProcesadas++;
        }

        //System.out.println(filas);
        JSONObject salida = new JSONObject();
        salida.put("filasBuenas", filasBuenas);
        salida.put("filasMalas", filasMalas);
        salida.put("filasProcesadas", filasProcesadas);
        salida.put("estado", "ok");
        System.out.println(salida);
        return salida;
    }

    private boolean procesarFila(String fila) {

        //System.out.println(campos.length);
        //[VALIDACIONES]--------------------------------------------------------
        try {
            String[] campos = fila.split(";");
            //Validar Largo --------------------------------------------------------
            if (campos.length < 19) {
                System.out.println("Largo invalido");
                return false;
            }
            //valida largo campo rut -----------------------------------------------
            if (campos[0].length() < 7 || campos[0].length() > 8) {
                System.out.println("Largo de rut invalido. Largo encontrado: " + campos[0].length());
                return false;
            }
            //Valida campo rut numérico --------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("Rut no numérico");
                return false;
            }
            //Valida dv ------------------------------------------------------------
            if (!new modelo.Util().validarRut(campos[0].concat(campos[1]))) {
                System.out.println("Rut inválido");
                return false;
            }
            //Validar largo campo nombres ------------------------------------------
            if (campos[2].length() < 2) {
                System.out.println("Largo de nombres < 2");
                return false;
            }
            //Validar largo campo apellidos ----------------------------------------
            if (campos[3].length() < 2) {
                System.out.println("Largo de apellidos < 2");
                return false;
            }
            //validar fono1 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[12]);
            } catch (NumberFormatException ex) {
                System.out.println("fono1 no numérico");
                return false;
            }
            //validar fono2 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[13]);
            } catch (NumberFormatException ex) {
                System.out.println("fono2 no numérico");
                return false;
            }
            //validar fono3 numérico -------------------------------------------
            try {
                Integer.parseInt(campos[14]);
            } catch (NumberFormatException ex) {
                System.out.println("fono3 no numérico");
                return false;
            }
            //Validar largo de fono1 -----------------------------------------------
            if ((campos[12]).trim().length() != 9) {
                System.out.println("Largo de fono1 debe ser de 9");
            }
            //Validar largo de fono2 -----------------------------------------------
            if ((campos[13]).trim().length() != 9) {
                System.out.println("Largo de fono2 debe ser de 9");
            }
            //Validar largo de fono3 -----------------------------------------------
            if ((campos[14]).trim().length() != 9) {
                System.out.println("Largo de fono3 debe ser de 9");
            }
        } catch (Exception ex) {
            System.out.println("Error al validar la fila:");
            System.out.println(ex);
            return false;
        }

        return true;
    }

    private boolean procesarFilaEliminacion(String fila) {

        //System.out.println(campos.length);
        //[VALIDACIONES]--------------------------------------------------------
        try {
            String[] campos = fila.split(";");
            //Validar Largo --------------------------------------------------------
            if (campos.length < 19) {
                System.out.println("Largo invalido");
                return false;
            }
            //valida largo campo rut -----------------------------------------------
            if (campos[0].length() < 7 || campos[0].length() > 8) {
                System.out.println("Largo de rut invalido. Largo encontrado: " + campos[0].length());
                return false;
            }
            //Valida campo rut numérico --------------------------------------------
            try {
                int rut = Integer.parseInt(campos[0]);
            } catch (NumberFormatException ex) {
                System.out.println("Rut no numérico");
                return false;
            }
            //Valida dv ------------------------------------------------------------
            if (!new modelo.Util().validarRut(campos[0].concat(campos[1]))) {
                System.out.println("Rut inválido");
                return false;
            }
        } catch (Exception ex) {
            System.out.println("Error al validar la fila:");
            System.out.println(ex);
            return false;
        }

        return true;
    }

}
