<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="http://code.jquery.com/jquery-1.7.js"
	type="text/javascript"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"
	type="text/javascript"></script>
<link
	href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
	rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="css/style.css">
<title>Payment</title>
<script type="text/javascript">
	$(document).ready(function() {
		$("#payment_user_dateOfBirth").datepicker();
	});
</script>
</head>
<body>
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>

	<s:form action="payment.action">
		<div class="ui-widget" align="center">
			<table id="paymentTable" style="border: 1 solid balck;">
				<tr>
					<th align="left">First Name</th>
					<th align="left">Last Name</th>
				</tr>
				<tr>
					<td><s:textfield name="user.firstname"></s:textfield></td>
					<td><s:textfield name="user.lastname"></s:textfield></td>
				</tr>
				<tr height="10px">
				</tr>
				<tr>
					<th align="left">Gender</th>
				</tr>
				<tr>
					<td><s:select
							list="#{'Please select' : 'Please select', 'Male':'Male', 'Female':'Female'}"
							name="user.gender"></s:select>
					</td>
				</tr>
				<tr height="10px">
				<tr>
					<th align="left">Date of Birth</th>
				</tr>
				<tr>
					<td>
						<s:textfield name="user.dateOfBirth"></s:textfield>
					</td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>