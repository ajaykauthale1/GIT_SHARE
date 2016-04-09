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
<script type="text/javascript" src="js/countries3.js"></script>
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
<style>
#payment_label_purchaseTicket {
background: #9AC462;
	border: 0;
	border-radius: 5px;
}

#payment_label_purchaseTicket:hover {
	background: #383;
}
</style>
</head>
<body background = "images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>

	<s:form action="payment.action">
		<div style="font-family: Verdana, Arial, sans-serif;" align="center">
			<table id="paymentTable" style="border: 1 solid balck;">
				<tr>
					<th align="center" colspan="2"><font style="color: #36c">Traveler
							Information</font></th>
				</tr>
				<tr height="5px">
				<tr>
					<th align="left">First Name</th>
					<th align="left">Last Name</th>
				</tr>
				<tr>
					<td><s:textfield name="user.firstname"></s:textfield></td>
					<td><s:textfield name="user.lastname"></s:textfield></td>
				</tr>
				<tr height="5px">
				</tr>
				<tr>
					<th align="left">Gender</th>
					<th align="left">Date of Birth</th>
				</tr>
				<tr>
					<td><s:select
							list="#{'Please select' : 'Please select', 'Male':'Male', 'Female':'Female'}"
							name="user.gender"></s:select></td>
					<td><s:textfield name="user.dateOfBirth"></s:textfield></td>
				</tr>
				<tr height="5px">
				</tr>
				<tr>
					<td colspan="2">
						<hr>
					</td>
				</tr>
				<tr>
					<th align="center" colspan="2"><font style="color: #36c">Payment
							Information</font></th>
				</tr>
				<tr height="5px">
				<tr>
					<th align="left">Credit Card Number</th>
				</tr>
				<tr>
					<td colspan="2"><s:textfield name="payment.cardNumber"
							size="50px"></s:textfield></td>
				</tr>
				<tr height="2px">
				<tr>
					<th align="left">Expires</th>
					<th align="left">CVV</th>
				</tr>
				<tr>
					<td><s:select name="payment.expiryMonth"
							list="#{'Month' : 'Month' , 'Jan' : 'Jan', 'Feb' : 'Feb', 'Mar' : 'Mar',
							 'Apr' : 'Apr', 'May' : 'May', 'Jun' : 'Jun', 'Jul' : 'Jul', 'Aug' : 'Aug',
							 'Sep' : 'Sep', 'Oct' : 'Oct', 'Nov' : 'Nov', 'Dec' : 'Dec'}"></s:select>
						&nbsp; <s:select name="payment.expiryYear"
							list="#{'Year' : 'Year' , '2016' : '2016', '2017' : '2017', '2018' : '2018',
							 '2019' : '2019', '2020' : '2020', '2021' : '2021', '2022' : '2022',
							 '2023' : '2023', '2024' : '2024', '2025' : '2025'}"></s:select>
					</td>
					<td><s:textfield name="payment.cvv" size="5" maxlength="3"></s:textfield></td>
				</tr>
				<tr height="3px">
				</tr>
				<tr>
					<th align="left">Country</th>
					<th align="left">State</th>
				</tr>
				<tr>
					<td><select
						onchange="print_state('state',this.selectedIndex);" id="country"
						name="payment.country"></select></td>
					<td><select name="payment.state" id="state"></select> <script
							language="javascript">
						print_country("country");
					</script>
					</td>
				</tr>
				<tr height="3px">
				</tr>
				<tr>
					<th align="left" colspan="2">Address</th>
				</tr>
				<tr>
					<td colspan="2"><s:textfield name="payment.address"
							size="60px"></s:textfield></td>
				</tr>
				<tr height="3px">
				</tr>
				<tr>
					<th align="left">City</th>
					<th align="left">Zipcode</th>
				</tr>
				<tr>
					<td><s:textfield name="payment.city"></s:textfield></td>
					<td><s:textfield name="payment.zipcode"></s:textfield></td>
				</tr>
				<tr height="3px;"></tr>
				<tr>
					<td colspan="2" align="center">
						<div class="ui-widget">
							<s:submit method="purchase" key="label.purchaseTicket"
								align="center" />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>