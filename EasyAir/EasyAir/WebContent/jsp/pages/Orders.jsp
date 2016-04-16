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
<title>My Orders</title>
<script>
	function setOrderId(orderId) {
		document.getElementById("selectedOrderId").value = orderId;
		document.forms[0].submit();
	}
	
	function setTicketId(ticketId) {
		document.getElementById("selectedTicketId").value = ticketId;
		document.forms[0].submit();
	}
</script>
<style>
#order_label_return_schedule {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	height: 25px;
	width: 200px;
}

#order_label_return_schedule:hover {
	background: #6286DE;
}
</style>
</head>
<body>
<body background="images/bg.jpg">
	<s:actionerror />
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="header.jsp"></jsp:include>

	<s:form action="order.action" method="post">
		<table id="results" style="border: 10px solid balck;" align="center"
			cellpadding="5" cellspacing="5">
			<thead>
				<s:if test="%{getOrders().isEmpty()}">
					<tr>
						<td>Orders are empty.</td>
					</tr>
				</s:if>
				<s:else>
					<tr>
						<th><div class="ui-widget">Order Number</div></th>
						<th style="padding-right: 5px;"><div class="ui-widget">Ticket
								Id</div></th>
						<th style="padding-right: 10px;"><div class="ui-widget">Last
								Updated</div></th>
						<th style="padding-right: 5px;"><div class="ui-widget">Active</div></th>
					</tr>
				</s:else>
				<s:iterator value="orders" status="od">
					<tr>
						<td align="left"><div class="ui-widget"
								style="font-size: 14px;">
								<input type="submit" name="method:orderUpdate"
									value="<s:property value="orderNumber" />"
									onclick="setOrderId('<s:property value="orderId" />');"
									style="background-color: transparent; text-decoration: underline; border: none; color: blue; cursor: pointer;" />
							</div></td>
						<s:if test="cancelled==	false">
							<td align="center"><div class="ui-widget"
									style="font-size: 14px;">
									<input type="submit" name="method:printTicket" align="top"
										value="<s:property value="ticket" />"
										onclick="setTicketId('<s:property value="ticket" />');"
										style="background-color: transparent; text-decoration: underline; border: none; color: blue; cursor: pointer;" />
								</div></td>
						</s:if>
						<s:else>
							<td align="center"><div class="ui-widget"
									style="font-size: 14px;">
									<s:property value="ticket" />
								</div></td>
						</s:else>
						<td align="left"><div class="ui-widget"
								style="font-size: 14px;">
								<s:property value="lastUpdatedOn" />
							</div></td>
						<td align="center"><div class="ui-widget"
								style="font-size: 14px;">
								<s:if test="cancelled==	false">
									Yes	
								</s:if>
								<s:else>
									No
								</s:else>
							</div></td>
					</tr>
				</s:iterator>
				<tr>
					<td colspan="4" align="center">
						<div class="ui-widget">
							<s:submit method="schedule" key="label.return.schedule"
								align="center" />
						</div>
					</td>
				</tr>
			</thead>
		</table>
		<s:hidden name="selectedOrderId" id="selectedOrderId"></s:hidden>
		<s:hidden name="selectedTicketId" id="selectedTicketId"></s:hidden>
	</s:form>
</body>
</html>