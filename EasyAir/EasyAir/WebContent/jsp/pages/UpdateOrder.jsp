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
<title>Update Order</title>
<style>
#orderUpdate_label_return_schedule, #ticketbook_label_back,
	#orderUpdate_label_cancelOrder {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	height: 25px;
	width: 200px;
}

#orderUpdate_label_return_schedule:hover, #ticketbook_label_back:hover,
	#orderUpdate_label_cancelOrder:hover {
	background: #6286DE;
}
</style>
<script>
	$(document).ready(function() {
		$('#orderUpdate_label_cancelOrder').click(function() {
			var strconfirm = confirm("Are you sure you want to cancel order?");
			if (strconfirm == true) {
				return true;
			} else {
				return false;
			}
		});
	});
</script>
</head>
<body>
<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<div style="height: 10px;"></div>
	<s:form action="orderUpdate.action" method="post">
		<div style="font-family: Verdana, Arial, sans-serif;" align="center">
			<table id="orderTable" style="border: 1 solid balck;">
				<s:if test="%{getOrder().isCancelled()}">
					<tr>
						<td colspan="8" align="center"><font color="red"> This
								order has been cancelled on <s:property
									value="order.lastUpdatedOn" />
						</font></td>
					</tr>
				</s:if>
				<tr>
					<th align="left" colspan="6"><font style="color: #36c">Ticket
							Details</font></th>
				</tr>
				<tr height="10px">
				<tr>
				<tr>
					<td>Ticket Number:&nbsp;</td>
					<td><s:property value="ticket.ticketNumber" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>Ticket Price:&nbsp;</td>
					<td><s:property value="ticket.price" />
					<td>Trip Hours:&nbsp;</td>
					<td><s:property value="schedule.tripHours" /></td>
				</tr>
				<tr>
					<td>Class:&nbsp;</td>
					<td><s:property value="ticket.chosenClass" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>Seat No:&nbsp;</td>
					<td><s:property value="ticket.seatNo" /></td>
				</tr>
				<tr height="10px"></tr>
				<tr>
					<td>Flight Number:&nbsp;</td>
					<td><s:property value="schedule.flight.flightNumber" /></td>
				</tr>
				<tr height="5px"></tr>
				<tr>
					<td>From:&nbsp;</td>
					<td><s:property value="schedule.flight.source" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>To:&nbsp;</td>
					<td><s:property value="schedule.flight.destination" /></td>
				</tr>
				<tr>
					<td>Departure Date:&nbsp;</td>
					<td><s:property value="schedule.departureDate" /></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td>Arrival Date:&nbsp;</td>
					<td><s:property value="schedule.arrivalDate" /></td>
				</tr>
				<tr height="10px">
				<tr>
				<tr>
					<th align="left" colspan="6"><font style="color: #36c">Luggage
							Details</font></th>
				</tr>
				<tr height="10px">
				</tr>
				<s:iterator value="baggages" status="stat">
					<s:if test="%{getBaggages().isEmpty()}">
						<tr>
							<td>Luggage details are not available.</td>
						</tr>
					</s:if>
					<s:else>
						<tr>
							<td>Type:&nbsp;</td>
							<td><s:property value="type" /></td>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td>Size:&nbsp;</td>
							<td><s:property value="size" /></td>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td>Weight:&nbsp;</td>
							<td><s:property value="weight" /></td>
						</tr>
						<tr height="5px"></tr>
					</s:else>
				</s:iterator>
				<tr height="10px"></tr>
				<s:if test="%{getOrder().isCancelled()}">
					<tr>
						<td colspan="4" align="right">
							<div class="ui-widget">
								<s:submit method="schedule" key="label.return.schedule"
									align="center" />
							</div>
						</td>
						<td colspan="4" align="left">
							<div class="ui-widget">
								<input type="button" onclick="window.history.back();"
									id='ticketbook_label_back' value="Back" />
							</div>
						</td>
					</tr>
				</s:if>
				<tr height="10px"></tr>
				<s:else>
					<tr>
						<td colspan="3" align="right" style="padding: 10px;">
							<div class="ui-widget">
								<s:submit method="schedule" key="label.return.schedule"
									align="center" />
							</div>
						</td>
						<td colspan="1" align="center" style="padding: 10px;">
							<div class="ui-widget">
								<input type="button" onclick="window.history.back();"
									id='ticketbook_label_back' value="Back" />
							</div>
						</td>
						<td colspan="4" align="left" style="padding: 10px;">
							<div class="ui-widget">
								<s:submit method="cancel" key="label.cancelOrder" align="center" />
							</div>
						</td>
					</tr>
				</s:else>
				<tr height="10px"></tr>
				<tr>
					<td colspan="8" align="center"><font color="green"><s:iterator
								value="actionMessages">
								<s:property />
								<br />
							</s:iterator> </font></td>
				</tr>
			</table>
		</div>
	</s:form>
</body>
</html>