<%@page import="org.apache.commons.lang.StringUtils"%>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
    	response.sendRedirect("login.jsp");	
	}

	String password = request.getParameter("mPassword");
%>