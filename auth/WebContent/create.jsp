<jsp:useBean id="meetingApplication" class="meeting.MeetingApplication"
	scope="session" />
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="org.w3c.dom.*,javax.xml.parsers.*"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<%!
	public boolean isTextNode(Node n) {
		return n.getNodeName().equals("#text");
	}
	%>
	
	<script type="text/javascript">
	
		// this small function allows to change Drop down list of lecture to textbox  (for Professors )
		function onCheck() {
			// this code is to trigger oncheck isLecture Event 
			var isCheckedLecture = document.getElementById("check").checked;
			if( isCheckedLecture  == true)
				isCheckedLecture = "true"; 
			else
				isCheckedLecture = "false";
	
			window.location.replace("create.jsp?isLecture="+isCheckedLecture);
			
		<%
			String check = (String) request.getParameter("isLecture");
			String isLecture = "true";
			session.setAttribute("isChecked", check);
			session.setAttribute("isLecture", isLecture);
		%>
		}	
	 
	</script>
	
	
	<title>Create Meeting</title>
	
	<style type="text/css">
	#container {
		display: table;
		margin: 0 auto;
		width: 500px;
	}
	
	#row {
		display: table-row;
	}
	
	#cell {
		display: table-cell;
		padding: 5px;
	}
	
	#left {
		display: table-cell;
		width: 40%;
		padding: 5px;
	}
	
	#right {
		display: table-cell;
		width: 60%;
		padding: 5px;
		vertical-align: middle;
	}
	
	#error {
		display: table-cell;
		padding: 25px;
	}
	</style>
