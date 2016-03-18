<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<html>
<head>
<!-- <link rel="stylesheet" href="css/style.css"> -->
<title>EasyAir Login</title>
</head>
<body>
<h2>EasyAir Login</h2>
<s:actionerror />
<s:form action="login.action" method="post">
	<s:textfield name="username" key="label.username" size="20" />
	<s:password name="password" key="label.password" size="20" />
	<s:submit method="authenticate" key="label.login" align="center" />
	<a href="jsp/pages/Signup.jsp">Sign Up</a>
</s:form>
</body>
</html>