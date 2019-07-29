package modelo;

public class Producto {
    private int id;
    private String codigo, descripcion;
    private Empresa empresa;

    public Producto(int id, String codigo, String descripcion, Empresa empresa) {
	this.id = id;
	this.codigo = codigo;
	this.descripcion = descripcion;
	this.empresa = empresa;
    }

    public Producto(String codigo, String descripcion, Empresa empresa) {
	this.codigo = codigo;
	this.descripcion = descripcion;
	this.empresa = empresa;
    }

    public int getId() {
	return id;
    }

    public void setId(int id) {
	this.id = id;
    }

    public String getCodigo() {
	return codigo;
    }

    public void setCodigo(String codigo) {
	this.codigo = codigo;
    }

    public String getDescripcion() {
	return descripcion;
    }

    public void setDescripcion(String descripcion) {
	this.descripcion = descripcion;
    }

    public Empresa getEmpresa() {
	return empresa;
    }

    public void setEmpresa(Empresa empresa) {
	this.empresa = empresa;
    }
    
    
}