</head>
<body>
	<%@ include file="meeting_api.jsp"%>
	<%@ include file="auth_header.jsp"%>
	
	<%
	if (ldap.getAccessLevel() < 10) {
		response.sendRedirect("login.jsp");
	}
	%>
	<form action="createAction.jsp" method="post" name="form">
		<div id='container' width='465'>
			<div id='row'>
				<h3>Create Session</h3>
			</div>
		<%
			String checked = "";
			if (session.getAttribute("isChecked") != null) {
				checked = (String) session.getAttribute("isChecked");
			} else
				checked = "false";
		
			if (ldap.getAccessLevel() >= 30) {
				// if you are logged in as prof you have checkbox which allows you to  create a lecture
				out.println("<div id='row'><div id='left'> Create a Lecture ?</div>");
				out.println("<div id='right'><input type='checkbox' id='check' name='check' onClick='onCheck()'");
				if (checked.equals("true"))
					out.println("checked = 'checked'");
				out.println("></div></div>");
			}
		
			if (ldap.getAccessLevel() >= 30 && checked.equals("true")) {
				// if you are professor and you checked is Lecture you see drop down list of lectures
				out.println("<div id='row'><div id='left' align='center'>");
				out.println("<span style='color:red'>*</span><select name='courses'>");
				ArrayList<String> courseList = meetingApplication.processCourseList();
				for (String courseName : meetingApplication.processCourseList()) {
					if (courseName.equals(session.getAttribute("meetingName"))) {
						out.println("<option selected='selected'>" + courseName + "</option>");
					} else {
						out.println("<option>" + courseName + "</option>");
					}
				}
		
				out.println("</select></div>");
				if (session.getAttribute("section") == null) {
					out.print("<div id='right'>Section <input type='text' size='5' maxlength='5' name='section' />");
				} else {
					out.print("<div id='right'>Section <input type='text' size='5' maxlength='5' name='section'");
					out.print("value='" + session.getAttribute("section") + "'");
					out.print("/>");
				}
				out.print("</div></div>");
			} else {
				// else user sees a textbox with name of the lecture
				out.print("<div id='row'> <div id='left'>Name of Meeting  <span style='color:red'>*</span></div>");
				out.println("<div id='right'>   <input type='text' id='meetingName' ");
				if (session.getAttribute("meetingName") != null)
					out.print("value='" + session.getAttribute("meetingName") + "' ");
				out.print("name='meetingName' size='30'/></div> </div>");
			}
		%>
			<div id='row'>
				<div id='left'>Moderator Password <span style='color: red'>*</span>
				</div>
				<div id='right'>
					<input type="password" id="mPwd" name="mPwd" 
						<% if (session.getAttribute("mPwd") != null)
							out.print("value = '" + session.getAttribute("mPwd") + "'"); %> />
				</div>
			</div>
			<div id='row'>
				<div id='left'>Confirm Moderator Password <span style='color: red'>*</span>
				</div>
				<div id='right'><input type="password" id="mPwdre" name="mPwdre"
					<% if (session.getAttribute("mPwdre") != null)
						out.print("value = '" + session.getAttribute("mPwdre") + "'"); %> />
				</div>
			</div>
			<div id='row'>
				<div id='left'>Viewer Password <span style='color: red'>*</span>
				</div>
				<div id='right'><input type="password" id="vPwd" name="vPwd"
					<% if (session.getAttribute("vPwd") != null)
						out.print("value = '" + session.getAttribute("vPwd") + "'");%> />
				</div>
			</div>
			<div id='row'>
				<div id='left'>Confirm Viewer Password <span style='color: red'>*</span>
				</div>
				<div id='right'><input type="password" id="vPwdre" name="vPwdre"
					<% if (session.getAttribute("vPwdre") != null)
						out.print("value = '" + session.getAttribute("vPwdre") + "'");%> />
				</div>
			</div>
			
			<%
				String guestsChecked = (String) session.getAttribute("allowGuests");
				String lectures = (String) session.getAttribute("lectures");
				// if user is authenticated as employee allowing them two options: invite non-ldap authenticated people
				// allow to record their meetings
				if (ldap.getAccessLevel() >= 20) {
					out.println("<div id='row'>");
					if (session.getAttribute("allowGuests") != null	&& guestsChecked.equals("on")) {
						out.println(" <div id='cell'> Allow Guests ? <input type='checkbox' id='allowGuests' name='allowGuests' checked='yes'/></div> ");
					} else {
						out.println(" <div id='cell'> Allow Guests ? <input type='checkbox' id='allowGuests' name='allowGuests'/></div> ");
					}
					if (session.getAttribute("lectures") != null && lectures.equals("on")) {
						out.println(" <div id='cell' text-align='left'> Recordable ? <input type='checkbox' id='Recordable' name='Recordable' checked='yes'/></div> ");
					} else {
						out.println(" <div id='cell' text-align='left'> Recordable ? <input type='checkbox' id='Recordable' name='Recordable' /></div> ");
					}
					out.println("</div>");
				}
			%>
			<div id='row' align='right'>
				<div id='cell'><input type='submit' value='Create' />
				</div>
				<div id='cell' align='center'><span style='color: red'>*</span> - Required Field
				</div>
			</div>
		</div>
			<!-- END OF MAIN TABLE -->
			
		<div id='container'>
			<div id='row' height='60' valign='middle'>
				<div id='error'>
				<%
					if (session.getAttribute("fail") != null) {
						String fail = (String) session.getAttribute("fail");
						session.removeAttribute("fail");
						if (fail.equals("1")) {
							out.print("<div style='color:red' align='center'> Please fill all the required fields</div>");
						} else if (fail.equals("2")) {
							out.print("<div style='color:red' align='center'> Moderator password and confirmation don't match</div>");
						} else if (fail.equals("3")) {
							out.print("<div style='color:red' align='center'> Viewer password and confirmation don't match</div>");
						} else if (fail.equals("4")) {
							out.print("<div style='color:red' align='center'> Your meeting name or section contains forbidden character(s) (not allowed: $&`~-#)</div>");
						} else if (fail.equals("5")) {
							out.print("<div style='color:red' align='center'> Moderator and Viewer passwords cannot be the same</div>");
						}
					}
				
					session.setAttribute("mPwd", null);
					session.setAttribute("mPwdre", null);
					session.setAttribute("vPwd", null);
					session.setAttribute("vPwdre", null);
					session.setAttribute("meetingName", null);
					session.setAttribute("section", null);
					session.setAttribute("allowGuests", null);
					session.setAttribute("lectures", null);
				%>
				</div>
			</div>
		</div>
	</form>
</body>

</html>