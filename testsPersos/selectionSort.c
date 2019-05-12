extern int printd(int i);
extern void swap(int xp, int yp);
  
void selectionSort(int arr, int n) 
{ 
    int i, j, min_idx; 
  
    /* One by one move boundary of unsorted subarray */
    for (i = 0; i < n-1; i=i+1) 
    { 
        /* Find the minimum element in unsorted array */
        min_idx = i; 
        for (j = i+1; j < n; j=j+1) 
          if (arr[j] < arr[min_idx]) 
            min_idx = j; 
  
        /* Swap the found minimum element with the first element */
        swap(arr[min_idx], arr[i]); 
    } 
} 
  
/* Function to print an array */
void printArray(int arr, int size) 
{ 
    int i; 
    for (i=0; i < size; i=i+1) 
        printd(arr[i]);
} 
  
/* Driver program to test above functions */
int main() 
{ 
    int arr[5];
    arr[0] = 64;
    arr[1] = 25;
    arr[2] = 12;
    arr[3] = 22;
    arr[4] = 11;
    selectionSort(arr, 5); 
    printArray(arr, 5); 
    return 0; 
} 
