<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<div align='right'><a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="seneca_header.jsp"%>
<br><br>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>
