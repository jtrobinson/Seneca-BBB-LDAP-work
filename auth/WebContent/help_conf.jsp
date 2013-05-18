<%@ page import="java.util.HashMap"%>

<%

String helpURL = "http://zenit.senecac.on.ca/wiki/index.php/Seneca_BigBlueButton_web_gateway_help";

HashMap<String, String> helpRedirect = new HashMap<String, String>();

helpRedirect.put("login.jsp", "Logging_In");
helpRedirect.put("join.jsp", "Joining_Meetings");
helpRedirect.put("create.jsp", "Create_Meetings");
helpRedirect.put("meetings.jsp", "Manage_Meetings");
helpRedirect.put("meetings_edit.jsp", "Manage_Meetings");
helpRedirect.put("recordings.jsp", "Manage_Recordings");

helpRedirect.put("adminmeetings.jsp", "All_Meetings");
helpRedirect.put("adminrecordings.jsp", "All_Recordings");

%>