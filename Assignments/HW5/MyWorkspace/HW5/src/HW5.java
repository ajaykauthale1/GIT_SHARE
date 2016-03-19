import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;

/**
 * 
 */

/**
 * @author Ajay Kauthale
 *
 * Version 1.0
 */
public class HW5 {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// Get relevance judgments
		Map<Integer, List<String>> judgementMap = getRelevantDocIds("resources\\input\\cacm.rel");
		// Get HW4 results for given queries
		Map<Integer, List<String>> actualMap12 = getActualResultMap("resources\\input\\q1.txt", 12);
		Map<Integer, List<String>> actualMap13 = getActualResultMap("resources\\input\\q2.txt", 13);
		Map<Integer, List<String>> actualMap19 = getActualResultMap("resources\\input\\q3.txt", 19);
		// Get Ideal ranking results for given queries
		Map<Integer, List<String>> idealMap12 = getActualResultMap("resources\\input\\q1-ideal.txt", 12);
		Map<Integer, List<String>> idealMap13 = getActualResultMap("resources\\input\\q2-ideal.txt", 13);
		Map<Integer, List<String>> idealMap19 = getActualResultMap("resources\\input\\q3-ideal.txt", 19);
	
		// Calculate the precision for each document
		System.out.println("RESULTS FOR HW4:");
		System.out.println("Precision:");
		Map<Integer, Double> query12prec = getPrecision(actualMap12, judgementMap);
		Map<Integer, Double> query13prec = getPrecision(actualMap13, judgementMap);
		Map<Integer, Double> query19prec = getPrecision(actualMap19, judgementMap);
		
		// Calculate the recall for each document
		Map<Integer, Double> query12rec = getRecall(actualMap12, judgementMap);
		Map<Integer, Double> query13rec = getRecall(actualMap13, judgementMap);
		Map<Integer, Double> query19rec = getRecall(actualMap19, judgementMap);
		
		// Calculate the NDCG for each document
		Map<String, Double> query12ndcg = getNDCG(actualMap12, judgementMap, idealMap12);
		Map<String, Double> query13ndcg = getNDCG(actualMap13, judgementMap, idealMap13);
		Map<String, Double> query19ndcg = getNDCG(actualMap19, judgementMap, idealMap19);
		
		// Output precision at k=20
		System.out.println("P@20");
		System.out.println("Query 12: " + query12prec.get(20));
		System.out.println("Query 13: " + query13prec.get(20));
		System.out.println("Query 19: " + query19prec.get(20));

		// Calculate MAP for all queries
		System.out.println("MAP:");
		Double avg = (getAvgPrecision(actualMap12, judgementMap) + getAvgPrecision(actualMap13, judgementMap)
				+ getAvgPrecision(actualMap19, judgementMap)) / new Double(3);
		System.out.println(avg);
		
