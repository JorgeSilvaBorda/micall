package modelo;

import clases.json.JSONObject;

public class Empresa {
    private int id, rut;
    private String dv, nombre, direccion;
    private String creacion, ultModificacion; //String pero serán tratados como date
    
    public Empresa(){
	
    }

    public Empresa(int id, int rut, String dv, String nombre, String direccion, String creacion, String ultModificacion) {
	this.id = id;
	this.rut = rut;
	this.dv = dv;
	this.nombre = nombre;
	this.direccion = direccion;
	this.creacion = creacion;
	this.ultModificacion = ultModificacion;
    }

    public Empresa(int rut, String dv, String nombre, String direccion, String creacion, String ultModificacion) {
	this.rut = rut;
	this.dv = dv;
	this.nombre = nombre;
	this.direccion = direccion;
	this.creacion = creacion;
	this.ultModificacion = ultModificacion;
    }

    public int getId() {
	return id;
    }

    public void setId(int id) {
	this.id = id;
    }

    public int getRut() {
	return rut;
    }

    public void setRut(int rut) {
	this.rut = rut;
    }

    public String getDv() {
	return dv;
    }

    public void setDv(String dv) {
	this.dv = dv;
    }

    public String getNombre() {
	return nombre;
    }

    public void setNombre(String nombre) {
	this.nombre = nombre;
    }

    public String getDireccion() {
	return direccion;
    }

    public void setDireccion(String direccion) {
	this.direccion = direccion;
    }

    public String getCreacion() {
	return creacion;
    }

    public void setCreacion(String creacion) {
	this.creacion = creacion;
    }

    public String getUltModificacion() {
	return ultModificacion;
    }

    public void setUltModificacion(String ultModificacion) {
	this.ultModificacion = ultModificacion;
    }
    
    public JSONObject toJson(){
	JSONObject empresa = new JSONObject();
	empresa.put("idempresa", this.id);
	empresa.put("rutempresa", this.id);
	empresa.put("dvempresa", this.id);
	empresa.put("nombre", this.id);
	empresa.put("direccion", this.id);
	empresa.put("creacion", this.id);
	empresa.put("ultModificacion", this.id);
	return empresa;
    }
    
    public static Empresa fromJsonWithId(JSONObject empresa){
	
	Empresa emp = new Empresa();
	
	emp.setId(empresa.getInt("idempresa"));
	emp.setRut(empresa.getInt("rutempresa"));
	emp.setDv(empresa.getString("dvempresa"));
	emp.setNombre(empresa.getString("nombre"));
	emp.setDireccion(empresa.getString("direccion"));
	emp.setCreacion(empresa.getString("creacion"));
	emp.setUltModificacion(empresa.getString("ultmodificacion"));
	
	return emp;
    }
    
    public static Empresa fromJsonWithoutId(JSONObject empresa){
	
	Empresa emp = new Empresa();
	
	emp.setId(empresa.getInt("idempresa"));
	emp.setRut(empresa.getInt("rutempresa"));
	emp.setDv(empresa.getString("dvempresa"));
	emp.setNombre(empresa.getString("nombre"));
	emp.setDireccion(empresa.getString("direccion"));
	emp.setCreacion(empresa.getString("creacion"));
	emp.setUltModificacion(empresa.getString("ultmodificacion"));
	
	return emp;
    }
}
