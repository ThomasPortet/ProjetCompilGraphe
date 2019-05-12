for i in tests/*.c
do
	./executable < $i | dot -Tpdf -o "tests_results/$i.pdf"
done
