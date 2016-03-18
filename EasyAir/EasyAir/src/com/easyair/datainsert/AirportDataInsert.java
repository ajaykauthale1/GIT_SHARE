/**
 * 
 */
package com.easyair.datainsert;

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;


/**
 * One time data insert
 * 
 * @author Ajay
 *
 */
public class AirportDataInsert {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			final String DB_URL = "jdbc:mysql://localhost:3306/easyair";

			// Database credentials
			String USER = "root";
			final String PASS = "root";

			Connection conn = null;
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(DB_URL, USER, PASS);
			PreparedStatement stmt = conn.prepareStatement("INSERT INTO airports(airport, code)  VALUES (?, ?)");

			BufferedReader br = new BufferedReader(new FileReader("resources\\airport_codes.txt"));
			String line;
			while ((line = br.readLine()) != null) {
				int lastSpace = line.lastIndexOf("	");
				String airportCity = line.substring(0, lastSpace);
				String code = line.substring(lastSpace + 1);
				stmt.setString(1, airportCity);
				stmt.setString(2, code);
				stmt.executeUpdate();

			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
