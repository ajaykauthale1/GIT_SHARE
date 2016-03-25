/**
 * 
 */
package com.easyair.controller;

import com.easyair.model.beans.PaymentDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
public class PaymentManager {

	/**
	 * 
	 * @param bean
	 */
	public void storePaymentInfo(PaymentDataBean bean) {
		HibernateUtil.persist(bean);
	}
	
	/**
	 * 
	 * @param bean
	 */
	public void updateOrder(Long scheduleId, UserBean user) {
		
	}
}
