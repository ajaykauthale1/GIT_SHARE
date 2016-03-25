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
	background: #9AC462;
	border: 0;
	border-radius: 5px;
}

#ticketbook_label_confirmToContinue:hover, #ticketbook_label_back:hover
	{
	background: #383;
}
</style>
<title>Confirmation</title>
</head>
<body>
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<s:form action="ticketbook.action">
		<div class="ui-widget" align="center">
			<table id="bookingTable" style="border: 1 solid balck;">
				<tr>
					<td colspan="4">Price Details</td>
				</tr>
				<tr>
					<td>Base Fare</td>
					<td>Tax Fee</td>
					<td>Total</td>
				</tr>
				<tr>
					<td><s:property value="schedule.price" /></td>
					<td>$0</td>
					<td><s:property value="schedule.price" /></td>
				</tr>
				<tr height="20px"></tr>
				<tr>
					<td colspan="4">Trip Details</td>
				</tr>
				<tr>
					<th><div class="ui-widget">
							<font style="color: #36c" size="3px">Fly from</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c" size="3px">To</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c" size="3px">Departure Date</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c" size="3px">Arrival Date</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c" size="3px">Departure Time</font>
						</div></th>
				</tr>
				<tr height="10"></tr>
				<tr>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.flight.source" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.flight.destination" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.departureDate" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.arrivalDate" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:property value="schedule.departureTime" />
						</div>
					</td>
				</tr>
				<tr align="center">
					<td>
						<div class="ui-widget">
							<s:submit method="confirm" key="label.confirmToContinue"
								align="center" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<input type="button" onclick="window.history.back();" id='ticketbook_label_back' value="Back"/> 
						</div>
					</td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>