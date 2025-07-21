String convertTagsToString(List<String> tags){
  if(tags.isNotEmpty){
    String res = "";
    for(String tag in tags){
      res += "#$tag ";
    }
    return res;
  }else{
    return "";
  }
}