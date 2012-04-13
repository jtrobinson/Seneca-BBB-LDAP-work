<%@page import="org.apache.commons.lang.StringUtils"%>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
    	response.sendRedirect("login.jsp");	
	}

	String password = request.getParameter("lPassword");
	String type = request.getParameter("type");
	System.out.println("Meeting type is " + type);
	
	if (password == null){
		response.sendRedirect("join.jsp");
	}
	
	if (password.trim().length() == 0){
		session.setAttribute( "fail", "1" );
		response.sendRedirect("join.jsp");
	}
%>