<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<html>

<head>
<title>Ticket</title>
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
#printButton {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	width: 200px;
}

#printButton:hover {
	background: #6286DE;
}
</style>
<script>
    function printDiv() {
      var divToPrint = document.getElementById('ticketDetails');
      newWin = window.open("");
      newWin.document.write(divToPrint.outerHTML);
      newWin.print();
      newWin.close();
   }
</script>
</head>

<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<div class="ui-widget" id="ticketDetails">
		<table id="ticketTable" style="border: 1 solid balck;" align="center">
			<thead>
				<tr>
					<th colspan="2" align="left">
						<div class="ui-widget">Ticket Details</div>
					</th>
				</tr>
				<tr height="15px;">
				</tr>
				<tr>
					<td><s:label name="schedule.flight.source" /> to <s:label
							name="schedule.flight.destination" /></td>
					<td width="300px"></td>
					<td><s:label name="schedule.departureDate" /></td>
				</tr>
				<tr height="10px"></tr>
				<tr>
					<td><s:label name="schedule.flight.airline.name" /></td>
					<td></td>
					<td><s:label name="ticket.seatNo"></s:label></td>
				</tr>
				<tr>
					<td colspan="3"><hr color="black" /></td>
				</tr>
				<tr height="20px"></tr>
				<tr>
					<td><s:label name="schedule.flight.source" /> - <s:label
							name="schedule.departureTime" /></td>
					<td></td>
					<td><s:label name="schedule.flight.destination" /> - <s:label
							name="schedule.arrivalTime" /></td>
				</tr>
				<tr height="3px"></tr>
				<tr>
					<td><s:label name="schedule.departureDate" /></td>
					<td><s:label name="schedule.tripHours" /></td>
					<td><s:label name="schedule.arrivalDate" /></td>
				</tr>
			</thead>
			<tr height="15px"></tr>
			<tbody>
				<tr>
					<td>Traveler</td>
					<td>PNR</td>
					<td>Ticket No.</td>
				</tr>
				<tr height="5px"></tr>
				<tr>
					<td><s:label name="user.userId" /></td>
					<td><s:label name="ticket.pnrNumber" /></td>
					<td><s:label name="ticket.ticketNumber" /></td>
				</tr>
			</tbody>
		</table>
	</div>
	<div style="height: 20px;"></div>
	<div align="center" class="ui-widget">
		<INPUT TYPE="button" onClick="printDiv()" id="printButton" value="Print Ticket">
	</div>
</body>
</html>