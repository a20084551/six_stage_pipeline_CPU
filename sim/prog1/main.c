int main(void){
	extern int array_size;
	extern int array_addr;
	extern int _test_start;
	int i,j,k;

	int temp0,temp1,temp2;

	for(i=0;i<array_size;i++){
	  *(&_test_start+i) = *(&array_addr+i);
	}
	
	for(j=0;j<array_size;j++){
	  	  
	  for(k=0;k<array_size-j-1;k++){
	    if(*(&_test_start+k)>*(&_test_start+k+1)){
	      temp0 = *(&_test_start+k);
	      temp1 = *(&_test_start+k+1);
	      *(&_test_start+k)   = temp1;
	      *(&_test_start+k+1) = temp0;

	     }
	    
	   }
	  
	 }
	
	

	
	return 0;
}
