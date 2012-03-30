<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<%@page import="java.util.*" %>

<%
	ldap.resetAuthenticated();
	ldap.setLogout(true);
	response.sendRedirect("../login.jsp");
 %>


