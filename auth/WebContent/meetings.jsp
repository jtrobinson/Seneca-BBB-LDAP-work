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
	<link rel="stylesheet" type="text/css" href="css/ui.jqgrid.css" />
	<link rel="stylesheet" type="text/css" href="css/redmond/jquery-ui-redmond.css" />
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript" src="js/jquery.min.js"></script>
	<script type="text/javascript" src="js/jquery.validate.min.js"></script>
	<script src="js/grid.locale-en.js" type="text/javascript"></script>
	<script src="js/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="js/jquery.xml2json.js" type="text/javascript"></script>
	<title>Manage Your Meetings</title>
	<style type="text/css">
	 #formcreate{
		margin-bottom:30px;
	 }
	 #formcreate label.labform{
	 	display:block;
	 	float:left;
	 	width:100px;
	 	text-align:right;
		margin-right:5px;
	 }
	 #formcreate div{
		margin-bottom:5px;
		clear:both;
	 }
	 #formcreate .submit{
		margin-left:100px;
		margin-top:15px;
	 }
	 #descript{
	 	vertical-align:top;
	 }
	 #meta_description , #username1{
		float:left;
	 }
	 .ui-jqgrid{
		font-size:0.7em
	}
	label.error{
		float: none; 
		color: red; 
		padding-left: .5em; 
		vertical-align: top;
		width:200px;
		text-align:left;
	}
	</style>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ page import="java.util.regex.*"%>

<%@ include file="auth_header.jsp"%>

<%
	if (request.getParameterMap().isEmpty()) {
		//
		// Assume we want to see a list of meetings
		//
%>	


	<table align='center'>
		<tr><td>
			<h3>Manage Meetings</h3>
			<select id="actionscmb" name="actions" onchange="recordedAction(this.value);">
				<option value="novalue" selected>Actions...</option>
				<option value="start">Start</option>
				<option value="edit">Edit</option>
				<option value="delete">Delete</option>
				<%	if (ldap.getOU().equals("Employee")) { %>
				<option value="guest">Guest URL</option>
				<%	} %>
			</select>
			<table id="meetinggrid"></table>
			<p>Note: New meetings will appear in the above list after processing.  Refresh your browser to update the list.</p>
		</td></tr>
	</table>
	<div id="pager"></div>
	
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
		
		if(action=="delete"){
			var answer = confirm ("Are you sure to delete the selected meeting?");
			if (answer){
				var header="";
				if (d.type=="Lecture")
					header = "#";
				sendRecordingAction(meetingid,action);
			}else{
				$("#actionscmb").val("novalue");
				return;
			}
		}else if(action=="start"){
			var description = "";
			if (d.recorded=="true"){
				description = prompt("Please enter a description for your meeting. Example: \"Week 01 Lecture\"", "");
			}
			window.open('meetings_create.jsp?command=start&meetingID='+meetingid+
														  "&modpass="+d.modpass+
														  "&viewpass="+d.viewpass+
														  "&recorded="+d.recorded+
														  "&description="+description,
					  '_blank');
		}else if(action=="guest"){			
			alert('The guest url is : "<%= StringUtils.remove(BigBlueButtonURL,"bigbluebutton/") %>o.jsp?m='+meetingid+'"\n\n' +
						'*Note* Remember to enable guest access before you give out the url.');
		}else{
			sendRecordingAction(meetingid,action);
		}
		$("#actionscmb").val("novalue");
	}
	
	function sendRecordingAction(meetingID,action){
		$.ajax({
			type: "GET",
			url: 'meetings_helper.jsp',
			data: "command="+action+"&meetingID="+meetingID,
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
			url: "meetings_helper.jsp?command=getMeetings",
			datatype: "xml",
			height: 300,
			rowNum: 20,
			loadonce: true,
			sortable: true,
			autowidth: false,
			colNames:['Id','Type','Name','Moderator Pass', 'Viewer Pass', 'Guests', 'Recorded', 'Date Last Edited'],
			colModel:[
				{name:'id',index:'id', width:50, hidden:true, xmlmap: "meetingid"},
				{name:'type',index:'type', width:80, xmlmap: "type"},
				{name:'name',index:'name', width:150, xmlmap: "name",editable: 'true', edittype: 'text', editoptions: { size: 10}},
				{name:'modpass',index:'modpass', width:100, xmlmap: "modpass",sortable: false},
				{name:'viewpass',index:'viewpass', width:100, xmlmap: "viewpass",sortable: false},
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
