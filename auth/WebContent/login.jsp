<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%@ include file="help_conf.jsp" %>
<%@ include file="bbb_api_conf.jsp" %>

<%
	if (!ldap.getAuthenticated().equals("true")) {
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
		<html>
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<title>Login Page</title>
			
			<script type="text/javascript">
			//if (window.location.protocol != "https:") {
			//   window.location = 'https://<%=BigBlueButtonURL.substring(BigBlueButtonURL.indexOf('/')+2, BigBlueButtonURL.indexOf('/', BigBlueButtonURL.indexOf('/')+3))%>/auth/login.jsp';
			//}
			</script>
			
			<style type="text/css">
				div.container{
					display: table;
					margin: 0 auto;
					width: 400px;
					border: 1px solid #000000;
					background-color: #efefef;
			    }
			
			  	div.row{
			    	display: table-row;
			    }
			
			  	div.cell{
			    	display: table-cell;
					padding: 5px;
			    }
			    
			    div.left {
					display: table-cell;
					width: 30%;
					padding: 5px;
					text-align: right;
				}
				
				div.right {
					display: table-cell;
					width: 30%;
					padding: 5px;
					vertical-align: middle;
				}
			    
			    div.bottom-cell{
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

				<div class="container">
					<div class="row">
						<div class="left">
							<b><label for="SenecaLDAPBBBLogin">Login Name</label></b>
						</div>
						<div class="right">
							<input type="text" name="SenecaLDAPBBBLogin" id="SenecaCDAPBBBLogin" value="">
						</div>							
					</div>
					<div class="row">
						<div class="left">
							<b><label>Password</label></b>
						</div>
						<div class="right">
							<input type="password" name="SenecaLDAPBBBLoginPass" id="SenecaLDAPBBBLoginPass" value="">
						</div>							
					</div>
					<div class="row">
						<div class="bottom-cell"></div>
						<input type="submit" name="Submit" value="Login">							
						<%
						out.print("<a href='"+helpURL);
						if (helpRedirect.containsKey("login.jsp"))
							out.print("#"+helpRedirect.get("login.jsp"));
						out.println("'>Help</a>");
						%>
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
		</body>
		</html>
<%
	} else
		response.sendRedirect("join.jsp");
%>