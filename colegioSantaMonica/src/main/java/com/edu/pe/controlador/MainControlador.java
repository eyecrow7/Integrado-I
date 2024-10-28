package com.edu.pe.controlador;

import com.edu.pe.dto.UsuarioDTO;
import com.edu.pe.modelo.CursoProfesor;
import com.edu.pe.modelo.HorarioCurso;
import com.edu.pe.modelo.PeriodoLectivo;
import com.edu.pe.modelo.dao.AuthDAO;
import com.edu.pe.modelo.dao.CursoProfesorDAO;
import com.edu.pe.modelo.dao.HorarioCursoDAO;
import com.edu.pe.modelo.dao.PeriodoLectivoDAO;
import jakarta.servlet.ServletConfig;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@WebServlet(name = "MainControlador", urlPatterns = {"/main"})
public class MainControlador extends HttpServlet {
   private static final Logger logger = LoggerFactory.getLogger(MainControlador.class);
   
    private UsuarioDTO usuario;
    private CursoProfesorDAO cursoProfDao;
    private PeriodoLectivoDAO periodoLectivoDao;
    private HorarioCursoDAO horarioCursoDao;

    @Override
    public void init(ServletConfig config) throws ServletException {
        cursoProfDao = new CursoProfesorDAO();
        periodoLectivoDao = new PeriodoLectivoDAO();
        horarioCursoDao = new HorarioCursoDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        usuario = (UsuarioDTO) request.getSession().getAttribute("usuario");

        String accion = request.getParameter("accion");

        switch (accion) {
            case "inicio":
                inicio(request, response);
                break;
        }
    }

    protected void inicio(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int idProf = usuario.getId();

        PeriodoLectivo objPeriodo = periodoLectivoDao.ObtenerPeriodoVigente();
        List<CursoProfesor> listaCursos;
        if (objPeriodo != null) {
            listaCursos = cursoProfDao.CursoProfesor(idProf);
            
            for(CursoProfesor obj: listaCursos){
                obj.setHorarios(horarioCursoDao.listarHorarioCursoPorCursoProf(obj.getIdCursoProf()));
            }
        } else {
            listaCursos = new ArrayList<>();
        }

        request.setAttribute("periodo_vigente", objPeriodo);
        request.setAttribute("secciones",listaCursos);

        request.getRequestDispatcher("pagMain.jsp").forward(request, response);
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
