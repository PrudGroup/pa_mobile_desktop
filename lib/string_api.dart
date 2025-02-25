extension StringLookup on String {
  bool containsAny(List<String> searchList) {
    if(searchList.isNotEmpty){
      for(int i = 0; i < searchList.length; i++){
        if(contains(searchList[i])){
          return true;
        }
      }
      return false;
    }else{
      return false;
    }
  }
}