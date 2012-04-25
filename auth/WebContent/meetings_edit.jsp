<?xml version="1.0" encoding="UTF-8" ?>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Edit Meeting</title>
</head>
<body>
	<%@ include file="auth_header.jsp" %>
	<%@ include file="meeting_api.jsp"%>
	
	<%
	String meetingid = request.getParameter("meetingid");
	String modpass = request.getParameter("modpass");
	String viewpass = request.getParameter("viewpass");
	String guests = request.getParameter("guests");
	String recorded = request.getParameter("recorded");
	String type = request.getParameter("type");
	
	String modpassErr = "";
	String viewpassErr = "";
	String passErr = "";
	
	if (request.getParameter("sent") != null) {
		if (guests == null) guests = "false";
		else guests = "true";
		
		if (recorded == null) recorded = "false";
		else recorded = "true";
		
		if (modpass.equals("")) {
			modpassErr = "You must enter a password.";
		} else if (modpass.indexOf("~")!=-1 || modpass.indexOf("`")!=-1 || modpass.indexOf("$")!=-1 || modpass.indexOf("-")!=-1 || modpass.indexOf("#")!=-1) {
			modpassErr = "Passwords must not contain ~, `, $, -, or #.";
		}
		
		if (viewpass.equals("")) {
			viewpassErr = "You must enter a password.";
		} else if (viewpass.indexOf("~")!=-1 || viewpass.indexOf("`")!=-1 || viewpass.indexOf("$")!=-1 || viewpass.indexOf("-")!=-1 || viewpass.indexOf("#")!=-1) {
			viewpassErr = "Passwords must not contain ~, `, $, -, or #.";
		}
		
		if (modpassErr.equals("") && viewpassErr.equals("") && modpass.equals(viewpass)) {
			passErr = "Moderator and viewer passwords can't be equal.";
		}
		
		if (modpassErr.equals("") && viewpassErr.equals("") && passErr.equals("")) {
			saveMeeting(ldap.getUserID(), meetingid, modpass, viewpass, guests.equals("true"), recorded.equals("true"));
			response.sendRedirect("meetings.jsp");
		}
	}
	if (request.getParameter("command") != null && request.getParameter("command").equals("edit")
		&& meetingid != null && modpass != null
		&& viewpass != null && guests != null
		&& recorded != null && type != null
		&& (type.equals("Lecture")||type.equals("Meeting"))) {
	
		if (type.equals("Lecture") && ldap.getAccessLevel() < 30) { %>
			<%= loadRedirect() %>
	 <% } else if (ldap.getAccessLevel() < 20 && (guests.equals("true") || recorded.equals("true"))) { %>
	 		<%= loadRedirect() %>
	 <% } else { %>
	 	<form action="meetings_edit.jsp" method="post" name="form">
	 		<input type="hidden" id="sent" name="sent" value="sent"/> 
	 		<input type="hidden" id="command" name="command" value="edit"/>
	 		<input type="hidden" id="meetingid" name="meetingid" value='<%= meetingid %>'/>
	 		<input type="hidden" id="type" name="type" value='<%= type %>'/> 
	 		<table align="center">
	 			<tr><td colspan='2'><h2>Edit <%= type %></h2></td></tr>
	 			<% 
	 			if (type.equals("Lecture")) { %>
	 			<tr>
	 				<td>Course</td>
	 				<td><%= StringUtils.stripStart(meetingid.split("-")[0], "`") %></td>
	 			</tr>
	 			<tr>
	 				<td>Section</td>
	 				<td><%= (meetingid.split("-")[1]).split("\\^")[0] %></td>
	 			</tr>
	 			<%
	 			} else { %>
	 			<tr>
	 				<td>Name</td>
	 				<td><%= meetingid.split("\\^")[0] %></td>
	 			</tr>
	 			<%
	 			} %>
	 			
	 			<tr>
	 				<td>Moderator Password</td>
	 				<td><input type="text" id="modpass" name="modpass" value="<%= modpass %>"/></td>
	 			</tr>
	 			<%
	 			if (!modpassErr.equals("")) { %>
	 			<tr>
	 				<td colspan='2'><div style='color:red' align='center'><%= modpassErr %></div></td>
	 			</tr>
	 			<%
	 			} %>
	 			<tr>
	 				<td>Viewer Password</td>
	 				<td><input type="text" id="viewpass" name="viewpass" value="<%= viewpass %>"/></td>
	 			</tr>
	 			<%
	 			if (!viewpassErr.equals("")) { %>
	 			<tr>
	 				<td colspan='2'><div style='color:red' align='center'><%= viewpassErr %></div></td>
	 			</tr>
	 			<%
	 			} %>
	 			
	 			<%
	 			if (!passErr.equals("")) { %>
	 			<tr>
	 				<td colspan='2'><div style='color:red' align='center'><%= passErr %></div></td>
	 			</tr>
	 			<%
	 			} %>
	 			
	 			<%
	 			if(ldap.getAccessLevel() >= 20){ %>
	 			<tr>
	 				<td>Allow Guests?</td>
	 				<td><input type='checkbox' id='guests' name='guests' <% if (guests.equals("true")) out.print("checked='checked'"); %>/></td>
	 			</tr>
	 			<tr>
	 				<td>Recorded?</td>
	 				<td><input type='checkbox' id='recorded' name='recorded' <% if (recorded.equals("true")) out.print("checked='checked'"); %>/></td>
	 			</tr>
	 			<%
	 			} %>
	 			<tr align='center'>
	 				<td colspan='2'>
	 					<input type='submit' value='Edit'/>
	 				</td>
	 			</tr>
	 		</table>
	 	</form>
	 <%	} %>
 <%	} else { %>
		<%= loadRedirect() %>
 <%	} %>
</body>
</html>

<%!
public String loadRedirect() {
	return "<script language='javascript' type='text/javascript'>" +
  				"window.location.href='meetings.jsp';" +
  			"</script>";
}
%>