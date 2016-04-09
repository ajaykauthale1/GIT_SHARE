<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link
	href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
	rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="css/style.css">
<style>
#login_label_login {
	background: #9AC462;
	border: 0;
	border-radius: 5px;
	width: 5em;
	height: 2em;
}
#login_label_login:hover {
	background: #383;
}
</style>
<title>NewAccount</title>
<script>
if (frm.confirmpassword.value != frmpassword.value)
	{
	alert("Password confirmation does not match!");
		return false;
	}
</script>

</head>

<body background = "images/bg.jpg">
	<s:set name="theme" value="'simple'" scope="page" />
	<jsp:include page="LoginHeader.jsp"></jsp:include>
		<div class="ui-widget">
			
			<table id="NewAccountTable"
				style="border: 9px solid #A5BFFE; border-radius: 10px; padding: 2em;"
				align="center">
				
				<tr>
					<td>
						<h2 style="color: #A5BFFE;">Create a new account here</h2>
					</td>
				</tr>
				<tr>
					<td>
						<h4>User Name (Must be an Email)
							<span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:textfield name="username" key="label.username" size="25" /></td>
				</tr>
				<tr height="5"></tr>
				
				<form name="frm" method ="post" >
				<tr> 
					<td>
						<h4>Enter Password (Fill in 8 characters at least)
							<span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:password name="password" key="label.password" size="25" /></td>
				</tr>
				<tr height="5"></tr>
				
				<tr>
					<td>
						<h4>Confirm Password (Must match to above password)
							<span style="color: red;">*</span>
						</h4>
					</td>
					<td><s:password name="confirmpassword" key="label.confirmpassword" size="25" /></td>
				</tr>	
				</form>		
				
					
				<tr height="5"></tr>
				
				<tr>
					<td>
						<h4>Gender (M for Male; F for Female)</h4>
					</td>
					<td> 
						<s:radio label="Gender" name="gender"
							list="#{'1':'Male','2':'Female', '3':'Secret'}" value="1"onchange="onChangeRadio()" />
					</td>
				</tr>				
				<tr height="5"></tr>
				
				<tr>
					<td>
						<h4>Date of Birth <span style="color: red;">*</span>
					
					<s:select name="payment.expiryMonth"
							list="#{'Month' : 'Month' , 'Jan' : 'Jan', 'Feb' : 'Feb', 'Mar' : 'Mar',
							 'Apr' : 'Apr', 'May' : 'May', 'Jun' : 'Jun', 'Jul' : 'Jul', 'Aug' : 'Aug',
							 'Sep' : 'Sep', 'Oct' : 'Oct', 'Nov' : 'Nov', 'Dec' : 'Dec'}"></s:select>
						&nbsp; <s:select name="dateofbirth.expiryDay"
							list="#{'Day' : 'Day', '01' : '01' , '02' : '02', '03' : '03', '04' : '04',
							 '05' : '05', '06' : '06', '07' : '07', '08' : '08', '09' : '09',
							 '10' : '10', '11' : '11', '12' : '12', '13' : '13', '14' : '14', 
							 '15' : '15', '16' : '16', '17' : '17', '18' : '18', '19' : '19', 
							 '20' : '20', '21' : '21', '22' : '22', '23' : '23', '24' : '24', 
							 '25' : '25', '26' : '26', '27' : '27', '28' : '28', '29' : '29', 
							 '30' : '30', '31' : '31'}"
						></s:select>
						
						&nbsp; <s:select name="dateofbirth.expiryYear"
							list="#{'Year' : 'Year' , '2016' : '2016', '2015' : '2015', '2014' : '2014',
							 '2013' : '2013', '2012' : '2012', '2011' : '2011', '2010' : '2010',
							 '2009' : '2009', '2008' : '2008', '2007' : '2007', '2006' : '2006', 
							 '2005' : '2005', '2004' : '2004', '2003' : '2003', '2002' : '2002',
							 '2001' : '2001', '2000' : '2000', '1999' : '1999', '1998' : '1998', 
							 '1997' : '1997', '1996' : '1996', '1995' : '1995', '1994' : '1994', 
							 '1993' : '1993', '1992' : '1992', '1991' : '1991', '1990' : '1990', 
							 '1989' : '1989', '1988' : '1988', '1987' : '1987', '1986' : '1986', 
							 '1985' : '1985', '1984' : '1984', '1983' : '1983', '1982' : '1982', 
							 '1981' : '1981', '1980' : '1980', '1979' : '1979', '1978' : '1978', 
							 '1977' : '1977', '1976' : '1976', '1975' : '1975', '1974' : '1974', 
							 '1973' : '1973', '1972' : '1972', '1971' : '1971', '1970' : '1970'}"></s:select>
						</h4>
					</td>
					
				</tr>				
				<tr height="5"></tr>				
				
				<tr>
					<td>
						<h4>Address1 <span style="color: red;">*</span></h4>
					</td>
				
					<td><s:textfield name="address" key="label.address" size="30" /></td>
				</tr>				
				<tr height="5"></tr>					
								<tr>
					<td>
						<h4>Address2 </h4>
					</td>
					<td><s:textfield name="address" key="label.address" size="30" /></td>
				</tr>				
				<tr height="5"></tr>	
				<tr>
					<td>
						<h4>State <span style="color: red;">*</span></h4>
					</td>
					<td><s:textfield name="state" key="label.state" size="15" /></td>
				</tr>				
				<tr height="5"></tr>		
				
				<tr>
					<td>
						<h4>Country <span style="color: red;">*</span></h4>
					</td>
					<td><s:textfield name="country" key="label.country" size="20" /></td>
				</tr>				
				<tr height="5"></tr>		
				
				<tr>
					<td>
						<h4>Post Code </h4>
					</td>
					<td><s:textfield name="postcode" key="label.postcode" size="15" /></td>
				</tr>				
				<tr height="5"></tr>			
															
				<tr>
					<td>
						<h4>Contact Phone </h4>
					</td>
					<td><s:textfield name="postcode" key="label.postcode" size="20" /></td>
				</tr>				
				<tr height="5"></tr>					
								
				<tr>
					<td>					
						<input type="submit" value="Submit" onclick = "return" val();/>
						<input type="reset" value="Reset" />								
					</td>
				</tr>
				
				
			</table>
		</div>
</body>
</html>
