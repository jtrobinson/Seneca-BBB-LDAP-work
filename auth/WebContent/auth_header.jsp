<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>
<div align='right'>Logged in as <%= ldap.getGivenName() %>&nbsp;<a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="help_conf.jsp" %>
<%@ include file="seneca_header.jsp"%>
<br><br>
<div align="center">
<% if (ldap.getAccessLevel() >= 10) { %>
	<a href="meetings.jsp">Meetings</a>&nbsp;&nbsp;
<% } %>
<% if (ldap.getAccessLevel() >= 20) { %>
	<a href="recordings.jsp">Recordings</a>&nbsp;&nbsp;
<% } %>
<% if (ldap.getAccessLevel() >= 10) { %>
	<a href="create.jsp">Create</a>&nbsp;&nbsp;
<% } %>
<% if (ldap.getAccessLevel() >= 0) { %>
	<a href="join.jsp">Join</a>&nbsp;&nbsp;
<% } %>
<% if (ldap.getAccessLevel() >= 100) { %>
	<a href="adminmeetings.jsp">All Meetings</a>&nbsp;&nbsp;
<% } %>
<% if (ldap.getAccessLevel() >= 100) { %>
	<a href="adminrecordings.jsp">All Recordings</a>
<% } %>
</div>