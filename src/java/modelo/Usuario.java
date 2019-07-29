package modelo;

public class Usuario {
    
    private int id, rut, estado;
    private String dv, nombre, appaterno, apmaterno;
    private String ultModificacion; //String pero será tratado como date
    private TipoUsuario tipoUsuario;
    private Empresa empresa;

    public Usuario(int id, int rut, int estado, String dv, String nombre, String appaterno, String apmaterno, String ultModificacion, TipoUsuario tipoUsuario, Empresa empresa) {
	this.id = id;
	this.rut = rut;
	this.estado = estado;
	this.dv = dv;
	this.nombre = nombre;
	this.appaterno = appaterno;
	this.apmaterno = apmaterno;
	this.ultModificacion = ultModificacion;
	this.tipoUsuario = tipoUsuario;
	this.empresa = empresa;
    }

    public Usuario(int rut, int estado, String dv, String nombre, String appaterno, String apmaterno, String ultModificacion, TipoUsuario tipoUsuario, Empresa empresa) {
	this.rut = rut;
	this.estado = estado;
	this.dv = dv;
	this.nombre = nombre;
	this.appaterno = appaterno;
	this.apmaterno = apmaterno;
	this.ultModificacion = ultModificacion;
	this.tipoUsuario = tipoUsuario;
	this.empresa = empresa;
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

    public int getEstado() {
	return estado;
    }

    public void setEstado(int estado) {
	this.estado = estado;
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

    public String getAppaterno() {
	return appaterno;
    }

    public void setAppaterno(String appaterno) {
	this.appaterno = appaterno;
    }

    public String getApmaterno() {
	return apmaterno;
    }

    public void setApmaterno(String apmaterno) {
	this.apmaterno = apmaterno;
    }

    public String getUltModificacion() {
	return ultModificacion;
    }

    public void setUltModificacion(String ultModificacion) {
	this.ultModificacion = ultModificacion;
    }

    public TipoUsuario getTipoUsuario() {
	return tipoUsuario;
    }

    public void setTipoUsuario(TipoUsuario tipoUsuario) {
	this.tipoUsuario = tipoUsuario;
    }

    public Empresa getEmpresa() {
	return empresa;
    }

    public void setEmpresa(Empresa empresa) {
	this.empresa = empresa;
    }
    
}
