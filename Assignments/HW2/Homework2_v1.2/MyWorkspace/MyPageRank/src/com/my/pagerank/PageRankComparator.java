/**
 * Comparator for sorting the map of pages based on their page rank
 */
package com.my.pagerank;

import java.util.Comparator;
import java.util.Map;

/**
 * @author Ajay Kauthale
 *
 * @version 1.1
 */
public class PageRankComparator implements Comparator<Map.Entry<String, Double>> {
	@Override
	public int compare(Map.Entry<String, Double> o1, Map.Entry<String, Double> o2) {
		return o2.getValue().compareTo(o1.getValue());
	}
}
