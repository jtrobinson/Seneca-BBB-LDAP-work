<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<div align='right'>Logged in as <%= ldap.getGivenName() %>&nbsp;<a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="seneca_header.jsp"%>
<br><br>
<div align="center">
<a href="meetings.jsp">Meetings</a>&nbsp;&nbsp;
<a href="recordings.jsp">Recordings</a>&nbsp;&nbsp;
<a href="create.jsp">Create</a>&nbsp;&nbsp;
<a href="join.jsp">Join</a>
</div>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>
