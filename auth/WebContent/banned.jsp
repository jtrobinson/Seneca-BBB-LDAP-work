<?xml version="1.0" encoding="UTF-8" ?>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Banned</title>
</head>
<body>
	<%@ include file="auth_header.jsp"%>
	
	<%
	if(ldap.getAccessLevel() >= 0) {
	    response.sendRedirect("login.jsp");	
	}
	%>
	
	<div align='center' style='color:red'>
	You have been banned from accessing this server.<br/><br/>
	If this message is not expected please contact <br/>the System Administrator.
	</div>
</body>
</html>