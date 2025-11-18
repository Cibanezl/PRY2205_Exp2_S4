-- CASO 1

SELECT INITCAP(nombre) ||
     ' ' ||
    INITCAP(appaterno) ||
     ' ' ||
    INITCAP(apmaterno) AS "Nombre Completo Trabajador",
    TO_CHAR(numrut, '99G999G999') || 
    '-' || 
    dvrut AS "RUT Trabajador",
    INITCAP(c.desc_categoria) AS "Tipo Trabajador",
    INITCAP(ci.nombre_ciudad) AS "Ciudad Trabajador",
    TO_CHAR(sueldo_base, '$99G999G999') AS "Sueldo Base"
FROM trabajador t 
    INNER JOIN tipo_trabajador c 
        ON t.id_categoria_t=c.id_categoria
    INNER JOIN comuna_ciudad ci
        ON t.id_ciudad=ci.id_ciudad
WHERE sueldo_base BETWEEN 650000 AND 3000000        
ORDER BY ci.nombre_ciudad DESC, 
        sueldo_base ASC;
        
--CASO 2
SELECT TO_CHAR(numrut, '99G999G999') || 
    '-' || 
    dvrut AS "RUT Trabajador",
    INITCAP(t.nombre) ||
     ' ' ||
    INITCAP(t.appaterno) ||
     ' ' ||
    INITCAP(t.apmaterno) AS "Nombre Trabajador",
    INITCAP(tc.nro_ticket) AS "Total Tickets",
    TO_CHAR(tc.monto_ticket, '$999G999G999') AS "Total Vendido",
    TO_CHAR(SUM(cc.valor_comision), '$999G999G999') AS "Comisión Total",
    INITCAP(tp.desc_categoria) AS "Tipo Trabajador",
    INITCAP(ci.nombre_ciudad) AS "Ciudad Trabajador"
FROM trabajador t
    INNER JOIN tickets_concierto tc
        ON t.numrut=tc.numrut_t
    INNER JOIN comisiones_ticket cc
        ON tc.nro_ticket=cc.nro_ticket
    INNER JOIN tipo_trabajador tp
        ON t.id_categoria_t=tp.id_categoria
    INNER JOIN comuna_ciudad ci
        ON t.id_ciudad=ci.id_ciudad   
WHERE UPPER(tp.desc_categoria) = 'CAJERO'        
GROUP BY 
    t.numrut, t.dvrut, t.nombre,
    t.appaterno, t.apmaterno,
    tc.nro_ticket, tc.monto_ticket, 
    tp.desc_categoria,
    ci.nombre_ciudad
HAVING SUM(tc.monto_ticket) > 50000
ORDER BY SUM(tc.monto_ticket) DESC;