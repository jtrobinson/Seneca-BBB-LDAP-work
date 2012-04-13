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
	
	<script type="text/javascript">
		function setLecture(){
			alert("Script setLecture works");
			session.setAttribute( "type", "lecture" );
		}
   	</script>
	
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
		if(!ldap.getAuthenticated().equals("true")) {
	    	response.sendRedirect("login.jsp");	
		}
		meetingApplication.loadAllMeetings();
		ArrayList <String[]> lectureList = meetingApplication.lectures;
   		ArrayList <String[]> meetingList = meetingApplication.meetings;
   	%>
	<table align="center" border="1" cellpadding="10" cellspacing="10">
		<tr>
			<td>
				<b>Join Lecture:</b><br/>
   				<form action="joinLectureAction.jsp" method="post" name="lectureForm">
   					<%
   						out.println("<select name='lectures'>");
   						
   						for (int i = 0; i < lectureList.size(); i++){
   							String rawDisplayName = lectureList.get(i)[0];
   							String displayName = StringUtils.removeStart(rawDisplayName, String.valueOf(PROF_SYMBOL));
   							displayName = StringUtils.replace(displayName, String.valueOf(NAME_DELIMITER), " (");
   							displayName = displayName + ")";
   							
   							out.println("<option value='" + rawDisplayName + "'>" + displayName + "</option>");
   						}
   						
   						out.println("</select>");
   						out.println("<br/>Password: <input type='password' name='lPassword' value=''/><br/><br/>");
   						out.println("<button type='submit' id='lectureBtn' onClick='setLecture()'>Join Lecture</button>");
   						   						
   						if( session.getAttribute( "fail" )!= null){
   							String fail = (String) session.getAttribute( "fail" );
   							session.removeAttribute("fail");
   							if(fail.equals("1")){
   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
   							}
   						}
   					%>   					
   				</form>
   			</td>
   			<td>
				<b>Join Meeting:</b><br/>
				<form action="joinMeetingAction.jsp" method="post" name="meetingForm">
   					<%
   						out.println("<select name='meetings'>");
   						
   						for (int i = 0; i < meetingList.size(); i++){
   							String displayName = meetingList.get(i)[0];
   							displayName = StringUtils.replace(displayName, String.valueOf(NAME_DELIMITER), " (");
   							displayName = displayName + ")";
   							
   							out.println("<option>" + displayName + "</option>");
   						}
   						
   						out.println("</select>");
   						out.println("<br/>Password: <input type='password' name='lPassword' value=''/><br/><br/>");
   						out.println("<input type='submit' id='meetingBtn' value='Join Meeting'/>");
   						
   						if( session.getAttribute( "fail" )!= null){
   							String fail = (String) session.getAttribute( "fail" );
   							session.removeAttribute("fail");
   							if(fail.equals("2")){
   								out.print("<div style='color:red' align='center'> Please input a password.</div>");
   							}
   						}
   					%>
   				</form> 
   			</td>
   		</tr>
   	</table>
</body>
</html>