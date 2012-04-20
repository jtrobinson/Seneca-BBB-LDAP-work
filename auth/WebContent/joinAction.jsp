<%@page import="org.apache.commons.lang.StringUtils"%>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="meeting.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
    	response.sendRedirect("login.jsp");	
	}

	String type = request.getParameter("type");
	session.removeAttribute("type");
	String password = null;
	if (type.equals("1"))
		password = request.getParameter("lPassword");
	else if (type.equals("2"))
		password = request.getParameter("mPassword");	
	
	if (password == null){
		response.sendRedirect("join.jsp");
	}
	else if (password.trim().length() == 0){
		session.setAttribute( "fail", type );
		response.sendRedirect("join.jsp");
	}
	else{
		meetingApplication.loadAllMeetings();
		ArrayList <String[]> list = new ArrayList <String[]> ();
		String rawName = null;
		if (type.equals("1")){
			list = meetingApplication.getLectures();
			rawName = request.getParameter("lectureName");
		}
		else if (type.equals("2")){
			list = meetingApplication.getMeetings();
			rawName = request.getParameter("meetingName");
		}
		
		// Go through LIST until you find the meeting with a name that matches the rawMeetingName you have 
		int i = -1;
		Boolean found = false;
		String meetingID = null;
		while (!found && i < list.size()){
			i++;
			meetingID = list.get(i)[0];
			if (meetingID.equals(rawName)){
				found = true;
			}
		}
		if (found){
			String modPass = list.get(i)[1];
			String viewPass = list.get(i)[2];
			//System.out.println("DEBUG ONLY Meeting ID is " + meetingID + "</br>");
			meetingID = StringUtils.removeStart(meetingID, String.valueOf(PROF_SYMBOL));
			//System.out.println("DEBUG ONLY NEW Meeting ID is " + meetingID + "</br>");
			//System.out.println("DEBUG ONLY Mod password is " + modPass + "</br>");
			//System.out.println("DEBUG ONLY Viewer password is " + viewPass + "</br>");

			if (!password.equals(modPass) && !password.equals(viewPass)){
				session.setAttribute( "fail", "PW"+type );
				response.sendRedirect("join.jsp");
			}
			else
			{
				if (isMeetingRunning(meetingID).equals("false")){
					out.println("This meeting has not begun yet. Please try again later, or contact the presenter.");
				}
				else{
					if (password.equals(viewPass)){
						out.println("Logging you in as viewer<br/>");
						String meetingURL = getJoinURLViewer(ldap.getCN(), meetingID, password);
						out.println("DEBUG ONLY MeetingURL is " + meetingURL);
						response.sendRedirect(meetingURL);
					}
					else if (password.equals(modPass)){
						out.println("Logging you in as moderator<br/>");
						String meetingURL = getJoinMeetingURL(ldap.getCN(), meetingID, password);
						out.println("DEBUG ONLY MeetingURL is " + meetingURL);
						response.sendRedirect(meetingURL);
					}
				}
			}
		}
	}
%>