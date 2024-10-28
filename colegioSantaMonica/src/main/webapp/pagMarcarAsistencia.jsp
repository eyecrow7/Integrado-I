<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Colegio Santa Monica</title>
        <meta charset="utf-8">
        <jsp:include page="includes/css.jsp" />

    </head>

    <body>
        <jsp:include page="includes/navegacion.jsp" />
        <jsp:include page="includes/mensaje.jsp" />

        <div class="pcoded-main-container">
            <div class="pcoded-wrapper container-fluid mt-2">
                <div class="main-body">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="card">
                                <div class="card-body">
                                    <ul class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="#!"><i class="feather icon-home"></i></a></li>
                                        <li class="breadcrumb-item"><a href="#!">Asistencia de clase</a></li>
                                        <li class="breadcrumb-item"><a href="#!">Periodo ${periodo_vigente.nombrePeriodo}</a></li>
                                    </ul>

                                    <div class="row">
                                        <div class="col-sm-4">
                                            <strong>ID CURSO:</strong>
                                            <span> ${seccion.idCurso} </span>

                                            <br /> 
                                            <strong>ID SECCIÓN:</strong>
                                            <span> ${seccion.idSeccion} </span>
                                            
                                            <br />
                                            <strong>NIVEL:</strong>
                                            <span> ${seccion.nivel} </span>
                                        </div>
                                        <div class="col-sm-4">
                                            <strong>NOMBRE CURSO:</strong>
                                            <span> ${seccion.nombreCurso} </span>

                                            <br /> 
                                            <strong>HORAS ACADÉMICAS:</strong>
                                            <span> ${seccion.horas} </span>

                                            <br />
                                            <strong>GRADO:</strong>
                                            <span> ${seccion.nroGrado}° ${seccion.letra} </span>
                                        </div>


                                        <div class="col-sm-4">
                                            <span>
                                                <strong>Horario:</strong>

                                                <ul style="list-style-type: none; padding-left: 0;">
                                                    <c:forEach items="${seccion.horarios}" var="horario">
                                                        <li>
                                                            <span>${horario.diaSemana}</span> 
                                                            <span>${horario.horaInicio} - ${horario.horaFin}</span>
                                                        </li>
                                                    </c:forEach>
                                                </ul>
                                            </span>
                                        </div>
                                    </div>

                                    <c:if test="${seccion.marcacion == false}">
                                        <div class="row mt-2">
                                            <div class="col-sm-12">
                                                <div class="alert alert-primary" role="alert">
                                                    Lo sentimos! Usted no cuenta con una marcación asignada para el dia de hoy.
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>

                                    <c:if test="${seccion.marcacion == true}">
                                        <form method="POST" action="asistencia">
                                            <div class="row mt-2">
                                                <div class="col-sm-12">
                                                    <table class="table table-bordered table-striped">
                                                        <thead class="bg-primary ">
                                                            <tr>
                                                                <th>#</th>
                                                                <th>Alumno</th>
                                                                <th>Correo</th>
                                                                <th>Asistió</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach items="${asistencia}" var="item" varStatus="loop">
                                                                <tr>
                                                                    <td>${loop.index + 1}</td>
                                                                    <td>${item.apePaterno} ${item.apeMaterno} ${item.nombres}</td>
                                                                    <td>${item.correo}</td>
                                                                    <td>
                                                                        <input type="hidden" name="idAsistencia" value="${item.idAsisAlu}">
                                                                        <input type="hidden" name="idAlumno" value="${item.idAlumno}" />
                                                                        <input type="checkbox" name="asistio_${item.idAlumno}" value="1" ${item.asistio == 1 ? "checked": ""}>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                            <c:if test="${asistencia.size() == 0}">
                                                                <tr class="text-center">
                                                                    <td colspan="7">No se encontró alumnos</td>
                                                                </tr>
                                                            </c:if>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-sm-12">
                                                    <input type="hidden" name="idSeccion" value="${seccion.idSeccion}">
                                                    <input type="hidden" name="idCursoProf" value="${seccion.idCursoProf}">
                                                    <input type="hidden" name="accion" value="procesar">
                                                    <button type="submit" class="btn btn-info">
                                                        <i class="fa fa-save"></i> Guardar Asistencia
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="includes/js.jsp" />
    </body>
</html>
