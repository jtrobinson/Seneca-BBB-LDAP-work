
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
	<title>Manage Your Recordings</title>
	<style type="text/css">
	#container {
		text-align: left;
		width:600px;
	}
	</style>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ page import="java.util.regex.*"%>

<%@ include file="auth_header.jsp"%>

<%
if(ldap.getAccessLevel() < 20) {
    response.sendRedirect("login.jsp");	
}
%>

<%
	if (request.getParameterMap().isEmpty()) {
%>
	<div align="center">
		<div id="container">
			<h3>Recorded Sessions</h3>
			<input type='button' value='Delete Selected' onclick='recordedAction("delete");'/>
			<table id="recordgrid"></table>
			<div id="pager"></div>
			Note: New recordings will appear in the above list after processing.<br/>  Refresh your browser to update the list.
		</div>
	</div>
	
	
	<!-- 
	<table align='center'>
	<tr><td>
	<h3>Recorded Sessions</h3>
	<input type='button' value='Delete Selected' onclick='recordedAction("delete");'/>
	<table id="recordgrid"></table>
	<div id="pager"></div> 
	<p>Note: New recordings will appear in the above list after processing.<br/>  Refresh your browser to update the list.</p>
	</td></tr>
	</table>
	-->
	
	<script>
	function recordedAction(action){
		if(action=="novalue"){
			return;
		}
		
		var s = jQuery("#recordgrid").jqGrid('getGridParam','selarrrow');
		if(s.length==0){
			alert("Select at least one row");
			$("#actionscmb").val("novalue");
			return;
		}
		var recordid="";
		for(var i=0;i<s.length;i++){
			var d = jQuery("#recordgrid").jqGrid('getRowData',s[i]);
			recordid+=d.id;	
			if(i!=s.length-1)
				recordid+=",";
		}
		if(action=="delete"){
			var answer = confirm ("Are you sure to delete the selected recordings?");
			if (answer)
				sendRecordingAction(recordid,action);
			else{
				$("#actionscmb").val("novalue");
				return;
			}
		}else{
			sendRecordingAction(recordid,action);
		}
		$("#actionscmb").val("novalue");
	}
	
	function sendRecordingAction(recordID,action){
		$.ajax({
			type: "GET",
			url: 'recordings_helper.jsp',
			data: "command="+action+"&recordID="+recordID,
			dataType: "xml",
			cache: false,
			success: function(xml) {
				window.location.reload(true);
				$("#recordgrid").trigger("reloadGrid");
			},
			error: function() {
				alert("Failed to connect to API.");
			}
		});
	}
	
	$(document).ready(function(){
		jQuery("#recordgrid").jqGrid({
			url: "recordings_helper.jsp?command=getRecords",
			datatype: "xml",
			height: 300,
			loadonce: true,
			sortable: true,
			colNames:['Id', 'Name', 'Type', 'Description', 'Date Recorded', 'Playback', 'Length'],
			colModel:[
				{name:'id',index:'id', width:50, hidden:true, xmlmap: "recordID"},
				{name:'course',index:'course', width:125, xmlmap: "name", sortable:true},
				{name:'type',index:'type', width:80, xmlmap: "type"},
				{name:'description',index:'description', width:150, xmlmap: "description",sortable: true},
				{name:'daterecorded',index:'daterecorded', width:120, xmlmap: "startTime", sortable: true, sorttype: "datetime", datefmt: "d-m-y h:i:s"},
				{name:'playback',index:'playback', width:80, xmlmap:"playback", sortable:false},
				{name:'length',index:'length', width:50, xmlmap:"length", sortable:true}
			],
			xmlReader: {
				root : "recordings",
				row : "recording",
				repeatitems : false,
				id: "recordID"
			},
			pager : '#pager',
			emptyrecords: "Nothing to display",
			multiselect: true,
			viewrecords: true,
			caption: "Recorded Sessions",
			loadComplete: function(){
				$("#recordgrid").trigger("reloadGrid");
			}
		});
	});

	</script>
<%
	}
%> 


</body>
</html>
