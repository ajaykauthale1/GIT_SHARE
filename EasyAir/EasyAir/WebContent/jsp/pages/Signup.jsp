<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
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
#signup_label_signup, #reset {
	background: #AEC3F5;
	border: 0;
	border-radius: 5px;
	width: 200px;
}

#signup_label_signup:hover, #reset:hover {
	background: #6286DE;
}
</style>
<title>NewAccount</title>
<script lang="text/javascript">
	$(document).ready(function() {
		$("#signup_dateOfBirth").datepicker({
			changeMonth : true,
			changeYear : true,
			yearRange : '-100:+0'
		});

		$("#reset").click(function() {
			$(this).closest('form').find("input[type=text], textarea").val("");
		});
		
		$('#signup_label_signup').click(function() {
			var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
			if ($('#signup_firstName').val() == '') {
				alert('First name can not be left blank');
				$('#signup_firstName').focus();
				return false;
			} else if ($('#signup_lastName').val() == '') {
				alert('Last name can not be left blank');
				$('#signup_lastName').focus();
				return false;
			} else if ($('#signup_email').val() == '') {
				alert('Email can not be left blank');
				$('#signup_email').focus();
				return false;
			} else if (emailReg.test( $('#signup_email').val()) == false) {
				alert('Enter a valid email.');
				$('#signup_email').focus();
				return false;
			} else if ($('#signup_password').val() == '') {
				alert('Password can not be left blank');
				$('#signup_password').focus();
				return false;
			} else if ($('#signup_password').val().length < 8) {
				alert('Password length should be atleast 8.');
				$('#signup_password').focus();
				return false;
			} else if ($('#signup_password').val() != $('#signup_repeatPassword').val()) {
				alert('Passwords does not matched.');
				$('#signup_password').focus();
				return false;
			} else if ($('[name="gender"]').val().length == '') {
				alert('Gender can not be left empty.');
				$('[name="gender"]').focus();
				return false;
			} else if ($('#signup_dateOfBirth').val() == '') {
				alert('Date of birth can not be empty.');
				$('#signup_dateOfBirth').focus();
				return false;
			} else if ($('#address1').val() == '') {
				alert('Address can not be empty.');
				$('#address1').focus();
				return false;
			} else if ($('#state').val() == '') {
				alert('State can not be empty.');
				$('#state').focus();
				return false;
			} else if ($('#country').val() == '') {
				alert('Country can not be empty.');
				$('#country').focus();
				return false;
			} 
			return true;
		});
	});
</script>
</head>

<body background="images/bg.jpg">
	<font color="red"><s:iterator value="actionErrors">
			<s:property />
			<br />
		</s:iterator> </font>
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="LoginHeader.jsp"></jsp:include>

	<s:form action="signup.action" method="post">
		<div class="ui-widget">
			<table id="NewAccountTable"
				style="border: 4px solid #A5BFFE; border-radius: 10px; padding: 2em;"
				align="center">

				<tr>
					<td>
						<h2 style="color: #A5BFFE;">Create a new account here</h2>
					</td>
				</tr>
				<tr>
					<td>
						<h4>
							First Name <span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:textfield name="firstName" key="label.username" size="25" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>
							Last Name <span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:textfield name="lastName" key="label.username" size="25" /></td>
				</tr>
				<tr height="5"></tr>


				<tr>
					<td>
						<h4>
							User Name (Must be an Email) <span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:textfield name="email" key="label.username" size="25" /></td>
				</tr>
				<tr height="5"></tr>
				<tr>
					<td>
						<h4>
							Enter Password (Fill in 8 characters at least) <span
								style="color: red;">*</span>
						</h4>
					</td>
					<td><s:password name="password" key="label.password" size="25" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>
							Confirm Password (Must match to above password) <span
								style="color: red;">*</span>
						</h4>
					</td>
					<td><s:password name="repeatPassword"
							key="label.repeatPassword" size="25" /></td>
				</tr>


				<tr height="5"></tr>

				<tr>
					<td>
						<h4>Gender (M for Male; F for Female)</h4>
					</td>
					<td><s:radio label="Gender" name="gender"
							list="#{'Male':'Male','Female':'Female'}" value="Male"/></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>
							Date of Birth <span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:textfield name="dateOfBirth"></s:textfield></td>

				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>
							Address1 <span style="color: red;">*</span>
						</h4>
					</td>

					<td><input type="text" size="30" id="address1" /></td>
				</tr>
				<tr height="5"></tr>
				<tr>
					<td>
						<h4>Address2</h4>
					</td>
					<td><input type="text" size="30" /></td>
				</tr>
				<tr height="5"></tr>
				<tr>
					<td>
						<h4>
							State <span style="color: red;">*</span>
						</h4>
					</td>
					<td><input type="text" size="30" id="state" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>
							Country <span style="color: red;">*</span>
						</h4>
					</td>
					<td><input type="text" size="30" id="country" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>Post Code</h4>
					</td>
					<td><input type="text" size="30" id="zipcode" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td>
						<h4>Contact Phone</h4>
					</td>
					<td><input type="text" size="30" id="contactPhone" /></td>
				</tr>
				<tr height="5"></tr>

				<tr>
					<td align="right"><s:submit method="signUp" key="label.signup"
							align="center" /></td>
					<td align="left"><input type="reset" value="Reset" id="reset" /></td>
				</tr>
				<tr height="10px">
					<td><font color="green"><s:iterator
								value="actionMessages">
								<s:property />
								<br />
							</s:iterator> </font></td>
				</tr>
				<tr>
			</table>
		</div>
	</s:form>
</body>
</html>
