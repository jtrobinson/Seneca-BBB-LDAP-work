<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="css/ui.jqgrid.css" />
	<link rel="stylesheet" type="text/css" href="css/redmond/jquery-ui-redmond.css" />
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript" src="js/jquery.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script src="js/grid.locale-en.js" type="text/javascript"></script>
	<script src="js/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="js/jquery.xml2json.js" type="text/javascript"></script>
	
	<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
	<title>Join a Meeting</title>
</head>
<body>
	<%@ include file="auth_header.jsp"%>
	<%@ include file="meeting_api.jsp"%>
	<br/>
	<br/>
	<%
		out.println("<p align='center' style='font-size:23px'>Welcome <b><span style='color:green;'>" + ldap.getCN() + "</b> as " + ldap.getOU() + "</p>");

		if(!ldap.getAuthenticated().equals("true")) {
	    	response.sendRedirect("login.jsp");	
		}
		meetingApplication.loadAllMeetings();
		System.out.println("Lecture size after: " +meetingApplication.getLectures().size());
		ArrayList <String[]> lectureList = runningList(meetingApplication.getLectures());
   		ArrayList <String[]> meetingList = runningList(meetingApplication.getMeetings());
   		
   		System.out.println("Is tehre any meetings? " +meetingList.size()+ "  " +lectureList.size() );
   	%>
	<table align="center" width="1000" border="0" cellpadding="0" cellspacing="30">
		<tr valign="top">
			<td align="right" width="500">
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
   				</form><br/><br/>
   			</td>
   			<td width="1" bgcolor="#000000"></td>
   			<td align="left" width="500">
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
   				</form><br/><br/>
   			</td>
   		</tr>
   	</table>
</body>
</html>