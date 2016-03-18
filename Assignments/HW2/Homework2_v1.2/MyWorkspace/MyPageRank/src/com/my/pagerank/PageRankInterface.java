/**
 * Interface for page rank
 */
package com.my.pagerank;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

/**
 * @author Ajay Kauthale
 * 
 * @version 1.1
 */
public interface PageRankInterface {

	/**
	 * Method for calculation of the PageRank using page ranking algorithm
	 * 
	 * @return Map<String, Page> - the map of <Key, Value> as <PageId, Page>
	 *         with calculated page rank for each page
	 */
	Map<String, Page> calculatePageRank(Map<String, Page> pageMap);

	/**
	 * Method for checking if the convergence of the page rank values happen
	 * 
	 * @param pageMap
	 *            the page map from the TREC collection
	 * @return boolean - true iff page rank values has been converged
	 */
	boolean isConverged(Map<String, Page> pageMap);

	/**
	 * Method for getting all sink nodes for the TREC collection "Sink Node"
	 * term refer to the pages which do not have any out-links
	 * 
	 * @param pageMap
	 *            the page map from the TREC collection
	 * @return Set<Page> - the set of sink nodes (pages)
	 */
	Set<Page> getSinkNodes(Map<String, Page> pageMap);
	
	/**
	 * Method for getting all source nodes for the TREC collection "Source Node"
	 * term refer to the pages which do not have any in-links
	 * 
	 * @param pageMap
	 *            the page map from the TREC collection
	 * @return Set<Page> - the set of source nodes (pages)
	 */
	Set<Page> getSourceNodes(Map<String, Page> pageMap);
	
	/**
	 * Method for getting all source nodes from the TREC collection whose
	 * final page rank is less than initial uniform page rank (1/N)
	 * 
	 * @param pageMap
	 *            the page map from the TREC collection
	 * @return Set<Page> - the set of source nodes (pages)
	 */
	 Set<Page> getNodesWithFinalPRLessThanInitial(Map<String, Page> pageMap);

	/**
	 * Method which is used for reading the TREC collection and forming the page
	 * map. In this method, the in-links and out-links are also stored for each
	 * page.
	 * 
	 * @param pageMap
	 *            the page map from the TREC collection
	 * @return Map<String, Page> - the initial map of <Key, Value> as <PageId,
	 *         Page>
	 */
	Map<String, Page> readTRECCollection(Map<String, Page> pageMap) throws IOException;
}
