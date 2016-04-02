/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.classic.Session;

import com.easyair.model.beans.UserBean;
import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
public class LoginManager extends HibernateUtil {

	@SuppressWarnings("unchecked")
	/**
	 * 
	 * @return
	 */
	public List<UserBean> list() {

		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<UserBean> users = null;
		try {

			users = (List<UserBean>) session.createQuery("from UserBean").list();

		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return users;
	}
	
	/**
	 * 
	 * @param email
	 * @param password
	 * @return
	 */
	public boolean authenticate(String email, String password, Session session) throws SQLException{
		Connection con = session.connection();
			PreparedStatement stmt = con.prepareStatement("select count(*) from user where email=? and password=?");
			stmt.setString(1, email);
			stmt.setString(2, password);
			
			ResultSet rs = stmt.executeQuery();
			if (rs.next()) 
			{
				int count = rs.getInt(1);
				if (count == 1) {
					return true;
				}
			}
		
		return false;
	}
	
	/**
	 * 
	 * @param email
	 * @param password
	 * @return
	 */
	public UserBean getUser(String email, String password) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		UserBean user = null;
		session.beginTransaction();
		try {
			if (authenticate(email, password, session)) {
				String queryString = "from UserBean where email = :email";
				Query query = session.createQuery(queryString);
				query.setString("email", email);
				user = (UserBean) query.uniqueResult();
			}
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return user;
	}
}
