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
<style>
#ticketbook_label_confirmToContinue, #ticketbook_label_back {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	width: 200px;
}

#ticketbook_label_confirmToContinue:hover, #ticketbook_label_back:hover
	{
	background: #6286DE;
}
</style>
<title>Confirmation</title>
</head>
<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<s:form action="ticketbook.action">
		<div class="ui-widget" align="center">
			<table id="bookingTable" style="border: 1 solid balck;">
				<tr>
					<td colspan="4"><h4 style="color: #36c;">Price Details</h4></td>
				</tr>
				<tr>
					<th align="left"><div class="ui-widget">
							<font style="color: black">Base Fare</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black">Tax Fee</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black">Total</font>
						</div></th>
				</tr>
				<tr>
					<td><s:property value="schedule.price" /></td>
					<td>&nbsp;</td>
					<td>$0</td>
					<td>&nbsp;</td>
					<td><s:property value="schedule.price" /></td>
				</tr>
				<tr height="20px"></tr>
				<tr>
					<td colspan="4"><h4 style="color: #36c;">Trip Details</h4></td>
				</tr>
				<tr>
					<th align="left"><div class="ui-widget">
							<font style="color: black" size="3px">Fly from</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black" size="3px">To</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black" size="3px">Departure Date</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black" size="3px">Arrival Date</font>
						</div></th>
					<th>&nbsp;</th>
					<th align="left"><div class="ui-widget">
							<font style="color: black" size="3px">Departure Time</font>
						</div></th>
				</tr>
				<tr height="5px"></tr>
				<tr>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.flight.source" />
						</div>
					</td>
					<td>&nbsp;</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.flight.destination" />
						</div>
					</td>
					<td>&nbsp;</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.departureDate" />
						</div>
					</td>
					<td>&nbsp;</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.arrivalDate" />
						</div>
					</td>
					<td>&nbsp;</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.departureTime" />
						</div>
					</td>
				</tr>
				<tr height="20px"></tr>
				<tr align="center">
					<td colspan="2"></td>
					<td colspan="1" align="center">
						<div class="ui-widget">
							<s:submit method="confirm" key="label.confirmToContinue"
								align="center" />
						</div>
					</td>
					<td colspan="2" align="left">
						<div class="ui-widget">
							<input type="button" onclick="window.history.back();"
								id='ticketbook_label_back' value="Back" />
						</div>
					</td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>