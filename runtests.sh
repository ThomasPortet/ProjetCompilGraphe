for i in tests/*.c
do
	echo $i
	./executable < $i | dot -Tpdf -o "tests_results/$i.pdf"
done
for i in testsPersos/*.c
do
	echo $i
	./executable < $i | dot -Tpdf -o "tests_results/$i.pdf"
done
