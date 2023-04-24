int main(void){
	extern int _test_start;
	extern int mul1;
	extern int mul2;
	int a,b,i;
	int L1,L2,H1,H2;
	

	H1 = ((*(&mul1))>>16);
	H2 = ((*(&mul2))>>16) ;
	L1 = ((*(&mul1)) << 16) >> 16;
	L2 = ((*(&mul2)) << 16) >> 16;

	*(&_test_start) = (L1*L2) + ((L1*H2+L2*H1)<<16);
	*(&_test_start+1) = H1*H2 + (((L1*H2+L2*H1)>>16));

	
	return 0;
}