		// Write Results
		writeResult(actualMap12, judgementMap, query12prec, query12rec, query12ndcg);
		writeResult(actualMap13, judgementMap, query13prec, query13rec, query13ndcg);
		writeResult(actualMap19, judgementMap, query19prec, query19rec, query19ndcg);
	}

	/**
	 * Write the results of search engine evaluation
	 * 
	 * @param actualMap the map of actual search engine result
	 * @param judgementMap the relevance judgment map 
	 * @param precision the precision map
	 * @param recall the recall map
	 * @param ndcg the NDCG map
	 */
    public static void writeResult(Map<Integer, List<String>> actualMap, Map<Integer, List<String>> judgementMap
    		, Map<Integer, Double> precision, Map<Integer, Double> recall, Map<String, Double> ndcg) {
    	// Iterator for actual map
    	Iterator<Integer> it = actualMap.keySet().iterator();
    	int qid = 0;
    	
    	// get query id
    	while (it.hasNext()) {
			qid = it.next();
    	}
    	String resultFile = "";
    	
    	// get relevant docs for the query
    	List<String> relevantDocs = judgementMap.get(qid);
    	
    	if (qid == 12) {
    		resultFile = "q1.txt";
    	} else if (qid == 13) {
    		resultFile = "q2.txt";
    	} else if (qid == 19) {
    		resultFile = "q3.txt";
    	}
    	
    	try {
			LineIterator lineit = FileUtils.lineIterator(new File("resources\\input\\" + resultFile), "UTF-8");
			// output stream for result file
			FileOutputStream output = null;
			// Buffer writer for writing the result file
			BufferedWriter writer = null;
			// result file
			File result = new File("resources\\output\\" + qid + ".txt");
			// open the output stream for writing ranking result
			if (output == null) {
				output = new FileOutputStream(result);
			}
			// get buffer writer for writing the file
			writer = new BufferedWriter(new OutputStreamWriter(output));
			writer.write("RANK" + "\tDOC-ID" + "\tSCORE" + "\t\tREL-JUDGMENT" + "\tPRECISION" + "\tRECALL"
					+ "\tNDCG");
			writer.newLine();
			
			while (lineit.hasNext()) {
				// read line
				String line = lineit.nextLine();
				// scanner for reading each word
				Scanner sc = new Scanner(line);
				// read the line
				while(sc.hasNext()) {
					// get rank
					String rank = sc.next();
					rank = rank.substring(0, rank.indexOf("."));
					if (sc.hasNext()) {
						// get document id
						String document = sc.next();
						document = truncateDocumentName(document);
						// get document score
						String score = sc.next();
						score = score.substring(score.indexOf("=") + 1);
						// get relevance judgment
						int relevanceJudgement = 0;
						if (relevantDocs.contains(document)) {
							relevanceJudgement = 1;
						}
						// get precision
						Double pre = precision.get(Integer.parseInt(rank));
						// get recall
						Double rec = recall.get(Integer.parseInt(rank));
						// get ndcg
						Double ndcgVal = ndcg.get(document);
						
						// write the evaluation values into file
						writer.write(rank + "\t\t" + document + "\t" + score + "\t\t" + relevanceJudgement + "\t\t\t"
								+ String.format("%.2f", pre) + "\t\t" + String.format("%.2f", rec)+ "\t" + String.format("%.2f", ndcgVal));
						writer.newLine();
					}
				}
				// close scanner
				sc.close();
			}
			// close writer
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
    }
    
    /**
     * Calculate the precision
     * 
     * @param actualMap the actual map
     * @param judgementMap the judgment map
     * @return the precision map
     */
	public static Map<Integer, Double> getPrecision(Map<Integer, List<String>> actualMap, Map<Integer, List<String>> judgementMap) {
		// Iterator for actual map
		Iterator<Integer> it = actualMap.keySet().iterator();
		Map<Integer, Double> precisionMap = new LinkedHashMap<Integer, Double>();
		// map for storing precision
		int totalRelelevantDocsRetrieved = 0;
		int totalRetrieved = 0;
		int cnt = 1;
		// iterate over map
		while (it.hasNext()) {
			int qid = it.next();
			// get retrieved docs for the query
			List<String> retrievedDocs = actualMap.get(qid);
			// get relevant docs for the query
 			List<String> relevantDocs = judgementMap.get(qid);
 			// for each doc calculate precision
 			for (String doc : retrievedDocs) {
 				if (relevantDocs.contains(doc)) {
 					totalRelelevantDocsRetrieved ++;
 				}
 				totalRetrieved++;
 				// precision calculation
 				Double precision = new Double(totalRelelevantDocsRetrieved) / new Double(totalRetrieved);
 				precisionMap.put(cnt++, precision);
 			}
		}
		
		return precisionMap;
	}

	/**
     * Calculate the recall
     * 
     * @param actualMap the actual map
     * @param judgementMap the judgment map
     * @return the recall map
     */
	public static Map<Integer, Double> getRecall(Map<Integer, List<String>> actualMap, Map<Integer, List<String>> judgementMap) {
		// Iterator for actual map
		Iterator<Integer> it = actualMap.keySet().iterator();
		// map for storing recall
		Map<Integer, Double> recallMap = new LinkedHashMap<Integer, Double>();
		int totalRelelevantDocsRetrieved = 0;
		int cnt = 1;
		// iterate over map
		while (it.hasNext()) {
			int qid = it.next();
			// get retrieved docs for the query
			List<String> retrievedDocs = actualMap.get(qid);
			// get relevant docs for the query
 			List<String> relevantDocs = judgementMap.get(qid);
 			// for each doc calculate recall	
 			for (String doc : retrievedDocs) {
 				if (relevantDocs.contains(doc)) {
 					totalRelelevantDocsRetrieved ++;
 				}
 				
 				// recall calculation
 				Double recall = new Double(totalRelelevantDocsRetrieved) / new Double(relevantDocs.size());
 				recallMap.put(cnt++, recall);
 			}
		}
		
		return recallMap;
	}
	
	/**
	 * Get precision at k = 20
	 * @param precisionMap the precision map
	 * @return the precision at k = 20
	 */
	public static Double getPatK(Map<String, Double> precisionMap) {
		// Iterator for precision map
		Iterator<String> it = precisionMap.keySet().iterator();
		// initial precision
		Double prec = 0.0;
		// counter for precision values
		int cnt = 0;
		while(it.hasNext()) {
			// doc it
			String doc = it.next();
			cnt++;
			// break at k = 20
			if (cnt == 20) {
				// get precision at k = 20
				prec = precisionMap.get(doc);
				break;
			}
		}
		return prec;
	}
	
	/**
	 * Calculate NDCG values
	 * 
	 * @param actualMap the actual map
	 * @param judgementMap the judgment map
	 * @param idealMap the ideal relevance map
	 * @return the NDCG map
	 */
	public static Map<String, Double> getNDCG(Map<Integer, List<String>> actualMap, Map<Integer, List<String>> judgementMap, Map<Integer, List<String>> idealMap) {
		Map<String, Integer> relevanceScale = new LinkedHashMap<String, Integer>();
		Map<String, Double> discountedGain = new LinkedHashMap<String, Double>();
		Map<String, Double> discountedCumulativeGain = new LinkedHashMap<String, Double>();
		Map<String, Double> discountedCumulativeGain1 = new LinkedHashMap<String, Double>();
		Map<String, Double> ndcg = new LinkedHashMap<String, Double>();
		
		Iterator<Integer> it = actualMap.keySet().iterator();
		
		// relevance scale
		while (it.hasNext()) {
			int qid = it.next();
			List<String> retrievedDocs = actualMap.get(qid);
			List<String> relevantDocs = judgementMap.get(qid);
			
			for (String doc : retrievedDocs) {
				if (relevantDocs.contains(doc)) {
					relevanceScale.put(doc, 1);
				} else {
					relevanceScale.put(doc, 0);
				}
			}
		}
		
		// discounted gain
		Iterator<String> rel = relevanceScale.keySet().iterator();
		int i = 1;
		while (rel.hasNext()) {
			String doc = rel.next();
			int relevance = relevanceScale.get(doc);
			Double dc;
			if (i == 1) {
				dc = new Double(relevance);
			} else {
				dc = new Double(relevance) / getLogBase2(i);
			}
			discountedGain.put(doc, dc);
			i++;
		}
		
		// dcg
		Iterator<String> dit = discountedGain.keySet().iterator();
		Double total = 0.0;
		while (dit.hasNext()) {
			String doc = dit.next();
			total += discountedGain.get(doc);
			discountedCumulativeGain.put(doc, total);
		}
		
		////////////////////Ideal//////////////////////////
		it = idealMap.keySet().iterator();
		relevanceScale.clear();
		// relevance scale
		while (it.hasNext()) {
			int qid = it.next();
			List<String> retrievedDocs = idealMap.get(qid);
			List<String> relevantDocs = judgementMap.get(qid);

			for (String doc : retrievedDocs) {
				if (relevantDocs.contains(doc)) {
					relevanceScale.put(doc, 1);
				} else {
					relevanceScale.put(doc, 0);
				}
			}
		}

		// discounted gain
		rel = relevanceScale.keySet().iterator();
		discountedGain.clear();
		i = 1;
		while (rel.hasNext()) {
			String doc = rel.next();
			int relevance = relevanceScale.get(doc);
			Double dc;
			if (i == 1) {
				dc = new Double(relevance);
			} else {
				dc = new Double(relevance) / getLogBase2(i);
			}
			discountedGain.put(doc, dc);
			i++;
		}

		// dcg
		dit = discountedGain.keySet().iterator();
		total = 0.0;
		while (dit.hasNext()) {
			String doc = dit.next();
			total += discountedGain.get(doc);
			discountedCumulativeGain1.put(doc, total);
		}
		
		//ndcg
		Iterator<String> dcgit = discountedCumulativeGain.keySet().iterator();
		Iterator<String> dcgit1 = discountedCumulativeGain1.keySet().iterator();
		while (dcgit.hasNext() && dcgit1.hasNext()) {
			String doc = dcgit1.next();
			String key = dcgit.next();
			Double val = discountedCumulativeGain1.get(doc) / discountedCumulativeGain.get(key);
			ndcg.put(doc, val);
		}
		
		return ndcg;
	}
	
	/**
	 * Get log to the base 2
	 * @param number the number
	 * @return return log2(number)
	 */
	public static Double getLogBase2(int number) {
		return new Double(Math.log(number)) / new Double(Math.log(2));
	}
	
	/**
	 * Get average precision
	 * 
	 * @param actualMap the actual map
	 * @param judgementMap the judgment map
	 * @return the average of precision
	 */
	public static Double getAvgPrecision(Map<Integer, List<String>> actualMap, Map<Integer, List<String>> judgementMap) {
		// Iterator for actual map
		Iterator<Integer> it = actualMap.keySet().iterator();
		Double totalPrecision = 0.0;
		int currentRetrieved  = 0;
		int currentRelevant = 0;
		// the constant for relevant docs
		int rel = 0;
		while(it.hasNext()) {
			int qid = it.next();
			List<String> retrievedDocs = actualMap.get(qid);
 			List<String> relevantDocs = judgementMap.get(qid);
 			
 			for (String doc : retrievedDocs) {
 				if (relevantDocs.contains(doc)) {
 					rel++;
 				}
 			}
		}
		
		it = actualMap.keySet().iterator();
		while(it.hasNext()) {
			int qid = it.next();
			// get actual docs
			List<String> retrievedDocs = actualMap.get(qid);
			// get relevant docs
 			List<String> relevantDocs = judgementMap.get(qid);
 			
 			for (String doc : retrievedDocs) {
 				if (rel == currentRelevant) {
 					break;
 				}
 				if (relevantDocs.contains(doc)) {
 					currentRetrieved++;
 					currentRelevant++;
 					// calculate precision total cumulatively only for relevant docs
 					totalPrecision += getCurrentPrecision(currentRelevant, currentRetrieved);
 				} else {
 					currentRetrieved++;
 				}
 			}
		}
		
		// return average of precision
		return totalPrecision / new Double(rel);
	}
	
	/**
	 * Get current precision
	 * 
	 * @param relevantDocsRetrieved the number of relevance docs retrieved
	 * @param retrievedDocs the number of retrieved docs 
	 * @return the current precision
	 */
	public static Double getCurrentPrecision(int relevantDocsRetrieved, int retrievedDocs) {
		return (new Double(relevantDocsRetrieved)/ new Double(retrievedDocs));
	}
	
	/**
	 * Get relevant doc id's
	 * 
	 * @param inputFile the input file string
	 * @return the map of relevant doc id's
	 */
	public static Map<Integer, List<String>> getRelevantDocIds(String inputFile) {
		Map<Integer, List<String>> judgementMap = new LinkedHashMap<Integer, List<String>>();
		try {
			LineIterator it = FileUtils.lineIterator(new File(inputFile), "UTF-8");
			
			// iterate over each line
			while (it.hasNext()) {
				// read line
				String line = it.nextLine();
				// scanner for reading each word
				Scanner sc = new Scanner(line);
				
				while(sc.hasNext()) {
					String id = sc.next();
					
					if (!id.equals("12") && !id.equals("13") && !id.equals("19")) {
						break;
					}
					// skip Q0
					sc.next();
					
					String document = sc.next();
					String flag = sc.next();
					document = document.substring(document.indexOf("-") + 1);
					int queryId = Integer.parseInt(id);
					List<String> docList = new LinkedList<String>();
					
					if (flag.equals("1")) {
						if (judgementMap.containsKey(queryId)) {
							docList = judgementMap.get(queryId);
							docList.add(document);
							judgementMap.put(queryId, docList);
						} else {
							docList.add(document);
							judgementMap.put(queryId, docList);	
						}
					}
				}
				
				sc.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return judgementMap;
	}
	
	/**
	 * Get actual result map
	 * 
	 * @param resultFile the input file string
	 * @param queryId the query id
	 * @return the map after reading the input file
	 */
	public static Map<Integer, List<String>> getActualResultMap(String resultFile, int queryId) {
		Map<Integer, List<String>> actualMap = new LinkedHashMap<Integer, List<String>>();
		
		try {
			LineIterator it = FileUtils.lineIterator(new File(resultFile), "UTF-8");
			
			while (it.hasNext()) {
				// read line
				String line = it.nextLine();
				// scanner for reading each word
				Scanner sc = new Scanner(line);
				
				while(sc.hasNext()) {
					sc.next();
					if (sc.hasNext()) {
						String document = sc.next();
						document = truncateDocumentName(document);
						List<String> docList = new LinkedList<String>();
						
						if (actualMap.containsKey(queryId)) {
							docList = actualMap.get(queryId);
							docList.add(document);
							actualMap.put(queryId, docList);
						} else {
							docList.add(document);
							actualMap.put(queryId, docList);	
						}
					}
				}
				sc.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	
		return actualMap;
	}
	
	/**
	 * Get document id
	 * @param document documetn name
	 * @return the document id by truncating CACM-
	 */
	public static String truncateDocumentName(String document) {
		return document.substring(document.indexOf("-") + 1, document.lastIndexOf("."));
	}
}
