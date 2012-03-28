<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%
	if(request.getParameter( "username" ) != null && request.getParameter( "password" ) != null){
		String name = request.getParameter( "username" );
		String paswd = request.getParameter( "password" ) ;
		
		if (ldap.search(request.getParameter( "username" ))) {
			session.setAttribute( "theName",  name);
			response.sendRedirect("loggedIn/welcome.jsp");
		} else {
			response.sendRedirect("login.jsp?fail=1001a99847aa");	
		}
	} else if(session.getAttribute("theName") != "root") {
		response.sendRedirect("login.jsp");	
	}
%>