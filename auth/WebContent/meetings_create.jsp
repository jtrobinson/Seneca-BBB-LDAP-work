<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>

<%
	if (!ldap.getAuthenticated().equals("true")) {
		response.sendRedirect("login.jsp");
	}
%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Start Session</title>
</head>
<body>
	<%  
		Map<String,String> metadata=new HashMap<String,String>();
	
		metadata.put("email", request.getParameter("username"));
		metadata.put("title", request.getParameter("meetingID"));
		//metadata.put("publish", "false");
		
		if (request.getParameter("recorded").equals("false")){
			metadata.put("description", "");
		}
		else{
			metadata.put("description", request.getParameter("description"));
		}
		
	%>
	<script language="javascript" type="text/javascript">
  		window.location.href="<%=getJoinURL(ldap.getCN(), request.getParameter("meetingID"), request.getParameter("recorded"),"Welcome", request.getParameter("modpass"), request.getParameter("viewpass"), metadata, null)%>";
	</script>
</body>
</html>