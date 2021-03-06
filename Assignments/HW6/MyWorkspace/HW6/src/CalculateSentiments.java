
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;

public class CalculateSentiments {
	//Use to get positive and negative sentiments
	public HashMap<String,Integer> getSentiment(HashMap<String ,Integer>sentiments, String inputDir) throws IOException
	{
		int count=0;
		File dir = new File(inputDir);
        File[] files = dir.listFiles();
        for (File f : files) {
            if(f.isFile()) {
                BufferedReader inputStream = null;
                inputStream = new BufferedReader(new FileReader(f));
        String line;

        while ((line = inputStream.readLine()) != null) {
        String tokens[]=line.split(" ");
        for(int i=0;i<tokens.length;i++)
        {
        	
        	if(sentiments.containsKey(tokens[i]))
        	{
        		sentiments.put(tokens[i], sentiments.get(tokens[i])+1);
        	}
        	else
        	{
        		sentiments.put(tokens[i],1);
        	}
        }
        }}}

		
		return sentiments;
		
	}
//This function is use to calculate total  vocubulary size and remove words whoose positive and negative count is greater than 5
	public HashMap<String, Integer> calculateVocubularySize(HashMap<String, Integer> vocubularySize,
			HashMap<String, Integer> sentiments) {
		Iterator<String> itr = sentiments.keySet().iterator();

		while (itr.hasNext()) {
			String term = itr.next();
			if (vocubularySize.containsKey(term)) {
				vocubularySize.put(term, vocubularySize.get(term) + sentiments.get(term));
			} else {
				vocubularySize.put(term, sentiments.get(term));
			}
		}
		return vocubularySize;

	}
// Use to remove terms from positive and negative vocubulary	
  public HashMap<String,Integer>removeTerms(HashMap<String,Integer>positiveSentiment, HashMap<String,Integer>vocubularysize)
  {
	 HashMap<String,Integer>sentiment=new HashMap<String,Integer>();
	 Iterator<String> itr =vocubularysize.keySet().iterator();
	 while (itr.hasNext()) {
			String term = itr.next();
			if(vocubularysize.get(term) >= 5)
			{
				if (positiveSentiment.containsKey(term)) {
					sentiment.put(term,positiveSentiment.get(term));
				} else {
					sentiment.put(term,0);
				}
			
			}
	 }
	return sentiment;
	  
  
  }
  //Use to calculate probability of all terms
  public HashMap<String,Double> calculateProbability(HashMap<String,Integer>sentiments,int count,HashMap<String,Integer>vocubularySize)
  {
	Iterator<String> it = sentiments.keySet().iterator();
	HashMap<String,Double> wordNegProbMap=new HashMap<String,Double>();
		
			while (it.hasNext()) {
				String term = it.next();
				// negative
				int negCount = sentiments.get(term);
				Double prob = new Double(negCount + 1) / new Double(count + vocubularySize.size());
				wordNegProbMap.put(term, prob);
			} 
	return wordNegProbMap;
	  
  }
  //Use to write terms to model files.
  public void writeModel(HashMap<String,Integer>vocubularySize,HashMap<String, Double>wordPosProbMap,
		  HashMap<String, Double>wordNegProbMap, String modelFile) throws IOException
  { 
	  BufferedWriter writer=new BufferedWriter(new FileWriter(modelFile));
	  Iterator<String> it = vocubularySize.keySet().iterator();
	  while (it.hasNext())
	  {
		  String term = it.next();
		  double pos=0;
		  double neg=0;
		  if(wordPosProbMap.containsKey(term))
		  {
			  pos=wordPosProbMap.get(term);
			  pos=Math.log(pos);
		  }
		  if(wordNegProbMap.containsKey(term))
		  {
			  neg=wordNegProbMap.get(term);
			  neg=Math.log(neg);
		  }
		  writer.write(term+" "+pos+" "+neg+"\n");  
	  }
	  writer.close();
  }
}
