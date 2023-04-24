int main(void)
{
	extern int _test_start;
	extern int div1;
	extern int div2;
	int a, b, t; 
	
	if(*(&div1) > *(&div2))
	{	
		a = *(&div1);
		b = *(&div2);
	}
	else
	{	
		a = *(&div2);
		b = *(&div1);
	}	
		
    while(b != 0 )
    {
        t = b;
        b = a % b;
        a = t;
    }
    
	
	*(&_test_start) = t;
	
}

