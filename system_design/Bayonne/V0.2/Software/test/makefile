CC=g++
CFLAGS=-Wall -g

testLstm:
	$(CC) $(CFLAGS) -o test.out test-lstm/test-lstm.cpp test-lstm/model-loading.cpp ../Arduino/signal-compensation/lstm.cpp ../Arduino/signal-compensation/linear-algebra.cpp
	./test.out

debugLstm:
	$(CC) $(CFLAGS) -o test.out test-lstm/test-lstm.cpp test-lstm/model-loading.cpp ../Arduino/signal-compensation/lstm.cpp ../Arduino/signal-compensation/linear-algebra.cpp
	gdb ./test.out

testReduced:
	$(CC) $(CFLAGS) -o test.out test-reduced/test-reduced.cpp test-reduced/model-loading.cpp ../Arduino/compressed-compensation/reduced-lstm.cpp ../Arduino/compressed-compensation/linear-algebra.cpp
	./test.out
