<%@ page language="java" contentType="text/html; charset=UTF-8"pageEncoding="UTF-8" %>
<%
	try{
		javax.naming.Context initialContext = new javax.naming.InitialContext();
		javax.sql.DataSource dataSource = (javax.sql.DataSource)initialContext.lookup("/jdbc/db2DataSource");

		java.sql.Connection conn = dataSource.getConnection();

		String sql = "SELECT * FROM test";
		java.sql.PreparedStatement stmt = conn.prepareStatement(sql);

		java.sql.ResultSet rs = stmt.executeQuery();

        //JSON STRING BUILDER
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        // initialize first
        boolean first = true;

		while(rs.next()){

            if (!first){ 
                json.append(",");
            }

            json.append("{");
            json.append("\"id\":\"").append(rs.getString("id")).append("\",");
            json.append("\"name\":\"").append(rs.getString("name")).append("\",");
            json.append("\"ts\":\"").append(rs.getString("ts")).append("\"");
            json.append("}");

            first = false;

        }
        json.append("]");

        response.setContentType("application/json");
        response.getWriter().write(json.toString());

		// close objects
		rs.close();
		stmt.close();
		conn.close();

	}catch(javax.naming.NamingException | java.sql.SQLException e){
		out.println("Error:" +e.getMessage());
	}
%>