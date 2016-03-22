<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link
	href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
	rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="css/style.css">
<style>
#login_label_login {
	background: #9AC462;
	border: 0;
	border-radius: 5px;
	width: 5em;
	height: 2em;
}

#login_label_login:hover {
	background: #383;
}
</style>
<title>EasyAir Login</title>
</head>
<body>
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="LoginHeader.jsp"></jsp:include>
	<s:form action="login.action" method="post">
		<div class="ui-widget">
			<table id="loginTable"
				style="border: 1px solid #DAE5E8; border-radius: 5px; padding: 1em;"
				align="center">
				<tr>
					<td>
						<h2 style="color: #36c;">Login</h2>
					</td>
				</tr>
				<tr>
					<td>
						<h4>Email</h4>
					</td>
				</tr>
				<tr>
					<td><s:textfield name="username" key="label.username"
							size="40" /></td>
				</tr>
				<tr height="10"></tr>
				<tr>
					<td>
						<h4>Password</h4>
					</td>
				</tr>
				<tr>
					<td><s:password name="password" key="label.password" size="40" /></td>
				</tr>
				<tr height="10"></tr>
				<tr>
					<td align="center"><div class="ui-widget">
							<s:submit method="authenticate" key="label.login" align="center" />
						</div></td>
				</tr>
				<tr>
					<td>
						<div class="ui-widget" align="center" style="color: red;">
							<s:actionerror />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>