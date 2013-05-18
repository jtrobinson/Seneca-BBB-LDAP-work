<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%
	if(request.getParameter( "SenecaLDAPBBBLogin" ) != null && request.getParameter( "SenecaLDAPBBBLoginPass" ) != null){
		
		if (ldap.search(request.getParameter( "SenecaLDAPBBBLogin" ),request.getParameter( "SenecaLDAPBBBLoginPass"))) {
			if (ldap.getAccessLevel() < 0) {
				response.sendRedirect("banned.jsp");
			} else {
				response.sendRedirect("join.jsp");
			}
		} else {
			response.sendRedirect("login.jsp");	
		}
	}
%>