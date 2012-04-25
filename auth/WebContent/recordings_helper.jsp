<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meets" class="meeting.MeetingApplication" scope="session"/>
<%@ page contentType="text/xml" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>
<?xml version="1.0" ?>
<% if (request.getParameter("command").equals("isRunning")){ %>
<response>
	<running><%= isMeetingRunning(request.getParameter("meetingID")) %></running>
</response>
<% } else if(request.getParameter("command").equals("getRecords")){%>
	<%= getRecordings(meets.getRecordingString(ldap.getUserID())) %>
<% } else if(request.getParameter("command").equals("getAllRecords")){%>
	<%= getRecordings("") %>
<% } else if(request.getParameter("command").equals("publish")||request.getParameter("command").equals("unpublish")){%>
	<%= setPublishRecordings( (request.getParameter("command").equals("publish")) ? true : false , request.getParameter("recordID"))%>
<% } else if(request.getParameter("command").equals("delete")){%>
	<%= deleteRecordings(request.getParameter("recordID"))%>
<% } %>