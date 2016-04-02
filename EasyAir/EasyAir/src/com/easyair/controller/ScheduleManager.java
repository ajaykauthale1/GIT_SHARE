/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.classic.Session;

import com.easyair.dto.ScheduleDto;
import com.easyair.mapper.scheduleMapper;
import com.easyair.model.beans.AirlineDataBean;
import com.easyair.model.beans.FlightDataBean;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
@SuppressWarnings("deprecation")
public class ScheduleManager extends HibernateUtil {
	
	/**
	 * 
	 * @return
	 */
	public List<FlightDataBean> getFlights() {

		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<FlightDataBean> flights = null;
		try {

			flights = (List<FlightDataBean>) session.createQuery("from FlightDataBean").list();

		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flights;
	}
	
	/**
	 * 
	 * @return
	 */
	public List<FlightDataBean> getFlights(String source, String destination) {

		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<FlightDataBean> flights = null;
		try {
			String queryString = "from FlightDataBean where source = :source and destination = :destination";
			Query query = session.createQuery(queryString);
			query.setString("source", source);
			query.setString("destination", destination);
			flights = (List<FlightDataBean>) query.list();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flights;
	}
	
	/**
	 * 
	 * @param flightId
	 * @return
	 */
	public Set<ScheduleDataBean> getFlightSchedules(Long flightId) {
		Set<ScheduleDataBean> schedules = new HashSet<>();
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		FlightDataBean flight = null;
		try {
			String queryString = "from FlightDataBean where flightId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", flightId);
			flight = (FlightDataBean) query.uniqueResult();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flight.getSchedules();
	}
	
	/**
	 * 
	 * @param airlineId
	 * @return
	 */
	public String getAirlineName(Long airlineId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		String airlineName = null;
		try {
			String queryString = "from AirlineDataBean where airlineId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", airlineId);
			airlineName = ((AirlineDataBean) query.uniqueResult()).getName();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return airlineName;
	}
	
	/**
	 * 
	 * @param source
	 * @param destination
	 * @return
	 */
	public List<ScheduleDto> getSchedules(String source, String destination, Date departureDate) {
		scheduleMapper mapper = new scheduleMapper();
		return mapper.getScheduleDtoList(source, destination, departureDate);
	}
	
	public String getAirport(String code) {
		String airport = null;
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select airport from airports where code=?");
			stmt.setString(1, code);
			
			ResultSet rs = stmt.executeQuery();
			if (rs.next()) 
			{
				airport = code + " - " + rs.getString(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			session.getTransaction().commit();
		}
		return airport;
	}
	
	/**
	 * 
	 * @param scheduleId
	 * @return
	 */
	public ScheduleDataBean getSchedule(Long scheduleId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		ScheduleDataBean schedule = null;
		session.beginTransaction();
		try {
				String queryString = "from ScheduleDataBean where scheduleId = :id";
				Query query = session.createQuery(queryString);
				query.setLong("id", scheduleId);
				schedule = (ScheduleDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return schedule;
	}
}
