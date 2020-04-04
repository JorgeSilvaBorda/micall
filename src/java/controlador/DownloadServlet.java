package controlador;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class DownloadServlet extends HttpServlet {

    private static final String RUTA_PROPERTIES = System.getenv("PANEL_PROPERTIES");
    private static String RUTA_LOGS_RUTEROS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // Parametrización ruta de archivos-------------------------------------
        try {
            InputStream inStream = new FileInputStream(RUTA_PROPERTIES);
            Properties prop = new Properties();
            prop.load(inStream);
            RUTA_LOGS_RUTEROS = prop.getProperty("dir.ruteros.logs.linux");
            //----------------------------------------------------------------------
            String nomarchivo = request.getParameter("nomarchivo");
            File archivo = new File(RUTA_LOGS_RUTEROS + File.separator + nomarchivo);
            ServletOutputStream outServlet = response.getOutputStream();
            String mimeType = "application/octet-stream";
            FileInputStream fis = new FileInputStream(archivo);
            byte[] buffer = new byte[4096];
            int length;

            while ((length = fis.read(buffer)) > 0) {
                outServlet.write(buffer, 0, length);
            }

            fis.close();
            response.addHeader("Content-Disposition", "attachment; filename=" + nomarchivo);
            response.setHeader("Content-Length", Integer.toString(length));
            response.setContentType(mimeType);
        } catch (IOException ex) {
            System.out.println("No se puede obtener el log de la carga de rutero");
            System.out.println(ex);
        }

    }

}
