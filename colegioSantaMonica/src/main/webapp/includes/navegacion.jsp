<%@page contentType="text/html" pageEncoding="UTF-8"%>
<nav class="pcoded-navbar theme-horizontal menu-light brand-blue">
    <div class="navbar-wrapper container">
        <div class="navbar-content sidenav-horizontal" id="layout-sidenav">
            <ul class="nav pcoded-inner-navbar sidenav-inner">
                <li class="nav-item pcoded-menu-caption">
                    <label>Navigation</label>
                </li>
                <li class="nav-item">
                    <a href="main?accion=inicio" class="nav-link "><span class="pcoded-micon"><i class="feather icon-home"></i></span><span class="pcoded-mtext">Inicio</span></a>
                </li>

                <li class="nav-item pcoded-hasmenu">
                    <a href="#!" class="nav-link ">
                        <span class="pcoded-micon">
                            <i class="feather icon-layout"></i>
                        </span><span class="pcoded-mtext">Marcación</span></a>
                    <ul class="pcoded-submenu">
                        <li><a href="asistencia?accion=rectificacion">Rectificación</a></li>
                    </ul>
                </li>


                <!-- 
                   <li class="nav-item">
                       <a href="#" class="nav-link ">
                           <span class="pcoded-micon">
                               <i class="feather icon-file-text"></i>
                           </span>
                           <span class="pcoded-mtext">Marcacion</span>
                       </a>
                   </li>
                -->

            </ul>
        </div>
    </div>
</nav>

<header class="navbar pcoded-header navbar-expand-lg navbar-light header-blue">
    <div class="container">
        <div class="m-header">
            <a class="mobile-menu" id="mobile-collapse" href="#!"><span></span></a>
            <a href="#!" class="b-brand">

                <img src="assets/images/logo.png" alt="" class="logo" style="width: 50px; height: 45px;">
                <img src="assets/images/logo.png" alt="" class="logo-thumb" style="width: 50px; height: 45px;">
            </a>
            <a href="#!" class="mob-toggler">
                <i class="feather icon-more-vertical"></i>
            </a>
        </div>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ml-auto">
                <li>
                    <div class="dropdown drp-user">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                            <i class="feather icon-user"></i> 
                        </a>
                        <div class="dropdown-menu dropdown-menu-right profile-notification">
                            <div class="pro-head">
                                <img src="assets/images/usuario/${sessionScope.usuario.foto}" class="img-radius" alt="User-Profile-Image">
                                <span>${sessionScope.usuario.nombres}</span>
                                <a href="auth?accion=logout" class="dud-logout" title="Logout">
                                    <i class="feather icon-log-out"></i>
                                </a>
                            </div>
                            <ul class="pro-body">
                                <li><a href="#" class="dropdown-item"><i class="feather icon-user"></i> Perfil</a></li>
                            </ul>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </div>
</header>