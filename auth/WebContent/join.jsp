<jsp:useBean id="meetingApplication" class="meeting.MeetingApplication" scope="session"/>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<title>Join a Meeting</title>
	
	<style type="text/css">
		#container{
	    	display: table;
	    }
	
	  	#row{
	    	display: table-row;
	    	vertical-align: center;
	    }
	
	  	#left{
	    	display: table-cell;
	    	padding: 25px;
	    	width: 50%;
	    }
	    
	    #right{
	    	display: table-cell;
	    	padding: 25px;
	    	width: 50%;
	    	border-left: 1px solid black;
	    }
	</style>
</head>
<body>
	<%@ include file="auth_header.jsp"%>
	<%
	if(ldap.getAccessLevel() < 0) {
    	response.sendRedirect("login.jsp");	
	}
	%>
	<%@ include file="meeting_api.jsp"%>
	<br/>
	<br/>
	<%
		out.println("<p align='center' style='font-size:23px'>Welcome <b><span style='color:green;'>" + ldap.getGivenName() + "</b> as " + ldap.getPosition() + "</p>");

		meetingApplication.loadAllMeetings();
		ArrayList <String[]> lectureList = runningList(meetingApplication.getLectures());
   		ArrayList <String[]> meetingList = runningList(meetingApplication.getMeetings());

   	%>
   	
   	<div align="center">
		<div id="container">
			<div id="row">
				<div id="left" align="right">
					<br/><b>Join Lecture:</b><br/>
	   				<form action="joinAction.jsp?type=1" method="post" name="lectureForm">
	   					<%
							if (lectureList.size() == 0){
	   							out.println("No active lectures. <br/>");
	   						}
	   						else{
	   							out.println("<select name='lectureName'>");
		   						for (int i = 0; i < lectureList.size(); i++){
		   							String rawName = lectureList.get(i)[0];
		   							String displayName = StringUtils.removeStart(rawName, String.valueOf(PROF_SYMBOL));
		   							displayName = StringUtils.replace(displayName, String.valueOf(NAME_DELIMITER), " (");
		   							displayName = displayName + ")";
		   							out.println("<option value='" + rawName + "'>" + displayName + "</option>");
		   						}
								out.println("</select>");
								out.println("<br/>Password: <input type='password' name='lPassword' value=''/><br/><br/>");
								out.println("<input type='submit' id='lectureBtn' value='Join Lecture'/>");
	   						}					   						
	   						if(session.getAttribute("fail")!= null){
	   							if (session.getAttribute("fail").toString().equals("1")){
	  								session.removeAttribute("fail");
	   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
	   							}
	   							else if (session.getAttribute("fail").toString().equals("PW1")){
	   								session.removeAttribute("fail");
	   								out.print("<div style='color:red' align='center'> Invalid password.</div>");
	   							}
	   						}
	   					%>   					
	   				</form><br/>
				</div>
				<div id="right" align="left">
					<br/><b>Join Meeting:</b><br/>
					<form action="joinAction.jsp?type=2" method="post" name="meetingForm">
	   					<%
	   						if (meetingList.size() == 0){
	   							out.println("No active meetings. <br/>");
	   						}
	   						else{
		   						out.println("<select name='meetingName'>");
		   						for (int i = 0; i < meetingList.size(); i++){
		   							String rawName = meetingList.get(i)[0];
		   							String displayName = StringUtils.replace(rawName, String.valueOf(NAME_DELIMITER), " (");
		   							displayName = displayName + ")";
		   							out.println("<option value='" + rawName + "'>" + displayName + "</option>");
		   						}
		   						out.println("</select>");
		   						out.println("<br/>Password: <input type='password' name='mPassword' value=''/><br/><br/>");
		   						out.println("<input type='submit' id='meetingBtn' value='Join Meeting'/>");
	   						}   						
	   						if(session.getAttribute("fail")!= null){
	   							if (session.getAttribute("fail").toString().equals("2")){
	  								session.removeAttribute("fail");
	   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
	   							}
	   							else if (session.getAttribute("fail").toString().equals("PW2")){
	   								session.removeAttribute("fail");
	   								out.print("<div style='color:red' align='center'> Invalid password.</div>");
	   							}
	   						}
	   					%>
   					</form><br/>
				</div>
			</div>
		</div>
	</div>
</body>
</html>