<%
    if(session.getAttribute("rutusuario") == null){
        session.invalidate();
	response.sendRedirect("login.jsp");
    }
    
%>
