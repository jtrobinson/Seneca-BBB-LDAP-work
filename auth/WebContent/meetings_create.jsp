<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%  
		Map<String,String> metadata=new HashMap<String,String>();
	
		metadata.put("email", request.getParameter("username"));
		metadata.put("title", request.getParameter("meetingID"));
	%>
	<script language="javascript" type="text/javascript">
  		window.location.href="<%=getJoinURL(ldap.getCN(), request.getParameter("meetingID"), request.getParameter("recorded"), request.getParameter("modpass"), request.getParameter("viewpass"), "Welcome", metadata, null)%>";
	</script>
</body>
</html>