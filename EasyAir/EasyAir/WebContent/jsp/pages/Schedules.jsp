<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Search Flight Schedules</title>
<script src="http://code.jquery.com/jquery-1.7.js"
	type="text/javascript"></script>
<script
	src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"
	type="text/javascript"></script>
<link
	href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
	rel="stylesheet" type="text/css" />
<style>
#schedule_label_searchFlights {
	background: #9AC462;
	border: 0;
	border-radius: 5px;
}

#schedule_label_searchFlights:hover {
	background: #383;
}

heading {
	color: #36c;
}

#book_btn {
	background: #7DC25D;
	border: 0;
	border-radius: 5px;
	height: 25px; 
	width: 50px;
}

#book_btn:hover {
	background: #A5D190;
}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		$("input#schedule_source").autocomplete({
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
		$("input#schedule_destination").autocomplete({
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

		$("#schedule_departureDate").datepicker();
		$("#schedule_arrivalDate").datepicker();

		onChangeRadio();
	});

	function onChangeRadio() {
		if ($("#schedule_tripType1").is(':checked')) {
			$("#schedule_arrivalDate").attr("disabled", "true");
		} else {
			$("#schedule_arrivalDate").removeAttr("disabled");
		}
	}
	

	function setScheduleId(scheduleId) {
		document.getElementById("selectedSchedule").value = scheduleId;
	    document.forms[0].submit();
	}
</script>
</head>
<body>
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<s:form action="schedule.action" method="post">
		<table id="scheduleTable" style="border: 1 solid balck;"
			align="center">
			<thead>
				<tr>
					<td colspan="4" align="center">
						<div class="ui-widget">
							<h3 style="color: #8FBA56;">EasyAir</h3>
						</div>
					</td>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td colspan="1" align="left" width="100">
						<table>
							<tr>
								<td colspan="2">
									<div class="ui-widget">
										<h4 style="color: #9AC462;">Search Flights</h4>
									</div>
									<div class="ui-widget">
										<s:radio label="TripType" name="tripType"
											list="#{'1':'One way','2':'Round'}" value="1"
											onchange="onChangeRadio()" />
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr height="10"></tr>
				<tr>
					<th><div class="ui-widget">
							<font style="color: #36c">Fly from</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c">To</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c">Departure Date</font>
						</div></th>
					<th><div class="ui-widget">
							<font style="color: #36c">Arrival Date</font>
						</div></th>
				</tr>
				<tr height="10"></tr>
				<tr>
					<td>
						<div class="ui-widget">
							<s:textfield name="source" size="30" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:textfield name="destination" size="30" />
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:textfield name="departureDate" size="15"></s:textfield>
						</div>
					</td>
					<td>
						<div class="ui-widget">
							<s:textfield name="arrivalDate" size="15"></s:textfield>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="4" align="center">
						<div class="ui-widget">
							<s:submit method="search" key="label.searchFlights"
								align="center" />
						</div>
					</td>
				</tr>
			</tbody>
		</table>

		<table id="results" style="border: 10px solid balck;" align="center"
			cellpadding="5" cellspacing="5">
			<thead>
				<tr>
					<th><div class="ui-widget">Price</div></th>
					<th style="padding-right: 5px;"><div class="ui-widget">Airline</div></th>
					<th style="padding-right: 10px;"><div class="ui-widget">From</div></th>
					<th style="padding-right: 5px;"><div class="ui-widget">To</div></th>
					<th><div class="ui-widget">Trip Hours</div></th>
					<th>&nbsp;</th>
				</tr>
			</thead>
			<tbody>
				<s:iterator value="schedules">
					<tr>
						<td align="left"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="price" />
								$
							</div></td>
						<td align="left" style="padding-right: 5px;"><div
								class="ui-widget" style="font-size: 14px;">
								<s:property value="airlineName" />
							</div></td>
						<td style="padding-right: 10px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="source" />
							</div></td>
						<td style="padding-right: 5px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="destination" />
							</div></td>
						<td align="center"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="tripHours" />
							</div></td>
						<td colspan="4" align="center"><input type="submit" id="book_btn"
							name="method:bookTicket" value="Book"
							onclick="setScheduleId('<s:property value="scheduleId" />');" />  
							<%-- <div class="ui-widget">
							<s:submit method="hold" value="Hold" id="book_btn1"
								align="center" />
						</div> --%></td>
					</tr>
				</s:iterator>
			</tbody>
		</table>
		<s:hidden name="selectedSchedule" id="selectedSchedule"></s:hidden>
	</s:form>
</body>
</html>
