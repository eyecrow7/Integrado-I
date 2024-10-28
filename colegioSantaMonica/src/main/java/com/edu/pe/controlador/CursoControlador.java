package com.edu.pe.controlador;

import com.edu.pe.dto.UsuarioDTO;
import com.edu.pe.modelo.Curso;
import com.edu.pe.modelo.Grado;
import com.edu.pe.modelo.Seccion;
import com.edu.pe.modelo.dao.CursoDAO;
import com.edu.pe.modelo.dao.CursoProfesorDAO;
import com.edu.pe.modelo.dao.GradoDAO;
import com.edu.pe.modelo.dao.HorarioCursoDAO;
import com.edu.pe.modelo.dao.PeriodoLectivoDAO;
import com.edu.pe.modelo.dao.SeccionDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletConfig;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "cursoControlador", urlPatterns = {"/curso"})
public class CursoControlador extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(MainControlador.class);
    private UsuarioDTO usuario;
    private GradoDAO gradoDao;
    private SeccionDAO seccionDao;
    private CursoDAO cursoDao;

    @Override
    public void init(ServletConfig config) throws ServletException {
        gradoDao = new GradoDAO();
        seccionDao = new SeccionDAO();
        cursoDao = new CursoDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        usuario = (UsuarioDTO) request.getSession().getAttribute("usuario");

        String accion = request.getParameter("accion");

        switch (accion) {
            case "listar_x_profesor":
                listarGradoPorProfesor(request, response);
                break;
            case "listar_fechas_x_curso":
                listarFechasPorCurso(request, response);
                break;
        }

    }

    protected void listarFechasPorCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int idPeriodo = Integer.parseInt(request.getParameter("periodo"));
        int idCurso = Integer.parseInt(request.getParameter("curso"));
        
        List<String> lista = cursoDao.FechasPorCurso(idPeriodo, idCurso);

        out.print(new Gson().toJson(lista));
    }

    protected void listarGradoPorProfesor(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int idSeccion = Integer.parseInt(request.getParameter("seccion"));

        List<Curso> lista = cursoDao.CursoPorSeccion(idSeccion, usuario.getId());

        out.print(new Gson().toJson(lista));
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
