<jsp:useBean id="meeting" class="meeting.Meeting" scope="session"/>

<?xml version="1.0" encoding="UTF-8" ?>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Guest Access</title>
</head>
<body>
<%@ include file="seneca_header.jsp" %>
<%@ include file="bbb_api.jsp" %>
<%
	String m = request.getParameter("m");
	String errorName = "";
	String errorPassword = "";
	
	String name = request.getParameter("name");
	String password = request.getParameter("password");
	
	if (meeting.isFound() && meeting.getMeetingID().equals(m)) {
		if (name != null && password != null) {
			
			if (name.equals("")) {
				errorPassword = "You must enter a password";
			} else if (!password.equals(meeting.getViewPass())) {
				errorPassword = "Password does not match";
			} 
			
			if (name.equals("")) {
				errorName = "You must enter a name";
			}
			
			if (errorName.equals("") && errorPassword.equals("")) {
				response.sendRedirect(getJoinURLViewer(name, m, password));
			}
		}
	}
	if (!meeting.loadMeeting(m)) {
		out.println("Desired meeting not found. Please check the url again.");
	} else if (!meeting.isGuestsAllowed()) {
		out.println("The meeting creator has disallowed guest access. Please contact the meeting creator.");
	} else if (isMeetingRunning(meeting.getMeetingID()).equals("false")) {
		out.println("The meeting has not been started yet. Please wait and try again.");
	} else {
		if (name == null) {
			name = "";
		}
	%>
		<br/><br/>
		<form action='<%= request.getRequestURI() %>?m=<%= meeting.getMeetingID() %>' method="post" name="login">
			<div align="center">
				<table>
					<tr>
						<td>
							Your Name: 
						</td>
						<td>
							<input type='text'name='name' value='<%= name %>'/>&nbsp;
							<div style='color:red'><%= errorName %></div>
						</td>
					</tr>
					<tr>
						<td>
							Password: 
						</td>
						<td>
							<input type='password' name='password' />&nbsp;
							<div style='color:red'><%= errorPassword %></div>
						</td>
					</tr>
				</table>
				<br/><input type="submit" value="Login" />
			</div>
		</form>
	<%
	}
%>
</body>
</html>