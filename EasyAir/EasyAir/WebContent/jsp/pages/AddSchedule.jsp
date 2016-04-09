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
#addSchedule_label_addSchedule {
	background: #7DC25D;
	border: 0;
	border-radius: 5px;
	height: 30px;
	width: 70px;
}

#addSchedule_label_addSchedule:hover {
	background: #A5D190;
}
</style>
<script type="text/javascript">
	$(document).ready(function() {
		$("#addSchedule_schedule_arrivalTime").attr("disabled", "true");

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

	$(document).ready(function() {
		$("input#addSchedule_schedule_flight_destination").autocomplete({
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

	function changeArrivalTime() {
		var tripHours = document
				.getElementById("addSchedule_schedule_tripHours");
		var arrivaleTime = document
				.getElementById("addSchedule_schedule_arrivalTime");
		var departureTime = document
				.getElementById("addSchedule_schedule_departureTime");
		arrivaleTime.value = ((parseInt(departureTime.value) + parseInt(tripHours.value)) % 24);
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
						<td><s:select list="airlines" name="schedule.flight.airline"></s:select></td>
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
						<td><s:textfield name="schedule.arrivaleDate" size="30" /></td>
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
					</tr>
					<tr height="10px"></tr>
					<tr>
						<td colspan="5" align="center">
							<div class="ui-widget">
								<s:submit method="addSchedule" key="label.addSchedule"
									align="center" />
							</div>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</s:form>

</body>
</html>