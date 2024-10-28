package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.Grado;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GradoDAO {

    private static final Logger logger = LoggerFactory.getLogger(GradoDAO.class);

    private Connection connection;

    public GradoDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<Grado> ListarGradoPorProf(int idProf, int idPeriodo) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: : {}", methodName);

        List<Grado> lista = new ArrayList<>();

        String sql = "select * from seccion s\n"
                + "inner join grado g on g.id_grado = s.id_grado\n"
                + "where id_seccion in (select id_seccion from curso_profesor where id_profesor = ?)\n"
                + "and s.id_periodo = ?\n"
                + "order by nivel asc , nro asc";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idProf);
            ps.setInt(2, idPeriodo);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Grado obj = new Grado();
                obj.setIdGrado(rs.getInt("id_grado"));
                obj.setNivel(rs.getString("nivel"));
                obj.setNro(rs.getInt("nro"));
                obj.setLetra(rs.getString("letra"));
                obj.setIdSeccion(rs.getInt("id_seccion"));
                lista.add(obj);
            }

            logger.info("Método: {}, Data: {}", methodName, JsonUtil.toJsonValueAsString(lista));
            logger.info("Método: {}, Cantidad: {}", methodName, lista.size());
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return lista;
    }

}
