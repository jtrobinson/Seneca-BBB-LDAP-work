<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%@ include file="help_conf.jsp" %>
<%
	if (!ldap.getAuthenticated().equals("true")) { 
%>
		<html>
		<head>
			<title>Login</title>
			<style type="text/css">
				#container{
			    	display: table;
			    	width: 300px;
			    	border: 1px solid #000000;
			    	background-color: #efefef;
			    }
			
			  	#row{
			    	display: table-row;
			    }
			
			  	#cell{
			    	display: table-cell;
			    	padding: 5px;
			    	vertical-align: middle;
			    }
			    
			    #bottom-cell{
			    	display: table-cell;
			    	padding: 5px;
			    	width: 25%;
			    }
			</style>
		</head>
		<body>
			<%@ include file="seneca_header.jsp"%>
			<form name="loginform" method="post" action="auth.jsp">
				<br/><br/>
				<div align="center">
					<div id="container">
						<div id="row">
							<div id="cell">
								<b>Login Name</b>
							</div>
							<div id="cell">
								<input type="text" name="username" value="">
							</div>							
						</div>
						<div id="row">
							<div id="cell">
								<b>Password</b>
							</div>
							<div id="cell">
								<input type="password" name="password" value="">
							</div>							
						</div>
						<div id="row" align="left">
							<div id="bottom-cell"></div>
							<input type="submit" name="Submit" value="Login">							
							<%
							out.print("<a href='"+helpURL);
							if (helpRedirect.containsKey("login.jsp"))
								out.print("#"+helpRedirect.get("login.jsp"));
							out.println("'>Help</a>");
							%>
						</div>
					</div>
				</div>			
			</form>
			<%
				if (ldap.getAuthenticated().equals("failed")) {
					out.print("<div style='color:red' align='center'> Your credentials are incorrect, please try again</div>");
				} else if (ldap.getAuthenticated().equals("error")) {
					out.print("<div style='color:red' align='center'> Error with login please contact the system administrator.</div>");
				} else if (ldap.getAuthenticated().equals("timeout")) {
					ldap.resetAuthenticated();
				   	out.print("<div style='color:green' align='center'> Your session timed out!</div>");
				} else if (ldap.isLogout()) {
					ldap.setLogout(false);
			   		out.print("<div style='color:green' align='center'> You are logged out!</div>");
			   	}
			%>
			
			<% if (request.getHeader("User-Agent").indexOf("MSIE") != -1) { %>
				<br/>
				<div id="container">
					<div id="row">
						<div id="cell">
							For best results please use Firefox or Chrome.
						</div>
					</div>
				</div>
			<% } %>
		</body>
		</html>
<%
	} else
		response.sendRedirect("join.jsp");
%>