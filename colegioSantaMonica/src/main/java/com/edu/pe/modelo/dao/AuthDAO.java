package com.edu.pe.modelo.dao;

import com.edu.pe.config.Conexion;
import com.edu.pe.dto.UsuarioDTO;
import com.edu.pe.util.JsonUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthDAO {

    private static final Logger logger = LoggerFactory.getLogger(AuthDAO.class);
    private Connection connection;

    public AuthDAO() {
        this.connection = Conexion.getInstance().getConnection();
    }

    public UsuarioDTO Login(String correo, String password) {
        String methodName = new Throwable().getStackTrace()[0].getMethodName();
        logger.info("Método: {}, Param correo: {}", methodName, correo);
        logger.info("Método: {}, Param password: {}", methodName, password);

        UsuarioDTO obj = null;

        try {
            PreparedStatement ps = connection.prepareStatement("{CALL sp_auth_login(?,?)}");
            ps.setString(1, correo);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                obj = new UsuarioDTO();
                obj.setIdUsuario(rs.getInt("id_usuario"));
                obj.setIdRol(rs.getInt("id_rol"));
                obj.setNombres(rs.getString("nombres"));
                obj.setCorreo(rs.getString("correo"));
                obj.setId(rs.getInt("id"));
                obj.setEstado(rs.getInt("estado"));
                obj.setFoto(rs.getString("foto"));
            }

            logger.info("Método {}: {}", methodName, JsonUtil.toJsonValueAsString(obj));
        } catch (Exception e) {
            logger.error("Error en el método {}: {}", methodName, e.getMessage(), e);
            e.printStackTrace();
        }

        return obj;
    }

}
