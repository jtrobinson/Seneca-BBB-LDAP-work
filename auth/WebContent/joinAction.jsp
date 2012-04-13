<%@page import="org.apache.commons.lang.StringUtils"%>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
    	response.sendRedirect("login.jsp");	
	}

	String type = request.getParameter("type");
	session.removeAttribute("type");
	String password = null;
	if (type.compareTo("1") == 0)
		password = request.getParameter("lPassword");
	else if (type.compareTo("2") == 0)
		password = request.getParameter("mPassword");
	
	System.out.println("Meeting type is " + type);
	
	
	if (password == null){
		response.sendRedirect("join.jsp");
	}
	
	if (password.trim().length() == 0){
		System.out.println("Returning fail code " + type);
		session.setAttribute( "fail", type );
		response.sendRedirect("join.jsp");
	}
	
%>