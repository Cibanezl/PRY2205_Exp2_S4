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

--CASO 3

SELECT
    -- 1. Rut y Nombre
    t.numrut AS "RUT Trabajador",
    t.dvrut AS "DV Trabajador",
    t.nombre AS "Nombre Trabajador",
    t.appaterno AS "Ap. Paterno Trabajador",
    t.apmaterno AS "Ap. Materno Trabajador",

    
    TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) AS "Años Antigüedad",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10 THEN '10%'
        ELSE '15%'
    END AS "Porc. Bono Antiguedad",

    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10 THEN ROUND(t.sueldo_base * 0.10)
        ELSE ROUND(t.sueldo_base * 0.15)
    END AS "Monto Bono Antiguedad",

    NVL(i.nombre_isapre, 'N/A') AS "Sistema Salud",
    
    CASE
        WHEN i.nombre_isapre = 'FONASA' THEN ROUND(t.sueldo_base * 0.01)
        ELSE 0
    END AS "Bono Extra",


    (
        
        CASE
            WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12) <= 10 THEN ROUND(t.sueldo_base * 0.10)
            ELSE ROUND(t.sueldo_base * 0.15)
        END
       
        +
        CASE
            WHEN i.nombre_isapre = 'FONASA' THEN ROUND(t.sueldo_base * 0.01)
            ELSE 0
        END
    ) AS "Total Bonificaciones"

FROM
    trabajador t
JOIN
    isapre i ON t.cod_isapre = i.cod_isapre
LEFT JOIN
    est_civil ec ON t.numrut = ec.numrut_t
WHERE
    ec.fecter_estcivil IS NULL OR ec.fecter_estcivil > SYSDATE 
    
ORDER BY
    t.numrut ASC;