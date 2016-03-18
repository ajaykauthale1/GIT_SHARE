<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<script type="text/javascript">
function validatePassword() {
	if (document.form1.password.value != document.form1.repeatPassword.value) {
		alert('Password does not match!');
		document.form1.password.focus();
		return false;
	} else {
		return true;
	}
}
</script>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>User Signup</title>
</head>
<body>
<h2>Sign Up Page</h2>
<s:actionerror />
<s:form action="signup.action" method="post" onsubmit="return validatePassword()" name="form1">
	<s:textfield name="firstname" key="label.firstname" size="40"></s:textfield>
	<s:textfield name="lastname" key="label.lastname" size="40"></s:textfield>
	<s:textfield name="email" key="label.email" size="40" />
	<s:password name="password" key="label.password" size="20" />
	<s:password name="repeatPassword" key="label.repeatPassword" size="20" />
	<s:checkbox name="emailNotify" key="label.notify.email"/>
	<s:submit method="signup" key="label.signup" align="center" />
</s:form>
</body>
</html>