<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<%@page import="com.easyair.model.beans.UserBean"%>
<%@page import="com.easyair.utils.Constants"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<%
	UserBean user = (UserBean) request.getSession().getAttribute(Constants.USER);
	boolean isAdmin = false;
	if (user != null) {
		isAdmin = user.isAdmin();
	}
%>
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
<link rel="stylesheet" href="css/style.css">
<style>
#schedule_label_searchFlights {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	width: 200px;
}

#schedule_label_searchFlights:hover {
	background: #6286DE;
}

heading {
	color: #36c;
}

#book_btn2 {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	height: 25px;
	width: 200px;
}

#book_btn, #book_btn1, #book_btn3 {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	height: 25px;
	width: 200px;
}

#book_btn:hover, #book_btn1:hover, #book_btn2:hover, #book_btn3:hover {
	background: #6286DE;
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

		$('#schedule_label_searchFlights').click(function() {
			if ($('#schedule_source').val() == '') {
				alert('Fly from can not be left blank');
				$('#schedule_source').focus();
				return false;
			} else if ($('#schedule_destination').val() == '') {
				alert('To can not be left blank');
				$('#schedule_destination').focus();
				return false;
			} else if ($('#schedule_departureDate').val() == '') {
				alert('Departure date can not be left blank');
				$('#schedule_departureDate').focus();
				return false;
			}

			isPrevDate($('#schedule_departureDate').val());
			return true;
		});
	});

	function isPrevDate(Startdate) {
		if (Startdate.length != 0 && Startdate != '') {
			var start_date = Startdate.split('-');
			start_date = start_date[1] + "/" + start_date[2] + "/"
					+ start_date[0];
			var a = new Date(start_date);
			var today = new Date();
			var day = today.getDate();
			var mon = today.getMonth() + 1;
			var year = today.getFullYear();
			today = (mon + "/" + day + "/" + year);
			var today = new Date(today);
			if (today.getTime() > a.getTime()) {
				alert("Departure date can not be in the past.");
				return false;
			}
		}
	}

	function setScheduleId(scheduleId) {
		document.getElementById("selectedSchedule").value = scheduleId;
		document.forms[0].submit();
	}
</script>
</head>
<body background="images/bg.jpg">
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>
	<s:actionerror />
	<s:form action="schedule.action" method="post">
		<table id="scheduleTable" style="border: 1 solid balck;"
			align="center">
			<tbody>
				<tr>
					<td colspan="2" align="left">
						<div class="ui-widget">
							<h4 style="color: #36c;">Search Flights</h4>
						</div>
					</td>
				</tr>
				<tr height="10"></tr>
				<tr>
					<th align="left"><div class="ui-widget">
							<font style="color: black">Fly from</font>
						</div></th>
					<th align="left"><div class="ui-widget">
							<font style="color: black">To</font>
						</div></th>
					<th align="left"><div class="ui-widget">
							<font style="color: black">Departure Date</font>
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
					<%-- <td>
						<div class="ui-widget">
							<s:textfield name="arrivalDate" size="15"></s:textfield>
						</div>
					</td> --%>
				</tr>
				<tr height="10px">
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
				<s:if test="%{getSchedules().isEmpty()}">
					<tr>
						<td>Schedules are empty.</td>
					</tr>
				</s:if>
				<s:else>
					<tr>
						<td></td>
						<td colspan="4" align="center"><font color="green"><s:iterator
									value="actionMessages">
									<s:property />
									<br />
								</s:iterator> </font></td>
					</tr>
					<tr>
						<th><div class="ui-widget">Price</div></th>
						<th style="padding-right: 5px;"><div class="ui-widget">Airline</div></th>
						<th style="padding-right: 10px;"><div class="ui-widget">From</div></th>
						<th style="padding-right: 5px;"><div class="ui-widget">To</div></th>
						<th><div class="ui-widget">Trip Hours</div></th>
						<th>&nbsp;</th>
					</tr>
				</s:else>
			</thead>
			<tbody>
				<%
					if (!isAdmin) {
				%>
				<s:iterator value="schedules">
					<tr>
						<td align="left"><div class="ui-widget"
								style="font-size: 14px;">
								$
								<s:property value="price" />
							</div></td>
						<td align="left" style="padding-right: 5px;"><div
								class="ui-widget" style="font-size: 14px;">
								<s:property value="airlineName" />
							</div></td>
						<td style="padding-right: 10px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="fromSource" />
							</div></td>
						<td style="padding-right: 5px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="toDestination" />
							</div></td>
						<td align="center"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="tripHours" />
							</div></td>
						<td colspan="3" align="center"><input type="submit"
							id="book_btn" name="method:bookTicket" value="Book"
							onclick="setScheduleId('<s:property value="scheduleId" />');" />
						</td>
					</tr>
				</s:iterator>
				<%
					} else {
				%>
				<s:iterator value="schedules" id="shdl" status="stat">
					<tr>
						<td align="left"><div class="ui-widget"
								style="font-size: 14px;">
								<s:textfield name="schedules[%{#stat.index}].price" />
								<s:hidden name="schedules[%{#stat.index}].scheduleId" />
								<s:hidden name="schedules[%{#stat.index}].flightId" />
								<s:hidden name="schedules[%{#stat.index}].airlineId" />
								$
							</div></td>
						<td align="left" style="padding-right: 5px;"><div
								class="ui-widget" style="font-size: 14px;">
								<s:property value="airlineName" />
							</div></td>
						<td style="padding-right: 10px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="fromSource" />
							</div></td>
						<td style="padding-right: 5px;"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="toDestination" />
							</div></td>
						<td align="center"><div class="ui-widget"
								style="font-size: 14px;">
								<s:textfield name="schedules[%{#stat.index}].tripHours" />
							</div></td>
						<td colspan="4" align="center"><input type="submit"
							id="book_btn1" name="method:updateSchedule" value="Update"
							onclick="setScheduleId('<s:property value="scheduleId" />');" />
						</td>
						<td colspan="4" align="center"><input type="submit"
							id="book_btn3" name="method:deleteSchedule" value="Delete"
							onclick="setScheduleId('<s:property value="scheduleId" />');" />
						</td>
					</tr>
				</s:iterator>
				<%
					}
				%>
			</tbody>
		</table>
		<%
			if (isAdmin) {
		%>
		<div align="center" class="ui-widget">
			<input type="submit" id="book_btn2" name="method:addSchedule"
				value="Add New" />
		</div>
		<%
			}
		%>
		<s:hidden name="selectedSchedule" id="selectedSchedule"></s:hidden>
	</s:form>
</body>
</html>
