<%@ page language="java" contentType="text/html" pageEncoding="UTF-8" %>
<html>
<head>
	<title>test_2 page</title>
	<meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">

	<!--  Javascript FetchData from JSON -->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js" ></script>
	<script>
		$(document).ready(function(){
			
			function fetchData(){
				try{
					$.ajax({
						url:"fetchData.jsp", 
						type: "GET", 
						dataType: 'json',
						success: function(response){
							displayData(response);
						},
						error: function(xhr, status, error) {
							console.error('Error fetching data:',error);
						}
					});			
						
				}catch(error){
					$('#error-message').text(error);
				}
			}

			function displayData(response){
				var tableBody =$('#data-table tbody');
				tableBody.empty();
				response.forEach(function(item){
					var row ='<tr>'+
						'<td>' + item.id + '</td>'+
						'<td>' + item.name + '</td>'+
						'<td>' + item.ts + '</td>'+
						'</tr>';
					tableBody.append(row);
				});
			}

			fetchData();

			setInterval(fetchData, 100);

		});
	</script>

</head>
<body>

<div class="alert alert-info" role="alert">
	<pre><code>It is <%= new java.util.Date() %> now.</code></pre>
</div>

<div class="container">
	<h2>DB2 Query Test_2</h2>

	<p id="error-message" style="color: red;"></p>

	<table id= "data-table" class="table-striped table-bordered">
		<thead>
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>timestamp</th>
			</tr>
		</thead>

		
		<tbody>
		</tbody>
		

	</table>
</div>





<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
<!--
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.slim.min.js" integrity="sha512-sNylduh9fqpYUK5OYXWcBleGzbZInWj8yCJAU57r1dpSK9tP2ghf/SRYCMj+KsslFkCOt3TvJrX2AV/Gc3wOqA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
-->
</body>

</html>
