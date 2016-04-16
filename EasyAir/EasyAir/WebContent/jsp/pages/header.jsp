<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.easyair.model.beans.UserBean"%>
<%@page import="com.easyair.utils.Constants"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="js/jquery.leanModal.min.js"></script>
<link rel="stylesheet" href="css/popup.css">
<%
	UserBean user = (UserBean) request.getSession().getAttribute(Constants.USER);
	String username = "";
	if (user != null) {
		username = user.getFirstname();
	}
%>

<script type="text/javascript">
	
</script>
</head>
<body>
	<s:set name="theme" value="'simple'" scope="page" />
	<div align="left" style="background-color: #02153F;">
		<s:form action="login.action">
			<table>
				<tr>
					<td width="50px"></td>
					<td colspan="4" align="center">
						<div class="ui-widget">
							<h3 style="color: #A5BFFE;">EasyAir</h3>
						</div>
					</td>
					<%
						if (user != null) {
								if (!user.isAdmin()) {
					%>
					<td width="800px"></td>
					<%
						} else {
					%>
					<td width="950px"></td>
					<%
						}
					%>
					<td colspan="5" align="right">
						<div class="ui-widget" style="color: #A5BFFE">
						<font color="#A5BFFE">
							Welcome
							<%=username%>
						</font>
							|
							<%
							if (!user.isAdmin()) {
						%><a href="order.action" style="color: #A5BFFE;">My Orders</a> |<%
							}
						%>
							<s:submit method="logout" key="label.logout" align="center"
								cssStyle=" background-color: transparent; text-decoration: underline;
 									 border: none; color: #A5BFFE; cursor: pointer;" />
						</div>
					</td>
					<%
						} else {
					%>
					<td width="1000"></td>
					<td colspan="5" align="right">
						<div class="ui-widget" style="color: #A5BFFE">
							<a href="login.action" style="color: #A5BFFE">Log In</a> | <a href="signup.action" style="color: #A5BFFE;">Sign
								Up</a>
							<%
								}
							%>
						</div>
					</td>
				</tr>
			</table>
		</s:form>
	</div>
</body>