<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meets" class="ldap.MeetingApplication" scope="session"/>
e
<%@ page contentType="text/xml" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="bbb_api.jsp" %>
<?xml version="1.0" ?>
<% if (request.getParameter("command").equals("isRunning")){ %>
<response>
	<running><%= isMeetingRunning(request.getParameter("meetingID")) %></running>
</response>
<% } else if(request.getParameter("command").equals("getMeetings")){%>
	<%= getMeetings(ldap.getUID()) %>
<% } else if(request.getParameter("command").equals("start")){ %>
	<%=    %>
<% } else if(request.getParameter("command").equals("edit")){%>
	<%=  //make call to edit page or create with fields filled *TBD*%>
<% } else if(request.getParameter("command").equals("delete")){%>
	<%=  //make call to delete the meeting %>
<% } %>

<%!

public String getMeetings(String UID) {
//recordID,name,description,starttime,published,playback,length
	String newXMLdoc = "<meetings>";
	
	meets.loadMeetingsByUser(UID);	
	
	newXMLdoc += convertMeetingList(meets.getLectures(), "Lecture");
	newXMLdoc += convertMeetingList(meets.getMeetings(), "Meeting");

	newXMLdoc += "</meetings>";
	return newXMLdoc;
}

public String convertMeetingList(ArrayList<String[]> meetings, String type) {
	String convMeetings = "";
	
	/*	Each meeting follows the format
		course-uid
		modpass
		viewpass
		guests allowed
		recorded
		date
	 */
	for (String[] meet : meetings) {
		
		String [] parts = meet[0].split("-");
		
		convMeetings += "<meeting>";
		
		convMeetings += "<meetingID>" + meet[0] + "</meetingID>";
		convMeetings += "<type>" + type + "</type>";
		convMeetings += "<name>" + parts[0] + "</name>";
		convMeetings += "<modPass>" + meet[1] + "</modPass>";
		convMeetings += "<viewPass>" + meet[2] + "</viewPass>";
		convMeetings += "<guests>" + meet[3] + "</guests>";
		convMeetings += "<recorded>" + meet[4] + "</recorded>";
		convMeetings += "<date>" + meet[5] + "</date>";
		
		convMeetings += "</meeting>";
	}
	
	return convMeetings;
}
%>