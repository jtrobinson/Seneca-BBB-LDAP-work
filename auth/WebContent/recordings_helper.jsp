<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meets" class="meeting.MeetingApplication" scope="session"/>

<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("login.jsp");	
}
%>

<%@ page contentType="text/xml" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>
<?xml version="1.0" ?>
<% if (request.getParameter("command").equals("isRunning")){ %>
<response>
	<running><%= isMeetingRunning(request.getParameter("meetingID")) %></running>
</response>
<% } else if(request.getParameter("command").equals("getRecords") && ldap.getAccessLevel() >= 20){%>
	<%= getRecordings(meets.getRecordingString(ldap.getUserID())) %>
<% } else if(request.getParameter("command").equals("getAllRecords") && ldap.getAccessLevel() >= 100){%>
	<%= getRecordings("") %>
<% } else if(request.getParameter("command").equals("delete") && ldap.getAccessLevel() >= 20){%>
	<%= deleteRecordings(request.getParameter("recordID"))%>
<% } %>