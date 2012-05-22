<!--
XX
BigBlueButton - http://www.bigbluebutton.org

Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.

BigBlueButton is free software; you can redistribute it and/or modify it under the 
terms of the GNU Lesser General Public License as published by the Free Software 
Foundation; either version 3 of the License, or (at your option) any later 
version. 

BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along 
with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.

-->
<%@page import="org.apache.commons.lang.StringUtils"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<% 
	request.setCharacterEncoding("UTF-8"); 
	response.setCharacterEncoding("UTF-8"); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="css/redmond/jquery-ui-redmond.css" />
	<link rel="stylesheet" type="text/css" href="css/ui.jqgrid.css" />
	<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script src="js/grid.locale-en.js" type="text/javascript"></script>
	<script src="js/jquery.jqGrid.min.js" type="text/javascript"></script>
	<title>Manage All Meetings</title>
	<style type="text/css">
	#container {
		text-align: left;
		width:800px;
	}
	</style>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ page import="java.util.regex.*"%>

<%@ include file="auth_header.jsp"%>

<%
if(ldap.getAccessLevel() < 100) {
    response.sendRedirect("login.jsp");	
}
%>
<%
	if (request.getParameterMap().isEmpty()) {
%>	
	<div align="center">
		<div id="container">
			<h3>Manage All Meetings</h3>
			<input type='button' value='Start Selected' onclick='recordedAction("start");'/>
			<input type='button' value='Delete Selected' onclick='recordedAction("delete");'/>
			<input type='button' value='Guest URL' onclick='recordedAction("guest");'/>
			<input type='button' value='Show Passwords' onclick='recordedAction("passwords");'/>
			<table id="meetinggrid"></table>
			<div id="pager"></div>
			Note: New meetings will appear in the above list after processing.<br/>  Refresh your browser to update the list.
		</div>
	</div>
	
	<script>
	function recordedAction(action){
		if(action=="novalue"){
			return;
		}
		
		var s = jQuery("#meetinggrid").jqGrid('getGridParam','selrow');
		if(s == null){
			alert("Select a row");
			$("#actionscmb").val("novalue");
			return;
		}
		var meetingid="";
		var d = jQuery("#meetinggrid").jqGrid('getRowData',s);
		meetingid+=d.id;
		meetingid.replace(/\s/g, "+");
		meetingid = encodeURIComponent( unescape ( meetingid )); 
		
		if(action=="delete"){
			var answer = confirm ("Are you sure to delete the selected meeting?");
			if (answer){
				if (d.type=="Lecture") {
					meetingid = meetingid;
				}
				sendRecordingAction(meetingid,"admin"+action,d.UID);
			}else{
				$("#actionscmb").val("novalue");
				return;
			}
		}else if(action=="start"){
			var description = "";
			if (d.recorded=="true"){
				do {
				description = prompt("Please enter a description for your meeting. Example: \"Week 01 Lecture\"", "");
				} while (description == null);
			}

			if (navigator.vendor.indexOf("Apple") != -1) {
				window.location.href='meetings_create.jsp?command=start&meetingID='+meetingid+
				  										"&modpass="+d.modpass+
				  										"&viewpass="+d.viewpass+
				  										"&recorded="+d.recorded+
				  										"&description="+description;
			} else {			
				window.open('meetings_create.jsp?command=start&meetingID='+meetingid+
														"&modpass="+d.modpass+
														"&viewpass="+d.viewpass+
														"&recorded="+d.recorded+
														"&description="+description,
									'_blank');
			}
		}else if(action=="guest"){		
			alert('The guest url is : "<%= StringUtils.remove(BigBlueButtonURL,"bigbluebutton/") %>auth/o.jsp?m='+meetingid+'"\n\n' +
						'*Note* Remember to enable guest access before you give out the url.');
		}else if(action=="passwords"){
			alert(" Mod Pass: " + d.modpass + "\n" +
				  "View Pass: " + d.viewpass);
		}else{
			sendRecordingAction(meetingid,action,"null");
		}
		$("#actionscmb").val("novalue");
	}
	
	function sendRecordingAction(meetingID,action,uid){
		$.ajax({
			type: "GET",
			url: 'meetings_helper.jsp',
			data: "command="+action+"&meetingID="+meetingID+"&uid="+uid,
			dataType: "xml",
			cache: false,
			success: function(xml) {
				window.location.reload(true);
				$("#meetinggrid").trigger("reloadGrid");
			},
			error: function() {
				alert("Failed to connect to API.");
			}
		});
	}
	
	$(document).ready(function(){
		
		jQuery("#meetinggrid").jqGrid({
			url: "meetings_helper.jsp?command=getAllMeetings",
			datatype: "xml",
			height: 300,
			loadonce: true,
			sortable: true,
			autowidth: false,
			colNames:['Id','Type','Name', 'Creator', 'UID', 'Moderator Pass', 'Viewer Pass', 'Guests', 'Recorded', 'Date Last Edited'],
			colModel:[
				{name:'id',index:'id', width:50, hidden:true, xmlmap: "meetingid"},
				{name:'type',index:'type', width:80, xmlmap: "type"},
				{name:'name',index:'name', width:150, xmlmap: "name"},
				{name:'creator',index:'creator', width:125, xmlmap: "creatorname", sortable:true},
				{name:'UID',index:'UID', width:125, xmlmap: 'creatoruid', sortable:true},
				{name:'modpass',index:'modpass', width:100, xmlmap: "modpass",sortable: false, hidden: true},
				{name:'viewpass',index:'viewpass', width:100, xmlmap: "viewpass",sortable: false, hidden: true},
				{name:'guests',index:'guests', width:80, xmlmap: "guests", sortable:false, align:"right"},
				{name:'recorded',index:'recorded', width:80, xmlmap: "recorded", sortable:false, align:"right"},
				{name:'date',index:'date', width:120, xmlmap: "date", align:"right"},
			],
			xmlReader: {
				root : "meetings",
				row: "meeting",
				repeatitems:false,
				id: "meetingid"
			},
			pager : '#pager',
			emptyrecords: "Nothing to display",
			caption: "Your Meetings",
			sortname: 'date',
			sortorder: "desc",
			viewrecords: true,
			loadComplete: function(){
				$("#meetinggrid").trigger("reloadGrid");
			}
		});
	});
	
	</script>
<%
	}
%> 



</body>
</html>
