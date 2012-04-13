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
	<%@ include file="bbb_api.jsp"%>
	<%@ include file="meeting_api.jsp"%>
	<br/>
	<br/>
	<br/>
	<br/>
	<%  
		System.out.println("About to loadAllMeetings");
		meetingApplication.loadAllMeetings();
		ArrayList <String[]> lectureList = meetingApplication.lectures;
   		ArrayList <String[]> meetingList = meetingApplication.meetings;
   		System.out.println("After population, lectureList.size is " + lectureList.size() + " and meetingList.size is " + meetingList.size());
   	%>
	<table align="center" border="1" cellpadding="10" cellspacing="10">
		<tr>
			<td>
				<b>Join Lecture:</b><br/>
   				<form action="joinAction.jsp" method="post" name="lectureForm">
   					<!--  select name="lectures"></select -->
   					<%
   						out.println("<select name='lectures'>");
   						
   						for (int i = 0; i < lectureList.size(); i++){
   							out.println("<option>" + lectureList.get(i)[0] + "</option>");
   						}
   						
   						out.println("</select>");
   					%>
   					<br/>
   					Password: <input type="password" name="lPassword" value=""/>
   				</form>
   			</td>
   			<td>
				<b>Join Meeting:</b><br/>
				<form action="joinAction.jsp" method="post" name="lectureForm">
   					<!-- Put the generation of the SELECT boxes into a Script block, 
   						 use a call to meetingApplication like in create.jsp (but not exactly, because it looks in XML -->
   					<br/>
   					Password: <input type="password" name="lPassword" value=""/>
   				</form> 
   			</td>
   		</tr>
   	</table>
</body>
</html>