/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.hibernate.classic.Session;

import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
public class AutocompleteManager {

	/**
	 * 
	 * @param city
	 * @return
	 */
	public List<String> getAirports(String city) {
		List<String> airports = new ArrayList<String>();
		PreparedStatement ps = null;
		String data;
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		Connection con = session.connection();
		try {
			ps = con.prepareStatement("SELECT airport, code FROM airports where airport like ?");
			ps.setString(1, city + "%");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				data = rs.getString("airport") + " - " + rs.getString("code");
				airports.add(data);
			}
		} catch (Exception e) {
			System.out.println(e.getMessage());
		} finally {
			session.getTransaction().commit();
		}

		return airports;
	}
}
