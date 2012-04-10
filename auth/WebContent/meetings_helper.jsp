<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meets" class="ldap.MeetingApplication" scope="session"/>
<%@ page contentType="text/xml" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>
<?xml version="1.0" ?>
<% if (request.getParameter("command").equals("isRunning")){ %>
<response>
	<running><%= isMeetingRunning(request.getParameter("meetingID")) %></running>
</response>
<% } else if(request.getParameter("command").equals("getMeetings")){%>
	<%= meets.getUserMeetingsXML(ldap.getUID()) %>
<% } else if(request.getParameter("command").equals("start")){ %>
	<%    %>
<% } else if(request.getParameter("command").equals("edit")){%>
	<%  //make call to edit page or create with fields filled *TBD*%>
<% } else if(request.getParameter("command").equals("delete")){%>
	<%  //make call to delete the meeting %>
<% } %>