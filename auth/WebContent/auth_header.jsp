<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<div align='right'><a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="seneca_header.jsp"%>
<br><br>
<div align="center">
<a href="meetings.jsp">Meetings</a>&nbsp;&nbsp;
<a href="recordings.jsp">Recordings</a>&nbsp;&nbsp;
<a href="create.jsp">Create</a>
</div>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>
