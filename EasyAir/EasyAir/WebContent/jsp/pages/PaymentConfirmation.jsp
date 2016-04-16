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

		$('#payment_label_purchaseTicket').click(function() {
			if ($('#payment_user_firstname').val() == '') {
				alert('First name can not be left blank');
				$('#payment_user_firstname').focus();
				return false;
			} else if ($('#payment_user_lastname').val() == '') {
				alert('Last name can not be left blank');
				$('#payment_user_lastname').focus();
				return false;
			} else if ($('#payment_user_gender').val() == '') {
				alert('Gender can not be left blank');
				$('#payment_user_gender').focus();
				return false;
			} else if ($('#payment_user_dateOfBirth').val() == '') {
				alert('Date of birth can not be left blank');
				$('#payment_user_dateOfBirth').focus();
				return false;
			} else if ($('#payment_payment_cardNumber').val() == '') {
				alert('Card number can not be left blank');
				$('#payment_payment_cardNumber').focus();
				return false;
			} else if ($('#payment_payment_expiryMonth').val() == '') {
				alert('Card expirty month can not be left blank');
				$('#payment_payment_expiryMonth').focus();
				return false;
			} else if ($('#payment_payment_expiryYear').val() == '') {
				alert('Card expirty year can not be left blank');
				$('#payment_payment_expiryYear').focus();
				return false;
			} else if ($('#payment_payment_cvv').val() == '') {
				alert('Card cvv can not be left blank');
				$('#payment_payment_cvv').focus();
				return false;
			} else if ($('#country').val() == '') {
				alert('Country can not be left blank');
				$('#country').focus();
				return false;
			} else if ($('#state').val() == '') {
				alert('State can not be left blank');
				$('#state').focus();
				return false;
			} else if ($('#payment_payment_address').val() == '') {
				alert('Address can not be left blank');
				$('#payment_payment_address').focus();
				return false;
			} else if ($('#payment_payment_city').val() == '') {
				alert('City can not be left blank');
				$('#payment_payment_city').focus();
				return false;
			} else if ($('#payment_payment_zipcode').val() == '') {
				alert('Zipcode can not be left blank');
				$('#payment_payment_zipcode').focus();
				return false;
			}
			return true;
		});
	});

	function numbersonly(myfield, e, dec) {
		var key;
		var keychar;
		if (window.event)
			key = window.event.keyCode;
		else if (e)
			key = e.which;
		else
			return true;
		keychar = String.fromCharCode(key);
		// control keys 
		if ((key == null) || (key == 0) || (key == 8) || (key == 9)
				|| (key == 13) || (key == 27))
			return true;
		// numbers
		else if ((("0123456789").indexOf(keychar) > -1))
			return true;
		// decimal point jump 
		return false;
	}
</script>
<style>
#payment_label_purchaseTicket {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	width: 200px;
}

#payment_label_purchaseTicket:hover {
	background: #6286DE;
}
</style>
</head>
<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>

	<s:form action="payment.action">
		<div style="font-family: Verdana, Arial, sans-serif;" align="center">
			<table id="paymentTable" style="border: 1 solid balck;">
				<tr>
					<th align="left" colspan="2"><font style="color: #36c">Traveler
							Information</font></th>
				</tr>
				<tr height="10px">
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
					<th align="left" colspan="2"><font style="color: #36c">Payment
							Information</font></th>
				</tr>
				<tr height="10px">
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
					<td><s:textfield name="payment.cvv" size="5" maxlength="3" onkeypress="return numbersonly(this, event);"></s:textfield></td>
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
					</script></td>
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
				<tr height="15px;"></tr>
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