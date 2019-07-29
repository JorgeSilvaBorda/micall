class Empresa{
    
    setId(id){
        this.id = id;
    }
    setRut(rut){
        this.rutempresa = rut;
    }
    setDv(dv){
        this.dvempresa = dv;
    }
    setNombre(nombre){
        this.nombre = nombre;
    }
    setDireccion(direccion){
        this.direccion = direccion;
    }
    setCreacion(creacion){
        this.creacion = creacion;
    }
    setUltModificacion(ultmodificacion){
        this.ultmodificacion = ultmodificacion;
    }
    
    constructor(rut, dv, nombre, direccion){
        this.rutempresa = rut;
        this.dvempresa = dv;
        this.nombre = nombre;
        this.direccion = direccion;
    }
    
    toJsonString(){
        return JSON.stringify(toObject());
    }
    
    toObject(){
        var emp = {
            id: this.id,
            rutempresa: this.rutempresa,
            dvempresa: this.dvempresa,
            nombre: this.nombre,
            direccion: this.direccion,
            creacion: this.creacion,
            ultmodificacion: this.ultmodificacion
        };
        return emp;
    }
}

class Producto{
    
}