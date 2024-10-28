package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.modelo.Grado;
import com.edu.pe.modelo.Seccion;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SeccionDAO {

    private static final Logger logger = LoggerFactory.getLogger(SeccionDAO.class);

    private Connection connection;

    public SeccionDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public List<Seccion> ListarSeccionPorGrado(int idGrado) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param id Grado: {}", methodName, idGrado);

        List<Seccion> lista = new ArrayList<>();

        String sql = "select * from seccion s where id_grado = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, idGrado);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Seccion obj = new Seccion();
                obj.setIdSeccion(rs.getInt("id_seccion"));
                obj.setIdGrado(rs.getInt("id_grado"));
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
