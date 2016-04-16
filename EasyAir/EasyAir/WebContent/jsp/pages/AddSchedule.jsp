<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page import="com.easyair.model.beans.UserBean"%>
<%@page import="com.easyair.utils.Constants"%>
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
<title>Add Schedule</title>
<style>
#addSchedule_label_addSchedule, #ticketbook_label_back {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	height: 30px;
	width: 200px;
}

#addSchedule_label_addSchedule:hover, #ticketbook_label_back:hover {
	background: #6286DE;
}
</style>
<script type="text/javascript">
	$(document).ready(function() {

		$("input#addSchedule_schedule_flight_source").autocomplete({
			width : 300,
			max : 10,
			delay : 100,
			minLength : 1,
			autoFocus : true,
			cacheLength : 1,
			scroll : true,
			highlight : false,
			source : function(request, response) {
				$.ajax({
					url : "AjaxAirportRequest",
					dataType : "json",
					data : request,
					success : function(data, textStatus, jqXHR) {
						console.log(data);
						var items = data;
						response(items);
					},
					error : function(jqXHR, textStatus, errorThrown) {
						console.log(textStatus);
					}
				});
			}

		});
	});

	$(document)
			.ready(
					function() {
						$("input#addSchedule_schedule_flight_destination")
								.autocomplete(
										{
											width : 300,
											max : 10,
											delay : 100,
											minLength : 1,
											autoFocus : true,
											cacheLength : 1,
											scroll : true,
											highlight : false,
											source : function(request, response) {
												$
														.ajax({
															url : "AjaxAirportRequest",
															dataType : "json",
															data : request,
															success : function(
																	data,
																	textStatus,
																	jqXHR) {
																console
																		.log(data);
																var items = data;
																response(items);
															},
															error : function(
																	jqXHR,
																	textStatus,
																	errorThrown) {
																console
																		.log(textStatus);
															}
														});
											}

										});

						$("#addSchedule_schedule_departureDate").datepicker();
						$("#addSchedule_schedule_arrivalDate").datepicker();

						$('#addSchedule_label_addSchedule')
								.click(
										function() {
											if ($(
													'#addSchedule_schedule_flight_source')
													.val() == '') {
												alert('Fly from can not be left blank');
												$(
														'#addSchedule_schedule_flight_source')
														.focus();
												return false;
											} else if ($(
													'#addSchedule_schedule_flight_destination')
													.val() == '') {
												alert('To can not be left blank');
												$(
														'#addSchedule_schedule_flight_destination')
														.focus();
												return false;
											} else if ($(
													'#addSchedule_schedule_departureDate')
													.val() == '') {
												alert('Departure date can not be left blank');
												$(
														'#addSchedule_schedule_departureDate')
														.focus();
												return false;
											} else if ($(
													'#addSchedule_schedule_arrivalDate')
													.val() == '') {
												alert('Arrival date can not be left blank');
												$(
														'#addSchedule_schedule_arrivalDate')
														.focus();
												return false;
											} else if ($(
													'#addSchedule_schedule_departureTime')
													.val() == '') {
												alert('Departure time can not be left blank');
												$(
														'#addSchedule_schedule_departureTime')
														.focus();
												return false;
											} else if ($(
													'#addSchedule_schedule_tripHours')
													.val() == '0.0'
													|| $(
															'#addSchedule_schedule_tripHours')
															.val() == '') {
												alert('Trip hours can not zero');
												$(
														'#addSchedule_schedule_tripHours')
														.focus();
												return false;
											} else if (parseFloat($(
													'#addSchedule_schedule_price')
													.val()) <= 0
													|| $(
															'#addSchedule_schedule_price')
															.val() == '') {
												alert('Price should be greater than zero.');
												$('#addSchedule_schedule_price')
														.focus();
												return false;
											}
											return true;
										});

					});

	function changeArrivalTime() {
		var tripHours = document
				.getElementById("addSchedule_schedule_tripHours");
		var arrivaleTime = document
				.getElementById("addSchedule_schedule_arrivalTime");
		var departureTime = document
				.getElementById("addSchedule_schedule_departureTime");
		arrivaleTime.value = ((parseFloat(departureTime.value) + parseFloat(tripHours.value)) % 24).toString();
		
		document.getElementById("arrivalTime").value = ((parseFloat(departureTime.value) + parseFloat(tripHours.value)) % 24).toString();
		;
	}
</script>
</head>
<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<s:form action="addSchedule.action" name="frm">
		<div
			style="font-family: Verdana, Arial, sans-serif; margin-top: 10px;"
			align="center" class="ui-widget">
			<table id="flightDetails" style="border: 1 solid balck;">
				<thead>
					<tr>
						<th align="left" colspan="4"><font style="color: #36c">Flight
								Details</font></th>
					</tr>
				</thead>
				<tr height="10px">
				</tr>
				<tbody>
					<tr>
						<td>Fly from:&nbsp;</td>
						<td><s:textfield name="schedule.flight.source" size="30" /></td>
						<td>&nbsp;&nbsp;&nbsp;</td>
						<td>To:&nbsp;</td>
						<td><s:textfield name="schedule.flight.destination" size="30" /></td>
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td>Airline:&nbsp;</td>
						<td><s:select list="airlines"
								name="schedule.flight.airline.airlineId"></s:select></td>
					<tr>
					<tr height="10px"></tr>
					<tr>
						<th align="left" colspan="4"><font style="color: #36c">Schedule
								Details</font></th>
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td>Departure Date:&nbsp;</td>
						<td><s:textfield name="schedule.departureDate" size="30" /></td>
						<td>&nbsp;&nbsp;&nbsp;</td>
						<td>Arrival Date:&nbsp;</td>
						<td><s:textfield name="schedule.arrivalDate" size="30" /></td>
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td>Departure Time:&nbsp;</td>
						<td><s:textfield name="schedule.departureTime" size="30"
								onchange="changeArrivalTime();" /></td>
						<td>&nbsp;&nbsp;&nbsp;</td>
						<td>Arrival Time :&nbsp;</td>
						<td><s:textfield name="schedule.arrivalTime" size="30" /></td>
					<tr>
					<tr height="10px"></tr>
					<tr>
						<td>Trip Hours:&nbsp;</td>
						<td><s:textfield name="schedule.tripHours"
								onchange="changeArrivalTime();" /></td>
						<td>&nbsp;&nbsp;&nbsp;</td>
						<td>Price:&nbsp;</td>
						<td><s:textfield name="schedule.price" /></td>
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td colspan="2" align="right">
							<div class="ui-widget">
								<s:submit method="addSchedule" key="label.addSchedule"
									align="center" />
							</div>
						</td>
						<td colspan="3" align="left">
							<div class="ui-widget">
								<input type="button" onclick="window.history.back();"
									id='ticketbook_label_back' value="Back" />
							</div>
						</td>
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td colspan="5" align="center">
							<div class="ui-widget">
								<font color="green"><s:iterator value="actionMessages">
										<s:property />
										<br />
									</s:iterator></font>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</s:form>

	<s:hidden name="arrivalTime" id="arrivalTime"></s:hidden>

</body>
</html>