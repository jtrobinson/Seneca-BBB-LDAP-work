<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meets" class="meeting.MeetingApplication" scope="session"/>

<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>

<%@ page contentType="text/xml" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="meeting_api.jsp" %>
<?xml version="1.0" ?>

<% if(request.getParameter("command").equals("getMeetings") && ldap.getAccessLevel() >= 10){%>
	<%= meets.getUserMeetingsXML(ldap.getUserID()) %>
<% } else if(request.getParameter("command").equals("getAllMeetings") && ldap.getAccessLevel() >= 100){%>
	<%= meets.getUserMeetingsXML("adminAccess") %>
<% } else if(request.getParameter("command").equals("delete") && ldap.getAccessLevel() >= 10){%>
	<%= deleteMeeting(ldap.getUserID(), request.getParameter("meetingID")) %>
<% } else if(request.getParameter("command").equals("admindelete") && ldap.getAccessLevel() >= 100){%>
<%= deleteMeeting(request.getParameter("uid"), request.getParameter("meetingID")) %>
<%  } %>