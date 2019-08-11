package modelo;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Util {

    public static int generaRandom(int ini, int fin) {
	return (int) Math.floor(Math.random() * (fin - ini + 1) + ini);
    }

    public static String hashMD5(String texto) {
	try {
	    MessageDigest md = MessageDigest.getInstance("MD5");
	    byte[] hashInBytes = md.digest(texto.getBytes(StandardCharsets.UTF_8));

	    StringBuilder sb = new StringBuilder();
	    for (byte b : hashInBytes) {
		sb.append(String.format("%02x", b));
	    }
	    return sb.toString();
	} catch (NoSuchAlgorithmException ex) {
	    System.out.println("Problemas al cifrar el mensaje");
	    System.out.println(ex);
	    return "";
	}

    }

    public static String armarSelect(ResultSet rs, String primerItemValue, String primerItemText, String colValues, String colTextos) {
	String salida = "<option value='" + primerItemValue + "'>" + primerItemText + "</option>";
	try {
	    while (rs.next()) {
		salida += "<option value='" + rs.getString(colValues) + "'>" + rs.getString(colTextos) + "</option>";
	    }
	} catch (SQLException ex) {
	    System.out.println("No se puede armar el select.");
	    System.out.println(ex);
	}
	return salida;
    }

    public static float redondearDecimales(float numero, int cantDecimales) {
	BigDecimal bd = new BigDecimal(Float.toString(numero));
	bd = bd.setScale(cantDecimales, BigDecimal.ROUND_HALF_UP);
	return bd.floatValue();
    }

    public static BigDecimal redondear(float numero, int cantDecimales) {
	BigDecimal bd = new BigDecimal(Float.toString(numero));
	bd = bd.setScale(cantDecimales, BigDecimal.ROUND_HALF_UP);
	return bd;
    }

    public static String formatRut(String rut) {

	int cont = 0;
	String format;
	rut = rut.replace(".", "");
	rut = rut.replace("-", "");
	format = "-" + rut.substring(rut.length() - 1);
	for (int i = rut.length() - 2; i >= 0; i--) {
	    format = rut.substring(i, i + 1) + format;
	    cont++;
	    if (cont == 3 && i != 0) {
		format = "." + format;
		cont = 0;
	    }
	}
	return format;
    }
    
    public static String formatMiles(String numero){
	StringBuilder builder = new StringBuilder();
	for(int i = 1, len = builder.length();	i < len; i++){
	    if(i % 4 == 0){
		builder.insert(len = builder.length() - i, '.');
		len = builder.length();
	    }
	}
	return builder.toString();
    }
    
}
