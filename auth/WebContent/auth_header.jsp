<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>
<div align='right'>Logged in as <%= ldap.getGivenName() %>&nbsp;<a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="seneca_header.jsp"%>
<br><br>
<div align="center">
<a href="meetings.jsp">Meetings</a>&nbsp;&nbsp;
<% if (ldap.getPosition().equals("Employee")) { %>
<a href="recordings.jsp">Recordings</a>&nbsp;&nbsp;
<% } %>
<a href="create.jsp">Create</a>&nbsp;&nbsp;
<a href="join.jsp">Join</a>&nbsp;&nbsp;
<a href="adminmeetings.jsp">All Meetings</a>&nbsp;&nbsp;
<a href="adminrecordings.jsp">All Recordings</a>
</div>