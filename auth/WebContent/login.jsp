<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<%
	if (!ldap.getAuthenticated().equals("true")) { 
%>
		<html>
		<head>
			<title>Login</title>
		</head>
		<body>
			<%@ include file="seneca_header.jsp"%>
			<form name="loginform" method="post" action="auth.jsp">
				<br><br>
				<table width="300px" align="center" style="border:1px solid #000000;background-color:#efefef;">
					<tr><td colspan=2></td></tr>
					<tr><td colspan=2> </td></tr>
					<tr>
						<td><b>Login Name</b></td>
						<td><input type="text" name="username" value=""></td>
					</tr>
					<tr>
						<td><b>Password</b></td>
						<td><input type="password" name="password" value=""></td>
					</tr>
					<tr>
						<td></td>
						<td><input type="submit" name="Submit" value="Login"></td>
					</tr>
					<tr><td colspan=2> </td></tr>
				</table>
			</form>
			<%
				if (ldap.getAuthenticated().equals("failed")) {
					out.print("<div style='color:red' align='center'> Your credentials are incorrect, please try again</div>");
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