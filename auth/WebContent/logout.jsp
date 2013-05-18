<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<%@page import="java.util.*" %>

<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>

<%
	ldap.resetAuthenticated();
	ldap.setLogout(true);
	response.sendRedirect("login.jsp");
%>


